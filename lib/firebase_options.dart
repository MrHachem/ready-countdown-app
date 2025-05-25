// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyDsOEebI0uSWCHreVGe0P-VaDQ09sFpouI',
      appId: '1:1032479700400:android:772798404ef3b7377a1275',
      messagingSenderId: '1032479700400',
      projectId: 'digit-real-time-app',
      databaseURL: 'https://digit-real-time-app-default-rtdb.europe-west1.firebasedatabase.app/',
    );
  }
}