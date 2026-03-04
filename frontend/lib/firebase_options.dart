import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCVBMJGSrCUo56BzNWNuYoAfZMZXJZY5J0',
    appId: '1:126221318196:ios:782bd103ed26688ce9f261',
    messagingSenderId: '126221318196',
    projectId: 'starter-project-44977',
    storageBucket: 'starter-project-44977.firebasestorage.app',
    iosBundleId: 'com.example.newsAppCleanArchitecture',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDICIEdh5DcOaNPl0EgfRhQyoVYqHT5DZM',
    appId: '1:126221318196:android:604f171817720779e9f261',
    messagingSenderId: '126221318196',
    projectId: 'starter-project-44977',
    storageBucket: 'starter-project-44977.firebasestorage.app',
  );
}
