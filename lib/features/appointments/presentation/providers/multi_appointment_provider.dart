// lib/features/Appointment/presentation/providers/multi_Appointment_provider.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:millionaire_barber/features/appointments/data/repositories/appointment_repository.dart';
import 'package:millionaire_barber/features/appointments/domain/models/appointment_model.dart';
import 'package:millionaire_barber/features/appointments/domain/models/electronic_wallet_model.dart';

// ══════════════════════════════════════════════════════════
// نماذج مساعدة للـ UI فقط (ليست Database Models)
// ══════════════════════════════════════════════════════════

class AppointmentServiceItem {
  final int serviceId;
  final String serviceName;
  final String serviceNameAr;
  final double price;
  final int duration;

  AppointmentServiceItem({
    required this.serviceId,
    required this.serviceName,
    required this.serviceNameAr,
    required this.price,
    required this.duration,
  });
}

class AppointmentPersonItem {
  final String tempId; // ID مؤقت للـ UI فقط
  String name;
  String notes;
  List<AppointmentServiceItem> services;

  AppointmentPersonItem({
    required this.tempId,
    required this.name,
    this.notes = '',
    List<AppointmentServiceItem>? services,
  }) : services = services ?? [];

  double get totalPrice =>
      services.fold(0.0, (sum, s) => sum + s.price);

  int get totalDuration =>
      services.fold(0, (sum, s) => sum + s.duration);

  bool get isValid =>
      name.trim().isNotEmpty && services.isNotEmpty;
}

// ══════════════════════════════════════════════════════════
// Provider الرئيسي
// ══════════════════════════════════════════════════════════

class MultiAppointmentProvider with ChangeNotifier {
  final AppointmentRepository repository;

  MultiAppointmentProvider({required this.repository});

  // ── قائمة الأشخاص ─────────────────────────────────────
  final List<AppointmentPersonItem> _persons = [];
  List<AppointmentPersonItem> get persons => List.unmodifiable(_persons);

  // ── بيانات الموعد ──────────────────────────────────────
  DateTime? _selectedDate;
  String?   _selectedTimeSlot;
  int?      _selectedEmployeeId;

  DateTime? get selectedDate      => _selectedDate;
  String?   get selectedTimeSlot  => _selectedTimeSlot;
  int?      get selectedEmployeeId => _selectedEmployeeId;

  // ── الدفع ──────────────────────────────────────────────
  String  _paymentMethod   = 'cash'; // cash | electronic
  int?    _selectedWalletId;
  File?   _receiptFile;

  String  get paymentMethod    => _paymentMethod;
  int?    get selectedWalletId => _selectedWalletId;
  File?   get receiptFile      => _receiptFile;

  // ── المحافظ الإلكترونية ────────────────────────────────
  List<ElectronicWalletModel> _wallets = [];
  List<ElectronicWalletModel> get wallets => _wallets;
  bool _walletsLoaded = false;

  // ── الحالة ─────────────────────────────────────────────
  bool    _isLoading    = false;
  String? _errorMessage;
  bool    _isSuccess    = false;
  AppointmentModel? _createdAppointment;

  bool              get isLoading          => _isLoading;
  String?           get errorMessage       => _errorMessage;
  bool              get isSuccess          => _isSuccess;
  AppointmentModel? get createdAppointment => _createdAppointment;

  // ── Computed ───────────────────────────────────────────
  double get totalPrice =>
      _persons.fold(0.0, (sum, p) => sum + p.totalPrice);

  int get totalDuration =>
      _persons.fold(0, (sum, p) => sum + p.totalDuration);

  bool get isElectronic => _paymentMethod == 'electronic';

  bool get isFormValid {
    if (_persons.isEmpty)          return false;
    if (!_persons.every((p) => p.isValid)) return false;
    if (_selectedDate == null)     return false;
    if (_selectedTimeSlot == null) return false;
    if (isElectronic) {
      if (_selectedWalletId == null) return false;
      if (_receiptFile == null)      return false;
    }
    return true;
  }

  // ══════════════════════════════════════════════════════════
  // إدارة الأشخاص
  // ══════════════════════════════════════════════════════════

  void addPerson({String? name}) {
    _persons.add(AppointmentPersonItem(
      tempId: '${DateTime.now().microsecondsSinceEpoch}_${_persons.length}',
      name:   name ?? 'شخص ${_persons.length + 1}',
    ));
    notifyListeners();
  }

  void removePerson(String tempId) {
    if (_persons.length <= 1) return; // لا يمكن حذف الشخص الأول
    _persons.removeWhere((p) => p.tempId == tempId);
    notifyListeners();
  }

  void updatePersonName(String tempId, String name) {
    _findPerson(tempId)?.name = name;
    notifyListeners();
  }

