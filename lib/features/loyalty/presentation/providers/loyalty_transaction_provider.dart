// import 'package:flutter/material.dart';
// import 'package:millionaire_barber/features/loyalty/domain/models/loyalty_settings_model.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../domain/models/loyalty_transaction_model.dart';
// import '../../domain/entities/reward.dart';
// import '../../domain/entities/reward_redemption.dart';
// import '../../data/repositories/loyalty_transaction_repository.dart';
//
// class LoyaltyTransactionProvider extends ChangeNotifier {
//   final LoyaltyTransactionRepository loyaltyTransactionRepository;
//   final SupabaseClient _supabase = Supabase.instance.client;
//
//   LoyaltyTransactionProvider({required this.loyaltyTransactionRepository});
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // STATE VARIABLES
//   // ════════════════════════════════════════════════════════════════════════════
//   // العمليات والمكافآت
//   List<LoyaltyTransactionModel> _transactions = [];
//   LoyaltyTransactionModel? _selectedTransaction;
//
//   // النقاط
//   int _userLoyaltyPoints = 0;
//   int _pendingPoints = 0;
//
//   // الإعدادات
//   LoyaltySettingsModel? _loyaltySettings;
//
//   // كوبونات المعالم
//   List<Map<String, dynamic>> _milestoneCoupons = [];
//
//   // حالة التحميل والأخطاء
//   bool _isLoading = false;
//   String? _error;
//
//   // القنوات الفورية
//   RealtimeChannel? _transactionsChannel;
//   RealtimeChannel? _loyaltyChannel;
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // GETTERS
//   // ════════════════════════════════════════════════════════════════════════════
//
//   List<LoyaltyTransactionModel> get transactions => _transactions;
//   LoyaltyTransactionModel? get selectedTransaction => _selectedTransaction;
//
//   int get totalPoints => _userLoyaltyPoints;
//   int get pendingPoints => _pendingPoints;
//
//   LoyaltySettingsModel? get loyaltySettings => _loyaltySettings;
//   List<Map<String, dynamic>> get milestoneCoupons => _milestoneCoupons;
//
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // LOYALTY TRANSACTIONS
//   // ════════════════════════════════════════════════════════════════════════════
//
//   /// جلب عملية ولاء بواسطة ID
//   Future<void> fetchTransactionById(int id) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
//
//     try {
//       _selectedTransaction = await loyaltyTransactionRepository.getTransactionById(id);
//       print('✅ Fetched transaction #$id');
//     } catch (e) {
//       _error = 'خطأ في جلب بيانات العملية';
//       print('❌ Error fetching transaction: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   /// جلب العمليات لمستخدم معين
//   Future<void> fetchTransactionsByUser(int userId) async {
//     try {
//       _transactions = await loyaltyTransactionRepository.getTransactionsByUser(userId);
//       print('✅ Fetched ${_transactions.length} transactions for user $userId');
//       notifyListeners();
//     } catch (e) {
//       _error = 'خطأ في جلب بيانات عمليات المستخدم';
//       print('❌ Error fetching transactions: $e');
//       notifyListeners();
//     }
//   }
//
//   /// إنشاء عملية جديدة
//   Future<bool> createTransaction(LoyaltyTransactionModel transaction) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
//
//     try {
//       final created = await loyaltyTransactionRepository.createTransaction(transaction);
//       _transactions.insert(0, created);
//       print('✅ Created new transaction');
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _error = 'فشل إنشاء العملية';
//       print('❌ Error creating transaction: $e');
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // LOYALTY SETTINGS
//   // ════════════════════════════════════════════════════════════════════════════
//
//   /// جلب إعدادات الولاء
//   Future<void> fetchLoyaltySettings() async {
//     try {
//       final data = await _supabase
//           .from('loyalty_settings')
//           .select()
//           .eq('is_active', true)
//           .order('updated_at', ascending: false)
//           .limit(1)
//           .maybeSingle();
//
//       if (data != null) {
//         _loyaltySettings = LoyaltySettingsModel.fromJson(data);
//         print('✅ Loaded loyalty settings: ${_loyaltySettings?.descriptionAr}');
//       } else {
//         _loyaltySettings = _getDefaultSettings();
//         print('⚠️ Using default loyalty settings');
//       }
//
//       notifyListeners();
//     } catch (e) {
//       print('❌ Error fetching loyalty settings: $e');
//       _loyaltySettings = _getDefaultSettings();
//       notifyListeners();
//     }
//   }
//
//   /// إعدادات افتراضية
//   LoyaltySettingsModel _getDefaultSettings() {
//     return LoyaltySettingsModel(
//       id: 0,
//       pointsPerCurrency: 1.0,
//       currencyPerPoint: 10.0,
//       minPurchaseForPoints: 0.0,
//       bonusMultiplier: 1.0,
//       isActive: true,
//       descriptionAr: 'نقطة واحدة لكل 10 ريال',
//     );
//   }
//
//   /// حساب النقاط من المبلغ
//   int calculateLoyaltyPoints(double amount) {
//     if (_loyaltySettings == null) {
//       return (amount / 10).floor();
//     }
//     return _loyaltySettings!.calculatePointsFromAmount(amount);
//   }
//
//   /// حساب المبلغ من النقاط
//   double calculateAmountFromPoints(int points) {
//     if (_loyaltySettings == null) {
//       return points * 10.0;
//     }
//     return _loyaltySettings!.calculateAmountFromPoints(points);
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // PENDING POINTS
//   // ════════════════════════════════════════════════════════════════════════════
//
//   /// جلب النقاط المعلقة
//   Future<void> fetchPendingPoints(int userId) async {
//     try {
//       final result = await _supabase
//           .from('loyalty_transactions')
//           .select('points_amount')
//           .eq('user_id', userId)
//           .eq('status', 'pending')
//           .eq('transaction_type', 'earned');
//
//       _pendingPoints = 0;
//
//       if (result is List) {
//         for (var row in result) {
//           _pendingPoints += row['points_amount'] as int? ?? 0;
//         }
//       }
//
//       notifyListeners();
//       print('✅ Pending points: $_pendingPoints');
//     } catch (e) {
//       print('❌ Error fetching pending points: $e');
//       _pendingPoints = 0;
//       notifyListeners();
//     }
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // MILESTONE COUPONS
//   // ════════════════════════════════════════════════════════════════════════════
//
//   /// جلب كوبونات المعالم للمستخدم
//   Future<void> fetchUserMilestoneCoupons(int userId) async {
//     try {
//       final data = await _supabase
//           .rpc('get_user_milestone_coupons', params: {'p_user_id': userId});
//
//       if (data is List) {
//         _milestoneCoupons = List<Map<String, dynamic>>.from(data);
//         print('✅ Loaded ${_milestoneCoupons.length} milestone coupons');
//       } else {
//         _milestoneCoupons = [];
//         print('⚠️ No milestone coupons found');
//       }
//
//       notifyListeners();
//     } catch (e) {
//       print('❌ Error loading milestone coupons: $e');
//       _milestoneCoupons = [];
//       notifyListeners();
//     }
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // LOAD ALL data
//   // ════════════════════════════════════════════════════════════════════════════
//
//   /// تحميل جميع بيانات الولاء دفعة واحدة
//   Future<void> loadLoyaltyData(int userId) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
//
//     try {
//       // جلب النقاط الفعلية (المكتملة فقط)
//       _userLoyaltyPoints = await loyaltyTransactionRepository.getUserLoyaltyPoints(userId);
//       print('✅ Loaded loyalty points: $_userLoyaltyPoints');
//
//       // جلب باقي البيانات بالتوازي
//       await Future.wait([
//         fetchTransactionsByUser(userId),
//         fetchPendingPoints(userId),
//         fetchUserMilestoneCoupons(userId),
//         fetchLoyaltySettings(),
//       ]);
//
//       print('✅ All loyalty data loaded successfully');
//     } catch (e) {
//       _error = 'خطأ في جلب بيانات الولاء: ${e.toString()}';
//       print('❌ Error loading loyalty data: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // REALTIME SUBSCRIPTIONS - LOYALTY
//   // ════════════════════════════════════════════════════════════════════════════
//
//   /// الاشتراك في تحديثات الولاء الشاملة
//   void subscribeToLoyaltyUpdates(int userId) {
//     unsubscribeFromLoyaltyUpdates();
//
//     print('📡 Subscribing to loyalty updates for user: $userId');
//
//     try {
//       _loyaltyChannel = _supabase
//           .channel('loyalty_user_$userId')
//           .onPostgresChanges(
//         event: PostgresChangeEvent.all,
//         schema: 'public',
//         table: 'loyalty_transactions',
//         filter: PostgresChangeFilter(
//           type: PostgresChangeFilterType.eq,
//           column: 'user_id',
//           value: userId,
//         ),
//         callback: (payload) {
//           print('📡 Loyalty Transaction Event: ${payload.eventType}');
//           // إعادة تحميل البيانات عند أي تغيير
//           loadLoyaltyData(userId);
//         },
//       )
//           .onPostgresChanges(
//         event: PostgresChangeEvent.all,
//         schema: 'public',
//         table: 'user_milestone_achievements',
//         filter: PostgresChangeFilter(
//           type: PostgresChangeFilterType.eq,
//           column: 'user_id',
//           value: userId,
//         ),
//         callback: (payload) {
//           print('📡 Milestone Achievement Event: ${payload.eventType}');
//           fetchUserMilestoneCoupons(userId);
//         },
//       )
//           .subscribe();
//
//       print('✅ Subscribed to loyalty realtime updates');
//     } catch (e) {
//       print('❌ Error subscribing to loyalty updates: $e');
//     }
//   }
//
//   /// إلغاء الاشتراك في تحديثات الولاء
//   void unsubscribeFromLoyaltyUpdates() {
//     if (_loyaltyChannel != null) {
//       _loyaltyChannel!.unsubscribe();
//       _loyaltyChannel = null;
//       print('🔕 Unsubscribed from loyalty updates');
//     }
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // REALTIME SUBSCRIPTIONS - TRANSACTIONS
//   // ════════════════════════════════════════════════════════════════════════════
//
//   /// الاشتراك في تحديثات عمليات المستخدم (تفصيلي)
//   void subscribeToUserTransactions(int userId) {
//     unsubscribeFromTransactions();
//
//     print('📡 Subscribing to user loyalty transactions: $userId');
//
//     try {
//       _transactionsChannel = _supabase
//           .channel('loyalty_transactions_user_$userId')
//           .onPostgresChanges(
//         event: PostgresChangeEvent.all,
//         schema: 'public',
//         table: 'loyalty_transactions',
//         filter: PostgresChangeFilter(
//           type: PostgresChangeFilterType.eq,
//           column: 'user_id',
//           value: userId,
//         ),
//         callback: (payload) {
//           print('📡 Transaction Realtime Event: ${payload.eventType}');
//           _handleTransactionRealtimeEvent(payload, userId);
//         },
//       )
//           .subscribe();
//
//       print('✅ Subscribed to transaction realtime updates');
//     } catch (e) {
//       print('❌ Error subscribing to transactions: $e');
//     }
//   }
//
//   /// معالجة أحداث Realtime للعمليات
//   void _handleTransactionRealtimeEvent(PostgresChangePayload payload, int userId) {
//     if (payload.eventType == PostgresChangeEvent.insert) {
//       if (payload.newRecord != null) {
//         final newTransaction = LoyaltyTransactionModel.fromJson(payload.newRecord);
//         _transactions.insert(0, newTransaction);
//         loadLoyaltyData(userId);
//         print('✅ New transaction added via Realtime');
//       }
//     } else if (payload.eventType == PostgresChangeEvent.update) {
//       if (payload.newRecord != null) {
//         final updatedTransaction = LoyaltyTransactionModel.fromJson(payload.newRecord);
//         final index = _transactions.indexWhere((t) => t.id == updatedTransaction.id);
//         if (index >= 0) {
//           _transactions[index] = updatedTransaction;
//           notifyListeners();
//           print('✅ Transaction updated via Realtime');
//         }
//       }
//     } else if (payload.eventType == PostgresChangeEvent.delete) {
//       if (payload.oldRecord != null) {
//         final deletedId = payload.oldRecord['id'];
//         _transactions.removeWhere((t) => t.id == deletedId);
//         loadLoyaltyData(userId);
//         print('✅ Transaction deleted via Realtime');
//       }
//     }
//   }
//
//   /// إلغاء الاشتراك في تحديثات العمليات
//   void unsubscribeFromTransactions() {
//     if (_transactionsChannel != null) {
//       _transactionsChannel!.unsubscribe();
//       _transactionsChannel = null;
//       print('🔕 Unsubscribed from transaction changes');
//     }
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // CLEANUP
//   // ════════════════════════════════════════════════════════════════════════════
//
//   @override
//   void dispose() {
//     unsubscribeFromTransactions();
//     unsubscribeFromLoyaltyUpdates();
//     super.dispose();
//   }
// }



