import 'package:flutter/foundation.dart';
import '../models/system_status.dart';
import '../models/access_history.dart';
import '../models/guest_access.dart';
import '../models/app_notification.dart';
import '../services/mqtt_service.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';

class FortlockProvider extends ChangeNotifier {
  final MqttService mqttService = MqttService();
  final FirebaseService firebaseService = FirebaseService();

  SystemStatus systemStatus = SystemStatus();
  List<AccessHistory> history = [];
  List<GuestAccess> guestList = [];
  List<AppNotification> notifications = [];
  bool mqttConnected = false;

  String? _lastAlarmState;
  String? _lastModeState;

  Future<void> init() async {
    await NotificationService.init();
    await mqttService.connect();

    mqttService.connectionStream.listen((connected) {
      mqttConnected = connected;
      notifyListeners();
    });

    mqttService.statusStream.listen((data) {
      _handleMqttStatus(data);
    });

    mqttService.accessLogStream.listen((data) {
      _handleAccessLog(data);
    });

    firebaseService.watchSystemStatus().listen((status) {
      systemStatus = status;
      notifyListeners();
    });

    firebaseService.watchHistory().listen((list) {
      history = list;
      notifyListeners();
    });

    firebaseService.watchGuestAccess().listen((list) {
      guestList = list;
      notifyListeners();
      _checkExpiredGuests(list);
    });

    firebaseService.watchNotifications().listen((list) {
      notifications = list;
      notifyListeners();
    });
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

  void _checkAlertConditions(Map<String, dynamic> updates) {
    if (updates['alarm'] == 'on' && _lastAlarmState != 'on') {
      NotificationService.show(
        title: '🚨 Alarm Aktif!',
        body: 'Sensor mendeteksi aktivitas tidak normal di pintu.',
      );
      firebaseService.addNotification(AppNotification(
        id: '',
        judul: 'Alarm Aktif',
        pesan: 'Sensor mendeteksi aktivitas tidak normal di pintu.',
        timestamp: DateTime.now(),
        type: 'danger',
      ));
    }
    _lastAlarmState = updates['alarm'] ?? _lastAlarmState;

    if (updates['mode'] == 'panic' && _lastModeState != 'panic') {
      NotificationService.show(
        title: '🆘 Mode Panic Diaktifkan',
        body: 'Sistem dalam mode panic. Periksa kondisi rumah segera.',
      );
      firebaseService.addNotification(AppNotification(
        id: '',
        judul: 'Mode Panic',
        pesan: 'Sistem dalam mode panic. Periksa kondisi rumah segera.',
        timestamp: DateTime.now(),
        type: 'danger',
      ));
    }
    _lastModeState = updates['mode'] ?? _lastModeState;
  }

  void _handleAccessLog(Map<String, dynamic> data) {
    final entry = AccessHistory(
      id: '',
      nama: data['nama'] ?? 'Tidak diketahui',
      rfidUid: data['rfid_uid'] ?? data['raw'] ?? '',
      timestamp: DateTime.now(),
      status: data['status'] ?? 'failed',
      jenis: data['jenis'] ?? 'rfid',
      keterangan: data['keterangan'] ?? '',
    );
    firebaseService.addHistory(entry);

    if (entry.status != 'success') {
      NotificationService.show(
        title: '⚠️ Akses Ditolak',
        body: 'RFID tidak dikenal mencoba mengakses pintu.',
      );
    }
  }

  void _checkExpiredGuests(List<GuestAccess> list) {
    for (final guest in list) {
      if (guest.isActive && guest.isExpiredNow()) {
        firebaseService.updateGuestStatus(guest.id, 'expired');
        mqttService.revokeGuestRfid(guest.rfidUid);
      }
    }
  }

  void lockDoor() {
    mqttService.lockDoor();
  }

  void unlockDoor() {
    mqttService.unlockDoor();
  }

  void silenceAlarm() {
    mqttService.triggerAlarmOff();
  }

  void triggerPanic() {
    mqttService.triggerPanic();
  }

  void cancelPanic() {
    mqttService.cancelPanic();
  }

  Future<void> addGuest(GuestAccess guest) async {
    await firebaseService.addGuestAccess(guest);
    mqttService.registerGuestRfid(guest.rfidUid);
  }

  Future<void> removeGuest(GuestAccess guest) async {
    await firebaseService.deleteGuestAccess(guest.id);
    mqttService.revokeGuestRfid(guest.rfidUid);
  }

  @override
  void dispose() {
    mqttService.dispose();
    super.dispose();
  }
}
