// // lib/features/packages/providers/package_subscription_provider.dart
//
// import 'package:flutter/foundation.dart';
// import 'package:millionaire_barber/features/packages/data/repositories/package_subscription_repository.dart';
// import 'package:millionaire_barber/features/packages/domain/models/package_model.dart';
// import 'package:millionaire_barber/features/packages/domain/models/package_subscription_model.dart';
//
// /// Provider لإدارة حالة اشتراكات الباقات
// class PackageSubscriptionProvider with ChangeNotifier {
//   final PackageSubscriptionRepository _repository;
//   String _userId = '';
//
//
//
//   // ✅ Constructor بسيط بدون userId
//   PackageSubscriptionProvider({
//     required PackageSubscriptionRepository repository,
//   }) : _repository = repository;
//
//   // ✅ Getter
//   String get userId => _userId;
//
//   // ✅ Setter
//   void setUserId(String id) {
//     if (_userId != id) {
//       _userId = id;
//       if (id.isNotEmpty) {
//         loadUserSubscriptions(); // تحميل تلقائي عند تعيين userId
//       }
//       notifyListeners();
//     }
//   }
//
//
//   // ═══════════════════════════════════════════════════════════════
//   // 📊 State
//   // ═══════════════════════════════════════════════════════════════
//
//   List<PackageSubscriptionModel> _subscriptions = [];
//   List<PackageSubscriptionModel> _activeSubscriptions = [];
//   Map<String, dynamic>? _summary;
//
//
//   // Lists for different subscription states
//   List<PackageSubscriptionModel> _usedSubscriptions = [];
//   List<PackageSubscriptionModel> _expiredSubscriptions = [];
//
//   List<PackageSubscriptionModel> get usedSubscriptions => _usedSubscriptions;
//   List<PackageSubscriptionModel> get expiredSubscriptions => _expiredSubscriptions;
//
//   bool _isLoading = false;
//   bool _isSubscribing = false;
//   String? _error;
//
//   String? _errorMessage;
//
//   // ═══════════════════════════════════════════════════════════════
//   // 📖 Getters
//   // ═══════════════════════════════════════════════════════════════
//
//   List<PackageSubscriptionModel> get subscriptions => _subscriptions;
//   List<PackageSubscriptionModel> get activeSubscriptions => _activeSubscriptions;
//   Map<String, dynamic>? get summary => _summary;
//
//
//
//   bool get isLoading => _isLoading;
//   bool get isSubscribing => _isSubscribing;
//   String? get error => _error;
//   bool get hasError => _error != null;
//
//   /// هل لدى المستخدم اشتراكات نشطة؟
//   bool get hasActiveSubscriptions => _activeSubscriptions.isNotEmpty;
//
//   /// عدد الاشتراكات النشطة
//   int get activeCount => _activeSubscriptions.length;
//
//   /// إجمالي الجلسات المتبقية
//   int get totalRemainingSessions {
//     return _activeSubscriptions.fold<int>(
//       0,
//           (sum, sub) => sum + sub.remainingSessions,
//     );
//   }
//
//   /// إجمالي المبلغ المنفق
//   double get totalSpent {
//     return (_summary?['total_spent'] is num)
//         ? (_summary?['total_spent'] as num).toDouble()
//         : 0.0;
//   }
//
//
//   // ═══════════════════════════════════════════════════════════════
//   // 🔄 Load Data
//   // ═══════════════════════════════════════════════════════════════
//
//   /// تحميل جميع اشتراكات المستخدم
//   Future<void> loadUserSubscriptions() async {
//     // ✅ التحقق من userId قبل البدء
//     if (userId.isEmpty) {
//       _subscriptions = [];
//       _activeSubscriptions = [];
//       _usedSubscriptions = [];
//       _expiredSubscriptions = [];
//       _summary = null;
//       _clearError();
//       notifyListeners();
//       return;
//     }
//
//     _setLoading(true);
//     _clearError();
//
//     try {
//       // تحميل جميع الاشتراكات
//       _subscriptions = await _repository.getUserSubscriptions(
//         userId,
//         includePackageDetails: true,
//       );
//
//       // تصنيف الاشتراكات حسب الحالة
//       _activeSubscriptions = _subscriptions.where((s) =>
//       s.isActive && s.remainingSessions > 0
//       ).toList();
//
//       _usedSubscriptions = _subscriptions.where((s) =>
//       s.usedSessions > 0 && s.remainingSessions == 0 && !s.isExpired
//       ).toList();
//
//       _expiredSubscriptions = _subscriptions.where((s) => s.isExpired).toList();
//
//       // تحميل الملخص
//       _summary = await _repository.getUserSubscriptionsSummary(userId);
//
//       notifyListeners();
//     } catch (e) {
//       _setError('فشل تحميل الاشتراكات: $e');
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//
//   /// تحديث البيانات
//   Future<void> refresh() async {
//     await loadUserSubscriptions();
//   }
//
//   // ═══════════════════════════════════════════════════════════════
//   // ✅ Subscribe to Package
//   // ═══════════════════════════════════════════════════════════════
//
//   /// الاشتراك في باقة جديدة
//   Future<bool> subscribeToPackage({
//     required PackageModel package,
//     required String paymentMethod,
//     double? customPrice,
//     String? transactionId,
//   }) async {
//     _isSubscribing = true;
//     _clearError();
//     notifyListeners();
//
//     try {
//       final subscription = await _repository.subscribeToPackage(
//         userId: userId,
//         package: package,
//         paymentMethod: paymentMethod,
//       );
//
//       // إضافة الاشتراك الجديد للقائمة
//       _subscriptions.insert(0, subscription);
//       _activeSubscriptions.insert(0, subscription);
//
//       // تحديث الملخص
//       await _loadSummary();
//
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _setError('فشل الاشتراك: $e');
//       return false;
//     } finally {
//       _isSubscribing = false;
//       notifyListeners();
//     }
//   }
//
//   // ═══════════════════════════════════════════════════════════════
//   // ❌ Cancel Subscription
//   // ═══════════════════════════════════════════════════════════════
//
//   /// إلغاء اشتراك
//   Future<bool> cancelSubscription(
//       int subscriptionId, {
//         String? reason,
//       }) async {
//     _setLoading(true);
//     _clearError();
//
//     try {
//       final result = await _repository.cancelSubscription(
//         subscriptionId,
//         reason: reason,
//       );
//
//       if (result?['success'] == true) {
//         // تحديث القوائم محلياً
//         _subscriptions.removeWhere((s) => s.id == subscriptionId);
//         _activeSubscriptions.removeWhere((s) => s.id == subscriptionId);
//
//         await _loadSummary();
//         notifyListeners();
//         return true;
//       }
//
//       _setError(result?['message'].toString() ?? 'فشل الإلغاء');
//       return false;
//     } catch (e) {
//       _setError('فشل إلغاء الاشتراك: $e');
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   // ═══════════════════════════════════════════════════════════════
//   // 🔍 Query Methods
//   // ═══════════════════════════════════════════════════════════════
//
//   /// جلب اشتراك محدد
//   Future<PackageSubscriptionModel?> getSubscriptionById(int id) async {
//     try {
//       return await _repository.getSubscriptionById(id);
//     } catch (e) {
//       _setError('فشل جلب الاشتراك: $e');
//       return null;
//     }
//   }
//
//   /// التحقق من اشتراك نشط في باقة محددة
//   Future<bool> hasActivePackageSubscription(int packageId) async {
//     try {
//       return await _repository.hasActivePackageSubscription(userId, packageId);
//     } catch (e) {
//       return false;
//     }
//   }
//
//   /// البحث عن اشتراك نشط في باقة محددة (محلياً)
//   PackageSubscriptionModel? findActiveSubscription(int packageId) {
//     try {
//       return _activeSubscriptions.firstWhere(
//             (sub) => sub.packageId == packageId && sub.isActive,
//       );
//     } catch (e) {
//       return null;
//     }
//   }
//
//   // ═══════════════════════════════════════════════════════════════
//   // 🎫 Session Management
//   // ═══════════════════════════════════════════════════════════════
//
//   /// استخدام جلسة من اشتراك
//   Future<bool> useSession(int subscriptionId) async {
//     try {
//       final success = await _repository.useSession(subscriptionId);
//
//       if (success) {
//         // تحديث محلي
//         final index = _activeSubscriptions.indexWhere((s) => s.id == subscriptionId);
//         if (index != -1) {
//           final sub = _activeSubscriptions[index];
//           _activeSubscriptions[index] = sub.copyWith(
//             remainingSessions: sub.remainingSessions - 1,
//             usedSessions: sub.usedSessions + 1,
//           );
//           notifyListeners();
//         }
//       }
//
//       return success;
//     } catch (e) {
//       _setError('فشل استخدام الجلسة: $e');
//       return false;
//     }
//   }
//
//   // ═══════════════════════════════════════════════════════════════
//   // 🔔 Real-time Updates
//   // ═══════════════════════════════════════════════════════════════
//
//   /// تفعيل الاستماع المباشر للتحديثات
//   void listenToRealtimeUpdates() {
//     _repository.subscribeToUserSubscriptions(userId).listen(
//           (subscriptions) {
//         _subscriptions = subscriptions;
//         notifyListeners();
//       },
//       onError: (e) {
//         _setError('خطأ في الاستماع المباشر: $e');
//       },
//     );
//
//     _repository.subscribeToActiveSubscriptions(userId).listen(
//           (activeSubscriptions) {
//         _activeSubscriptions = activeSubscriptions;
//         notifyListeners();
//       },
//       onError: (e) {
//         _setError('خطأ في الاستماع المباشر: $e');
//       },
//     );
//   }
//
//   Future<void> subscribe(String userId, PackageModel package) async {
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       await _repository.subscribeToPackage(
//         userId: userId,
//         package: package,
//         paymentMethod: 'cash',
//       );
//
//       _errorMessage = null;
//       notifyListeners();
//
//     } catch (e) {
//       // ✅ تخزين رسالة الخطأ
//       if (e.toString().contains('لديك اشتراك نشط')) {
//         _errorMessage = 'duplicate_subscription';
//       } else {
//         _errorMessage = e.toString();
//       }
//       notifyListeners();
//       rethrow;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//
//
// // ═══════════════════════════════════════════════════════════════
//   // 🛠️ Helper Methods
//   // ═══════════════════════════════════════════════════════════════
//
//   Future<void> _loadSummary() async {
//     try {
//       _summary = await _repository.getUserSubscriptionsSummary(userId);
//     } catch (e) {
//     }
//   }
//
//   void _setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }
//
//   void _setError(String message) {
//     _error = message;
//     notifyListeners();
//   }
//
//   void _clearError() {
//     _error = null;
//   }
//
//   /// مسح الخطأ يدوياً
//   void clearError() {
//     _clearError();
//     notifyListeners();
//   }
//
//   @override
//   void dispose() {
//     // تنظيف الموارد
//     super.dispose();
//   }
// }


// lib/features/packages/presentation/providers/package_subscription_provider.dart

import 'package:flutter/foundation.dart';
import 'package:millionaire_barber/core/models/payment_result.dart';
import 'package:millionaire_barber/features/packages/data/repositories/package_subscription_repository.dart';
import 'package:millionaire_barber/features/packages/domain/models/package_model.dart';
import 'package:millionaire_barber/features/packages/domain/models/package_subscription_model.dart';
import 'package:millionaire_barber/features/packages/presentation/widgets/payment_sheet.dart';

class PackageSubscriptionProvider with ChangeNotifier {
  final PackageSubscriptionRepository _repository;
  String _userId = '';

  PackageSubscriptionProvider({
    required PackageSubscriptionRepository repository,
  }) : _repository = repository;

  // ══════════════════════════════════════════════════════════════
  // 📊 State
  // ══════════════════════════════════════════════════════════════
  List<PackageSubscriptionModel> _subscriptions        = [];
  List<PackageSubscriptionModel> _activeSubscriptions  = [];
  List<PackageSubscriptionModel> _usedSubscriptions    = [];
  List<PackageSubscriptionModel> _expiredSubscriptions = [];
  Map<String, dynamic>?          _summary;

  bool    _isLoading     = false;
  bool    _isSubscribing = false;
  String? _error;

  // ══════════════════════════════════════════════════════════════
  // 📖 Getters
  // ══════════════════════════════════════════════════════════════
  String get userId => _userId;

  List<PackageSubscriptionModel> get subscriptions        => _subscriptions;
  List<PackageSubscriptionModel> get activeSubscriptions  => _activeSubscriptions;
  List<PackageSubscriptionModel> get usedSubscriptions    => _usedSubscriptions;
  List<PackageSubscriptionModel> get expiredSubscriptions => _expiredSubscriptions;
  Map<String, dynamic>?          get summary              => _summary;

  bool    get isLoading              => _isLoading;
  bool    get isSubscribing          => _isSubscribing;
  String? get error                  => _error;
  bool    get hasError               => _error != null;
  bool    get hasActiveSubscriptions => _activeSubscriptions.isNotEmpty;
  int     get activeCount            => _activeSubscriptions.length;

  int get totalRemainingSessions => _activeSubscriptions.fold<int>(
      0, (sum, s) => sum + s.remainingSessions);

  double get totalSpent =>
      (_summary?['total_spent'] is num)
          ? (_summary!['total_spent'] as num).toDouble()
          : 0.0;

  // ══════════════════════════════════════════════════════════════
  // setUserId
  // ══════════════════════════════════════════════════════════════
  void setUserId(String id) {
    if (_userId != id) {
      _userId = id;
      if (id.isNotEmpty) loadUserSubscriptions();
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════
  // 🔄 Load
  // ══════════════════════════════════════════════════════════════
  Future<void> loadUserSubscriptions() async {
    if (_userId.isEmpty) {
      _subscriptions       = [];
      _activeSubscriptions = [];
      _usedSubscriptions   = [];
      _expiredSubscriptions = [];
      _summary             = null;
      _clearError();
      notifyListeners();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      // ✅ cast صريح لتجنب خطأ dynamic assignment
      final raw = await _repository.getUserSubscriptions(
        _userId,
        includePackageDetails: true,
      );
      _subscriptions = List<PackageSubscriptionModel>.from(raw);

      // تصنيف الاشتراكات
      _activeSubscriptions = _subscriptions
          .where((s) => s.isActive && s.remainingSessions > 0)
          .toList();

      _usedSubscriptions = _subscriptions
          .where((s) =>
      s.usedSessions > 0 &&
          s.remainingSessions == 0 &&
          !s.isExpired)
          .toList();

      _expiredSubscriptions =
          _subscriptions.where((s) => s.isExpired).toList();

      _summary =
      await _repository.getUserSubscriptionsSummary(_userId);

      notifyListeners();
    } catch (e) {
      _setError('فشل تحميل الاشتراكات: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() => loadUserSubscriptions();

  // ══════════════════════════════════════════════════════════════
  // ✅ Subscribe — يقبل PaymentResult كاملاً
  // ══════════════════════════════════════════════════════════════
  Future<bool> subscribeToPackage({
    required PackageModel  package,
    required PaymentResult paymentResult,
    String?                overrideUserId,
  }) async {
    // ✅ أولوية: overrideUserId → _userId
    final effectiveUserId = (overrideUserId?.trim().isNotEmpty == true)
        ? overrideUserId!.trim()
        : _userId.trim();

    // ✅ رفض فوري قبل أي عملية
    if (effectiveUserId.isEmpty) {
      _setError('لم يتم تحديد المستخدم');
      debugPrint('❌ subscribeToPackage: userId فارغ');
      return false;
    }

    // ✅ تحديث _userId إن كان مختلفاً
    if (_userId != effectiveUserId) {
      _userId = effectiveUserId;
    }

    _isSubscribing = true;
    _clearError();
    notifyListeners();

    try {
      final subscription = await _repository.subscribeToPackage(
        userId:        effectiveUserId,
        package:       package,
        paymentResult: paymentResult,
      );

      _subscriptions.insert(0, subscription);
      if (subscription.isActive) {
        _activeSubscriptions.insert(0, subscription);
      }

      await _loadSummary();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل الاشتراك: $e');
      return false;
    } finally {
      _isSubscribing = false;
      notifyListeners();
    }
  }

  // Future<bool> subscribeToPackage({
  //   required PackageModel  package,
  //   required PaymentResult paymentResult,
  //   String?                overrideUserId, // ✅ override اختياري
  // }) async {
  //   // ✅ يأخذ الـ override أولاً، ثم الـ _userId المخزن
  //   final effectiveUserId = (overrideUserId?.trim().isNotEmpty == true)
  //       ? overrideUserId!.trim()
  //       : _userId.trim();
  //
  //   if (effectiveUserId.isEmpty) {
  //     _setError('لم يتم تحديد المستخدم، يرجى تسجيل الدخول مجدداً');
  //     return false;
  //   }
  //
  //   _isSubscribing = true;
  //   _clearError();
  //   notifyListeners();
  //
  //   try {
  //     final subscription = await _repository.subscribeToPackage(
  //       userId:        effectiveUserId,
  //       package:       package,
  //       paymentResult: paymentResult,
  //     );
  //
  //     _subscriptions.insert(0, subscription);
  //     if (subscription.isActive) {
  //       _activeSubscriptions.insert(0, subscription);
  //     }
  //     await _loadSummary();
  //     notifyListeners();
  //     return true;
  //   } catch (e) {
  //     _setError('فشل الاشتراك: $e');
  //     return false;
  //   } finally {
  //     _isSubscribing = false;
  //     notifyListeners();
  //   }
  // }
  //
  // Future<bool> subscribeToPackage({
  //   required PackageModel  package,
  //   required PaymentResult paymentResult,
  // }) async {
  //   _isSubscribing = true;
  //   _clearError();
  //   notifyListeners();
  //
  //   try {
  //     final subscription = await _repository.subscribeToPackage(
  //       userId:        _userId,
  //       package:       package,
  //       paymentResult: paymentResult,
  //     );
  //
  //     _subscriptions.insert(0, subscription);
  //     if (subscription.isActive) {
  //       _activeSubscriptions.insert(0, subscription);
  //     }
  //
  //     await _loadSummary();
  //     notifyListeners();
  //     return true;
  //   } catch (e) {
  //     _setError('فشل الاشتراك: $e');
  //     return false;
  //   } finally {
  //     _isSubscribing = false;
  //     notifyListeners();
  //   }
  // }

  // ══════════════════════════════════════════════════════════════
  // ❌ Cancel
  // ══════════════════════════════════════════════════════════════
  Future<bool> cancelSubscription(int subscriptionId,
      {String? reason}) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _repository.cancelSubscription(
        subscriptionId,
        reason: reason,
      );

      if (result?['success'] == true) {
        _subscriptions
            .removeWhere((s) => s.id == subscriptionId);
        _activeSubscriptions
            .removeWhere((s) => s.id == subscriptionId);
        _usedSubscriptions
            .removeWhere((s) => s.id == subscriptionId);

        await _loadSummary();
        notifyListeners();
        return true;
      }

      _setError(result?['message']?.toString() ?? 'فشل الإلغاء');
      return false;
    } catch (e) {
      _setError('فشل إلغاء الاشتراك: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ══════════════════════════════════════════════════════════════
  // 🔍 Query
  // ══════════════════════════════════════════════════════════════
  Future<PackageSubscriptionModel?> getSubscriptionById(int id) async {
    try {
      return await _repository.getSubscriptionById(id);
    } catch (e) {
      _setError('فشل جلب الاشتراك: $e');
      return null;
    }
  }

  Future<bool> hasActivePackageSubscription(int packageId) async {
    try {
      return await _repository.hasActivePackageSubscription(
          _userId, packageId);
    } catch (_) {
      return false;
    }
  }

  /// بحث محلي سريع بدون طلب شبكة
  PackageSubscriptionModel? findActiveSubscription(int packageId) {
    try {
      return _activeSubscriptions
          .firstWhere((s) => s.packageId == packageId && s.isActive);
    } catch (_) {
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // 🎫 Session
  // ══════════════════════════════════════════════════════════════
  Future<bool> useSession(int subscriptionId) async {
    try {
      final success = await _repository.useSession(subscriptionId);
      if (success) {
        final idx = _activeSubscriptions
            .indexWhere((s) => s.id == subscriptionId);
        if (idx != -1) {
          final s = _activeSubscriptions[idx];
          _activeSubscriptions[idx] = s.copyWith(
            remainingSessions: s.remainingSessions - 1,
            usedSessions:      s.usedSessions + 1,
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _setError('فشل استخدام الجلسة: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // 🔔 Realtime
  // ✅ حُذفت subscribeToActiveSubscriptions — نستخدم فلتر محلي
  // ══════════════════════════════════════════════════════════════
  void listenToRealtimeUpdates() {
    _repository.subscribeToUserSubscriptions(_userId).listen(
          (subs) {
        _subscriptions = List<PackageSubscriptionModel>.from(subs);

        // تصنيف تلقائي عند كل تحديث
        _activeSubscriptions = _subscriptions
            .where((s) => s.isActive && s.remainingSessions > 0)
            .toList();

        _usedSubscriptions = _subscriptions
            .where((s) =>
        s.usedSessions > 0 &&
            s.remainingSessions == 0 &&
            !s.isExpired)
            .toList();

        _expiredSubscriptions =
            _subscriptions.where((s) => s.isExpired).toList();

        notifyListeners();
      },
      onError: (e) => _setError('خطأ في الاستماع المباشر: $e'),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 🛠️ Helpers
  // ══════════════════════════════════════════════════════════════
  Future<void> _loadSummary() async {
    try {
      _summary =
      await _repository.getUserSubscriptionsSummary(_userId);
    } catch (_) {}
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    notifyListeners();
  }

  void _clearError() => _error = null;

  void clearError() {
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() => super.dispose();
}
