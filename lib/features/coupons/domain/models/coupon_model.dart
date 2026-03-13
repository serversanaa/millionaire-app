// lib/features/coupons/domain/models/user_stats_model.dart

// class CouponModel {
//   final int? id;
//   final String code;
//   final String discountType; // 'percentage' or 'fixed'
//   final double discountValue;
//   final double minAmount;
//   final double? maxDiscount;
//   final int? usageLimit;
//   final int usagePerUser;
//   final DateTime startDate;
//   final DateTime endDate;
//   final bool isActive;
//   final bool isVipOnly;
//   final String? description;
//   final String? descriptionAr;
//   final DateTime? createdAt;
//
//   CouponModel({
//     this.id,
//     required this.code,
//     required this.discountType,
//     required this.discountValue,
//     this.minAmount = 0,
//     this.maxDiscount,
//     this.usageLimit,
//     this.usagePerUser = 1,
//     required this.startDate,
//     required this.endDate,
//     this.isActive = true,
//     this.isVipOnly = false,
//     this.description,
//     this.descriptionAr,
//     this.createdAt,
//   });
//
//   factory CouponModel.fromJson(Map<String, dynamic> json) {
//     return CouponModel(
//       id: json['id'] as int?,
//       code: json['code'] as String,
//       discountType: json['discount_type'] as String,
//       discountValue: (json['discount_value'] as num).toDouble(),
//       minAmount: (json['min_amount'] as num?)?.toDouble() ?? 0,
//       maxDiscount: (json['max_discount'] as num?)?.toDouble(),
//       usageLimit: json['usage_limit'] as int?,
//       usagePerUser: json['usage_per_user'] as int? ?? 1,
//       startDate: DateTime.parse(json['start_date'] as String),
//       endDate: DateTime.parse(json['end_date'] as String),
//       isActive: json['is_active'] as bool? ?? true,
//       isVipOnly: json['is_vip_only'] as bool? ?? false,
//       description: json['description'] as String?,
//       descriptionAr: json['description_ar'] as String?,
//       createdAt: json['created_at'] != null
//           ? DateTime.parse(json['created_at'] as String)
//           : null,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       if (id != null) 'id': id,
//       'code': code,
//       'discount_type': discountType,
//       'discount_value': discountValue,
//       'min_amount': minAmount,
//       if (maxDiscount != null) 'max_discount': maxDiscount,
//       if (usageLimit != null) 'usage_limit': usageLimit,
//       'usage_per_user': usagePerUser,
//       'start_date': startDate.toIso8601String(),
//       'end_date': endDate.toIso8601String(),
//       'is_active': isActive,
//       'is_vip_only': isVipOnly,
//       if (description != null) 'description': description,
//       if (descriptionAr != null) 'description_ar': descriptionAr,
//     };
//   }
//
//   bool get isValid {
//     final now = DateTime.now();
//     return isActive && now.isAfter(startDate) && now.isBefore(endDate);
//   }
//
//   String getDisplayDescription() {
//     return descriptionAr ?? description ?? '';
//   }
//
//   String getDiscountText() {
//     if (discountType == 'percentage') {
//       return '${discountValue.toStringAsFixed(0)}%';
//     } else {
//       return '${discountValue.toStringAsFixed(0)} ريال';
//     }
//   }
// }
//
// // نموذج نتيجة التحقق من الكوبون
// class CouponValidationResult {
//   final bool valid;
//   final int? couponId;
//   final String? discountType;
//   final double? discountValue;
//   final double? discountAmount;
//   final double? finalAmount;
//   final String message;
//
//   CouponValidationResult({
//     required this.valid,
//     this.couponId,
//     this.discountType,
//     this.discountValue,
//     this.discountAmount,
//     this.finalAmount,
//     required this.message,
//   });
//
//   factory CouponValidationResult.fromJson(Map<String, dynamic> json) {
//     return CouponValidationResult(
//       valid: json['valid'] as bool,
//       couponId: json['coupon_id'] as int?,
//       discountType: json['discount_type'] as String?,
//       discountValue: (json['discount_value'] as num?)?.toDouble(),
//       discountAmount: (json['discount_amount'] as num?)?.toDouble(),
//       finalAmount: (json['final_amount'] as num?)?.toDouble(),
//       message: json['message'] as String,
//     );
//   }
// }




import 'package:flutter/services.dart';

class CouponModel {
  final int? id;
  final String code;
  final String discountType;
  final double discountValue;
  final double minAmount;
  final double? maxDiscount;
  final int? usageLimit;
  final int? usagePerUser;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool isVipOnly;
  final String? description;
  final String? descriptionAr;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? userId;
  final int? usedCount;  // ✅ إضافة

