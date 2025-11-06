import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: "AIzaSyCQonz7JVRl5di8XkElbGtSffncJvmnCk8",
      authDomain: "appamigurumi-f5d6a.firebaseapp.com",
      projectId: "appamigurumi-f5d6a",
      storageBucket: "appamigurumi-f5d6a.appspot.com", // ⚠️ Debe ser ".appspot.com"
      messagingSenderId: "216499397339",
      appId: "1:216499397339:web:b97fd4dc78d338998f62fe",
      measurementId: "G-8F9K99ZK6Y",
    );
  }
}