import 'package:flutter/material.dart';
import 'package:millionaire_barber/features/coupons/domain/models/coupon_model.dart';
import 'package:millionaire_barber/features/loyalty/domain/models/milestone_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/loyalty_settings_model.dart';
import '../../domain/models/loyalty_transaction_model.dart';
import '../../data/repositories/loyalty_transaction_repository.dart';

class LoyaltyTransactionProvider extends ChangeNotifier {
  final LoyaltyTransactionRepository repository;
  final SupabaseClient _supabase = Supabase.instance.client;

  LoyaltyTransactionProvider({required this.repository});

  // ════════════════════════════════════════════════════════════════════════════
  // STATE VARIABLES
  // ════════════════════════════════════════════════════════════════════════════

  // العمليات
  List<LoyaltyTransactionModel> _transactions = [];
  LoyaltyTransactionModel? _selectedTransaction;

  // النقاط
  int _userLoyaltyPoints = 0;
  int _totalEarnedPoints = 0;
  int _totalRedeemedPoints = 0;
  int _pendingPoints = 0;

  // الإعدادات
  LoyaltySettingsModel? _loyaltySettings;

  // كوبونات المعالم
  List<Map<String, dynamic>> _milestoneCoupons = [];

  // حالة التحميل والأخطاء
  bool _isLoading = false;
  bool _isLoadingTransactions = false;
  bool _isLoadingSettings = false;
  String? _error;

