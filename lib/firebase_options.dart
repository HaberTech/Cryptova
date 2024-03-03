// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCjcxAyelxDuJLbcJcscdfecnVAxTb9fA0',
    appId: '1:786894849619:web:b9205b65a2cbc40477a8a6',
    messagingSenderId: '786894849619',
    projectId: 'habertech-cryptova',
    authDomain: 'habertech-cryptova.firebaseapp.com',
    storageBucket: 'habertech-cryptova.appspot.com',
    measurementId: 'G-QRZVGZ5TNG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBKDgewo5zGRHieEMAYu7soiPB-30cQ7HE',
    appId: '1:786894849619:android:7c35c04fbeea1e1077a8a6',
    messagingSenderId: '786894849619',
    projectId: 'habertech-cryptova',
    storageBucket: 'habertech-cryptova.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBM4hjHZ78OP-Wqs3nUBgmomais9QKD5ro',
    appId: '1:786894849619:ios:dd10841c8aab467b77a8a6',
    messagingSenderId: '786894849619',
    projectId: 'habertech-cryptova',
    storageBucket: 'habertech-cryptova.appspot.com',
    iosBundleId: 'info.habertech.cryptova',
  );

}