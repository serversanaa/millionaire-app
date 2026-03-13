// lib/features/products/data/services/product_category_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_category_model.dart';

class ProductCategoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// جلب جميع فئات المنتجات النشطة مع عدد المنتجات
  Future<List<ProductCategory>> getActiveCategories() async {
    try {
      final response = await _supabase
          .from('products_count_by_category')
          .select()
          .eq('is_active', true)
          .order('display_order', ascending: true);

      return (response as List)
          .map((json) => ProductCategory.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب فئات المنتجات: $e');
    }
  }

  /// جلب فئة واحدة حسب ID
  Future<ProductCategory?> getCategoryById(String categoryId) async {
    try {
      final response = await _supabase
          .from('product_categories')
          .select()
          .eq('id', categoryId)
          .single();

      return ProductCategory.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('فشل في جلب الفئة: $e');
    }
  }

  /// إضافة فئة جديدة (Admin فقط)
  Future<ProductCategory> createCategory(Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from('product_categories')
          .insert(data)
          .select()
          .single();

      return ProductCategory.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('فشل في إضافة الفئة: $e');
    }
  }

  /// تحديث فئة (Admin فقط)
  Future<ProductCategory> updateCategory(
      String categoryId,
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await _supabase
          .from('product_categories')
          .update(data)
          .eq('id', categoryId)
          .select()
          .single();

      return ProductCategory.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('فشل في تحديث الفئة: $e');
    }
  }

  /// حذف فئة (Admin فقط)
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _supabase
          .from('product_categories')
          .delete()
          .eq('id', categoryId);
    } catch (e) {
      throw Exception('فشل في حذف الفئة: $e');
    }
  }
}
