import 'package:millionaire_barber/features/settings/domain/models/settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsRepository {
  final SupabaseClient _supabase;

  // Keys for SharedPreferences
  static const String _keyDarkMode = 'is_dark_mode';
  static const String _keyLanguage = 'language';
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyEmailNotifications = 'email_notifications';
  static const String _keySmsNotifications = 'sms_notifications';
  static const String _keyBiometric = 'biometric_enabled';

  SettingsRepository(this._supabase);

  // ════════════════════════════════════════════════════════════════════════════
  // LOCAL STORAGE (SharedPreferences)
  // ════════════════════════════════════════════════════════════════════════════

  /// ✅ تحميل الإعدادات من SharedPreferences
  Future<SettingsModel> loadLocalSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return SettingsModel(
        isDarkMode: prefs.getBool(_keyDarkMode) ?? false,
        language: prefs.getString(_keyLanguage) ?? 'ar',
        notificationsEnabled: prefs.getBool(_keyNotifications) ?? true,
        emailNotifications: prefs.getBool(_keyEmailNotifications) ?? false,
        smsNotifications: prefs.getBool(_keySmsNotifications) ?? true,
        biometricEnabled: prefs.getBool(_keyBiometric) ?? false,
      );
    } catch (e) {
      return SettingsModel.defaultSettings();
    }
  }

  /// ✅ حفظ الإعدادات في SharedPreferences
  Future<void> saveLocalSettings(SettingsModel settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await Future.wait([
        prefs.setBool(_keyDarkMode, settings.isDarkMode),
        prefs.setString(_keyLanguage, settings.language),
        prefs.setBool(_keyNotifications, settings.notificationsEnabled),
        prefs.setBool(_keyEmailNotifications, settings.emailNotifications),
        prefs.setBool(_keySmsNotifications, settings.smsNotifications),
        prefs.setBool(_keyBiometric, settings.biometricEnabled),
      ]);

    } catch (e) {
      throw Exception('فشل حفظ الإعدادات محلياً');
    }
  }

  /// ✅ حفظ إعداد واحد محلياً
  Future<void> saveLocalSetting(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      }

    } catch (e) {
    }
  }

  /// ✅ مسح الإعدادات المحلية
  Future<void> clearLocalSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await Future.wait([
        prefs.remove(_keyDarkMode),
        prefs.remove(_keyLanguage),
        prefs.remove(_keyNotifications),
        prefs.remove(_keyEmailNotifications),
        prefs.remove(_keySmsNotifications),
        prefs.remove(_keyBiometric),
      ]);

    } catch (e) {
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // REMOTE STORAGE (Supabase)
  // ════════════════════════════════════════════════════════════════════════════

  /// ✅ تحميل الإعدادات من Supabase
  Future<SettingsModel?> loadRemoteSettings(int userId) async {
    try {
      final response = await _supabase
          .from('user_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        return SettingsModel.fromJson(response);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// ✅ حفظ الإعدادات في Supabase
  Future<void> saveRemoteSettings(int userId, SettingsModel settings) async {
    try {
      final data = {
        'user_id': userId,
        'is_dark_mode': settings.isDarkMode,
        'language': settings.language,
        'notifications_enabled': settings.notificationsEnabled,
        'email_notifications': settings.emailNotifications,
        'sms_notifications': settings.smsNotifications,
        'biometric_enabled': settings.biometricEnabled,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // استخدام upsert للإضافة أو التحديث
      await _supabase
          .from('user_settings')
          .upsert(data, onConflict: 'user_id');

    } catch (e) {
      throw Exception('فشل حفظ الإعدادات على السيرفر');
    }
  }

  /// ✅ تحديث إعداد واحد في Supabase
  Future<void> updateRemoteSetting(int userId, String key, dynamic value) async {
    try {
      await _supabase
          .from('user_settings')
          .update({
        key: value,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('user_id', userId);

    } catch (e) {
    }
  }

  /// ✅ حذف إعدادات المستخدم من Supabase
  Future<void> deleteRemoteSettings(int userId) async {
    try {
      await _supabase
          .from('user_settings')
          .delete()
          .eq('user_id', userId);

    } catch (e) {
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SYNC (Local + Remote)
  // ════════════════════════════════════════════════════════════════════════════

  /// ✅ مزامنة الإعدادات (Local + Remote)
  Future<SettingsModel> syncSettings(int userId) async {
    try {
      // 1. محاولة التحميل من Supabase
      final remoteSettings = await loadRemoteSettings(userId);

      if (remoteSettings != null) {
        // 2. حفظ الإعدادات البعيدة محلياً
        await saveLocalSettings(remoteSettings);
        return remoteSettings;
      }

      // 3. إذا لم توجد إعدادات بعيدة، استخدم المحلية
      final localSettings = await loadLocalSettings();

      // 4. رفع الإعدادات المحلية للسيرفر
      await saveRemoteSettings(userId, localSettings);

      return localSettings;
    } catch (e) {
      // في حالة الفشل، استخدم الإعدادات المحلية
      return await loadLocalSettings();
    }
  }

  /// ✅ فرض المزامنة (Remote → Local)
  Future<SettingsModel> forceRemoteSync(int userId) async {
    try {
      final remoteSettings = await loadRemoteSettings(userId);

      if (remoteSettings != null) {
        await saveLocalSettings(remoteSettings);
        return remoteSettings;
      }

      return await loadLocalSettings();
    } catch (e) {
      return await loadLocalSettings();
    }
  }

  /// ✅ فرض المزامنة (Local → Remote)
  Future<void> forceLocalSync(int userId) async {
    try {
      final localSettings = await loadLocalSettings();
      await saveRemoteSettings(userId, localSettings);
    } catch (e) {
      throw Exception('فشل المزامنة مع السيرفر');
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════════════════════

  /// ✅ التحقق من وجود إعدادات محلية
  Future<bool> hasLocalSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_keyDarkMode) ||
          prefs.containsKey(_keyLanguage);
    } catch (e) {
      return false;
    }
  }

  /// ✅ التحقق من وجود إعدادات بعيدة
  Future<bool> hasRemoteSettings(int userId) async {
    try {
      final response = await _supabase
          .from('user_settings')
          .select('user_id')
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// ✅ الحصول على آخر تحديث للإعدادات البعيدة
  Future<DateTime?> getRemoteLastUpdate(int userId) async {
    try {
      final response = await _supabase
          .from('user_settings')
          .select('updated_at')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null && response['updated_at'] != null) {
        return DateTime.parse(response['updated_at'].toString());
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}