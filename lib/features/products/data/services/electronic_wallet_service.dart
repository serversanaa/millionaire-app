import 'package:flutter/foundation.dart';
import 'package:millionaire_barber/features/appointments/domain/models/electronic_wallet_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ✅ استخدام الموديل الموجود في booking

class ElectronicWalletService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ✅ Cache لتجنب طلبات متكررة
  List<ElectronicWalletModel>? _cache;

  Future<List<ElectronicWalletModel>> getActiveWallets() async {
    if (_cache != null) return _cache!;

    try {
      final response = await _supabase
          .from('electronic_wallets')
          .select()
          .eq('is_active', true)
          .order('display_order');

      _cache = (response as List)
          .map((j) => ElectronicWalletModel.fromJson(j as Map<String, dynamic>))
          .toList();

      return _cache!;
    } catch (e) {
      debugPrint('❌ خطأ في جلب المحافظ: $e');
      return [];
    }
  }

  void clearCache() => _cache = null;
}
