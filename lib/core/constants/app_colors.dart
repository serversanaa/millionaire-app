import 'package:flutter/material.dart';

class AppColors {
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);


  // الأحمر الداكن (مركز)
  static const Color darkRed = Color(0xFFA62424);
  static const Color darkRedLight = Color(0xFFE57373); // أفتح للـ hover أو خلفيات
  static const Color darkRedDark = Color(0xFF8B0000);  // أغمق للأزرار أو borders

  static const Color primary = darkRedDark; // الأحمر الداكن هو اللون الأساسي

  // الذهبي
  static const Color gold = Color(0xFFB6862C);
  static const Color goldLight = Color(0xFFFFD700); // ذهبي مشرق للـ highlights
  static const Color goldDark = Color(0xFF8B6B1A);  // ذهب غامق للـ text أو shadows

  // الرمادي
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyMedium = Color(0xFF9E9E9E);
  static const Color greyDark = Color(0xFF424242);

  // الرسائل
  static const Color success = Color(0xFF43A047); // أخضر هادئ وجذاب
  static const Color error   = Color(0xFFE53935); // أحمر غني وواضح
  static const Color warning = Color(0xFFFFB300); // أصفر دافئ
  static const Color info    = Color(0xFF1E88E5); // أزرق حديث


  // ألوان إضافية للأزرق (لـ gradients)
  static const Color accentBlue = Color(0xFF1976D2);      // أزرق أساسي
  static const Color accentLightBlue = Color(0xFF64B5F6); // أزرق فاتح
}
