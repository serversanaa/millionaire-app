import 'package:flutter/material.dart';

class ResponsiveHelper {
  // ترجع حجم شاشة الجهاز (العرض والارتفاع)
  static Size mediaQuerySize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  // دالة لضبط حجم النص بناءً على عرض الشاشة (مع معيار 375 كبداية)
  static double textScale(BuildContext context, double baseFontSize) {
    final width = MediaQuery.of(context).size.width;
    double scale = width / 375;
    if (scale < 0.8) scale = 0.8;        // الحد الأدنى للتكبير
    if (scale > 1.3) scale = 1.3;        // الحد الأعلى للتكبير
    return baseFontSize * scale;
  }

  // دالة لضبط نسبة بالنسبة للعرض
  static double widthPercentage(BuildContext context, double percent) {
    final width = MediaQuery.of(context).size.width;
    return (width * percent) / 100;
  }

  // دالة لضبط نسبة بالنسبة للارتفاع
  static double heightPercentage(BuildContext context, double percent) {
    final height = MediaQuery.of(context).size.height;
    return (height * percent) / 100;
  }
}
