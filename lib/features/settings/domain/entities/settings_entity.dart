class SettingsEntity {
  final bool isDarkMode;
  final String language;
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool biometricEnabled;

  const SettingsEntity({
    required this.isDarkMode,
    required this.language,
    required this.notificationsEnabled,
    required this.emailNotifications,
    required this.smsNotifications,
    required this.biometricEnabled,
  });

  SettingsEntity copyWith({
    bool? isDarkMode,
    String? language,
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? biometricEnabled,
  }) {
    return SettingsEntity(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }
}
