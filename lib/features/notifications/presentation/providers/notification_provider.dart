import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/services/notification_service.dart';
import '../../domain/models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository notificationRepository;
  final NotificationService notificationService;
  final SupabaseClient _supabase = Supabase.instance.client;

  NotificationProvider({
    required this.notificationRepository,
    required this.notificationService,
  });

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  List<NotificationModel> _unreadNotifications = [];
  List<NotificationModel> get unreadNotifications => _unreadNotifications;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ✅ قناة Realtime
  RealtimeChannel? _realtimeChannel;

  /// تهيئة خدمة الإشعارات
  Future<void> initializeNotifications() async {
    try {
      await notificationService.initialize();
      final hasPermission = await notificationService.requestPermissions();
      if (!hasPermission) {
      }
    } catch (e) {
    }
  }

  /// جلب جميع الإشعارات
  Future<void> fetchNotifications(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await notificationRepository.getUserNotifications(userId);
      _unreadNotifications = _notifications.where((n) => !n.isRead).toList();
      _unreadCount = _unreadNotifications.length;
    } catch (e) {
      _error = 'فشل تحميل الإشعارات';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// جلب عدد الإشعارات غير المقروءة
  Future<void> fetchUnreadCount(int userId) async {
    try {
      _unreadCount = await notificationRepository.getUnreadCount(userId);
      notifyListeners();
    } catch (e) {
    }
  }

  /// تعليم إشعار كمقروء
  Future<void> markAsRead(int notificationId, int userId) async {
    try {
      final success = await notificationRepository.markAsRead(notificationId);
      if (success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(
            isRead: true,
            updatedAt: DateTime.now(),
          );
          _unreadNotifications = _notifications.where((n) => !n.isRead).toList();
          _unreadCount = _unreadNotifications.length;

          // ✅ سيتم التحديث تلقائياً عبر Realtime
          notifyListeners();
        }
      }
    } catch (e) {
    }
  }

  /// تعليم جميع الإشعارات كمقروءة
  Future<void> markAllAsRead(int userId) async {
    try {
      final success = await notificationRepository.markAllAsRead(userId);
      if (success) {
        _notifications = _notifications
            .map((n) => n.copyWith(isRead: true, updatedAt: DateTime.now()))
            .toList();
        _unreadNotifications = [];
        _unreadCount = 0;

        // ✅ سيتم التحديث تلقائياً عبر Realtime
        notifyListeners();
      }
    } catch (e) {
    }
  }

  /// حذف إشعار
  Future<void> deleteNotification(int notificationId, int userId) async {
    try {
      final success = await notificationRepository.deleteNotification(notificationId);
      if (success) {
        _notifications.removeWhere((n) => n.id == notificationId);
        _unreadNotifications = _notifications.where((n) => !n.isRead).toList();
        _unreadCount = _unreadNotifications.length;

        // ✅ سيتم التحديث تلقائياً عبر Realtime
        notifyListeners();
      }
    } catch (e) {
    }
  }

  /// حذف جميع الإشعارات المقروءة
  Future<void> deleteReadNotifications(int userId) async {
    try {
      final success = await notificationRepository.deleteReadNotifications(userId);
      if (success) {
        _notifications.removeWhere((n) => n.isRead);
        notifyListeners();
      }
    } catch (e) {
    }
  }

  /// حذف جميع الإشعارات
  Future<void> deleteAllNotifications(int userId) async {
    try {
      final success = await notificationRepository.deleteAllNotifications(userId);
      if (success) {
        _notifications.clear();
        _unreadNotifications.clear();
        _unreadCount = 0;
        notifyListeners();
      }
    } catch (e) {
    }
  }

  /// إنشاء إشعار حجز
  Future<void> createBookingNotification({
    required int userId,
    required int appointmentId,
    required String serviceName,
    required DateTime appointmentDate,
    required String appointmentTime,
  }) async {
    try {
      final notification = NotificationModel(
        userId: userId,
        appointmentId: appointmentId,
        title: 'تم تأكيد حجزك',
        body: 'تم تأكيد حجز $serviceName في ${appointmentDate.day}/${appointmentDate.month} الساعة $appointmentTime',
        type: NotificationType.bookingConfirmed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final created = await notificationRepository.createNotification(notification);

      if (created != null) {
        _notifications.insert(0, created);
        _unreadNotifications.insert(0, created);
        _unreadCount++;

        // ✅ سيتم التحديث تلقائياً عبر Realtime
        notifyListeners();
      }

      await notificationService.showBookingConfirmation(
        appointmentId: appointmentId,
        serviceName: serviceName,
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
      );

      final appointmentDateTime = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        int.parse(appointmentTime.split(':')[0]),
        int.parse(appointmentTime.split(':')[1]),
      );

      await notificationService.scheduleAppointmentReminders(
        appointmentId: appointmentId,
        serviceName: serviceName,
        appointmentDateTime: appointmentDateTime,
      );
    } catch (e) {
    }
  }

  /// إنشاء إشعار إلغاء
  Future<void> createCancellationNotification({
    required int userId,
    required int appointmentId,
    required String serviceName,
  }) async {
    try {
      final notification = NotificationModel(
        userId: userId,
        appointmentId: appointmentId,
        title: 'تم إلغاء الموعد',
        body: 'تم إلغاء موعد $serviceName',
        type: NotificationType.cancelled,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final created = await notificationRepository.createNotification(notification);

      if (created != null) {
        _notifications.insert(0, created);
        _unreadNotifications.insert(0, created);
        _unreadCount++;
        notifyListeners();
      }

      await notificationService.showCancellationNotification(
        appointmentId: appointmentId,
        serviceName: serviceName,
      );
    } catch (e) {
    }
  }

  /// إنشاء إشعار عرض
  Future<void> createOfferNotification({
    required int userId,
    required String title,
    required String body,
    int? offerId,
  }) async {
    try {
      final notification = NotificationModel(
        userId: userId,
        title: title,
        body: body,
        type: NotificationType.offer,
        data: offerId != null ? {'offer_id': offerId} : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final created = await notificationRepository.createNotification(notification);

      if (created != null) {
        _notifications.insert(0, created);
        _unreadNotifications.insert(0, created);
        _unreadCount++;
        notifyListeners();
      }

      await notificationService.showOfferNotification(
        title: title,
        body: body,
        offerId: offerId,
      );
    } catch (e) {
    }
  }

  /// جلب إشعارات حسب النوع
  Future<List<NotificationModel>> getNotificationsByType(
      int userId,
      NotificationType type,
      ) async {
    try {
      return await notificationRepository.getNotificationsByType(userId, type);
    } catch (e) {
      return [];
    }
  }

  /// ✅ الاشتراك في تحديثات إشعارات المستخدم
  void subscribeToUserNotifications(int userId) {
    unsubscribeFromNotifications();


    _realtimeChannel = _supabase
        .channel('notifications_user_$userId')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) {

        if (payload.eventType == PostgresChangeEvent.insert) {
          // إشعار جديد
          if (payload.newRecord != null) {
            final newNotification = NotificationModel.fromJson(payload.newRecord);
            _notifications.insert(0, newNotification);

            if (!newNotification.isRead) {
              _unreadNotifications.insert(0, newNotification);
              _unreadCount++;
            }

            notifyListeners();
          }
        } else if (payload.eventType == PostgresChangeEvent.update) {
          // تحديث إشعار
          if (payload.newRecord != null) {
            final updatedNotification = NotificationModel.fromJson(payload.newRecord);
            final index = _notifications.indexWhere((n) => n.id == updatedNotification.id);

            if (index >= 0) {
              _notifications[index] = updatedNotification;
              _unreadNotifications = _notifications.where((n) => !n.isRead).toList();
              _unreadCount = _unreadNotifications.length;
              notifyListeners();
            }
          }
        } else if (payload.eventType == PostgresChangeEvent.delete) {
          // حذف إشعار
          if (payload.oldRecord != null) {
            final deletedId = payload.oldRecord['id'];
            _notifications.removeWhere((n) => n.id == deletedId);
            _unreadNotifications = _notifications.where((n) => !n.isRead).toList();
            _unreadCount = _unreadNotifications.length;
            notifyListeners();
          }
        }
      },
    )
        .subscribe();
  }


  Future<void> createLoyaltyPointsNotification({
    required int userId,
    required int appointmentId,
    required int pointsEarned,
    required String serviceName,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': 'مبروك! حصلت على نقاط ولاء 🎉',
        'message': 'لقد حصلت على $pointsEarned نقطة ولاء من حجزك "$serviceName"',
        'notification_type': 'loyalty',
        'is_read': false,
      });

    } catch (e) {
    }
  }

  // في NotificationProvider

  Future<void> createRescheduleNotification({
    required int userId,
    required int appointmentId,
    required DateTime newDate,
    required String newTime,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'appointment_id': appointmentId,
        'title': 'تم إعادة جدولة الموعد ✅',
        'body': 'تم إعادة جدولة موعدك بنجاح إلى ${DateFormat('d MMMM', 'ar').format(newDate)} في $newTime',
        'type': 'appointment',
        'is_read': false,
      });

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }


  /// ✅ إلغاء الاشتراك
  void unsubscribeFromNotifications() {
    if (_realtimeChannel != null) {
      _realtimeChannel!.unsubscribe();
      _realtimeChannel = null;
    }
  }

  @override
  void dispose() {
    unsubscribeFromNotifications();
    super.dispose();
  }
}