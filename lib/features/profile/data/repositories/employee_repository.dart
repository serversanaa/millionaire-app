import 'package:millionaire_barber/features/appointments/domain/models/employee_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmployeeRepository {
  final SupabaseClient client;

  EmployeeRepository(this.client);

  /// جلب بيانات موظف معين حسب الـ ID
  Future<EmployeeModel?> getEmployeeById(int id) async {
    final data = await client.from('employees').select().eq('id', id).maybeSingle();

    if (data == null) return null;

    // تحقق من نوع البيانات ثم تحويلها
    if (data is Map<String, dynamic>) {
      return EmployeeModel.fromJson(data);
    }

    if (data is Map) {
      return EmployeeModel.fromJson(Map<String, dynamic>.from(data));
    }

    throw Exception('تنسيق بيانات الموظف غير صحيح');
  }

  /// جلب قائمة الموظفين النشطين
  Future<List<EmployeeModel>> getAllActiveEmployees() async {
    final data = await client.from('employees').select().eq('is_active', true);
    if (data == null) return [];

    return (data as List).map((e) {
      if (e is Map<String, dynamic>) return EmployeeModel.fromJson(e);
      if (e is Map) return EmployeeModel.fromJson(Map<String, dynamic>.from(e));
      throw Exception('تنسيق أحد عناصر الموظفين غير صحيح');
    }).toList();
  }

  /// إنشاء موظف جديد
  Future<EmployeeModel> createEmployee(EmployeeModel employee) async {
    final data = await client.from('employees').insert(employee.toJson()).select().maybeSingle();

    if (data == null) {
      throw Exception('فشل إنشاء الموظف');
    }

    if (data is Map<String, dynamic>) {
      return EmployeeModel.fromJson(data);
    }

    if (data is Map) {
      return EmployeeModel.fromJson(Map<String, dynamic>.from(data));
    }

    throw Exception('تنسيق بيانات الموظف المنشأ غير صحيح');
  }

  /// تحديث بيانات موظف معين
  Future<EmployeeModel?> updateEmployee(int id, Map<String, dynamic> updates) async {
    final data = await client.from('employees').update(updates).eq('id', id).select().maybeSingle();

    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      return EmployeeModel.fromJson(data);
    }

    if (data is Map) {
      return EmployeeModel.fromJson(Map<String, dynamic>.from(data));
    }

    throw Exception('تنسيق بيانات الموظف المحدّث غير صحيح');
  }

  /// حذف موظف معين
  Future<void> deleteEmployee(int id) async {
    final res = await client.from('employees').delete().eq('id', id);

    if (res.error != null) {
      throw Exception('خطأ أثناء حذف الموظف: ${res.error!.message}');
    }
  }

  /// متابعة تحديثات بيانات موظف في الوقت الحقيقي
  Stream<List<Map<String, dynamic>>> employeeStream(int id) {
    return client.from('employees:id=eq.$id').stream(primaryKey: ['id']);
  }
}
