// lib/features/products/presentation/providers/product_provider.dart

import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _service = ProductService();

  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<Product> _searchResults = [];
  bool _isLoading = false;
  bool _isFeaturedLoading = false;
  bool _isSearching = false;
  String? _errorMessage;
  Product? _selectedProduct;

  // Getters
  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isFeaturedLoading => _isFeaturedLoading;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  Product? get selectedProduct => _selectedProduct;

  /// جلب جميع المنتجات
  Future<void> fetchProducts({int? limit, int? offset}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _service.getAllProducts(limit: limit, offset: offset);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// جلب منتجات حسب الفئة
  Future<void> fetchProductsByCategory(
      String categoryId, {
        int? limit,
        int? offset,
      }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _service.getProductsByCategory(
        categoryId,
        limit: limit,
        offset: offset,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// جلب المنتجات المميزة
  Future<void> fetchFeaturedProducts({int limit = 10}) async {
    _isFeaturedLoading = true;
    notifyListeners();

    try {
      _featuredProducts = await _service.getFeaturedProducts(limit: limit);
      _isFeaturedLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isFeaturedLoading = false;
      notifyListeners();
    }
  }

  /// البحث عن منتجات
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      _searchResults = await _service.searchProducts(query);
      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isSearching = false;
      notifyListeners();
    }
  }

  /// مسح نتائج البحث
  void clearSearch() {
    _searchResults = [];
    _isSearching = false;
    notifyListeners();
  }

  /// اختيار منتج
  void selectProduct(Product? product) {
    _selectedProduct = product;
    if (product != null) {
      _service.incrementViews(product.id);
    }
    notifyListeners();
  }

  /// جلب منتج حسب ID
  Future<Product?> getProductById(String productId) async {
    try {
      final product = await _service.getProductById(productId);
      return product;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// إضافة منتج جديد (Admin)
  Future<bool> createProduct(Map<String, dynamic> data) async {
    try {
      final newProduct = await _service.createProduct(data);
      _products.insert(0, newProduct);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// تحديث منتج (Admin)
  Future<bool> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      final updatedProduct = await _service.updateProduct(productId, data);
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// حذف منتج (Admin)
  Future<bool> deleteProduct(String productId) async {
    try {
      await _service.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
