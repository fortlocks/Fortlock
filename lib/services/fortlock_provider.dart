import 'package:flutter/foundation.dart';
import '../models/system_status.dart';
import '../models/access_history.dart';
import '../models/guest_access.dart';
import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/photo_evidence.dart';
import '../services/mqtt_service.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';

class FortlockProvider extends ChangeNotifier {
  final MqttService mqttService = MqttService();
  final FirebaseService firebaseService = FirebaseService();
  final AuthService authService = AuthService();

  SystemStatus systemStatus = SystemStatus();
  List<AccessHistory> history = [];
  List<GuestAccess> guestList = [];
  List<AppNotification> notifications = [];
  List<AppUser> userList = [];
  List<PhotoEvidence> evidenceList = [];
  bool mqttConnected = false;
  String? mqttError;
  List<String> mqttLog = [];

  AppUser? currentUser;

  String? _lastAlarmState;
  String? _lastModeState;
  String? _lastPintuState;
  final Map<String, DateTime> _lastNotifTime = {};

  bool _canNotify(String key, {int cooldownSeconds = 30}) {
    final last = _lastNotifTime[key];
    if (last == null || DateTime.now().difference(last).inSeconds > cooldownSeconds) {
      _lastNotifTime[key] = DateTime.now();
      return true;
    }
    return false;
  }

  Future<void> init() async {
    await NotificationService.init();
    currentUser = await authService.getCurrentAppUser();
    notifyListeners();

    mqttService.connectionStream.listen((connected) {
      mqttConnected = connected;
      if (connected) mqttError = null;
      notifyListeners();
      if (!connected) {
        Future.delayed(const Duration(seconds: 5), () {
          if (!mqttConnected) mqttService.connect();
        });
      }
    });

    mqttService.errorStream.listen((error) {
      mqttError = error;
      mqttLog.add(error);
      if (mqttLog.length > 20) mqttLog.removeAt(0);
      notifyListeners();
    });

    await mqttService.connect();

    mqttService.statusStream.listen(_handleMqttStatus);
    mqttService.accessStream.listen(_handleAccessEvent);
    mqttService.alarmStream.listen(_handleAlarmEvent);

    firebaseService.watchSystemStatus().listen((status) {
      systemStatus = status;
      notifyListeners();
    }, onError: (e) => _logFirebaseError('system_status', e));

    firebaseService.watchHistory().listen((list) {
      history = list;
      notifyListeners();
    }, onError: (e) => _logFirebaseError('history', e));

    firebaseService.watchGuestAccess().listen((list) {
      guestList = list;
      notifyListeners();
      _checkExpiredGuests(list);
    }, onError: (e) => _logFirebaseError('guest_access', e));

    firebaseService.watchNotifications().listen((list) {
      notifications = list;
      notifyListeners();
    }, onError: (e) => _logFirebaseError('notifications', e));

    firebaseService.watchPhotoEvidence().listen((list) {
      evidenceList = list;
      notifyListeners();
    }, onError: (e) => _logFirebaseError('photo_evidence', e));

    authService.watchUsers().listen((list) {
      userList = list;
      notifyListeners();
    }, onError: (e) => _logFirebaseError('users', e));
  }

  Future<void> refreshCurrentUser() async {
    currentUser = await authService.getCurrentAppUser();
    notifyListeners();
  }

  void _handleMqttStatus(Map<String, dynamic> data) {
    final updates = <String, dynamic>{};
    if (data.containsKey('pintu')) updates['pintu'] = data['pintu'];
    if (data.containsKey('kunci')) updates['kunci'] = data['kunci'];
    if (data.containsKey('alarm')) updates['alarm'] = data['alarm'];
    if (data.containsKey('esp32')) updates['esp32'] = data['esp32'];
    if (data.containsKey('mode')) updates['mode'] = data['mode'];

    if (updates.isNotEmpty) {
      systemStatus = systemStatus.copyWith(
        pintu: updates['pintu'],
        kunci: updates['kunci'],
        alarm: updates['alarm'],
        esp32: updates['esp32'],
        mode: updates['mode'],
        lastUpdate: DateTime.now(),
      );
      notifyListeners();
      firebaseService.updateSystemStatus(updates);
      _checkAlertConditions(updates);
    }
  }

