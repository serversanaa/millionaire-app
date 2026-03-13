// // lib/features/products/data/models/product_model.dart
//
// class Product {
//   final String id;
//   final String name;
//   final String? nameEn;
//   final String? description;
//   final String? descriptionEn;
//   final String? categoryId;
//   final String? categoryName;
//   final String? categoryNameEn;
//   final String? categoryColor;
//   final String? categoryIcon;
//   final double price;
//   final double? discountPercentage;
//   final double finalPrice;
//   final String? imageUrl;
//   final String? thumbnailUrl;
//   final List<String>? galleryImages;
//   final bool isAvailable;
//   final bool isFeatured;
//   final int displayOrder;
//   final String? slug;
//   final List<String>? tags;
//   final int viewsCount;
//   final int salesCount;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//
//   Product({
//     required this.id,
//     required this.name,
//     this.nameEn,
//     this.description,
//     this.descriptionEn,
//     this.categoryId,
//     this.categoryName,
//     this.categoryNameEn,
//     this.categoryColor,
//     this.categoryIcon,
//     required this.price,
//     this.discountPercentage,
//     required this.finalPrice,
//     this.imageUrl,
//     this.thumbnailUrl,
//     this.galleryImages,
//     required this.isAvailable,
//     required this.isFeatured,
//     required this.displayOrder,
//     this.slug,
//     this.tags,
//     required this.viewsCount,
//     required this.salesCount,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       id: json['id'] as String,
//       name: json['name'] as String,
//       nameEn: json['name_en'] as String?,
//       description: json['description'] as String?,
//       descriptionEn: json['description_en'] as String?,
//       categoryId: json['category_id'] as String?,
//       categoryName: json['category_name'] as String?,
//       categoryNameEn: json['category_name_en'] as String?,
//       categoryColor: json['category_color'] as String?,
//       categoryIcon: json['category_icon'] as String?,
//       price: (json['price'] as num).toDouble(),
//       discountPercentage: json['discount_percentage'] != null
//           ? (json['discount_percentage'] as num).toDouble()
//           : null,
//       finalPrice: (json['final_price'] as num).toDouble(),
//       imageUrl: json['image_url'] as String?,
//       thumbnailUrl: json['thumbnail_url'] as String?,
//
//       // ✅ إصلاح السطر 78 - galleryImages
//       galleryImages: json['gallery_images'] != null
//           ? (json['gallery_images'] as List<dynamic>)
//           .map((e) => e as String)
//           .toList()
//           : null,
//
//       isAvailable: json['is_available'] as bool? ?? true,
//       isFeatured: json['is_featured'] as bool? ?? false,
//       displayOrder: json['display_order'] as int? ?? 0,
//       slug: json['slug'] as String?,
//
//       // ✅ إصلاح السطر 84 - tags
//       tags: json['tags'] != null
//           ? (json['tags'] as List<dynamic>)
//           .map((e) => e as String)
//           .toList()
//           : null,
//
//       viewsCount: json['views_count'] as int? ?? 0,
//       salesCount: json['sales_count'] as int? ?? 0,
//       createdAt: DateTime.parse(json['created_at'] as String),
//       updatedAt: DateTime.parse(json['updated_at'] as String),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'name_en': nameEn,
//       'description': description,
//       'description_en': descriptionEn,
//       'category_id': categoryId,
//       'price': price,
//       'discount_percentage': discountPercentage,
//       'final_price': finalPrice,
//       'image_url': imageUrl,
//       'thumbnail_url': thumbnailUrl,
//       'gallery_images': galleryImages,
//       'is_available': isAvailable,
//       'is_featured': isFeatured,
//       'display_order': displayOrder,
//       'slug': slug,
//       'tags': tags,
//       'views_count': viewsCount,
//       'sales_count': salesCount,
//       'created_at': createdAt.toIso8601String(),
//       'updated_at': updatedAt.toIso8601String(),
//     };
//   }
//
//   Product copyWith({
//     String? id,
//     String? name,
//     String? nameEn,
//     String? description,
//     String? descriptionEn,
//     String? categoryId,
//     double? price,
//     double? discountPercentage,
//     double? finalPrice,
//     String? imageUrl,
//     bool? isAvailable,
//     bool? isFeatured,
//   }) {
//     return Product(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       nameEn: nameEn ?? this.nameEn,
//       description: description ?? this.description,
//       descriptionEn: descriptionEn ?? this.descriptionEn,
//       categoryId: categoryId ?? this.categoryId,
//       categoryName: categoryName,
//       categoryNameEn: categoryNameEn,
//       categoryColor: categoryColor,
//       categoryIcon: categoryIcon,
//       price: price ?? this.price,
//       discountPercentage: discountPercentage ?? this.discountPercentage,
//       finalPrice: finalPrice ?? this.finalPrice,
//       imageUrl: imageUrl ?? this.imageUrl,
//       thumbnailUrl: thumbnailUrl,
//       galleryImages: galleryImages,
//       isAvailable: isAvailable ?? this.isAvailable,
//       isFeatured: isFeatured ?? this.isFeatured,
//       displayOrder: displayOrder,
//       slug: slug,
//       tags: tags,
//       viewsCount: viewsCount,
//       salesCount: salesCount,
//       createdAt: createdAt,
//       updatedAt: updatedAt,
//     );
//   }
//
//   // ✨ دوال مساعدة إضافية
//
//   /// حساب نسبة الخصم إذا كانت موجودة
//   String? get discountText {
//     if (discountPercentage != null && discountPercentage! > 0) {
//       return '-${discountPercentage!.toStringAsFixed(0)}%';
//     }
//     return null;
//   }
//
//   /// هل المنتج له خصم؟
//   bool get hasDiscount => discountPercentage != null && discountPercentage! > 0;
//
//   /// السعر المشطوب (السعر الأصلي قبل الخصم)
//   double get originalPrice => hasDiscount ? price : finalPrice;
//
//   /// رابط الصورة المصغرة أو الأساسية
//   String? get displayImage => thumbnailUrl ?? imageUrl;
//
//   /// الاسم المناسب حسب اللغة (يمكن تعديله لاحقاً بناءً على Locale)
//   String get displayName => name; // يمكن استبداله بـ nameEn حسب اللغة
// }


