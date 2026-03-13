class MilestoneModel {
  final int id;
  final int pointsRequired;
  final double discountPercentage;
  final double? maxDiscount;
  final int? couponValidityDays;
  final String couponCodePrefix;
  final String? descriptionAr;
  final bool isAchieved;
  final String? couponCode;
  final DateTime? couponExpiresAt;
  final int pointsToGo;

  MilestoneModel({
    required this.id,
    required this.pointsRequired,
    required this.discountPercentage,
    this.maxDiscount,
    this.couponValidityDays,
    required this.couponCodePrefix,
    this.descriptionAr,
    required this.isAchieved,
    this.couponCode,
    this.couponExpiresAt,
    required this.pointsToGo,
  });

  factory MilestoneModel.fromJson(Map<String, dynamic> json) {
    return MilestoneModel(
      id: json['milestone_id'] as int,
      pointsRequired: json['points_required'] as int,
      discountPercentage: (json['discount_percentage'] as num).toDouble(),
      maxDiscount: json['max_discount'] != null
          ? (json['max_discount'] as num).toDouble()
          : null,
      couponValidityDays: json['coupon_validity_days'] as int?,
      couponCodePrefix: json['coupon_code_prefix'] as String? ?? '',
      descriptionAr: json['description_ar'] as String?,
      isAchieved: json['is_achieved'] as bool? ?? false,
      couponCode: json['coupon_code'] as String?,
      couponExpiresAt: json['coupon_expires_at'] != null
          ? DateTime.parse(json['coupon_expires_at'] as String)
          : null,
      pointsToGo: json['points_to_go'] as int? ?? 0,
    );
  }

  bool get isExpired => couponExpiresAt != null &&
      couponExpiresAt!.isBefore(DateTime.now());

  bool get canUse => isAchieved && couponCode != null && !isExpired;

  double get progressPercentage {
    if (pointsRequired == 0) return 0;
    return ((pointsRequired - pointsToGo) / pointsRequired).clamp(0.0, 1.0);
  }
}
