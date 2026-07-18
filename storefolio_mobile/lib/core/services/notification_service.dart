import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles Firebase Cloud Messaging setup and local notification display.
///
/// Safe to call even when Firebase is not configured for a particular build.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static NotificationService get instance => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Request permission on iOS. Android doesn't need runtime permission.
      if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
        await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Background handler must be a top-level function.
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Local notifications channel for foreground messages.
      await _setupLocalNotifications();

      // Foreground message listener.
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Token refresh.
      _messaging.onTokenRefresh.listen((token) {
        debugPrint('FCM token refreshed: $token');
      });

      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService: FCM not available: $e');
    }
  }

  Future<String?> getToken() async {
    if (!_initialized) return null;
    try {
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  Future<void> _setupLocalNotifications() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'storefolio_default_channel',
      'Storefolio Notifications',
      description: 'Default notification channel for Storefolio.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(initSettings);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'storefolio_default_channel',
            'Storefolio Notifications',
            channelDescription: 'Default notification channel for Storefolio.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: message.data.toString(),
      );
    }
  }
}

/// Background message handler. Must be a top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If using other Firebase services in background, initialize them here.
  debugPrint('Background message received: ${message.messageId}');
}
