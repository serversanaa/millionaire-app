// import 'package:flutter/material.dart';
// import 'order_item_model.dart';
//
// class Order {
//   final String id;
//   final String orderNumber;
//   final int? userId;
//   final String customerName;
//   final String customerPhone;
//   final String? customerEmail;
//   final String deliveryAddress;
//   final String? deliveryCity;
//   final String? deliveryNotes;
//   final double subtotal;
//   final double discountAmount;
//   final double deliveryFee;
//   final double taxAmount;
//   final double totalAmount;
//   final int? couponId;
//   final String? couponCode;
//   final int loyaltyPointsUsed;
//   final int loyaltyPointsEarned;
//   final String status;
//   final String paymentStatus;
//   final String? paymentMethod;
//   final String deliveryMethod;
//   final DateTime? deliveryDate;
//   final String? notes;
//   final String? adminNotes;
//   final String? cancellationReason;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final DateTime? confirmedAt;
//   final DateTime? cancelledAt;
//   final DateTime? deliveredAt;
//   final List<OrderItem>? items;
//
//   Order({
//     required this.id,
//     required this.orderNumber,
//     this.userId,
//     required this.customerName,
//     required this.customerPhone,
//     this.customerEmail,
//     required this.deliveryAddress,
//     this.deliveryCity,
//     this.deliveryNotes,
//     required this.subtotal,
//     required this.discountAmount,
//     required this.deliveryFee,
//     required this.taxAmount,
//     required this.totalAmount,
//     this.couponId,
//     this.couponCode,
//     required this.loyaltyPointsUsed,
//     required this.loyaltyPointsEarned,
//     required this.status,
//     required this.paymentStatus,
//     this.paymentMethod,
//     required this.deliveryMethod,
//     this.deliveryDate,
//     this.notes,
//     this.adminNotes,
//     this.cancellationReason,
//     required this.createdAt,
//     required this.updatedAt,
//     this.confirmedAt,
//     this.cancelledAt,
//     this.deliveredAt,
//     this.items,
//   });
//
//   // ✅ fromJson محسّن مع معالجة أخطاء Type Casting
//   factory Order.fromJson(Map<String, dynamic> json) {
//     List<OrderItem>? orderItems;
//
//     // ✅ معالجة order_items
//     if (json['order_items'] != null) {
//       try {
//         orderItems = (json['order_items'] as List)
//             .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
//             .toList();
//         debugPrint('✅ تم تحويل ${orderItems.length} عنصر من order_items');
//       } catch (e) {
//         debugPrint('⚠️ خطأ في تحويل order_items: $e');
//         orderItems = [];
//       }
//     } else if (json['items'] != null) {
//       try {
//         orderItems = (json['items'] as List)
//             .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
//             .toList();
//         debugPrint('✅ تم تحويل ${orderItems.length} عنصر من items');
//       } catch (e) {
//         debugPrint('⚠️ خطأ في تحويل items: $e');
//         orderItems = [];
//       }
//     }
//
//     return Order(
//       id: json['id']?.toString() ?? '',
//       orderNumber: json['order_number']?.toString() ?? '',
//       userId: json['user_id'] as int?,
//       customerName: json['customer_name']?.toString() ?? '',
//       customerPhone: json['customer_phone']?.toString() ?? '',
//       customerEmail: json['customer_email']?.toString(),
//       deliveryAddress: json['delivery_address']?.toString() ?? '',
//       deliveryCity: json['delivery_city']?.toString(),
//       deliveryNotes: json['delivery_notes']?.toString(),
//       // ✅ إصلاح Type Casting للـ double
//       subtotal: _toDouble(json['subtotal']),
//       discountAmount: _toDouble(json['discount_amount']),
//       deliveryFee: _toDouble(json['delivery_fee']),
//       taxAmount: _toDouble(json['tax_amount']),
//       totalAmount: _toDouble(json['total_amount']),
//       couponId: json['coupon_id'] as int?,
//       couponCode: json['coupon_code']?.toString(),
//       loyaltyPointsUsed: _toInt(json['loyalty_points_used']),
//       loyaltyPointsEarned: _toInt(json['loyalty_points_earned']),
//       status: json['status']?.toString() ?? 'pending',
//       paymentStatus: json['payment_status']?.toString() ?? 'unpaid',
//       paymentMethod: json['payment_method']?.toString(),
//       deliveryMethod: json['delivery_method']?.toString() ?? 'home_delivery',
//       deliveryDate: json['delivery_date'] != null
//           ? DateTime.tryParse(json['delivery_date'].toString())
//           : null,
//       notes: json['notes']?.toString(),
//       adminNotes: json['admin_notes']?.toString(),
//       cancellationReason: json['cancellation_reason']?.toString(),
//       createdAt: json['created_at'] != null
//           ? DateTime.parse(json['created_at'].toString())
//           : DateTime.now(),
//       updatedAt: json['updated_at'] != null
//           ? DateTime.parse(json['updated_at'].toString())
//           : DateTime.now(),
//       confirmedAt: json['confirmed_at'] != null
//           ? DateTime.tryParse(json['confirmed_at'].toString())
//           : null,
//       cancelledAt: json['cancelled_at'] != null
//           ? DateTime.tryParse(json['cancelled_at'].toString())
//           : null,
//       deliveredAt: json['delivered_at'] != null
//           ? DateTime.tryParse(json['delivered_at'].toString())
//           : null,
//       items: orderItems,
//     );
//   }
//
//   // ✅ Helper لتحويل dynamic إلى double بأمان
//   static double _toDouble(dynamic value) {
//     if (value == null) return 0.0;
//     if (value is double) return value;
//     if (value is int) return value.toDouble();
//     if (value is String) return double.tryParse(value) ?? 0.0;
//     return 0.0;
//   }
//
//   // ✅ Helper لتحويل dynamic إلى int بأمان
//   static int _toInt(dynamic value) {
//     if (value == null) return 0;
//     if (value is int) return value;
//     if (value is double) return value.toInt();
//     if (value is String) return int.tryParse(value) ?? 0;
//     return 0;
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'order_number': orderNumber,
//       'user_id': userId,
//       'customer_name': customerName,
//       'customer_phone': customerPhone,
//       'customer_email': customerEmail,
//       'delivery_address': deliveryAddress,
//       'delivery_city': deliveryCity,
//       'delivery_notes': deliveryNotes,
//       'subtotal': subtotal,
//       'discount_amount': discountAmount,
//       'delivery_fee': deliveryFee,
//       'tax_amount': taxAmount,
//       'total_amount': totalAmount,
//       'coupon_id': couponId,
//       'coupon_code': couponCode,
//       'loyalty_points_used': loyaltyPointsUsed,
//       'loyalty_points_earned': loyaltyPointsEarned,
//       'status': status,
//       'payment_status': paymentStatus,
//       'payment_method': paymentMethod,
//       'delivery_method': deliveryMethod,
//       'delivery_date': deliveryDate?.toIso8601String(),
//       'notes': notes,
//       'admin_notes': adminNotes,
//       'cancellation_reason': cancellationReason,
//       'created_at': createdAt.toIso8601String(),
//       'updated_at': updatedAt.toIso8601String(),
//       'confirmed_at': confirmedAt?.toIso8601String(),
//       'cancelled_at': cancelledAt?.toIso8601String(),
//       'delivered_at': deliveredAt?.toIso8601String(),
//       'order_items': items?.map((item) => item.toJson()).toList(),
//     };
//   }
//
//   // ✅ copyWith محدّث
//   Order copyWith({
//     String? id,
//     String? orderNumber,
//     int? userId,
//     String? customerName,
//     String? customerPhone,
//     String? customerEmail,
//     String? deliveryAddress,
//     String? deliveryCity,
//     String? deliveryNotes,
//     double? subtotal,
//     double? discountAmount,
//     double? deliveryFee,
//     double? taxAmount,
//     double? totalAmount,
//     int? couponId,
//     String? couponCode,
//     int? loyaltyPointsUsed,
//     int? loyaltyPointsEarned,
//     String? status,
//     String? paymentStatus,
//     String? paymentMethod,
//     String? deliveryMethod,
//     DateTime? deliveryDate,
//     String? notes,
//     String? adminNotes,
//     String? cancellationReason,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     DateTime? confirmedAt,
//     DateTime? cancelledAt,
//     DateTime? deliveredAt,
//     List<OrderItem>? items,
//   }) {
//     return Order(
//       id: id ?? this.id,
//       orderNumber: orderNumber ?? this.orderNumber,
//       userId: userId ?? this.userId,
//       customerName: customerName ?? this.customerName,
//       customerPhone: customerPhone ?? this.customerPhone,
//       customerEmail: customerEmail ?? this.customerEmail,
//       deliveryAddress: deliveryAddress ?? this.deliveryAddress,
//       deliveryCity: deliveryCity ?? this.deliveryCity,
//       deliveryNotes: deliveryNotes ?? this.deliveryNotes,
//       subtotal: subtotal ?? this.subtotal,
//       discountAmount: discountAmount ?? this.discountAmount,
//       deliveryFee: deliveryFee ?? this.deliveryFee,
//       taxAmount: taxAmount ?? this.taxAmount,
//       totalAmount: totalAmount ?? this.totalAmount,
//       couponId: couponId ?? this.couponId,
//       couponCode: couponCode ?? this.couponCode,
//       loyaltyPointsUsed: loyaltyPointsUsed ?? this.loyaltyPointsUsed,
//       loyaltyPointsEarned: loyaltyPointsEarned ?? this.loyaltyPointsEarned,
//       status: status ?? this.status,
//       paymentStatus: paymentStatus ?? this.paymentStatus,
//       paymentMethod: paymentMethod ?? this.paymentMethod,
//       deliveryMethod: deliveryMethod ?? this.deliveryMethod,
//       deliveryDate: deliveryDate ?? this.deliveryDate,
//       notes: notes ?? this.notes,
//       adminNotes: adminNotes ?? this.adminNotes,
//       cancellationReason: cancellationReason ?? this.cancellationReason,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//       confirmedAt: confirmedAt ?? this.confirmedAt,
//       cancelledAt: cancelledAt ?? this.cancelledAt,
//       deliveredAt: deliveredAt ?? this.deliveredAt,
//       items: items ?? this.items,
//     );
//   }
//
//   // ✅ Getters للنصوص العربية
//   String get statusText {
//     switch (status.toLowerCase()) {
//       case 'pending':
//         return 'قيد الانتظار';
//       case 'confirmed':
//         return 'مؤكد';
//       case 'preparing':
//         return 'قيد التحضير';
//       case 'ready':
//         return 'جاهز';
//       case 'out_for_delivery':
//         return 'في طريق التوصيل';
//       case 'delivered':
//         return 'مكتمل';
//       case 'cancelled':
//         return 'ملغي';
//       case 'returned':
//         return 'مرتجع';
//       default:
//         return status;
//     }
//   }
//
//   Color get statusColor {
//     switch (status.toLowerCase()) {
//       case 'pending':
//         return Colors.orange;
//       case 'confirmed':
//         return Colors.blue;
//       case 'preparing':
//         return Colors.purple;
//       case 'ready':
//         return Colors.teal;
//       case 'out_for_delivery':
//         return Colors.indigo;
//       case 'delivered':
//         return Colors.green;
//       case 'cancelled':
//         return Colors.red;
//       case 'returned':
//         return Colors.grey;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   IconData get statusIcon {
//     switch (status.toLowerCase()) {
//       case 'pending':
//         return Icons.schedule;
//       case 'confirmed':
//         return Icons.check_circle_outline;
//       case 'preparing':
//         return Icons.inventory_2;
//       case 'ready':
//         return Icons.shopping_bag;
//       case 'out_for_delivery':
//         return Icons.local_shipping;
//       case 'delivered':
//         return Icons.done_all;
//       case 'cancelled':
//         return Icons.cancel;
//       case 'returned':
//         return Icons.keyboard_return;
//       default:
//         return Icons.info;
//     }
//   }
//
//   String get paymentStatusText {
//     switch (paymentStatus.toLowerCase()) {
//       case 'unpaid':
//         return 'غير مدفوع ✗';
//       case 'paid':
//         return 'مدفوع ✓';
//       case 'partial':
//         return 'دفع جزئي';
//       case 'refunded':
//         return 'مسترد 💵';
//       default:
//         return paymentStatus;
//     }
//   }
//
//   String get paymentMethodText {
//     switch (paymentMethod?.toLowerCase()) {
//       case 'cash':
//         return 'الدفع عند الاستلام';
//       case 'card':
//         return 'البطاقة الائتمانية';
//       case 'wallet':
//         return 'المحفظة الإلكترونية';
//       case 'points':
//         return 'نقاط الولاء';
//       case 'bank_transfer':
//         return 'تحويل بنكي';
//       default:
//         return paymentMethod ?? 'غير محدد';
//     }
//   }
//
//   String get deliveryMethodText {
//     switch (deliveryMethod.toLowerCase()) {
//       case 'home_delivery':
//         return 'توصيل منزلي 🏠';
//       case 'pickup':
//         return 'استلام من المركز 🏢';
//       case 'in_store':
//         return 'داخل المركز';
//       default:
//         return deliveryMethod;
//     }
//   }
//
//   @override
//   String toString() {
//     return 'Order(id: $id, orderNumber: $orderNumber, status: $status, total: $totalAmount)';
//   }
//
//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is Order && other.id == id;
//   }
//
//   @override
//   int get hashCode => id.hashCode;
// }



