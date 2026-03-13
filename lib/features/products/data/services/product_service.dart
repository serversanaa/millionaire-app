import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// جلب جميع المنتجات المتاحة
  Future<List<Product>> getAllProducts({
    int? limit,
    int? offset,
  }) async {
    try {
      debugPrint('🔍 ProductService: Starting getAllProducts...');

      // ✅ استخدام الجدول الأساسي بدلاً من View
      var query = _supabase
          .from('products')  // ❌ كان: products_full_details
          .select('''
            *,
            categories:category_id (
              id,
              name,
              name_en,
              icon
            )
          ''')
          .eq('is_available', true)
          .order('created_at', ascending: false);

      if (limit != null) query = query.limit(limit);
      if (offset != null) query = query.range(offset, offset + (limit ?? 10) - 1);

      final response = await query;

      debugPrint('✅ ProductService: Received response type: ${response.runtimeType}');
      debugPrint('✅ ProductService: Products count: ${(response as List).length}');

      final products = (response as List)
          .map((json) {
        try {
          return Product.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          debugPrint('❌ Error parsing product: $e');
          debugPrint('JSON: $json');
          rethrow;
        }
      })
          .toList();

      debugPrint('✅ ProductService: Successfully parsed ${products.length} products');
      return products;

    } catch (e, stackTrace) {
      debugPrint('❌ ProductService Error: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('فشل في جلب المنتجات: $e');
    }
  }

  /// جلب المنتجات حسب الفئة
  Future<List<Product>> getProductsByCategory(
      String categoryId, {
        int? limit,
        int? offset,
      }) async {
    try {
      debugPrint('🔍 ProductService: Fetching products for category: $categoryId');

      var query = _supabase
          .from('products')
          .select('''
            *,
            categories:category_id (
              id,
              name,
              name_en,
              icon
            )
          ''')
          .eq('category_id', categoryId)
          .eq('is_available', true)
          .order('created_at', ascending: false);

      if (limit != null) query = query.limit(limit);
      if (offset != null) query = query.range(offset, offset + (limit ?? 10) - 1);

      final response = await query;

      debugPrint('✅ Found ${(response as List).length} products in category');

      return (response as List)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching products by category: $e');
      throw Exception('فشل في جلب منتجات الفئة: $e');
    }
  }

  /// جلب منتج واحد بالتفصيل
  Future<Product?> getProductById(String productId) async {
    try {
      debugPrint('🔍 ProductService: Fetching product: $productId');

      final response = await _supabase
          .from('products')
          .select('''
            *,
            categories:category_id (
              id,
              name,
              name_en,
              icon
            )
          ''')
          .eq('id', productId)
          .single();

      return Product.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Error fetching product by id: $e');
      throw Exception('فشل في جلب المنتج: $e');
    }
  }

  /// جلب المنتجات المميزة
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    try {
      debugPrint('🔍 ProductService: Fetching featured products...');

      final response = await _supabase
          .from('products')
          .select('''
            *,
            categories:category_id (
              id,
              name,
              name_en,
              icon
            )
          ''')
          .eq('is_featured', true)
          .eq('is_available', true)
          .order('created_at', ascending: false)
          .limit(limit);

      debugPrint('✅ Found ${(response as List).length} featured products');

      return (response as List)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching featured products: $e');
      throw Exception('فشل في جلب المنتجات المميزة: $e');
    }
  }

  /// البحث عن منتجات
  Future<List<Product>> searchProducts(String query) async {
    try {
      debugPrint('🔍 ProductService: Searching for: $query');

      final response = await _supabase
          .from('products')
          .select('''
            *,
            categories:category_id (
              id,
              name,
              name_en,
              icon
            )
          ''')
          .or('name.ilike.%$query%,name_en.ilike.%$query%,description.ilike.%$query%')
          .eq('is_available', true)
          .limit(50);

      debugPrint('✅ Search found ${(response as List).length} products');

      return (response as List)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Search error: $e');
      throw Exception('فشل في البحث: $e');
    }
  }

  /// إضافة منتج جديد (Admin فقط)
  Future<Product> createProduct(Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from('products')
          .insert(data)
          .select()
          .single();

      return Product.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('فشل في إضافة المنتج: $e');
    }
  }

  /// تحديث منتج (Admin فقط)
  Future<Product> updateProduct(
      String productId,
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await _supabase
          .from('products')
          .update(data)
          .eq('id', productId)
          .select()
          .single();

      return Product.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('فشل في تحديث المنتج: $e');
    }
  }

  /// حذف منتج (Admin فقط)
  Future<void> deleteProduct(String productId) async {
    try {
      await _supabase.from('products').delete().eq('id', productId);
    } catch (e) {
      throw Exception('فشل في حذف المنتج: $e');
    }
  }

  /// زيادة عدد المشاهدات
  Future<void> incrementViews(String productId) async {
    try {
      await _supabase.rpc('increment_product_views', params: {
        'product_id': productId,
      });
    } catch (e) {
      debugPrint('⚠️ Failed to increment views: $e');
    }
  }
}
