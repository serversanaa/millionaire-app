import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/package_model.dart';
import '../../domain/models/package_service_model.dart';

/// ═══════════════════════════════════════════════════════════════
/// 📦 Packages Repository - النسخة الكاملة مع Realtime
/// مسؤول عن جميع عمليات قاعدة البيانات + التحديثات الفورية
/// ═══════════════════════════════════════════════════════════════

class PackagesRepository {
  final SupabaseClient _supabase;

  // ═══════════════════════════════════════════════════════════════
  // Realtime Subscriptions
  // ═══════════════════════════════════════════════════════════════
  RealtimeChannel? _packagesChannel;
  RealtimeChannel? _servicesChannel;

  // ═══════════════════════════════════════════════════════════════
  // Stream Controllers
  // ═══════════════════════════════════════════════════════════════
  final _packagesStreamController = StreamController<List<PackageModel>>.broadcast();
  final _packageUpdateStreamController = StreamController<PackageModel>.broadcast();
  final _serviceUpdateStreamController = StreamController<PackageServiceModel>.broadcast();

  PackagesRepository(this._supabase);

  // ═══════════════════════════════════════════════════════════════
  // 🌊 Streams (للاستماع للتحديثات الفورية)
  // ═══════════════════════════════════════════════════════════════

  /// Stream لقائمة الباقات الكاملة
  Stream<List<PackageModel>> get packagesStream => _packagesStreamController.stream;

  /// Stream لتحديث باقة واحدة
  Stream<PackageModel> get packageUpdateStream => _packageUpdateStreamController.stream;

  /// Stream لتحديث خدمة واحدة
  Stream<PackageServiceModel> get serviceUpdateStream => _serviceUpdateStreamController.stream;

  // ═══════════════════════════════════════════════════════════════
  // 📡 Initialize Realtime Subscriptions
  // ═══════════════════════════════════════════════════════════════

