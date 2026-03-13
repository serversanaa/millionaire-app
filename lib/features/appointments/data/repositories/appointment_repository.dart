// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../domain/models/appointment_model.dart';
// import '../../domain/models/employee_model.dart';
//
// class AppointmentRepository {
//   final SupabaseClient client;
//
//   AppointmentRepository(this.client);
//
//   /// إنشاء موعد جديد مع خدماته
//   Future<AppointmentModel> createAppointment(
//     AppointmentModel appointment,
//     List<int> serviceIds,
//   ) async {
//     try {
//       // 1. إنشاء الموعد
//       final appointmentResponse = await client
//           .from('appointments')
//           .insert(appointment.toJson())
//           .select()
//           .single();
//
//       final appointmentId = appointmentResponse['id'] as int;
//
//       // 2. جلب تفاصيل الخدمات من جدول services
//       // ✅ التعديل: استخدام الأسماء الصحيحة
//       final servicesData = await client
//           .from('services')
//           .select('id, service_name, service_name_ar, price, duration_minutes')
//           .inFilter('id', serviceIds);
//
//
//       // 3. إضافة الخدمات للموعد مع التفاصيل الكاملة
//       final appointmentServices = (servicesData as List).map((service) {
//         final serviceMap = service as Map<String, dynamic>;
//         return {
//           'appointment_id': appointmentId,
//           'service_id': serviceMap['id'],
//           'service_price': serviceMap['price'],
//           'service_duration': serviceMap['duration_minutes'],
//           'employee_id': appointment.employeeId,
//           'status': 'pending',
//         };
//       }).toList();
//
//       await client.from('appointment_services').insert(appointmentServices);
//
//       // 4. جلب الموعد مع كل التفاصيل
//       return await getAppointmentById(appointmentId) ??
//           AppointmentModel.fromJson(appointmentResponse);
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   /// ✅ إتمام الحجز وتفعيل النقاط
//   Future<void> completeAppointment(int appointmentId) async {
//     try {
//       // 1. تحديث حالة الحجز
//       await client.from('appointments').update({
//         'status': 'completed',
//         'payment_status': 'paid',
//       }).eq('id', appointmentId);
//
//       // 2. تفعيل النقاط
//       await client
//           .from('loyalty_transactions')
//           .update({'status': 'completed'})
//           .eq('reference_type', 'appointment')
//           .eq('reference_id', appointmentId)
//           .eq('status', 'pending');
//
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   /// ✅ إلغاء الحجز وإلغاء النقاط المعلقة
//   Future<void> cancelAppointment(int appointmentId) async {
//     try {
//       // 1. تحديث حالة الحجز
//       await client
//           .from('appointments')
//           .update({'status': 'cancelled'}).eq('id', appointmentId);
//
//       // 2. إلغاء النقاط المعلقة
//       await client
//           .from('loyalty_transactions')
//           .update({'status': 'cancelled'})
//           .eq('reference_type', 'appointment')
//           .eq('reference_id', appointmentId)
//           .eq('status', 'pending');
//
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   /// جلب مواعيد المستخدم
//   Future<List<AppointmentModel>> getUserAppointments(int userId,
//       {String? status}) async {
//     try {
//       var query = client.from('appointments').select('''
//             *,
//             employees!appointments_employee_id_fkey(full_name, profile_image_url)
//           ''').eq('user_id', userId);
//
//       if (status != null) {
//         query = query.eq('status', status);
//       }
//
//       final response = await query
//           .order('appointment_date', ascending: false)
//           .order('appointment_time', ascending: false);
//
//       final appointments = <AppointmentModel>[];
//
//       for (var json in response as List) {
//         final jsonMap = json as Map<String, dynamic>;
//
//         // معالجة بيانات الموظف
//         if (jsonMap['employees'] != null) {
//           jsonMap['employee_name'] = jsonMap['employees']['full_name'];
//           jsonMap['employee_image_url'] =
//               jsonMap['employees']['profile_image_url'];
//         }
//
//         // جلب خدمات كل موعد
//         final appointmentId = jsonMap['id'] as int;
//         final services = await _getAppointmentServices(appointmentId);
//         jsonMap['services'] = services;
//
//         appointments.add(AppointmentModel.fromJson(jsonMap));
//       }
//
//       return appointments;
//     } catch (e) {
//       return [];
//     }
//   }
//
//   /// جلب موعد معين مع تفاصيله
//   Future<AppointmentModel?> getAppointmentById(int id) async {
//     try {
//
//       // 1. جلب بيانات الموعد الأساسية
//       final appointmentResponse = await client.from('appointments').select('''
//             *,
//             employees!appointments_employee_id_fkey(full_name, profile_image_url)
//           ''').eq('id', id).maybeSingle();
//
//       if (appointmentResponse == null) {
//         return null;
//       }
//
//       final jsonMap = appointmentResponse;
//
//       // 2. معالجة بيانات الموظف
//       if (jsonMap['employees'] != null) {
//         jsonMap['employee_name'] = jsonMap['employees']['full_name'];
//         jsonMap['employee_image_url'] =
//             jsonMap['employees']['profile_image_url'];
//       }
//
//       // 3. جلب خدمات الموعد
//       final services = await _getAppointmentServices(id);
//       jsonMap['services'] = services;
//
//
//       return AppointmentModel.fromJson(jsonMap);
//     } catch (e) {
//       return null;
//     }
//   }
//
//   /// جلب خدمات موعد معين (دالة مساعدة)
//   /// جلب خدمات موعد معين (دالة مساعدة)
//   Future<List<Map<String, dynamic>>> _getAppointmentServices(
//       int appointmentId) async {
//     try {
//       // 1. جلب خدمات الموعد من appointment_services
//       final servicesResponse = await client
//           .from('appointment_services')
//           .select('*')
//           .eq('appointment_id', appointmentId);
//
//       if (servicesResponse == null || (servicesResponse as List).isEmpty) {
//         return [];
//       }
//
//       final servicesList = servicesResponse as List;
//       print(
//           '📦 Found ${servicesList.length} services for appointment $appointmentId');
//
//       // 2. استخراج service_ids
//       final serviceIds = servicesList
//           .map((s) => (s as Map<String, dynamic>)['service_id'] as int?)
//           .where((id) => id != null)
//           .cast<int>()
//           .toList();
//
//       if (serviceIds.isEmpty) {
//         return servicesList.cast<Map<String, dynamic>>();
//       }
//
//       // 3. جلب تفاصيل الخدمات من جدول services
//       // ✅ التعديل: استخدام service_name بدلاً من name
//       final servicesData = await client
//           .from('services')
//           .select('id, service_name, service_name_ar, price, duration_minutes')
//           .inFilter('id', serviceIds);
//
//       // 4. دمج البيانات
//       final services = servicesList.map((appointmentService) {
//         final serviceMap = Map<String, dynamic>.from(
//             appointmentService as Map<String, dynamic>);
//         final serviceId = serviceMap['service_id'];
//
//         if (serviceId != null) {
//           try {
//             final serviceData = (servicesData as List).firstWhere(
//               (s) => (s as Map<String, dynamic>)['id'] == serviceId,
//               orElse: () => <String, dynamic>{},
//             ) as Map<String, dynamic>;
//
//             if (serviceData.isNotEmpty) {
//               // ✅ استخدام الأسماء الصحيحة للأعمدة
//               serviceMap['service_name'] = serviceData['service_name'];
//               serviceMap['service_name_ar'] = serviceData['service_name_ar'];
//
//               // استخدم السعر والمدة من appointment_services إذا كانت موجودة
//               serviceMap['service_price'] ??= serviceData['price'];
//               serviceMap['service_duration'] ??=
//                   serviceData['duration_minutes'];
//             }
//           } catch (e) {
//           }
//         }
//
//         // تأكد من وجود قيم افتراضية
//         serviceMap['service_name'] ??= 'خدمة';
//         serviceMap['service_name_ar'] ??= 'خدمة';
//         serviceMap['service_price'] ??= 0.0;
//         serviceMap['service_duration'] ??= 30;
//
//         print(
//             '  📌 ${serviceMap['service_name_ar']} - ${serviceMap['service_price']} ريال');
//
//         return serviceMap;
//       }).toList();
//
//       return services;
//     } catch (e) {
//       return [];
//     }
//   }
//
//   /// تحديث حالة الموعد
//   Future<AppointmentModel?> updateAppointmentStatus(
//       int id, String status) async {
//     try {
//       final response = await client
//           .from('appointments')
//           .update({
//             'status': status,
//             'updated_at': DateTime.now().toIso8601String(),
//           })
//           .eq('id', id)
//           .select()
//           .maybeSingle();
//
//       if (response == null) return null;
//
//       // جلب الموعد الكامل مع الخدمات
//       return await getAppointmentById(id);
//     } catch (e) {
//       return null;
//     }
//   }
//
//   /// جلب الموظفين المتاحين
//   Future<List<EmployeeModel>> getAvailableEmployees() async {
//     try {
//       final response = await client
//           .from('employees')
//           .select()
//           .eq('is_active', true)
//           .order('full_name');
//
//       return (response as List)
//           .map((json) => EmployeeModel.fromJson(json as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       return [];
//     }
//   }
//
//   /// جلب الأوقات المتاحة ليوم معين
//   Future<List<String>> getAvailableTimeSlots(
//     DateTime date,
//     int durationMinutes, {
//     int? employeeId,
//   }) async {
//     try {
//       final dateStr =
//           '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
//
//       var query = client
//           .from('appointments')
//           .select('appointment_time, duration_minutes')
//           .eq('appointment_date', dateStr)
//           .neq('status', 'cancelled')
//           .neq('status', 'no_show');
//
//       if (employeeId != null) {
//         query = query.eq('employee_id', employeeId);
//       }
//
//       final response = await query;
//       final bookedAppointments = response as List;
//
//       final allSlots = _generateTimeSlots('09:00', '21:30', 30);
//
//       final availableSlots = allSlots.where((slot) {
//         final slotTime = _parseTime(slot);
//
//         for (var appointment in bookedAppointments) {
//           final appointmentMap = appointment as Map<String, dynamic>;
//           final bookedTime =
//               _parseTime(appointmentMap['appointment_time'] as String);
//           final bookedDuration = appointmentMap['duration_minutes'] as int;
//           final bookedEndTime =
//               bookedTime.add(Duration(minutes: bookedDuration));
//           final slotEndTime = slotTime.add(Duration(minutes: durationMinutes));
//
//           if ((slotTime.isBefore(bookedEndTime) &&
//                   slotEndTime.isAfter(bookedTime)) ||
//               slotTime == bookedTime) {
//             return false;
//           }
//         }
//         return true;
//       }).toList();
//
//       return availableSlots;
//     } catch (e) {
//       return _generateTimeSlots('09:00', '21:30', 30);
//     }
//   }
//
//   /// توليد فترات زمنية
//   List<String> _generateTimeSlots(
//       String startTime, String endTime, int intervalMinutes) {
//     final slots = <String>[];
//     var current = _parseTime(startTime);
//     final end = _parseTime(endTime);
//
//     while (current.isBefore(end) || current == end) {
//       slots.add(
//           '${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}');
//       current = current.add(Duration(minutes: intervalMinutes));
//     }
//
//     return slots;
//   }
//
//   /// تحويل نص الوقت إلى DateTime
//   DateTime _parseTime(String time) {
//     final parts = time.split(':');
//     final now = DateTime.now();
//     return DateTime(
//         now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
//   }
//
//   /// جلب المواعيد القادمة
//   Future<List<AppointmentModel>> getUpcomingAppointments(int userId) async {
//     try {
//       final today = DateTime.now();
//       final dateStr =
//           '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
//
//       final response = await client
//           .from('appointments')
//           .select('''
//             *,
//             employees!appointments_employee_id_fkey(full_name, profile_image_url)
//           ''')
//           .eq('user_id', userId)
//           .gte('appointment_date', dateStr)
//           .inFilter('status', ['pending', 'confirmed'])
//           .order('appointment_date')
//           .order('appointment_time');
//
//       final appointments = <AppointmentModel>[];
//
//       for (var json in response as List) {
//         final jsonMap = json as Map<String, dynamic>;
//
//         if (jsonMap['employees'] != null) {
//           jsonMap['employee_name'] = jsonMap['employees']['full_name'];
//           jsonMap['employee_image_url'] =
//               jsonMap['employees']['profile_image_url'];
//         }
//
//         final appointmentId = jsonMap['id'] as int;
//         final services = await _getAppointmentServices(appointmentId);
//         jsonMap['services'] = services;
//
//         appointments.add(AppointmentModel.fromJson(jsonMap));
//       }
//
//       return appointments;
//     } catch (e) {
//       return [];
//     }
//   }
//
//   /// جلب المواعيد السابقة
//   Future<List<AppointmentModel>> getPastAppointments(int userId) async {
//     try {
//       final today = DateTime.now();
//       final dateStr =
//           '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
//
//       final response = await client
//           .from('appointments')
//           .select('''
//             *,
//             employees!appointments_employee_id_fkey(full_name, profile_image_url)
//           ''')
//           .eq('user_id', userId)
//           .or('appointment_date.lt.$dateStr,status.eq.completed,status.eq.cancelled')
//           .order('appointment_date', ascending: false)
//           .order('appointment_time', ascending: false);
//
//       final appointments = <AppointmentModel>[];
//
//       for (var json in response as List) {
//         final jsonMap = json as Map<String, dynamic>;
//
//         if (jsonMap['employees'] != null) {
//           jsonMap['employee_name'] = jsonMap['employees']['full_name'];
//           jsonMap['employee_image_url'] =
//               jsonMap['employees']['profile_image_url'];
//         }
//
//         final appointmentId = jsonMap['id'] as int;
//         final services = await _getAppointmentServices(appointmentId);
//         jsonMap['services'] = services;
//
//         appointments.add(AppointmentModel.fromJson(jsonMap));
//       }
//
//       return appointments;
//     } catch (e) {
//       return [];
//     }
//   }
// }


