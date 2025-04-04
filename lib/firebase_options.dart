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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCd35b6M5XB_UtaIcp0uMKSw1IalztMIwE',
    appId: '1:751439789472:android:79ceabd50018cfb67c38c5',
    messagingSenderId: '751439789472',
    projectId: 'pokar-food-service-pvt-ltd',
    storageBucket: 'pokar-food-service-pvt-ltd.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDsO3pkXp7X51pcvzifYvbViSaXl8_Rycc',
    appId: '1:751439789472:ios:a4d71e77bf62f5c77c38c5',
    messagingSenderId: '751439789472',
    projectId: 'pokar-food-service-pvt-ltd',
    storageBucket: 'pokar-food-service-pvt-ltd.firebasestorage.app',
    androidClientId: '751439789472-81jrntmldmmjtgsem47cvph0b3ubr7pr.apps.googleusercontent.com',
    iosClientId: '751439789472-emdufmbgpuphe2tu11au02etha15i94q.apps.googleusercontent.com',
    iosBundleId: 'com.pokargreens.customer',
  );

}