  // القنوات الفورية
  RealtimeChannel? _loyaltyChannel;
  RealtimeChannel? _settingsChannel;

  // منع التحميل المتكرر
  bool _isCurrentlyLoading = false;
  DateTime? _lastLoadTime;
  static const _minLoadInterval = Duration(seconds: 3);



  // ════════════════════════════════════════════════════════════════════
// STATE - المعالم والكوبونات
// ════════════════════════════════════════════════════════════════════
  List<MilestoneModel> _milestones = [];
  List<CouponModel> _coupons = [];

  bool _isLoadingMilestones = false;
  bool _isLoadingCoupons = false;

  // ════════════════════════════════════════════════════════════════════════════
  // GETTERS
  // ════════════════════════════════════════════════════════════════════════════

  List<LoyaltyTransactionModel> get transactions => _transactions;
  LoyaltyTransactionModel? get selectedTransaction => _selectedTransaction;

  int get totalPoints => _userLoyaltyPoints;
  int get totalEarnedPoints => _totalEarnedPoints;
  int get totalRedeemedPoints => _totalRedeemedPoints;
  int get pendingPoints => _pendingPoints;
  int get availablePoints => _userLoyaltyPoints;

  LoyaltySettingsModel? get loyaltySettings => _loyaltySettings;
  List<Map<String, dynamic>> get milestoneCoupons => _milestoneCoupons;