import 'package:flutter/material.dart';
import 'order_item_model.dart';

class Order {
  final String id;
  final String orderNumber;
  final int? userId;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String deliveryAddress;
  final String? deliveryCity;
  final String? deliveryNotes;
  final double subtotal;
  final double discountAmount;
  final double deliveryFee;
  final double taxAmount;
  final double totalAmount;
  final int? couponId;
  final String? couponCode;
  final int loyaltyPointsUsed;
  final int loyaltyPointsEarned;
  final String status;
  final String paymentStatus;
  final String? paymentMethod;
  final String deliveryMethod;
  final DateTime? deliveryDate;
  final String? notes;
  final String? adminNotes;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final DateTime? deliveredAt;
  final List<OrderItem>? items;

  // ✅ حقول الدفع الإلكتروني
  final String? receiptUrl;
  final String? walletType;
  final String? walletPhone;
  final String? walletNameAr; // ✅ جديد

  Order({
    required this.id,
    required this.orderNumber,
    this.userId,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    required this.deliveryAddress,
    this.deliveryCity,
    this.deliveryNotes,
    required this.subtotal,
    required this.discountAmount,
    required this.deliveryFee,
    required this.taxAmount,
    required this.totalAmount,
    this.couponId,
    this.couponCode,
    required this.loyaltyPointsUsed,
    required this.loyaltyPointsEarned,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    required this.deliveryMethod,
    this.deliveryDate,
    this.notes,
    this.adminNotes,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
    this.confirmedAt,
    this.cancelledAt,
    this.deliveredAt,
    this.items,
    // ✅ حقول الدفع الإلكتروني
    this.receiptUrl,
    this.walletType,
    this.walletPhone,
    this.walletNameAr, // ✅ جديد

  });

