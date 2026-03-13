import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../data/repositories/packages_repository.dart';
import '../../domain/models/package_model.dart';
import '../../domain/models/package_service_model.dart';

/// ═══════════════════════════════════════════════════════════════
/// 📦 Packages Provider مع Realtime Support
/// State Management للباقات + الاستماع للتحديثات الفورية
/// ═══════════════════════════════════════════════════════════════

class PackagesProvider extends ChangeNotifier {
  final PackagesRepository _repository;

  // ═══════════════════════════════════════════════════════════════
  // State Variables
  // ═══════════════════════════════════════════════════════════════

  List<PackageModel> _packages = [];
  List<PackageModel> _featuredPackages = [];
  List<PackageModel> _seasonalPackages = [];
  PackageModel? _selectedPackage;

  bool _isLoading = false;
  bool _isRealtimeInitialized = false;
  String? _error;

  Map<String, int> _statistics = {
    'total': 0,
    'active': 0,
    'inactive': 0,
    'featured': 0,
    'seasonal': 0,
  };

  // Realtime Subscriptions
  StreamSubscription? _packagesSubscription;
  StreamSubscription? _packageUpdateSubscription;
  StreamSubscription? _serviceUpdateSubscription;

  PackagesProvider(this._repository);

  // ═══════════════════════════════════════════════════════════════
  // Getters
  // ═══════════════════════════════════════════════════════════════

  List<PackageModel> get packages => _packages;
  List<PackageModel> get featuredPackages => _featuredPackages;
  List<PackageModel> get seasonalPackages => _seasonalPackages;
  PackageModel? get selectedPackage => _selectedPackage;

  bool get isLoading => _isLoading;
  bool get isRealtimeInitialized => _isRealtimeInitialized;
  bool get hasError => _error != null;
  String? get error => _error;

  Map<String, int> get statistics => _statistics;

  int get packagesCount => _packages.length;
  int get featuredCount => _featuredPackages.length;
  int get seasonalCount => _seasonalPackages.length;

  // ═══════════════════════════════════════════════════════════════
  // 📡 Initialize Realtime
  // ═══════════════════════════════════════════════════════════════

