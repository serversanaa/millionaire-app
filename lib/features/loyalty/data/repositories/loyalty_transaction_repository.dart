// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../domain/models/loyalty_transaction_model.dart';
// import '../../domain/entities/reward.dart';
// import '../../domain/entities/reward_redemption.dart';
//
// class LoyaltyTransactionRepository {
//   final SupabaseClient client;
//
//   LoyaltyTransactionRepository(this.client);
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // LOYALTY TRANSACTIONS
//   // ════════════════════════════════════════════════════════════════════════════
//
//   /// جلب عملية ولاء بواسطة ID
//   Future<LoyaltyTransactionModel?> getTransactionById(int id) async {
//     final data = await client
//         .from('loyalty_transactions')
//         .select()
//         .eq('id', id)
//         .maybeSingle();
//
//     if (data == null) return null;
//
//     if (data is Map<String, dynamic>) {
//       return LoyaltyTransactionModel.fromJson(data);
//     }
//     if (data is Map) {
//       return LoyaltyTransactionModel.fromJson(Map<String, dynamic>.from(data));
//     }
//
//     throw Exception('تنسيق بيانات عملية الولاء غير صحيح');
//   }
//
//   /// جلب جميع العمليات لمستخدم معين
//   Future<List<LoyaltyTransactionModel>> getTransactionsByUser(
//       int userId) async {
//     final data = await client
//         .from('loyalty_transactions')
//         .select()
//         .eq('user_id', userId)
//         .order('created_at', ascending: false);
//
//     if (data == null) return [];
//
//     return (data as List).map((e) {
//       if (e is Map<String, dynamic>) {
//         return LoyaltyTransactionModel.fromJson(e);
//       }
//       if (e is Map) {
//         return LoyaltyTransactionModel.fromJson(Map<String, dynamic>.from(e));
//       }
//       throw Exception('تنسيق أحد عمليات الولاء غير صحيح');
//     }).toList();
//   }
//
//   /// إنشاء عملية جديدة
//   Future<LoyaltyTransactionModel> createTransaction(
//       LoyaltyTransactionModel transaction) async {
//     final data = await client
//         .from('loyalty_transactions')
//         .insert(transaction.toJson())
//         .select()
//         .single();
//
//     if (data is Map<String, dynamic>) {
//       return LoyaltyTransactionModel.fromJson(data);
//     }
//     if (data is Map) {
//       return LoyaltyTransactionModel.fromJson(Map<String, dynamic>.from(data));
//     }
//
//     throw Exception('فشل إنشاء عملية الولاء');
//   }
//
//   /// تحديث عملية
//   Future<LoyaltyTransactionModel?> updateTransaction(int id,
//       Map<String, dynamic> updates) async {
//     final data = await client
//         .from('loyalty_transactions')
//         .update(updates)
//         .eq('id', id)
//         .select()
//         .maybeSingle();
//
//     if (data == null) return null;
//
//     if (data is Map<String, dynamic>) {
//       return LoyaltyTransactionModel.fromJson(data);
//     }
//     if (data is Map) {
//       return LoyaltyTransactionModel.fromJson(Map<String, dynamic>.from(data));
//     }
//
//     throw Exception('تنسيق بيانات عملية الولاء المحدّثة غير صحيح');
//   }
//
//   /// حذف عملية
//   Future<void> deleteTransaction(int id) async {
//     await client.from('loyalty_transactions').delete().eq('id', id);
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // USER LOYALTY POINTS
//   // ════════════════════════════════════════════════════════════════════════════
//
//   /// جلب نقاط الولاء من جدول users
//   Future<int> getUserLoyaltyPoints(int userId) async {
//     try {
//       final data = await client
//           .from('users')
//           .select('loyalty_points')
//           .eq('id', userId)
//           .single();
//
//       if (data is Map<String, dynamic>) {
//         final points = data['loyalty_points'];
//         if (points is int) return points;
//         if (points is num) return points.toInt();
//         return 0;
//       }
//
//       return 0;
//     } catch (e) {
//       print('❌ Error fetching user loyalty points: $e');
//       return 0;
//     }
//   }
//
// }





import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/loyalty_transaction_model.dart';
import '../../domain/models/loyalty_settings_model.dart';

class LoyaltyTransactionRepository {
  final SupabaseClient client;

  LoyaltyTransactionRepository(this.client);

  // ════════════════════════════════════════════════════════════════════════════
  // LOYALTY TRANSACTIONS - CRUD
  // ════════════════════════════════════════════════════════════════════════════

  /// جلب عملية ولاء بواسطة ID
  Future<LoyaltyTransactionModel?> getTransactionById(int id) async {
    try {
      final data = await client
          .from('loyalty_transactions')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (data == null) return null;
      return LoyaltyTransactionModel.fromJson(_ensureMap(data));
    } catch (e) {
      rethrow;
    }
  }

