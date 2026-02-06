import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer' as developer;

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Initialize Firebase Cloud Messaging
  Future<void> initialize() async {
    try {
      developer.log('[FCM] Starting FCM initialization', name: 'FCMService');
      
      // Request permission for Android
      try {
        await _firebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
        developer.log('[FCM] Permission requested', name: 'FCMService');
      } catch (e) {
        developer.log('[FCM] Permission request failed: $e', name: 'FCMService', error: e);
      }

      // Get and log the device token
      try {
        final token = await _firebaseMessaging.getToken();
        developer.log('[FCM] Token obtained: $token', name: 'FCMService');
      } catch (e) {
        developer.log('[FCM] Token retrieval failed: $e', name: 'FCMService', error: e);
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log('[FCM] Message received in foreground', name: 'FCMService');
        if (message.notification != null) {
          developer.log('[FCM] Notification: ${message.notification?.title}', name: 'FCMService');
        }
      });

      // Handle message when app is in background or terminated
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        developer.log('[FCM] App opened from message', name: 'FCMService');
        if (message.data.containsKey('propertyId')) {
          developer.log('[FCM] Navigate to property: ${message.data['propertyId']}', name: 'FCMService');
        }
      });

      // Handle notifications when app is terminated
      try {
        final initialMessage = await _firebaseMessaging.getInitialMessage();
        if (initialMessage != null) {
          developer.log('[FCM] Initial message on startup', name: 'FCMService');
        }
      } catch (e) {
        developer.log('[FCM] Initial message check failed: $e', name: 'FCMService', error: e);
      }
      
      developer.log('[FCM] Initialization complete', name: 'FCMService');
    } catch (e, stackTrace) {
      developer.log('[FCM] Fatal initialization error: $e', name: 'FCMService', error: e, stackTrace: stackTrace);
    }
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }

  // Get device token
  Future<String?> getDeviceToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Listen to token refresh
  void listenToTokenRefresh(Function(String) onTokenRefresh) {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('Token refreshed: $newToken');
      onTokenRefresh(newToken);
    });
  }
}