  void updatePersonNotes(String tempId, String notes) {
    _findPerson(tempId)?.notes = notes;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════
  // إدارة خدمات كل شخص
  // ══════════════════════════════════════════════════════════

  void addServiceToPerson(String tempId, AppointmentServiceItem service) {
    final person = _findPerson(tempId);
    if (person == null) return;

    // منع إضافة نفس الخدمة مرتين
    final alreadyAdded =
    person.services.any((s) => s.serviceId == service.serviceId);
    if (alreadyAdded) return;

    person.services.add(service);
    notifyListeners();
  }

  void removeServiceFromPerson(String tempId, int serviceId) {
    _findPerson(tempId)
        ?.services
        .removeWhere((s) => s.serviceId == serviceId);
    notifyListeners();
  }

  void toggleServiceForPerson(String tempId, AppointmentServiceItem service) {
    final person = _findPerson(tempId);
    if (person == null) return;

    final exists = person.services.any((s) => s.serviceId == service.serviceId);
    if (exists) {
      person.services.removeWhere((s) => s.serviceId == service.serviceId);
    } else {
      person.services.add(service);
    }
    notifyListeners();
  }

  bool isServiceSelectedForPerson(String tempId, int serviceId) {
    return _findPerson(tempId)
        ?.services
        .any((s) => s.serviceId == serviceId) ??
        false;
  }

  // ══════════════════════════════════════════════════════════
  // التاريخ والوقت
  // ══════════════════════════════════════════════════════════

  void setDate(DateTime date) {
    _selectedDate    = date;
    _selectedTimeSlot = null; // reset عند تغيير التاريخ
    notifyListeners();
  }

  void setTimeSlot(String slot) {
    _selectedTimeSlot = slot;
    notifyListeners();
  }

  void setEmployee(int? employeeId) {
    _selectedEmployeeId = employeeId;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════
  // الدفع
  // ══════════════════════════════════════════════════════════

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    if (method == 'cash') {
      _selectedWalletId = null;
      _receiptFile      = null;
    }
    notifyListeners();
  }

  void selectWallet(int walletId) {
    _selectedWalletId = walletId;
    notifyListeners();
  }

  void setReceiptFile(File file) {
    _receiptFile = file;
    notifyListeners();
  }

  void clearReceipt() {
    _receiptFile = null;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════
  // جلب المحافظ الإلكترونية
  // ══════════════════════════════════════════════════════════

  Future<void> loadWallets() async {
    if (_walletsLoaded) return; // لا نجلب مرتين
    try {
      _wallets      = await repository.getElectronicWallets();
      _walletsLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ loadWallets error: $e');
    }
  }

  ElectronicWalletModel? get selectedWallet =>
      _wallets.where((w) => w.id == _selectedWalletId).firstOrNull;

  // ══════════════════════════════════════════════════════════
  // تأكيد الحجز
  // ══════════════════════════════════════════════════════════

  Future<bool> submitAppointment({
    required int userId,
    required String clientName,
    required String clientPhone,
  }) async {
    if (!isFormValid) {
      _errorMessage = _getValidationError();
      notifyListeners();
      return false;
    }

    _isLoading    = true;
    _errorMessage = null;
    _isSuccess    = false;
    notifyListeners();

    try {
      // بناء بيانات الأشخاص للـ Repository
      final personsData = _persons.map((person) {
        return {
          'name':  person.name.trim(),
          'notes': person.notes.trim().isEmpty ? null : person.notes.trim(),
          'services': person.services.map((s) => {
            'service_id': s.serviceId,
            'price':      s.price,
            'duration':   s.duration,
          }).toList(),
        };
      }).toList();

      // بناء AppointmentModel الرئيسي
      final appointment = AppointmentModel(
        userId:           userId,
        employeeId:       _selectedEmployeeId,
        appointmentDate:  _selectedDate!,
        appointmentTime:  _selectedTimeSlot!,
        durationMinutes:  totalDuration,
        totalPrice:       totalPrice,
        status:           'pending',
        paymentStatus:    'unpaid',
        paymentMethod:    _paymentMethod,
        clientName:       clientName,
        clientPhone:      clientPhone,
        personsCount:     _persons.length,
        electronicWalletId: _selectedWalletId,
      );

      // إرسال للـ Repository
      final result = await repository.createAppointmentWithPersons(
        appointment:  appointment,
        personsData:  personsData,
        receiptFile:  _receiptFile,
      );

      _createdAppointment = result;
      _isSuccess          = true;
      _isLoading          = false;
      notifyListeners();
      return true;

    } catch (e) {
      debugPrint('❌ submitAppointment error: $e');
      _errorMessage = 'فشل إنشاء الحجز، حاول مرة أخرى';
      _isLoading    = false;
      notifyListeners();
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════
  // Helpers
  // ══════════════════════════════════════════════════════════

  AppointmentPersonItem? _findPerson(String tempId) =>
      _persons.where((p) => p.tempId == tempId).firstOrNull;

  String _getValidationError() {
    if (_persons.isEmpty)      return 'أضف شخصاً واحداً على الأقل';
    for (final p in _persons) {
      if (p.name.trim().isEmpty) return 'أدخل اسم ${p.name}';
      if (p.services.isEmpty)   return 'اختر خدمة لـ ${p.name}';
    }
    if (_selectedDate == null)     return 'اختر تاريخ الموعد';
    if (_selectedTimeSlot == null) return 'اختر وقت الموعد';
    if (isElectronic) {
      if (_selectedWalletId == null) return 'اختر المحفظة الإلكترونية';
      if (_receiptFile == null)      return 'ارفع صورة الإيصال';
    }
    return 'تحقق من البيانات';
  }

  // إعادة تعيين كل شيء بعد الحجز أو عند الخروج
  void reset() {
    _persons.clear();
    _selectedDate       = null;
    _selectedTimeSlot   = null;
    _selectedEmployeeId = null;
    _paymentMethod      = 'cash';
    _selectedWalletId   = null;
    _receiptFile        = null;
    _isLoading          = false;
    _errorMessage       = null;
    _isSuccess          = false;
    _createdAppointment = null;
    notifyListeners();
  }

  @override
  void dispose() {
    reset();
    super.dispose();
  }
}
