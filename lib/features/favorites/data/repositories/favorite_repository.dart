// lib/features/favorites/data/repositories/favorite_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/favorite_model.dart';

class FavoriteRepository {
  final SupabaseClient client;

  FavoriteRepository(this.client);

  /// إضافة خدمة للمفضلة
  Future<FavoriteModel?> addToFavorites(int userId, int serviceId) async {
    try {
      final data = {
        'user_id': userId,
        'service_id': serviceId,
      };

      final response = await client
          .from('favorites')
          .insert(data)
          .select()
          .single();

      return FavoriteModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// حذف خدمة من المفضلة
  Future<bool> removeFromFavorites(int userId, int serviceId) async {
    try {
      await client
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('service_id', serviceId);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// جلب جميع المفضلات للمستخدم
  Future<List<FavoriteModel>> getUserFavorites(int userId) async {
    try {
      final response = await client
          .from('favorites')
          .select('''
            *,
            services(*)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => FavoriteModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// التحقق من وجود خدمة في المفضلة
  Future<bool> isFavorite(int userId, int serviceId) async {
    try {
      final response = await client
          .from('favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('service_id', serviceId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// عدد المفضلات
  Future<int> getFavoritesCount(int userId) async {
    try {
      final response = await client
          .from('favorites')
          .select('id')
          .eq('user_id', userId);

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }


  /// مسح كل المفضلات
  Future<bool> clearAllFavorites(int userId) async {
    try {
      await client
          .from('favorites')
          .delete()
          .eq('user_id', userId);

      return true;
    } catch (e) {
      return false;
    }
  }
}