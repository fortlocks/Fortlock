class GuestAccess {
  final String id;
  final String namaTamu;
  final String rfidUid;
  final DateTime tanggalMulai;
  final DateTime tanggalBerakhir;
  final String jamMulai;
  final String jamBerakhir;
  final String status;
  final String createdBy;

  GuestAccess({
    required this.id,
    required this.namaTamu,
    required this.rfidUid,
    required this.tanggalMulai,
    required this.tanggalBerakhir,
    required this.jamMulai,
    required this.jamBerakhir,
    this.status = 'active',
    this.createdBy = '',
  });

  factory GuestAccess.fromMap(String id, Map<dynamic, dynamic> map) {
    return GuestAccess(
      id: id,
      namaTamu: map['nama_tamu'] ?? '',
      rfidUid: map['rfid_uid'] ?? '',
      tanggalMulai:
          DateTime.tryParse(map['tanggal_mulai']?.toString() ?? '') ??
              DateTime.now(),
      tanggalBerakhir:
          DateTime.tryParse(map['tanggal_berakhir']?.toString() ?? '') ??
              DateTime.now(),
      jamMulai: map['jam_mulai'] ?? '00:00',
      jamBerakhir: map['jam_berakhir'] ?? '23:59',
      status: map['status'] ?? 'active',
      createdBy: map['created_by'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama_tamu': namaTamu,
      'rfid_uid': rfidUid,
      'tanggal_mulai': tanggalMulai.toIso8601String(),
      'tanggal_berakhir': tanggalBerakhir.toIso8601String(),
      'jam_mulai': jamMulai,
      'jam_berakhir': jamBerakhir,
      'status': status,
      'created_by': createdBy,
    };
  }

  bool get isActive => status == 'active';

  bool isExpiredNow() {
    final now = DateTime.now();
    if (now.isAfter(tanggalBerakhir)) return true;
    if (now.isBefore(tanggalMulai)) return false;
    if (now.year == tanggalBerakhir.year &&
        now.month == tanggalBerakhir.month &&
        now.day == tanggalBerakhir.day) {
      final parts = jamBerakhir.split(':');
      final endHour = int.tryParse(parts[0]) ?? 23;
      final endMinute = int.tryParse(parts.length > 1 ? parts[1] : '59') ?? 59;
      final endTime =
          DateTime(now.year, now.month, now.day, endHour, endMinute);
      return now.isAfter(endTime);
    }
    return false;
  }
}
