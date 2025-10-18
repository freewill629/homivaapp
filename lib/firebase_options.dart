import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:demo:android:123456',
    messagingSenderId: '1234567890',
    projectId: 'homiva-demo',
  );
}
