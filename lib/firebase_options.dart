import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions belum dikonfigurasi untuk platform ini. '
      'Jalankan flutterfire configure untuk generate ulang file ini.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'GANTI_DENGAN_API_KEY_ASLI',
    appId: 'GANTI_DENGAN_APP_ID_ASLI',
    messagingSenderId: 'GANTI_DENGAN_SENDER_ID_ASLI',
    projectId: 'GANTI_DENGAN_PROJECT_ID_ASLI',
    databaseURL: 'https://GANTI-PROJECT-ID-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'GANTI_DENGAN_PROJECT_ID.appspot.com',
  );
}
