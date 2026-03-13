// import 'dart:async';
// import 'dart:convert';
// import 'dart:ui' as ui;
//
// import 'package:crypto/crypto.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
// import 'package:millionaire_barber/core/constants/app_colors.dart';
// import 'package:millionaire_barber/core/services/firebase_messaging_service.dart';
// import 'package:millionaire_barber/features/authentication/presentation/pages/forgot_password_screen.dart';
// import 'package:millionaire_barber/shared/widgets/custom_snackbar.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// import '../../../profile/domain/models/user_model.dart' as local_user;
// import '../../../profile/presentation/providers/user_provider.dart';
// import '../../../settings/presentation/providers/settings_provider.dart';
// import 'register_screen.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _identifierController = TextEditingController();
//   final _passwordController = TextEditingController();
//
//   bool _showPassword = false;
//   bool _isLoading = false;
//   bool _rememberMe = false;
//
//   StreamSubscription<InternetConnectionStatus>? _internetSubscription;
//   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeScreen();
//   }
//
//   Future<void> _initializeScreen() async {
//     // مراقبة الاتصال بالإنترنت
//     _internetSubscription =
//         InternetConnectionChecker().onStatusChange.listen((status) {
//           if (status == InternetConnectionStatus.disconnected && mounted) {
//             CustomSnackbar.showInternetError(context);
//           }
//         });
//
//     final connected = await InternetConnectionChecker().hasConnection;
//     if (!connected && mounted) {
//       CustomSnackbar.showInternetError(context);
//       return;
//     }
//
//     try {
//       final settingsProvider =
//       Provider.of<SettingsProvider>(context, listen: false);
//
//       // تحديث إعدادات البصمة
//       await settingsProvider.refresh();
//
//       // تحميل بيانات "تذكرني" لملء الحقول فقط
//       await _loadSavedCredentials();
//
//       // فحص وجود بيانات للبصمة في التخزين الآمن
//       final hasBiometricCreds = await _hasBiometricCredentials();
//
//       // تسجيل الدخول التلقائي بالبصمة طالما:
//       // - البصمة مفعّلة ومتاحة
//       // - توجد بيانات مصادقة مخزنة للبصمة
//       if (settingsProvider.biometricEnabled &&
//           settingsProvider.biometricAvailable &&
//           hasBiometricCreds &&
//           mounted) {
//         await Future.delayed(const Duration(milliseconds: 500));
//
//         if (!_isLoading && mounted) {
//           await _authenticateWithBiometric();
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   /// هل توجد بيانات مصادقة مخزّنة للبصمة؟
//   Future<bool> _hasBiometricCredentials() async {
//     final identifier = await _secureStorage.read(key: 'bio_identifier');
//     final password = await _secureStorage.read(key: 'bio_password');
//     return identifier != null && password != null;
//   }
//
//   /// تحميل بيانات "تذكرني" لملء الفورم
//   Future<void> _loadSavedCredentials() async {
//     try {
//       final savedIdentifier =
//       await _secureStorage.read(key: 'saved_identifier');
//       final rememberMeStr = await _secureStorage.read(key: 'remember_me');
//
//       if (mounted && savedIdentifier != null && rememberMeStr == 'true') {
//         setState(() {
//           _identifierController.text = savedIdentifier;
//           _rememberMe = true;
//         });
//       }
//     } catch (e) {
//       // يمكن تسجيل الخطأ في Crashlytics مثلاً
//     }
//   }
//
//   /// التحقق بالبصمة
//   Future<void> _authenticateWithBiometric() async {
//     try {
//       if (!mounted) return;
//
//       final settingsProvider =
//       Provider.of<SettingsProvider>(context, listen: false);
//
//       final authenticated = await settingsProvider.authenticateForLogin();
//       if (!authenticated) return;
//
//       // قراءة بيانات خاصة بالبصمة فقط
//       final savedPassword = await _secureStorage.read(key: 'bio_password');
//       final savedIdentifier =
//       await _secureStorage.read(key: 'bio_identifier');
//
//       if (savedPassword == null || savedIdentifier == null) {
//         if (!mounted) return;
//
//         CustomSnackbar.showError(
//           context,
//           'لا توجد بيانات دخول محفوظة للبصمة، سجّل دخولك مرة واحدة أولاً',
//         );
//         return;
//       }
//
//       if (_isLoading) {
//         setState(() => _isLoading = false);
//         await Future.delayed(const Duration(milliseconds: 100));
//       }
//
//       _identifierController.text = savedIdentifier;
//       _passwordController.text = savedPassword;
//
//       await _login(fromBiometric: true);
//     } catch (e) {
//       if (mounted) {
//         CustomSnackbar.showError(context, 'فشل التحقق من البصمة');
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   /// Hash Password
//   String hashPassword(String password) {
//     final bytes = utf8.encode(password);
//     return sha256.convert(bytes).toString();
//   }
//
//   /// تسجيل الدخول
//   Future<void> _login({bool fromBiometric = false}) async {
//     if (_isLoading) return;
//
//     // في حالة البصمة نتجاوز فاليديشن الفورم (البيانات تم جلبها من التخزين)
//     if (!fromBiometric && !(_formKey.currentState?.validate() ?? false)) {
//       return;
//     }
//
//     if (!mounted) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       final connected = await InternetConnectionChecker().hasConnection;
//       if (!connected) {
//         if (mounted) {
//           CustomSnackbar.showInternetError(context);
//         }
//         return;
//       }
//
//       final input = _identifierController.text.trim();
//       final passwordInput = _passwordController.text.trim();
//
//       if (input.isEmpty || passwordInput.isEmpty) {
//         throw Exception('الرجاء إدخال البريد الإلكتروني وكلمة المرور');
//       }
//       if (passwordInput.length < 6) {
//         throw Exception('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
//       }
//
//       final hashedInputPassword = hashPassword(passwordInput);
//       final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
//
//       final userProvider =
//       Provider.of<UserProvider>(context, listen: false);
//       local_user.UserModel? user;
//
//       // البحث عن المستخدم بالبريد أو الهاتف
//       if (emailRegex.hasMatch(input)) {
//         user = await userProvider.userRepository.getUserByEmail(input);
//       } else {
//         user = await userProvider.userRepository.getUserByPhone(input);
//       }
//
//       if (user == null) {
//         throw Exception('المستخدم غير موجود');
//       }
//
//       // التحقق من كلمة المرور
//       if (user.passwordHash != hashedInputPassword) {
//         throw Exception('كلمة المرور غير صحيحة');
//       }
//
//       // حفظ بيانات الاعتماد (بصمة + تذكرني)
//       await _saveCredentials(input, passwordInput);
//
//       // حفظ معرف المستخدم الحالي
//       if (user.id != null) {
//         await userProvider.saveCurrentUserId(user.id!);
//       }
//
//       // تسجيل الدخول في UserProvider
//       userProvider.login(user);
//       await userProvider.setLoggedIn(true);
//
//       // حفظ FCM Token والاشتراك في الـ Topics
//       await _saveFCMToken(userProvider, user.id);
//
//       if (!mounted) return;
//
//       CustomSnackbar.showSuccess(
//         context,
//         "مرحباً ${user.fullName}! تم تسجيل الدخول بنجاح",
//       );
//
//       await Future.delayed(const Duration(milliseconds: 500));
//
//       if (!mounted) return;
//
//       Navigator.pushReplacementNamed(context, '/home');
//     } catch (e) {
//       if (mounted) {
//         CustomSnackbar.showError(
//           context,
//           e.toString().replaceAll('Exception: ', ''),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   /// حفظ بيانات الاعتماد:
//   /// - دائماً نحفظ bio_identifier / bio_password للبصمة
//   /// - "تذكرني" يتحكم فقط في saved_identifier لملء الفورم
//   Future<void> _saveCredentials(String identifier, String password) async {
//     try {
//       // بيانات خاصة بالبصمة (دخول تلقائي بالبصمة)
//       await _secureStorage.write(key: 'bio_identifier', value: identifier);
//       await _secureStorage.write(key: 'bio_password', value: password);
//
//       // بيانات "تذكرني" لواجهة المستخدم
//       if (_rememberMe) {
//         await _secureStorage.write(
//             key: 'saved_identifier', value: identifier);
//         await _secureStorage.write(key: 'remember_me', value: 'true');
//       } else {
//         await _secureStorage.delete(key: 'saved_identifier');
//         await _secureStorage.write(key: 'remember_me', value: 'false');
//       }
//     } catch (e) {
//       // يمكن تسجيل الخطأ
//     }
//   }
//
//   /// حفظ FCM Token + الاشتراك في Topics
//   Future<void> _saveFCMToken(
//       UserProvider userProvider, int? userId) async {
//     try {
//       if (userId == null) return;
//
//       final messagingService = FirebaseMessagingService();
//       final fcmToken = messagingService.fcmToken;
//
//       Future<void> _subscribeVipIfNeeded() async {
//         try {
//           final user = await Supabase.instance.client
//               .from('users')
//               .select('vip_status')
//               .eq('id', userId)
//               .single();
//
//           if (user['vip_status'] == true) {
//             try {
//               await messagingService.subscribeToTopic('vip_users');
//             } catch (_) {}
//           }
//         } catch (_) {}
//       }
//
//       if (fcmToken != null) {
//         try {
//           await userProvider.saveFCMToken(userId);
//         } catch (_) {}
//
//         try {
//           await messagingService.subscribeToTopic('all_users');
//         } catch (_) {}
//
//         await _subscribeVipIfNeeded();
//       } else {
//         await Future.delayed(const Duration(seconds: 1));
//         final newToken = messagingService.fcmToken;
//
//         if (newToken != null) {
//           try {
//             await userProvider.saveFCMToken(userId);
//           } catch (_) {}
//
//           try {
//             await messagingService.subscribeToTopic('all_users');
//           } catch (_) {}
//
//           await _subscribeVipIfNeeded();
//         }
//       }
//     } catch (_) {}
//   }
//
//   @override
//   void dispose() {
//     _internetSubscription?.cancel();
//     _identifierController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Directionality(
//       textDirection: ui.TextDirection.rtl,
//       child: Scaffold(
//         backgroundColor:
//         isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
//         body: SafeArea(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
//             child: Column(
//               children: [
//                 SizedBox(height: 40.h),
//                 _buildLogo(isDark),
//                 SizedBox(height: 30.h),
//                 _buildTitle(isDark),
//                 SizedBox(height: 30.h),
//                 _buildLoginCard(isDark),
//                 SizedBox(height: 24.h),
//                 _buildRegisterLink(isDark),
//                 SizedBox(height: 40.h),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// Logo
//   Widget _buildLogo(bool isDark) {
//     return Hero(
//       tag: "app_logo",
//       child: SizedBox(
//         height: 150.h,
//         width: 150.w,
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             Container(
//               height: 150.h,
//               width: 150.w,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: RadialGradient(
//                   colors: [
//                     AppColors.gold.withOpacity(0.2),
//                     Colors.transparent,
//                   ],
//                 ),
//               ),
//             )
//                 .animate(onPlay: (controller) => controller.repeat())
//                 .scale(
//               duration: 2000.ms,
//               begin: const Offset(0.9, 0.9),
//               end: const Offset(1.1, 1.1),
//             )
//                 .then()
//                 .scale(
//               duration: 2000.ms,
//               begin: const Offset(1.1, 1.1),
//               end: const Offset(0.9, 0.9),
//             ),
//             Container(
//               height: 130.h,
//               width: 130.w,
//               padding: EdgeInsets.all(15.r),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: isDark
//                       ? [const Color(0xFF2A2A2A), const Color(0xFF1E1E1E)]
//                       : [Colors.white, Colors.grey.shade50],
//                 ),
//                 shape: BoxShape.circle,
//                 border: Border.all(color: AppColors.gold, width: 2.5),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.darkRed.withOpacity(0.3),
//                     blurRadius: 25,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: ClipOval(
//                 child: Image.asset(
//                   'assets/images/logo_hd.png',
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Title
//   Widget _buildTitle(bool isDark) {
//     return Column(
//       children: [
//         Text(
//           'أهلاً بك',
//           style: TextStyle(
//             fontSize: 28.sp,
//             fontWeight: FontWeight.bold,
//             color: isDark ? Colors.white : AppColors.black,
//             fontFamily: 'Cairo',
//           ),
//         ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2),
//         SizedBox(height: 5.h),
//         Text(
//           'سجل دخولك للمتابعة',
//           style: TextStyle(
//             fontSize: 15.sp,
//             color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
//             fontFamily: 'Cairo',
//           ),
//         ).animate().fadeIn(delay: 300.ms),
//       ],
//     );
//   }
//
//   /// Login Card
//   Widget _buildLoginCard(bool isDark) {
//     return Container(
//       padding: EdgeInsets.all(24.r),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//         borderRadius: BorderRadius.circular(24.r),
//         border: Border.all(
//           color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             _buildInputField(
//               controller: _identifierController,
//               hint: 'البريد الإلكتروني أو رقم الهاتف',
//               icon: Icons.person_rounded,
//               keyboardType: TextInputType.text,
//               isDark: isDark,
//               validator: (val) {
//                 if (val == null || val.trim().isEmpty) {
//                   return 'أدخل البريد الإلكتروني أو رقم الهاتف';
//                 }
//                 return null;
//               },
//             ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),
//             SizedBox(height: 20.h),
//             _buildInputField(
//               controller: _passwordController,
//               hint: 'كلمة المرور',
//               icon: Icons.lock_rounded,
//               obscure: !_showPassword,
//               isDark: isDark,
//               suffixIcon: IconButton(
//                 icon: Icon(
//                   _showPassword
//                       ? Icons.visibility_rounded
//                       : Icons.visibility_off_rounded,
//                   color: isDark
//                       ? Colors.grey.shade500
//                       : AppColors.greyMedium,
//                   size: 20.sp,
//                 ),
//                 onPressed: () =>
//                     setState(() => _showPassword = !_showPassword),
//               ),
//               validator: (val) {
//                 if (val == null || val.trim().isEmpty) {
//                   return 'أدخل كلمة المرور';
//                 }
//                 if (val.length < 6) {
//                   return 'كلمة المرور قصيرة جدًا (6 أحرف على الأقل)';
//                 }
//                 return null;
//               },
//             ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),
//             SizedBox(height: 16.h),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     SizedBox(
//                       width: 24.w,
//                       height: 24.h,
//                       child: Checkbox(
//                         value: _rememberMe,
//                         onChanged: (val) {
//                           setState(() => _rememberMe = val ?? false);
//                         },
//                         activeColor: AppColors.darkRed,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(4.r),
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 8.w),
//                     Text(
//                       'تذكرني',
//                       style: TextStyle(
//                         fontSize: 13.sp,
//                         color: isDark
//                             ? Colors.grey.shade400
//                             : AppColors.greyDark,
//                         fontFamily: 'Cairo',
//                       ),
//                     ),
//                   ],
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) =>
//                          ForgotPasswordScreen(),
//                       ),
//                     );
//                   },
//                   style: TextButton.styleFrom(
//                     padding: EdgeInsets.zero,
//                     minimumSize: const Size(0, 0),
//                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                   ),
//                   child: Text(
//                     'نسيت كلمة المرور؟',
//                     style: TextStyle(
//                       fontSize: 13.sp,
//                       color: AppColors.darkRed,
//                       fontWeight: FontWeight.w600,
//                       fontFamily: 'Cairo',
//                     ),
//                   ),
//                 ),
//               ],
//             ).animate().fadeIn(delay: 600.ms),
//             SizedBox(height: 30.h),
//             SizedBox(
//               width: double.infinity,
//               height: 52.h,
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _login,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.darkRed,
//                   foregroundColor: Colors.white,
//                   disabledBackgroundColor: Colors.grey.shade300,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16.r),
//                   ),
//                 ),
//                 child: _isLoading
//                     ? SizedBox(
//                   height: 24.h,
//                   width: 24.w,
//                   child: const CircularProgressIndicator(
//                     color: Colors.white,
//                     strokeWidth: 2,
//                   ),
//                 )
//                     : Text(
//                   'تسجيل الدخول',
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Cairo',
//                   ),
//                 ),
//               ),
//             ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),
//             _buildBiometricButton(isDark),
//           ],
//         ),
//       ),
//     ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.9, 0.9));
//   }
//
//   Widget _buildInputField({
//     required TextEditingController controller,
//     required String hint,
//     required IconData icon,
//     required bool isDark,
//     bool obscure = false,
//     Widget? suffixIcon,
//     TextInputType keyboardType = TextInputType.text,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscure,
//       keyboardType: keyboardType,
//       validator: validator,
//       style: TextStyle(
//         color: isDark ? Colors.white : AppColors.black,
//         fontSize: 14.sp,
//         fontFamily: 'Cairo',
//       ),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: TextStyle(
//           color: isDark ? Colors.grey.shade600 : AppColors.greyMedium,
//           fontSize: 13.sp,
//           fontFamily: 'Cairo',
//         ),
//         prefixIcon: Icon(icon, color: AppColors.darkRed, size: 20.sp),
//         suffixIcon: suffixIcon,
//         filled: true,
//         fillColor:
//         isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14.r),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14.r),
//           borderSide: BorderSide(
//             color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14.r),
//           borderSide:
//           const BorderSide(color: AppColors.darkRed, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14.r),
//           borderSide: const BorderSide(color: AppColors.error),
//         ),
//         contentPadding:
//         EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
//       ),
//     );
//   }
//
//   Widget _buildBiometricButton(bool isDark) {
//     return Consumer<SettingsProvider>(
//       builder: (context, settingsProvider, _) {
//         if (!settingsProvider.biometricAvailable ||
//             !settingsProvider.biometricEnabled) {
//           return const SizedBox.shrink();
//         }
//
//         return Center(
//           child: GestureDetector(
//             onTap: _isLoading ? null : _authenticateWithBiometric,
//             child: Container(
//               margin: EdgeInsets.only(top: 16.h),
//               padding: EdgeInsets.all(16.r),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: LinearGradient(
//                   colors: [
//                     AppColors.gold.withOpacity(0.2),
//                     AppColors.gold.withOpacity(0.1),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.gold.withOpacity(0.3),
//                     blurRadius: 20,
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               child: Icon(
//                 Icons.fingerprint_rounded,
//                 size: 40.sp,
//                 color: _isLoading ? Colors.grey : AppColors.gold,
//               ),
//             ),
//           ),
//         )
//             .animate(onPlay: (controller) => controller.repeat())
//             .shimmer(
//           duration: 2000.ms,
//           color: AppColors.gold.withOpacity(0.5),
//         )
//             .animate()
//             .scale(duration: 600.ms, curve: Curves.easeOutBack)
//             .fadeIn(duration: 400.ms);
//       },
//     );
//   }
//
//   Widget _buildRegisterLink(bool isDark) {
//     return GestureDetector(
//       onTap: _navigateToRegister,
//       child: RichText(
//         text: TextSpan(
//           style: TextStyle(
//             fontSize: 14.sp,
//             color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
//             fontFamily: 'Cairo',
//           ),
//           children: const [
//             TextSpan(text: 'ليس لديك حساب؟ '),
//             TextSpan(
//               text: 'أنشئ حسابًا',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.darkRed,
//                 decoration: TextDecoration.underline,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ).animate().fadeIn(delay: 800.ms);
//   }
//
//   void _navigateToRegister() {
//     Navigator.of(context).push(
//       PageRouteBuilder(
//         pageBuilder: (_, __, ___) => const RegisterScreen(),
//         transitionsBuilder: (_, animation, __, child) {
//           const begin = Offset(1.0, 0);
//           const end = Offset.zero;
//           final tween =
//           Tween(begin: begin, end: end).chain(
//             CurveTween(curve: Curves.easeInOut),
//           );
//           final offsetAnimation = animation.drive(tween);
//           return SlideTransition(position: offsetAnimation, child: child);
//         },
//       ),
//     );
//   }
// }


import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:millionaire_barber/core/constants/app_colors.dart';
import 'package:millionaire_barber/core/constants/app_constants.dart';
import 'package:millionaire_barber/core/services/connectivity_service.dart';
import 'package:millionaire_barber/core/services/firebase_messaging_service.dart';
import 'package:millionaire_barber/features/authentication/presentation/pages/forgot_password_screen.dart';
import 'package:millionaire_barber/shared/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../profile/domain/models/user_model.dart' as local_user;
import '../../../profile/presentation/providers/user_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  StreamSubscription<InternetConnectionStatus>? _internetSubscription;

  // ✅ إصلاح 1: FlutterSecureStorage مع AndroidOptions
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // ✅ إصلاح 2: InternetConnectionChecker مع عنوان Supabase مباشرة
  late final InternetConnectionChecker _connectionChecker;

  @override
  void initState() {
    super.initState();
    // ✅ ننتظر اكتمال أول frame قبل أي عملية
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }


  Future<void> _initializeScreen() async {
    _internetSubscription =
        InternetConnectionChecker().onStatusChange.listen((status) async {
          if (!mounted) return;
          if (status == InternetConnectionStatus.disconnected) {
            CustomSnackbar.showInternetError(context);
          } else {
            final quality = await ConnectionService.checkQuality();
            if (quality == ConnectionQuality.unstable && mounted) {
              CustomSnackbar.showWarning(
                context,
                'الاتصال غير مستقر، قد تكون العملية بطيئة ⚠️',
              );
            }
          }
        });

    // ✅ فحص عند فتح الشاشة
    final quality = await ConnectionService.checkQuality();
    if (!mounted) return;

    if (quality == ConnectionQuality.none) {
      CustomSnackbar.showInternetError(context);
    } else if (quality == ConnectionQuality.unstable) {
      CustomSnackbar.showWarning(
        context,
        'الاتصال غير مستقر، قد تكون العملية بطيئة ⚠️',
      );
    }

    // ✅ باقي منطق Login كما هو
    try {
      final settingsProvider =
      Provider.of<SettingsProvider>(context, listen: false);

      await settingsProvider.refresh();
      await _loadSavedCredentials();

      if (!mounted) return;

      final hasBiometricCreds = await _hasBiometricCredentials();

      if (settingsProvider.biometricEnabled &&
          settingsProvider.biometricAvailable &&
          hasBiometricCreds &&
          mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!_isLoading && mounted) {
          await _authenticateWithBiometric();
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Future<void> _initializeScreen() async {
  //   _internetSubscription = InternetConnectionChecker().onStatusChange.listen((status) {
  //     if (status == InternetConnectionStatus.disconnected && mounted) {
  //       CustomSnackbar.showInternetError(context);
  //     }
  //   });
  //
  //   if (!mounted) return;
  //
  //   try {
  //     final settingsProvider =
  //     Provider.of<SettingsProvider>(context, listen: false);
  //
  //     // ✅ الآن آمن لأننا بعد اكتمال البناء
  //     await settingsProvider.refresh();
  //     await _loadSavedCredentials();
  //
  //     if (!mounted) return;
  //
  //     final hasBiometricCreds = await _hasBiometricCredentials();
  //
  //     if (settingsProvider.biometricEnabled &&
  //         settingsProvider.biometricAvailable &&
  //         hasBiometricCreds &&
  //         mounted) {
  //       await Future.delayed(const Duration(milliseconds: 500));
  //       if (!_isLoading && mounted) {
  //         await _authenticateWithBiometric();
  //       }
  //     }
  //   } catch (e) {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

  Future<bool> _hasBiometricCredentials() async {
    final identifier = await _secureStorage.read(key: 'bio_identifier');
    final password = await _secureStorage.read(key: 'bio_password');
    return identifier != null && password != null;
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final savedIdentifier =
      await _secureStorage.read(key: 'saved_identifier');
      final rememberMeStr = await _secureStorage.read(key: 'remember_me');

      if (mounted && savedIdentifier != null && rememberMeStr == 'true') {
        setState(() {
          _identifierController.text = savedIdentifier;
          _rememberMe = true;
        });
      }
    } catch (_) {}
  }

  Future<void> _authenticateWithBiometric() async {
    try {
      if (!mounted) return;

      final settingsProvider =
      Provider.of<SettingsProvider>(context, listen: false);

      final authenticated = await settingsProvider.authenticateForLogin();
      if (!authenticated) return;

      final savedPassword = await _secureStorage.read(key: 'bio_password');
      final savedIdentifier =
      await _secureStorage.read(key: 'bio_identifier');

      if (savedPassword == null || savedIdentifier == null) {
        if (!mounted) return;
        CustomSnackbar.showError(
          context,
          'لا توجد بيانات دخول محفوظة للبصمة، سجّل دخولك مرة واحدة أولاً',
        );
        return;
      }

      if (_isLoading) {
        setState(() => _isLoading = false);
        await Future.delayed(const Duration(milliseconds: 100));
      }

      _identifierController.text = savedIdentifier;
      _passwordController.text = savedPassword;

      await _login(fromBiometric: true);
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'فشل التحقق من البصمة');
        setState(() => _isLoading = false);
      }
    }
  }

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // ✅ إصلاح 4: منطق تسجيل الدخول مع معالجة شاملة لأخطاء الشبكة
  Future<void> _login({bool fromBiometric = false}) async {
    if (_isLoading) return;

    if (!fromBiometric && !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final input = _identifierController.text.trim();
      final passwordInput = _passwordController.text.trim();

      if (input.isEmpty || passwordInput.isEmpty) {
        throw Exception('الرجاء إدخال البريد الإلكتروني وكلمة المرور');
      }
      if (passwordInput.length < 6) {
        throw Exception('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      }

      final hashedInputPassword = hashPassword(passwordInput);
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      local_user.UserModel? user;

      // ✅ المحاولة مباشرة والتعامل مع أخطاء الشبكة في catch
      if (emailRegex.hasMatch(input)) {
        user = await userProvider.userRepository.getUserByEmail(input);
      } else {
        user = await userProvider.userRepository.getUserByPhone(input);
      }

      if (user == null) throw Exception('المستخدم غير موجود');
      if (user.passwordHash != hashedInputPassword) {
        throw Exception('كلمة المرور غير صحيحة');
      }

      await _saveCredentials(input, passwordInput);

      if (user.id != null) {
        await userProvider.saveCurrentUserId(user.id!);
      }

      userProvider.login(user);
      await userProvider.setLoggedIn(true);
      await _saveFCMToken(userProvider, user.id);

      if (!mounted) return;

      CustomSnackbar.showSuccess(
        context,
        "مرحباً ${user.fullName}! تم تسجيل الدخول بنجاح",
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/home');
    } on SocketException {
      if (mounted) {
        CustomSnackbar.showError(context, 'لا يوجد اتصال بالإنترنت');
      }
    } on TimeoutException {
      if (mounted) {
        CustomSnackbar.showError(
            context, 'انتهت مهلة الاتصال، تحقق من الإنترنت وأعد المحاولة');
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        CustomSnackbar.showError(
            context, 'خطأ في الاتصال بالخادم: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCredentials(String identifier, String password) async {
    try {
      await _secureStorage.write(key: 'bio_identifier', value: identifier);
      await _secureStorage.write(key: 'bio_password', value: password);

      if (_rememberMe) {
        await _secureStorage.write(
            key: 'saved_identifier', value: identifier);
        await _secureStorage.write(key: 'remember_me', value: 'true');
      } else {
        await _secureStorage.delete(key: 'saved_identifier');
        await _secureStorage.write(key: 'remember_me', value: 'false');
      }
    } catch (_) {}
  }

  Future<void> _saveFCMToken(UserProvider userProvider, int? userId) async {
    try {
      if (userId == null) return;

      final messagingService = FirebaseMessagingService();
      final fcmToken = messagingService.fcmToken;

      Future<void> subscribeVipIfNeeded() async {
        try {
          final user = await Supabase.instance.client
              .from('users')
              .select('vip_status')
              .eq('id', userId)
              .single();

          if (user['vip_status'] == true) {
            await messagingService.subscribeToTopic('vip_users').catchError((_) {});
          }
        } catch (_) {}
      }

      final token = fcmToken ??
          await Future.delayed(
            const Duration(seconds: 1),
                () => messagingService.fcmToken,
          );

      if (token != null) {
        await userProvider.saveFCMToken(userId).catchError((_) {});
        await messagingService.subscribeToTopic('all_users').catchError((_) {});
        await subscribeVipIfNeeded();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _internetSubscription?.cancel();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─────────────────────────── UI ───────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // ✅ Adaptive: حجم الشاشة للتكيف مع الأجهزة المختلفة
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
        isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth > 600 ? 80.w : 24.w,
                  vertical: 20.h,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(height: isSmallScreen ? 20.h : 40.h),
                        _buildLogo(isDark, isSmallScreen),
                        SizedBox(height: isSmallScreen ? 16.h : 30.h),
                        _buildTitle(isDark, isSmallScreen),
                        SizedBox(height: isSmallScreen ? 16.h : 30.h),
                        _buildLoginCard(isDark, isSmallScreen),
                        SizedBox(height: 24.h),
                        _buildRegisterLink(isDark),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isDark, bool isSmallScreen) {
    final size = isSmallScreen ? 110.0 : 150.0;

    return Hero(
      tag: "app_logo",
      child: SizedBox(
        height: size.h,
        width: size.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: size.h,
              width: size.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .scale(
              duration: 2000.ms,
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.1, 1.1),
            )
                .then()
                .scale(
              duration: 2000.ms,
              begin: const Offset(1.1, 1.1),
              end: const Offset(0.9, 0.9),
            ),
            Container(
              height: (size - 20).h,
              width: (size - 20).w,
              padding: EdgeInsets.all(15.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF2A2A2A), const Color(0xFF1E1E1E)]
                      : [Colors.white, Colors.grey.shade50],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkRed.withOpacity(0.3),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo_hd.png',
                  fit: BoxFit.cover,
                ),
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(bool isDark, bool isSmallScreen) {
    return Column(
      children: [
        Text(
          'أهلاً بك',
          style: TextStyle(
            fontSize: isSmallScreen ? 22.sp : 28.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.black,
            fontFamily: 'Cairo',
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2),
        SizedBox(height: 5.h),
        Text(
          'سجل دخولك للمتابعة',
          style: TextStyle(
            fontSize: isSmallScreen ? 13.sp : 15.sp,
            color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
            fontFamily: 'Cairo',
          ),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildLoginCard(bool isDark, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16.r : 24.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildInputField(
              controller: _identifierController,
              hint: 'البريد الإلكتروني أو رقم الهاتف',
              icon: Icons.person_rounded,
              keyboardType: TextInputType.text,
              isDark: isDark,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'أدخل البريد الإلكتروني أو رقم الهاتف';
                }
                return null;
              },
            ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),
            SizedBox(height: 16.h),
            _buildInputField(
              controller: _passwordController,
              hint: 'كلمة المرور',
              icon: Icons.lock_rounded,
              obscure: !_showPassword,
              isDark: isDark,
              suffixIcon: IconButton(
                icon: Icon(
                  _showPassword
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: isDark
                      ? Colors.grey.shade500
                      : AppColors.greyMedium,
                  size: 20.sp,
                ),
                onPressed: () =>
                    setState(() => _showPassword = !_showPassword),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'أدخل كلمة المرور';
                }
                if (val.length < 6) {
                  return 'كلمة المرور قصيرة جدًا (6 أحرف على الأقل)';
                }
                return null;
              },
            ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),
            SizedBox(height: 12.h),
            _buildRememberForgotRow(isDark),
            SizedBox(height: isSmallScreen ? 20.h : 30.h),
            _buildLoginButton(isDark),
            _buildBiometricButton(isDark),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildRememberForgotRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 24.w,
              height: 24.h,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (val) =>
                    setState(() => _rememberMe = val ?? false),
                activeColor: AppColors.darkRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'تذكرني',
              style: TextStyle(
                fontSize: 13.sp,
                color:
                isDark ? Colors.grey.shade400 : AppColors.greyDark,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ForgotPasswordScreen(),
            ),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'نسيت كلمة المرور؟',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.darkRed,
              fontWeight: FontWeight.w600,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildLoginButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkRed,
          foregroundColor: Colors.white,
          disabledBackgroundColor: isDark
              ? Colors.grey.shade800
              : Colors.grey.shade300,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isLoading
              ? SizedBox(
            key: const ValueKey('loading'),
            height: 24.h,
            width: 24.w,
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : Text(
            key: const ValueKey('text'),
            'تسجيل الدخول',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2);
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      textInputAction: TextInputAction.next,
      style: TextStyle(
        color: isDark ? Colors.white : AppColors.black,
        fontSize: 14.sp,
        fontFamily: 'Cairo',
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.grey.shade600 : AppColors.greyMedium,
          fontSize: 13.sp,
          fontFamily: 'Cairo',
        ),
        prefixIcon: Icon(icon, color: AppColors.darkRed, size: 20.sp),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor:
        isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(
            color:
            isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppColors.darkRed, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding:
        EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      ),
    );
  }

  Widget _buildBiometricButton(bool isDark) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        if (!settingsProvider.biometricAvailable ||
            !settingsProvider.biometricEnabled) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.only(top: 16.h),
          child: Column(
            children: [
              Text(
                'أو سجّل الدخول بالبصمة',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark
                      ? Colors.grey.shade500
                      : AppColors.greyMedium,
                  fontFamily: 'Cairo',
                ),
              ),
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: _isLoading ? null : _authenticateWithBiometric,
                child: Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.gold.withOpacity(0.2),
                        AppColors.gold.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.fingerprint_rounded,
                    size: 40.sp,
                    color: _isLoading ? Colors.grey : AppColors.gold,
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(
                duration: 2000.ms,
                color: AppColors.gold.withOpacity(0.5),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.easeOutBack)
                  .fadeIn(duration: 400.ms),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRegisterLink(bool isDark) {
    return GestureDetector(
      onTap: _navigateToRegister,
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 14.sp,
            color:
            isDark ? Colors.grey.shade400 : AppColors.greyDark,
            fontFamily: 'Cairo',
          ),
          children: const [
            TextSpan(text: 'ليس لديك حساب؟ '),
            TextSpan(
              text: 'أنشئ حسابًا',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkRed,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 800.ms);
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const RegisterScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final tween = Tween(
            begin: const Offset(1.0, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOut));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}
