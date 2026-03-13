// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:local_auth/error_codes.dart' as auth_error;
//
// import '../../data/repositories/settings_repository.dart';
// import '../../domain/models/settings_model.dart';
//
// class SettingsProvider extends ChangeNotifier {
//   final SettingsRepository _repository;
//   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
//   final LocalAuthentication _localAuth = LocalAuthentication();
//
//   SettingsModel _settings = SettingsModel.defaultSettings();
//   bool _isLoading = false;
//   String? _error;
//   bool _biometricAvailable = false;
//
//   SettingsProvider({required SettingsRepository repository})
//       : _repository = repository {
//     _initialize();
//   }
//
//   // Getters
//   SettingsModel get settings => _settings;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   bool get isDarkMode => _settings.isDarkMode;
//   String get language => _settings.language;
//   bool get notificationsEnabled => _settings.notificationsEnabled;
//   bool get emailNotifications => _settings.emailNotifications;
//   bool get smsNotifications => _settings.smsNotifications;
//   bool get biometricEnabled => _settings.biometricEnabled;
//   bool get biometricAvailable => _biometricAvailable;
//
//   /// ✅ تهيئة أولية
//   Future<void> _initialize() async {
//     await _checkBiometricAvailability();
//   }
//
//   /// ✅ التحقق من توفر البصمة
//   Future<void> _checkBiometricAvailability() async {
//     try {
//       print('🔐 Checking biometric availability...');
//
//       final canCheckBiometrics = await _localAuth.canCheckBiometrics;
//       final isDeviceSupported = await _localAuth.isDeviceSupported();
//       final canAuthenticate = canCheckBiometrics || isDeviceSupported;
//
//       print('   Can check biometrics: $canCheckBiometrics');
//       print('   Device supported: $isDeviceSupported');
//
//       if (canAuthenticate) {
//         final availableBiometrics = await _localAuth.getAvailableBiometrics();
//         print('   Available biometrics: $availableBiometrics');
//
//         _biometricAvailable = availableBiometrics.isNotEmpty;
//       } else {
//         _biometricAvailable = false;
//       }
//
//       print('   Biometric available: $_biometricAvailable');
//       notifyListeners();
//     } catch (e) {
//       print('❌ Error checking biometric availability: $e');
//       _biometricAvailable = false;
//       notifyListeners();
//     }
//   }
//
//   /// ✅ تحميل الإعدادات
//   Future<void> loadSettings({int? userId}) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
//
//     try {
//       if (userId != null) {
//         _settings = await _repository.syncSettings(userId);
//       } else {
//         _settings = await _repository.loadLocalSettings();
//       }
//
//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _error = e.toString();
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   /// ✅ تبديل الوضع الداكن
//   Future<void> toggleDarkMode(bool value, {int? userId}) async {
//     try {
//       _settings = _settings.copyWith(isDarkMode: value);
//       await _repository.saveLocalSettings(_settings);
//
//       if (userId != null) {
//         await _repository.saveRemoteSettings(userId, _settings);
//       }
//
//       notifyListeners();
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//     }
//   }
//
//   /// ✅ تغيير اللغة
//   Future<void> changeLanguage(String language, {int? userId}) async {
//     try {
//       _settings = _settings.copyWith(language: language);
//       await _repository.saveLocalSettings(_settings);
//
//       if (userId != null) {
//         await _repository.saveRemoteSettings(userId, _settings);
//       }
//
//       notifyListeners();
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//     }
//   }
//
//   /// ✅ تفعيل/إيقاف الإشعارات
//   Future<void> toggleNotifications(bool value, {int? userId}) async {
//     try {
//       _settings = _settings.copyWith(notificationsEnabled: value);
//       await _repository.saveLocalSettings(_settings);
//
//       if (userId != null) {
//         await _repository.saveRemoteSettings(userId, _settings);
//       }
//
//       notifyListeners();
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//     }
//   }
//
//   /// ✅ تفعيل/إيقاف إشعارات البريد
//   Future<void> toggleEmailNotifications(bool value, {int? userId}) async {
//     try {
//       _settings = _settings.copyWith(emailNotifications: value);
//       await _repository.saveLocalSettings(_settings);
//
//       if (userId != null) {
//         await _repository.saveRemoteSettings(userId, _settings);
//       }
//
//       notifyListeners();
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//     }
//   }
//
//   /// ✅ تفعيل/إيقاف إشعارات SMS
//   Future<void> toggleSmsNotifications(bool value, {int? userId}) async {
//     try {
//       _settings = _settings.copyWith(smsNotifications: value);
//       await _repository.saveLocalSettings(_settings);
//
//       if (userId != null) {
//         await _repository.saveRemoteSettings(userId, _settings);
//       }
//
//       notifyListeners();
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//     }
//   }
//
//   /// ✅ تفعيل/إيقاف البصمة مع التحقق
//   Future<bool> toggleBiometric(bool value, {int? userId}) async {
//     if (!_biometricAvailable) {
//       _error = 'البصمة غير متاحة على هذا الجهاز';
//       notifyListeners();
//       return false;
//     }
//
//     try {
//       if (value) {
//         // ✅ التحقق من البصمة قبل التفعيل
//         print('🔐 Authenticating with biometric...');
//
//         final authenticated = await _localAuth.authenticate(
//           localizedReason: 'استخدم بصمتك لتفعيل المصادقة البيومترية',
//           options: const AuthenticationOptions(
//             stickyAuth: true,
//             biometricOnly: false,
//             useErrorDialogs: true,
//             sensitiveTransaction: true,
//           ),
//         );
//
//         if (!authenticated) {
//           print('❌ Biometric authentication failed');
//           return false;
//         }
//
//         print('✅ Biometric authentication successful');
//
//         // ✅ حفظ الإعدادات
//         await _secureStorage.write(key: 'biometric_enabled', value: 'true');
//
//         if (userId != null) {
//           await _secureStorage.write(key: 'biometric_user_id', value: userId.toString());
//         }
//
//         _settings = _settings.copyWith(biometricEnabled: true);
//         await _repository.saveLocalSettings(_settings);
//
//         if (userId != null) {
//           await _repository.saveRemoteSettings(userId, _settings);
//         }
//
//         notifyListeners();
//         return true;
//       } else {
//         // ✅ إلغاء التفعيل
//         await _secureStorage.delete(key: 'biometric_enabled');
//         await _secureStorage.delete(key: 'biometric_user_id');
//         await _secureStorage.delete(key: 'saved_password');
//
//         _settings = _settings.copyWith(biometricEnabled: false);
//         await _repository.saveLocalSettings(_settings);
//
//         if (userId != null) {
//           await _repository.saveRemoteSettings(userId, _settings);
//         }
//
//         notifyListeners();
//         return true;
//       }
//     } on PlatformException catch (e) {
//       print('❌ Platform error: ${e.code}');
//
//       if (e.code == auth_error.notAvailable) {
//         _error = 'البصمة غير متاحة';
//       } else if (e.code == auth_error.notEnrolled) {
//         _error = 'لم يتم تسجيل بصمة على الجهاز';
//       } else if (e.code == auth_error.lockedOut) {
//         _error = 'تم قفل البصمة مؤقتاً';
//       } else {
//         _error = 'فشل التحقق من البصمة';
//       }
//
//       notifyListeners();
//       return false;
//     } catch (e) {
//       print('❌ Error: $e');
//       _error = e.toString();
//       notifyListeners();
//       return false;
//     }
//   }
//
//   /// ✅ التحقق من البصمة عند تسجيل الدخول
//   Future<bool> authenticateForLogin() async {
//     if (!biometricEnabled || !_biometricAvailable) {
//       return false;
//     }
//
//     try {
//       final authenticated = await _localAuth.authenticate(
//         localizedReason: 'استخدم بصمتك لتسجيل الدخول',
//         options: const AuthenticationOptions(
//           stickyAuth: true,
//           biometricOnly: false,
//           useErrorDialogs: true,
//           sensitiveTransaction: true,
//         ),
//       );
//
//       return authenticated;
//     } catch (e) {
//       print('Error authenticating for login: $e');
//       return false;
//     }
//   }
//
//   /// ✅ إعادة تعيين الإعدادات
//   Future<void> resetSettings({int? userId}) async {
//     try {
//       _settings = SettingsModel.defaultSettings();
//       await _repository.saveLocalSettings(_settings);
//
//       if (userId != null) {
//         await _repository.saveRemoteSettings(userId, _settings);
//       }
//
//       notifyListeners();
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//     }
//   }
//
//   /// ✅ مسح الإعدادات المحلية
//   Future<void> clearLocalSettings() async {
//     try {
//       await _repository.clearLocalSettings();
//       _settings = SettingsModel.defaultSettings();
//       notifyListeners();
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//     }
//   }
//
//   /// ✅ إعادة تحميل
//   Future<void> refresh({int? userId}) async {
//     await _checkBiometricAvailability();
//     await loadSettings(userId: userId);
//   }
// }
//
//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