  void _handleAlarmEvent(Map<String, dynamic> data) {
    final state = data['raw'] ?? data['state'];
    if (state == 'ALARM_ON' && _lastAlarmState != 'on') {
      if (_canNotify('alarm')) {
        _notifyAndLog('Alarm Aktif', 'Sensor mendeteksi aktivitas tidak normal di pintu.', 'danger');
      }
      _lastAlarmState = 'on';
    } else if (state == 'ALARM_OFF') {
      _lastAlarmState = 'off';
    }
  }

  void _checkAlertConditions(Map<String, dynamic> updates) {
    if (updates['alarm'] == 'on' && _lastAlarmState != 'on' && _canNotify('alarm')) {
      _notifyAndLog('Alarm Aktif', 'Sensor mendeteksi aktivitas tidak normal di pintu.', 'danger');
    }
    _lastAlarmState = updates['alarm'] ?? _lastAlarmState;

    if (updates['mode'] == 'panic' && _lastModeState != 'panic' && _canNotify('panic')) {
      _notifyAndLog('Mode Panic', 'Sistem dalam mode panic. Periksa kondisi rumah segera.', 'danger');
    }
    _lastModeState = updates['mode'] ?? _lastModeState;

    if (updates['pintu'] == 'open' && _lastPintuState != 'open' && _canNotify('pintu_open')) {
      _notifyAndLog('Pintu Dibuka', 'Pintu baru saja dibuka.', 'info');
    } else if (updates['pintu'] == 'closed' && _lastPintuState != 'closed' && _canNotify('pintu_closed')) {
      _notifyAndLog('Pintu Ditutup', 'Pintu baru saja ditutup.', 'info');
    }
    _lastPintuState = updates['pintu'] ?? _lastPintuState;
  }

  void _notifyAndLog(String judul, String pesan, String type) {
    NotificationService.show(title: judul, body: pesan);
    firebaseService.addNotification(AppNotification(
      id: '',
      judul: judul,
      pesan: pesan,
      timestamp: DateTime.now(),
      type: type,
    ));
  }

  void _logFirebaseError(String source, Object error) {
    final message = 'Firebase error [$source]: $error';
    mqttLog.add(message);
    if (mqttLog.length > 20) mqttLog.removeAt(0);
    notifyListeners();
  }

  void _handleAccessEvent(Map<String, dynamic> data) {
    final entry = AccessHistory(
      id: '',
      nama: data['nama'] ?? 'Tidak diketahui',
      rfidUid: data['uid'] ?? data['rfid_uid'] ?? data['raw'] ?? '',
      timestamp: DateTime.now(),
      status: data['status'] ?? 'failed',
      jenis: data['jenis'] ?? 'rfid',
      keterangan: data['keterangan'] ?? '',
    );
    firebaseService.addHistory(entry);

    if (entry.status != 'success') {
      if (_canNotify('rfid_unknown', cooldownSeconds: 10)) {
        _notifyAndLog('RFID Tidak Dikenal', 'Percobaan akses dengan RFID tidak dikenal.', 'warning');
      }
    }
  }

  void _checkExpiredGuests(List<GuestAccess> list) {
    for (final guest in list) {
      if (guest.isActive && guest.isExpiredNow()) {
        firebaseService.updateGuestStatus(guest.id, 'expired');
      }
    }
  }

  void lockDoor() => mqttService.lockDoor();
  void unlockDoor() => mqttService.unlockDoor();
  void alarmOn() => mqttService.alarmOn();
  void alarmOff() => mqttService.alarmOff();

  void triggerPanic() {
    mqttService.triggerPanic();
    if (_canNotify('panic', cooldownSeconds: 60)) {
      _notifyAndLog('Panic Mode', 'Panic Mode diaktifkan. Semua akses sementara dinonaktifkan.', 'danger');
    }
  }

  Future<void> addGuest(GuestAccess guest) async {
    await firebaseService.addGuestAccess(guest);
  }

  Future<void> removeGuest(GuestAccess guest) async {
    await firebaseService.deleteGuestAccess(guest.id);
  }

  Future<void> logout() async {
    await authService.logout();
    currentUser = null;
    notifyListeners();
  }

  @override
  void dispose() {
    mqttService.dispose();
    super.dispose();
  }
}
