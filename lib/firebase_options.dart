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
    apiKey: 'AIzaSyDAvk4iWLF51IGP1YmFUvGZA8oRKhQPHbA',
    appId: '1:896075086092:web:8cbf6241151c8cb211b129',
    messagingSenderId: '896075086092',
    projectId: 'cameye-9ae6a',
    authDomain: 'cameye-9ae6a.firebaseapp.com',
    databaseURL: 'https://cameye-9ae6a-default-rtdb.firebaseio.com',
    storageBucket: 'cameye-9ae6a.appspot.com',
    measurementId: 'G-G4WT8RP5T4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBWJiZuPuDke7399LVOiXnlCGEeI21ho2c',
    appId: '1:896075086092:android:5f7907cfff02a75811b129',
    messagingSenderId: '896075086092',
    projectId: 'cameye-9ae6a',
    databaseURL: 'https://cameye-9ae6a-default-rtdb.firebaseio.com',
    storageBucket: 'cameye-9ae6a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC3QMOUVh546ElptnEWVbSEC_XWXU6VpQU',
    appId: '1:896075086092:ios:cc3745a7b43fa64b11b129',
    messagingSenderId: '896075086092',
    projectId: 'cameye-9ae6a',
    databaseURL: 'https://cameye-9ae6a-default-rtdb.firebaseio.com',
    storageBucket: 'cameye-9ae6a.appspot.com',
    iosBundleId: 'com.example.cameye',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC3QMOUVh546ElptnEWVbSEC_XWXU6VpQU',
    appId: '1:896075086092:ios:cc3745a7b43fa64b11b129',
    messagingSenderId: '896075086092',
    projectId: 'cameye-9ae6a',
    databaseURL: 'https://cameye-9ae6a-default-rtdb.firebaseio.com',
    storageBucket: 'cameye-9ae6a.appspot.com',
    iosBundleId: 'com.example.cameye',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDAvk4iWLF51IGP1YmFUvGZA8oRKhQPHbA',
    appId: '1:896075086092:web:0783edf0170ffd8511b129',
    messagingSenderId: '896075086092',
    projectId: 'cameye-9ae6a',
    authDomain: 'cameye-9ae6a.firebaseapp.com',
    databaseURL: 'https://cameye-9ae6a-default-rtdb.firebaseio.com',
    storageBucket: 'cameye-9ae6a.appspot.com',
    measurementId: 'G-8Z9JXPE9FK',
  );
}
