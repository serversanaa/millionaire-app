// lib/features/products/presentation/providers/product_category_provider.dart

import 'package:flutter/material.dart';
import '../../data/models/product_category_model.dart';
import '../../data/services/product_category_service.dart';

class ProductCategoryProvider with ChangeNotifier {
  final ProductCategoryService _service = ProductCategoryService();

  List<ProductCategory> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  ProductCategory? _selectedCategory;

  // Getters
  List<ProductCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProductCategory? get selectedCategory => _selectedCategory;

  /// جلب جميع الفئات
  Future<void> fetchCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _service.getActiveCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// اختيار فئة
  void selectCategory(ProductCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// إلغاء اختيار الفئة
  void clearSelectedCategory() {
    _selectedCategory = null;
    notifyListeners();
  }

  /// جلب فئة حسب ID
  Future<ProductCategory?> getCategoryById(String categoryId) async {
    try {
      return await _service.getCategoryById(categoryId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// إضافة فئة جديدة (Admin)
  Future<bool> createCategory(Map<String, dynamic> data) async {
    try {
      final newCategory = await _service.createCategory(data);
      _categories.add(newCategory);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// تحديث فئة (Admin)
  Future<bool> updateCategory(String categoryId, Map<String, dynamic> data) async {
    try {
      final updatedCategory = await _service.updateCategory(categoryId, data);
      final index = _categories.indexWhere((c) => c.id == categoryId);
      if (index != -1) {
        _categories[index] = updatedCategory;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// حذف فئة (Admin)
  Future<bool> deleteCategory(String categoryId) async {
    try {
      await _service.deleteCategory(categoryId);
      _categories.removeWhere((c) => c.id == categoryId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
