// import 'package:flutter/material.dart';
// import 'package_service_model.dart';
//
// /// ═══════════════════════════════════════════════════════════════
// /// 📦 Package Model
// /// نموذج الباقة (مثل: الباقة الذهبية، الفضية، البرونزية)
// /// ═══════════════════════════════════════════════════════════════
//
// class PackageModel {
//   final int id;
//   final String nameAr;
//   final String? nameEn;
//   final String? descriptionAr;
//   final String? descriptionEn;
//
//   // السعر
//   final double price;
//   final double? originalPrice;
//   final int? discountPercentage;
//
//   // الصلاحية الزمنية
//   final DateTime validFrom;
//   final DateTime? validUntil;
//
//   // التصميم
//   final String? colorPrimary;      // HEX: #D4A056
//   final String? colorSecondary;    // HEX: #B8860B
//   final String? iconUrl;
//   final String? imageUrl;
//
//   // الترتيب والعرض
//   final int displayOrder;
//   final bool isActive;
//   final bool isFeatured;
//   final bool isSeasonal;
//
//   // الخدمات
//   final List<PackageServiceModel> services;
//
//   // التوقيت
//   final DateTime createdAt;
//   final DateTime updatedAt;
//
//   PackageModel({
//     required this.id,
//     required this.nameAr,
//     this.nameEn,
//     this.descriptionAr,
//     this.descriptionEn,
//     required this.price,
//     this.originalPrice,
//     this.discountPercentage,
//     required this.validFrom,
//     this.validUntil,
//     this.colorPrimary,
//     this.colorSecondary,
//     this.iconUrl,
//     this.imageUrl,
//     this.displayOrder = 0,
//     this.isActive = true,
//     this.isFeatured = false,
//     this.isSeasonal = false,
//     this.services = const [],
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   /// ═══════════════════════════════════════════════════════════════
//   /// Getters
//   /// ═══════════════════════════════════════════════════════════════
//
//   /// هل الباقة صالحة (ضمن الفترة الزمنية)؟
//   bool get isValid {
//     final now = DateTime.now();
//     return now.isAfter(validFrom) &&
//         (validUntil == null || now.isBefore(validUntil!));
//   }
//
//   /// هل الباقة قريبة من الانتهاء؟
//   bool get isExpiringSoon {
//     if (validUntil == null) return false;
//     final daysLeft = validUntil!.difference(DateTime.now()).inDays;
//     return daysLeft <= 7 && daysLeft > 0;
//   }
//
//   /// هل يوجد خصم؟
//   bool get hasDiscount => originalPrice != null && originalPrice! > price;
//
//   /// قيمة الخصم
//   double get savingsAmount => hasDiscount ? originalPrice! - price : 0;
//
//   /// نسبة الخصم المحسوبة
//   int get calculatedDiscountPercentage {
//     if (!hasDiscount) return 0;
//     return ((savingsAmount / originalPrice!) * 100).round();
//   }
//
//   /// اللون الأساسي
//   Color get primaryColor {
//     if (colorPrimary == null) return const Color(0xFFD4A056);
//     try {
//       return Color(int.parse('0xFF${colorPrimary!.replaceAll('#', '')}'));
//     } catch (e) {
//       return const Color(0xFFD4A056);
//     }
//   }
//
//   /// اللون الثانوي
//   Color get secondaryColor {
//     if (colorSecondary == null) return const Color(0xFFB8860B);
//     try {
//       return Color(int.parse('0xFF${colorSecondary!.replaceAll('#', '')}'));
//     } catch (e) {
//       return const Color(0xFFB8860B);
//     }
//   }
//
//   /// عدد الخدمات
//   int get servicesCount => services.length;
//
//   /// ═══════════════════════════════════════════════════════════════
//   /// Factory: From JSON
//   /// ═══════════════════════════════════════════════════════════════
//   factory PackageModel.fromJson(Map<String, dynamic> json) {
//     return PackageModel(
//       id: json['id'] as int,
//       nameAr: json['name_ar'] as String,
//       nameEn: json['name_en'] as String?,
//       descriptionAr: json['description_ar'] as String?,
//       descriptionEn: json['description_en'] as String?,
//       price: (json['price'] as num).toDouble(),
//       originalPrice: json['original_price'] != null
//           ? (json['original_price'] as num).toDouble()
//           : null,
//       discountPercentage: json['discount_percentage'] as int?,
//
//       // ✅ Fix: معالجة آمنة للتواريخ
//       validFrom: json['valid_from'] != null
//           ? DateTime.parse(json['valid_from'] as String)
//           : DateTime.now(),
//       validUntil: json['valid_until'] != null
//           ? DateTime.parse(json['valid_until'] as String)
//           : null,
//
//       colorPrimary: json['color_primary'] as String?,
//       colorSecondary: json['color_secondary'] as String?,
//       iconUrl: json['icon_url'] as String?,
//       imageUrl: json['image_url'] as String?,
//       displayOrder: json['display_order'] as int? ?? 0,
//       isActive: json['is_active'] as bool? ?? true,
//       isFeatured: json['is_featured'] as bool? ?? false,
//       isSeasonal: json['is_seasonal'] as bool? ?? false,
//
//       // ✅ Fix: معالجة آمنة للخدمات
//       services: json['services'] != null
//           ? (json['services'] is List
//           ? (json['services'] as List)
//           .map((s) => PackageServiceModel.fromJson(s as Map<String, dynamic>))
//           .toList()
//           : [])
//           : [],
//
//       // ✅ Fix: معالجة آمنة للتواريخ
//       createdAt: json['created_at'] != null
//           ? DateTime.parse(json['created_at'] as String)
//           : DateTime.now(),
//       updatedAt: json['updated_at'] != null
//           ? DateTime.parse(json['updated_at'] as String)
//           : DateTime.now(),
//     );
//   }
//
//   /// ═══════════════════════════════════════════════════════════════
//   /// To JSON
//   /// ═══════════════════════════════════════════════════════════════
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name_ar': nameAr,
//       'name_en': nameEn,
//       'description_ar': descriptionAr,
//       'description_en': descriptionEn,
//       'price': price,
//       'original_price': originalPrice,
//       'discount_percentage': discountPercentage,
//       'valid_from': validFrom.toIso8601String(),
//       'valid_until': validUntil?.toIso8601String(),
//       'color_primary': colorPrimary,
//       'color_secondary': colorSecondary,
//       'icon_url': iconUrl,
//       'image_url': imageUrl,
//       'display_order': displayOrder,
//       'is_active': isActive,
//       'is_featured': isFeatured,
//       'is_seasonal': isSeasonal,
//       'services': services.map((s) => s.toJson()).toList(),
//       'created_at': createdAt.toIso8601String(),
//       'updated_at': updatedAt.toIso8601String(),
//     };
//   }
//
//   /// ═══════════════════════════════════════════════════════════════
//   /// Copy With
//   /// ═══════════════════════════════════════════════════════════════
//   PackageModel copyWith({
//     int? id,
//     String? nameAr,
//     String? nameEn,
//     String? descriptionAr,
//     String? descriptionEn,
//     double? price,
//     double? originalPrice,
//     int? discountPercentage,
//     DateTime? validFrom,
//     DateTime? validUntil,
//     String? colorPrimary,
//     String? colorSecondary,
//     String? iconUrl,
//     String? imageUrl,
//     int? displayOrder,
//     bool? isActive,
//     bool? isFeatured,
//     bool? isSeasonal,
//     List<PackageServiceModel>? services,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//   }) {
//     return PackageModel(
//       id: id ?? this.id,
//       nameAr: nameAr ?? this.nameAr,
//       nameEn: nameEn ?? this.nameEn,
//       descriptionAr: descriptionAr ?? this.descriptionAr,
//       descriptionEn: descriptionEn ?? this.descriptionEn,
//       price: price ?? this.price,
//       originalPrice: originalPrice ?? this.originalPrice,
//       discountPercentage: discountPercentage ?? this.discountPercentage,
//       validFrom: validFrom ?? this.validFrom,
//       validUntil: validUntil ?? this.validUntil,
//       colorPrimary: colorPrimary ?? this.colorPrimary,
//       colorSecondary: colorSecondary ?? this.colorSecondary,
//       iconUrl: iconUrl ?? this.iconUrl,
//       imageUrl: imageUrl ?? this.imageUrl,
//       displayOrder: displayOrder ?? this.displayOrder,
//       isActive: isActive ?? this.isActive,
//       isFeatured: isFeatured ?? this.isFeatured,
//       isSeasonal: isSeasonal ?? this.isSeasonal,
//       services: services ?? this.services,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }
//
//   @override
//   String toString() {
//     return 'PackageModel(id: $id, nameAr: $nameAr, price: $price, services: ${services.length})';
//   }
//
//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//
//     return other is PackageModel &&
//         other.id == id &&
//         other.nameAr == nameAr &&
//         other.price == price;
//   }
//
//   @override
//   int get hashCode {
//     return id.hashCode ^ nameAr.hashCode ^ price.hashCode;
//   }
// }



