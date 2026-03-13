// lib/features/booking/domain/models/appointment_person_model.dart

import 'package:millionaire_barber/core/utils/type_parser.dart';
import 'appointment_model.dart';

class AppointmentPersonModel {
  final int? id;
  final int appointmentId;
  final String personName;
  final int personOrder;
  final String? notes;
  final DateTime? createdAt;

  // الخدمات المرتبطة بهذا الشخص (للعرض فقط)
  final List<AppointmentService>? services;

  AppointmentPersonModel({
    this.id,
    required this.appointmentId,
    required this.personName,
    required this.personOrder,
    this.notes,
    this.createdAt,
    this.services,
  });

  factory AppointmentPersonModel.fromJson(Map<String, dynamic> json) {
    return AppointmentPersonModel(
      id:            parseInt(json['id']),
      appointmentId: parseInt(json['appointment_id']),
      personName:    parseString(json['person_name']),
      personOrder:   parseInt(json['person_order']) ?? 0,
      notes:         parseString(json['notes'], defaultValue: ''),
      createdAt:     parseDateTime(json['created_at']),
      services: json['appointment_services'] != null
          ? (json['appointment_services'] as List)
          .map((s) => AppointmentService.fromJson(s as Map<String, dynamic>))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson(int appointmentId) => {
    'appointment_id': appointmentId,
    'person_name':    personName,
    'person_order':   personOrder,
    'notes':          notes,
  };

  double get totalPrice =>
      services?.fold(0.0, (sum, s) => sum! + s.servicePrice) ?? 0.0;
}