  bool get isLoading => _isLoading;
  bool get isLoadingTransactions => _isLoadingTransactions;
  bool get isLoadingSettings => _isLoadingSettings;
  String? get error => _error;

  bool get hasSettings => _loyaltySettings != null;
  bool get hasTransactions => _transactions.isNotEmpty;
  bool get hasPendingPoints => _pendingPoints > 0;

  /// تصفية العمليات حسب الحالة
  List<LoyaltyTransactionModel> get completedTransactions =>
      _transactions.where((t) => t.status == 'completed').toList();

  List<LoyaltyTransactionModel> get pendingTransactions =>
      _transactions.where((t) => t.status == 'pending').toList();

  List<LoyaltyTransactionModel> get cancelledTransactions =>
      _transactions.where((t) => t.status == 'cancelled').toList();

  /// تصفية حسب نوع العملية
  List<LoyaltyTransactionModel> get earnedTransactions =>
      completedTransactions
          .where((t) => t.transactionType == 'earned')
          .toList();

  List<LoyaltyTransactionModel> get bonusTransactions =>
      completedTransactions
          .where((t) => t.transactionType == 'bonus')
          .toList();

  List<LoyaltyTransactionModel> get redeemedTransactions =>
      completedTransactions
          .where((t) => t.transactionType == 'redeemed')
          .toList();

