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
    apiKey: 'AIzaSyD4vVM7Y8TKlvC_OO0cJkc_UjjkCRpSmdI',
    appId: '1:489390018231:web:6f733f66c888bb3a4b4732',
    messagingSenderId: '489390018231',
    projectId: 'penalty-card-game-login',
    authDomain: 'penalty-card-game-login.firebaseapp.com',
    storageBucket: 'penalty-card-game-login.appspot.com',
    measurementId: 'G-8WXMKV1LH4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD2J-Q2K2iggXhGBICw5jLq7_NA-wW49pA',
    appId: '1:489390018231:android:ed83b4271be527954b4732',
    messagingSenderId: '489390018231',
    projectId: 'penalty-card-game-login',
    storageBucket: 'penalty-card-game-login.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD-MqtzR3qgIqI8QiH0nsJVDvlCn3EeekE',
    appId: '1:489390018231:ios:0976291316e75d704b4732',
    messagingSenderId: '489390018231',
    projectId: 'penalty-card-game-login',
    storageBucket: 'penalty-card-game-login.appspot.com',
    iosBundleId: 'com.example.penaltyCardGame',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD-MqtzR3qgIqI8QiH0nsJVDvlCn3EeekE',
    appId: '1:489390018231:ios:0976291316e75d704b4732',
    messagingSenderId: '489390018231',
    projectId: 'penalty-card-game-login',
    storageBucket: 'penalty-card-game-login.appspot.com',
    iosBundleId: 'com.example.penaltyCardGame',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD4vVM7Y8TKlvC_OO0cJkc_UjjkCRpSmdI',
    appId: '1:489390018231:web:c48e50629bd51ae94b4732',
    messagingSenderId: '489390018231',
    projectId: 'penalty-card-game-login',
    authDomain: 'penalty-card-game-login.firebaseapp.com',
    storageBucket: 'penalty-card-game-login.appspot.com',
    measurementId: 'G-LL76Z2L60V',
  );
}