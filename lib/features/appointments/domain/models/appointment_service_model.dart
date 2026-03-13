import 'package:millionaire_barber/core/utils/type_parser.dart';

class AppointmentServiceModel {
  final int id;
  final int appointmentId;
  final int serviceId;
  final int? employeeId;
  final int quantity;
  final double price;
  final double discountAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppointmentServiceModel({
    required this.id,
    required this.appointmentId,
    required this.serviceId,
    this.employeeId,
    required this.quantity,
    required this.price,
    required this.discountAmount,
    this.createdAt,
    this.updatedAt,
  });

  factory AppointmentServiceModel.fromJson(Map<String, dynamic> json) {
    return AppointmentServiceModel(
      id: parseInt(json['id']),
      appointmentId: parseInt(json['appointment_id']),
      serviceId: parseInt(json['service_id']),
      employeeId: json['employee_id'] != null ? parseInt(json['employee_id']) : null,
      quantity: parseInt(json['quantity']),
      price: parseDouble(json['price']),
      discountAmount: parseDouble(json['discount_amount']),
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointment_id': appointmentId,
      'service_id': serviceId,
      'employee_id': employeeId,
      'quantity': quantity,
      'price': price,
      'discount_amount': discountAmount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