// lib/features/packages/domain/models/package_model.dart


/// ═══════════════════════════════════════════════════════════════
/// 📦 Package Model
/// نموذج باقات العضوية الشاملة
///
/// الباقة = جلسة واحدة شاملة تحتوي على عدة خدمات تُنفذ في موعد واحد
/// مثال: الباقة الذهبية = موعد واحد يشمل (قص + حلاقة + حمام زيت + تسريحة)
/// ═══════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package_service_model.dart';

class PackageModel {
  // ═══════════════════════════════════════════════════════════════
  // 🔑 المعرفات الأساسية
  // ═══════════════════════════════════════════════════════════════

  /// المعرف الفريد للباقة (ID)
  final int id;

  /// اسم الباقة بالعربية (مطلوب) - مثل: "الباقة الذهبية"
  final String nameAr;

  /// اسم الباقة بالإنجليزية (اختياري) - مثل: "Gold Package"
  final String? nameEn;

  /// وصف الباقة بالعربية (اختياري)
  /// مثل: "باقة شاملة تحتوي على قص شعر، حلاقة ذقن، حمام زيت، وتسريحة شعر"
  final String? descriptionAr;

  /// وصف الباقة بالإنجليزية (اختياري)
  final String? descriptionEn;

  // ═══════════════════════════════════════════════════════════════
  // 💰 السعر والخصومات
  // ═══════════════════════════════════════════════════════════════

