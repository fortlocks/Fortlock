import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/app_user.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.ref().child('users');

  User? get currentFirebaseUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

Future<bool> ownerExists() async {
  final snapshot = await FirebaseDatabase.instance
      .ref()
      .child('system_meta')
      .child('owner_exists')
      .get();
  return snapshot.exists && snapshot.value == true;
}

Future<AppUser> setupOwner({
  required String nama,
  required String email,
  required String password,
  required String noTelepon,
  String rfidUid = '',
}) async {

    final exists = await ownerExists();
    if (exists) {
      throw Exception('Owner sudah terdaftar. Tidak bisa membuat Owner baru.');
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

final uid = credential.user!.uid;
final owner = AppUser(
  uid: uid,
  nama: nama,
  email: email,
  role: 'owner',
  rfidUid: rfidUid,
  aktif: true,
  createdAt: DateTime.now(),
);


final ownerMap = owner.toMap();
ownerMap['no_telepon'] = noTelepon;
await _usersRef.child(uid).set(ownerMap);

await FirebaseDatabase.instance
    .ref()
    .child('system_meta')
    .child('owner_exists')
    .set(true);

return owner;
}

  Future<AppUser> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    final snapshot = await _usersRef.child(uid).get();

    if (!snapshot.exists) {
      await _auth.signOut();
      throw Exception('Data pengguna tidak ditemukan.');
    }

    final user = AppUser.fromMap(uid, snapshot.value as Map<dynamic, dynamic>);

    if (!user.aktif) {
      await _auth.signOut();
      throw Exception('Akun Anda telah dinonaktifkan.');
    }

    return user;
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<AppUser?> getCurrentAppUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    final snapshot = await _usersRef.child(firebaseUser.uid).get();
    if (!snapshot.exists) return null;

    return AppUser.fromMap(
        firebaseUser.uid, snapshot.value as Map<dynamic, dynamic>);
  }
Future<AppUser> addUser({
  required String nama,
  required String email,
  required String password,
  required String role,
  required String rfidUid,
}) async {
  final secondaryApp = await Firebase.initializeApp(
    name: 'SecondaryApp_${DateTime.now().millisecondsSinceEpoch}',
    options: Firebase.app().options,
  );

  try {
    final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

    final credential = await secondaryAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    final newUser = AppUser(
      uid: uid,
      nama: nama,
      email: email,
      role: role,
      rfidUid: rfidUid,
      aktif: true,
      createdAt: DateTime.now(),
    );

    await _usersRef.child(uid).set(newUser.toMap());
    await secondaryAuth.signOut();

    return newUser;
  } finally {
    await secondaryApp.delete();
  }
}

  Stream<List<AppUser>> watchUsers() {
    return _usersRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        return data.entries
            .map((e) =>
                AppUser.fromMap(e.key.toString(), e.value as Map<dynamic, dynamic>))
            .toList();
      }
      return <AppUser>[];
    });
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    await _usersRef.child(uid).update({'role': newRole});
  }

  Future<void> setUserActive(String uid, bool aktif) async {
    await _usersRef.child(uid).update({'aktif': aktif});
  }

  Future<void> deleteUser(String uid) async {
    await _usersRef.child(uid).remove();
  }
}