  Future<void> initializeRealtime() async {
    if (_isRealtimeInitialized) {
      return;
    }

    try {

      // 1️⃣ Initialize repository realtime
      await _repository.initializeRealtime();

      // 2️⃣ Subscribe to packages stream
      _packagesSubscription = _repository.packagesStream.listen(
            (packages) {
          _packages = packages;
          _filterPackages();
          notifyListeners();
        },
        onError: (error) {
          _error = error.toString();
          notifyListeners();
        },
      );

      // 3️⃣ Subscribe to package update stream
      _packageUpdateSubscription = _repository.packageUpdateStream.listen(
            (package) {
          _handlePackageUpdate(package);
        },
        onError: (error) {
        },
      );

      // 4️⃣ Subscribe to service update stream
      _serviceUpdateSubscription = _repository.serviceUpdateStream.listen(
            (service) {
          _handleServiceUpdate(service);
        },
        onError: (error) {
        },
      );

      _isRealtimeInitialized = true;
    } catch (e) {
      _error = e.toString();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔄 Handle Realtime Updates
  // ═══════════════════════════════════════════════════════════════

  void _handlePackageUpdate(PackageModel updatedPackage) {
    final index = _packages.indexWhere((p) => p.id == updatedPackage.id);

    if (index != -1) {
      _packages[index] = updatedPackage;
    } else {
      _packages.add(updatedPackage);
    }

    _filterPackages();

    // Update selected package if it's the same
    if (_selectedPackage?.id == updatedPackage.id) {
      _selectedPackage = updatedPackage;
    }

    notifyListeners();
  }

  void _handleServiceUpdate(PackageServiceModel updatedService) {
    // Find package that contains this service
    final packageIndex = _packages.indexWhere(
          (p) => p.services.any((s) => s.id == updatedService.id),
    );

    if (packageIndex != -1) {
      final package = _packages[packageIndex];
      final serviceIndex = package.services.indexWhere(
            (s) => s.id == updatedService.id,
      );

      if (serviceIndex != -1) {
        final updatedServices = List<PackageServiceModel>.from(package.services);
        updatedServices[serviceIndex] = updatedService;

        _packages[packageIndex] = package.copyWith(services: updatedServices);

        // Update selected package if needed
        if (_selectedPackage?.id == package.id) {
          _selectedPackage = _packages[packageIndex];
        }

        notifyListeners();
      }
    }
  }

  void _filterPackages() {
    _featuredPackages = _packages.where((p) => p.isFeatured).toList();
    _seasonalPackages = _packages.where((p) => p.isSeasonal).toList();
  }

  // ═══════════════════════════════════════════════════════════════
  // 📋 Fetch Operations
  // ═══════════════════════════════════════════════════════════════

  /// Load Active Packages
  Future<void> loadActivePackages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {

      _packages = await _repository.getActivePackages();
      _filterPackages();

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load All Packages (including inactive)
  Future<void> loadAllPackages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {

      _packages = await _repository.getAllPackages();
      _filterPackages();

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load Package By ID
  Future<void> loadPackageById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {

      _selectedPackage = await _repository.getPackageById(id);

      if (_selectedPackage == null) {
        _error = 'الباقة غير موجودة';
      } else {
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh Packages
  Future<void> refreshPackages() async {
    await loadActivePackages();
  }

  /// Load Statistics
  Future<void> loadStatistics() async {
    try {

      _statistics = await _repository.getPackagesStatistics();

      notifyListeners();
    } catch (e) {
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ✅ Create Operations
  // ═══════════════════════════════════════════════════════════════

  /// Create New Package
  Future<bool> createPackage(Map<String, dynamic> packageData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {

      final package = await _repository.createPackage(packageData);

      if (package != null) {
        await refreshPackages();
        return true;
      } else {
        _error = 'فشل إنشاء الباقة';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add Service to Package
  Future<bool> addServiceToPackage(
      int packageId,
      Map<String, dynamic> serviceData,
      ) async {
    try {

      final service = await _repository.addServiceToPackage(
        packageId,
        serviceData,
      );

      if (service != null) {

        // Reload package to get updated services
        await loadPackageById(packageId);

        return true;
      } else {
        _error = 'فشل إضافة الخدمة';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔄 Update Operations
  // ═══════════════════════════════════════════════════════════════

  /// Update Package
  Future<bool> updatePackage(int id, Map<String, dynamic> packageData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {

      final success = await _repository.updatePackage(id, packageData);

      if (success) {
        await refreshPackages();
        return true;
      } else {
        _error = 'فشل تحديث الباقة';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update Service
  Future<bool> updateService(int serviceId, Map<String, dynamic> serviceData) async {
    try {

      final success = await _repository.updateService(serviceId, serviceData);

      if (success) {
        return true;
      } else {
        _error = 'فشل تحديث الخدمة';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🗑️ Delete Operations
  // ═══════════════════════════════════════════════════════════════

  /// Delete Package
  Future<bool> deletePackage(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {

      final success = await _repository.deletePackage(id);

      if (success) {
        await refreshPackages();
        return true;
      } else {
        _error = 'فشل حذف الباقة';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Remove Service from Package
  Future<bool> removeServiceFromPackage(int serviceId) async {
    try {

      final success = await _repository.removeServiceFromPackage(serviceId);

      if (success) {
        return true;
      } else {
        _error = 'فشل حذف الخدمة';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔍 Search & Filter
  // ═══════════════════════════════════════════════════════════════

  /// Search Packages by Name
  List<PackageModel> searchPackages(String query) {
    if (query.isEmpty) return _packages;

    return _packages.where((package) {
      return package.nameAr.contains(query) ||
          (package.nameEn?.contains(query) ?? false);
    }).toList();
  }

  /// Filter Packages by Price Range
  List<PackageModel> filterByPriceRange(double minPrice, double maxPrice) {
    return _packages.where((package) {
      return package.price >= minPrice && package.price <= maxPrice;
    }).toList();
  }

  /// Get Valid Packages Only
  List<PackageModel> getValidPackages() {
    return _packages.where((package) => package.isValid).toList();
  }

  /// Get Expiring Soon Packages
  List<PackageModel> getExpiringSoonPackages() {
    return _packages.where((package) => package.isExpiringSoon).toList();
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎯 Selection Management
  // ═══════════════════════════════════════════════════════════════

  /// Select Package
  void selectPackage(PackageModel package) {
    _selectedPackage = package;
    notifyListeners();
  }

  /// Clear Selection
  void clearSelection() {
    _selectedPackage = null;
    notifyListeners();
  }

  /// Clear Error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════
  // 🧹 Dispose
  // ═══════════════════════════════════════════════════════════════

  @override
  void dispose() {

    _packagesSubscription?.cancel();
    _packageUpdateSubscription?.cancel();
    _serviceUpdateSubscription?.cancel();

    _repository.dispose();

    super.dispose();

  }
}