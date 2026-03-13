class NotificationModel {
  final int? id;
  final int userId;
  final int? appointmentId;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime? scheduledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    this.id,
    required this.userId,
    this.appointmentId,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    this.data,
    this.scheduledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// إنشاء NotificationModel من JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      appointmentId: json['appointment_id'] as int?,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.fromString(json['type'] as String),
      isRead: json['is_read'] as bool? ?? false,
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// تحويل NotificationModel إلى JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      if (appointmentId != null) 'appointment_id': appointmentId,
      'title': title,
      'body': body,
      'type': type.value,
      'is_read': isRead,
      if (data != null) 'data': data,
      if (scheduledAt != null) 'scheduled_at': scheduledAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// إنشاء نسخة جديدة مع تحديث بعض الحقول
  NotificationModel copyWith({
    int? id,
    int? userId,
    int? appointmentId,
    String? title,
    String? body,
    NotificationType? type,
    bool? isRead,
    Map<String, dynamic>? data,
    DateTime? scheduledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      appointmentId: appointmentId ?? this.appointmentId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// للطباعة والتصحيح
  @override
  String toString() {
    return 'NotificationModel(id: $id, userId: $userId, title: $title, type: ${type.value}, isRead: $isRead)';
  }

  /// للمقارنة
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationModel &&
        other.id == id &&
        other.userId == userId &&
        other.appointmentId == appointmentId &&
        other.title == title &&
        other.body == body &&
        other.type == type &&
        other.isRead == isRead;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    userId.hashCode ^
    appointmentId.hashCode ^
    title.hashCode ^
    body.hashCode ^
    type.hashCode ^
    isRead.hashCode;
  }
}

/// أنواع الإشعارات
enum NotificationType {
  bookingConfirmed('booking_confirmed'),
  reminder('reminder'),
  cancelled('cancelled'),
  completed('completed'),
  offer('offer'),
  general('general');

  final String value;
  const NotificationType(this.value);

  /// تحويل String إلى NotificationType
  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
          (type) => type.value == value,
      orElse: () => NotificationType.general,
    );
  }

  /// الحصول على الأيقونة المناسبة
  String get icon {
    switch (this) {
      case NotificationType.bookingConfirmed:
        return '✅';
      case NotificationType.reminder:
        return '⏰';
      case NotificationType.cancelled:
        return '❌';
      case NotificationType.completed:
        return '✔️';
      case NotificationType.offer:
        return '🎁';
      case NotificationType.general:
        return '🔔';
    }
  }

  /// الحصول على الوصف بالعربية
  String get displayName {
    switch (this) {
      case NotificationType.bookingConfirmed:
        return 'تأكيد الحجز';
      case NotificationType.reminder:
        return 'تذكير';
      case NotificationType.cancelled:
        return 'إلغاء';
      case NotificationType.completed:
        return 'مكتمل';
      case NotificationType.offer:
        return 'عرض خاص';
      case NotificationType.general:
        return 'عام';
    }
  }
}
