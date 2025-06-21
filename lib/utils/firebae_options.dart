// utils/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get web {
    return const FirebaseOptions(
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
}
