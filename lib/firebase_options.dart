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
    apiKey: 'AIzaSyCOiVlgxsOGZUMlHgc--_mvp00kPravRFY',
    appId: '1:1083406847577:web:4101e017969d3ee7a66b48',
    messagingSenderId: '1083406847577',
    projectId: 'connectmarinan',
    authDomain: 'connectmarinan.firebaseapp.com',
    storageBucket: 'connectmarinan.firebasestorage.app',
    measurementId: 'G-X6KWS4LEK2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCqz0PMIHKt-bxQ_LpipMsAESBx5rRTbIA',
    appId: '1:1083406847577:android:4a3cb65b53924472a66b48',
    messagingSenderId: '1083406847577',
    projectId: 'connectmarinan',
    storageBucket: 'connectmarinan.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAqlVTDZab7AY-pZT-iUyz8QO1CqTSKw-c',
    appId: '1:1083406847577:ios:9a942b8fbf6ccda4a66b48',
    messagingSenderId: '1083406847577',
    projectId: 'connectmarinan',
    storageBucket: 'connectmarinan.firebasestorage.app',
    iosBundleId: 'com.example.connectmarian',
  );
}
