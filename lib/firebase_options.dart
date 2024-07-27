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
    apiKey: 'AIzaSyC5LHUA8qhuwSwnujN9IgO2ljTv9aap9Lw',
    appId: '1:827064956292:web:0cb57a3b5a419f10a299d1',
    messagingSenderId: '827064956292',
    projectId: 'gupsup-343c6',
    authDomain: 'gupsup-343c6.firebaseapp.com',
    storageBucket: 'gupsup-343c6.appspot.com',
    measurementId: 'G-225M6E61WB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCqobz7YE-G1ePM4OOAr0U2NMsL0wXzVKc',
    appId: '1:827064956292:android:1aeb1e4a350e1f75a299d1',
    messagingSenderId: '827064956292',
    projectId: 'gupsup-343c6',
    storageBucket: 'gupsup-343c6.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDMiyWtCgdM3KvqMEramZXkEAdy4bXlGXM',
    appId: '1:827064956292:ios:a81e667cce8da5bca299d1',
    messagingSenderId: '827064956292',
    projectId: 'gupsup-343c6',
    storageBucket: 'gupsup-343c6.appspot.com',
    iosBundleId: 'com.example.gupsup',
  );
}
