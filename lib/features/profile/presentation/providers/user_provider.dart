import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:millionaire_barber/core/constants/app_constants.dart';
import 'package:millionaire_barber/core/services/firebase_messaging_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository userRepository;
  final SupabaseClient _supabase = Supabase.instance.client;

  UserProvider({required this.userRepository});

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  // ✅ قناة Realtime
  RealtimeChannel? _realtimeChannel;

  // ✅ دالة مساعدة لتغيير حالة التحميل
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }


  void updateUserFromRealtime(Map<String, dynamic> updatedUserMap) {
    _user = UserModel.fromJson(updatedUserMap);
    notifyListeners();
  }

  /// تحميل حالة المستخدم من SharedPreferences عند بداية التطبيق
  Future<void> loadUserStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (_isLoggedIn) {
      await fetchCurrentUser();

      // ✅ الاشتراك في التحديثات بعد تحميل المستخدم
      if (_user?.id != null) {
        subscribeToUserChanges(_user!.id!);
      }
    }
    notifyListeners();
  }

  /// حفظ حالة تسجيل الدخول
  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = value;
    await prefs.setBool('isLoggedIn', value);
    notifyListeners();
  }

  /// حفظ معرف المستخدم الحالي في SharedPreferences
  Future<void> saveCurrentUserId(int id) async {
    await userRepository.saveCurrentUserId(id);
  }

  /// مسح معرف المستخدم الحالي من SharedPreferences
  Future<void> clearCurrentUserId() async {
    await userRepository.clearCurrentUserId();
  }

  /// جلب المستخدم الحالي من الريبو
  Future<void> fetchCurrentUser() async {
    _setLoading(true);
    _error = null;

    try {
      final currentUser = await userRepository.getCurrentUser();
      _user = currentUser;
      if (_user == null) {
        _isLoggedIn = false;
        await setLoggedIn(false);
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء جلب بيانات المستخدم الحالي.';
      _user = null;
      _isLoggedIn = false;
    } finally {
      _setLoading(false);
    }
  }

  /// جلب المستخدم بواسطة ID
  Future<void> fetchUserById(int id) async {
    _setLoading(true);
    _error = null;

    try {
      final fetchedUser = await userRepository.getUserById(id);
      _user = fetchedUser;
    } catch (e) {
      _error = 'حدث خطأ أثناء جلب بيانات المستخدم.';
    } finally {
      _setLoading(false);
    }
  }

  /// إنشاء مستخدم جديد
  Future<bool> createUser(UserModel newUser) async {
    _setLoading(true);
    _error = null;

    try {
      final createdUser = await userRepository.createUser(newUser);
      _user = createdUser;

      if (createdUser.id != null) {
        await saveCurrentUserId(createdUser.id!);
        await setLoggedIn(true);

        // ✅ الاشتراك في التحديثات
        subscribeToUserChanges(createdUser.id!);
      }

      return true;
    } catch (e) {
      _error = 'فشل إنشاء المستخدم.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// تحديث بيانات المستخدم
  Future<bool> updateUser(int id, Map<String, dynamic> updates) async {
    _setLoading(true);
    _error = null;

    try {
      final updatedUser = await userRepository.updateUser(id, updates);
      if (updatedUser != null) {
        _user = updatedUser;
        return true;
      } else {
        _error = 'لم يتم العثور على المستخدم لتحديثه.';
        return false;
      }
    } catch (e) {
      _error = 'فشل تحديث بيانات المستخدم.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// حذف المستخدم
  Future<bool> deleteUser(int id) async {
    _setLoading(true);
    _error = null;

    try {
      await userRepository.deleteUser(id);
      _user = null;
      await setLoggedIn(false);
      await clearCurrentUserId();

      // ✅ إلغاء الاشتراك
      unsubscribeFromUserChanges();

      return true;
    } catch (e) {
      _error = 'فشل حذف المستخدم.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// تسجيل دخول المستخدم (استقبال UserModel مباشرة)
  void login(UserModel user) {
    _user = user;
    _isLoggedIn = true;

    // ✅ الاشتراك في التحديثات
    if (user.id != null) {
      subscribeToUserChanges(user.id!);
    }

    notifyListeners();
  }

  /// ✅ تغيير كلمة المرور
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_user == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    _setLoading(true);

    try {
      await userRepository.updatePassword(
        userId: _user!.id!,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// تسجيل خروج المستخدم ومسح البيانات
  Future<void> logout() async {
    _user = null;
    _isLoggedIn = false;
    await clearCurrentUserId();
    await setLoggedIn(false);

    // ✅ إلغاء الاشتراك
    unsubscribeFromUserChanges();

    notifyListeners();
  }

  /// ✅ الاشتراك في تحديثات المستخدم Realtime
  void subscribeToUserChanges(int id) {
    // إلغاء الاشتراك السابق إن وجد
    unsubscribeFromUserChanges();


    _realtimeChannel = _supabase
        .channel('user_changes_$id')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'users',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: id,
      ),
      callback: (payload) {

        if (payload.eventType == PostgresChangeEvent.update) {
          // تحديث البيانات
          if (payload.newRecord != null) {
            _user = UserModel.fromJson(payload.newRecord);
            notifyListeners();
          }
        } else if (payload.eventType == PostgresChangeEvent.delete) {
          // المستخدم تم حذفه
          logout();
        }
      },
    )
        .subscribe();
  }

  /// ✅ إلغاء الاشتراك في التحديثات
  void unsubscribeFromUserChanges() {
    if (_realtimeChannel != null) {
      _realtimeChannel!.unsubscribe();
      _realtimeChannel = null;
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// UPLOAD PROFILE IMAGE - مُصلح ومُحسّن
  /// ═══════════════════════════════════════════════════════════════
  Future<bool> uploadProfileImage(String userId, String imagePath) async {
    try {
      final file = File(imagePath);

      // ✅ Get file extension
      final extension = imagePath.split('.').last.toLowerCase();

      // ✅ Determine MIME type
      String mimeType = 'jpeg';
      if (extension == 'png') {
        mimeType = 'png';
      } else if (extension == 'jpg' || extension == 'jpeg') {
        mimeType = 'jpeg';
      } else if (extension == 'gif') {
        mimeType = 'gif';
      } else if (extension == 'webp') {
        mimeType = 'webp';
      }

      const functionUrl = '${Constants.supabaseUrl}/functions/v1/upload-profile-image';


      final request = http.MultipartRequest('POST', Uri.parse(functionUrl));

      request.headers['Authorization'] = 'Bearer ${Constants.supabaseAnonKey}';

      // ✅ Add file with correct MIME type
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: 'profile.$extension',
          contentType: MediaType('image', mimeType), // ✅ استخدام MediaType
        ),
      );

      request.fields['userId'] = userId;


      final response = await request.send();
      final responseData = await response.stream.bytesToString();


      final jsonData = json.decode(responseData);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        final imageUrl = jsonData['imageUrl'] as String;

        if (_user != null) {
          _user = UserModel.fromJson({
            ..._user!.toJson(),
            'profile_image_url': imageUrl,
          });
          notifyListeners();
        }

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }


  /// حفظ FCM Token في Database
  Future<void> saveFCMToken(int userId) async {
    try {
      final fcmToken = FirebaseMessagingService().fcmToken;
      if (fcmToken == null) {
        return;
      }

      await _supabase
          .from('users')
          .update({'fcm_token': fcmToken})
          .eq('id', userId);

    } catch (e) {
    }
  }



  @override
  void dispose() {
    unsubscribeFromUserChanges();
    super.dispose();
  }
}

