import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/service_model.dart';
import '../../domain/models/service_category_model.dart';
import '../../data/repositories/services_repository.dart';

class ServicesProvider extends ChangeNotifier {
  final ServicesRepository servicesRepository;
  final SupabaseClient _supabase = Supabase.instance.client;

  ServicesProvider({required this.servicesRepository});

  List<ServiceCategoryModel> _categories = [];
  List<ServiceCategoryModel> get categories => _categories;

  List<ServiceModel> _allServices = [];
  List<ServiceModel> _services = [];
  List<ServiceModel> get services => _services;

  ServiceModel? _selectedService;
  ServiceModel? get selectedService => _selectedService;

  int? _selectedCategoryId;
  int? get selectedCategoryId => _selectedCategoryId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ✅ قنوات Realtime
  RealtimeChannel? _servicesChannel;
  RealtimeChannel? _categoriesChannel;

  /// جلب جميع الفئات
  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await servicesRepository.getCategories();
    } catch (e) {
      _error = 'حدث خطأ أثناء تحميل فئات الخدمات.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث البيانات مع الحفاظ على الفلتر الحالي
  Future<void> refresh({bool onlyActive = true}) async {
    final currentCategory = _selectedCategoryId;

    await fetchCategories();
    await fetchServices(onlyActive: onlyActive);

    if (currentCategory != null) {
      filterByCategory(currentCategory);
    }
  }

  /// جلب جميع الخدمات
  Future<void> fetchServices({bool onlyActive = true}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allServices = await servicesRepository.getServices(onlyActive: onlyActive);
      _services = _allServices;
    } catch (e) {
      _error = 'حدث خطأ أثناء تحميل الخدمات.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// فلترة الخدمات حسب التصنيف
  void filterByCategory(int? categoryId) {
    _selectedCategoryId = categoryId;

    if (categoryId == null) {
      _services = _allServices;
    } else {
      _services = _allServices
          .where((service) => service.categoryId == categoryId)
          .toList();
    }

    notifyListeners();
  }

  /// إعادة تعيين الفلتر
  void resetFilter() {
    _selectedCategoryId = null;
    _services = _allServices;
    notifyListeners();
  }

  /// جلب خدمة واحدة بواسطة ID
  Future<void> fetchServiceById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedService = await servicesRepository.getServiceById(id);
    } catch (e) {
      _error = 'حدث خطأ أثناء تحميل بيانات الخدمة.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إنشاء خدمة جديدة
  Future<bool> createService(ServiceModel service) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final created = await servicesRepository.createService(service);
      _allServices.add(created);
      _services.add(created);

      // ✅ سيتم التحديث تلقائياً عبر Realtime
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'فشل إنشاء الخدمة.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث خدمة معينة
  Future<bool> updateService(int id, Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await servicesRepository.updateService(id, updates);
      if (updated != null) {
        final allIndex = _allServices.indexWhere((s) => s.id == id);
        if (allIndex >= 0) {
          _allServices[allIndex] = updated;
        }

        final index = _services.indexWhere((s) => s.id == id);
        if (index >= 0) {
          _services[index] = updated;
        }

        // ✅ سيتم التحديث تلقائياً عبر Realtime
        notifyListeners();
        return true;
      } else {
        _error = 'الخدمة غير موجودة.';
        return false;
      }
    } catch (e) {
      _error = 'فشل تحديث الخدمة.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// حذف خدمة بواسطة ID
  Future<bool> deleteService(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await servicesRepository.deleteService(id);
      _allServices.removeWhere((s) => s.id == id);
      _services.removeWhere((s) => s.id == id);

      // ✅ سيتم التحديث تلقائياً عبر Realtime
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'فشل حذف الخدمة.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ الاشتراك في تحديثات جميع الخدمات
  void subscribeToServicesChanges() {
    unsubscribeFromServices();


    _servicesChannel = _supabase
        .channel('services_changes')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'services',
      callback: (payload) {

        // إعادة جلب جميع الخدمات
        fetchServices();
      },
    )
        .subscribe();
  }

  /// ✅ الاشتراك في تحديثات الفئات
  void subscribeToCategories() {
    if (_categoriesChannel != null) {
      _categoriesChannel!.unsubscribe();
    }


    _categoriesChannel = _supabase
        .channel('categories_changes')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'service_categories',
      callback: (payload) {

        // إعادة جلب الفئات
        fetchCategories();
      },
    )
        .subscribe();
  }

  /// ✅ الاشتراك في تحديثات خدمة واحدة
  void subscribeToServiceChanges(int id) {
    unsubscribeFromServices();


    _servicesChannel = _supabase
        .channel('service_changes_$id')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'services',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: id,
      ),
      callback: (payload) {

        if (payload.eventType == PostgresChangeEvent.update) {
          if (payload.newRecord != null) {
            _selectedService = ServiceModel.fromJson(payload.newRecord);
            notifyListeners();
          }
        }
      },
    )
        .subscribe();
  }

  /// ✅ إلغاء الاشتراك من الخدمات
  void unsubscribeFromServices() {
    if (_servicesChannel != null) {
      _servicesChannel!.unsubscribe();
      _servicesChannel = null;
    }
  }

  /// ✅ إلغاء الاشتراك من الفئات
  void unsubscribeFromCategories() {
    if (_categoriesChannel != null) {
      _categoriesChannel!.unsubscribe();
      _categoriesChannel = null;
    }
  }

  @override
  void dispose() {
    unsubscribeFromServices();
    unsubscribeFromCategories();
    super.dispose();
  }
}