  /// السعر النهائي للباقة بالريال (بعد الخصم إن وجد)
  /// مثال: 450.00 ريال
  final double price;

  /// السعر الأصلي قبل الخصم (للمقارنة والعرض)
  /// مثال: 500.00 ريال قبل الخصم
  /// إذا كان null = لا يوجد خصم
  final double? originalPrice;

  /// نسبة الخصم المباشرة من قاعدة البيانات (اختياري)
  /// مثال: 10 (يعني 10%)
  final int? discountPercentage;

  // ═══════════════════════════════════════════════════════════════
  // 📅 فترة عرض الباقة (متى يمكن شراؤها)
  // ═══════════════════════════════════════════════════════════════

  /// تاريخ بدء عرض الباقة (من متى تظهر للعملاء في التطبيق)
  /// مثال: 2025-01-01 (تبدأ الباقة من أول يناير)
  final DateTime validFrom;

  /// تاريخ انتهاء عرض الباقة (حتى متى يمكن شراؤها)
  /// مثال: 2025-12-31 (الباقة متاحة حتى آخر ديسمبر)
  /// إذا كان null = الباقة متاحة دائماً
  final DateTime? validUntil;

  // ═══════════════════════════════════════════════════════════════
  // ⏰ صلاحية الاشتراك (بعد الشراء)
  // ═══════════════════════════════════════════════════════════════

  /// عدد أيام صلاحية الاشتراك بعد الشراء
  /// مثال: 30 يوم (العميل يشتري اليوم ويستخدم الباقة خلال 30 يوم)
  /// هذا مختلف عن validFrom/validUntil
  final int validityDays;

  /// عدد الجلسات الشاملة المتضمنة في الباقة
  ///
  /// ⚠️ ملاحظة مهمة جداً:
  /// • totalSessions = 1 يعني جلسة واحدة شاملة
  /// • الجلسة الشاملة = موعد واحد يتم فيه تنفيذ جميع الخدمات
  /// • مثال: الباقة الذهبية = 1 جلسة = 1 موعد = (قص + حلاقة + حمام + تسريحة)
  ///
  /// ليس:
  /// • totalSessions ≠ عدد الخدمات
  /// • totalSessions ≠ عدد المواعيد المنفصلة
  ///
  /// إذا أردت 5 جلسات منفصلة:
  /// • totalSessions = 5
  /// • يعني 5 مواعيد مختلفة، كل موعد يشمل نفس الخدمات
  final int totalSessions;

  // ═══════════════════════════════════════════════════════════════
  // 🎨 التصميم والألوان
  // ═══════════════════════════════════════════════════════════════

  /// اللون الأساسي للباقة (HEX format)
  /// مثال: "#D4A056" (ذهبي فاتح)
  final String? colorPrimary;

