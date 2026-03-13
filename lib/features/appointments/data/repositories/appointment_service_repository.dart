// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../domain/models/appointment_service_model.dart';
//
// class AppointmentServiceRepository {
//   final SupabaseClient client;
//
//   AppointmentServiceRepository(this.client);
//
//   Future<AppointmentServiceModel?> getById(int id) async {
//     final data = await client
//         .from('appointment_services')
//         .select()
//         .eq('id', id)
//         .maybeSingle();
//
//     if (data == null) return null;
//
//     if (data is Map<String, dynamic>)
//       return AppointmentServiceModel.fromJson(data);
//     if (data is Map)
//       return AppointmentServiceModel.fromJson(Map<String, dynamic>.from(data));
//
//     throw Exception('تنسيق بيانات خدمة الموعد غير صحيح');
//   }
//
//   Future<List<AppointmentServiceModel>> getByAppointmentId(
//       int appointmentId) async {
//     final data = await client
//         .from('appointment_services')
//         .select()
//         .eq('appointment_id', appointmentId);
//     if (data == null) return [];
//
//     return (data as List).map((e) {
//       if (e is Map<String, dynamic>) return AppointmentServiceModel.fromJson(e);
//       if (e is Map)
//         return AppointmentServiceModel.fromJson(Map<String, dynamic>.from(e));
//       throw Exception('تنسيق إحدى خدمات الموعد غير صحيح');
//     }).toList();
//   }
//
//   Future<AppointmentServiceModel> create(
//       AppointmentServiceModel service) async {
//     final data = await client
//         .from('appointment_services')
//         .insert(service.toJson())
//         .select()
//         .maybeSingle();
//
//     if (data == null) throw Exception('فشل إنشاء خدمة الموعد');
//
//     if (data is Map<String, dynamic>)
//       return AppointmentServiceModel.fromJson(data);
//     if (data is Map)
//       return AppointmentServiceModel.fromJson(Map<String, dynamic>.from(data));
//
//     throw Exception('تنسيق بيانات خدمة الموعد المنشأة غير صحيح');
//   }
//
//   Future<AppointmentServiceModel?> update(
//       int id, Map<String, dynamic> updates) async {
//     final data = await client
//         .from('appointment_services')
//         .update(updates)
//         .eq('id', id)
//         .select()
//         .maybeSingle();
//
//     if (data == null) return null;
//
//     if (data is Map<String, dynamic>)
//       return AppointmentServiceModel.fromJson(data);
//     if (data is Map)
//       return AppointmentServiceModel.fromJson(Map<String, dynamic>.from(data));
//
//     throw Exception('تنسيق بيانات خدمة الموعد المحدّثة غير صحيح');
//   }
//
//   Future<void> delete(int id) async {
//     final res = await client.from('appointment_services').delete().eq('id', id);
//
//     if (res.error != null)
//       throw Exception('خطأ في حذف خدمة الموعد: ${res.error!.message}');
//   }
//
//   Stream<List<Map<String, dynamic>>> streamByAppointmentId(int appointmentId) {
//     return client
//         .from('appointment_services:appointment_id=eq.$appointmentId')
//         .stream(primaryKey: ['id']);
//   }
// }


// lib/features/booking/data/repositories/appointment_service_repository.dart
// ✅ إصلاح res.error + إضافة دوال جديدة

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/appointment_service_model.dart';

class AppointmentServiceRepository {
  final SupabaseClient client;

  AppointmentServiceRepository(this.client);

  Future<AppointmentServiceModel?> getById(int id) async {
    final data = await client
        .from('appointment_services')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;
    return AppointmentServiceModel.fromJson(
        Map<String, dynamic>.from(data as Map));
  }

  Future<List<AppointmentServiceModel>> getByAppointmentId(
      int appointmentId) async {
    final data = await client
        .from('appointment_services')
        .select()
        .eq('appointment_id', appointmentId);

    return (data as List)
        .map((e) => AppointmentServiceModel.fromJson(
        Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  // ✅ جديد: جلب خدمات شخص معين
  Future<List<AppointmentServiceModel>> getByPersonId(int personId) async {
    final data = await client
        .from('appointment_services')
        .select()
        .eq('person_id', personId);

    return (data as List)
        .map((e) => AppointmentServiceModel.fromJson(
        Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<AppointmentServiceModel> create(
      AppointmentServiceModel service) async {
    final data = await client
        .from('appointment_services')
        .insert(service.toJson())
        .select()
        .single();

    return AppointmentServiceModel.fromJson(
        Map<String, dynamic>.from(data as Map));
  }

  Future<AppointmentServiceModel?> update(
      int id, Map<String, dynamic> updates) async {
    final data = await client
        .from('appointment_services')
        .update(updates)
        .eq('id', id)
        .select()
        .maybeSingle();

    if (data == null) return null;
    return AppointmentServiceModel.fromJson(
        Map<String, dynamic>.from(data as Map));
  }

  Future<void> delete(int id) async {
    await client.from('appointment_services').delete().eq('id', id);
  }

  Stream<List<Map<String, dynamic>>> streamByAppointmentId(
      int appointmentId) {
    return client
        .from('appointment_services')
        .stream(primaryKey: ['id'])
        .eq('appointment_id', appointmentId);
  }
}