import '../../data/repositories/settings_repository.dart';
import '../../domain/models/settings_model.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  SettingsModel _settings = SettingsModel.defaultSettings();
  bool _isLoading = false;
  String? _error;
  bool _biometricAvailable = false;
  bool _isInitialized = false; // ✅ إضافة متغير التهيئة

  SettingsProvider({required SettingsRepository repository})
      : _repository = repository {
    // ✅ استخدام Future.microtask لتأخير التنفيذ حتى بعد اكتمال البناء
    Future.microtask(() => initialize());
  }

  // Getters
  SettingsModel get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isDarkMode => _settings.isDarkMode;
  String get language => _settings.language;
  bool get notificationsEnabled => _settings.notificationsEnabled;
  bool get emailNotifications => _settings.emailNotifications;
  bool get smsNotifications => _settings.smsNotifications;
  bool get biometricEnabled => _settings.biometricEnabled;
  bool get biometricAvailable => _biometricAvailable;
  bool get isInitialized => _isInitialized; // ✅ إضافة getter

  /// ✅ تهيئة أولية عامة (يمكن استدعاؤها من الخارج)
  Future<void> initialize() async {
    try {
      await _checkBiometricAvailability();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _error = 'فشل تهيئة الإعدادات: ${e.toString()}';
      _isInitialized = true; // نضع true حتى لو فشلت لتجنب التعليق
      notifyListeners();
    }
  }

  /// ✅ التحقق من توفر البصمة
  Future<void> _checkBiometricAvailability() async {
    try {

      // ✅ التحقق من الدعم الأساسي للجهاز
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();


      // ✅ الجهاز يدعم البيومترية
      if (canCheckBiometrics || isDeviceSupported) {
        // ✅ الحصول على أنواع البيومترية المتاحة
        final availableBiometrics = await _localAuth.getAvailableBiometrics();

        // ✅ التحقق من وجود بيومترية مسجلة
        _biometricAvailable = availableBiometrics.isNotEmpty;

        // ✅ طباعة تفاصيل أنواع البيومترية المتاحة
        if (_biometricAvailable) {
          if (availableBiometrics.contains(BiometricType.face)) {
          }
          if (availableBiometrics.contains(BiometricType.fingerprint)) {
          }
          if (availableBiometrics.contains(BiometricType.iris)) {
          }
          if (availableBiometrics.contains(BiometricType.strong)) {
          }
          if (availableBiometrics.contains(BiometricType.weak)) {
          }
        } else {
        }
      } else {
        _biometricAvailable = false;
      }

      notifyListeners();
    } catch (e) {
      _biometricAvailable = false;
      _error = 'فشل التحقق من توفر البصمة: ${e.toString()}';
      notifyListeners();
    }
  }

  /// ✅ تحميل الإعدادات
  Future<void> loadSettings({int? userId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {

      if (userId != null) {
        _settings = await _repository.syncSettings(userId);
      } else {
        _settings = await _repository.loadLocalSettings();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'فشل تحميل الإعدادات: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ تبديل الوضع الداكن
  Future<void> toggleDarkMode(bool value, {int? userId}) async {
    try {
      _settings = _settings.copyWith(isDarkMode: value);
      await _repository.saveLocalSettings(_settings);

      if (userId != null) {
        await _repository.saveRemoteSettings(userId, _settings);
      }

      notifyListeners();
    } catch (e) {
      _error = 'فشل تغيير الوضع الداكن: ${e.toString()}';
      notifyListeners();
    }
  }

  /// ✅ تغيير اللغة
  Future<void> changeLanguage(String language, {int? userId}) async {
    try {
      _settings = _settings.copyWith(language: language);
      await _repository.saveLocalSettings(_settings);

      if (userId != null) {
        await _repository.saveRemoteSettings(userId, _settings);
      }

      notifyListeners();
    } catch (e) {
      _error = 'فشل تغيير اللغة: ${e.toString()}';
      notifyListeners();
    }
  }

  /// ✅ تفعيل/إيقاف الإشعارات
  Future<void> toggleNotifications(bool value, {int? userId}) async {
    try {
      _settings = _settings.copyWith(notificationsEnabled: value);
      await _repository.saveLocalSettings(_settings);

      if (userId != null) {
        await _repository.saveRemoteSettings(userId, _settings);
      }

      notifyListeners();
    } catch (e) {
      _error = 'فشل تغيير إعدادات الإشعارات: ${e.toString()}';
      notifyListeners();
    }
  }

  /// ✅ تفعيل/إيقاف إشعارات البريد
  Future<void> toggleEmailNotifications(bool value, {int? userId}) async {
    try {
      _settings = _settings.copyWith(emailNotifications: value);
      await _repository.saveLocalSettings(_settings);

      if (userId != null) {
        await _repository.saveRemoteSettings(userId, _settings);
      }

      notifyListeners();
    } catch (e) {
      _error = 'فشل تغيير إشعارات البريد: ${e.toString()}';
      notifyListeners();
    }
  }

  /// ✅ تفعيل/إيقاف إشعارات SMS
  Future<void> toggleSmsNotifications(bool value, {int? userId}) async {
    try {
      _settings = _settings.copyWith(smsNotifications: value);
      await _repository.saveLocalSettings(_settings);

      if (userId != null) {
        await _repository.saveRemoteSettings(userId, _settings);
      }

      notifyListeners();
    } catch (e) {
      _error = 'فشل تغيير إشعارات الرسائل: ${e.toString()}';
      notifyListeners();
    }
  }

  /// ✅ تفعيل/إيقاف البصمة مع التحقق
  Future<bool> toggleBiometric(bool value, {int? userId}) async {
    // ✅ التحقق من توفر البصمة أولاً
    if (!_biometricAvailable) {
      _error = 'البصمة غير متاحة على هذا الجهاز. تأكد من:\n'
          '1. دعم جهازك للبصمة\n'
          '2. تفعيل البصمة من إعدادات الجهاز\n'
          '3. تسجيل بصمة واحدة على الأقل';
      notifyListeners();
      return false;
    }

    try {
      if (value) {
        // ✅ التحقق من البصمة قبل التفعيل

        final authenticated = await _localAuth.authenticate(
          localizedReason: 'استخدم بصمتك لتفعيل المصادقة البيومترية',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false, // السماح بالـ PIN كبديل
            useErrorDialogs: true,
            sensitiveTransaction: true,
          ),
        );

        if (!authenticated) {
          _error = 'فشل التحقق من البصمة أو تم الإلغاء';
          notifyListeners();
          return false;
        }


        // ✅ حفظ الإعدادات في التخزين الآمن
        await _secureStorage.write(key: 'biometric_enabled', value: 'true');

        if (userId != null) {
          await _secureStorage.write(
            key: 'biometric_user_id',
            value: userId.toString(),
          );
        }

        // ✅ تحديث الإعدادات
        _settings = _settings.copyWith(biometricEnabled: true);
        await _repository.saveLocalSettings(_settings);

        if (userId != null) {
          await _repository.saveRemoteSettings(userId, _settings);
        }

        notifyListeners();
        return true;
      } else {
        // ✅ إلغاء تفعيل البصمة

        await _secureStorage.delete(key: 'biometric_enabled');
        await _secureStorage.delete(key: 'biometric_user_id');
        await _secureStorage.delete(key: 'saved_password');

        _settings = _settings.copyWith(biometricEnabled: false);
        await _repository.saveLocalSettings(_settings);

        if (userId != null) {
          await _repository.saveRemoteSettings(userId, _settings);
        }

        notifyListeners();
        return true;
      }
    } on PlatformException catch (e) {

      // ✅ معالجة الأخطاء المختلفة
      if (e.code == auth_error.notAvailable) {
        _error = 'البصمة غير متاحة على هذا الجهاز';
      } else if (e.code == auth_error.notEnrolled) {
        _error = 'لم يتم تسجيل بصمة على الجهاز.\n'
            'الرجاء تسجيل بصمة من إعدادات الجهاز أولاً.';
      } else if (e.code == auth_error.lockedOut) {
        _error = 'تم قفل البصمة مؤقتاً بسبب محاولات فاشلة متعددة.\n'
            'حاول مرة أخرى بعد قليل.';
      } else if (e.code == auth_error.permanentlyLockedOut) {
        _error = 'تم قفل البصمة بشكل دائم.\n'
            'الرجاء إعادة تشغيل الجهاز أو استخدام كلمة المرور.';
      } else if (e.code == 'PasscodeNotSet') {
        _error = 'لم يتم تعيين رمز قفل للجهاز.\n'
            'الرجاء تعيين رمز قفل من إعدادات الجهاز أولاً.';
      } else if (e.code == 'NotAvailable') {
        _error = 'خدمة المصادقة البيومترية غير متاحة حالياً';
      } else {
        _error = 'فشل التحقق من البصمة: ${e.message ?? e.code}';
      }

      notifyListeners();
      return false;
    } catch (e) {
      _error = 'حدث خطأ غير متوقع: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// ✅ التحقق من البصمة عند تسجيل الدخول
  Future<bool> authenticateForLogin() async {
    // ✅ التحقق من التفعيل والتوفر
    if (!biometricEnabled) {
      return false;
    }

    if (!_biometricAvailable) {
      return false;
    }

    try {

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'استخدم بصمتك لتسجيل الدخول',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );

      if (authenticated) {
      } else {
      }

      return authenticated;
    } on PlatformException catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }

  /// ✅ إعادة فحص البيومترية يدويًا (للمستخدم)
  Future<void> recheckBiometric() async {
    _error = null;
    _isInitialized = false;
    notifyListeners();

    await _checkBiometricAvailability();

    _isInitialized = true;
    notifyListeners();

    if (_biometricAvailable) {
    } else {
      _error = 'البيومترية غير متاحة على هذا الجهاز';
    }
  }

  /// ✅ إعادة تعيين الإعدادات
  Future<void> resetSettings({int? userId}) async {
    try {
      _settings = SettingsModel.defaultSettings();
      await _repository.saveLocalSettings(_settings);

      if (userId != null) {
        await _repository.saveRemoteSettings(userId, _settings);
      }

      notifyListeners();
    } catch (e) {
      _error = 'فشل إعادة تعيين الإعدادات: ${e.toString()}';
      notifyListeners();
    }
  }

  /// ✅ مسح الإعدادات المحلية
  Future<void> clearLocalSettings() async {
    try {
      await _repository.clearLocalSettings();
      _settings = SettingsModel.defaultSettings();
      notifyListeners();
    } catch (e) {
      _error = 'فشل مسح الإعدادات المحلية: ${e.toString()}';
      notifyListeners();
    }
  }

  /// ✅ إعادة تحميل مع تأكيد التهيئة
  Future<void> refresh({int? userId}) async {
    _isInitialized = false;
    notifyListeners();

    await _checkBiometricAvailability();
    await loadSettings(userId: userId);

    _isInitialized = true;
    notifyListeners();
  }

  /// ✅ مسح الأخطاء
  void clearError() {
    _error = null;
    notifyListeners();
  }
}