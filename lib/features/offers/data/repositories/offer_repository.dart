import 'package:millionaire_barber/features/offers/domain/models/offers_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OfferRepository {
  final SupabaseClient client;

  OfferRepository(this.client);

  /// جلب جميع العروض النشطة
  Future<List<OfferModel>> getActiveOffers() async {
    final data = await client.from('offers').select().eq('is_active', true);

    if (data == null) return [];

    return (data as List).map((e) {
      if (e is Map<String, dynamic>) return OfferModel.fromJson(e);
      if (e is Map) return OfferModel.fromJson(Map<String, dynamic>.from(e));
      throw Exception('تنسيق بيانات العرض غير صحيح');
    }).toList();
  }

  /// جلب عرض معين بالمعرف
  Future<OfferModel?> getOfferById(int id) async {
    final data = await client.from('offers').select().eq('id', id).maybeSingle();

    if (data == null) return null;

    if (data is Map<String, dynamic>) return OfferModel.fromJson(data);
    if (data is Map) return OfferModel.fromJson(Map<String, dynamic>.from(data));

    throw Exception('تنسيق بيانات العرض غير صحيح');
  }

  /// إنشاء عرض جديد
  Future<OfferModel> createOffer(OfferModel offer) async {
    final data = await client.from('offers').insert(offer.toJson()).select().maybeSingle();

    if (data == null) throw Exception('فشل إنشاء العرض');

    if (data is Map<String, dynamic>) return OfferModel.fromJson(data);
    if (data is Map) return OfferModel.fromJson(Map<String, dynamic>.from(data));

    throw Exception('تنسيق بيانات العرض المنشأ غير صحيح');
  }

  /// تحديث عرض معين
  Future<OfferModel?> updateOffer(int id, Map<String, dynamic> updates) async {
    final data = await client.from('offers').update(updates).eq('id', id).select().maybeSingle();

    if (data == null) return null;

    if (data is Map<String, dynamic>) return OfferModel.fromJson(data);
    if (data is Map) return OfferModel.fromJson(Map<String, dynamic>.from(data));

    throw Exception('تنسيق بيانات العرض المحدّث غير صحيح');
  }

  /// حذف عرض معين
  Future<void> deleteOffer(int id) async {
    final res = await client.from('offers').delete().eq('id', id);

    if (res.error != null) throw Exception('خطأ في حذف العرض: ${res.error!.message}');
  }

  /// الاشتراك في تحديثات العرض realtime
  Stream<List<Map<String, dynamic>>> offerStream(int id) {
    return client.from('offers:id=eq.$id').stream(primaryKey: ['id']);
  }
}
