// lib/features/products/data/models/product_category_model.dart

class ProductCategory {
  final String id;
  final String name;
  final String? nameEn;
  final String? description;
  final String icon;
  final String color;
  final int displayOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? totalProducts;
  final int? availableProducts;
  final int? featuredProducts;

  ProductCategory({
    required this.id,
    required this.name,
    this.nameEn,
    this.description,
    required this.icon,
    required this.color,
    required this.displayOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.totalProducts,
    this.availableProducts,
    this.featuredProducts,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      description: json['description'] as String?,
      icon: json['icon'] as String? ?? 'category',
      color: json['color'] as String? ?? '#D4AF37',
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      totalProducts: json['total_products'] as int?,
      availableProducts: json['available_products'] as int?,
      featuredProducts: json['featured_products'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'description': description,
      'icon': icon,
      'color': color,
      'display_order': displayOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
