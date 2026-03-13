// lib/features/home/presentation/providers/banner_provider.dart

import 'package:flutter/foundation.dart';
import 'package:millionaire_barber/features/home/domain/models/banner_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BannerProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<BannerModel> _banners   = [];
  bool              _isLoading = false;

  List<BannerModel> get banners   => _banners;
  bool              get isLoading => _isLoading;

  // Future<void> fetchBanners() async {
  //   if (_isLoading) return;
  //   _isLoading = true;
  //   notifyListeners();
  //
  //   try {
  //     final res = await _supabase
  //         .from('banners')
  //         .select()
  //         .eq('is_active', true)
  //         .order('display_order');
  //
  //     _banners = (res as List)
  //         .map((j) => BannerModel.fromJson(j as Map<String, dynamic>))
  //         .where((b) => b.isCurrentlyActive)
  //         .toList();
  //   } catch (e) {
  //     debugPrint('❌ خطأ في جلب البنرات: $e');
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> fetchBanners() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _supabase
          .from('banners')
          .select()
          .eq('is_active', true)
          .order('display_order');

      debugPrint('🔍 بنرات من Supabase: ${res.length}');         // ✅ كم سجل؟
      debugPrint('🔍 البيانات: $res');                           // ✅ ما البيانات؟

      _banners = (res as List)
          .map((j) => BannerModel.fromJson(j as Map<String, dynamic>))
          .where((b) => b.isCurrentlyActive)
          .toList();

      debugPrint('✅ بنرات نشطة بعد الفلتر: ${_banners.length}'); // ✅ كم بعد الفلتر؟
      for (final b in _banners) {
        debugPrint('🖼️ imageUrl: ${b.imageUrl}');               // ✅ هل الرابط صحيح؟
      }
    } catch (e) {
      debugPrint('❌ خطأ في جلب البنرات: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


}