  // ✅ حقول جديدة
  final bool? isUsed;
  final DateTime? usedAt;
  final DateTime? achievedAt;

  CouponModel({
    this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.minAmount,
    this.maxDiscount,
    this.usageLimit,
    this.usagePerUser,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.isVipOnly,
    this.description,
    this.descriptionAr,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.isUsed,
    this.usedAt,
    this.achievedAt,
    this.usedCount,

  });

  // ✅ Getters
  bool get isExpiredNow => DateTime.now().isAfter(endDate);

  bool get isExpiringSoon {
    final daysUntilExpiry = endDate.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 7 && daysUntilExpiry > 0;
  }

  bool get canUse => isActive && !isExpiredNow && !(isUsed ?? false);

  String get status {
    if (isUsed ?? false) return 'مستخدم';
    if (isExpiredNow) return 'منتهي';
    return 'متاح';
  }

  // ✅ Method لنسخ الكود
  Future<void> copyCode() async {
    await Clipboard.setData(ClipboardData(text: code));
  }
  // ✅ من جدول coupons العادي
  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'] as int?,
      code: json['code'] as String,
      discountType: json['discount_type'] as String,
      discountValue: (json['discount_value'] as num).toDouble(),
      minAmount: (json['min_amount'] as num?)?.toDouble() ?? 0,
      maxDiscount: (json['max_discount'] as num?)?.toDouble(),
      usageLimit: json['usage_limit'] as int?,
      usagePerUser: json['usage_per_user'] as int? ?? 1,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      isActive: json['is_active'] as bool? ?? true,
      isVipOnly: json['is_vip_only'] as bool? ?? false,
      description: json['description'] as String?,
      descriptionAr: json['description_ar'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      userId: json['user_id'] as int?,
      usedCount: json['used_count'] as int? ?? 0,  // ✅ إضافة

    );
  }

  // ✅ من RPC get_user_milestone_coupons
  // factory CouponModel.fromMilestoneCoupon(Map<String, dynamic> json) {
  //   return CouponModel(
  //     id: json['coupon_id'] as int?,
  //     code: json['coupon_code'] as String,
  //     discountType: 'percentage',
  //
  //     // ✅ الحل: استخدام null-aware operator
  //     discountValue: json['discount_percentage'] != null
  //         ? (json['discount_percentage'] as num).toDouble()
  //         : 0.0,
  //
  //     minAmount: json['min_amount'] != null
  //         ? (json['min_amount'] as num).toDouble()
  //         : 0.0,
  //
  //     maxDiscount: json['max_discount'] != null
  //         ? (json['max_discount'] as num).toDouble()
  //         : null,
  //
  //     usageLimit: json['usage_limit'] as int? ?? 1,
  //     usagePerUser: json['usage_per_user'] as int? ?? 1,
  //
  //     startDate: json['achieved_at'] != null
  //         ? DateTime.parse(json['achieved_at'] as String)
  //         : DateTime.now(),
  //
  //     endDate: DateTime.parse(json['expires_at'] as String),
  //
  //     isActive: true,
  //     isVipOnly: false,
  //
  //     description: json['description'] as String?,
  //     descriptionAr: json['description_ar'] as String?,
  //
  //     createdAt: json['achieved_at'] != null
  //         ? DateTime.parse(json['achieved_at'] as String)
  //         : null,
  //
  //     // ✅ الحقول الجديدة
  //     isUsed: json['is_used'] as bool? ?? false,
  //
  //     usedAt: json['used_at'] != null
  //         ? DateTime.parse(json['used_at'] as String)
  //         : null,
  //
  //     achievedAt: json['achieved_at'] != null
  //         ? DateTime.parse(json['achieved_at'] as String)
  //         : null,
  //   );
  // }

  factory CouponModel.fromMilestoneCoupon(Map<String, dynamic> json) {
    final bool isUsedFromUMA = json['is_used'] as bool? ?? false;
    final int usedCount = json['used_count'] as int? ?? 0;

    return CouponModel(
      id: json['coupon_id'] as int?,
      code: json['coupon_code'] as String,
      discountType: 'percentage',
      discountValue: (json['discount_percentage'] as num?)?.toDouble() ?? 0.0,
      minAmount: 0.0,
      maxDiscount: json['max_discount'] != null
          ? (json['max_discount'] as num).toDouble()
          : null,
      usageLimit: 1,
      usagePerUser: 1,
      startDate: json['achieved_at'] != null
          ? DateTime.parse(json['achieved_at'] as String)
          : DateTime.now(),
      endDate: DateTime.parse(json['expires_at'] as String),
      isActive: true,
      isVipOnly: false,
      description: json['description'] as String?,
      descriptionAr: json['description_ar'] as String?,
      createdAt: json['achieved_at'] != null
          ? DateTime.parse(json['achieved_at'] as String)
          : null,
      isUsed: isUsedFromUMA || usedCount > 0,  // ✅
      usedAt: json['used_at'] != null
          ? DateTime.parse(json['used_at'] as String)
          : null,
      achievedAt: json['achieved_at'] != null
          ? DateTime.parse(json['achieved_at'] as String)
          : null,
      usedCount: usedCount,  // ✅
    );
  }



  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'code': code,
      'discount_type': discountType,
      'discount_value': discountValue,
      'min_amount': minAmount,
      if (maxDiscount != null) 'max_discount': maxDiscount,
      if (usageLimit != null) 'usage_limit': usageLimit,
      'usage_per_user': usagePerUser,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
      'is_vip_only': isVipOnly,
      if (description != null) 'description': description,
      if (descriptionAr != null) 'description_ar': descriptionAr,
      if (userId != null) 'user_id': userId,
    };
  }

  // ✅ حالة الكوبون
  bool get isValid {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }



  // ✅ لون الحالة
  CouponStatus get statusEnum {
    if (isUsed == true) return CouponStatus.used;
    if (isExpiredNow) return CouponStatus.expired;
    if (canUse) return CouponStatus.available;
    return CouponStatus.inactive;
  }

  // ✅ عرض الوصف
  String getDisplayDescription() {
    return descriptionAr ?? description ?? '';
  }

  // ✅ نص الخصم
  String getDiscountText() {
    if (discountType == 'percentage') {
      return '${discountValue.toStringAsFixed(0)}%';
    } else {
      return '${discountValue.toStringAsFixed(0)} ريال';
    }
  }

  // ✅ وصف كامل للخصم
  String getFullDiscountDescription() {
    final discountText = getDiscountText();
    if (discountType == 'percentage' && maxDiscount != null) {
      return 'خصم $discountText (حد أقصى ${maxDiscount!.toStringAsFixed(0)} ريال)';
    }
    return 'خصم $discountText';
  }

  // ✅ أيام متبقية
  int get daysRemaining {
    if (isExpiredNow) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }




  CouponModel copyWith({
    int? id,
    String? code,
    String? discountType,
    double? discountValue,
    double? minAmount,
    double? maxDiscount,
    int? usageLimit,
    int? usagePerUser,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    bool? isVipOnly,
    String? description,
    String? descriptionAr,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? userId,
    bool? isExpired,
    bool? isUsed,
    DateTime? achievedAt,
    int? milestoneId,
  }) {
    return CouponModel(
      id: id ?? this.id,
      code: code ?? this.code,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minAmount: minAmount ?? this.minAmount,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      usageLimit: usageLimit ?? this.usageLimit,
      usagePerUser: usagePerUser ?? this.usagePerUser,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      isVipOnly: isVipOnly ?? this.isVipOnly,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      isUsed: isUsed ?? this.isUsed,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }

  @override
  String toString() {
    return 'CouponModel(id: $id, code: $code, discount: ${getDiscountText()}, status: $status)';
  }
}

