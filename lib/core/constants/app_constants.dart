class Constants {
  const Constants._();

  static const String appName = 'مركز المليونير للحلاقة';

  static const bool isDebugMode = true;

  // مفاتيح Supabase (ضع القيم الحقيقية لاحقاً)
  static const String supabaseUrl = 'https://xdkdyrgkxltixyaeqevb.supabase.co';

  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhka2R5cmdreGx0aXh5YWVxZXZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgyOTg1MjQsImV4cCI6MjA3Mzg3NDUyNH0.5RKfYp-JO_xhZ3x8bEqr-vYiiFnNBW-IwsNq6vBWo-Y';

  // إعدادات عامة
  static const String supportPhone = '+966501234567';
  static const String salonName = 'مركز المليونير للحلاقة';

  // أوقات العمل
  static const String workingHoursStart = '09:00';
  static const String workingHoursEnd = '22:00';

  // حدود التطبيق
  static const int defaultServiceDuration = 30; // بالدقائق
  static const int maxAdvanceBookingDays = 30;

  // مفاتيح التخزين المحلي
  static const String userTokenKey = 'user_token';
  static const String languageKey = 'language';

  // إعدادات التصميم
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1024;


  static const String baseUrl = '';  // ضع هنا إذا كنت ستستخدم API خارجي بخلاف supabase
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;

}
