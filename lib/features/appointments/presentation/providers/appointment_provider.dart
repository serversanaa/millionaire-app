import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/appointment_repository.dart';
import '../../domain/models/appointment_model.dart';
import '../../domain/models/employee_model.dart';

class AppointmentProvider extends ChangeNotifier {
  final AppointmentRepository repository;
  final SupabaseClient _supabase = Supabase.instance.client;

  AppointmentProvider({required this.repository});


  // ✅ متغير لحفظ وقت السيرفر
  DateTime? _serverTime;
  DateTime? get serverTime => _serverTime;


  // ══════════════════════════════════════════════════════════════════
  // STATE VARIABLES
  // ══════════════════════════════════════════════════════════════════

  List<AppointmentModel> _appointments = [];
  List<AppointmentModel> get appointments => _appointments;

  List<EmployeeModel> _employees = [];
  List<EmployeeModel> get employees => _employees;

  List<String> _availableTimeSlots = [];
  List<String> get availableTimeSlots => _availableTimeSlots;

  AppointmentModel? _selectedAppointment;
  AppointmentModel? get selectedAppointment => _selectedAppointment;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  RealtimeChannel? _realtimeChannel;

  // ══════════════════════════════════════════════════════════════════
  // USER APPOINTMENTS
  // ══════════════════════════════════════════════════════════════════

