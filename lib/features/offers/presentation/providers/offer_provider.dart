import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:millionaire_barber/features/offers/domain/models/offers_model.dart';
import '../../data/repositories/offer_repository.dart';

class OfferProvider extends ChangeNotifier {
  final OfferRepository offerRepository;
  final SupabaseClient _supabase = Supabase.instance.client;

  OfferProvider({required this.offerRepository});

  List<OfferModel> _offers = [];
  List<OfferModel> get offers => _offers;

  OfferModel? _selectedOffer;
  OfferModel? get selectedOffer => _selectedOffer;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ✅ قناة Realtime
  RealtimeChannel? _realtimeChannel;

  /// جلب كل العروض النشطة
  Future<void> fetchActiveOffers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _offers = await offerRepository.getActiveOffers();
    } catch (e) {
      _error = 'فشل تحميل العروض النشطة.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// جلب عرض معين بواسطة ID
  Future<void> fetchOfferById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedOffer = await offerRepository.getOfferById(id);
    } catch (e) {
      _error = 'فشل تحميل بيانات العرض.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إنشاء عرض جديد
  Future<bool> createOffer(OfferModel offer) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final created = await offerRepository.createOffer(offer);
      _offers.add(created);

      // ✅ سيتم التحديث تلقائياً عبر Realtime
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'فشل إنشاء العرض.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث عرض معين
  Future<bool> updateOffer(int id, Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await offerRepository.updateOffer(id, updates);
      if (updated != null) {
        final index = _offers.indexWhere((o) => o.id == id);
        if (index >= 0) {
          _offers[index] = updated;
        }

        // ✅ سيتم التحديث تلقائياً عبر Realtime
        notifyListeners();
        return true;
      } else {
        _error = 'العرض غير موجود.';
        return false;
      }
    } catch (e) {
      _error = 'فشل تحديث العرض.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// حذف عرض بواسطة ID
  Future<bool> deleteOffer(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await offerRepository.deleteOffer(id);
      _offers.removeWhere((o) => o.id == id);

      // ✅ سيتم التحديث تلقائياً عبر Realtime
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'فشل حذف العرض.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ الاشتراك في تحديثات جميع العروض النشطة
  void subscribeToActiveOffers() {
    unsubscribeFromOffers();


    _realtimeChannel = _supabase
        .channel('offers_changes')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'offers',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'is_active',
        value: true,
      ),
      callback: (payload) {

        if (payload.eventType == PostgresChangeEvent.insert) {
          // عرض جديد
          if (payload.newRecord != null) {
            final newOffer = OfferModel.fromJson(payload.newRecord);
            _offers.insert(0, newOffer);
            notifyListeners();
          }
        } else if (payload.eventType == PostgresChangeEvent.update) {
          // تحديث عرض
          if (payload.newRecord != null) {
            final updatedOffer = OfferModel.fromJson(payload.newRecord);
            final index = _offers.indexWhere((o) => o.id == updatedOffer.id);
            if (index >= 0) {
              _offers[index] = updatedOffer;
              notifyListeners();
            }
          }
        } else if (payload.eventType == PostgresChangeEvent.delete) {
          // حذف عرض
          if (payload.oldRecord != null) {
            final deletedId = payload.oldRecord['id'];
            _offers.removeWhere((o) => o.id == deletedId);
            notifyListeners();
          }
        }
      },
    )
        .subscribe();
  }

  /// ✅ الاشتراك في تحديثات عرض واحد (محدث)
  void subscribeToOfferChanges(int id) {
    unsubscribeFromOffers();


    _realtimeChannel = _supabase
        .channel('offer_changes_$id')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'offers',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: id,
      ),
      callback: (payload) {

        if (payload.eventType == PostgresChangeEvent.update) {
          if (payload.newRecord != null) {
            _selectedOffer = OfferModel.fromJson(payload.newRecord);
            notifyListeners();
          }
        }
      },
    )
        .subscribe();
  }

  /// ✅ إلغاء الاشتراك
  void unsubscribeFromOffers() {
    if (_realtimeChannel != null) {
      _realtimeChannel!.unsubscribe();
      _realtimeChannel = null;
    }
  }

  @override
  void dispose() {
    unsubscribeFromOffers();
    super.dispose();
  }
}