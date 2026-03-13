/// ═══════════════════════════════════════════════════════════════
/// 📋 Package Service Model
/// نموذج خدمة الباقة (مثل: حلاقة، مساج، استشوار)
/// ═══════════════════════════════════════════════════════════════

class PackageServiceModel {
  final int id;
  final int packageId;
  final String nameAr;
  final String? nameEn;
  final int? iconNumber;          // رقم الأيقونة (1, 2, 3...)
  final String? iconName;         // اسم الأيقونة (cut, beard, massage...)
  final int displayOrder;
  final DateTime createdAt;

  PackageServiceModel({
    required this.id,
    required this.packageId,
    required this.nameAr,
    this.nameEn,
    this.iconNumber,
    this.iconName,
    this.displayOrder = 0,
    required this.createdAt,
  });

  /// ═══════════════════════════════════════════════════════════════
  /// Factory: From JSON
  /// ═══════════════════════════════════════════════════════════════
  factory PackageServiceModel.fromJson(Map<String, dynamic> json) {
    return PackageServiceModel(
      id: json['id'] as int,
      packageId: json['package_id'] as int? ?? 0,
      nameAr: json['service_name_ar'] as String,
      nameEn: json['service_name_en'] as String?,
      iconNumber: json['icon_number'] as int?,
      iconName: json['icon_name'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// To JSON
  /// ═══════════════════════════════════════════════════════════════
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'package_id': packageId,
      'service_name_ar': nameAr,
      'service_name_en': nameEn,
      'icon_number': iconNumber,
      'icon_name': iconName,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// ═══════════════════════════════════════════════════════════════
  /// Copy With
  /// ═══════════════════════════════════════════════════════════════
  PackageServiceModel copyWith({
    int? id,
    int? packageId,
    String? nameAr,
    String? nameEn,
    int? iconNumber,
    String? iconName,
    int? displayOrder,
    DateTime? createdAt,
  }) {
    return PackageServiceModel(
      id: id ?? this.id,
      packageId: packageId ?? this.packageId,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      iconNumber: iconNumber ?? this.iconNumber,
      iconName: iconName ?? this.iconName,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'PackageServiceModel(id: $id, nameAr: $nameAr, iconNumber: $iconNumber)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PackageServiceModel &&
        other.id == id &&
        other.packageId == packageId &&
        other.nameAr == nameAr;
  }

  @override
  int get hashCode {
    return id.hashCode ^ packageId.hashCode ^ nameAr.hashCode;
  }
}
