// // lib/features/packages/data/repositories/package_subscription_repository.dart
//
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import '../../domain/models/package_subscription_model.dart';
// // import '../../domain/models/package_model.dart';
// //
// // /// مستودع اشتراكات الباقات
// // class PackageSubscriptionRepository {
// //   final SupabaseClient _supabase = Supabase.instance.client;
// //
// //   // ═══════════════════════════════════════════════════════════════
// //   // ✅ الاشتراك في باقة جديدة
// //   // ═══════════════
// //   Future<PackageSubscriptionModel> subscribeToPackage({
// //     required String userId,
// //     required PackageModel package,
// //     required String paymentMethod,
// //   }) async {
// //     try {
// //       // ✅ البيانات الأساسية فقط (الـ Trigger سيملأ الباقي)
// //       final subscriptionData = {
// //         'user_id': int.parse(userId),
// //         'package_id': package.id,
// //         'payment_method': paymentMethod,
// //         // الباقي سيتم ملؤه تلقائياً من الـ Trigger
// //       };
// //
// //       final response = await _supabase
// //           .from('package_subscriptions')
// //           .insert(subscriptionData)
// //           .select('*, packages(*)')
// //           .single();
// //
// //       return PackageSubscriptionModel.fromJson(response);
// //     } catch (e) {
// //       rethrow;
// //     }
// //   }
// //
// //
// //
// //   // ═══════════════════════════════════════════════════════════════
// //   // 📋 جلب اشتراكات المستخدم
// //   // ═══════════════════════════════════════════════════════════════
// //   Future<List<PackageSubscriptionModel>> getUserSubscriptions(
// //       String userId, {
// //         String? status,
// //         bool includePackageDetails = false,
// //       }) async {
// //     try {
// //       final userIdInt = int.tryParse(userId);
// //       if (userIdInt == null) {
// //         return [];
// //       }
// //
// //       // ✅ جلب الاشتراكات مع package وخدماتها
// //       var query = _supabase
// //           .from('package_subscriptions')
// //           .select(includePackageDetails
// //           ? '*, packages(*, package_services(*))'
// //           : '*')
// //           .eq('user_id', userIdInt);
// //
// //       if (status != null) {
// //         query = query.eq('status', status);
// //       }
// //
// //       final response = await query.order('created_at', ascending: false);
// //
// //       final subscriptions = (response as List).map((json) {
// //         return PackageSubscriptionModel.fromJson(json as Map<String, dynamic>);
// //       }).toList();
// //
// //
// //       for (var sub in subscriptions) {
// //         if (sub.package != null) {
// //         }
// //       }
// //
// //       return subscriptions;
// //     } catch (e) {
// //       return [];
// //     }
// //   }
// //
// //   /// جلب الاشتراكات النشطة فقط
// //   Future<List<PackageSubscriptionModel>> getUserActiveSubscriptions(
// //       String userId, {
// //         bool includePackageDetails = true,
// //       }) async {
// //     try {
// //       final response = await _supabase
// //           .from('package_subscriptions')
// //           .select(includePackageDetails ? '*, packages(*)' : '*')
// //           .eq('user_id', userId)
// //           .eq('status', 'active')
// //           .gt('end_date', DateTime.now().toIso8601String())
// //           .gt('remaining_sessions', 0)
// //           .order('created_at', ascending: false);
// //
// //       return (response as List)
// //           .map((json) => PackageSubscriptionModel.fromJson(
// //         json as Map<String, dynamic>,
// //       ))
// //           .toList();
// //     } catch (e) {
// //       return [];
// //     }
// //   }
// //
// //   // ═══════════════════════════════════════════════════════════════
// //   // 🔍 جلب اشتراك محدد
// //   // ═══════════════════════════════════════════════════════════════
// //
// //   Future<PackageSubscriptionModel?> getSubscriptionById(
// //       int id, {
// //         bool includePackageDetails = true,
// //       }) async {
// //     try {
// //       final response = await _supabase
// //           .from('package_subscriptions')
// //           .select(includePackageDetails ? '*, packages(*)' : '*')
// //           .eq('id', id)
// //           .single();
// //
// //       return PackageSubscriptionModel.fromJson(
// //         response as Map<String, dynamic>,
// //       );
// //     } catch (e) {
// //       return null;
// //     }
// //   }
// //
// //   // ═══════════════════════════════════════════════════════════════
// //   // ✅ التحقق من الاشتراك النشط
// //   // ═══════════════════════════════════════════════════════════════
// //
// //   /// هل لدى المستخدم اشتراك نشط في باقة محددة؟
// //   Future<bool> hasActivePackageSubscription(
// //       String userId,
// //       int packageId,
// //       ) async {
// //     try {
// //       final response = await _supabase.rpc(
// //         'has_active_package_subscription',
// //         params: {
// //           'p_user_id': userId,
// //           'p_package_id': packageId,
// //         },
// //       );
// //       return response as bool;
// //     } catch (e) {
// //       return false;
// //     }
// //   }
// //
// //   /// هل لدى المستخدم أي اشتراك نشط؟
// //   Future<bool> hasAnyActiveSubscription(String userId) async {
// //     try {
// //       final subscriptions = await getUserActiveSubscriptions(userId);
// //       return subscriptions.isNotEmpty;
// //     } catch (e) {
// //       return false;
// //     }
// //   }
// //
// //   // ═══════════════════════════════════════════════════════════════
// //   // 📊 ملخص الاشتراكات
// //   // ═══════════════════════════════════════════════════════════════
// //   Future<Map<String, dynamic>> getUserSubscriptionsSummary(String userId) async {
// //     try {
// //       final userIdInt = int.parse(userId);
// //
// //       final response = await _supabase
// //           .rpc('get_user_subscriptions_summary', params: {'p_user_id': userIdInt});
// //
// //       if (response is Map<String, dynamic>) {
// //         return response;
// //       } else {
// //         return {};
// //       }
// //     } catch (e) {
// //       rethrow;
// //     }
// //   }
// //
// //
// //   // ═══════════════════════════════════════════════════════════════
// //   // ❌ إلغاء الاشتراك
// //   // ═══════════════════════════════════════════════════════════════
// //
// //   Future<Map<String, dynamic>?> cancelSubscription(
// //       int subscriptionId, {
// //         String? reason,
// //       }) async {
// //     try {
// //       final response = await _supabase.rpc(
// //         'cancel_package_subscription',
// //         params: {
// //           'p_subscription_id': subscriptionId,
// //           'p_reason': reason,
// //         },
// //       );
// //       return response as Map<String, dynamic>;
// //     } catch (e) {
// //       return null;
// //     }
// //   }
// //
// //   // ═══════════════════════════════════════════════════════════════
// //   // 🔄 تحديث الاشتراك
// //   // ═══════════════════════════════════════════════════════════════
// //
// //   Future<bool> updateSubscription(
// //       int subscriptionId,
// //       Map<String, dynamic> updates,
// //       ) async {
// //     try {
// //       await _supabase
// //           .from('package_subscriptions')
// //           .update(updates)
// //           .eq('id', subscriptionId);
// //       return true;
// //     } catch (e) {
// //       return false;
// //     }
// //   }
// //
// //   // ═══════════════════════════════════════════════════════════════
// //   // 🎫 استخدام جلسة
// //   // ═══════════════════════════════════════════════════════════════
// //
// //   Future<bool> useSession(int subscriptionId) async {
// //     try {
// //       final subscription = await getSubscriptionById(subscriptionId);
// //       if (subscription == null || !subscription.isActive) return false;
// //       if (subscription.remainingSessions <= 0) return false;
// //
// //       await _supabase.from('package_subscriptions').update({
// //         'remaining_sessions': subscription.remainingSessions - 1,
// //         'updated_at': DateTime.now().toIso8601String(),
// //       }).eq('id', subscriptionId);
// //
// //       return true;
// //     } catch (e) {
// //       return false;
// //     }
// //   }
// //
// //   // ═══════════════════════════════════════════════════════════════
// //   // 🔔 Real-time Subscriptions
// //   // ═══════════════════════════════════════════════════════════════
// //
// //   /// الاستماع المباشر لاشتراكات المستخدم
// //   Stream<List<PackageSubscriptionModel>> subscribeToUserSubscriptions(
// //       String userId,
// //       ) {
// //     return _supabase
// //         .from('package_subscriptions')
// //         .stream(primaryKey: ['id'])
// //         .order('created_at', ascending: false)
// //         .map((data) {
// //       return data
// //           .where((json) =>
// //       (json as Map<String, dynamic>)['user_id'] == userId)
// //           .map((json) => PackageSubscriptionModel.fromJson(
// //         json as Map<String, dynamic>,
// //       ))
// //           .toList();
// //     });
// //   }
// //
// //   /// الاستماع المباشر للاشتراكات النشطة
// //   Stream<List<PackageSubscriptionModel>> subscribeToActiveSubscriptions(
// //       String userId,
// //       ) {
// //     return _supabase
// //         .from('package_subscriptions')
// //         .stream(primaryKey: ['id'])
// //         .order('created_at', ascending: false)
// //         .map((data) {
// //       return data
// //           .where((json) {
// //         final map = json as Map<String, dynamic>;
// //         return map['user_id'] == userId && map['status'] == 'active';
// //       })
// //           .map((json) => PackageSubscriptionModel.fromJson(
// //         json as Map<String, dynamic>,
// //       ))
// //           .where((s) => s.isActive)
// //           .toList();
// //     });
// //   }
// //
// //   // ═══════════════════════════════════════════════════════════════
// //   // 📈 إحصائيات
// //   // ═══════════════════════════════════════════════════════════════
// //
// //   /// عدد الاشتراكات النشطة
// //   Future<int> getActiveSubscriptionsCount(String userId) async {
// //     final subscriptions = await getUserActiveSubscriptions(userId);
// //     return subscriptions.length;
// //   }
// //
// //   /// إجمالي المبلغ المنفق
// //   Future<double> getTotalSpentOnPackages(String userId) async {
// //     try {
// //       final summary = await getUserSubscriptionsSummary(userId);
// //       return (summary?['total_spent'] as num?)?.toDouble() ?? 0;
// //     } catch (e) {
// //       return 0;
// //     }
// //   }
// //
// //   /// إجمالي الجلسات المتبقية
// //   Future<int> getTotalRemainingSessions(String userId) async {
// //     final subscriptions = await getUserActiveSubscriptions(userId);
// //     return subscriptions.fold<int>(
// //       0,
// //           (sum, sub) => sum + sub.remainingSessions,
// //     );
// //   }
// // }
//
//
// import 'dart:io';
//
// import 'package:flutter/foundation.dart';
// import 'package:millionaire_barber/core/models/payment_result.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// import '../../domain/models/package_model.dart';
// import '../../domain/models/package_subscription_model.dart';
// import 'package:millionaire_barber/core/utils/receipt_compressor.dart';
// import '../../../packages/presentation/widgets/payment_sheet.dart';
//
// class PackageSubscriptionRepository {
//   final SupabaseClient _supabase = Supabase.instance.client;
//
//   static const String _storageBucket = 'package-subscription-receipts';
//
//   // ══════════════════════════════════════════════════════════════
//   // ✅ الاشتراك في باقة جديدة
//   // ══════════════════════════════════════════════════════════════
//   Future<PackageSubscriptionModel> subscribeToPackage({
//     required String        userId,
//     required PackageModel  package,
//     required PaymentResult paymentResult,
//   }) async {
//     String? receiptUrl;
//     File?   compressedFile;
//
//     try {
//       // ── ضغط ورفع الإيصال إن وُجد ────────────────────────────
//       if (paymentResult.receiptFile != null) {
//         final original = paymentResult.receiptFile!;
//
//         // ضغط الصورة (PDF يُرجع كما هو)
//         compressedFile = await ReceiptCompressor.compress(original);
//
//         // رفع الملف
//         receiptUrl = await _uploadReceipt(
//           userId:   userId,
//           file:     compressedFile,
//           original: original,
//         );
//       }
//
//       // ── إنشاء الاشتراك في Supabase ──────────────────────────
//       final data = <String, dynamic>{
//         'user_id':        int.parse(userId),
//         'package_id':     package.id,
//         'payment_method': paymentResult.paymentMethod == 'cash'
//             ? 'cash'
//             : paymentResult.wallet?.walletType ?? 'electronic',
//         'payment_status': paymentResult.paymentMethod == 'cash'
//             ? 'pending'       // ينتظر الدفع عند الجلسة
//             : 'under_review', // ينتظر مراجعة الإيصال
//         if (receiptUrl != null) 'receipt_url': receiptUrl,
//       };
//
//       final response = await _supabase
//           .from('package_subscriptions')
//           .insert(data)
//           .select('*, packages(*)')
//           .single();
//
//       return PackageSubscriptionModel.fromJson(response);
//     } catch (e) {
//       debugPrint('❌ خطأ في الاشتراك: $e');
//       rethrow;
//     } finally {
//       // ── تنظيف الملف المؤقت بعد الرفع ───────────────────────
//       if (compressedFile != null &&
//           paymentResult.receiptFile != null) {
//         await ReceiptCompressor.cleanTemp(
//           compressedFile,
//           paymentResult.receiptFile!,
//         );
//       }
//     }
//   }
//
//   // ══════════════════════════════════════════════════════════════
//   // رفع الإيصال إلى Supabase Storage
//   // ══════════════════════════════════════════════════════════════
//   Future<String> _uploadReceipt({
//     required String userId,
//     required File   file,
//     required File   original,
//   }) async {
//     final isPdf = original.path.toLowerCase().endsWith('.pdf');
//     final ext   = isPdf ? 'pdf' : 'jpg';
//     final ts    = DateTime.now().millisecondsSinceEpoch;
//     final path  = 'user_$userId/receipt_$ts.$ext';
//
//     try {
//       await _supabase.storage
//           .from('package-subscription-receipts')
//           .upload(
//         path,
//         file,
//         fileOptions: FileOptions(
//           contentType:  isPdf ? 'application/pdf' : 'image/jpeg',
//           cacheControl: '3600',
//           upsert:       false,
//         ),
//       );
//
//       // ✅ getPublicUrl أو createSignedUrl حسب نوع الـ bucket
//       // إذا bucket private استخدم signed URL
//       final signedUrl = await _supabase.storage
//           .from('package-subscription-receipts')
//           .createSignedUrl(path, 60 * 60 * 24 * 365); // سنة كاملة
//
//       return signedUrl;
//     } on StorageException catch (e) {
//       debugPrint('❌ Storage Error: ${e.message} | ${e.statusCode}');
//       rethrow;
//     }
//   }
//
//   // Future<String> _uploadReceipt({
//   //   required String userId,
//   //   required File   file,
//   //   required File   original,
//   // }) async {
//   //   final isPdf = original.path.toLowerCase().endsWith('.pdf');
//   //   final ext   = isPdf ? 'pdf' : 'jpg'; // الصور دائماً JPEG بعد الضغط
//   //   final ts    = DateTime.now().millisecondsSinceEpoch;
//   //   final path  = 'user_$userId/receipt_${ts}.$ext';
//   //
//   //   await _supabase.storage
//   //       .from(_storageBucket)
//   //       .upload(
//   //     path,
//   //     file,
//   //     fileOptions: FileOptions(
//   //       contentType:  isPdf ? 'application/pdf' : 'image/jpeg',
//   //       cacheControl: '3600',
//   //       upsert:       false,
//   //     ),
//   //   );
//   //
//   //   // إرجاع الـ Public URL
//   //   return _supabase.storage
//   //       .from(_storageBucket)
//   //       .getPublicUrl(path);
//   // }
//
//
//   // ══════════════════════════════════════════════════════════════
//   // جلب اشتراكات المستخدم
//   // ══════════════════════════════════════════════════════════════
//   Future<List<PackageSubscriptionModel>> getUserSubscriptions(
//       String userId, {
//         String? status,
//         bool    includePackageDetails = false,
//       }) async {
//     try {
//       final userIdInt = int.tryParse(userId);
//       if (userIdInt == null) return [];
//
//       var query = _supabase
//           .from('package_subscriptions')
//           .select(includePackageDetails
//           ? '*, packages(*, package_services(*))'
//           : '*')
//           .eq('user_id', userIdInt);
//
//       if (status != null) query = query.eq('status', status);
//
//       final response =
//       await query.order('created_at', ascending: false);
//
//       return (response as List)
//           .map((j) => PackageSubscriptionModel.fromJson(
//           j as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       debugPrint('❌ خطأ في جلب الاشتراكات: $e');
//       return [];
//     }
//   }
//
//   Future<List<PackageSubscriptionModel>> getUserActiveSubscriptions(
//       String userId, {
//         bool includePackageDetails = true,
//       }) async {
//     try {
//       final response = await _supabase
//           .from('package_subscriptions')
//           .select(includePackageDetails ? '*, packages(*)' : '*')
//           .eq('user_id', userId)
//           .eq('status', 'active')
//           .gt('end_date', DateTime.now().toIso8601String())
//           .gt('remaining_sessions', 0)
//           .order('created_at', ascending: false);
//
//       return (response as List)
//           .map((j) => PackageSubscriptionModel.fromJson(
//           j as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       return [];
//     }
//   }
//
//   Future<PackageSubscriptionModel?> getSubscriptionById(
//       int id, {
//         bool includePackageDetails = true,
//       }) async {
//     try {
//       final response = await _supabase
//           .from('package_subscriptions')
//           .select(includePackageDetails ? '*, packages(*)' : '*')
//           .eq('id', id)
//           .single();
//
//       return PackageSubscriptionModel.fromJson(
//           response as Map<String, dynamic>);
//     } catch (e) {
//       return null;
//     }
//   }
//
//   Future<bool> hasActivePackageSubscription(
//       String userId, int packageId) async {
//     try {
//       final response = await _supabase.rpc(
//         'has_active_package_subscription',
//         params: {
//           'p_user_id':   userId,
//           'p_package_id': packageId,
//         },
//       );
//       return response as bool;
//     } catch (e) {
//       return false;
//     }
//   }
//
//   Future<bool> hasAnyActiveSubscription(String userId) async {
//     final subs = await getUserActiveSubscriptions(userId);
//     return subs.isNotEmpty;
//   }
//
//   Future<Map<String, dynamic>> getUserSubscriptionsSummary(
//       String userId) async {
//     try {
//       final response = await _supabase.rpc(
//         'get_user_subscriptions_summary',
//         params: {'p_user_id': int.parse(userId)},
//       );
//       return response is Map<String, dynamic> ? response : {};
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   Future<Map<String, dynamic>?> cancelSubscription(
//       int subscriptionId, {
//         String? reason,
//       }) async {
//     try {
//       return await _supabase.rpc(
//         'cancel_package_subscription',
//         params: {
//           'p_subscription_id': subscriptionId,
//           'p_reason':          reason,
//         },
//       ) as Map<String, dynamic>;
//     } catch (e) {
//       return null;
//     }
//   }
//
//   Future<bool> updateSubscription(
//       int id, Map<String, dynamic> updates) async {
//     try {
//       await _supabase
//           .from('package_subscriptions')
//           .update(updates)
//           .eq('id', id);
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }
//
//   Future<bool> useSession(int subscriptionId) async {
//     try {
//       final sub = await getSubscriptionById(subscriptionId);
//       if (sub == null || !sub.isActive) return false;
//       if (sub.remainingSessions <= 0) return false;
//
//       await _supabase.from('package_subscriptions').update({
//         'remaining_sessions': sub.remainingSessions - 1,
//         'updated_at':         DateTime.now().toIso8601String(),
//       }).eq('id', subscriptionId);
//
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }
//
//   Stream<List<PackageSubscriptionModel>> subscribeToUserSubscriptions(
//       String userId) {
//     return _supabase
//         .from('package_subscriptions')
//         .stream(primaryKey: ['id'])
//         .order('created_at', ascending: false)
//         .map((data) => data
//         .where((j) =>
//     (j as Map<String, dynamic>)['user_id'].toString() ==
//         userId)
//         .map((j) => PackageSubscriptionModel.fromJson(
//         j as Map<String, dynamic>))
//         .toList());
//   }
//
//   Future<int> getActiveSubscriptionsCount(String userId) async {
//     final subs = await getUserActiveSubscriptions(userId);
//     return subs.length;
//   }
//
//   Future<double> getTotalSpentOnPackages(String userId) async {
//     try {
//       final summary = await getUserSubscriptionsSummary(userId);
//       return (summary['total_spent'] as num?)?.toDouble() ?? 0;
//     } catch (e) {
//       return 0;
//     }
//   }
//
//   Future<int> getTotalRemainingSessions(String userId) async {
//     final subs = await getUserActiveSubscriptions(userId);
//     return subs.fold<int>(0, (sum, s) => sum + s.remainingSessions);
//   }
// }



