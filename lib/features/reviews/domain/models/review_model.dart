// lib/features/reviews/domain/models/review_model.dart
class ReviewModel {
  final int? id;
  final int userId;
  final int? appointmentId;
  final int? serviceId;
  final int? employeeId;
  final int rating; // 1-5
  final String? comment;
  final bool isAnonymous;
  final bool isApproved;
  final int helpfulCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // معلومات إضافية للعرض
  final String? userName;
  final String? userImageUrl;
  final String? serviceName;
  final String? employeeName;

  ReviewModel({
    this.id,
    required this.userId,
    this.appointmentId,
    this.serviceId,
    this.employeeId,
    required this.rating,
    this.comment,
    this.isAnonymous = false,
    this.isApproved = true,
    this.helpfulCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userImageUrl,
    this.serviceName,
    this.employeeName,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      appointmentId: json['appointment_id'] as int?,
      serviceId: json['service_id'] as int?,
      employeeId: json['employee_id'] as int?,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      isApproved: json['is_approved'] as bool? ?? true,
      helpfulCount: json['helpful_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userName: json['user_name'] as String?,
      userImageUrl: json['user_image_url'] as String?,
      serviceName: json['service_name'] as String?,
      employeeName: json['employee_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      if (appointmentId != null) 'appointment_id': appointmentId,
      if (serviceId != null) 'service_id': serviceId,
      if (employeeId != null) 'employee_id': employeeId,
      'rating': rating,
      if (comment != null) 'comment': comment,
      'is_anonymous': isAnonymous,
      'is_approved': isApproved,
      'helpful_count': helpfulCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ReviewModel copyWith({
    int? id,
    int? userId,
    int? appointmentId,
    int? serviceId,
    int? employeeId,
    int? rating,
    String? comment,
    bool? isAnonymous,
    bool? isApproved,
    int? helpfulCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? userImageUrl,
    String? serviceName,
    String? employeeName,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      appointmentId: appointmentId ?? this.appointmentId,
      serviceId: serviceId ?? this.serviceId,
      employeeId: employeeId ?? this.employeeId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isApproved: isApproved ?? this.isApproved,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      serviceName: serviceName ?? this.serviceName,
      employeeName: employeeName ?? this.employeeName,
    );
  }
}