  /// اللون الثانوي للباقة (HEX format)
  /// مثال: "#B8860B" (ذهبي داكن)
  final String? colorSecondary;

  /// رابط أيقونة الباقة (من Supabase Storage أو CDN)
  /// مثال: "https://storage.supabase.co/.../gold_icon.png"
  final String? iconUrl;

  /// رابط صورة الباقة (من Supabase Storage أو CDN)
  /// مثال: "https://storage.supabase.co/.../gold_package.jpg"
  final String? imageUrl;

  // ═══════════════════════════════════════════════════════════════
  // 📊 الترتيب والعرض
  // ═══════════════════════════════════════════════════════════════

  /// ترتيب عرض الباقة في القائمة (الأقل = الأول)
  /// مثال: 1 (تظهر أولاً), 2 (تظهر ثانياً), إلخ
  final int displayOrder;

  /// هل الباقة نشطة ومعروضة للعملاء؟
  /// true = تظهر في التطبيق
  /// false = مخفية (للمسودات أو الباقات المعطلة مؤقتاً)
  final bool isActive;

  /// هل الباقة مميزة؟ (للعرض في قسم خاص أو بنجمة)
  /// true = تظهر في قسم "الباقات المميزة"
  final bool isFeatured;

  /// هل الباقة موسمية؟ (مرتبطة بموسم معين)
  /// مثال: باقة رمضان، باقة العيد، باقة الشتاء
  final bool isSeasonal;

  // ═══════════════════════════════════════════════════════════════
  // 🛠️ الخدمات المتضمنة
  // ═══════════════════════════════════════════════════════════════

  /// قائمة الخدمات المتضمنة في هذه الباقة
  ///
  /// ⚠️ جميع هذه الخدمات تُنفذ في موعد واحد (جلسة واحدة شاملة)
  ///
  /// مثال: الباقة الذهبية تحتوي على:
  /// • قص شعر
  /// • حلاقة ذقن
  /// • حمام زيت
  /// • تسريحة شعر
  ///
  /// العميل يحجز موعد واحد، وينفذ الحلاق جميع الخدمات بالتسلسل
  final List<PackageServiceModel> services;

  // ═══════════════════════════════════════════════════════════════
  // 📅 التوقيت
  // ═══════════════════════════════════════════════════════════════

  /// تاريخ إنشاء الباقة في قاعدة البيانات
  final DateTime createdAt;

  /// تاريخ آخر تحديث على الباقة
  final DateTime updatedAt;

  // ═══════════════════════════════════════════════════════════════
  // 🏗️ Constructor
  // ═══════════════════════════════════════════════════════════════

