import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/favorite_repository.dart';
import '../../domain/models/favorite_model.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteRepository favoriteRepository;
  final SupabaseClient _supabase = Supabase.instance.client;

  FavoriteProvider({required this.favoriteRepository});

  List<FavoriteModel> _favorites = [];
  List<FavoriteModel> get favorites => _favorites;

  Set<int> _favoriteServiceIds = {};
  Set<int> get favoriteServiceIds => _favoriteServiceIds;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int get favoritesCount => _favorites.length;

  // ✅ قناة Realtime
  RealtimeChannel? _realtimeChannel;

  /// جلب المفضلات
  Future<void> fetchFavorites(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _favorites = await favoriteRepository.getUserFavorites(userId);
      _favoriteServiceIds = _favorites.map((f) => f.serviceId).toSet();
    } catch (e) {
      _error = 'فشل تحميل المفضلات';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// التحقق من وجود خدمة في المفضلة
  bool isFavorite(int serviceId) {
    return _favoriteServiceIds.contains(serviceId);
  }

  /// إضافة/حذف من المفضلة (Toggle)
  Future<bool> toggleFavorite(int userId, int serviceId) async {
    try {
      final isFav = isFavorite(serviceId);

      if (isFav) {
        final success = await favoriteRepository.removeFromFavorites(userId, serviceId);
        if (success) {
          _favorites.removeWhere((f) => f.serviceId == serviceId);
          _favoriteServiceIds.remove(serviceId);

          // ✅ سيتم التحديث تلقائياً عبر Realtime
          notifyListeners();
          return true;
        }
      } else {
        final favorite = await favoriteRepository.addToFavorites(userId, serviceId);
        if (favorite != null) {
          _favorites.insert(0, favorite);
          _favoriteServiceIds.add(serviceId);

          // ✅ سيتم التحديث تلقائياً عبر Realtime
          notifyListeners();
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// مسح كل المفضلات
  Future<bool> clearAllFavorites(int userId) async {
    try {
      final success = await favoriteRepository.clearAllFavorites(userId);
      if (success) {
        _favorites.clear();
        _favoriteServiceIds.clear();
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// ✅ الاشتراك في تحديثات مفضلات المستخدم
  void subscribeToUserFavorites(int userId) {
    unsubscribeFromFavorites();


    _realtimeChannel = _supabase
        .channel('favorites_user_$userId')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'favorites',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) {

        if (payload.eventType == PostgresChangeEvent.insert) {
          // مفضلة جديدة
          if (payload.newRecord != null) {
            final newFavorite = FavoriteModel.fromJson(payload.newRecord);
            _favorites.insert(0, newFavorite);
            _favoriteServiceIds.add(newFavorite.serviceId);
            notifyListeners();
          }
        } else if (payload.eventType == PostgresChangeEvent.delete) {
          // حذف مفضلة
          if (payload.oldRecord != null) {
            final deletedServiceId = payload.oldRecord['service_id'];
            _favorites.removeWhere((f) => f.serviceId == deletedServiceId);
            _favoriteServiceIds.remove(deletedServiceId);
            notifyListeners();
          }
        }
      },
    )
        .subscribe();
  }

  /// ✅ إلغاء الاشتراك
  void unsubscribeFromFavorites() {
    if (_realtimeChannel != null) {
      _realtimeChannel!.unsubscribe();
      _realtimeChannel = null;
    }
  }

  /// مسح البيانات
  void clear() {
    _favorites = [];
    _favoriteServiceIds = {};
    _error = null;
    unsubscribeFromFavorites();
    notifyListeners();
  }

  @override
  void dispose() {
    unsubscribeFromFavorites();
    super.dispose();
  }
}