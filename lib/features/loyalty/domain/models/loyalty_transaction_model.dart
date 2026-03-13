// import 'package:millionaire_barber/core/utils/type_parser.dart';
//
// class LoyaltyTransactionModel {
//   final int id;
//   final int userId;
//   final int? appointmentId;
//   final String transactionType;
//   final int pointsAmount;
//   final String? description;
//   final DateTime? expiryDate;
//   final DateTime? createdAt;
//
//   LoyaltyTransactionModel({
//     required this.id,
//     required this.userId,
//     this.appointmentId,
//     required this.transactionType,
//     required this.pointsAmount,
//     this.description,
//     this.expiryDate,
//     this.createdAt,
//   });
//
//   factory LoyaltyTransactionModel.fromJson(Map<String, dynamic> json) {
//     return LoyaltyTransactionModel(
//       id: parseInt(json['id']),
//       userId: parseInt(json['user_id']),
//       appointmentId: json['appointment_id'] != null ? parseInt(json['appointment_id']) : null,
//       transactionType: parseString(json['transaction_type']),
//       pointsAmount: parseInt(json['points_amount']),
//       description: parseString(json['description'], defaultValue: ''),
//       expiryDate: parseDateTime(json['expiry_date']),
//       createdAt: parseDateTime(json['created_at']),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'user_id': userId,
//       'appointment_id': appointmentId,
//       'transaction_type': transactionType,
//       'points_amount': pointsAmount,
//       'description': description,
//       'expiry_date': expiryDate?.toIso8601String(),
//       'created_at': createdAt?.toIso8601String(),
//     };
//   }
// }




import 'package:millionaire_barber/core/utils/type_parser.dart';

class LoyaltyTransactionModel {
  final int id;
  final int userId;
  final int? appointmentId;
  final String? referenceType;
  final int? referenceId;
  final String transactionType;
  final int pointsAmount;
  final String status;
  final String? description;
  final DateTime? expiryDate;
  final DateTime? createdAt;

  LoyaltyTransactionModel({
    required this.id,
    required this.userId,
    this.appointmentId,
    this.referenceType,
    this.referenceId,
    required this.transactionType,
    required this.pointsAmount,
    required this.status,
    this.description,
    this.expiryDate,
    this.createdAt,
  });

  factory LoyaltyTransactionModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransactionModel(
      id: parseInt(json['id']),
      userId: parseInt(json['user_id']),
      appointmentId: json['appointment_id'] != null ? parseInt(json['appointment_id']) : null,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] != null ? parseInt(json['reference_id']) : null,
      transactionType: parseString(json['transaction_type']),
      pointsAmount: parseInt(json['points_amount']),
      status: parseString(json['status'], defaultValue: 'pending'),
      description: json['description'] as String?,
      expiryDate: json['expiry_date'] != null ? parseDateTime(json['expiry_date']) : null,
      createdAt: json['created_at'] != null ? parseDateTime(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'appointment_id': appointmentId,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'transaction_type': transactionType,
      'points_amount': pointsAmount,
      'status': status,
      'description': description,
      'expiry_date': expiryDate?.toIso8601String().split('T')[0],
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // ════════════════════════════════════════════════════════════════════════════
  // STATUS GETTERS
  // ════════════════════════════════════════════════════════════════════════════

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isCancelled => status == 'cancelled';

  // ════════════════════════════════════════════════════════════════════════════
  // TRANSACTION TYPE GETTERS
  // ════════════════════════════════════════════════════════════════════════════

  bool get isEarned => transactionType == 'earned';
  bool get isRedeemed => transactionType == 'redeemed';
  bool get isExpired => transactionType == 'expired';
  bool get isBonus => transactionType == 'bonus';

  // ════════════════════════════════════════════════════════════════════════════
  // HELPER GETTERS
  // ════════════════════════════════════════════════════════════════════════════

  /// ✅ هل النقاط موجبة (مكتسبة)؟
  bool get isPositive => transactionType == 'earned' || transactionType == 'bonus';

  /// ✅ هل النقاط سالبة (مستهلكة)؟
  bool get isNegative => transactionType == 'redeemed' || transactionType == 'expired';

  /// ✅ قيمة النقاط الفعلية (موجبة أو سالبة)
  int get effectivePoints {
    if (status != 'completed') return 0;
    return isPositive ? pointsAmount : -pointsAmount;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // COPY WITH
  // ════════════════════════════════════════════════════════════════════════════

  LoyaltyTransactionModel copyWith({
    int? id,
    int? userId,
    int? appointmentId,
    String? referenceType,
    int? referenceId,
    String? transactionType,
    int? pointsAmount,
    String? status,
    String? description,
    DateTime? expiryDate,
    DateTime? createdAt,
  }) {
    return LoyaltyTransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      appointmentId: appointmentId ?? this.appointmentId,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      transactionType: transactionType ?? this.transactionType,
      pointsAmount: pointsAmount ?? this.pointsAmount,
      status: status ?? this.status,
      description: description ?? this.description,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // STANDARD METHODS
  // ════════════════════════════════════════════════════════════════════════════

  @override
  String toString() {
    return 'LoyaltyTransaction(id: $id, user: $userId, type: $transactionType, points: $pointsAmount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoyaltyTransactionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