  /// جلب مواعيد المستخدم
  Future<void> fetchUserAppointments(int userId, {String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _appointments =
          await repository.getUserAppointments(userId, status: status);
    } catch (e) {
      _error = 'فشل تحميل المواعيد';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// جلب موعد معين
  Future<void> fetchAppointmentById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedAppointment = await repository.getAppointmentById(id);
    } catch (e) {
      _error = 'فشل تحميل تفاصيل الموعد';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// جلب المواعيد القادمة
  Future<List<AppointmentModel>> getUpcomingAppointments(int userId) async {
    try {
      return await repository.getUpcomingAppointments(userId);
    } catch (e) {
      return [];
    }
  }

  /// جلب المواعيد السابقة
  Future<List<AppointmentModel>> getPastAppointments(int userId) async {
    try {
      return await repository.getPastAppointments(userId);
    } catch (e) {
      return [];
    }
  }

  /// تصفية المواعيد حسب الحالة
  List<AppointmentModel> getAppointmentsByStatus(String status) {
    return _appointments.where((a) => a.status == status).toList();
  }

  // ══════════════════════════════════════════════════════════════════
  // CREATE & UPDATE APPOINTMENTS
  // ══════════════════════════════════════════════════════════════════

  /// إنشاء موعد جديد
  Future<bool> createAppointment(
    int userId,
    List<int> serviceIds,
    int? employeeId,
    DateTime appointmentDate,
    String appointmentTime,
    double totalPrice, {
    int durationMinutes = 60,
    String? clientName,
    String? clientPhone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final appointment = AppointmentModel(
        userId: userId,
        employeeId: employeeId,
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
        durationMinutes: durationMinutes,
        totalPrice: totalPrice,
        status: 'pending',
        paymentStatus: 'unpaid',
        clientName: clientName ?? 'عميل',
        clientPhone: clientPhone ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final created =
          await repository.createAppointment(appointment, serviceIds);

      if (created != null) {
        _appointments.insert(0, created);
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _error = 'فشل إنشاء الموعد';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث حالة الموعد
  Future<bool> updateAppointmentStatus(int appointmentId, String status) async {
    try {
      final success =
          await repository.updateAppointmentStatus(appointmentId, status);

      if (success != null) {
        final index = _appointments.indexWhere((a) => a.id == appointmentId);
        if (index != -1) {
          _appointments[index] = _appointments[index].copyWith(status: status);
        }
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// إلغاء الموعد
  Future<bool> cancelAppointment(int appointmentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await repository.updateAppointmentStatus(
        appointmentId,
        'cancelled',
      );

      if (success != null) {
        final index = _appointments.indexWhere((a) => a.id == appointmentId);
        if (index != -1) {
          _appointments[index] =
              _appointments[index].copyWith(status: 'cancelled');
        }
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _error = 'فشل إلغاء الموعد';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // ✅ EMPLOYEES & AVAILABLE TIMES (ديناميكي - حجز مفتوح)
  // ══════════════════════════════════════════════════════════════════

  /// جلب الموظفين المتاحين
  Future<void> fetchAvailableEmployees() async {
    try {
      _employees = await repository.getAvailableEmployees();
      notifyListeners();
    } catch (e) {
    }
  }

  /// ✅ جلب الأوقات المتاحة (ديناميكي من working_hours - حجز مفتوح)
  /// ✅ جلب الأوقات المتاحة (بدون شرط الموظفين)
  Future<void> fetchAvailableTimeSlots(
    DateTime date,
    int durationMinutes, {
    int? employeeId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      print(
          '📅 Fetching available time slots for: ${DateFormat('yyyy-MM-dd').format(date)}');

      // ✅ 1. جلب عدد الموظفين النشطين (اختياري)
      int totalEmployees = 1; // ✅ قيمة افتراضية

      try {
        final employeesResponse = await _supabase
            .from('employees')
            .select('id')
            .eq('is_active', true);

        final employeeCount = (employeesResponse as List).length;

        if (employeeCount > 0) {
          totalEmployees = employeeCount;
        }

      } catch (e) {
      }

      // ✅ 2. توليد جميع الأوقات من working_hours
      final allTimeSlots = await _generateTimeSlotsFromWorkingHours(date);

      if (allTimeSlots.isEmpty) {
        _availableTimeSlots = [];
        _isLoading = false;
        notifyListeners();
        return;
      }


      // ✅ 3. جلب الحجوزات في هذا التاريخ
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await _supabase
          .from('appointments')
          .select('appointment_time, status')
          .eq('appointment_date', formattedDate)
          .or('status.eq.pending,status.eq.confirmed');

      final bookings = response as List;


      // ✅ 4. حساب عدد الحجوزات لكل وقت
      final Map<String, int> bookingsPerSlot = {};

      for (var booking in bookings) {
        final time = booking['appointment_time'] as String;
        bookingsPerSlot[time] = (bookingsPerSlot[time] ?? 0) + 1;
      }

      // ✅ 5. تحديد الأوقات المتاحة
      _availableTimeSlots = allTimeSlots.where((time) {
        final bookingsCount = bookingsPerSlot[time] ?? 0;
        final isAvailable = bookingsCount < totalEmployees;

        if (!isAvailable) {
        } else {
        }

        return isAvailable;
      }).toList();

      print(
          '✅ Available times: ${_availableTimeSlots.length}/${allTimeSlots.length}');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _availableTimeSlots = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ توليد الأوقات من جدول working_hours
  Future<List<String>> _generateTimeSlotsFromWorkingHours(DateTime date) async {
    try {
      // تحديد يوم الأسبوع (0 = الأحد, 1 = الاثنين, ... 6 = السبت)
      final dayOfWeek = date.weekday % 7;


      // جلب أوقات العمل لهذا اليوم
      final response = await _supabase
          .from('working_hours')
          .select('start_time, end_time')
          .eq('day_of_week', dayOfWeek)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) {
        return [];
      }

      final startTime = response['start_time'] as String;
      final endTime = response['end_time'] as String;

      // تنظيف الوقت (إزالة الثواني إذا وجدت)
      final cleanStartTime =
          startTime.length > 5 ? startTime.substring(0, 5) : startTime;
      final cleanEndTime =
          endTime.length > 5 ? endTime.substring(0, 5) : endTime;


      return _generateTimeSlotsFromRange(cleanStartTime, cleanEndTime);
    } catch (e) {
      // Fallback: استخدام أوقات ثابتة
      return _generateAllTimeSlots();
    }
  }

  /// ✅ توليد الأوقات من نطاق معين
  List<String> _generateTimeSlotsFromRange(
      String startTimeStr, String endTimeStr) {
    final slots = <String>[];

    try {
      // تحويل النصوص إلى ساعات ودقائق
      final startParts = startTimeStr.split(':');
      int startHour = int.parse(startParts[0]);
      int startMinute = int.parse(startParts[1]);

      final endParts = endTimeStr.split(':');
      int endHour = int.parse(endParts[0]);
      int endMinute = int.parse(endParts[1]);

      // إذا كان وقت الانتهاء بعد منتصف الليل (مثلاً 01:00)
      if (endHour < startHour) {
        endHour += 24; // تحويل إلى 25:00 للحسابات
      }

      // توليد الأوقات (كل 30 دقيقة)
      int currentHour = startHour;
      int currentMinute = startMinute;

      while (currentHour < endHour ||
          (currentHour == endHour && currentMinute <= endMinute)) {
        final displayHour = currentHour % 24; // للعودة إلى 00-23
        final timeStr =
            '${displayHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}';
        slots.add(timeStr);

        // إضافة 30 دقيقة
        currentMinute += 30;
        if (currentMinute >= 60) {
          currentMinute = 0;
          currentHour++;
        }
      }

    } catch (e) {
    }

    return slots;
  }

  /// ✅ الحصول على اسم اليوم
  String _getDayName(int dayOfWeek) {
    const days = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    return days[dayOfWeek % 7];
  }

  // ✅ دالة لجلب وقت السيرفر من Supabase
  Future<void> fetchServerTime() async {
    try {
      // استدعاء Function من Supabase
      final response = await Supabase.instance.client.rpc('get_server_time');

      if (response != null) {
        // تحويل النص إلى DateTime
        final ksaTime = response['ksa_time'] as String;
        _serverTime = DateTime.parse(ksaTime);
        notifyListeners();
      }
    } catch (e) {
      // في حالة الخطأ، استخدم وقت الهاتف كاحتياطي
      _serverTime = DateTime.now();
    }
  }


  /// ✅ Fallback: توليد أوقات ثابتة (في حالة الخطأ)
  List<String> _generateAllTimeSlots() {
    return [
      '09:00',
      '09:30',
      '10:00',
      '10:30',
      '11:00',
      '11:30',
      '12:00',
      '12:30',
      '13:00',
      '13:30',
      '14:00',
      '14:30',
      '15:00',
      '15:30',
      '16:00',
      '16:30',
      '17:00',
      '17:30',
      '18:00',
      '18:30',
      '19:00',
      '19:30',
      '20:00',
      '20:30',
      '21:00',
      '21:30',
      '22:00',
      '22:30',
      '23:00',
      '23:30',
      '00:00',
      '00:30',
      '01:00',
    ];
  }

  /// ✅ الحصول على عدد الحجوزات لكل وقت
  Future<Map<String, int>> getBookingsPerSlot(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await _supabase
          .from('appointments')
          .select('appointment_time')
          .eq('appointment_date', formattedDate)
          .or('status.eq.pending,status.eq.confirmed');

      final bookings = response as List;
      final Map<String, int> bookingsPerSlot = {};

      for (var booking in bookings) {
        final time = booking['appointment_time'] as String;
        bookingsPerSlot[time] = (bookingsPerSlot[time] ?? 0) + 1;
      }

      return bookingsPerSlot;
    } catch (e) {
      return {};
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // REALTIME SUBSCRIPTIONS
  // ══════════════════════════════════════════════════════════════════

  /// الاشتراك في تحديثات مواعيد المستخدم
  void subscribeToUserAppointments(int userId) {
    unsubscribeFromAppointments();


    _realtimeChannel = _supabase
        .channel('appointments_user_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'appointments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {

            if (payload.eventType == PostgresChangeEvent.insert) {
              if (payload.newRecord != null) {
                final newAppointment =
                    AppointmentModel.fromJson(payload.newRecord);
                _appointments.insert(0, newAppointment);
                notifyListeners();
              }
            } else if (payload.eventType == PostgresChangeEvent.update) {
              if (payload.newRecord != null) {
                final updatedAppointment =
                    AppointmentModel.fromJson(payload.newRecord);
                final index = _appointments
                    .indexWhere((a) => a.id == updatedAppointment.id);
                if (index >= 0) {
                  _appointments[index] = updatedAppointment;
                  notifyListeners();
                }
              }
            } else if (payload.eventType == PostgresChangeEvent.delete) {
              if (payload.oldRecord != null) {
                final deletedId = payload.oldRecord['id'];
                _appointments.removeWhere((a) => a.id == deletedId);
                notifyListeners();
              }
            }
          },
        )
        .subscribe();
  }

  /// الاشتراك في تحديثات موعد واحد
  void subscribeToAppointmentChanges(int appointmentId) {
    unsubscribeFromAppointments();


    _realtimeChannel = _supabase
        .channel('appointment_changes_$appointmentId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'appointments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: appointmentId,
          ),
          callback: (payload) {

            if (payload.eventType == PostgresChangeEvent.update) {
              if (payload.newRecord != null) {
                _selectedAppointment =
                    AppointmentModel.fromJson(payload.newRecord);
                notifyListeners();
              }
            }
          },
        )
        .subscribe();
  }

  /// إلغاء الاشتراك
  void unsubscribeFromAppointments() {
    if (_realtimeChannel != null) {
      _realtimeChannel!.unsubscribe();
      _realtimeChannel = null;
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════

  /// مسح الأخطاء
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// إعادة تعيين الموعد المحدد
  void clearSelectedAppointment() {
    _selectedAppointment = null;
    notifyListeners();
  }


  // Future<AppointmentModel?> getAppointmentById(int appointmentId) async {
  //   try {
  //     final response = await Supabase.instance.client
  //         .from('appointments')
  //         .select('*, appointment_services(*, services(*))')
  //         .eq('id', appointmentId)
  //         .single();
  //
  //     return AppointmentModel.fromJson(response as Map<String, dynamic>);
  //   } catch (e) {
  //     debugPrint('❌ خطأ في جلب الحجز: $e');
  //     return null;
  //   }
  // }

  Future<AppointmentModel?> getAppointmentById(int appointmentId) async {
    try {
      final response = await Supabase.instance.client
          .from('appointments')
          .select('''
      *,
      appointment_services(
        *,
        services(
          id,
          service_name,
          service_name_ar,
          price,
          duration_minutes,
          image_url
        )
      ),
      employees!appointments_employee_id_fkey(
        id,
        full_name,
        job_title,
        profile_image_url
      )
    ''')
          .eq('id', appointmentId)
          .single();


      debugPrint('✅ بيانات الحجز: $response'); // ✅ للتشخيص
      return AppointmentModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ خطأ في جلب الحجز: $e');
      return null;
    }
  }


  // ══════════════════════════════════════════════════════════════════
// ✅ EMPLOYEE AVAILABILITY CHECK
// ══════════════════════════════════════════════════════════════════

  /// فحص توفر الموظف في وقت معين
  Future<bool> checkEmployeeAvailability({
    required int employeeId,
    required DateTime date,
    required String time,
    required int durationMinutes,
  }) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      final response = await _supabase
          .from('appointments')
          .select('appointment_time, duration_minutes')
          .eq('employee_id', employeeId)
          .eq('appointment_date', dateStr)
          .inFilter('status', ['pending', 'confirmed', 'in_progress']);

      final bookings = response as List;
      if (bookings.isEmpty) return true;

      final requestedStart = _timeToMinutes(time);
      final requestedEnd   = requestedStart + durationMinutes;

      for (final booking in bookings) {
        final existingStart    = _timeToMinutes(booking['appointment_time'] as String);
        final existingDuration = (booking['duration_minutes'] as num?)?.toInt() ?? 30;
        final existingEnd      = existingStart + existingDuration;

        // تحقق من التداخل: هل يتداخل الموعد المطلوب مع موعد موجود؟
        if (requestedStart < existingEnd && requestedEnd > existingStart) {
          return false; // ❌ يوجد تعارض
        }
      }

      return true; // ✅ متاح
    } catch (e) {
      debugPrint('checkEmployeeAvailability error: $e');
      return true; // افتراض التوفر عند الخطأ
    }
  }

  /// تحويل الوقت إلى دقائق للمقارنة
  int _timeToMinutes(String time) {
    try {
      final clean = time.length > 5 ? time.substring(0, 5) : time;
      final parts  = clean.split(':');
      final hour   = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      return hour * 60 + minute;
    } catch (_) {
      return 0;
    }
  }

  @override
  void dispose() {
    unsubscribeFromAppointments();
    super.dispose();
  }
}