  PackageModel({
    required this.id,
    required this.nameAr,
    this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    required this.price,
    this.originalPrice,
    this.discountPercentage,
    required this.validFrom,
    this.validUntil,
    this.validityDays = 30,      // ✅ القيمة الافتراضية: 30 يوم
    this.totalSessions = 1,      // ✅ القيمة الافتراضية: 1 جلسة شاملة
    this.colorPrimary,
    this.colorSecondary,
    this.iconUrl,
    this.imageUrl,
    this.displayOrder = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.isSeasonal = false,
    this.services = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // ═══════════════════════════════════════════════════════════════
  // 🔍 Computed Properties - خصائص محسوبة تلقائياً
  // ═══════════════════════════════════════════════════════════════

  /// هل الباقة صالحة للشراء حالياً؟ (ضمن فترة العرض)
  ///
  /// يتحقق من:
  /// 1. الوقت الحالي بعد validFrom
  /// 2. الوقت الحالي قبل validUntil (أو لا يوجد validUntil)
  bool get isValid {
    final now = DateTime.now();
    return now.isAfter(validFrom) &&
        (validUntil == null || now.isBefore(validUntil!));
  }

  /// هل الباقة قريبة من الانتهاء؟ (متبقي 7 أيام أو أقل)
  ///
  /// يُستخدم لعرض تنبيه "الباقة ستنتهي قريباً - اشترك الآن!"
  bool get isExpiringSoon {
    if (validUntil == null) return false;
    final daysLeft = validUntil!.difference(DateTime.now()).inDays;
    return daysLeft <= 7 && daysLeft > 0;
  }

  /// هل يوجد خصم على الباقة؟
  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  /// قيمة الخصم بالريال
  /// مثال: السعر الأصلي 500 - السعر النهائي 450 = 50 ريال خصم
  double get savingsAmount => hasDiscount ? originalPrice! - price : 0;

  /// نسبة الخصم المحسوبة تلقائياً من الأسعار
  /// يستخدم إذا لم يكن discountPercentage محدد في قاعدة البيانات
  int get calculatedDiscountPercentage {
    if (!hasDiscount) return 0;
    return ((savingsAmount / originalPrice!) * 100).round();
  }

  /// النسبة النهائية للخصم (محدد أو محسوب)
  /// يفضل استخدام discountPercentage من قاعدة البيانات، وإلا يحسبها
  int get finalDiscountPercentage {
    return discountPercentage ?? calculatedDiscountPercentage;
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎨 الألوان (محولة من HEX إلى Color object)
  // ═══════════════════════════════════════════════════════════════

  /// اللون الأساسي للباقة (Color object للاستخدام في Flutter)
  /// الافتراضي: ذهبي #D4A056
  Color get primaryColor {
    if (colorPrimary == null) return const Color(0xFFD4A056);
    try {
      return Color(int.parse('0xFF${colorPrimary!.replaceAll('#', '')}'));
    } catch (e) {
      return const Color(0xFFD4A056);
    }
  }

  /// اللون الثانوي للباقة (Color object للاستخدام في Flutter)
  /// الافتراضي: ذهبي داكن #B8860B
  Color get secondaryColor {
    if (colorSecondary == null) return const Color(0xFFB8860B);
    try {
      return Color(int.parse('0xFF${colorSecondary!.replaceAll('#', '')}'));
    } catch (e) {
      return const Color(0xFFB8860B);
    }
  }

  /// تدرج لوني للباقة (للخلفيات والبطاقات)
  /// يُستخدم في تصميم بطاقة الباقة
  LinearGradient get gradientColors {
    return LinearGradient(
      colors: [primaryColor, secondaryColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 📊 إحصائيات الخدمات
  // ═══════════════════════════════════════════════════════════════

  /// عدد الخدمات المتضمنة في الباقة
  /// مثال: 4 خدمات (قص + حلاقة + حمام زيت + تسريحة)
  int get servicesCount => services.length;

  /// هل الباقة تحتوي على خدمات؟
  bool get hasServices => services.isNotEmpty;

  /// أسماء الخدمات بالعربية (للعرض في الواجهة)
  List<String> get serviceNames {
    return services
        .map((s) => s.nameAr)  // ✅ استخدم nameAr مباشرة
        .toList();
  }

  /// وصف الجلسة الشاملة (للعرض)
  String get sessionDescription {
    if (services.isEmpty) return 'جلسة شاملة';

    final serviceNames = services
        .map((s) => s.nameAr)  // ✅ استخدم nameAr مباشرة
        .where((name) => name.isNotEmpty)
        .join(' + ');

    return 'جلسة شاملة: $serviceNames';
  }


  /// المدة الإجمالية التقديرية للجلسة بالدقائق
  /// ⚠️ PackageServiceModel لا يحتوي على durationMinutes
  /// لذلك سنحذف هذا Getter أو نجعله يرجع 0
  int get estimatedDurationMinutes {
    // PackageServiceModel لا يحتوي على duration
    // يمكنك حذف هذا الـ getter أو تركه يرجع قيمة افتراضية
    return 0;
  }




  /// المدة الإجمالية مُنسقة (للعرض)
  /// مثال: "ساعة و 15 دقيقة"
  String get formattedDuration {
    if (estimatedDurationMinutes == 0) return 'غير محدد';

    final hours = estimatedDurationMinutes ~/ 60;
    final minutes = estimatedDurationMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '$hours ساعة و $minutes دقيقة';
    } else if (hours > 0) {
      return '$hours ساعة';
    } else {
      return '$minutes دقيقة';
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔄 JSON Serialization
  // ═══════════════════════════════════════════════════════════════
  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] as int,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String?,
      descriptionAr: json['description_ar'] as String?,
      descriptionEn: json['description_en'] as String?,
      price: (json['price'] as num).toDouble(),
      originalPrice: json['original_price'] != null
          ? (json['original_price'] as num).toDouble()
          : null,
      discountPercentage: json['discount_percentage'] as int?,

      validFrom: json['valid_from'] != null
          ? DateTime.parse(json['valid_from'] as String)
          : DateTime.now(),
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'] as String)
          : null,

      validityDays: json['validity_days'] as int? ?? 30,
      totalSessions: json['total_sessions'] as int? ?? 1,

      colorPrimary: json['color_primary'] as String?,
      colorSecondary: json['color_secondary'] as String?,
      iconUrl: json['icon_url'] as String?,
      imageUrl: json['image_url'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      isSeasonal: json['is_seasonal'] as bool? ?? false,

      // ✅ معالجة صحيحة للخدمات من package_services
      services: _parseServices(json),

      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

// ✅ Helper method لمعالجة الخدمات
//   static List<PackageServiceModel> _parseServices(Map<String, dynamic> json) {
//     try {
//       // البحث في package_services أولاً (من Supabase مع join)
//       if (json['package_services'] != null && json['package_services'] is List) {
//         return (json['package_services'] as List).map((ps) {
//           final serviceData = ps['services'];
//           if (serviceData != null) {
//             return PackageServiceModel.fromJson(serviceData as Map<String, dynamic>);
//           }
//           return null;
//         }).whereType<PackageServiceModel>().toList();
//       }
//
//       // أو البحث في services مباشرة (من API أو cache)
//       if (json['services'] != null && json['services'] is List) {
//         return (json['services'] as List)
//             .map((s) => PackageServiceModel.fromJson(s as Map<String, dynamic>))
//             .toList();
//       }
//
//       return [];
//     } catch (e) {
//       print('❌ Error parsing services: $e');
//       return [];
//     }
//   }


  static List<PackageServiceModel> _parseServices(Map<String, dynamic> json) {
    try {
      // ✅ البحث في package_services (الخدمات مُخزنة مباشرة فيه)
      if (json['package_services'] != null && json['package_services'] is List) {
        return (json['package_services'] as List)
            .map((ps) => PackageServiceModel.fromJson(ps as Map<String, dynamic>))
            .toList();
      }

      // Fallback: البحث في services إذا كانت موجودة (للتوافق مع API مختلف)
      if (json['services'] != null && json['services'] is List) {
        return (json['services'] as List)
            .map((s) => PackageServiceModel.fromJson(s as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }



  /// تحويل من PackageModel إلى JSON (للإرسال إلى Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'price': price,
      'original_price': originalPrice,
      'discount_percentage': discountPercentage,
      'valid_from': validFrom.toIso8601String(),
      'valid_until': validUntil?.toIso8601String(),
      'validity_days': validityDays,
      'total_sessions': totalSessions,
      'color_primary': colorPrimary,
      'color_secondary': colorSecondary,
      'icon_url': iconUrl,
      'image_url': imageUrl,
      'display_order': displayOrder,
      'is_active': isActive,
      'is_featured': isFeatured,
      'is_seasonal': isSeasonal,
      'services': services.map((s) => s.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔄 Copy With Method
  // ═══════════════════════════════════════════════════════════════

  /// إنشاء نسخة معدلة من الباقة مع تغيير بعض الحقول
  /// مفيد لتحديث البيانات بدون تغيير الكائن الأصلي
  PackageModel copyWith({
    int? id,
    String? nameAr,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    double? price,
    double? originalPrice,
    int? discountPercentage,
    DateTime? validFrom,
    DateTime? validUntil,
    int? validityDays,
    int? totalSessions,
    String? colorPrimary,
    String? colorSecondary,
    String? iconUrl,
    String? imageUrl,
    int? displayOrder,
    bool? isActive,
    bool? isFeatured,
    bool? isSeasonal,
    List<PackageServiceModel>? services,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PackageModel(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      validityDays: validityDays ?? this.validityDays,
      totalSessions: totalSessions ?? this.totalSessions,
      colorPrimary: colorPrimary ?? this.colorPrimary,
      colorSecondary: colorSecondary ?? this.colorSecondary,
      iconUrl: iconUrl ?? this.iconUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      isSeasonal: isSeasonal ?? this.isSeasonal,
      services: services ?? this.services,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔍 Override Methods
  // ═══════════════════════════════════════════════════════════════

  @override
  String toString() {
    return 'PackageModel(id: $id, nameAr: $nameAr, price: $price SAR, '
        'validityDays: $validityDays days, totalSessions: $totalSessions, '
        'services: ${services.length}, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PackageModel &&
        other.id == id &&
        other.nameAr == nameAr &&
        other.price == price;
  }

  @override
  int get hashCode {
    return id.hashCode ^ nameAr.hashCode ^ price.hashCode;
  }
}