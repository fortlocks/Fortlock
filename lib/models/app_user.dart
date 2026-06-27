class AppUser {
  final String uid;
  final String nama;
  final String email;
  final String role;
  final String rfidUid;
  final bool aktif;
  final DateTime? createdAt;

  AppUser({
    required this.uid,
    required this.nama,
    required this.email,
    required this.role,
    this.rfidUid = '',
    this.aktif = true,
    this.createdAt,
  });

  factory AppUser.fromMap(String uid, Map<dynamic, dynamic> map) {
    return AppUser(
      uid: uid,
      nama: map['nama'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      rfidUid: map['rfid_uid'] ?? '',
      aktif: map['aktif'] ?? true,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'email': email,
      'role': role,
      'rfid_uid': rfidUid,
      'aktif': aktif,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';

  bool get canManageUsers => isOwner || isAdmin;
  bool get canDeleteUsers => isOwner;
  bool get canChangeRoles => isOwner;
  bool get canControlDevice => isOwner || isAdmin;
  bool get canViewAllHistory => isOwner || isAdmin;
  bool get canChangeSettings => isOwner;
}