  // ══════════════════════════════════════════════════════
  // fromJson
  // ══════════════════════════════════════════════════════
  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem>? orderItems;

    if (json['order_items'] != null) {
      try {
        orderItems = (json['order_items'] as List)
            .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('⚠️ خطأ في تحويل order_items: $e');
        orderItems = [];
      }
    } else if (json['items'] != null) {
      try {
        orderItems = (json['items'] as List)
            .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('⚠️ خطأ في تحويل items: $e');
        orderItems = [];
      }
    }

    return Order(
      id:                  json['id']?.toString() ?? '',
      orderNumber:         json['order_number']?.toString() ?? '',
      userId:              _toIntNullable(json['user_id']),
      customerName:        json['customer_name']?.toString() ?? '',
      customerPhone:       json['customer_phone']?.toString() ?? '',
      customerEmail:       json['customer_email']?.toString(),
      deliveryAddress:     json['delivery_address']?.toString() ?? '',
      deliveryCity:        json['delivery_city']?.toString(),
      deliveryNotes:       json['delivery_notes']?.toString(),
      subtotal:            _toDouble(json['subtotal']),
      discountAmount:      _toDouble(json['discount_amount']),
      deliveryFee:         _toDouble(json['delivery_fee']),
      taxAmount:           _toDouble(json['tax_amount']),
      totalAmount:         _toDouble(json['total_amount']),
      couponId:            _toIntNullable(json['coupon_id']),
      couponCode:          json['coupon_code']?.toString(),
      loyaltyPointsUsed:   _toInt(json['loyalty_points_used']),
      loyaltyPointsEarned: _toInt(json['loyalty_points_earned']),
      status:              json['status']?.toString() ?? 'pending',
      paymentStatus:       json['payment_status']?.toString() ?? 'unpaid',
      paymentMethod:       json['payment_method']?.toString(),
      deliveryMethod:      json['delivery_method']?.toString() ?? 'home_delivery',
      deliveryDate:        _toDateTime(json['delivery_date']),
      notes:               json['notes']?.toString(),
      adminNotes:          json['admin_notes']?.toString(),
      cancellationReason:  json['cancellation_reason']?.toString(),
      createdAt:           _toDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt:           _toDateTime(json['updated_at']) ?? DateTime.now(),
      confirmedAt:         _toDateTime(json['confirmed_at']),
      cancelledAt:         _toDateTime(json['cancelled_at']),
      deliveredAt:         _toDateTime(json['delivered_at']),
      items:               orderItems,
      // ✅ حقول الدفع الإلكتروني
      receiptUrl:          _parseNonEmpty(json['receipt_url']),
      walletType:          _parseNonEmpty(json['wallet_type']),
      walletPhone:         _parseNonEmpty(json['wallet_phone']),
      walletNameAr:        _parseNonEmpty(json['wallet_name_ar']),

    );
  }

  // ══════════════════════════════════════════════════════
  // Helpers
  // ══════════════════════════════════════════════════════
  static double _toDouble(dynamic v) {
    if (v == null)      return 0.0;
    if (v is double)    return v;
    if (v is int)       return v.toDouble();
    if (v is String)    return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null)   return 0;
    if (v is int)    return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  // ✅ nullable int (لـ userId و couponId)
  static int? _toIntNullable(dynamic v) {
    if (v == null)   return null;
    if (v is int)    return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  // ✅ تحويل DateTime بأمان
  static DateTime? _toDateTime(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  // ✅ تجاهل القيم الفارغة والـ null معاً
  static String? _parseNonEmpty(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  // ══════════════════════════════════════════════════════
  // toJson
  // ══════════════════════════════════════════════════════
  Map<String, dynamic> toJson() {
    return {
      'id':                   id,
      'order_number':         orderNumber,
      'user_id':              userId,
      'customer_name':        customerName,
      'customer_phone':       customerPhone,
      'customer_email':       customerEmail,
      'delivery_address':     deliveryAddress,
      'delivery_city':        deliveryCity,
      'delivery_notes':       deliveryNotes,
      'subtotal':             subtotal,
      'discount_amount':      discountAmount,
      'delivery_fee':         deliveryFee,
      'tax_amount':           taxAmount,
      'total_amount':         totalAmount,
      'coupon_id':            couponId,
      'coupon_code':          couponCode,
      'loyalty_points_used':  loyaltyPointsUsed,
      'loyalty_points_earned': loyaltyPointsEarned,
      'status':               status,
      'payment_status':       paymentStatus,
      'payment_method':       paymentMethod,
      'delivery_method':      deliveryMethod,
      'delivery_date':        deliveryDate?.toIso8601String(),
      'notes':                notes,
      'admin_notes':          adminNotes,
      'cancellation_reason':  cancellationReason,
      'created_at':           createdAt.toIso8601String(),
      'updated_at':           updatedAt.toIso8601String(),
      'confirmed_at':         confirmedAt?.toIso8601String(),
      'cancelled_at':         cancelledAt?.toIso8601String(),
      'delivered_at':         deliveredAt?.toIso8601String(),
      'order_items':          items?.map((i) => i.toJson()).toList(),
      'receipt_url':          receiptUrl,
      'wallet_type':          walletType,
      'wallet_phone':         walletPhone,
      'wallet_name_ar':       walletNameAr,

    };
  }

  // ══════════════════════════════════════════════════════
  // copyWith
  // ══════════════════════════════════════════════════════
  Order copyWith({
    String? id,
    String? orderNumber,
    int? userId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? deliveryAddress,
    String? deliveryCity,
    String? deliveryNotes,
    double? subtotal,
    double? discountAmount,
    double? deliveryFee,
    double? taxAmount,
    double? totalAmount,
    int? couponId,
    String? couponCode,
    int? loyaltyPointsUsed,
    int? loyaltyPointsEarned,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    String? deliveryMethod,
    DateTime? deliveryDate,
    String? notes,
    String? adminNotes,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? confirmedAt,
    DateTime? cancelledAt,
    DateTime? deliveredAt,
    List<OrderItem>? items,
    String? receiptUrl,
    String? walletType,
    String? walletPhone,
    String? walletNameAr,

  }) {
    return Order(
      id:                  id                  ?? this.id,
      orderNumber:         orderNumber         ?? this.orderNumber,
      userId:              userId              ?? this.userId,
      customerName:        customerName        ?? this.customerName,
      customerPhone:       customerPhone       ?? this.customerPhone,
      customerEmail:       customerEmail       ?? this.customerEmail,
      deliveryAddress:     deliveryAddress     ?? this.deliveryAddress,
      deliveryCity:        deliveryCity        ?? this.deliveryCity,
      deliveryNotes:       deliveryNotes       ?? this.deliveryNotes,
      subtotal:            subtotal            ?? this.subtotal,
      discountAmount:      discountAmount      ?? this.discountAmount,
      deliveryFee:         deliveryFee         ?? this.deliveryFee,
      taxAmount:           taxAmount           ?? this.taxAmount,
      totalAmount:         totalAmount         ?? this.totalAmount,
      couponId:            couponId            ?? this.couponId,
      couponCode:          couponCode          ?? this.couponCode,
      loyaltyPointsUsed:   loyaltyPointsUsed   ?? this.loyaltyPointsUsed,
      loyaltyPointsEarned: loyaltyPointsEarned ?? this.loyaltyPointsEarned,
      status:              status              ?? this.status,
      paymentStatus:       paymentStatus       ?? this.paymentStatus,
      paymentMethod:       paymentMethod       ?? this.paymentMethod,
      deliveryMethod:      deliveryMethod      ?? this.deliveryMethod,
      deliveryDate:        deliveryDate        ?? this.deliveryDate,
      notes:               notes               ?? this.notes,
      adminNotes:          adminNotes          ?? this.adminNotes,
      cancellationReason:  cancellationReason  ?? this.cancellationReason,
      createdAt:           createdAt           ?? this.createdAt,
      updatedAt:           updatedAt           ?? this.updatedAt,
      confirmedAt:         confirmedAt         ?? this.confirmedAt,
      cancelledAt:         cancelledAt         ?? this.cancelledAt,
      deliveredAt:         deliveredAt         ?? this.deliveredAt,
      items:               items               ?? this.items,
      // ✅ حقول الدفع الإلكتروني
      receiptUrl:          receiptUrl          ?? this.receiptUrl,
      walletType:          walletType          ?? this.walletType,
      walletPhone:         walletPhone         ?? this.walletPhone,
      walletNameAr:         walletNameAr         ?? this.walletNameAr,

    );
  }

  // ══════════════════════════════════════════════════════
  // Getters
  // ══════════════════════════════════════════════════════
  String get statusText {
    return switch (status.toLowerCase()) {
      'pending'          => 'قيد الانتظار',
      'confirmed'        => 'مؤكد',
      'preparing'        => 'قيد التحضير',
      'ready'            => 'جاهز',
      'out_for_delivery' => 'في طريق التوصيل',
      'delivered'        => 'مكتمل',
      'cancelled'        => 'ملغي',
      'returned'         => 'مرتجع',
      _                  => status,
    };
  }

  Color get statusColor {
    return switch (status.toLowerCase()) {
      'pending'          => Colors.orange,
      'confirmed'        => Colors.blue,
      'preparing'        => Colors.purple,
      'ready'            => Colors.teal,
      'out_for_delivery' => Colors.indigo,
      'delivered'        => Colors.green,
      'cancelled'        => Colors.red,
      'returned'         => Colors.grey,
      _                  => Colors.grey,
    };
  }

  IconData get statusIcon {
    return switch (status.toLowerCase()) {
      'pending'          => Icons.schedule,
      'confirmed'        => Icons.check_circle_outline,
      'preparing'        => Icons.inventory_2,
      'ready'            => Icons.shopping_bag,
      'out_for_delivery' => Icons.local_shipping,
      'delivered'        => Icons.done_all,
      'cancelled'        => Icons.cancel,
      'returned'         => Icons.keyboard_return,
      _                  => Icons.info,
    };
  }

  // ✅ paymentStatus يشمل under_review
  String get paymentStatusText {
    return switch (paymentStatus.toLowerCase()) {
      'unpaid'        => 'غير مدفوع ✗',
      'paid'          => 'مدفوع ✓',
      'partial'       => 'دفع جزئي',
      'refunded'      => 'مسترد 💵',
      'under_review'  => 'قيد المراجعة ⏳',
      _               => paymentStatus,
    };
  }

  String get paymentMethodText {
    return switch (paymentMethod?.toLowerCase()) {
      'cash'          => 'الدفع عند الاستلام 💵',
      'card'          => 'البطاقة الائتمانية 💳',
      'wallet'        => 'محفظة إلكترونية — ${_walletDisplayName()}',
      'points'        => 'نقاط الولاء 🏆',
      'bank_transfer' => 'تحويل بنكي 🏦',
      _               => paymentMethod ?? 'غير محدد',
    };
  }

  // ✅ اسم المحفظة ديناميكي
  String _walletDisplayName() {
    return switch (walletType?.toLowerCase()) {
      'kash'     => 'كاش 💳',
      'floosak'  => 'فلوسك 💰',
      'telecash' => 'تيليكاش 📱',
      null       => 'محفظة إلكترونية',
      _          => walletType!,
    };
  }

  String get deliveryMethodText {
    return switch (deliveryMethod.toLowerCase()) {
      'home_delivery' => 'توصيل منزلي 🏠',
      'pickup'        => 'استلام من المركز 🏢',
      'in_store'      => 'داخل المركز',
      _               => deliveryMethod,
    };
  }

  // ✅ هل الدفع إلكتروني؟
  bool get isElectronicPayment => paymentMethod?.toLowerCase() == 'wallet';

  // ✅ هل يوجد إيصال؟
  bool get hasReceipt => receiptUrl != null && receiptUrl!.isNotEmpty;

  @override
  String toString() =>
      'Order(id: $id, orderNumber: $orderNumber, status: $status, total: $totalAmount)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Order && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
