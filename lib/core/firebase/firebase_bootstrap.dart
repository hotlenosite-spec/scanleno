import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

abstract final class FirebaseBootstrap {
  static bool initialized = false;
  static Object? lastError;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      initialized = true;
      lastError = null;
    } catch (error) {
      initialized = false;
      lastError = error;
      debugPrint('Firebase initialization skipped: $error');
    }
  }
}
