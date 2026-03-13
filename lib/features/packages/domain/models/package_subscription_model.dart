// lib/features/packages/domain/models/package_subscription_model.dart

import 'package:flutter/material.dart';
import 'package:millionaire_barber/features/packages/domain/models/package_model.dart';

/// ═══════════════════════════════════════════════════════════════
/// 📦 Package Subscription Model
/// نموذج اشتراك الباقة
/// ═══════════════════════════════════════════════════════════════

class PackageSubscriptionModel {
  final int id;
  final String userId;
  final int packageId;

  // ⏰ التواريخ
  final DateTime startDate;
  final DateTime endDate;
  final String status; // active, expired, cancelled

  // 💰 التسعير
  final double price;
  final double? originalPrice;
  final int? discountPercentage;

  // 💳 الدفع
  final String? paymentMethod;
  final String paymentStatus; // pending, paid, failed, refunded
  final DateTime? paymentDate;
  final String? transactionId;

  // 🎫 الجلسات
  final int remainingSessions;
  final int totalSessions;
  final int usedSessions;

  // 📝 البيانات الإضافية
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  // 🔗 العلاقات (optional)
  final PackageModel? package;

  PackageSubscriptionModel({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.price,
    this.originalPrice,
    this.discountPercentage,
    this.paymentMethod,
    required this.paymentStatus,
    this.paymentDate,
    this.transactionId,
    required this.remainingSessions,
    required this.totalSessions,
    required this.usedSessions,
    required this.createdAt,
    required this.updatedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.package,
  });

  // ═════════════════════════════════════════════════════════════════
  // 🔍 Computed Properties
  // ═════════════════════════════════════════════════════════════════

  /// هل الاشتراك نشط وصالح؟
  bool get isActive =>
      status == 'active' &&
          endDate.isAfter(DateTime.now()) &&
          remainingSessions > 0;

  /// هل انتهت صلاحية الاشتراك؟
  bool get isExpired =>
      endDate.isBefore(DateTime.now()) ||
          status == 'expired';

  /// هل تم إلغاء الاشتراك؟
  bool get isCancelled => status == 'cancelled';

  /// هل توجد جلسات متبقية؟
  bool get hasRemainingSessions => remainingSessions > 0;

  /// نسبة الاستخدام (0-100)
  double get usagePercentage {
    if (totalSessions == 0) return 0;
    return (usedSessions / totalSessions) * 100;
  }

  /// عدد الأيام المتبقية
  int get daysRemaining {
    if (isExpired) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  /// عدد الساعات المتبقية
  int get hoursRemaining {
    if (isExpired) return 0;
    return endDate.difference(DateTime.now()).inHours;
  }

  /// هل توشك الباقة على الانتهاء؟ (أقل من 3 أيام)
  bool get isExpiringSoon => isActive && daysRemaining <= 3;

  /// هل الجلسات قليلة؟ (2 أو أقل)
  bool get isSessionsLow => isActive && remainingSessions <= 2;

  /// هل تم الدفع بنجاح؟
  bool get isPaid => paymentStatus == 'paid';

  /// هل يوجد خصم؟
  bool get hasDiscount =>
      originalPrice != null &&
          originalPrice! > price &&
          discountPercentage != null;

  /// قيمة الخصم بالريال
  double get discountAmount {
    if (!hasDiscount) return 0;
    return originalPrice! - price;
  }

  /// النص الوصفي للحالة
  String get statusText {
    switch (status) {
      case 'active':
        return 'نشط';
      case 'expired':
        return 'منتهي';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  /// النص الوصفي لحالة الدفع
  String get paymentStatusText {
    switch (paymentStatus) {
      case 'paid':
        return 'مدفوع';
      case 'pending':
        return 'معلق';
      case 'failed':
        return 'فشل';
      case 'refunded':
        return 'مسترد';
      default:
        return paymentStatus;
    }
  }

  /// لون الحالة
  Color get statusColor {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'expired':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// أيقونة الحالة
  IconData get statusIcon {
    switch (status) {
      case 'active':
        return Icons.check_circle;
      case 'expired':
        return Icons.access_time;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  // ═════════════════════════════════════════════════════════════════
  // 🔄 JSON Serialization
  // ═════════════════════════════════════════════════════════════════

  factory PackageSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return PackageSubscriptionModel(
      id: json['id'] as int,
      // ✅ دعم int و String معاً
      userId: (json['user_id'] is int)
          ? (json['user_id'] as int).toString()
          : json['user_id'] as String,
      packageId: json['package_id'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: json['status'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: json['original_price'] != null
          ? (json['original_price'] as num).toDouble()
          : null,
      discountPercentage: json['discount_percentage'] as int?,
      paymentMethod: json['payment_method'] as String?,
      paymentStatus: json['payment_status'] as String,
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'] as String)
          : null,
      transactionId: json['transaction_id'] as String?,
      remainingSessions: json['remaining_sessions'] as int,
      totalSessions: json['total_sessions'] as int,
      usedSessions: json['used_sessions'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      cancellationReason: json['cancellation_reason'] as String?,
      package: json['packages'] != null
          ? PackageModel.fromJson(json['packages'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'package_id': packageId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
      'price': price,
      'original_price': originalPrice,
      'discount_percentage': discountPercentage,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'payment_date': paymentDate?.toIso8601String(),
      'transaction_id': transactionId,
      'remaining_sessions': remainingSessions,
      'total_sessions': totalSessions,
      'used_sessions': usedSessions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancellation_reason': cancellationReason,
    };
  }

  // ═════════════════════════════════════════════════════════════════
  // 🔄 CopyWith Method
  // ═════════════════════════════════════════════════════════════════

  PackageSubscriptionModel copyWith({
    int? id,
    String? userId,
    int? packageId,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    double? price,
    double? originalPrice,
    int? discountPercentage,
    String? paymentMethod,
    String? paymentStatus,
    DateTime? paymentDate,
    String? transactionId,
    int? remainingSessions,
    int? totalSessions,
    int? usedSessions,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    PackageModel? package,
  }) {
    return PackageSubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      packageId: packageId ?? this.packageId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentDate: paymentDate ?? this.paymentDate,
      transactionId: transactionId ?? this.transactionId,
      remainingSessions: remainingSessions ?? this.remainingSessions,
      totalSessions: totalSessions ?? this.totalSessions,
      usedSessions: usedSessions ?? this.usedSessions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      package: package ?? this.package,
    );
  }

  @override
  String toString() {
    return 'PackageSubscriptionModel(id: $id, status: $status, remainingSessions: $remainingSessions/$totalSessions)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PackageSubscriptionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
