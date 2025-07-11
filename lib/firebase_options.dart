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
    apiKey: 'AIzaSyC_X8VzZ898k-yuRd0SCA9J1yp6FTRCFI0',
    appId: '1:726329073858:web:c06154c64b1d5b400f5b5b',
    messagingSenderId: '726329073858',
    projectId: 'idairy-d4257',
    authDomain: 'idairy-d4257.firebaseapp.com',
    storageBucket: 'idairy-d4257.firebasestorage.app',
    measurementId: 'G-4QRKE8J76F',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCKNMDVzAIcDRVPd-DBqQ7vrefJtLuQmL8',
    appId: '1:726329073858:android:f24f996c98ad67140f5b5b',
    messagingSenderId: '726329073858',
    projectId: 'idairy-d4257',
    storageBucket: 'idairy-d4257.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBTY9E9YTQMTlo8PIrN4DNWJ-sI5N845vs',
    appId: '1:726329073858:ios:15549486c48da88e0f5b5b',
    messagingSenderId: '726329073858',
    projectId: 'idairy-d4257',
    storageBucket: 'idairy-d4257.firebasestorage.app',
    iosBundleId: 'com.example.idairy',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBTY9E9YTQMTlo8PIrN4DNWJ-sI5N845vs',
    appId: '1:726329073858:ios:15549486c48da88e0f5b5b',
    messagingSenderId: '726329073858',
    projectId: 'idairy-d4257',
    storageBucket: 'idairy-d4257.firebasestorage.app',
    iosBundleId: 'com.example.idairy',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC_X8VzZ898k-yuRd0SCA9J1yp6FTRCFI0',
    appId: '1:726329073858:web:23a7b49742ee505b0f5b5b',
    messagingSenderId: '726329073858',
    projectId: 'idairy-d4257',
    authDomain: 'idairy-d4257.firebaseapp.com',
    storageBucket: 'idairy-d4257.firebasestorage.app',
    measurementId: 'G-5W47CFHM99',
  );

}