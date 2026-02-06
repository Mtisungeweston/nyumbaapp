import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCO0W3TaFguq_JOzu_qQnsCaQjNMBIALek',
    appId: '1:659261555916:android:ca262873b6aebf2773ee69',
    messagingSenderId: '659261555916',
    projectId: 'nyumba-application-a6587',
    databaseURL: 'https://nyumba-application-a6587.firebaseio.com',
    storageBucket: 'nyumba-application-a6587.firebasestorage.app',
  );
}
