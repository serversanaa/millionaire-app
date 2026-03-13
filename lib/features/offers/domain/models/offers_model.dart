import 'package:millionaire_barber/core/utils/type_parser.dart';

class OfferModel {
  final int id;
  final String title;
  final String titleAr;
  final String? description;
  final String? descriptionAr;
  final String? discountType;
  final double discountValue;
  final double minPurchaseAmount;
  final double? maxDiscountAmount;
  final DateTime startDate;
  final DateTime endDate;
  final int? usageLimit;
  final int usageLimitPerUser;
  final int currentUsage;
  final List<int>? applicableServices;
  final List<String> applicableUserTypes;
  final String? promoCode;
  final String? imageUrl;
  final bool isActive;
  final DateTime? createdAt;

  OfferModel({
    required this.id,
    required this.title,
    required this.titleAr,
    this.description,
    this.descriptionAr,
    this.discountType,
    required this.discountValue,
    this.minPurchaseAmount = 0.0,
    this.maxDiscountAmount,
    required this.startDate,
    required this.endDate,
    this.usageLimit,
    this.usageLimitPerUser = 1,
    this.currentUsage = 0,
    this.applicableServices,
    this.applicableUserTypes = const ['all'],
    this.promoCode,
    this.imageUrl,
    this.isActive = true,
    this.createdAt,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: parseInt(json['id']),
      title: parseString(json['title']),
      titleAr: parseString(json['title_ar']),
      description: parseString(json['description'], defaultValue: ''),
      descriptionAr: parseString(json['description_ar'], defaultValue: ''),
      discountType: parseString(json['discount_type'], defaultValue: ''),
      discountValue: parseDouble(json['discount_value']),
      minPurchaseAmount: parseDouble(json['min_purchase_amount'], defaultValue: 0.0),
      maxDiscountAmount: json['max_discount_amount'] != null ? parseDouble(json['max_discount_amount']) : null,
      startDate: parseDateTime(json['start_date']) ?? DateTime.now(),
      endDate: parseDateTime(json['end_date']) ?? DateTime.now(),
      usageLimit: json['usage_limit'] != null ? parseInt(json['usage_limit']) : null,
      usageLimitPerUser: json['usage_limit_per_user'] != null ? parseInt(json['usage_limit_per_user']) : 1,
      currentUsage: json['current_usage'] != null ? parseInt(json['current_usage']) : 0,
      applicableServices: parseList<int>(json['applicable_services']),
      applicableUserTypes: parseList<String>(json['applicable_user_types']) ?? ['all'],
      promoCode: parseString(json['promo_code'], defaultValue: ''),
      imageUrl: parseString(json['image_url'], defaultValue: ''),
      isActive: parseBool(json['is_active'], defaultValue: true),
      createdAt: parseDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_ar': titleAr,
      'description': description,
      'description_ar': descriptionAr,
      'discount_type': discountType,
      'discount_value': discountValue,
      'min_purchase_amount': minPurchaseAmount,
      'max_discount_amount': maxDiscountAmount,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'usage_limit': usageLimit,
      'usage_limit_per_user': usageLimitPerUser,
      'current_usage': currentUsage,
      'applicable_services': applicableServices,
      'applicable_user_types': applicableUserTypes,
      'promo_code': promoCode,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
