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
    apiKey: 'AIzaSyD6er207qKl2mtw9-hK-XaWJaxAT__4ZN8',
    appId: '1:1007664185805:web:3217fd2f076d6c6ad00484',
    messagingSenderId: '1007664185805',
    projectId: 'hayygov',
    authDomain: 'hayygov.firebaseapp.com',
    storageBucket: 'hayygov.firebasestorage.app',
    measurementId: 'G-KQZ6X5K8FL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyACVTI9t54NzqhCnRtgKn32CoF1kSojAQg',
    appId: '1:1007664185805:android:c35a8df7b85cad29d00484',
    messagingSenderId: '1007664185805',
    projectId: 'hayygov',
    storageBucket: 'hayygov.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBT9l-q1gDd72lFZgdBeJsrTWmldwyt4ak',
    appId: '1:1007664185805:ios:c8478205ba469aadd00484',
    messagingSenderId: '1007664185805',
    projectId: 'hayygov',
    storageBucket: 'hayygov.firebasestorage.app',
    iosBundleId: 'com.example.hayygov',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBT9l-q1gDd72lFZgdBeJsrTWmldwyt4ak',
    appId: '1:1007664185805:ios:c8478205ba469aadd00484',
    messagingSenderId: '1007664185805',
    projectId: 'hayygov',
    storageBucket: 'hayygov.firebasestorage.app',
    iosBundleId: 'com.example.hayygov',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD6er207qKl2mtw9-hK-XaWJaxAT__4ZN8',
    appId: '1:1007664185805:web:d386970a4fafe926d00484',
    messagingSenderId: '1007664185805',
    projectId: 'hayygov',
    authDomain: 'hayygov.firebaseapp.com',
    storageBucket: 'hayygov.firebasestorage.app',
    measurementId: 'G-W3HBV67P02',
  );
}