// ✅ Enum لحالة الكوبون
enum CouponStatus {
  available,
  used,
  expired,
  inactive,
}



/// ═══════════════════════════════════════════════════════════════
/// Coupon Validation Result
/// ═══════════════════════════════════════════════════════════════

class CouponValidationResult {
  final bool valid;
  final String message;
  final int? couponId;
  final String? discountType;
  final double? discountValue;
  final double? discountAmount;
  final double? finalAmount;
  final CouponModel? coupon;

  CouponValidationResult({
    required this.valid,
    required this.message,
    this.couponId,
    this.discountType,
    this.discountValue,
    this.discountAmount,
    this.finalAmount,
    this.coupon,
  });

  // ✅ إضافة factory method
  factory CouponValidationResult.fromJson(Map<String, dynamic> json) {
    return CouponValidationResult(
      valid: json['is_valid'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      couponId: json['coupon_id'] as int?,
      discountType: json['discount_type'] as String?,
      discountValue: json['discount_value'] != null
          ? (json['discount_value'] as num).toDouble()
          : null,
      discountAmount: json['discount_amount'] != null
          ? (json['discount_amount'] as num).toDouble()
          : null,
      finalAmount: json['final_amount'] != null
          ? (json['final_amount'] as num).toDouble()
          : null,
    );
  }

  // ✅ إضافة getter للتوافق
  bool get isValid => valid;

  @override
  String toString() {
    return 'CouponValidationResult(valid: $valid, message: $message, '
        'discountAmount: $discountAmount, finalAmount: $finalAmount)';
  }
}
