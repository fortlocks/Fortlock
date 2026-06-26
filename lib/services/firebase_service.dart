import 'package:firebase_database/firebase_database.dart';
import '../models/access_history.dart';
import '../models/guest_access.dart';
import '../models/app_notification.dart';
import '../models/system_status.dart';

class FirebaseService {
  final DatabaseReference _root = FirebaseDatabase.instance.ref();

  Stream<SystemStatus> watchSystemStatus() {
    return _root.child('system_status').onValue.map((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        return SystemStatus.fromMap(data);
      }
      return SystemStatus();
    });
  }

  Future<void> updateSystemStatus(Map<String, dynamic> updates) async {
    updates['last_update'] = DateTime.now().toIso8601String();
    await _root.child('system_status').update(updates);
  }

  Stream<List<AccessHistory>> watchHistory({int limit = 50}) {
    return _root
        .child('history')
        .orderByChild('timestamp')
        .limitToLast(limit)
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        final list = data.entries
            .map((e) => AccessHistory.fromMap(
                e.key.toString(), e.value as Map<dynamic, dynamic>))
            .toList();
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return list;
      }
      return <AccessHistory>[];
    });
  }

  Future<void> addHistory(AccessHistory history) async {
    await _root.child('history').push().set(history.toMap());
  }

  Stream<List<GuestAccess>> watchGuestAccess() {
    return _root.child('guest_access').onValue.map((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        final list = data.entries
            .map((e) => GuestAccess.fromMap(
                e.key.toString(), e.value as Map<dynamic, dynamic>))
            .toList();
        list.sort((a, b) => b.tanggalMulai.compareTo(a.tanggalMulai));
        return list;
      }
      return <GuestAccess>[];
    });
  }

  Future<void> addGuestAccess(GuestAccess guest) async {
    await _root.child('guest_access').push().set(guest.toMap());
  }

  Future<void> updateGuestStatus(String guestId, String status) async {
    await _root
        .child('guest_access')
        .child(guestId)
        .update({'status': status});
  }

  Future<void> deleteGuestAccess(String guestId) async {
    await _root.child('guest_access').child(guestId).remove();
  }

  Stream<List<AppNotification>> watchNotifications({int limit = 30}) {
    return _root
        .child('notifications')
        .orderByChild('timestamp')
        .limitToLast(limit)
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        final list = data.entries
            .map((e) => AppNotification.fromMap(
                e.key.toString(), e.value as Map<dynamic, dynamic>))
            .toList();
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return list;
      }
      return <AppNotification>[];
    });
  }

  Future<void> addNotification(AppNotification notif) async {
    await _root.child('notifications').push().set(notif.toMap());
  }

  Future<void> markNotificationRead(String notifId) async {
    await _root
        .child('notifications')
        .child(notifId)
        .update({'read': true});
  }

  Stream<List<Map<String, dynamic>>> watchPhotoEvidence({int limit = 20}) {
    return _root
        .child('photo_evidence')
        .orderByChild('timestamp')
        .limitToLast(limit)
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        final list = data.entries.map((e) {
          final map = Map<String, dynamic>.from(e.value as Map);
          map['id'] = e.key;
          return map;
        }).toList();
        list.sort((a, b) =>
            (b['timestamp'] ?? '').compareTo(a['timestamp'] ?? ''));
        return list;
      }
      return <Map<String, dynamic>>[];
    });
  }
}
