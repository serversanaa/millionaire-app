import 'package:flutter/material.dart';
import 'package:millionaire_barber/features/coupons/data/repositories/coupon_repository.dart';
import 'package:millionaire_barber/features/coupons/domain/models/coupon_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class CouponProvider extends ChangeNotifier {
  final CouponRepository couponRepository;
  final SupabaseClient _supabase = Supabase.instance.client;

  CouponProvider({required this.couponRepository});

  List<CouponModel> _coupons = [];
  List<CouponModel> get coupons => _coupons;

  CouponModel? _appliedCoupon;
  CouponModel? get appliedCoupon => _appliedCoupon;

  CouponValidationResult? _validationResult;
  CouponValidationResult? get validationResult => _validationResult;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  double? _discountAmount;
  double? get discountAmount => _discountAmount;

  RealtimeChannel? _realtimeChannel;

  /// ═══════════════════════════════════════════════════════════════
  /// جلب الكوبونات النشطة
  /// ═══════════════════════════════════════════════════════════════

  Future<void> fetchActiveCoupons() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _coupons = await couponRepository.getActiveCoupons();
    } catch (e) {
      _error = 'فشل تحميل الكوبونات';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// جلب الكوبونات المتاحة للمستخدم فقط (✨ جديد)
  /// ═══════════════════════════════════════════════════════════════

  Future<void> fetchAvailableCouponsForUser(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _coupons = await couponRepository.getAvailableCouponsForUser(userId);
    } catch (e) {
      _error = 'فشل تحميل الكوبونات المتاحة';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// التحقق من استخدام المستخدم لكوبون (✨ جديد)
  /// ═══════════════════════════════════════════════════════════════

  Future<bool> hasUserUsedCoupon({
    required int couponId,
    required int userId,
  }) async {
    try {
      return await couponRepository.hasUserUsedCoupon(
        couponId: couponId,
        userId: userId,
      );
    } catch (e) {
      return false;
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// التحقق من الكوبون وتطبيقه
  /// ═══════════════════════════════════════════════════════════════

  // Future<bool> validateAndApplyCoupon({
  //   required String code,
  //   required int userId,
  //   required double amount,
  //   bool isVip = false,
  // }) async {
  //   if (code.trim().isEmpty) {
  //     _error = 'يرجى إدخال كود الكوبون';
  //     notifyListeners();
  //     return false;
  //   }
  //
  //   _isLoading = true;
  //   _error = null;
  //   notifyListeners();
  //
  //   try {
  //     print('🔍 Validating coupon: ${code.trim().toUpperCase()}');
  //
  //     _validationResult = await couponRepository.validateCoupon(
  //       code: code.trim().toUpperCase(),
  //       userId: userId,
  //       amount: amount,
  //       isVip: isVip,
  //     );
  //
  //     print('📊 Validation result: ${_validationResult?.valid}');
  //
  //     if (_validationResult!.valid) {
  //       _appliedCoupon = await couponRepository.getCouponByCode(code.trim().toUpperCase());
  //       _discountAmount = _validationResult!.discountAmount;
  //       _error = null;
  //
  //       print('✅ Coupon applied: ${_appliedCoupon?.code}');
  //       print('💰 Discount amount: $_discountAmount');
  //
  //       _isLoading = false;
  //       notifyListeners();
  //       return true;
  //     } else {
  //       _error = _validationResult!.message;
  //       _appliedCoupon = null;
  //       _discountAmount = null;
  //
  //       print('❌ Validation failed: ${_validationResult!.message}');
  //
  //       _isLoading = false;
  //       notifyListeners();
  //       return false;
  //     }
  //   } catch (e) {
  //     _error = 'حدث خطأ أثناء التحقق من الكوبون: ${e.toString()}';
  //     _appliedCoupon = null;
  //     _discountAmount = null;
  //
  //     print('❌ Error validating coupon: $e');
  //
  //     _isLoading = false;
  //     notifyListeners();
  //     return false;
  //   }
  // }

  Future<bool> validateAndApplyCoupon({
    required String code,
    required int userId,
    required double amount,
    bool isVip = false,
  }) async {
    if (code.trim().isEmpty) {
      _error = 'يرجى إدخال كود الكوبون';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {

      _validationResult = await couponRepository.validateCoupon(
        code: code.trim().toUpperCase(),
        userId: userId,
        amount: amount,
        isVip: isVip,
      );


      if (_validationResult!.valid) {
        _appliedCoupon = await couponRepository.getCouponByCode(code.trim().toUpperCase());
        _discountAmount = _validationResult!.discountAmount;
        _error = null;


        // ✅ إضافة: تحديث used_count في قاعدة البيانات
        if (_appliedCoupon != null && _appliedCoupon!.id != null) {
          try {
            final currentUsedCount = _appliedCoupon!.usedCount ?? 0;
            final newUsedCount = currentUsedCount + 1;

            await _supabase
                .from('coupons')
                .update({
              'used_count': newUsedCount,
              'updated_at': DateTime.now().toIso8601String(),
            })
                .eq('id', _appliedCoupon!.id!);

          } catch (e) {
            // لا نفشل العملية بسبب هذا الخطأ
          }
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = _validationResult!.message;
        _appliedCoupon = null;
        _discountAmount = null;


        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء التحقق من الكوبون: ${e.toString()}';
      _appliedCoupon = null;
      _discountAmount = null;


      _isLoading = false;
      notifyListeners();
      return false;
    }
  }


  /// ═══════════════════════════════════════════════════════════════
  /// إزالة الكوبون المطبق
  /// ═══════════════════════════════════════════════════════════════

  void removeCoupon() {
    _appliedCoupon = null;
    _validationResult = null;
    _discountAmount = null;
    _error = null;
    notifyListeners();
  }

  /// ═══════════════════════════════════════════════════════════════
  /// تسجيل استخدام الكوبون
  /// ═══════════════════════════════════════════════════════════════

  Future<bool> useCoupon({
    required int appointmentId,
    required int userId,
  }) async {
    if (_appliedCoupon == null || _validationResult == null) {
      return false;
    }

    try {

      final success = await couponRepository.useCoupon(
        couponId: _validationResult!.couponId!,
        userId: userId,
        appointmentId: appointmentId,
        discountAmount: _discountAmount!,
      );

      if (success) {
        removeCoupon();
      } else {
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// حساب السعر النهائي بعد الخصم
  /// ═══════════════════════════════════════════════════════════════

  double calculateFinalPrice(double originalPrice) {
    if (_discountAmount == null || _discountAmount! <= 0) {
      return originalPrice;
    }

    final finalPrice = originalPrice - _discountAmount!;
    return finalPrice > 0 ? finalPrice : 0;
  }

  /// ═══════════════════════════════════════════════════════════════
  /// جلب كوبونات VIP
  /// ═══════════════════════════════════════════════════════════════

  Future<void> fetchVipCoupons() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _coupons = await couponRepository.getVipCoupons();
    } catch (e) {
      _error = 'فشل تحميل كوبونات VIP';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// Realtime Subscription
  /// ═══════════════════════════════════════════════════════════════

  void subscribeToActiveCoupons() {
    unsubscribeFromCoupons();


    _realtimeChannel = _supabase
        .channel('coupons_changes')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'coupons',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'is_active',
        value: true,
      ),
      callback: (payload) {
        fetchActiveCoupons();
      },
    )
        .subscribe();
  }

  void unsubscribeFromCoupons() {
    if (_realtimeChannel != null) {
      _realtimeChannel!.unsubscribe();
      _realtimeChannel = null;
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// مسح البيانات
  /// ═══════════════════════════════════════════════════════════════

  void clear() {
    _coupons = [];
    _appliedCoupon = null;
    _validationResult = null;
    _discountAmount = null;
    _error = null;
    unsubscribeFromCoupons();
    notifyListeners();
  }

  @override
  void dispose() {
    unsubscribeFromCoupons();
    super.dispose();
  }
}