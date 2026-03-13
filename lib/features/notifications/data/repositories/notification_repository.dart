// lib/features/notifications/data/repositories/notification_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/notification_model.dart';

class NotificationRepository {
  final SupabaseClient client;

  NotificationRepository(this.client);

  /// جلب جميع إشعارات المستخدم
  Future<List<NotificationModel>> getUserNotifications(int userId) async {
    try {
      final response = await client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (response == null) return [];

      return (response as List)
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// جلب الإشعارات غير المقروءة
  Future<List<NotificationModel>> getUnreadNotifications(int userId) async {
    try {
      final response = await client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('is_read', false)
          .order('created_at', ascending: false);

      if (response == null) return [];

      return (response as List)
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// إنشاء إشعار جديد
  Future<NotificationModel?> createNotification(NotificationModel notification) async {
    try {
      final data = notification.toJson();
      data.remove('id'); // إزالة id للسماح لقاعدة البيانات بتوليده

      final response = await client
          .from('notifications')
          .insert(data)
          .select()
          .single();

      return NotificationModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// تحديث إشعار (مثل تعليمه كمقروء)
  Future<bool> markAsRead(int notificationId) async {
    try {
      await client
          .from('notifications')
          .update({
        'is_read': true,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', notificationId);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// تعليم جميع الإشعارات كمقروءة
  Future<bool> markAllAsRead(int userId) async {
    try {
      await client
          .from('notifications')
          .update({
        'is_read': true,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('user_id', userId)
          .eq('is_read', false);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// حذف إشعار
  Future<bool> deleteNotification(int notificationId) async {
    try {
      await client
          .from('notifications')
          .delete()
          .eq('id', notificationId);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// حذف جميع الإشعارات المقروءة
  Future<bool> deleteReadNotifications(int userId) async {
    try {
      await client
          .from('notifications')
          .delete()
          .eq('user_id', userId)
          .eq('is_read', true);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// عدد الإشعارات غير المقروءة
  /// عدد الإشعارات غير المقروءة
  Future<int> getUnreadCount(int userId) async {
    try {
      // ✅ الطريقة الجديدة
      final response = await client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('is_read', false);

      if (response == null) return 0;

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  /// حذف جميع إشعارات المستخدم
  Future<bool> deleteAllNotifications(int userId) async {
    try {
      await client
          .from('notifications')
          .delete()
          .eq('user_id', userId);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// جلب إشعارات حسب النوع
  Future<List<NotificationModel>> getNotificationsByType(
      int userId,
      NotificationType type,
      ) async {
    try {
      final response = await client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('type', type.value)
          .order('created_at', ascending: false);

      if (response == null) return [];

      return (response as List)
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}