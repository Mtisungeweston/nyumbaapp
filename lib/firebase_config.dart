import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:developer' as developer;

class FirebaseConfig {
  static bool _initialized = false;
  static bool _initializationFailed = false;
  static String? _initializationError;

  static bool get isInitialized => _initialized;
  static bool get initializationFailed => _initializationFailed;
  static String? get initializationError => _initializationError;

  static Future<void> initialize() async {
    try {
      developer.log('[FirebaseConfig] Starting Firebase initialization', name: 'FirebaseConfig');
      
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      _initialized = true;
      _initializationFailed = false;
      _initializationError = null;
      
      developer.log('[FirebaseConfig] Firebase initialized successfully', name: 'FirebaseConfig');
    } on FirebaseException catch (e) {
      developer.log('[FirebaseConfig] Firebase initialization failed: ${e.message}', name: 'FirebaseConfig', error: e);
      _initialized = false;
      _initializationFailed = true;
      _initializationError = e.message ?? 'Firebase initialization failed';
    } catch (e, stackTrace) {
      developer.log('[FirebaseConfig] Unexpected error: $e', name: 'FirebaseConfig', error: e, stackTrace: stackTrace);
      _initialized = false;
      _initializationFailed = true;
      _initializationError = e.toString();
    }
  }
}
