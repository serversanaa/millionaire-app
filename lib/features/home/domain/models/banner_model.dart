// lib/features/home/data/models/banner_model.dart

class BannerModel {
  final int       id;
  final String?   titleAr;
  final String    imageUrl;
  final String?   linkType;
  final String?   linkValue;
  final bool      isActive;
  final int       displayOrder;
  final DateTime? startsAt;
  final DateTime? endsAt;

  const BannerModel({
    required this.id,
    this.titleAr,
    required this.imageUrl,
    this.linkType,
    this.linkValue,
    required this.isActive,
    required this.displayOrder,
    this.startsAt,
    this.endsAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
    id:           json['id']            as int,
    titleAr:      json['title_ar']      as String?,
    imageUrl:     json['image_url']     as String,
    linkType:     json['link_type']     as String?,
    linkValue:    json['link_value']    as String?,
    isActive:     json['is_active']     as bool? ?? true,
    displayOrder: json['display_order'] as int?  ?? 0,
    startsAt: json['starts_at'] != null
        ? DateTime.tryParse(json['starts_at'].toString()) : null,
    endsAt: json['ends_at'] != null
        ? DateTime.tryParse(json['ends_at'].toString())   : null,
  );

  bool get isCurrentlyActive {
    if (!isActive) return false;
    final now = DateTime.now();
    if (startsAt != null && now.isBefore(startsAt!)) return false;
    if (endsAt   != null && now.isAfter(endsAt!))    return false;
    return true;
  }
}
