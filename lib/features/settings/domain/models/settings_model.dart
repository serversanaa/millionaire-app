import '../../../../core/utils/type_parser.dart';

class SettingsModel {
  final bool isDarkMode;
  final String language;
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool biometricEnabled;

  const SettingsModel({
    required this.isDarkMode,
    required this.language,
    required this.notificationsEnabled,
    required this.emailNotifications,
    required this.smsNotifications,
    required this.biometricEnabled,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      isDarkMode: parseBool(json['is_dark_mode'], defaultValue: false), // ✅
      language: parseString(json['language'], defaultValue: 'ar'), // ✅
      notificationsEnabled: parseBool(json['notifications_enabled'], defaultValue: true), // ✅
      emailNotifications: parseBool(json['email_notifications'], defaultValue: false), // ✅
      smsNotifications: parseBool(json['sms_notifications'], defaultValue: true), // ✅
      biometricEnabled: parseBool(json['biometric_enabled'], defaultValue: false), // ✅
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_dark_mode': isDarkMode,
      'language': language,
      'notifications_enabled': notificationsEnabled,
      'email_notifications': emailNotifications,
      'sms_notifications': smsNotifications,
      'biometric_enabled': biometricEnabled,
    };
  }

  factory SettingsModel.defaultSettings() {
    return const SettingsModel(
      isDarkMode: false,
      language: 'ar',
      notificationsEnabled: true,
      emailNotifications: false,
      smsNotifications: true,
      biometricEnabled: false,
    );
  }

  SettingsModel copyWith({
    bool? isDarkMode,
    String? language,
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? biometricEnabled,
  }) {
    return SettingsModel(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }
}
