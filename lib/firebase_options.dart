import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


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
    apiKey: 'AIzaSyBPBY8ATe0trTDD8lRHPoe5tR4lpdaQ8-g',
    appId: '1:200655571194:web:7abce4d1551b8f81726143',
    messagingSenderId: '200655571194',
    projectId: 'nimah-app-74450',
    authDomain: 'nimah-app-74450.firebaseapp.com',
    storageBucket: 'nimah-app-74450.firebasestorage.app',
    measurementId: 'G-XPCQ1HL1DK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBZltZQk_1vtpg4gnlwQ_sNVzzK2ztS1Ts',
    appId: '1:200655571194:android:166dbc34969ed0af726143',
    messagingSenderId: '200655571194',
    projectId: 'nimah-app-74450',
    storageBucket: 'nimah-app-74450.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDcqxmk6ZoavZ7jDcSdG3XufVaEJUbRz10',
    appId: '1:200655571194:ios:592657c770fe6599726143',
    messagingSenderId: '200655571194',
    projectId: 'nimah-app-74450',
    storageBucket: 'nimah-app-74450.firebasestorage.app',
    iosBundleId: 'com.example.nimahApp',
  );
}