  Future<void> initializeRealtime() async {
    try {

      // 1️⃣ Subscription للباقات
      _packagesChannel = _supabase
          .channel('packages_realtime')
          .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'packages',
        callback: (payload) {
          _handlePackageChange(payload);
        },
      )
          .subscribe();

      // 2️⃣ Subscription لخدمات الباقات
      _servicesChannel = _supabase
          .channel('package_services_realtime')
          .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'package_services',
        callback: (payload) {
          _handleServiceChange(payload);
        },
      )
          .subscribe();

    } catch (e, stackTrace) {
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔄 Handle Package Changes (Realtime Events)
  // ═══════════════════════════════════════════════════════════════

  void _handlePackageChange(PostgresChangePayload payload) {
    try {
      switch (payload.eventType) {
        case PostgresChangeEvent.insert:
          if (payload.newRecord != null) {
            final package = PackageModel.fromJson(payload.newRecord);
            _packageUpdateStreamController.add(package);
            _refreshPackages();
          }
          break;

        case PostgresChangeEvent.update:
          if (payload.newRecord != null) {
            final package = PackageModel.fromJson(payload.newRecord);
            _packageUpdateStreamController.add(package);
            _refreshPackages();
          }
          break;

        case PostgresChangeEvent.delete:
          _refreshPackages();
          break;

        default:
      }
    } catch (e) {
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔄 Handle Service Changes (Realtime Events)
  // ═══════════════════════════════════════════════════════════════

  void _handleServiceChange(PostgresChangePayload payload) {
    try {
      switch (payload.eventType) {
        case PostgresChangeEvent.insert:
          if (payload.newRecord != null) {
            final service = PackageServiceModel.fromJson(payload.newRecord);
            _serviceUpdateStreamController.add(service);
            _refreshPackages();
          }
          break;

        case PostgresChangeEvent.update:
          if (payload.newRecord != null) {
            final service = PackageServiceModel.fromJson(payload.newRecord);
            _serviceUpdateStreamController.add(service);
            _refreshPackages();
          }
          break;

        case PostgresChangeEvent.delete:
          _refreshPackages();
          break;

        default:
      }
    } catch (e) {
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔄 Refresh Packages (Internal Helper)
  // ═══════════════════════════════════════════════════════════════

  Future<void> _refreshPackages() async {
    try {
      final packages = await getActivePackages();
      _packagesStreamController.add(packages);
    } catch (e) {
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🛑 Dispose Realtime Subscriptions
  // ═══════════════════════════════════════════════════════════════

  Future<void> dispose() async {

    try {
      await _packagesChannel?.unsubscribe();
      await _servicesChannel?.unsubscribe();

      await _packagesStreamController.close();
      await _packageUpdateStreamController.close();
      await _serviceUpdateStreamController.close();

    } catch (e) {
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 📋 GET OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  /// Get All Active Packages (الباقات الصالحة فقط)
  Future<List<PackageModel>> getActivePackages() async {
    try {

      final response = await _supabase.rpc('get_active_packages');

      if (response == null) {
        return [];
      }

      final packages = (response as List)
          .map((json) => PackageModel.fromJson(json as Map<String, dynamic>))
          .toList();


      // Update stream
      if (!_packagesStreamController.isClosed) {
        _packagesStreamController.add(packages);
      }

      return packages;
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  /// Get All Packages (بما في ذلك غير النشطة)
  Future<List<PackageModel>> getAllPackages() async {
    try {

      final packagesResponse = await _supabase
          .from('packages')
          .select()
          .order('display_order', ascending: true);

      final packages = <PackageModel>[];

      for (var json in packagesResponse as List) {
        var package = PackageModel.fromJson(json as Map<String, dynamic>);

        // جلب الخدمات لكل باقة
        final services = await getPackageServices(package.id);
        package = package.copyWith(services: services);

        packages.add(package);
      }

      return packages;
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  /// Get Package By ID
  Future<PackageModel?> getPackageById(int id) async {
    try {

      final response = await _supabase
          .from('packages')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      var package = PackageModel.fromJson(response);

      // جلب الخدمات
      final services = await getPackageServices(id);
      package = package.copyWith(services: services);

      return package;
    } catch (e, stackTrace) {
      return null;
    }
  }

  /// Get Package Services
  Future<List<PackageServiceModel>> getPackageServices(int packageId) async {
    try {

      final response = await _supabase
          .from('package_services')
          .select()
          .eq('package_id', packageId)
          .order('display_order', ascending: true);

      final services = (response as List)
          .map((json) => PackageServiceModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return services;
    } catch (e, stackTrace) {
      return [];
    }
  }

  /// Get Featured Packages
  Future<List<PackageModel>> getFeaturedPackages() async {
    try {

      final response = await _supabase.rpc('get_active_packages');

      if (response == null) return [];

      final packages = (response as List)
          .map((json) => PackageModel.fromJson(json as Map<String, dynamic>))
          .where((package) => package.isFeatured)
          .toList();

      return packages;
    } catch (e, stackTrace) {
      return [];
    }
  }

  /// Get Seasonal Packages
  Future<List<PackageModel>> getSeasonalPackages() async {
    try {

      final response = await _supabase.rpc('get_active_packages');

      if (response == null) return [];

      final packages = (response as List)
          .map((json) => PackageModel.fromJson(json as Map<String, dynamic>))
          .where((package) => package.isSeasonal)
          .toList();

      return packages;
    } catch (e, stackTrace) {
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ✅ CREATE OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  /// Create Package
  Future<PackageModel?> createPackage(Map<String, dynamic> packageData) async {
    try {

      final response = await _supabase
          .from('packages')
          .insert(packageData)
          .select()
          .single();

      final package = PackageModel.fromJson(response);

      return package;
    } catch (e, stackTrace) {
      return null;
    }
  }

  /// Add Service to Package
  Future<PackageServiceModel?> addServiceToPackage(
      int packageId,
      Map<String, dynamic> serviceData,
      ) async {
    try {

      serviceData['package_id'] = packageId;

      final response = await _supabase
          .from('package_services')
          .insert(serviceData)
          .select()
          .single();

      final service = PackageServiceModel.fromJson(response);

      return service;
    } catch (e, stackTrace) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔄 UPDATE OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  /// Update Package
  Future<bool> updatePackage(int id, Map<String, dynamic> packageData) async {
    try {

      await _supabase
          .from('packages')
          .update(packageData)
          .eq('id', id);

      return true;
    } catch (e, stackTrace) {
      return false;
    }
  }

  /// Update Service
  Future<bool> updateService(int serviceId, Map<String, dynamic> serviceData) async {
    try {

      await _supabase
          .from('package_services')
          .update(serviceData)
          .eq('id', serviceId);

      return true;
    } catch (e, stackTrace) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🗑️ DELETE OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  /// Delete Package
  Future<bool> deletePackage(int id) async {
    try {

      await _supabase
          .from('packages')
          .delete()
          .eq('id', id);

      return true;
    } catch (e, stackTrace) {
      return false;
    }
  }

  /// Remove Service from Package
  Future<bool> removeServiceFromPackage(int serviceId) async {
    try {

      await _supabase
          .from('package_services')
          .delete()
          .eq('id', serviceId);

      return true;
    } catch (e, stackTrace) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 📊 STATISTICS & ANALYTICS
  // ═══════════════════════════════════════════════════════════════

  /// Get Packages Statistics
  Future<Map<String, int>> getPackagesStatistics() async {
    try {

      final allPackages = await _supabase
          .from('packages')
          .select('id, is_active, is_featured, is_seasonal');

      final total = (allPackages as List).length;
      final active = allPackages.where((p) => p['is_active'] == true).length;
      final featured = allPackages.where((p) => p['is_featured'] == true).length;
      final seasonal = allPackages.where((p) => p['is_seasonal'] == true).length;

      final stats = {
        'total': total,
        'active': active,
        'inactive': total - active,
        'featured': featured,
        'seasonal': seasonal,
      };

      return stats;
    } catch (e, stackTrace) {
      return {
        'total': 0,
        'active': 0,
        'inactive': 0,
        'featured': 0,
        'seasonal': 0,
      };
    }
  }
}