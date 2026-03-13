import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:millionaire_barber/features/profile/domain/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepository {
  final SupabaseClient client;

  UserRepository(this.client);

  /// جلب مستخدم بواسطة الـ ID
  Future<UserModel?> getUserById(int id) async {
    final data = await client.from('users').select().eq('id', id).maybeSingle();

    if (data == null) return null;

    if (data is Map<String, dynamic>) return UserModel.fromJson(data);
    if (data is Map) return UserModel.fromJson(Map<String, dynamic>.from(data));

    throw Exception('تنسيق بيانات المستخدم غير صحيح');
  }

  /// إنشاء مستخدم جديد
  Future<UserModel> createUser(UserModel user) async {
    final data = await client.from('users').insert(user.toJson()).select().maybeSingle();

    if (data == null) throw Exception('فشل إنشاء المستخدم');

    if (data is Map<String, dynamic>) return UserModel.fromJson(data);
    if (data is Map) return UserModel.fromJson(Map<String, dynamic>.from(data));

    throw Exception('تنسيق بيانات المستخدم المنشأ غير صحيح');
  }

  /// تحديث بيانات مستخدم
  Future<UserModel?> updateUser(int id, Map<String, dynamic> updates) async {
    final data = await client.from('users').update(updates).eq('id', id).select().maybeSingle();

    if (data == null) return null;

    if (data is Map<String, dynamic>) return UserModel.fromJson(data);
    if (data is Map) return UserModel.fromJson(Map<String, dynamic>.from(data));

    throw Exception('تنسيق بيانات المستخدم المحدّث غير صحيح');
  }

  /// حذف مستخدم بواسطة الـ ID
  Future<void> deleteUser(int id) async {
    final res = await client.from('users').delete().eq('id', id);

    if (res.error != null) throw Exception('خطأ في حذف المستخدم: ${res.error!.message}');
  }

  /// جلب المستخدم الحالي عبر معرف مخزن في SharedPreferences
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('current_user_id');

    if (userId == null) return null;

    final data = await client.from('users').select().eq('id', userId).maybeSingle();

    if (data == null) return null;

    if (data is Map<String, dynamic>) return UserModel.fromJson(data);
    if (data is Map) return UserModel.fromJson(Map<String, dynamic>.from(data));

    throw Exception('تنسيق بيانات المستخدم غير صحيح');
  }


  // دالة بحث مستخدم حسب البريد الالكتروني
  Future<UserModel?> getUserByEmail(String email) async {
    final data = await client.from('users').select().eq('email', email).maybeSingle();

    if (data == null) return null;

    if (data is Map<String, dynamic>) return UserModel.fromJson(data);
    if (data is Map) return UserModel.fromJson(Map<String, dynamic>.from(data));

    throw Exception('تنسيق بيانات المستخدم غير صحيح');
  }

  // دالة بحث مستخدم حسب رقم الهاتف
  Future<UserModel?> getUserByPhone(String phone) async {
    final data = await client.from('users').select().eq('phone', phone).maybeSingle();

    if (data == null) return null;

    if (data is Map<String, dynamic>) return UserModel.fromJson(data);
    if (data is Map) return UserModel.fromJson(Map<String, dynamic>.from(data));

    throw Exception('تنسيق بيانات المستخدم غير صحيح');
  }

  Future<void> updatePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // 1. الحصول على كلمة المرور المشفرة من قاعدة البيانات
      final response = await client
          .from('users')
          .select('password_hash')
          .eq('id', userId)
          .single();

      final storedHash = response['password_hash'] as String?;

      if (storedHash == null) {
        throw Exception('لم يتم العثور على كلمة المرور');
      }

      // 2. تشفير كلمة المرور الحالية والتحقق منها
      final currentHash = _hashPassword(currentPassword);

      if (currentHash != storedHash) {
        throw Exception('كلمة المرور الحالية غير صحيحة');
      }

      // 3. تشفير كلمة المرور الجديدة
      final newHash = _hashPassword(newPassword);

      // 4. تحديث كلمة المرور في قاعدة البيانات
      await client
          .from('users')
          .update({
        'password_hash': newHash,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);

    } catch (e) {
      rethrow;
    }
  }

  /// ✅ تشفير كلمة المرور
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// ✅ التحقق من كلمة المرور
  Future<bool> verifyCurrentPassword(int userId, String password) async {
    try {
      final response = await client
          .from('users')
          .select('password_hash')
          .eq('id', userId)
          .single();

      final storedHash = response['password_hash'] as String?;
      if (storedHash == null) return false;

      final inputHash = _hashPassword(password);
      return inputHash == storedHash;
    } catch (e) {
      return false;
    }
  }







  /// حفظ معرف المستخدم الحالي في SharedPreferences
  Future<void> saveCurrentUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_user_id', id);
  }

  /// مسح معرف المستخدم الحالي من SharedPreferences
  Future<void> clearCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
  }

  /// الاشتراك في تحديثات بيانات المستخدم realtime
  Stream<List<Map<String, dynamic>>> userStream(int id) {
    return client.from('users:id=eq.$id').stream(primaryKey: ['id']);
  }
}