  List<LoyaltyTransactionModel> get expiredTransactions =>
      completedTransactions
          .where((t) => t.transactionType == 'expired')
          .toList();

  /// عدد العمليات
  int get transactionCount => _transactions.length;
  int get completedCount => completedTransactions.length;
  int get pendingCount => pendingTransactions.length;
  int get cancelledCount => cancelledTransactions.length;

  /// آخر عملية
  LoyaltyTransactionModel? get latestTransaction =>
      _transactions.isNotEmpty ? _transactions.first : null;


  // ════════════════════════════════════════════════════════════════════
// GETTERS - المعالم
// ════════════════════════════════════════════════════════════════════
  List<MilestoneModel> get milestones => _milestones;
  bool get isLoadingMilestones => _isLoadingMilestones;

  List<MilestoneModel> get achievedMilestones =>
      _milestones.where((m) => m.isAchieved).toList();

  List<MilestoneModel> get upcomingMilestones =>
      _milestones.where((m) => !m.isAchieved).toList();

  MilestoneModel? get nextMilestone =>
      upcomingMilestones.isEmpty ? null : upcomingMilestones.first;

  int get achievedMilestonesCount => achievedMilestones.length;

// ════════════════════════════════════════════════════════════════════
// GETTERS - الكوبونات
// ════════════════════════════════════════════════════════════════════
  List<CouponModel> get coupons => _coupons;
  bool get isLoadingCoupons => _isLoadingCoupons;

  List<CouponModel> get availableCoupons =>
      _coupons.where((c) => c.canUse).toList();

  List<CouponModel> get usedCoupons =>
      _coupons.where((c) => c.isUsed == true).toList();

  List<CouponModel> get expiredCoupons =>
      _coupons.where((c) => c.isExpiredNow).toList();

