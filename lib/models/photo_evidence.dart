class PhotoEvidence {
  final String id;
  final String imageUrl;
  final DateTime timestamp;
  final String eventType;
  final String rfidUid;
  final String status;

  PhotoEvidence({
    required this.id,
    required this.imageUrl,
    required this.timestamp,
    required this.eventType,
    this.rfidUid = '',
    this.status = 'Akses Ditolak',
  });

  factory PhotoEvidence.fromMap(String id, Map<dynamic, dynamic> map) {
    return PhotoEvidence(
      id: id,
      imageUrl: map['image_url'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      eventType: map['event_type'] ?? 'unknown',
      rfidUid: map['uid'] ?? '',
      status: map['status'] ?? 'Akses Ditolak',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image_url': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'event_type': eventType,
      'uid': rfidUid,
      'status': status,
    };
  }

  String get eventLabel {
    switch (eventType) {
      case 'unknown_rfid':
        return 'RFID Tidak Dikenal';
      case 'force_open':
        return 'Percobaan Buka Paksa';
      case 'congkel':
        return 'Percobaan Congkel';
      case 'panic':
        return 'Panic Mode Aktif';
      default:
        return 'Kejadian Tidak Dikenal';
    }
  }
}
