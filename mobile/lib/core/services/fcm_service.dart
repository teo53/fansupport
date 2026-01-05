/// 🔔 Firebase Cloud Messaging 서비스
/// 푸시 알림 처리
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize FCM
  Future<void> initialize() async {
    // Request permission
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ FCM: User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('⚠️ FCM: User granted provisional permission');
    } else {
      print('❌ FCM: User declined or has not accepted permission');
      return;
    }

    // Get FCM token
    _fcmToken = await _firebaseMessaging.getToken();
    print('📱 FCM Token: $_fcmToken');

    // TODO: Send token to backend
    // await _sendTokenToBackend(_fcmToken);

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      print('🔄 FCM Token refreshed: $newToken');
      // TODO: Send new token to backend
      // _sendTokenToBackend(newToken);
    });

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check if app was opened from terminated state
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'pipo_high_importance', // id
      'PIPO Notifications', // name
      description: 'PIPO 앱 알림',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('📨 Foreground message: ${message.notification?.title}');

    // Show local notification when app is in foreground
    _showLocalNotification(message);

    // TODO: Update notification center UI
    // ref.read(notificationProvider.notifier).addNotification(message);
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'pipo_high_importance',
            'PIPO Notifications',
            channelDescription: 'PIPO 앱 알림',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      _navigateToScreen(data);
    }
  }

  /// Handle message opened app (from background/terminated)
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('🔔 Notification tapped: ${message.notification?.title}');
    _navigateToScreen(message.data);
  }

  /// Navigate to appropriate screen based on notification data
  void _navigateToScreen(Map<String, dynamic> data) {
    final targetType = data['targetType'] as String?;
    final targetId = data['targetId'] as String?;

    print('🧭 Navigate to: $targetType / $targetId');

    // TODO: Implement navigation logic
    // Example:
    // if (targetType == 'post' && targetId != null) {
    //   navigatorKey.currentState?.pushNamed('/post/$targetId');
    // } else if (targetType == 'bubble' && targetId != null) {
    //   navigatorKey.currentState?.pushNamed('/bubble');
    // } else if (targetType == 'event' && targetId != null) {
    //   navigatorKey.currentState?.pushNamed('/event/$targetId');
    // }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('✅ Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('❌ Unsubscribed from topic: $topic');
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    await _firebaseMessaging.deleteToken();
    _fcmToken = null;
    print('🗑️ FCM token deleted');
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📨 Background message: ${message.notification?.title}');
  // Handle background message here if needed
}
