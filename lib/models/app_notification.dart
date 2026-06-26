class AppNotification {
  final String id;
  final String judul;
  final String pesan;
  final DateTime timestamp;
  final String type;
  final bool read;

  AppNotification({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.timestamp,
    this.type = 'info',
    this.read = false,
  });

  factory AppNotification.fromMap(String id, Map<dynamic, dynamic> map) {
    return AppNotification(
      id: id,
      judul: map['judul'] ?? '',
      pesan: map['pesan'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      type: map['type'] ?? 'info',
      read: map['read'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'judul': judul,
      'pesan': pesan,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'read': read,
    };
  }
}