// lib/features/booking/data/repositories/appointment_repository.dart
// ✅ استبدل الملف كاملاً

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/appointment_model.dart';
import '../../domain/models/appointment_person_model.dart';
import '../../domain/models/electronic_wallet_model.dart';
import '../../domain/models/employee_model.dart';

class AppointmentRepository {
  final SupabaseClient client;

  AppointmentRepository(this.client);

  // ══════════════════════════════════════════════════════════
  // ✅ CREATE - الحجز العادي (موجود - لا تعديل على منطقه)
  // ══════════════════════════════════════════════════════════

  Future<AppointmentModel> createAppointment(
      AppointmentModel appointment,
      List<int> serviceIds,
      ) async {
    try {
      final appointmentResponse = await client
          .from('appointments')
          .insert(appointment.toJson())
          .select()
          .single();

      final appointmentId = appointmentResponse['id'] as int;

      final servicesData = await client
          .from('services')
          .select('id, service_name, service_name_ar, price, duration_minutes')
          .inFilter('id', serviceIds);

      final appointmentServices = (servicesData as List).map((service) {
        final s = service as Map<String, dynamic>;
        return {
          'appointment_id': appointmentId,
          'service_id':     s['id'],
          'service_price':  s['price'],
          'service_duration': s['duration_minutes'],
          'employee_id':    appointment.employeeId,
          'status':         'pending',
        };
      }).toList();

      await client.from('appointment_services').insert(appointmentServices);

      return await getAppointmentById(appointmentId) ??
          AppointmentModel.fromJson(appointmentResponse);
    } catch (e) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════
  // ✅ CREATE - الحجز الجديد (متعدد الأشخاص + دفع إلكتروني)
  // ══════════════════════════════════════════════════════════

  /// نموذج بيانات الشخص عند الإنشاء
  /// person: { name, notes, services: [{serviceId, price, duration}] }
  Future<AppointmentModel> createAppointmentWithPersons({
    required AppointmentModel appointment,
    required List<Map<String, dynamic>> personsData,
    File? receiptFile,
  }) async {
    try {
      // ── 1. حساب المجموع الكلي ─────────────────────────────
      double totalPrice = 0;
      int totalDuration = 0;
      for (final person in personsData) {
        final services = person['services'] as List<Map<String, dynamic>>;
        for (final s in services) {
          totalPrice    += (s['price'] as num).toDouble();
          totalDuration += (s['duration'] as int? ?? 30);
        }
      }

      // ── 2. إنشاء الموعد الرئيسي ──────────────────────────
      final apptJson = {
        ...appointment.toJson(),
        'total_price':    totalPrice,
        'duration_minutes': totalDuration,
        'persons_count':  personsData.length,
      };

      final appointmentResponse = await client
          .from('appointments')
          .insert(apptJson)
          .select()
          .single();

      final appointmentId = appointmentResponse['id'] as int;
      debugPrint('✅ Appointment created: $appointmentId');

      // ── 3. رفع الإيصال إذا كان الدفع إلكترونياً ──────────
      if (receiptFile != null &&
          appointment.paymentMethod == 'electronic') {
        final receiptUrl = await _uploadReceipt(
          appointmentId: appointmentId,
          file: receiptFile,
        );
        if (receiptUrl != null) {
          await client
              .from('appointments')
              .update({'payment_receipt_url': receiptUrl})
              .eq('id', appointmentId);
          debugPrint('✅ Receipt uploaded: $receiptUrl');
        }
      }

      // ── 4. إدراج الأشخاص وخدماتهم ────────────────────────
      for (int i = 0; i < personsData.length; i++) {
        final personData = personsData[i];
        final personName  = personData['name'] as String;
        final personNotes = personData['notes'] as String?;
        final services    = personData['services'] as List<Map<String, dynamic>>;

        // إدراج الشخص
        final personResponse = await client
            .from('appointment_persons')
            .insert({
          'appointment_id': appointmentId,
          'person_name':    personName,
          'person_order':   i,
          'notes':          personNotes,
        })
            .select()
            .single();

        final personId = personResponse['id'] as int;
        debugPrint('✅ Person added: $personName (id: $personId)');

        // إدراج خدمات الشخص
        if (services.isNotEmpty) {
          final serviceRows = services.map((s) => {
            'appointment_id':   appointmentId,
            'service_id':       s['service_id'],
            'service_price':    s['price'],
            'service_duration': s['duration'] ?? 30,
            'employee_id':      appointment.employeeId,
            'status':           'pending',
            'person_id':        personId,
            'person_name':      personName,
          }).toList();

          await client
              .from('appointment_services')
              .insert(serviceRows);

          debugPrint('✅ ${services.length} services added for $personName');
        }
      }

      // ── 5. إرجاع الموعد الكامل ───────────────────────────
      return await getAppointmentById(appointmentId) ??
          AppointmentModel.fromJson(appointmentResponse);
    } catch (e) {
      debugPrint('❌ createAppointmentWithPersons error: $e');
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════
  // ✅ رفع الإيصال إلى Supabase Storage
  // ══════════════════════════════════════════════════════════

  Future<String?> _uploadReceipt({
    required int appointmentId,
    required File file,
  }) async {
    try {
      final ext      = file.path.split('.').last.toLowerCase();
      final fileName = 'receipt_${appointmentId}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final filePath = 'receipts/$fileName';

      await client.storage
          .from('payment-receipts')
          .upload(
        filePath,
        file,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );

      return client.storage
          .from('payment-receipts')
          .getPublicUrl(filePath);
    } catch (e) {
      debugPrint('❌ Upload receipt error: $e');
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════
  // ✅ ELECTRONIC WALLETS
  // ══════════════════════════════════════════════════════════

  Future<List<ElectronicWalletModel>> getElectronicWallets() async {
    try {
      final response = await client
          .from('electronic_wallets')
          .select()
          .eq('is_active', true)
          .order('display_order');

      return (response as List)
          .map((json) => ElectronicWalletModel.fromJson(
          json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ getElectronicWallets error: $e');
      return [];
    }
  }

  // ══════════════════════════════════════════════════════════
  // ✅ GET - جلب موعد مع الأشخاص والخدمات
  // ══════════════════════════════════════════════════════════

  Future<AppointmentModel?> getAppointmentById(int id) async {
    try {
      final appointmentResponse = await client
          .from('appointments')
          .select('''
            *,
            employees!appointments_employee_id_fkey(full_name, profile_image_url),
            electronic_wallets(*)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (appointmentResponse == null) return null;

      final jsonMap = Map<String, dynamic>.from(
          appointmentResponse as Map<String, dynamic>);

      // بيانات الموظف
      if (jsonMap['employees'] != null) {
        jsonMap['employee_name'] =
        jsonMap['employees']['full_name'];
        jsonMap['employee_image_url'] =
        jsonMap['employees']['profile_image_url'];
      }

      // ✅ جلب الأشخاص مع خدماتهم
      final persons = await _getAppointmentPersons(id);
      if (persons.isNotEmpty) {
        jsonMap['appointment_persons'] = persons;
      }

      // جلب الخدمات (للتوافق مع الكود القديم)
      final services = await _getAppointmentServices(id);
      jsonMap['appointment_services'] = services;

      return AppointmentModel.fromJson(jsonMap);
    } catch (e) {
      debugPrint('❌ getAppointmentById error: $e');
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════
  // ✅ جلب أشخاص الموعد (دالة مساعدة جديدة)
  // ══════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> _getAppointmentPersons(
      int appointmentId) async {
    try {
      final personsResponse = await client
          .from('appointment_persons')
          .select()
          .eq('appointment_id', appointmentId)
          .order('person_order');

      if ((personsResponse as List).isEmpty) return [];

      // جلب خدمات كل شخص
      final result = <Map<String, dynamic>>[];
      for (final person in personsResponse) {
        final personMap = Map<String, dynamic>.from(
            person as Map<String, dynamic>);
        final personId = personMap['id'] as int;

        // خدمات هذا الشخص
        final servicesResponse = await client
            .from('appointment_services')
            .select()
            .eq('appointment_id', appointmentId)
            .eq('person_id', personId);

        final services = (servicesResponse as List).cast<Map<String, dynamic>>();

        // إضافة أسماء الخدمات
        final enrichedServices = await _enrichServicesWithNames(services);
        personMap['appointment_services'] = enrichedServices;

        result.add(personMap);
      }
      return result;
    } catch (e) {
      debugPrint('❌ _getAppointmentPersons error: $e');
      return [];
    }
  }

  // ══════════════════════════════════════════════════════════
  // ✅ إضافة أسماء الخدمات (دالة مساعدة)
  // ══════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> _enrichServicesWithNames(
      List<Map<String, dynamic>> services) async {
    if (services.isEmpty) return services;

    try {
      final serviceIds = services
          .map((s) => s['service_id'] as int?)
          .where((id) => id != null)
          .cast<int>()
          .toSet()
          .toList();

      if (serviceIds.isEmpty) return services;

      final servicesData = await client
          .from('services')
          .select('id, service_name, service_name_ar')
          .inFilter('id', serviceIds);

      final servicesMap = {
        for (final s in (servicesData as List))
          (s as Map<String, dynamic>)['id'] as int: s
      };

      return services.map((s) {
        final enriched = Map<String, dynamic>.from(s);
        final svcData  = servicesMap[s['service_id'] as int?];
        if (svcData != null) {
          enriched['service_name']    = svcData['service_name'];
          enriched['service_name_ar'] = svcData['service_name_ar'];
        }
        enriched['service_name']    ??= 'خدمة';
        enriched['service_name_ar'] ??= 'خدمة';
        return enriched;
      }).toList();
    } catch (e) {
      return services;
    }
  }

  // ══════════════════════════════════════════════════════════
  // ✅ جلب خدمات الموعد (موجودة - محدَّثة)
  // ══════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> _getAppointmentServices(
      int appointmentId) async {
    try {
      final servicesResponse = await client
          .from('appointment_services')
          .select()
          .eq('appointment_id', appointmentId);

      if ((servicesResponse as List).isEmpty) return [];

      return await _enrichServicesWithNames(
          servicesResponse.cast<Map<String, dynamic>>());
    } catch (e) {
      debugPrint('❌ _getAppointmentServices error: $e');
      return [];
    }
  }

  // ══════════════════════════════════════════════════════════
  // ✅ باقي الدوال الموجودة (بدون تغيير في المنطق)
  // ══════════════════════════════════════════════════════════

  Future<void> completeAppointment(int appointmentId) async {
    try {
      await client.from('appointments').update({
        'status':         'completed',
        'payment_status': 'paid',
      }).eq('id', appointmentId);

      await client
          .from('loyalty_transactions')
          .update({'status': 'completed'})
          .eq('reference_type', 'appointment')
          .eq('reference_id', appointmentId)
          .eq('status', 'pending');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelAppointment(int appointmentId) async {
    try {
      await client
          .from('appointments')
          .update({'status': 'cancelled'}).eq('id', appointmentId);

      await client
          .from('loyalty_transactions')
          .update({'status': 'cancelled'})
          .eq('reference_type', 'appointment')
          .eq('reference_id', appointmentId)
          .eq('status', 'pending');
    } catch (e) {
      rethrow;
    }
  }

  Future<AppointmentModel?> updateAppointmentStatus(
      int id, String status) async {
    try {
      await client
          .from('appointments')
          .update({
        'status':     status,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', id);

      return await getAppointmentById(id);
    } catch (e) {
      return null;
    }
  }

  Future<List<AppointmentModel>> getUserAppointments(int userId,
      {String? status}) async {
    try {
      var query = client.from('appointments').select('''
        *,
        employees!appointments_employee_id_fkey(full_name, profile_image_url)
      ''').eq('user_id', userId);

      if (status != null) query = query.eq('status', status);

      final response = await query
          .order('appointment_date', ascending: false)
          .order('appointment_time', ascending: false);

      final appointments = <AppointmentModel>[];
      for (var json in response as List) {
        final jsonMap = Map<String, dynamic>.from(json as Map<String, dynamic>);

        if (jsonMap['employees'] != null) {
          jsonMap['employee_name'] = jsonMap['employees']['full_name'];
          jsonMap['employee_image_url'] =
          jsonMap['employees']['profile_image_url'];
        }

        final appointmentId = jsonMap['id'] as int;
        final services = await _getAppointmentServices(appointmentId);
        jsonMap['appointment_services'] = services;

        appointments.add(AppointmentModel.fromJson(jsonMap));
      }
      return appointments;
    } catch (e) {
      return [];
    }
  }

  Future<List<AppointmentModel>> getUpcomingAppointments(int userId) async {
    try {
      final today   = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final response = await client
          .from('appointments')
          .select('''
            *,
            employees!appointments_employee_id_fkey(full_name, profile_image_url)
          ''')
          .eq('user_id', userId)
          .gte('appointment_date', dateStr)
          .inFilter('status', ['pending', 'confirmed'])
          .order('appointment_date')
          .order('appointment_time');

      final appointments = <AppointmentModel>[];
      for (var json in response as List) {
        final jsonMap = Map<String, dynamic>.from(json as Map<String, dynamic>);

        if (jsonMap['employees'] != null) {
          jsonMap['employee_name'] = jsonMap['employees']['full_name'];
          jsonMap['employee_image_url'] =
          jsonMap['employees']['profile_image_url'];
        }

        final appointmentId = jsonMap['id'] as int;
        final services = await _getAppointmentServices(appointmentId);
        jsonMap['appointment_services'] = services;

        appointments.add(AppointmentModel.fromJson(jsonMap));
      }
      return appointments;
    } catch (e) {
      return [];
    }
  }

  Future<List<AppointmentModel>> getPastAppointments(int userId) async {
    try {
      final today   = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final response = await client
          .from('appointments')
          .select('''
            *,
            employees!appointments_employee_id_fkey(full_name, profile_image_url)
          ''')
          .eq('user_id', userId)
          .or('appointment_date.lt.$dateStr,status.eq.completed,status.eq.cancelled')
          .order('appointment_date', ascending: false)
          .order('appointment_time', ascending: false);

      final appointments = <AppointmentModel>[];
      for (var json in response as List) {
        final jsonMap = Map<String, dynamic>.from(json as Map<String, dynamic>);

        if (jsonMap['employees'] != null) {
          jsonMap['employee_name'] = jsonMap['employees']['full_name'];
          jsonMap['employee_image_url'] =
          jsonMap['employees']['profile_image_url'];
        }

        final appointmentId = jsonMap['id'] as int;
        final services = await _getAppointmentServices(appointmentId);
        jsonMap['appointment_services'] = services;

        appointments.add(AppointmentModel.fromJson(jsonMap));
      }
      return appointments;
    } catch (e) {
      return [];
    }
  }

  Future<List<EmployeeModel>> getAvailableEmployees() async {
    try {
      final response = await client
          .from('employees')
          .select()
          .eq('is_active', true)
          .order('full_name');

      return (response as List)
          .map((json) =>
          EmployeeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getAvailableTimeSlots(
      DateTime date,
      int durationMinutes, {
        int? employeeId,
      }) async {
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      var query = client
          .from('appointments')
          .select('appointment_time, duration_minutes')
          .eq('appointment_date', dateStr)
          .neq('status', 'cancelled')
          .neq('status', 'no_show');

      if (employeeId != null) {
        query = query.eq('employee_id', employeeId);
      }

      final response         = await query;
      final bookedApps       = response as List;
      final allSlots         = _generateTimeSlots('09:00', '21:30', 30);

      return allSlots.where((slot) {
        final slotTime = _parseTime(slot);
        for (var a in bookedApps) {
          final aMap        = a as Map<String, dynamic>;
          final bookedTime  = _parseTime(aMap['appointment_time'] as String);
          final bookedDur   = aMap['duration_minutes'] as int;
          final bookedEnd   = bookedTime.add(Duration(minutes: bookedDur));
          final slotEnd     = slotTime.add(Duration(minutes: durationMinutes));

          if (slotTime == bookedTime ||
              (slotTime.isBefore(bookedEnd) &&
                  slotEnd.isAfter(bookedTime))) {
            return false;
          }
        }
        return true;
      }).toList();
    } catch (e) {
      return _generateTimeSlots('09:00', '21:30', 30);
    }
  }

  List<String> _generateTimeSlots(
      String startTime, String endTime, int intervalMinutes) {
    final slots   = <String>[];
    var   current = _parseTime(startTime);
    final end     = _parseTime(endTime);

    while (!current.isAfter(end)) {
      slots.add(
        '${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}',
      );
      current = current.add(Duration(minutes: intervalMinutes));
    }
    return slots;
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final now   = DateTime.now();
    return DateTime(now.year, now.month, now.day,
        int.parse(parts[0]), int.parse(parts[1]));
  }
}
