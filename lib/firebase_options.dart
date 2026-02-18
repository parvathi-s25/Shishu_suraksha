// File generated manually based on user input
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDacyBFlS8E_3HON7HqWzx4Paqe5egQxc4',
    appId: '1:112887985521:web:99aab930191b394b5cf2d0',
    messagingSenderId: '112887985521',
    projectId: 'shisuraksha',
    authDomain: 'shisuraksha.firebaseapp.com',
    storageBucket: 'shisuraksha.firebasestorage.app',
    measurementId: 'G-ZCPHCYPMPP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDacyBFlS8E_3HON7HqWzx4Paqe5egQxc4',
    appId: '1:112887985521:android:placeholder',
    messagingSenderId: '112887985521',
    projectId: 'shisuraksha',
    storageBucket: 'shisuraksha.firebasestorage.app',
  );
}
