// firebase_option.dart

// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAi1WIlo3y0xCPpKCDiS6ActWbvmnv7bgg',
    appId: '1:331498241066:web:c66469be82530d97859753',
    messagingSenderId: '331498241066',
    projectId: 'serre-c10a3',
    authDomain: 'serre-c10a3.firebaseapp.com',
    databaseURL: 'https://serre-c10a3-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'serre-c10a3.firebasestorage.app',
    measurementId: 'G-BNR0Z2Z34B',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCwW5H5CgU6blrOcmNPYQ_TKv2aqyzK4dQ',
    appId: '1:331498241066:android:0bf70099f66da9f5859753',
    messagingSenderId: '331498241066',
    projectId: 'serre-c10a3',
    databaseURL: 'https://serre-c10a3-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'serre-c10a3.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDwUNHLMzRLgU0tsiurl4BUrMykR5T7Wao',
    appId: '1:331498241066:ios:b70a7d03b7979637859753',
    messagingSenderId: '331498241066',
    projectId: 'serre-c10a3',
    databaseURL: 'https://serre-c10a3-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'serre-c10a3.firebasestorage.app',
    iosClientId: '331498241066-r275igthg1rhmsm9fv6ejg3bvhmrjc46.apps.googleusercontent.com',
    iosBundleId: 'com.example.serre',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDwUNHLMzRLgU0tsiurl4BUrMykR5T7Wao',
    appId: '1:331498241066:ios:b70a7d03b7979637859753',
    messagingSenderId: '331498241066',
    projectId: 'serre-c10a3',
    databaseURL: 'https://serre-c10a3-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'serre-c10a3.firebasestorage.app',
    iosClientId: '331498241066-r275igthg1rhmsm9fv6ejg3bvhmrjc46.apps.googleusercontent.com',
    iosBundleId: 'com.example.serre',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAi1WIlo3y0xCPpKCDiS6ActWbvmnv7bgg',
    appId: '1:331498241066:web:a25f275bb6f0c269859753',
    messagingSenderId: '331498241066',
    projectId: 'serre-c10a3',
    authDomain: 'serre-c10a3.firebaseapp.com',
    databaseURL: 'https://serre-c10a3-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'serre-c10a3.firebasestorage.app',
    measurementId: 'G-JGLXX1PJRE',
  );
}
