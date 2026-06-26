class AccessHistory {
  final String id;
  final String nama;
  final String rfidUid;
  final DateTime timestamp;
  final String status;
  final String jenis;
  final String keterangan;

  AccessHistory({
    required this.id,
    required this.nama,
    required this.rfidUid,
    required this.timestamp,
    required this.status,
    required this.jenis,
    this.keterangan = '',
  });

  factory AccessHistory.fromMap(String id, Map<dynamic, dynamic> map) {
    return AccessHistory(
      id: id,
      nama: map['nama'] ?? 'Tidak diketahui',
      rfidUid: map['rfid_uid'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      status: map['status'] ?? 'failed',
      jenis: map['jenis'] ?? 'unknown',
      keterangan: map['keterangan'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'rfid_uid': rfidUid,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'jenis': jenis,
      'keterangan': keterangan,
    };
  }

  bool get isSuccess => status == 'success';
}
