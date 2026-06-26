import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions belum dikonfigurasi untuk platform ini.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBMCdPkuxBzhqr7rFFswTCpqF9_eVTdCeE',
    appId: '1:944158777706:android:535e7f1071396cb5bd8513',
    messagingSenderId: '944158777706',
    projectId: 'fortlock',
    databaseURL: 'https://fortlock-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'fortlock.firebasestorage.app',
  );
}
