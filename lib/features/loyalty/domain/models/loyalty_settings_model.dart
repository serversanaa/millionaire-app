// class LoyaltySettingsModel {
//   final int id;
//   final double pointsPerCurrency;
//   final double currencyPerPoint;
//   final double minPurchaseForPoints;
//   final double bonusMultiplier;
//   final bool isActive;
//   final String? descriptionAr;
//
//   LoyaltySettingsModel({
//     required this.id,
//     required this.pointsPerCurrency,
//     required this.currencyPerPoint,
//     required this.minPurchaseForPoints,
//     required this.bonusMultiplier,
//     required this.isActive,
//     this.descriptionAr,
//   });
//
//   factory LoyaltySettingsModel.fromJson(Map<String, dynamic> json) {
//     return LoyaltySettingsModel(
//       id: json['id'] as int,
//       pointsPerCurrency: (json['points_per_currency'] as num).toDouble(),
//       currencyPerPoint: (json['currency_per_point'] as num).toDouble(),
//       minPurchaseForPoints: (json['min_purchase_for_points'] as num?)?.toDouble() ?? 0.0,
//       bonusMultiplier: (json['bonus_multiplier'] as num?)?.toDouble() ?? 1.0,
//       isActive: json['is_active'] as bool? ?? true,
//       descriptionAr: json['description_ar'] as String?,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'points_per_currency': pointsPerCurrency,
//       'currency_per_point': currencyPerPoint,
//       'min_purchase_for_points': minPurchaseForPoints,
//       'bonus_multiplier': bonusMultiplier,
//       'is_active': isActive,
//       'description_ar': descriptionAr,
//     };
//   }
//
//   /// ✅ حساب النقاط من المبلغ
//   int calculatePointsFromAmount(double amount) {
//     if (amount < minPurchaseForPoints) return 0;
//     return ((amount / currencyPerPoint) * pointsPerCurrency * bonusMultiplier).floor();
//   }
//
//   /// ✅ حساب المبلغ من النقاط
//   double calculateAmountFromPoints(int points) {
//     return (points * currencyPerPoint) / pointsPerCurrency;
//   }
// }



class LoyaltySettingsModel {
  final int id;
  final double pointsPerCurrency;
  final double currencyPerPoint;
  final double minPurchaseForPoints;
  final double bonusMultiplier;
  final bool isActive;
  final String? description;
  final String? descriptionAr;
  final int? updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LoyaltySettingsModel({
    required this.id,
    required this.pointsPerCurrency,
    required this.currencyPerPoint,
    required this.minPurchaseForPoints,
    required this.bonusMultiplier,
    required this.isActive,
    this.description,
    this.descriptionAr,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory LoyaltySettingsModel.fromJson(Map<String, dynamic> json) {
    return LoyaltySettingsModel(
      id: json['id'] as int,
      pointsPerCurrency: (json['points_per_currency'] as num).toDouble(),
      currencyPerPoint: (json['currency_per_point'] as num).toDouble(),
      minPurchaseForPoints: (json['min_purchase_for_points'] as num?)?.toDouble() ?? 0.0,
      bonusMultiplier: (json['bonus_multiplier'] as num?)?.toDouble() ?? 1.0,
      isActive: json['is_active'] as bool? ?? true,
      description: json['description'] as String?,
      descriptionAr: json['description_ar'] as String?,
      updatedBy: json['updated_by'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'points_per_currency': pointsPerCurrency,
      'currency_per_point': currencyPerPoint,
      'min_purchase_for_points': minPurchaseForPoints,
      'bonus_multiplier': bonusMultiplier,
      'is_active': isActive,
      'description': description,
      'description_ar': descriptionAr,
      'updated_by': updatedBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// ✅ حساب النقاط من المبلغ
  int calculatePointsFromAmount(double amount) {
    if (amount < minPurchaseForPoints) return 0;
    if (currencyPerPoint == 0) return 0;

    final points = (amount / currencyPerPoint) * pointsPerCurrency * bonusMultiplier;
    return points.floor();
  }

  /// ✅ حساب المبلغ من النقاط
  double calculateAmountFromPoints(int points) {
    if (pointsPerCurrency == 0) return 0.0;
    return (points * currencyPerPoint) / pointsPerCurrency;
  }

  /// ✅ النقاط المطلوبة للوصول لمبلغ معين
  int getPointsNeededForAmount(double targetAmount) {
    if (currencyPerPoint == 0 || pointsPerCurrency == 0) return 0;
    final pointsNeeded = (targetAmount / currencyPerPoint) * pointsPerCurrency;
    return pointsNeeded.ceil();
  }

  /// ✅ المبلغ المطلوب للحصول على نقاط معينة
  double getAmountNeededForPoints(int targetPoints) {
    if (pointsPerCurrency == 0) return 0.0;
    return (targetPoints * currencyPerPoint) / pointsPerCurrency;
  }

  /// ✅ هل المبلغ يفي بالحد الأدنى؟
  bool isAmountEligible(double amount) {
    return amount >= minPurchaseForPoints;
  }

  /// ✅ معلومات الإعدادات كنص
  String getSettingsInfo() {
    final pointsText = pointsPerCurrency == 1 ? 'نقطة' : 'نقاط';
    final currencyText = currencyPerPoint == 1 ? 'ريال' : 'ريالات';

    String info = '$pointsPerCurrency $pointsText لكل $currencyPerPoint $currencyText';

    if (bonusMultiplier > 1.0) {
      info += ' (مضاعف: ${bonusMultiplier}x)';
    }

    if (minPurchaseForPoints > 0) {
      info += ' - حد أدنى: $minPurchaseForPoints ريال';
    }

    return info;
  }

  /// ✅ نسخ الموديل مع تعديلات
  LoyaltySettingsModel copyWith({
    int? id,
    double? pointsPerCurrency,
    double? currencyPerPoint,
    double? minPurchaseForPoints,
    double? bonusMultiplier,
    bool? isActive,
    String? description,
    String? descriptionAr,
    int? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LoyaltySettingsModel(
      id: id ?? this.id,
      pointsPerCurrency: pointsPerCurrency ?? this.pointsPerCurrency,
      currencyPerPoint: currencyPerPoint ?? this.currencyPerPoint,
      minPurchaseForPoints: minPurchaseForPoints ?? this.minPurchaseForPoints,
      bonusMultiplier: bonusMultiplier ?? this.bonusMultiplier,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'LoyaltySettings(id: $id, ${getSettingsInfo()}, active: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoyaltySettingsModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
