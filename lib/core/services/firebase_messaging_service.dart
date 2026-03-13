import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ═══════════════════════════════════════════════════════════════
/// BACKGROUND MESSAGE HANDLER (Top-level function)
/// ═══════════════════════════════════════════════════════════════

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// ═══════════════════════════════════════════════════════════════
/// FIREBASE MESSAGING SERVICE
/// ═══════════════════════════════════════════════════════════════

class FirebaseMessagingService {
  // Singleton pattern
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// ═══════════════════════════════════════════════════════════════
  /// INITIALIZE
  /// ═══════════════════════════════════════════════════════════════

  Future<void> initialize() async {
    try {

      // Request permissions
      await _requestPermissions();

      // Configure foreground notifications
      await _configureForegroundNotifications();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token
      await _getFCMToken();

      // Setup message handlers
      _setupMessageHandlers();

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

    } catch (e) {
      rethrow;
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// REQUEST PERMISSIONS
  /// ═══════════════════════════════════════════════════════════════

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      final plugin = FlutterLocalNotificationsPlugin();
      final granted = await plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// CONFIGURE FOREGROUND NOTIFICATIONS
  /// ═══════════════════════════════════════════════════════════════

  Future<void> _configureForegroundNotifications() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// INITIALIZE LOCAL NOTIFICATIONS
  /// ═══════════════════════════════════════════════════════════════

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// GET FCM TOKEN
  /// ═══════════════════════════════════════════════════════════════

  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();

      // Listen to token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        // TODO: Update token in database
      });
    } catch (e) {
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// SHOW LOCAL NOTIFICATION
  /// ═══════════════════════════════════════════════════════════════

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// NOTIFICATION TAPPED HANDLER
  /// ═══════════════════════════════════════════════════════════════

  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Navigate based on payload
  }

  void _handleNotificationTap(RemoteMessage message) {
    // TODO: Navigate based on message data
  }

  /// ═══════════════════════════════════════════════════════════════
  /// SUBSCRIBE TO TOPIC
  /// ═══════════════════════════════════════════════════════════════

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// UNSUBSCRIBE FROM TOPIC
  /// ═══════════════════════════════════════════════════════════════

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// DELETE TOKEN
  /// ═══════════════════════════════════════════════════════════════

  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
    } catch (e) {
    }
  }

  Future<void> _saveNotificationToDatabase(RemoteMessage message) async {
    try {
      final supabase = Supabase.instance.client;

      // ✅ الحصول على User ID من SharedPreferences أو أي مصدر
      // (يجب أن يكون متاح عند تسجيل الدخول)
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('current_user_id');

      if (userId == null) {
        return;
      }

      final notification = message.notification;
      if (notification == null) {
        return;
      }

      // ✅ تحديد نوع الإشعار من data
      String notificationType = 'general';
      if (message.data.containsKey('type')) {
        notificationType = message.data['type'].toString();
      }

      // ✅ حفظ الإشعار في جدول notifications
      await supabase.from('notifications').insert({
        'user_id': userId,
        'title': notification.title ?? 'إشعار جديد',
        'body': notification.body ?? '',
        'type': notificationType,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
        'data': message.data, // حفظ البيانات الإضافية
      });

    } catch (e) {
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// SETUP MESSAGE HANDLERS - محدث
  /// ═══════════════════════════════════════════════════════════════

  void _setupMessageHandlers() {
    // ✅ Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {

      // ✅ حفظ في Database
      await _saveNotificationToDatabase(message);

      // ✅ عرض الإشعار المحلي
      _showLocalNotification(message);
    });

    // ✅ Message tapped (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {

      // ✅ حفظ في Database
      await _saveNotificationToDatabase(message);

      _handleNotificationTap(message);
    });

    // ✅ Check if app opened from terminated state
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) async {
      if (message != null) {

        // ✅ حفظ في Database
        await _saveNotificationToDatabase(message);

        _handleNotificationTap(message);
      }
    });
  }
}