// lib/features/products/data/models/product_model.dart

class Product {
  final String id;
  final String name;
  final String? nameEn;
  final String? description;
  final String? descriptionEn;
  final String? categoryId;
  final String? categoryName;
  final String? categoryNameEn;
  final String? categoryColor;
  final String? categoryIcon;
  final double price;
  final double? discountPercentage;
  final double finalPrice;
  final String? imageUrl;
  final String? thumbnailUrl;
  final List<String>? galleryImages;
  final bool isAvailable;
  final bool isFeatured;
  final int displayOrder;
  final String? slug;
  final List<String>? tags;
  final int viewsCount;
  final int salesCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    this.nameEn,
    this.description,
    this.descriptionEn,
    this.categoryId,
    this.categoryName,
    this.categoryNameEn,
    this.categoryColor,
    this.categoryIcon,
    required this.price,
    this.discountPercentage,
    required this.finalPrice,
    this.imageUrl,
    this.thumbnailUrl,
    this.galleryImages,
    required this.isAvailable,
    required this.isFeatured,
    required this.displayOrder,
    this.slug,
    this.tags,
    required this.viewsCount,
    required this.salesCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // ✅ حساب السعر النهائي
    final double productPrice = (json['price'] as num).toDouble();
    final double? discount = json['discount_percentage'] != null
        ? (json['discount_percentage'] as num).toDouble()
        : null;

    // ✅ إذا كان final_price موجود استخدمه، وإلا احسبه
    final double calculatedFinalPrice = json['final_price'] != null
        ? (json['final_price'] as num).toDouble()
        : (discount != null && discount > 0)
        ? productPrice * (1 - discount / 100)
        : productPrice;

    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      description: json['description'] as String?,
      descriptionEn: json['description_en'] as String?,
      categoryId: json['category_id'] as String?,

      // ✅ استخراج بيانات الفئة من nested object
      categoryName: json['categories'] != null
          ? (json['categories']['name'] as String?)
          : json['category_name'] as String?,
      categoryNameEn: json['categories'] != null
          ? (json['categories']['name_en'] as String?)
          : json['category_name_en'] as String?,
      categoryIcon: json['categories'] != null
          ? (json['categories']['icon'] as String?)
          : json['category_icon'] as String?,
      categoryColor: json['category_color'] as String?,

      price: productPrice,
      discountPercentage: discount,
      finalPrice: calculatedFinalPrice,  // ✅ المشكلة مُحلولة

      imageUrl: json['image_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,

      galleryImages: json['gallery_images'] != null
          ? (json['gallery_images'] as List<dynamic>)
          .map((e) => e.toString())
          .toList()
          : null,

      isAvailable: json['is_available'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      slug: json['slug'] as String?,

      tags: json['tags'] != null
          ? (json['tags'] as List<dynamic>)
          .map((e) => e.toString())
          .toList()
          : null,

      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
      salesCount: (json['sales_count'] as num?)?.toInt() ?? 0,

      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'description': description,
      'description_en': descriptionEn,
      'category_id': categoryId,
      'price': price,
      'discount_percentage': discountPercentage,
      'final_price': finalPrice,
      'image_url': imageUrl,
      'thumbnail_url': thumbnailUrl,
      'gallery_images': galleryImages,
      'is_available': isAvailable,
      'is_featured': isFeatured,
      'display_order': displayOrder,
      'slug': slug,
      'tags': tags,
      'views_count': viewsCount,
      'sales_count': salesCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? description,
    String? descriptionEn,
    String? categoryId,
    double? price,
    double? discountPercentage,
    double? finalPrice,
    String? imageUrl,
    bool? isAvailable,
    bool? isFeatured,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      description: description ?? this.description,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName,
      categoryNameEn: categoryNameEn,
      categoryColor: categoryColor,
      categoryIcon: categoryIcon,
      price: price ?? this.price,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      finalPrice: finalPrice ?? this.finalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl,
      galleryImages: galleryImages,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      displayOrder: displayOrder,
      slug: slug,
      tags: tags,
      viewsCount: viewsCount,
      salesCount: salesCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // ✨ دوال مساعدة إضافية

  /// حساب نسبة الخصم إذا كانت موجودة
  String? get discountText {
    if (discountPercentage != null && discountPercentage! > 0) {
      return '-${discountPercentage!.toStringAsFixed(0)}%';
    }
    return null;
  }

  /// هل المنتج له خصم؟
  bool get hasDiscount => discountPercentage != null && discountPercentage! > 0;

  /// السعر المشطوب (السعر الأصلي قبل الخصم)
  double get originalPrice => hasDiscount ? price : finalPrice;

  /// رابط الصورة المصغرة أو الأساسية
  String? get displayImage => thumbnailUrl ?? imageUrl;

  /// الاسم المناسب حسب اللغة
  String get displayName => name;
}
