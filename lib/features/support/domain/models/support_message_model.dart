// lib/features/support/domain/models/support_message_model.dart

class SupportMessageModel {
  final int? id;
  final int userId;
  final String subject;
  final String message;
  final String status;
  final String? adminReply;
  final DateTime? repliedAt;
  final DateTime? createdAt;

  SupportMessageModel({
    this.id,
    required this.userId,
    required this.subject,
    required this.message,
    this.status = 'pending',
    this.adminReply,
    this.repliedAt,
    this.createdAt,
  });

  factory SupportMessageModel.fromJson(Map<String, dynamic> json) {
    return SupportMessageModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      subject: json['subject'] as String,
      message: json['message'] as String,
      status: json['status'] as String? ?? 'pending',
      adminReply: json['admin_reply'] as String?,
      repliedAt: json['replied_at'] != null
          ? DateTime.parse(json['replied_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'subject': subject,
      'message': message,
      'status': status,
      if (adminReply != null) 'admin_reply': adminReply,
    };
  }

  bool get isPending => status == 'pending';
  bool get isReplied => status == 'replied';
  bool get isClosed => status == 'closed';
}