  int get availableCouponsCount => availableCoupons.length;
  int get usedCouponsCount => usedCoupons.length;

// ════════════════════════════════════════════════════════════════════
// جلب المعالم
// ════════════════════════════════════════════════════════════════════
  Future<void> fetchMilestones(int userId, {bool silent = false}) async {
    if (!silent) {
      _isLoadingMilestones = true;
      notifyListeners();
    }

    try {
      final response = await _supabase.rpc(
        'get_user_milestone_status',
        params: {'p_user_id': userId},
      );

      if (response is List) {
        _milestones = response
            .map((json) => MilestoneModel.fromJson(json as Map<String, dynamic>))
            .toList();


        if (nextMilestone != null) {
          print('   - Next: ${nextMilestone!.pointsRequired} pts '
              '(${nextMilestone!.pointsToGo} to go)');
        }
      } else {
        _milestones = [];
      }
    } catch (e) {
      _milestones = [];
    } finally {
      if (!silent) {
        _isLoadingMilestones = false;
        notifyListeners();
      }
    }
  }

// ════════════════════════════════════════════════════════════════════
// جلب الكوبونات
// ════════════════════════════════════════════════════════════════════
  Future<void> fetchMilestoneCoupons(int userId, {bool silent = false}) async {
    if (!silent) {
      _isLoadingCoupons = true;
      notifyListeners();
    }

    try {
      final response = await _supabase.rpc(
        'get_user_milestone_coupons',
        params: {'p_user_id': userId},
      );

      if (response is List) {
        _coupons = response
            .map((json) => CouponModel.fromMilestoneCoupon(
            json as Map<String, dynamic>))
            .toList();

      } else {
        _coupons = [];
      }
    } catch (e) {
      _coupons = [];
    } finally {
      if (!silent) {
        _isLoadingCoupons = false;
        notifyListeners();
      }
    }
  }

// ════════════════════════════════════════════════════════════════════
// تحديث loadLoyaltyData لتضمين المعالم والكوبونات
// ════════════════════════════════════════════════════════════════════
  @override
  Future<void> loadLoyaltyData(
      int userId, {
        bool silent = false,
        bool force = false,
      }) async {
    // ... الكود الموجود ...

    try {

      await Future.wait([
        fetchUserLoyaltyPoints(userId, silent: true),
        fetchTransactionsByUser(userId, silent: true),
        fetchStatistics(userId, silent: true),
        fetchMilestones(userId, silent: true),           // ✅ جديد
        fetchMilestoneCoupons(userId, silent: true),     // ✅ جديد
        if (_loyaltySettings == null) fetchLoyaltySettings(),
      ]);

      _printSummary();

    } catch (e) {
      _error = 'خطأ في جلب بيانات الولاء';
    } finally {
      _isCurrentlyLoading = false;
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

// ════════════════════════════════════════════════════════════════════
// تحديث _printSummary
// ════════════════════════════════════════════════════════════════════
  void _printSummary() {
  }

// ════════════════════════════════════════════════════════════════════
// تحديث reset
// ════════════════════════════════════════════════════════════════════
  @override
  void reset() {
    _transactions = [];
    _selectedTransaction = null;
    _userLoyaltyPoints = 0;
    _totalEarnedPoints = 0;
    _totalRedeemedPoints = 0;
    _pendingPoints = 0;
    _milestoneCoupons = [];
    _milestones = [];           // ✅ جديد
    _coupons = [];              // ✅ جديد
    _error = null;
    _isLoading = false;
    _isLoadingTransactions = false;
    _isLoadingSettings = false;
    _isLoadingMilestones = false;   // ✅ جديد
    _isLoadingCoupons = false;      // ✅ جديد
    _isCurrentlyLoading = false;
    _lastLoadTime = null;

    unsubscribeFromLoyaltyUpdates();
    unsubscribeFromSettingsUpdates();

    notifyListeners();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // LOYALTY TRANSACTIONS
  // ════════════════════════════════════════════════════════════════════════════

  /// جلب عملية بواسطة ID
  Future<void> fetchTransactionById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedTransaction = await repository.getTransactionById(id);
    } catch (e) {
      _error = 'خطأ في جلب بيانات العملية';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// جلب العمليات لمستخدم معين
  Future<void> fetchTransactionsByUser(
      int userId, {
        bool silent = false,
        int? limit,
        int? offset,
      }) async {
    if (!silent) {
      _isLoadingTransactions = true;
      notifyListeners();
    }

    try {
      _transactions = await repository.getTransactionsByUser(
        userId,
        limit: limit,
        offset: offset,
      );

      if (!silent) notifyListeners();
    } catch (e) {
      _error = 'خطأ في جلب عمليات المستخدم';
      if (!silent) notifyListeners();
    } finally {
      if (!silent) {
        _isLoadingTransactions = false;
        notifyListeners();
      }
    }
  }

  /// إنشاء عملية جديدة
  Future<LoyaltyTransactionModel?> createTransaction(
      LoyaltyTransactionModel transaction,
      ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final created = await repository.createTransaction(transaction);
      _transactions.insert(0, created);

      notifyListeners();
      return created;
    } catch (e) {
      _error = 'فشل إنشاء العملية';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث حالة عملية
  Future<bool> updateTransactionStatus(
      int transactionId,
      String newStatus, {
        String? description,
      }) async {
    try {
      final success = await repository.updateTransactionStatus(
        transactionId,
        newStatus,
        description: description,
      );

      if (success) {
        final index = _transactions.indexWhere((t) => t.id == transactionId);
        if (index >= 0) {
          _transactions[index] = _transactions[index].copyWith(
            status: newStatus,
            description: description ?? _transactions[index].description,
          );
          notifyListeners();
        }
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  /// حذف عملية
  Future<bool> deleteTransaction(int transactionId) async {
    try {
      await repository.deleteTransaction(transactionId);
      _transactions.removeWhere((t) => t.id == transactionId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // USER LOYALTY POINTS
  // ════════════════════════════════════════════════════════════════════════════

  /// جلب نقاط المستخدم من جدول users
  Future<void> fetchUserLoyaltyPoints(int userId, {bool silent = false}) async {
    try {
      _userLoyaltyPoints = await repository.getUserLoyaltyPoints(userId);
      if (!silent) notifyListeners();
    } catch (e) {
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // LOYALTY SETTINGS
  // ════════════════════════════════════════════════════════════════════════════

  /// جلب إعدادات الولاء
  Future<void> fetchLoyaltySettings({bool force = false}) async {
    if (_loyaltySettings != null && !force) {
      return;
    }

    _isLoadingSettings = true;
    notifyListeners();

    try {
      _loyaltySettings = await repository.getActiveLoyaltySettings();

      if (_loyaltySettings != null) {
      } else {
      }

      notifyListeners();
    } catch (e) {
    } finally {
      _isLoadingSettings = false;
      notifyListeners();
    }
  }

  /// حساب النقاط من المبلغ
  int calculateLoyaltyPoints(double amount) {
    if (_loyaltySettings == null) {
      return (amount / 1000).floor();
    }
    return _loyaltySettings!.calculatePointsFromAmount(amount);
  }

  /// حساب المبلغ من النقاط
  double calculateAmountFromPoints(int points) {
    if (_loyaltySettings == null) {
      return points * 1000.0;
    }
    return _loyaltySettings!.calculateAmountFromPoints(points);
  }

  /// هل المبلغ مؤهل؟
  bool isAmountEligible(double amount) {
    if (_loyaltySettings == null) return amount > 0;
    return _loyaltySettings!.isAmountEligible(amount);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // STATISTICS
  // ════════════════════════════════════════════════════════════════════════════

  /// جلب الإحصائيات
  /// جلب الإحصائيات (بدون pending)
  Future<void> fetchStatistics(int userId, {bool silent = false}) async {
    try {
      final results = await Future.wait([
        repository.getTotalEarnedPoints(userId),
        repository.getTotalRedeemedPoints(userId),
        // ✅ لا تجلب النقاط المعلقة
        // repository.getPendingPoints(userId),
      ]);

      _totalEarnedPoints = results[0];
      _totalRedeemedPoints = results[1];
      _pendingPoints = 0;  // ✅ دائماً صفر


      if (!silent) notifyListeners();
    } catch (e) {
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // MILESTONE COUPONS
  // ════════════════════════════════════════════════════════════════════════════

  /// جلب كوبونات المعالم
  Future<void> fetchUserMilestoneCoupons(int userId, {bool silent = false}) async {
    try {
      final data = await _supabase
          .rpc('get_user_milestone_coupons', params: {'p_user_id': userId});

      if (data is List) {
        _milestoneCoupons = List<Map<String, dynamic>>.from(data);
      } else {
        _milestoneCoupons = [];
      }

      if (!silent) notifyListeners();
    } catch (e) {
      _milestoneCoupons = [];
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // LOAD ALL data
  // ════════════════════════════════════════════════════════════════════════════

  /// تحميل جميع بيانات الولاء
  /// إعادة تحميل سريعة
  Future<void> refreshLoyaltyData(int userId) async {
    await loadLoyaltyData(userId, silent: true, force: true);
    notifyListeners();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // REALTIME SUBSCRIPTIONS
  // ════════════════════════════════════════════════════════════════════════════

  /// الاشتراك في تحديثات الولاء
  void subscribeToLoyaltyUpdates(int userId) {
    unsubscribeFromLoyaltyUpdates();


    try {
      _loyaltyChannel = _supabase
          .channel('loyalty_user_$userId')
          .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'loyalty_transactions',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: userId,
        ),
        callback: (payload) {
          _handleTransactionEvent(payload, userId);
        },
      )
          .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'users',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id',
          value: userId,
        ),
        callback: (payload) {
          fetchUserLoyaltyPoints(userId, silent: true).then((_) {
            notifyListeners();
          });
        },
      )
          .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'user_milestone_achievements',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: userId,
        ),
        callback: (payload) {
          fetchUserMilestoneCoupons(userId, silent: true).then((_) {
            notifyListeners();
          });
        },
      )
          .subscribe();

    } catch (e) {
    }
  }

  /// الاشتراك في تحديثات الإعدادات
  void subscribeToSettingsUpdates() {
    _settingsChannel?.unsubscribe();


    try {
      _settingsChannel = _supabase
          .channel('loyalty_settings_updates')
          .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'loyalty_settings',
        callback: (payload) {
          fetchLoyaltySettings(force: true);
        },
      )
          .subscribe();

    } catch (e) {
    }
  }

  /// معالجة أحداث Realtime للعمليات
  void _handleTransactionEvent(PostgresChangePayload payload, int userId) {
    try {
      if (payload.eventType == PostgresChangeEvent.insert) {
        if (payload.newRecord != null) {
          final newTx = LoyaltyTransactionModel.fromJson(payload.newRecord);
          _transactions.insert(0, newTx);
        }
      } else if (payload.eventType == PostgresChangeEvent.update) {
        if (payload.newRecord != null) {
          final updated = LoyaltyTransactionModel.fromJson(payload.newRecord);
          final index = _transactions.indexWhere((t) => t.id == updated.id);
          if (index >= 0) {
            _transactions[index] = updated;
          }
        }
      } else if (payload.eventType == PostgresChangeEvent.delete) {
        if (payload.oldRecord != null) {
          final id = payload.oldRecord['id'] as int;
          _transactions.removeWhere((t) => t.id == id);
        }
      }

      refreshLoyaltyData(userId);
    } catch (e) {
    }
  }

  /// إلغاء الاشتراك
  void unsubscribeFromLoyaltyUpdates() {
    _loyaltyChannel?.unsubscribe();
    _loyaltyChannel = null;
  }

  void unsubscribeFromSettingsUpdates() {
    _settingsChannel?.unsubscribe();
    _settingsChannel = null;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // UTILITY
  // ════════════════════════════════════════════════════════════════════════════

  /// مسح الخطأ
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// إعادة تعيين

  @override
  void dispose() {
    unsubscribeFromLoyaltyUpdates();
    unsubscribeFromSettingsUpdates();
    _isCurrentlyLoading = false;
    super.dispose();
  }
}


