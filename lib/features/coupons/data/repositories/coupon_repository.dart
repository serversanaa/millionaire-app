// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../domain/models/coupon_model.dart';
//
// /// ═══════════════════════════════════════════════════════════════
// /// Coupon Repository - مستودع إدارة الكوبونات الشامل
// /// ═══════════════════════════════════════════════════════════════
//
// class CouponRepository {
//   final SupabaseClient _supabase = Supabase.instance.client;
//
//   /// ═══════════════════════════════════════════════════════════════
//   /// التحقق الشامل من الكوبون
//   /// ═══════════════════════════════════════════════════════════════
//
//   Future<CouponValidationResult> validateCoupon({
//     required String code,
//     required int userId,
//     required double amount,
//     bool isVip = false,
//   }) async {
//     try {
//       print('🔍 Repository: Validating coupon $code for user $userId');
//
//       // 1️⃣ جلب الكوبون من قاعدة البيانات
//       final response = await _supabase
//           .from('coupons')
//           .select()
//           .eq('code', code)
//           .maybeSingle();
//
//       if (response == null) {
//         return CouponValidationResult(
//           valid: false,
//           message: 'كود الكوبون غير موجود',
//         );
//       }
//
//       final coupon = CouponModel.fromJson(response as Map<String, dynamic>);
//       print('✅ Coupon found: ${coupon.code} (ID: ${coupon.id})');
//
//       // 2️⃣ التحقق من حالة الكوبون
//       if (!coupon.isActive) {
//         return CouponValidationResult(
//           valid: false,
//           message: 'الكوبون غير نشط',
//         );
//       }
//
//       // 3️⃣ التحقق من التواريخ (UTC)
//       final nowUtc = DateTime.now().toUtc();
//       final startDateUtc = coupon.startDate.toUtc();
//       final endDateUtc = coupon.endDate.toUtc();
//
//       print('📅 Date validation (UTC):');
//       print('   Now: $nowUtc');
//       print('   Start: $startDateUtc');
//       print('   End: $endDateUtc');
//       print('   Minutes from start: ${nowUtc.difference(startDateUtc).inMinutes}');
//       print('   Is valid time: ${nowUtc.isAfter(startDateUtc) && nowUtc.isBefore(endDateUtc)}');
//
//       if (nowUtc.isBefore(startDateUtc)) {
//         final minutesUntilStart = startDateUtc.difference(nowUtc).inMinutes;
//         return CouponValidationResult(
//           valid: false,
//           message: 'الكوبون لم يبدأ بعد (يبدأ بعد $minutesUntilStart دقيقة)',
//         );
//       }
//
//       if (nowUtc.isAfter(endDateUtc)) {
//         return CouponValidationResult(
//           valid: false,
//           message: 'الكوبون منتهي الصلاحية',
//         );
//       }
//
//       // 4️⃣ التحقق من VIP
//       if (coupon.isVipOnly && !isVip) {
//         return CouponValidationResult(
//           valid: false,
//           message: 'هذا الكوبون للأعضاء VIP فقط',
//         );
//       }
//
//       // 5️⃣ التحقق من الحد الأدنى للمبلغ
//       if (amount < coupon.minAmount) {
//         return CouponValidationResult(
//           valid: false,
//           message: 'الحد الأدنى للمبلغ هو ${coupon.minAmount.toStringAsFixed(0)} ريال',
//         );
//       }
//
//       // 6️⃣ التحقق من الاستخدام الكلي للكوبون
//       if (coupon.usageLimit != null && coupon.usageLimit! > 0) {
//         try {
//           final totalUsageResponse = await _supabase
//               .from('coupon_usages')
//               .select('id')
//               .eq('coupon_id', coupon.id!);
//
//           final totalUsageCount = (totalUsageResponse as List).length;
//
//           print('📊 Total usage: $totalUsageCount / ${coupon.usageLimit}');
//
//           if (totalUsageCount >= coupon.usageLimit!) {
//             return CouponValidationResult(
//               valid: false,
//               message: 'تم استخدام الكوبون بالكامل',
//             );
//           }
//         } catch (e) {
//           print('⚠️ Could not check total usage count: $e');
//         }
//       }
//
//       // 7️⃣ التحقق من استخدام المستخدم للكوبون (الأهم)
//       try {
//         final userUsageResponse = await _supabase
//             .from('coupon_usages')
//             .select('id')
//             .eq('coupon_id', coupon.id!)
//             .eq('user_id', userId);
//
//         final userUsageCount = (userUsageResponse as List).length;
//
//         print('👤 User usage: $userUsageCount / ${coupon.usagePerUser}');
//
//         if (userUsageCount >= coupon.usagePerUser) {
//           return CouponValidationResult(
//             valid: false,
//             message: 'لقد استخدمت هذا الكوبون من قبل',
//           );
//         }
//       } catch (e) {
//         print('⚠️ Could not check user usage count: $e');
//       }
//
//       // 8️⃣ حساب قيمة الخصم
//       double discountAmount = 0;
//
//       if (coupon.discountType == 'percentage') {
//         discountAmount = amount * (coupon.discountValue / 100);
//
//         if (coupon.maxDiscount != null && discountAmount > coupon.maxDiscount!) {
//           discountAmount = coupon.maxDiscount!;
//         }
//       } else if (coupon.discountType == 'fixed') {
//         discountAmount = coupon.discountValue;
//       }
//
//       if (discountAmount > amount) {
//         discountAmount = amount;
//       }
//
//       final finalAmount = amount - discountAmount;
//
//       print('✅ Coupon valid!');
//       print('   Discount: $discountAmount');
//       print('   Final amount: $finalAmount');
//
//       return CouponValidationResult(
//         valid: true,
//         message: 'تم التحقق من الكوبون بنجاح',
//         couponId: coupon.id,
//         discountType: coupon.discountType,
//         discountValue: coupon.discountValue,
//         discountAmount: discountAmount,
//         finalAmount: finalAmount,
//       );
//
//     } catch (e) {
//       print('❌ Error validating coupon: $e');
//       return CouponValidationResult(
//         valid: false,
//         message: 'حدث خطأ أثناء التحقق من الكوبون',
//       );
//     }
//   }
//
//   /// ═══════════════════════════════════════════════════════════════
//   /// جلب الكوبون بالكود
//   /// ═══════════════════════════════════════════════════════════════
//
//   Future<CouponModel?> getCouponByCode(String code) async {
//     try {
//       print('🔍 Fetching coupon by code: $code');
//
//       final response = await _supabase
//           .from('coupons')
//           .select()
//           .eq('code', code)
//           .maybeSingle();
//
//       if (response != null) {
//         final coupon = CouponModel.fromJson(response as Map<String, dynamic>);
//         print('✅ Coupon found: ${coupon.code}');
//         return coupon;
//       }
//
//       print('❌ Coupon not found');
//       return null;
//     } catch (e) {
//       print('❌ Error fetching coupon: $e');
//       return null;
//     }
//   }
//
//   /// ═══════════════════════════════════════════════════════════════
//   /// جلب الكوبون بالـ ID
//   /// ═══════════════════════════════════════════════════════════════
//
//   Future<CouponModel?> getCouponById(int id) async {
//     try {
//       print('🔍 Fetching coupon by ID: $id');
//
//       final response = await _supabase
//           .from('coupons')
//           .select()
//           .eq('id', id)
//           .maybeSingle();
//
//       if (response != null) {
//         final coupon = CouponModel.fromJson(response as Map<String, dynamic>);
//         print('✅ Coupon found: ${coupon.code}');
//         return coupon;
//       }
//
//       print('❌ Coupon not found');
//       return null;
//     } catch (e) {
//       print('❌ Error fetching coupon: $e');
//       return null;
//     }
//   }
//
//   /// ═══════════════════════════════════════════════════════════════
//   /// تسجيل استخدام الكوبون
//   /// ═══════════════════════════════════════════════════════════════
//
//   Future<bool> useCoupon({
//     required int couponId,
//     required int userId,
//     required int appointmentId,
//     required double discountAmount,
//   }) async {
//     try {
//       print('📝 Recording coupon usage:');
//       print('   Coupon ID: $couponId');
//       print('   User ID: $userId');
//       print('   Appointment ID: $appointmentId');
//       print('   Discount: $discountAmount');
//
//       await _supabase.from('coupon_usages').insert({
//         'coupon_id': couponId,
//         'user_id': userId,
//         'appointment_id': appointmentId,
//         'discount_amount': discountAmount,
//         'used_at': DateTime.now().toUtc().toIso8601String(),
//       });
//
//       print('✅ Coupon usage recorded successfully');
//       return true;
//     } catch (e) {
//       print('❌ Error recording coupon usage: $e');
//       return false;
//     }
//   }
//
//   /// ═══════════════════════════════════════════════════════════════
//   /// جلب الكوبونات النشطة
//   /// ═══════════════════════════════════════════════════════════════
//
//   Future<List<CouponModel>> getActiveCoupons() async {
//     try {
//       print('🔍 Fetching active coupons...');
//
//       final response = await _supabase
//           .from('coupons')
//           .select()
//           .eq('is_active', true)
//           .gte('end_date', DateTime.now().toUtc().toIso8601String())
//           .order('created_at', ascending: false);
//
//       final List<dynamic> data = response as List<dynamic>;
//
//       final coupons = data
//           .map((json) => CouponModel.fromJson(json as Map<String, dynamic>))
//           .toList();
//
//       print('✅ Found ${coupons.length} active coupons');
//
//       return coupons;
//     } catch (e) {
//       print('❌ Error fetching active coupons: $e');
//       return [];
//     }
//   }
//
//   /// ═══════════════════════════════════════════════════════════════
//   /// جلب كوبونات VIP
//   /// ═══════════════════════════════════════════════════════════════
//
//   Future<List<CouponModel>> getVipCoupons() async {
//     try {
//       print('🔍 Fetching VIP coupons...');
//
//       final response = await _supabase
//           .from('coupons')
//           .select()
//           .eq('is_active', true)
//           .eq('is_vip_only', true)
//           .gte('end_date', DateTime.now().toUtc().toIso8601String())
//           .order('created_at', ascending: false);
//
//       final List<dynamic> data = response as List<dynamic>;
//
//       final coupons = data
//           .map((json) => CouponModel.fromJson(json as Map<String, dynamic>))
//           .toList();
//
//       print('✅ Found ${coupons.length} VIP coupons');
//
//       return coupons;
//     } catch (e) {
//       print('❌ Error fetching VIP coupons: $e');
//       return [];
//     }
//   }
//
//   /// ═══════════════════════════════════════════════════════════════
//   /// التحقق من استخدام المستخدم لكوبون معين
//   /// ═══════════════════════════════════════════════════════════════
//
//   Future<bool> hasUserUsedCoupon({
//     required int couponId,
//     required int userId,
//   }) async {
//     try {
//       print('🔍 Checking if user $userId used coupon $couponId...');
//
//       final response = await _supabase
//           .from('coupon_usages')
//           .select('id')
//           .eq('coupon_id', couponId)
//           .eq('user_id', userId);
//
//       final usageCount = (response as List).length;
//
//       print('📊 User $userId has used coupon $couponId: $usageCount times');
//
//       return usageCount > 0;
//     } catch (e) {
//       print('❌ Error checking user coupon usage: $e');
//       return false;
//     }
//   }
//
//   /// ═══════════════════════════════════════════════════════════════
//   /// عرض الكوبونات المتاحة للمستخدم (لم يستخدمها بعد)
//   /// ═══════════════════════════════════════════════════════════════
//
//   Future<List<CouponModel>> getAvailableCouponsForUser(int userId) async {
//     try {
//       print('🔍 Fetching available coupons for user $userId...');
//
//       // 1️⃣ جلب جميع الكوبونات النشطة
//       final couponsResponse = await _supabase
//           .from('coupons')
//           .select()
//           .eq('is_active', true)
//           .gte('end_date', DateTime.now().toUtc().toIso8601String())
//           .order('created_at', ascending: false);
//
//       final List<dynamic> couponsData = couponsResponse as List<dynamic>;
//       final List<CouponModel> allCoupons = couponsData
//           .map((json) => CouponModel.fromJson(json as Map<String, dynamic>))
//           .toList();
//
//       print('📊 Total active coupons: ${allCoupons.length}');
//
//       // 2️⃣ جلب الكوبونات التي استخدمها المستخدم
//       final usedCouponsResponse = await _supabase
//           .from('coupon_usages')
//           .select('coupon_id')
//           .eq('user_id', userId);
//
//       final List<dynamic> usedData = usedCouponsResponse as List<dynamic>;
//       final Set<int> usedCouponIds = usedData
//           .map((item) => item['coupon_id'] as int)
//           .toSet();
//
//       print('📊 User $userId used coupons: $usedCouponIds');
//
//       // 3️⃣ فلترة الكوبونات المتاحة
//       final availableCoupons = allCoupons.where((coupon) {
//         // تحقق من أن الكوبون صالح
//         if (!coupon.isValid) {
//           print('   ❌ Coupon ${coupon.code} is not valid');
//           return false;
//         }
//
//         // تحقق من أن المستخدم لم يستخدمه
//         if (coupon.id != null && usedCouponIds.contains(coupon.id!)) {
//           print('   ❌ User already used coupon ${coupon.code}');
//           return false;
//         }
//
//         print('   ✅ Coupon ${coupon.code} is available');
//         return true;
//       }).toList();
//
//       print('✅ Available coupons for user $userId: ${availableCoupons.length}');
//
//       return availableCoupons;
//     } catch (e) {
//       print('❌ Error fetching available coupons for user: $e');
//       return [];
//     }
//   }
//
//   /// ═══════════════════════════════════════════════════════════════
//   /// جلب سجل استخدام الكوبونات للمستخدم
//   /// ═══════════════════════════════════════════════════════════════
//
//   Future<List<Map<String, dynamic>>> getUserCouponHistory(int userId) async {
//     try {
//       print('🔍 Fetching coupon history for user $userId...');
//
//       final response = await _supabase
//           .from('coupon_usages')
//           .select('*, coupons(code, discount_type, discount_value)')
//           .eq('user_id', userId)
//           .order('used_at', ascending: false);
//
//       final List<dynamic> data = response as List<dynamic>;
//
//       print('✅ Found ${data.length} usage records');
//
//       return data.map((item) => item as Map<String, dynamic>).toList();
//     } catch (e) {
//       print('❌ Error fetching user coupon history: $e');
//       return [];
//     }
//   }
//
//   /// ═══════════════════════════════════════════════════════════════
//   /// إحصائيات استخدام الكوبون
//   /// ═══════════════════════════════════════════════════════════════
//
//   Future<Map<String, int>> getCouponUsageStats(int couponId) async {
//     try {
//       print('🔍 Fetching usage stats for coupon $couponId...');
//
//       final response = await _supabase
//           .from('coupon_usages')
//           .select('id, user_id')
//           .eq('coupon_id', couponId);
//
//       final List<dynamic> data = response as List<dynamic>;
//
//       final totalUsage = data.length;
//       final uniqueUsers = data.map((item) => item['user_id']).toSet().length;
//
//       print('📊 Coupon stats:');
//       print('   Total usage: $totalUsage');
//       print('   Unique users: $uniqueUsers');
//
//       return {
//         'total_usage': totalUsage,
//         'unique_users': uniqueUsers,
//       };
//     } catch (e) {
//       print('❌ Error fetching coupon usage stats: $e');
//       return {
//         'total_usage': 0,
//         'unique_users': 0,
//       };
//     }
//   }
//
//   /// ═══════════════════════════════════════════════════════════════
//   /// حساب إجمالي الخصم الذي حصل عليه المستخدم
//   /// ═══════════════════════════════════════════════════════════════
//
//   Future<double> getTotalUserSavings(int userId) async {
//     try {
//       print('🔍 Calculating total savings for user $userId...');
//
//       final response = await _supabase
//           .from('coupon_usages')
//           .select('discount_amount')
//           .eq('user_id', userId);
//
//       final List<dynamic> data = response as List<dynamic>;
//
//       double totalSavings = 0;
//       for (var item in data) {
//         totalSavings += (item['discount_amount'] as num).toDouble();
//       }
//
//       print('💰 Total user savings: $totalSavings SAR');
//
//       return totalSavings;
//     } catch (e) {
//       print('❌ Error calculating total user savings: $e');
//       return 0;
//     }
//   }
//
//   /// ═══════════════════════════════════════════════════════════════
//   /// البحث عن كوبونات
//   /// ═══════════════════════════════════════════════════════════════
//
//   Future<List<CouponModel>> searchCoupons(String query) async {
//     try {
//       print('🔍 Searching coupons with query: $query');
//
//       final response = await _supabase
//           .from('coupons')
//           .select()
//           .eq('is_active', true)
//           .or('code.ilike.%$query%,description_ar.ilike.%$query%')
//           .order('created_at', ascending: false);
//
//       final List<dynamic> data = response as List<dynamic>;
//
//       final coupons = data
//           .map((json) => CouponModel.fromJson(json as Map<String, dynamic>))
//           .toList();
//
//       print('✅ Found ${coupons.length} coupons matching "$query"');
//
//       return coupons;
//     } catch (e) {
//       print('❌ Error searching coupons: $e');
//       return [];
//     }
//   }
// }



