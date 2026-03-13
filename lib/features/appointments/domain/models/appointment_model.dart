// // lib/features/booking/domain/models/appointment_model.dart
// import 'package:millionaire_barber/core/utils/type_parser.dart';
// class AppointmentModel {
//   final int? id;
//   final int userId;
//   final int? employeeId;
//   final DateTime appointmentDate;
//   final String appointmentTime;
//   final int durationMinutes;
//   final double totalPrice;
//   final String status; // pending, confirmed, in_progress, completed, cancelled, no_show
//   final String paymentStatus; // unpaid, paid, partial, refunded
//   final String? paymentMethod; // cash, card, wallet, points
//   final String? notes;
//   final String clientName;
//   final String clientPhone;
//   final int loyaltyPointsEarned;
//   final int loyaltyPointsUsed;
//   final double discountAmount;
//   final int? createdByEmployee;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   final int? couponId;
//
//   // معلومات إضافية للعرض
//   final String? employeeName;
//   final String? employeeImageUrl;
//   final List<AppointmentService>? services;
//
//   AppointmentModel({
//     this.id,
//     required this.userId,
//     this.employeeId,
//     required this.appointmentDate,
//     required this.appointmentTime,
//     required this.durationMinutes,
//     required this.totalPrice,
//     this.status = 'pending',
//     this.paymentStatus = 'unpaid',
//     this.paymentMethod,
//     this.notes,
//     required this.clientName,
//     required this.clientPhone,
//     this.loyaltyPointsEarned = 0,
//     this.loyaltyPointsUsed = 0,
//     this.discountAmount = 0.0,
//     this.createdByEmployee,
//     this.createdAt,
//     this.updatedAt,
//     this.employeeName,
//     this.employeeImageUrl,
//     this.services,
//     this.couponId,
//
//   });
//
//   factory AppointmentModel.fromJson(Map<String, dynamic> json) {
//     return AppointmentModel(
//       id: parseInt(json['id']),
//       userId: parseInt(json['user_id']),
//       employeeId: json['employee_id'] != null ? parseInt(json['employee_id']) : null,
//       appointmentDate: parseDateTime(json['appointment_date']) ?? DateTime.now(),
//       appointmentTime: parseString(json['appointment_time']),
//       durationMinutes: parseInt(json['duration_minutes']) ?? 30,
//       totalPrice: parseDouble(json['total_price']),
//       status: parseString(json['status'], defaultValue: 'pending'),
//       paymentStatus: parseString(json['payment_status'], defaultValue: 'unpaid'),
//       paymentMethod: parseString(json['payment_method'], defaultValue: ''),
//       notes: parseString(json['notes'], defaultValue: ''),
//       clientName: parseString(json['client_name']),
//       clientPhone: parseString(json['client_phone']),
//       loyaltyPointsEarned: parseInt(json['loyalty_points_earned']) ?? 0,
//       loyaltyPointsUsed: parseInt(json['loyalty_points_used']) ?? 0,
//       discountAmount: parseDouble(json['discount_amount'], defaultValue: 0.0),
//       createdByEmployee: json['created_by_employee'] != null ? parseInt(json['created_by_employee']) : null,
//       createdAt: parseDateTime(json['created_at']),
//       updatedAt: parseDateTime(json['updated_at']),
//       employeeName: parseString(json['employee_name'], defaultValue: ''),
//       employeeImageUrl: parseString(json['employee_image_url'], defaultValue: ''),
//       services: json['services'] != null
//           ? (json['services'] as List).map((s) => AppointmentService.fromJson(s as Map<String, dynamic>)).toList()
//           : null,
//       couponId: json['coupon_id'] as int?,
//
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'user_id': userId,
//       'employee_id': employeeId,
//       'appointment_date': '${appointmentDate.year}-${appointmentDate.month.toString().padLeft(2, '0')}-${appointmentDate.day.toString().padLeft(2, '0')}',
//       'appointment_time': appointmentTime,
//       'duration_minutes': durationMinutes,
//       'total_price': totalPrice,
//       'status': status,
//       'payment_status': paymentStatus,
//       'payment_method': paymentMethod,
//       'notes': notes,
//       'client_name': clientName,
//       'client_phone': clientPhone,
//       'loyalty_points_earned': loyaltyPointsEarned,
//       'loyalty_points_used': loyaltyPointsUsed,
//       'discount_amount': discountAmount,
//       'created_by_employee': createdByEmployee,
//       if (couponId != null) 'coupon_id': couponId,
//
//     };
//   }
//
//   bool get isPending => status == 'pending';
//   bool get isConfirmed => status == 'confirmed';
//   bool get isInProgress => status == 'in_progress';
//   bool get isCompleted => status == 'completed';
//   bool get isCancelled => status == 'cancelled';
//   bool get isNoShow => status == 'no_show';
//
//
//
//
//   // للتحقق إذا كان يمكن تقييم الخدمة
//   bool get canBeReviewed => isCompleted;
//
//   // ✅ يمكن إلغاء الحجز حتى لو كان in_progress
//   bool get canBeCancelled => isPending || isConfirmed || isInProgress;
//
//   // للعرض في تبويب "القادمة"
//   bool get isUpcoming => isPending || isConfirmed || isInProgress;
//
//   // للعرض في تبويب "الملغاة"
//   bool get isCancelledOrNoShow => isCancelled || isNoShow;
//   AppointmentModel copyWith({
//     int? id,
//     int? userId,
//     int? employeeId,
//     DateTime? appointmentDate,
//     String? appointmentTime,
//     int? durationMinutes,
//     double? totalPrice,
//     String? status,
//     String? paymentStatus,
//     String? paymentMethod,
//     String? notes,
//     String? clientName,
//     String? clientPhone,
//     int? loyaltyPointsEarned,
//     int? loyaltyPointsUsed,
//     double? discountAmount,
//     int? createdByEmployee,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     String? employeeName,
//     String? employeeImageUrl,
//     List<AppointmentService>? services,
//   }) {
//     return AppointmentModel(
//       id: id ?? this.id,
//       userId: userId ?? this.userId,
//       employeeId: employeeId ?? this.employeeId,
//       appointmentDate: appointmentDate ?? this.appointmentDate,
//       appointmentTime: appointmentTime ?? this.appointmentTime,
//       durationMinutes: durationMinutes ?? this.durationMinutes,
//       totalPrice: totalPrice ?? this.totalPrice,
//       status: status ?? this.status,
//       paymentStatus: paymentStatus ?? this.paymentStatus,
//       paymentMethod: paymentMethod ?? this.paymentMethod,
//       notes: notes ?? this.notes,
//       clientName: clientName ?? this.clientName,
//       clientPhone: clientPhone ?? this.clientPhone,
//       loyaltyPointsEarned: loyaltyPointsEarned ?? this.loyaltyPointsEarned,
//       loyaltyPointsUsed: loyaltyPointsUsed ?? this.loyaltyPointsUsed,
//       discountAmount: discountAmount ?? this.discountAmount,
//       createdByEmployee: createdByEmployee ?? this.createdByEmployee,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//       employeeName: employeeName ?? this.employeeName,
//       employeeImageUrl: employeeImageUrl ?? this.employeeImageUrl,
//       services: services ?? this.services,
//     );
//   }
// }
//
// // نموذج خدمة الموعد
// class AppointmentService {
//   final int? id;
//   final int appointmentId;
//   final int serviceId;
//   final double servicePrice;
//   final int serviceDuration;
//   final int? employeeId;
//   final String status;
//   final DateTime? startTime;
//   final DateTime? endTime;
//   final String? notes;
//
//   // معلومات إضافية
//   final String? serviceName;
//   final String? serviceNameAr;
//
//   AppointmentService({
//     this.id,
//     required this.appointmentId,
//     required this.serviceId,
//     required this.servicePrice,
//     required this.serviceDuration,
//     this.employeeId,
//     this.status = 'pending',
//     this.startTime,
//     this.endTime,
//     this.notes,
//     this.serviceName,
//     this.serviceNameAr,
//   });
//
//   factory AppointmentService.fromJson(Map<String, dynamic> json) {
//     return AppointmentService(
//       id: parseInt(json['id']),
//       appointmentId: parseInt(json['appointment_id']),
//       serviceId: parseInt(json['service_id']),
//       servicePrice: parseDouble(json['service_price']),
//       serviceDuration: parseInt(json['service_duration']) ?? 0,
//       employeeId: json['employee_id'] != null ? parseInt(json['employee_id']) : null,
//       status: parseString(json['status'], defaultValue: 'pending'),
//       startTime: parseDateTime(json['start_time']),
//       endTime: parseDateTime(json['end_time']),
//       notes: parseString(json['notes'], defaultValue: ''),
//       serviceName: parseString(json['service_name'], defaultValue: ''),
//       serviceNameAr: parseString(json['service_name_ar'], defaultValue: ''),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'appointment_id': appointmentId,
//       'service_id': serviceId,
//       'service_price': servicePrice,
//       'service_duration': serviceDuration,
//       'employee_id': employeeId,
//       'status': status,
//       'start_time': startTime?.toIso8601String(),
//       'end_time': endTime?.toIso8601String(),
//       'notes': notes,
//     };
//   }
//
//   // ✅ إضافة دالة getDisplayName
//   String getDisplayName() {
//     return serviceNameAr ?? serviceName ?? 'خدمة';
//   }
// }


