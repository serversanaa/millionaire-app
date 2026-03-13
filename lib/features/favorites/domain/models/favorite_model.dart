// lib/features/favorites/domain/models/favorite_model.dart

import '../../../services/domain/models/service_model.dart';

class FavoriteModel {
  final int? id;
  final int userId;
  final int serviceId;
  final DateTime createdAt;

  // معلومات الخدمة (للعرض)
  final ServiceModel? service;

  FavoriteModel({
    this.id,
    required this.userId,
    required this.serviceId,
    required this.createdAt,
    this.service,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      serviceId: json['service_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      service: json['services'] != null
          ? ServiceModel.fromJson(json['services'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'service_id': serviceId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  FavoriteModel copyWith({
    int? id,
    int? userId,
    int? serviceId,
    DateTime? createdAt,
    ServiceModel? service,
  }) {
    return FavoriteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceId: serviceId ?? this.serviceId,
      createdAt: createdAt ?? this.createdAt,
      service: service ?? this.service,
    );
  }
}
