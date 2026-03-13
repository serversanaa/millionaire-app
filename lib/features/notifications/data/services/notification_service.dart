// lib/features/notifications/data/services/notification_service.dart
import 'dart:io';
import 'dart:ui';import 'package:device_info_plus/device_info_plus.dart';


import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// تهيئة الإشعارات
  Future<void> initialize() async {
    if (_isInitialized) return;

    // تهيئة المناطق الزمنية
    tz.initializeTimeZones();
    // tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));
    tz.setLocalLocation(tz.getLocation('Asia/Aden'));

    // إعدادات Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // إعدادات iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// معالجة النقر على الإشعار
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      // TODO: Navigate to appointment details
    }
  }

  /// طلب الأذونات
  // Future<bool> requestPermissions() async {
  //   if (await Permission.notification.isGranted) {
  //     return true;
  //   }
  //
  //   final status = await Permission.notification.request();
  //   return status.isGranted;
  // }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;

        // Android 13+ يحتاج طلب إذن runtime
        if (androidInfo.version.sdkInt >= 33) {
          final status = await Permission.notification.request();
          return status.isGranted;
        }

        return true; // للإصدارات الأقدم
      } catch (e) {
        // محاولة طلب الإذن على أي حال
        final status = await Permission.notification.request();
        return status.isGranted;
      }
    }

    // iOS
    if (Platform.isIOS) {
      return await _notifications
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      ) ?? false;
    }

    return true;
  }
  /// إظهار إشعار فوري
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      _notificationDetails(),
      payload: payload,
    );
  }

  /// جدولة إشعار لوقت محدد
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // ✅ هذا فقط
      payload: payload,
    );
  }

  /// إلغاء إشعار محدد
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// إلغاء جميع الإشعارات
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// إعدادات الإشعار
  // NotificationDetails _notificationDetails() {
  //   return const NotificationDetails(
  //     android: AndroidNotificationDetails(
  //       'millionaire_barber_channel',
  //       'Millionaire Barber',
  //       channelDescription: 'إشعارات Millionaire Barber',
  //       importance: Importance.high,
  //       priority: Priority.high,
  //       showWhen: true,
  //       enableVibration: true,
  //       playSound: true,
  //       icon: '@mipmap/ic_launcher',
  //     ),
  //     iOS: DarwinNotificationDetails(
  //       presentAlert: true,
  //       presentBadge: true,
  //       presentSound: true,
  //     ),
  //   );
  // }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'millionaire_barber_channel',
        'مركز المليونير',
        channelDescription: 'إشعارات مركز المليونير للحلاقة',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher', // ✅ يمكنك تغييرها لـ 'ic_notification' إذا أضفت أيقونة مخصصة
        color: Color(0xFF8B1538), // ✅ لون AppColors.darkRed
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      ),
    );
  }

  /// إشعار تأكيد الحجز
  Future<void> showBookingConfirmation({
    required int appointmentId,
    required String serviceName,
    required DateTime appointmentDate,
    required String appointmentTime,
  }) async {
    await showInstantNotification(
      id: appointmentId,
      title: '✅ تم تأكيد حجزك',
      body: 'حجز $serviceName في ${appointmentDate.day}/${appointmentDate.month} الساعة $appointmentTime',
      payload: 'appointment_$appointmentId',
    );
  }

  /// جدولة تذكير قبل الموعد
  Future<void> scheduleAppointmentReminders({
    required int appointmentId,
    required String serviceName,
    required DateTime appointmentDateTime,
  }) async {
    // تذكير قبل 24 ساعة
    final reminder24h = appointmentDateTime.subtract(const Duration(hours: 24));
    if (reminder24h.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: appointmentId * 100 + 1, // ID فريد
        title: '⏰ تذكير بموعدك غداً',
        body: 'لديك موعد $serviceName غداً الساعة ${_formatTime(appointmentDateTime)}',
        scheduledTime: reminder24h,
        payload: 'appointment_$appointmentId',
      );
    }

    // تذكير قبل ساعة
    final reminder1h = appointmentDateTime.subtract(const Duration(hours: 1));
    if (reminder1h.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: appointmentId * 100 + 2, // ID فريد
        title: '🔔 موعدك بعد ساعة',
        body: 'موعد $serviceName بعد ساعة واحدة',
        scheduledTime: reminder1h,
        payload: 'appointment_$appointmentId',
      );
    }
  }

  /// إشعار إلغاء الموعد
  Future<void> showCancellationNotification({
    required int appointmentId,
    required String serviceName,
  }) async {
    await showInstantNotification(
      id: appointmentId * 10,
      title: '❌ تم إلغاء الموعد',
      body: 'تم إلغاء موعد $serviceName',
      payload: 'appointment_$appointmentId',
    );

    // إلغاء التذكيرات المجدولة
    await cancelNotification(appointmentId * 100 + 1);
    await cancelNotification(appointmentId * 100 + 2);
  }

  /// إشعار عرض خاص
  Future<void> showOfferNotification({
    required String title,
    required String body,
    int? offerId,
  }) async {
    await showInstantNotification(
      id: offerId ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🎁 $title',
      body: body,
      payload: offerId != null ? 'offer_$offerId' : null,
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}