import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/coupon_model.dart';

/// ═══════════════════════════════════════════════════════════════
/// Coupon Repository - مستودع إدارة الكوبونات الشامل مع المعالم
/// ═══════════════════════════════════════════════════════════════

class CouponRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// ═══════════════════════════════════════════════════════════════
  /// جلب كوبونات المعالم للمستخدم
  /// ═══════════════════════════════════════════════════════════════

  Future<List<CouponModel>> getMilestoneCoupons(int userId) async {
    try {

      final response = await _supabase.rpc(
        'get_user_milestone_coupons',
        params: {'p_user_id': userId},
      );

      if (response is List) {
        final coupons = response
            .map((json) => CouponModel.fromMilestoneCoupon(
            json as Map<String, dynamic>))
            .toList();

        return coupons;
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// جلب كوبونات المستخدم (من جدول coupons)
  /// ═══════════════════════════════════════════════════════════════

  Future<List<CouponModel>> getUserCoupons(int userId) async {
    try {

      final response = await _supabase
          .from('coupons')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .gte('end_date', DateTime.now().toUtc().toIso8601String())
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;

      final coupons = data
          .map((json) => CouponModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return coupons;
    } catch (e) {
      return [];
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// جلب جميع كوبونات المستخدم (معالم + عادية)
  /// ═══════════════════════════════════════════════════════════════

  Future<List<CouponModel>> getAllUserCoupons(int userId) async {
    try {

      final results = await Future.wait([
        getMilestoneCoupons(userId),
        getUserCoupons(userId),
      ]);

      final allCoupons = [...results[0], ...results[1]];


      return allCoupons;
    } catch (e) {
      return [];
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// التحقق الشامل من الكوبون
  /// ═══════════════════════════════════════════════════════════════

  Future<CouponValidationResult> validateCoupon({
    required String code,
    required int userId,
    required double amount,
    bool isVip = false,
  }) async {
    try {

      // 1️⃣ جلب الكوبون من قاعدة البيانات
      final response = await _supabase
          .from('coupons')
          .select()
          .eq('code', code)
          .maybeSingle();

      if (response == null) {
        return CouponValidationResult(
          valid: false,
          message: 'كود الكوبون غير موجود',
        );
      }

      final coupon = CouponModel.fromJson(response as Map<String, dynamic>);

      // 2️⃣ التحقق من حالة الكوبون
      if (!coupon.isActive) {
        return CouponValidationResult(
          valid: false,
          message: 'الكوبون غير نشط',
        );
      }

      // 3️⃣ التحقق من التواريخ (UTC)
      final nowUtc = DateTime.now().toUtc();
      final startDateUtc = coupon.startDate.toUtc();
      final endDateUtc = coupon.endDate.toUtc();

      if (nowUtc.isBefore(startDateUtc)) {
        return CouponValidationResult(
          valid: false,
          message: 'الكوبون لم يبدأ بعد',
        );
      }

      if (nowUtc.isAfter(endDateUtc)) {
        return CouponValidationResult(
          valid: false,
          message: 'الكوبون منتهي الصلاحية',
        );
      }

      // 4️⃣ التحقق من أن الكوبون خاص بهذا المستخدم (إذا كان محدد)
      if (coupon.userId != null && coupon.userId != userId) {
        return CouponValidationResult(
          valid: false,
          message: 'هذا الكوبون خاص بمستخدم آخر',
        );
      }

      // 5️⃣ التحقق من VIP
      if (coupon.isVipOnly && !isVip) {
        return CouponValidationResult(
          valid: false,
          message: 'هذا الكوبون للأعضاء VIP فقط',
        );
      }

      // 6️⃣ التحقق من الحد الأدنى للمبلغ
      if (amount < coupon.minAmount) {
        return CouponValidationResult(
          valid: false,
          message: 'الحد الأدنى للمبلغ هو ${coupon.minAmount.toStringAsFixed(0)} ريال',
        );
      }

      // 7️⃣ التحقق من الاستخدام الكلي للكوبون
      if (coupon.usageLimit != null && coupon.usageLimit! > 0) {
        final totalUsageResponse = await _supabase
            .from('coupon_usages')
            .select('id')
            .eq('coupon_id', coupon.id!);

        final totalUsageCount = (totalUsageResponse as List).length;

        if (totalUsageCount >= coupon.usageLimit!) {
          return CouponValidationResult(
            valid: false,
            message: 'تم استخدام الكوبون بالكامل',
          );
        }
      }

      // 8️⃣ التحقق من استخدام المستخدم للكوبون
      final userUsageResponse = await _supabase
          .from('coupon_usages')
          .select('id')
          .eq('coupon_id', coupon.id!)
          .eq('user_id', userId);

      final userUsageCount = (userUsageResponse as List).length;

      if (coupon.isUsed ?? false) {
        return CouponValidationResult(
          valid: false,
          message: 'لقد استخدمت هذا الكوبون من قبل',
        );
      }

      // 9️⃣ حساب قيمة الخصم
      double discountAmount = 0;

      if (coupon.discountType == 'percentage') {
        discountAmount = amount * (coupon.discountValue / 100);
        if (coupon.maxDiscount != null && discountAmount > coupon.maxDiscount!) {
          discountAmount = coupon.maxDiscount!;
        }
      } else if (coupon.discountType == 'fixed') {
        discountAmount = coupon.discountValue;
      }

      if (discountAmount > amount) {
        discountAmount = amount;
      }

      final finalAmount = amount - discountAmount;


      return CouponValidationResult(
        valid: true,
        message: 'تم التحقق من الكوبون بنجاح',
        couponId: coupon.id,
        discountType: coupon.discountType,
        discountValue: coupon.discountValue,
        discountAmount: discountAmount,
        finalAmount: finalAmount,
        coupon: coupon,
      );

    } catch (e) {
      return CouponValidationResult(
        valid: false,
        message: 'حدث خطأ أثناء التحقق من الكوبون',
      );
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// جلب الكوبون بالكود
  /// ═══════════════════════════════════════════════════════════════

  Future<CouponModel?> getCouponByCode(String code) async {
    try {

      final response = await _supabase
          .from('coupons')
          .select()
          .eq('code', code)
          .maybeSingle();

      if (response != null) {
        final coupon = CouponModel.fromJson(response as Map<String, dynamic>);
        return coupon;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// جلب الكوبون بالـ ID
  /// ═══════════════════════════════════════════════════════════════

  Future<CouponModel?> getCouponById(int id) async {
    try {

      final response = await _supabase
          .from('coupons')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response != null) {
        final coupon = CouponModel.fromJson(response as Map<String, dynamic>);
        return coupon;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// تسجيل استخدام الكوبون
  /// ═══════════════════════════════════════════════════════════════

  Future<bool> useCoupon({
    required int couponId,
    required int userId,
    required int appointmentId,
    required double discountAmount,
  }) async {
    try {

      await _supabase.from('coupon_usages').insert({
        'coupon_id': couponId,
        'user_id': userId,
        'appointment_id': appointmentId,
        'discount_amount': discountAmount,
        'used_at': DateTime.now().toUtc().toIso8601String(),
      });

      // ✅ تحديث حالة الكوبون في user_milestone_achievements
      await _supabase
          .from('user_milestone_achievements')
          .update({'is_used': true})
          .eq('coupon_id', couponId)
          .eq('user_id', userId);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// جلب الكوبونات النشطة العامة
  /// ═══════════════════════════════════════════════════════════════

  Future<List<CouponModel>> getActiveCoupons() async {
    try {

      final response = await _supabase
          .from('coupons')
          .select()
          .eq('is_active', true)
          .isFilter('user_id', null)
          .gte('end_date', DateTime.now().toUtc().toIso8601String())
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;

      final coupons = data
          .map((json) => CouponModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return coupons;
    } catch (e) {
      return [];
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// جلب كوبونات VIP
  /// ═══════════════════════════════════════════════════════════════

  Future<List<CouponModel>> getVipCoupons() async {
    try {

      final response = await _supabase
          .from('coupons')
          .select()
          .eq('is_active', true)
          .eq('is_vip_only', true)
          .gte('end_date', DateTime.now().toUtc().toIso8601String())
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;

      final coupons = data
          .map((json) => CouponModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return coupons;
    } catch (e) {
      return [];
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// التحقق من استخدام المستخدم لكوبون معين
  /// ═══════════════════════════════════════════════════════════════

  Future<bool> hasUserUsedCoupon({
    required int couponId,
    required int userId,
  }) async {
    try {
      final response = await _supabase
          .from('coupon_usages')
          .select('id')
          .eq('coupon_id', couponId)
          .eq('user_id', userId);

      return (response as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// عرض الكوبونات المتاحة للمستخدم (لم يستخدمها + صالحة)
  /// ═══════════════════════════════════════════════════════════════

  Future<List<CouponModel>> getAvailableCouponsForUser(int userId) async {
    try {

      // جلب جميع كوبونات المستخدم
      final allCoupons = await getAllUserCoupons(userId);

      // فلترة الكوبونات المتاحة فقط
      final available = allCoupons.where((c) => c.canUse).toList();

      return available;
    } catch (e) {
      return [];
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// جلب سجل استخدام الكوبونات للمستخدم
  /// ═══════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getUserCouponHistory(int userId) async {
    try {

      final response = await _supabase
          .from('coupon_usages')
          .select('*, coupons(code, discount_type, discount_value)')
          .eq('user_id', userId)
          .order('used_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;

      return data.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// إحصائيات استخدام الكوبون
  /// ═══════════════════════════════════════════════════════════════

  Future<Map<String, int>> getCouponUsageStats(int couponId) async {
    try {
      final response = await _supabase
          .from('coupon_usages')
          .select('id, user_id')
          .eq('coupon_id', couponId);

      final List<dynamic> data = response as List<dynamic>;

      return {
        'total_usage': data.length,
        'unique_users': data.map((item) => item['user_id']).toSet().length,
      };
    } catch (e) {
      return {'total_usage': 0, 'unique_users': 0};
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// حساب إجمالي الخصم الذي حصل عليه المستخدم
  /// ═══════════════════════════════════════════════════════════════

  Future<double> getTotalUserSavings(int userId) async {
    try {
      final response = await _supabase
          .from('coupon_usages')
          .select('discount_amount')
          .eq('user_id', userId);

      final List<dynamic> data = response as List<dynamic>;

      double total = 0;
      for (var item in data) {
        total += (item['discount_amount'] as num).toDouble();
      }

      return total;
    } catch (e) {
      return 0;
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// البحث عن كوبونات
  /// ═══════════════════════════════════════════════════════════════

  Future<List<CouponModel>> searchCoupons(String query) async {
    try {

      final response = await _supabase
          .from('coupons')
          .select()
          .eq('is_active', true)
          .or('code.ilike.%$query%,description_ar.ilike.%$query%')
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;

      final coupons = data
          .map((json) => CouponModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return coupons;
    } catch (e) {
      return [];
    }
  }
}
