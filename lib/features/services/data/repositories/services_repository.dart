import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/service_model.dart';
import '../../domain/models/service_category_model.dart';

class ServicesRepository {
  final SupabaseClient client;

  ServicesRepository(this.client);

  Future<List<ServiceCategoryModel>> getCategories() async {
    final data = await client.from('service_categories').select();
    if (data == null) return [];
    return (data as List).map((e) {
      if (e is Map<String, dynamic>) return ServiceCategoryModel.fromJson(e);
      if (e is Map) return ServiceCategoryModel.fromJson(Map<String, dynamic>.from(e));
      throw Exception('تنسيق بيانات تصنيفات الخدمات غير صحيح');
    }).toList();
  }

  Future<List<ServiceModel>> getServices({bool onlyActive = true}) async {
    var query = client.from('services').select();

    if (onlyActive) {
      query = query.eq('is_active', true);
    }

    final data = await query;
    if (data == null) return [];

    return (data as List).map((e) {
      if (e is Map<String, dynamic>) return ServiceModel.fromJson(e);
      if (e is Map) return ServiceModel.fromJson(Map<String, dynamic>.from(e));
      throw Exception('تنسيق بيانات الخدمات غير صحيح');
    }).toList();
  }

  Future<ServiceModel?> getServiceById(int id) async {
    final data = await client.from('services').select().eq('id', id).maybeSingle();
    if (data == null) return null;

    if (data is Map<String, dynamic>) return ServiceModel.fromJson(data);
    if (data is Map) return ServiceModel.fromJson(Map<String, dynamic>.from(data));

    throw Exception('تنسيق بيانات الخدمة غير صحيح');
  }

  Future<ServiceModel> createService(ServiceModel service) async {
    final data = await client.from('services').insert(service.toJson()).select().maybeSingle();
    if (data == null) throw Exception('فشل إنشاء الخدمة');

    if (data is Map<String, dynamic>) return ServiceModel.fromJson(data);
    if (data is Map) return ServiceModel.fromJson(Map<String, dynamic>.from(data));

    throw Exception('تنسيق بيانات الخدمة المنشأة غير صحيح');
  }

  Future<ServiceModel?> updateService(int id, Map<String, dynamic> updates) async {
    final data = await client.from('services').update(updates).eq('id', id).select().maybeSingle();
    if (data == null) return null;

    if (data is Map<String, dynamic>) return ServiceModel.fromJson(data);
    if (data is Map) return ServiceModel.fromJson(Map<String, dynamic>.from(data));

    throw Exception('تنسيق بيانات الخدمة المحدّثة غير صحيح');
  }

  Future<void> deleteService(int id) async {
    final res = await client.from('services').delete().eq('id', id);
    if (res.error != null) throw Exception('خطأ في حذف الخدمة: ${res.error!.message}');
  }

  Stream<List<Map<String, dynamic>>> serviceStream(int id) {
    return client.from('services:id=eq.$id').stream(primaryKey: ['id']);
  }
}