  /// جلب جميع العمليات لمستخدم معين
  Future<List<LoyaltyTransactionModel>> getTransactionsByUser(
      int userId, {
        int? limit,
        int? offset,
      }) async {
    try {
      var query = client
          .from('loyalty_transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final data = await query;
      if (data == null || data is! List) return [];

      return data
          .map((e) => LoyaltyTransactionModel.fromJson(_ensureMap(e)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// جلب العمليات حسب الحالة
  Future<List<LoyaltyTransactionModel>> getTransactionsByStatus(
      int userId,
      String status,
      ) async {
    try {
      final data = await client
          .from('loyalty_transactions')
          .select()
          .eq('user_id', userId)
          .eq('status', status)
          .order('created_at', ascending: false);

      if (data == null || data is! List) return [];

      return data
          .map((e) => LoyaltyTransactionModel.fromJson(_ensureMap(e)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// جلب العمليات حسب النوع
  Future<List<LoyaltyTransactionModel>> getTransactionsByType(
      int userId,
      String transactionType,
      ) async {
    try {
      final data = await client
          .from('loyalty_transactions')
          .select()
          .eq('user_id', userId)
          .eq('transaction_type', transactionType)
          .order('created_at', ascending: false);

      if (data == null || data is! List) return [];

      return data
          .map((e) => LoyaltyTransactionModel.fromJson(_ensureMap(e)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// جلب العمليات المرتبطة بموعد معين
  Future<List<LoyaltyTransactionModel>> getTransactionsByAppointment(
      int appointmentId,
      ) async {
    try {
      final data = await client
          .from('loyalty_transactions')
          .select()
          .eq('appointment_id', appointmentId)
          .order('created_at', ascending: false);

      if (data == null || data is! List) return [];

      return data
          .map((e) => LoyaltyTransactionModel.fromJson(_ensureMap(e)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// جلب العمليات حسب المرجع
  Future<List<LoyaltyTransactionModel>> getTransactionsByReference(
      String referenceType,
      int referenceId,
      ) async {
    try {
      final data = await client
          .from('loyalty_transactions')
          .select()
          .eq('reference_type', referenceType)
          .eq('reference_id', referenceId)
          .order('created_at', ascending: false);

      if (data == null || data is! List) return [];

      return data
          .map((e) => LoyaltyTransactionModel.fromJson(_ensureMap(e)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// إنشاء عملية جديدة
  Future<LoyaltyTransactionModel> createTransaction(
      LoyaltyTransactionModel transaction,
      ) async {
    try {
      final json = transaction.toJson();
      if (json['id'] == 0) json.remove('id');

      final data = await client
          .from('loyalty_transactions')
          .insert(json)
          .select()
          .single();

      return LoyaltyTransactionModel.fromJson(_ensureMap(data));
    } catch (e) {
      rethrow;
    }
  }

  /// تحديث عملية
  Future<LoyaltyTransactionModel?> updateTransaction(
      int id,
      Map<String, dynamic> updates,
      ) async {
    try {
      final data = await client
          .from('loyalty_transactions')
          .update(updates)
          .eq('id', id)
          .select()
          .maybeSingle();

      if (data == null) return null;

      return LoyaltyTransactionModel.fromJson(_ensureMap(data));
    } catch (e) {
      rethrow;
    }
  }

  /// تحديث حالة عملية
  Future<bool> updateTransactionStatus(
      int id,
      String newStatus, {
        String? description,
      }) async {
    try {
      final updates = <String, dynamic>{'status': newStatus};
      if (description != null) updates['description'] = description;

      await updateTransaction(id, updates);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// حذف عملية
  Future<void> deleteTransaction(int id) async {
    try {
      await client.from('loyalty_transactions').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // USER LOYALTY POINTS
  // ════════════════════════════════════════════════════════════════════════════

  /// جلب نقاط الولاء من جدول users
  Future<int> getUserLoyaltyPoints(int userId) async {
    try {
      final data = await client
          .from('users')
          .select('loyalty_points')
          .eq('id', userId)
          .single();

      final map = _ensureMap(data);
      final points = map['loyalty_points'];

      if (points is int) return points;
      if (points is num) return points.toInt();
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// تحديث نقاط الولاء في جدول users
  Future<bool> updateUserLoyaltyPoints(int userId, int newPoints) async {
    try {
      await client
          .from('users')
          .update({'loyalty_points': newPoints})
          .eq('id', userId);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// إضافة نقاط للمستخدم
  Future<bool> addPointsToUser(int userId, int pointsToAdd) async {
    try {
      final currentPoints = await getUserLoyaltyPoints(userId);
      final newPoints = currentPoints + pointsToAdd;
      return await updateUserLoyaltyPoints(userId, newPoints);
    } catch (e) {
      return false;
    }
  }

  /// خصم نقاط من المستخدم
  Future<bool> deductPointsFromUser(int userId, int pointsToDeduct) async {
    try {
      final currentPoints = await getUserLoyaltyPoints(userId);

      if (currentPoints < pointsToDeduct) {
        return false;
      }

      final newPoints = currentPoints - pointsToDeduct;
      return await updateUserLoyaltyPoints(userId, newPoints);
    } catch (e) {
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // LOYALTY SETTINGS
  // ════════════════════════════════════════════════════════════════════════════

  /// جلب إعدادات الولاء النشطة
  Future<LoyaltySettingsModel?> getActiveLoyaltySettings() async {
    try {
      final data = await client
          .from('loyalty_settings')
          .select()
          .eq('is_active', true)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data == null) return null;
      return LoyaltySettingsModel.fromJson(_ensureMap(data));
    } catch (e) {
      return null;
    }
  }

  /// جلب جميع إعدادات الولاء
  Future<List<LoyaltySettingsModel>> getAllLoyaltySettings() async {
    try {
      final data = await client
          .from('loyalty_settings')
          .select()
          .order('updated_at', ascending: false);

      if (data == null || data is! List) return [];

      return data
          .map((e) => LoyaltySettingsModel.fromJson(_ensureMap(e)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // STATISTICS
  // ════════════════════════════════════════════════════════════════════════════

  /// حساب إجمالي النقاط المكتسبة (completed فقط)
  Future<int> getTotalEarnedPoints(int userId) async {
    try {
      final data = await client
          .from('loyalty_transactions')
          .select('points_amount')
          .eq('user_id', userId)
          .eq('status', 'completed')
          .or('transaction_type.eq.earned,transaction_type.eq.bonus');

      if (data == null || data is! List) return 0;

      int total = 0;
      for (var row in data) {
        final map = _ensureMap(row);
        total += (map['points_amount'] as int?) ?? 0;
      }

      return total;
    } catch (e) {
      return 0;
    }
  }

  /// حساب إجمالي النقاط المستهلكة (completed فقط)
  Future<int> getTotalRedeemedPoints(int userId) async {
    try {
      final data = await client
          .from('loyalty_transactions')
          .select('points_amount')
          .eq('user_id', userId)
          .eq('status', 'completed')
          .or('transaction_type.eq.redeemed,transaction_type.eq.expired');

      if (data == null || data is! List) return 0;

      int total = 0;
      for (var row in data) {
        final map = _ensureMap(row);
        total += (map['points_amount'] as int?) ?? 0;
      }

      return total;
    } catch (e) {
      return 0;
    }
  }

  /// حساب النقاط المعلقة
  Future<int> getPendingPoints(int userId) async {
    try {
      final data = await client
          .from('loyalty_transactions')
          .select('points_amount')
          .eq('user_id', userId)
          .eq('status', 'pending')
          .or('transaction_type.eq.earned,transaction_type.eq.bonus');

      if (data == null || data is! List) return 0;

      int total = 0;
      for (var row in data) {
        final map = _ensureMap(row);
        total += (map['points_amount'] as int?) ?? 0;
      }

      return total;
    } catch (e) {
      return 0;
    }
  }

  /// عدد العمليات حسب الحالة
  Future<int> getTransactionCountByStatus(int userId, String status) async {
    try {
      final data = await client
          .from('loyalty_transactions')
          .select('id')
          .eq('user_id', userId)
          .eq('status', status);

      return (data as List?)?.length ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // EXPIRY MANAGEMENT
  // ════════════════════════════════════════════════════════════════════════════

  /// جلب العمليات القريبة من الانتهاء
  Future<List<LoyaltyTransactionModel>> getExpiringTransactions(
      int userId,
      int daysBeforeExpiry,
      ) async {
    try {
      final expiryDate = DateTime.now().add(Duration(days: daysBeforeExpiry));

      final data = await client
          .from('loyalty_transactions')
          .select()
          .eq('user_id', userId)
          .eq('status', 'completed')
          .or('transaction_type.eq.earned,transaction_type.eq.bonus')
          .lte('expiry_date', expiryDate.toIso8601String().split('T')[0])
          .order('expiry_date', ascending: true);

      if (data == null || data is! List) return [];

      return data
          .map((e) => LoyaltyTransactionModel.fromJson(_ensureMap(e)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // BATCH OPERATIONS
  // ════════════════════════════════════════════════════════════════════════════

  /// إنشاء عدة عمليات دفعة واحدة
  Future<List<LoyaltyTransactionModel>> createTransactionsBatch(
      List<LoyaltyTransactionModel> transactions,
      ) async {
    try {
      final jsonList = transactions.map((t) {
        final json = t.toJson();
        if (json['id'] == 0) json.remove('id');
        return json;
      }).toList();

      final data = await client
          .from('loyalty_transactions')
          .insert(jsonList)
          .select();

      if (data == null || data is! List) return [];

      return data
          .map((e) => LoyaltyTransactionModel.fromJson(_ensureMap(e)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ════════════════════════════════════════════════════════════════════════════

  /// تحويل أي Map إلى Map<String, dynamic>
  Map<String, dynamic> _ensureMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw Exception('Invalid data format: expected Map, got ${data.runtimeType}');
  }
}