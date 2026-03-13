import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:millionaire_barber/features/appointments/domain/models/employee_model.dart';
import '../../data/repositories/employee_repository.dart';

class EmployeeProvider extends ChangeNotifier {
  final EmployeeRepository employeeRepository;
  final SupabaseClient _supabase = Supabase.instance.client;

  EmployeeProvider({required this.employeeRepository});

  List<EmployeeModel> _employees = [];
  List<EmployeeModel> get employees => _employees;

  EmployeeModel? _selectedEmployee;
  EmployeeModel? get selectedEmployee => _selectedEmployee;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ✅ قناة Realtime
  RealtimeChannel? _realtimeChannel;

  /// جلب جميع الموظفين النشطين
  Future<void> fetchActiveEmployees() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _employees = await employeeRepository.getAllActiveEmployees();
    } catch (e) {
      _error = 'خطأ أثناء تحميل بيانات الموظفين.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// جلب موظف واحد بواسطة ID
  Future<void> fetchEmployeeById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedEmployee = await employeeRepository.getEmployeeById(id);
    } catch (e) {
      _error = 'خطأ أثناء تحميل بيانات الموظف.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إنشاء موظف جديد
  Future<bool> createEmployee(EmployeeModel employee) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final created = await employeeRepository.createEmployee(employee);
      _employees.add(created);

      // ✅ سيتم التحديث تلقائياً عبر Realtime
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'فشل إنشاء الموظف.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث بيانات موظف معين
  Future<bool> updateEmployee(int id, Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await employeeRepository.updateEmployee(id, updates);
      if (updated != null) {
        final index = _employees.indexWhere((e) => e.id == id);
        if (index >= 0) {
          _employees[index] = updated;
        }

        // ✅ سيتم التحديث تلقائياً عبر Realtime
        notifyListeners();
        return true;
      } else {
        _error = 'الموظف غير موجود.';
        return false;
      }
    } catch (e) {
      _error = 'فشل تحديث بيانات الموظف.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// حذف موظف بواسطة ID
  Future<bool> deleteEmployee(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await employeeRepository.deleteEmployee(id);
      _employees.removeWhere((e) => e.id == id);

      // ✅ سيتم التحديث تلقائياً عبر Realtime
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'فشل حذف الموظف.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ الاشتراك في تحديثات جميع الموظفين (محدث)
  void subscribeToAllEmployees() {
    // إلغاء الاشتراك السابق
    unsubscribeFromEmployees();


    _realtimeChannel = _supabase
        .channel('employees_changes')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'employees',
      callback: (payload) {

        if (payload.eventType == PostgresChangeEvent.insert) {
          // إضافة موظف جديد
          if (payload.newRecord != null) {
            final newEmployee = EmployeeModel.fromJson(payload.newRecord);
            _employees.add(newEmployee);
            notifyListeners();
          }
        } else if (payload.eventType == PostgresChangeEvent.update) {
          // تحديث موظف
          if (payload.newRecord != null) {
            final updatedEmployee = EmployeeModel.fromJson(payload.newRecord);
            final index = _employees.indexWhere((e) => e.id == updatedEmployee.id);
            if (index >= 0) {
              _employees[index] = updatedEmployee;
              notifyListeners();
            }
          }
        } else if (payload.eventType == PostgresChangeEvent.delete) {
          // حذف موظف
          if (payload.oldRecord != null) {
            final deletedId = payload.oldRecord['id'];
            _employees.removeWhere((e) => e.id == deletedId);
            notifyListeners();
          }
        }
      },
    )
        .subscribe();
  }

  /// ✅ الاشتراك في تحديثات موظف واحد (محدث)
  void subscribeToEmployeeChanges(int id) {
    // إلغاء الاشتراك السابق
    unsubscribeFromEmployees();


    _realtimeChannel = _supabase
        .channel('employee_changes_$id')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'employees',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: id,
      ),
      callback: (payload) {

        if (payload.eventType == PostgresChangeEvent.update) {
          if (payload.newRecord != null) {
            _selectedEmployee = EmployeeModel.fromJson(payload.newRecord);
            notifyListeners();
          }
        }
      },
    )
        .subscribe();
  }

  /// ✅ إلغاء الاشتراك
  void unsubscribeFromEmployees() {
    if (_realtimeChannel != null) {
      _realtimeChannel!.unsubscribe();
      _realtimeChannel = null;
    }
  }

  @override
  void dispose() {
    unsubscribeFromEmployees();
    super.dispose();
  }
}