// lib/features/booking/domain/models/appointment_model.dart
// ✅ استبدل الملف كاملاً بهذا

import 'package:millionaire_barber/core/utils/type_parser.dart';
import 'appointment_person_model.dart';
import 'electronic_wallet_model.dart';

class AppointmentModel {
  final int? id;
  final int userId;
  final int? employeeId;
  final DateTime appointmentDate;
  final String appointmentTime;
  final int durationMinutes;
  final double totalPrice;
  final String status;
  final String paymentStatus;
  final String? paymentMethod;
  final String? notes;
  final String clientName;
  final String clientPhone;
  final int loyaltyPointsEarned;
  final int loyaltyPointsUsed;
  final double discountAmount;
  final int? createdByEmployee;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? couponId;

  // ✅ حقول جديدة
  final String? paymentReceiptUrl;
  final int? electronicWalletId;
  final int personsCount;

  // معلومات إضافية للعرض
  final String? employeeName;
  final String? employeeImageUrl;
  final List<AppointmentService>? services;

  // ✅ جديد: قائمة الأشخاص
  final List<AppointmentPersonModel>? persons;

  // ✅ جديد: بيانات المحفظة الإلكترونية
  final ElectronicWalletModel? electronicWallet;

  AppointmentModel({
    this.id,
    required this.userId,
    this.employeeId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.durationMinutes,
    required this.totalPrice,
    this.status = 'pending',
    this.paymentStatus = 'unpaid',
    this.paymentMethod,
    this.notes,
    required this.clientName,
    required this.clientPhone,
    this.loyaltyPointsEarned = 0,
    this.loyaltyPointsUsed = 0,
    this.discountAmount = 0.0,
    this.createdByEmployee,
    this.createdAt,
    this.updatedAt,
    this.couponId,
    // ✅ جديد
    this.paymentReceiptUrl,
    this.electronicWalletId,
    this.personsCount = 1,
    // عرض
    this.employeeName,
    this.employeeImageUrl,
    this.services,
    this.persons,
    this.electronicWallet,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id:                  parseInt(json['id']),
      userId:              parseInt(json['user_id']),
      employeeId:          json['employee_id'] != null ? parseInt(json['employee_id']) : null,
      appointmentDate:     parseDateTime(json['appointment_date']) ?? DateTime.now(),
      appointmentTime:     parseString(json['appointment_time']),
      durationMinutes:     parseInt(json['duration_minutes']) ?? 30,
      totalPrice:          parseDouble(json['total_price']),
      status:              parseString(json['status'], defaultValue: 'pending'),
      paymentStatus:       parseString(json['payment_status'], defaultValue: 'unpaid'),
      paymentMethod:       parseString(json['payment_method'], defaultValue: ''),
      notes:               parseString(json['notes'], defaultValue: ''),
      clientName:          parseString(json['client_name']),
      clientPhone:         parseString(json['client_phone']),
      loyaltyPointsEarned: parseInt(json['loyalty_points_earned']) ?? 0,
      loyaltyPointsUsed:   parseInt(json['loyalty_points_used']) ?? 0,
      discountAmount:      parseDouble(json['discount_amount'], defaultValue: 0.0),
      createdByEmployee:   json['created_by_employee'] != null ? parseInt(json['created_by_employee']) : null,
      createdAt:           parseDateTime(json['created_at']),
      updatedAt:           parseDateTime(json['updated_at']),
      couponId:            json['coupon_id'] as int?,
      // ✅ جديد
      paymentReceiptUrl:   json['payment_receipt_url'] as String?,
      electronicWalletId:  json['electronic_wallet_id'] != null
          ? parseInt(json['electronic_wallet_id'])
          : null,
      personsCount:        parseInt(json['persons_count']) ?? 1,
      // عرض
      employeeName:        parseString(json['employee_name'], defaultValue: ''),
      employeeImageUrl:    parseString(json['employee_image_url'], defaultValue: ''),
      services: json['appointment_services'] != null
          ? (json['appointment_services'] as List)
          .map((s) => AppointmentService.fromJson(s as Map<String, dynamic>))
          .toList()
          : null,
      persons: json['appointment_persons'] != null
          ? (json['appointment_persons'] as List)
          .map((p) => AppointmentPersonModel.fromJson(p as Map<String, dynamic>))
          .toList()
          : null,
      electronicWallet: json['electronic_wallets'] != null
          ? ElectronicWalletModel.fromJson(json['electronic_wallets'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id':               userId,
      'employee_id':           employeeId,
      'appointment_date':      '${appointmentDate.year}-${appointmentDate.month.toString().padLeft(2, '0')}-${appointmentDate.day.toString().padLeft(2, '0')}',
      'appointment_time':      appointmentTime,
      'duration_minutes':      durationMinutes,
      'total_price':           totalPrice,
      'status':                status,
      'payment_status':        paymentStatus,
      'payment_method':        paymentMethod,
      'notes':                 notes,
      'client_name':           clientName,
      'client_phone':          clientPhone,
      'loyalty_points_earned': loyaltyPointsEarned,
      'loyalty_points_used':   loyaltyPointsUsed,
      'discount_amount':       discountAmount,
      'created_by_employee':   createdByEmployee,
      'persons_count':         personsCount,
      // ✅ جديد
      if (paymentReceiptUrl != null)  'payment_receipt_url':  paymentReceiptUrl,
      if (electronicWalletId != null) 'electronic_wallet_id': electronicWalletId,
      if (couponId != null)           'coupon_id':            couponId,
    };
  }

  // ══ Status helpers ══
  bool get isPending     => status == 'pending';
  bool get isConfirmed   => status == 'confirmed';
  bool get isInProgress  => status == 'in_progress';
  bool get isCompleted   => status == 'completed';
  bool get isCancelled   => status == 'cancelled';
  bool get isNoShow      => status == 'no_show';

  bool get canBeReviewed      => isCompleted;
  bool get canBeCancelled     => isPending || isConfirmed || isInProgress;
  bool get isUpcoming         => isPending || isConfirmed || isInProgress;
  bool get isCancelledOrNoShow => isCancelled || isNoShow;

  // ✅ جديد: هل الدفع إلكتروني؟
  bool get isElectronicPayment => paymentMethod == 'electronic';

  // ✅ جديد: هل تم رفع الإيصال؟
  bool get hasReceipt => paymentReceiptUrl != null && paymentReceiptUrl!.isNotEmpty;

  AppointmentModel copyWith({
    int? id,
    int? userId,
    int? employeeId,
    DateTime? appointmentDate,
    String? appointmentTime,
    int? durationMinutes,
    double? totalPrice,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    String? notes,
    String? clientName,
    String? clientPhone,
    int? loyaltyPointsEarned,
    int? loyaltyPointsUsed,
    double? discountAmount,
    int? createdByEmployee,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? employeeName,
    String? employeeImageUrl,
    List<AppointmentService>? services,
    // ✅ جديد
    String? paymentReceiptUrl,
    int? electronicWalletId,
    int? personsCount,
    List<AppointmentPersonModel>? persons,
    ElectronicWalletModel? electronicWallet,
  }) {
    return AppointmentModel(
      id:                  id ?? this.id,
      userId:              userId ?? this.userId,
      employeeId:          employeeId ?? this.employeeId,
      appointmentDate:     appointmentDate ?? this.appointmentDate,
      appointmentTime:     appointmentTime ?? this.appointmentTime,
      durationMinutes:     durationMinutes ?? this.durationMinutes,
      totalPrice:          totalPrice ?? this.totalPrice,
      status:              status ?? this.status,
      paymentStatus:       paymentStatus ?? this.paymentStatus,
      paymentMethod:       paymentMethod ?? this.paymentMethod,
      notes:               notes ?? this.notes,
      clientName:          clientName ?? this.clientName,
      clientPhone:         clientPhone ?? this.clientPhone,
      loyaltyPointsEarned: loyaltyPointsEarned ?? this.loyaltyPointsEarned,
      loyaltyPointsUsed:   loyaltyPointsUsed ?? this.loyaltyPointsUsed,
      discountAmount:      discountAmount ?? this.discountAmount,
      createdByEmployee:   createdByEmployee ?? this.createdByEmployee,
      createdAt:           createdAt ?? this.createdAt,
      updatedAt:           updatedAt ?? this.updatedAt,
      couponId:            couponId,
      employeeName:        employeeName ?? this.employeeName,
      employeeImageUrl:    employeeImageUrl ?? this.employeeImageUrl,
      services:            services ?? this.services,
      // ✅ جديد
      paymentReceiptUrl:   paymentReceiptUrl ?? this.paymentReceiptUrl,
      electronicWalletId:  electronicWalletId ?? this.electronicWalletId,
      personsCount:        personsCount ?? this.personsCount,
      persons:             persons ?? this.persons,
      electronicWallet:    electronicWallet ?? this.electronicWallet,
    );
  }
}

// ══════════════════════════════════════════════════════════
// ✅ AppointmentService - مُحدَّث بإضافة personId و personName
// ══════════════════════════════════════════════════════════

class AppointmentService {
  final int? id;
  final int appointmentId;
  final int serviceId;
  final double servicePrice;
  final int serviceDuration;
  final int? employeeId;
  final String status;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? notes;
  final String? serviceName;
  final String? serviceNameAr;

  // ✅ جديد
  final int? personId;
  final String? personName;

  AppointmentService({
    this.id,
    required this.appointmentId,
    required this.serviceId,
    required this.servicePrice,
    required this.serviceDuration,
    this.employeeId,
    this.status = 'pending',
    this.startTime,
    this.endTime,
    this.notes,
    this.serviceName,
    this.serviceNameAr,
    // ✅ جديد
    this.personId,
    this.personName,
  });

  factory AppointmentService.fromJson(Map<String, dynamic> json) {
    return AppointmentService(
      id:              parseInt(json['id']),
      appointmentId:   parseInt(json['appointment_id']),
      serviceId:       parseInt(json['service_id']),
      servicePrice:    parseDouble(json['service_price']),
      serviceDuration: parseInt(json['service_duration']) ?? 0,
      employeeId:      json['employee_id'] != null ? parseInt(json['employee_id']) : null,
      status:          parseString(json['status'], defaultValue: 'pending'),
      startTime:       parseDateTime(json['start_time']),
      endTime:         parseDateTime(json['end_time']),
      notes:           parseString(json['notes'], defaultValue: ''),
      serviceName:     parseString(json['service_name'], defaultValue: ''),
      serviceNameAr:   parseString(json['service_name_ar'], defaultValue: ''),
      // ✅ جديد
      personId:        json['person_id'] != null ? parseInt(json['person_id']) : null,
      personName:      parseString(json['person_name'], defaultValue: ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointment_id':   appointmentId,
      'service_id':       serviceId,
      'service_price':    servicePrice,
      'service_duration': serviceDuration,
      'employee_id':      employeeId,
      'status':           status,
      'start_time':       startTime?.toIso8601String(),
      'end_time':         endTime?.toIso8601String(),
      'notes':            notes,
      // ✅ جديد
      if (personId != null)   'person_id':   personId,
      if (personName != null) 'person_name': personName,
    };
  }

  String getDisplayName() => serviceNameAr ?? serviceName ?? 'خدمة';
}
