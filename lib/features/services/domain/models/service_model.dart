import 'package:millionaire_barber/core/utils/type_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceModel {
  final int id;
  final String serviceName;
  final String serviceNameAr;
  final String? description;
  final String? descriptionAr;
  final int categoryId;
  final double price;
  final int durationMinutes;
  final int loyaltyPoints;
  final String? imageUrl;
  final List<String>? beforeAfterImages;
  final bool isActive;
  final bool requiresBooking;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ServiceModel({
    required this.id,
    required this.serviceName,
    required this.serviceNameAr,
    this.description,
    this.descriptionAr,
    required this.categoryId,
    required this.price,
    required this.durationMinutes,
    required this.loyaltyPoints,
    this.imageUrl,
    this.beforeAfterImages,
    required this.isActive,
    required this.requiresBooking,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: parseInt(json['id']),
      serviceName: parseString(json['service_name']),
      serviceNameAr: parseString(json['service_name_ar']),
      description: parseString(json['description'], defaultValue: ''),
      descriptionAr: parseString(json['description_ar'], defaultValue: ''),
      categoryId: parseInt(json['category_id']),
      price: parseDouble(json['price']),
      durationMinutes: parseInt(json['duration_minutes']),
      loyaltyPoints: parseInt(json['loyalty_points'], defaultValue: 1),
      imageUrl: parseString(json['image_url'], defaultValue: ''),
      beforeAfterImages: parseList<String>(json['before_after_images']),
      isActive: parseBool(json['is_active'], defaultValue: true),
      requiresBooking: parseBool(json['requires_booking'], defaultValue: true),
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_name': serviceName,
      'service_name_ar': serviceNameAr,
      'description': description,
      'description_ar': descriptionAr,
      'category_id': categoryId,
      'price': price,
      'duration_minutes': durationMinutes,
      'loyalty_points': loyaltyPoints,
      'image_url': imageUrl,
      'before_after_images': beforeAfterImages,
      'is_active': isActive,
      'requires_booking': requiresBooking,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  // ✅ دالة للحصول على رابط الصورة الكامل من Supabase Storage
  String? getImageUrl() {
    if (imageUrl == null || imageUrl!.isEmpty) return null;

    // إذا كان الرابط كامل بالفعل، أرجعه
    if (imageUrl!.startsWith('http')) return imageUrl;

    try {
      // الحصول على الرابط العام من Storage
      final url = Supabase.instance.client.storage
          .from('services_images')
          .getPublicUrl(imageUrl!);
      return url;
    } catch (e) {
      return null;
    }
  }

  // ✅ دالة للحصول على صورة placeholder إذا لم توجد صورة
  String getImageUrlOrDefault() {
    return getImageUrl() ?? 'assets/images/logo.png';
  }

}
