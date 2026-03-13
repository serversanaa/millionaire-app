import 'package:millionaire_barber/core/utils/type_parser.dart';

class ServiceCategoryModel {
  final int id;
  final String categoryName;
  final String categoryNameAr;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ServiceCategoryModel({
    required this.id,
    required this.categoryName,
    required this.categoryNameAr,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: parseInt(json['id']),
      categoryName: parseString(json['category_name']),
      categoryNameAr: parseString(json['category_name_ar']),
      description: parseString(json['description'], defaultValue: ''),
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_name': categoryName,
      'category_name_ar': categoryNameAr,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