// lib/features/packages/data/repositories/package_subscription_repository.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:millionaire_barber/core/models/payment_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/package_model.dart';
import '../../domain/models/package_subscription_model.dart';
import 'package:millionaire_barber/core/utils/receipt_compressor.dart';
import '../../../packages/presentation/widgets/payment_sheet.dart';

class PackageSubscriptionRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _storageBucket = 'package-subscription-receipts';

  // ══════════════════════════════════════════════════════════════
  // ✅ تحويل userId بأمان
  // ══════════════════════════════════════════════════════════════
  int? _parseUserId(String userId) {
    final trimmed = userId.trim();
    final parsed  = int.tryParse(trimmed);
    if (parsed == null) {
      debugPrint('❌ userId غير صالح: "$userId"');
    }
    return parsed;
  }

  // ══════════════════════════════════════════════════════════════
  // ✅ الاشتراك في باقة
  // ══════════════════════════════════════════════════════════════
  Future<PackageSubscriptionModel> subscribeToPackage({
    required String        userId,
    required PackageModel  package,
    required PaymentResult paymentResult,
  }) async {
    // ✅ التحقق من userId أولاً قبل أي عملية
    final userIdInt = _parseUserId(userId);
    if (userIdInt == null) {
      throw Exception('userId غير صالح: "$userId"');
    }

    String? receiptUrl;
    File?   compressedFile;

    try {
      // ✅ الرفع فقط بعد التحقق من userId
      if (paymentResult.receiptFile != null) {
        final original = paymentResult.receiptFile!;
        compressedFile = await ReceiptCompressor.compress(original);
        receiptUrl     = await _uploadReceipt(
          userId:   userId,
          file:     compressedFile,
          original: original,
        );
      }

      final data = <String, dynamic>{
        'user_id':        userIdInt,
        'package_id':     package.id,
        'payment_method': paymentResult.paymentMethod == 'cash'
            ? 'cash'
            : paymentResult.wallet?.walletType ?? 'electronic',
        'payment_status': paymentResult.paymentMethod == 'cash'
            ? 'pending'
            : 'under_review',
        if (receiptUrl != null) 'receipt_url': receiptUrl,
      };

      final response = await _supabase
          .from('package_subscriptions')
          .insert(data)
          .select('*, packages(*)')
          .single();

      return PackageSubscriptionModel.fromJson(
          response as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ خطأ في الاشتراك: $e');
      rethrow;
    } finally {
      if (compressedFile != null && paymentResult.receiptFile != null) {
        await ReceiptCompressor.cleanTemp(
            compressedFile, paymentResult.receiptFile!);
      }
    }
  }


  // Future<PackageSubscriptionModel> subscribeToPackage({
  //   required String        userId,
  //   required PackageModel  package,
  //   required PaymentResult paymentResult,
  // }) async {
  //   final userIdInt = _parseUserId(userId);
  //   if (userIdInt == null) {
  //     throw FormatException('userId غير صالح: "$userId"');
  //   }
  //
  //   String? receiptUrl;
  //   File?   compressedFile;
  //
  //   try {
  //     if (paymentResult.receiptFile != null) {
  //       final original = paymentResult.receiptFile!;
  //       compressedFile = await ReceiptCompressor.compress(original);
  //       receiptUrl     = await _uploadReceipt(
  //         userId:   userId,
  //         file:     compressedFile,
  //         original: original,
  //       );
  //     }
  //
  //     final data = <String, dynamic>{
  //       'user_id':        userIdInt,
  //       'package_id':     package.id,
  //       'payment_method': paymentResult.paymentMethod == 'cash'
  //           ? 'cash'
  //           : paymentResult.wallet?.walletType ?? 'electronic',
  //       'payment_status': paymentResult.paymentMethod == 'cash'
  //           ? 'pending'
  //           : 'under_review',
  //       if (receiptUrl != null) 'receipt_url': receiptUrl,
  //     };
  //
  //     final response = await _supabase
  //         .from('package_subscriptions')
  //         .insert(data)
  //         .select('*, packages(*)')
  //         .single();
  //
  //     return PackageSubscriptionModel.fromJson(
  //         response as Map<String, dynamic>);
  //   } catch (e) {
  //     debugPrint('❌ خطأ في الاشتراك: $e');
  //     rethrow;
  //   } finally {
  //     if (compressedFile != null && paymentResult.receiptFile != null) {
  //       await ReceiptCompressor.cleanTemp(
  //           compressedFile, paymentResult.receiptFile!);
  //     }
  //   }
  // }

  // ══════════════════════════════════════════════════════════════
  // رفع الإيصال
  // ══════════════════════════════════════════════════════════════
  Future<String> _uploadReceipt({
    required String userId,
    required File   file,
    required File   original,
  }) async {
    final isPdf = original.path.toLowerCase().endsWith('.pdf');
    final ext   = isPdf ? 'pdf' : 'jpg';
    final ts    = DateTime.now().millisecondsSinceEpoch;
    final path  = 'user_$userId/receipt_$ts.$ext';

    try {
      await _supabase.storage
          .from(_storageBucket)
          .upload(
        path,
        file,
        fileOptions: FileOptions(
          contentType:  isPdf ? 'application/pdf' : 'image/jpeg',
          cacheControl: '3600',
          upsert:       false,
        ),
      );

      return _supabase.storage
          .from(_storageBucket)
          .getPublicUrl(path);
    } on StorageException catch (e) {
      debugPrint('❌ Storage Error: ${e.message} | ${e.statusCode}');
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // جلب اشتراكات المستخدم
  // ══════════════════════════════════════════════════════════════
  Future<List<PackageSubscriptionModel>> getUserSubscriptions(
      String userId, {
        String? status,
        bool    includePackageDetails = false,
      }) async {
    try {
      final userIdInt = _parseUserId(userId);
      if (userIdInt == null) return [];

      var query = _supabase
          .from('package_subscriptions')
          .select(includePackageDetails
          ? '*, packages(*, package_services(*))'
          : '*')
          .eq('user_id', userIdInt);

      if (status != null) query = query.eq('status', status);

      final response =
      await query.order('created_at', ascending: false);

      return (response as List)
          .map((j) => PackageSubscriptionModel.fromJson(
          j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ خطأ في جلب الاشتراكات: $e');
      return [];
    }
  }

  // ══════════════════════════════════════════════════════════════
  // الاشتراكات النشطة
  // ══════════════════════════════════════════════════════════════
  Future<List<PackageSubscriptionModel>> getUserActiveSubscriptions(
      String userId, {
        bool includePackageDetails = true,
      }) async {
    try {
      final userIdInt = _parseUserId(userId);
      if (userIdInt == null) return [];

      final response = await _supabase
          .from('package_subscriptions')
          .select(includePackageDetails ? '*, packages(*)' : '*')
          .eq('user_id', userIdInt)
          .eq('status', 'active')
          .gt('end_date', DateTime.now().toIso8601String())
          .gt('remaining_sessions', 0)
          .order('created_at', ascending: false);

      return (response as List)
          .map((j) => PackageSubscriptionModel.fromJson(
          j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ══════════════════════════════════════════════════════════════
  // جلب اشتراك بالـ id
  // ══════════════════════════════════════════════════════════════
  Future<PackageSubscriptionModel?> getSubscriptionById(
      int id, {
        bool includePackageDetails = true,
      }) async {
    try {
      final response = await _supabase
          .from('package_subscriptions')
          .select(includePackageDetails ? '*, packages(*)' : '*')
          .eq('id', id)
          .single();

      return PackageSubscriptionModel.fromJson(
          response as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // التحقق من اشتراك نشط
  // ══════════════════════════════════════════════════════════════
  Future<bool> hasActivePackageSubscription(
      String userId, int packageId) async {
    try {
      final userIdInt = _parseUserId(userId);
      if (userIdInt == null) return false;

      final response = await _supabase.rpc(
        'has_active_package_subscription',
        params: {
          'p_user_id':    userIdInt,
          'p_package_id': packageId,
        },
      );
      return response as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> hasAnyActiveSubscription(String userId) async {
    final subs = await getUserActiveSubscriptions(userId);
    return subs.isNotEmpty;
  }

  // ══════════════════════════════════════════════════════════════
  // ملخص الاشتراكات
  // ══════════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> getUserSubscriptionsSummary(
      String userId) async {
    try {
      final userIdInt = _parseUserId(userId);
      if (userIdInt == null) return {};

      final response = await _supabase.rpc(
        'get_user_subscriptions_summary',
        params: {'p_user_id': userIdInt},
      );
      return response is Map<String, dynamic> ? response : {};
    } catch (e) {
      debugPrint('❌ خطأ في جلب الملخص: $e');
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // إلغاء اشتراك
  // ══════════════════════════════════════════════════════════════
  Future<Map<String, dynamic>?> cancelSubscription(
      int subscriptionId, {
        String? reason,
      }) async {
    try {
      return await _supabase.rpc(
        'cancel_package_subscription',
        params: {
          'p_subscription_id': subscriptionId,
          'p_reason':          reason,
        },
      ) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateSubscription(
      int id, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('package_subscriptions')
          .update(updates)
          .eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // استخدام جلسة
  // ══════════════════════════════════════════════════════════════
  Future<bool> useSession(int subscriptionId) async {
    try {
      final sub = await getSubscriptionById(subscriptionId);
      if (sub == null || !sub.isActive) return false;
      if (sub.remainingSessions <= 0) return false;

      await _supabase.from('package_subscriptions').update({
        'remaining_sessions': sub.remainingSessions - 1,
        'updated_at':         DateTime.now().toIso8601String(),
      }).eq('id', subscriptionId);

      return true;
    } catch (e) {
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // Realtime stream
  // ══════════════════════════════════════════════════════════════
  Stream<List<PackageSubscriptionModel>> subscribeToUserSubscriptions(
      String userId) {
    final userIdInt = _parseUserId(userId) ?? 0;

    return _supabase
        .from('package_subscriptions')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data
        .where((j) =>
    (j as Map<String, dynamic>)['user_id'] == userIdInt)
        .map((j) => PackageSubscriptionModel.fromJson(
        j as Map<String, dynamic>))
        .toList());
  }
}
