// import 'dart:convert';
// import 'dart:async';
// import 'dart:io';
// import 'package:crypto/crypto.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
// import 'package:millionaire_barber/core/services/firebase_messaging_service.dart';
// import 'package:millionaire_barber/shared/widgets/custom_snackbar.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'dart:ui' as ui;
//
// import '../../../../core/constants/app_colors.dart';
// import '../../../profile/domain/models/user_model.dart';
// import '../../../profile/presentation/providers/user_provider.dart';
//
// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({Key? key}) : super(key: key);
//
//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }
//
// class _RegisterScreenState extends State<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _addressController = TextEditingController();
//
//   bool _showPassword = false;
//   bool _showConfirmPassword = false;
//   bool _isLoading = false;
//   bool _isPhoneValid = false;
//   bool _acceptTerms = false;
//
//   String countryCode = '+967';
//   String flagEmoji = '🇾🇪';
//
//   late StreamSubscription<InternetConnectionStatus> _internetSubscription;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeScreen();
//   }
//
//   Future<void> _initializeScreen() async {
//
//     _internetSubscription =
//         InternetConnectionChecker().onStatusChange.listen((status) {
//       if (status == InternetConnectionStatus.disconnected && mounted) {
//         CustomSnackbar.showInternetError(context);
//       }
//     });
//
//     final connected = await InternetConnectionChecker().hasConnection;
//
//     if (!connected && mounted) {
//       CustomSnackbar.showInternetError(context);
//     }
//
//   }
//
//   @override
//   void dispose() {
//     _internetSubscription.cancel();
//     _nameController.dispose();
//     _phoneController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }
//
//   /// ✅ التحقق من رقم الهاتف
//   String? _validatePhone(String? val) {
//     if (val == null || val.trim().isEmpty) {
//       return 'أدخل رقم الهاتف';
//     }
//
//     final phone = val.trim();
//
//     if (phone.length != 9) {
//       return 'رقم الهاتف يجب أن يكون 9 أرقام';
//     }
//
//     final validPrefixes = ['77', '78', '73', '71'];
//     final hasValidPrefix =
//         validPrefixes.any((prefix) => phone.startsWith(prefix));
//
//     if (!hasValidPrefix) {
//       return 'يجب أن يبدأ بـ 77 أو 78 أو 73 أو 71';
//     }
//
//     return null;
//   }
//
//   /// ✅ Hash Password
//   String hashPassword(String password) {
//     final bytes = utf8.encode(password);
//     return sha256.convert(bytes).toString();
//   }
//
//
//   // Future<void> _register() async {
//   //
//   //   if (!_formKey.currentState!.validate()) {
//   //     return;
//   //   }
//   //
//   //   if (!_acceptTerms) {
//   //     CustomSnackbar.showError(context, 'يجب الموافقة على الشروط والأحكام');
//   //     return;
//   //   }
//   //
//   //   setState(() => _isLoading = true);
//   //
//   //   try {
//   //     // ✅ فحص الاتصال بالإنترنت
//   //     final connected = await InternetConnectionChecker().hasConnection;
//   //
//   //     if (!connected) {
//   //       if (mounted) CustomSnackbar.showInternetError(context);
//   //       return;
//   //     }
//   //
//   //     final supabase = Supabase.instance.client;
//   //     final userProvider = Provider.of<UserProvider>(context, listen: false);
//   //
//   //     final fullName = _nameController.text.trim();
//   //     final phone = _phoneController.text.trim();
//   //     final email = _emailController.text.trim();
//   //     final password = _passwordController.text.trim();
//   //     final address = _addressController.text.trim();
//   //
//   //
//   //     // ✅ تحقق من وجود المستخدم مسبقاً
//   //     final existingUser = await supabase
//   //         .from('users')
//   //         .select()
//   //         .or('email.eq.$email,phone.eq.$phone')
//   //         .maybeSingle();
//   //
//   //     if (existingUser != null) {
//   //       if ((existingUser['email'] as String?) == email) {
//   //         throw Exception('البريد الإلكتروني مسجل بالفعل');
//   //       }
//   //       if ((existingUser['phone'] as String?) == phone) {
//   //         throw Exception('رقم الهاتف مسجل بالفعل');
//   //       }
//   //     }
//   //
//   //
//   //     // ✅ التسجيل في Supabase Auth
//   //     final response = await supabase.auth.signUp(
//   //       email: email,
//   //       password: password,
//   //     );
//   //
//   //     if (response.user == null) {
//   //       throw Exception('فشل التسجيل في نظام المصادقة');
//   //     }
//   //
//   //     final hashedPass = hashPassword(password);
//   //     final authUserId = response.user!.id;
//   //
//   //     // ✅ إضافة المستخدم لجدول users (قاعدة البيانات الرئيسية)
//   //     final insertedData = await supabase
//   //         .from('users')
//   //         .insert({
//   //           'full_name': fullName,
//   //           'phone': phone,
//   //           'email': email,
//   //           'password_hash': hashedPass,
//   //           'address': address,
//   //           'gender': 'male', // يمكن جعله حسب اختيار المستخدم
//   //           'auth_uid': authUserId,
//   //           'created_at': DateTime.now().toIso8601String(),
//   //         })
//   //         .select()
//   //         .single();
//   //
//   //
//   //     final newUser = UserModel.fromJson(insertedData);
//   //
//   //     // ✅ حفظ معرف المستخدم وتحديث السياق وحالة FCM Token
//   //     if (newUser.id != null) {
//   //       await userProvider.saveCurrentUserId(newUser.id!);
//   //
//   //       // ✅ حفظ FCM Token في قاعدة البيانات إن وجد
//   //       try {
//   //         final fcmToken = FirebaseMessagingService().fcmToken;
//   //         if (fcmToken != null) {
//   //           await userProvider.saveFCMToken(newUser.id!);
//   //         }
//   //       } catch (e) {
//   //       }
//   //
//   //     }
//   //
//   //     // ✅ تسجيل الدخول الفوري
//   //     userProvider.login(newUser);
//   //     await userProvider.setLoggedIn(true);
//   //
//   //     if (!mounted) return;
//   //
//   //     // ✅ رسالة النجاح
//   //     CustomSnackbar.showSuccess(
//   //       context,
//   //       "مرحباً $fullName! تم إنشاء حسابك بنجاح 🎉",
//   //     );
//   //
//   //     // ✅ الانتقال للصفحة الرئيسية بعد تأخير قصير
//   //     await Future.delayed(const Duration(milliseconds: 500));
//   //     if (mounted) {
//   //       Navigator.pushReplacementNamed(context, '/home');
//   //     }
//   //
//   //   } on SocketException catch (_) {
//   //     if (mounted) CustomSnackbar.showError(context, 'لا يوجد اتصال بالإنترنت');
//   //   } on TimeoutException catch (_) {
//   //     if (mounted)
//   //       CustomSnackbar.showError(context, 'انتهت مهلة الاتصال، حاول لاحقاً');
//   //   } catch (e, stackTrace) {
//   //
//   //     if (mounted) {
//   //       String errorMessage = 'حدث خطأ أثناء التسجيل';
//   //
//   //       if (e.toString().contains('already registered') ||
//   //           e.toString().contains('already exists')) {
//   //         errorMessage = 'البريد الإلكتروني أو رقم الهاتف مسجل بالفعل';
//   //       } else if (e.toString().contains('network')) {
//   //         errorMessage = 'خطأ في الاتصال بالإنترنت';
//   //       } else if (e is Exception) {
//   //         errorMessage = e.toString().replaceAll('Exception: ', '');
//   //       }
//   //
//   //       CustomSnackbar.showError(context, errorMessage);
//   //     }
//   //   } finally {
//   //     if (mounted) {
//   //       setState(() => _isLoading = false);
//   //     }
//   //   }
//   // }
//
//   Future<void> _register() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }
//
//     if (!_acceptTerms) {
//       CustomSnackbar.showError(context, 'يجب الموافقة على الشروط والأحكام');
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       // ✅ فحص الاتصال بالإنترنت
//       final connected = await InternetConnectionChecker().hasConnection;
//       if (!connected) {
//         if (mounted) CustomSnackbar.showInternetError(context);
//         return;
//       }
//
//       final supabase = Supabase.instance.client;
//       final userProvider = Provider.of<UserProvider>(context, listen: false);
//
//       final fullName = _nameController.text.trim();
//       final phone = _phoneController.text.trim();
//       final email = _emailController.text.trim();
//       final password = _passwordController.text.trim();
//       final address = _addressController.text.trim();
//
//       // ✅ تحقق من وجود المستخدم مسبقاً (Phone أو Email)
//       final checkQuery = StringBuffer('phone.eq.$phone');
//       if (email.isNotEmpty) {
//         checkQuery.write(',email.eq.$email');
//       }
//
//       final existingUser = await supabase
//           .from('users')
//           .select()
//           .or(checkQuery.toString())
//           .maybeSingle();
//
//       if (existingUser != null) {
//         // التحقق من التفاصيل
//         if ((existingUser['phone'] as String?) == phone) {
//           throw Exception('رقم الهاتف مسجل بالفعل');
//         }
//         if (email.isNotEmpty && (existingUser['email'] as String?) == email) {
//           throw Exception('البريد الإلكتروني مسجل بالفعل');
//         }
//       }
//
//       // ✅ Hash Password
//       final hashedPass = hashPassword(password);
//
//       // ✅ إضافة المستخدم مباشرة لجدول users (بدون Supabase Auth)
//       final insertedData = await supabase
//           .from('users')
//           .insert({
//         'full_name': fullName,
//         'phone': phone,
//         'email': email.isNotEmpty ? email : null,
//         'password_hash': hashedPass,
//         'address': address,
//         'gender': 'male',
//         'role': 'client', // ✅ دور افتراضي
//         'auth_uid': null, // ✅ لا نستخدم Supabase Auth
//         'is_active': true,
//         'loyalty_points': 0,
//         'vip_status': false,
//         'created_at': DateTime.now().toIso8601String(),
//         'updated_at': DateTime.now().toIso8601String(),
//         'registration_date': DateTime.now().toIso8601String(),
//       })
//           .select()
//           .single();
//
//       final newUser = UserModel.fromJson(insertedData);
//
//       // ✅ حفظ معرف المستخدم في SharedPreferences
//       if (newUser.id != null) {
//         await userProvider.saveCurrentUserId(newUser.id!);
//
//         // ✅ حفظ FCM Token
//         try {
//           final fcmToken = FirebaseMessagingService().fcmToken;
//           if (fcmToken != null) {
//             await userProvider.saveFCMToken(newUser.id!);
//           }
//         } catch (e) {
//           // تجاهل خطأ FCM
//         }
//       }
//
//       // ✅ تسجيل الدخول الفوري
//       userProvider.login(newUser);
//       await userProvider.setLoggedIn(true);
//
//       if (!mounted) return;
//
//       // ✅ رسالة النجاح
//       CustomSnackbar.showSuccess(
//         context,
//         "مرحباً $fullName! تم إنشاء حسابك بنجاح 🎉",
//       );
//
//       // ✅ الانتقال للصفحة الرئيسية
//       await Future.delayed(const Duration(milliseconds: 500));
//       if (mounted) {
//         Navigator.pushReplacementNamed(context, '/home');
//       }
//
//     } on SocketException catch (_) {
//       if (mounted) CustomSnackbar.showError(context, 'لا يوجد اتصال بالإنترنت');
//     } on TimeoutException catch (_) {
//       if (mounted) {
//         CustomSnackbar.showError(context, 'انتهت مهلة الاتصال، حاول لاحقاً');
//       }
//     } on PostgrestException catch (e) {
//       // ✅ التعامل مع أخطاء Supabase
//       if (mounted) {
//         String errorMessage = 'حدث خطأ أثناء التسجيل';
//
//         if (e.message.contains('duplicate key') ||
//             e.message.contains('unique constraint')) {
//           if (e.message.contains('phone')) {
//             errorMessage = 'رقم الهاتف مسجل بالفعل';
//           } else if (e.message.contains('email')) {
//             errorMessage = 'البريد الإلكتروني مسجل بالفعل';
//           }
//         } else if (e.message.contains('violates foreign key')) {
//           errorMessage = 'خطأ في البيانات المدخلة';
//         }
//
//         CustomSnackbar.showError(context, errorMessage);
//       }
//     } catch (e) {
//       if (mounted) {
//         String errorMessage = 'حدث خطأ أثناء التسجيل';
//
//         if (e is Exception) {
//           errorMessage = e.toString().replaceAll('Exception: ', '');
//         }
//
//         CustomSnackbar.showError(context, errorMessage);
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Directionality(
//       textDirection: ui.TextDirection.rtl,
//       child: Scaffold(
//         backgroundColor:
//             isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
//         body: SafeArea(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
//             child: Column(
//               children: [
//                 // ✅ Back Button
//                 _buildBackButton(isDark),
//
//                 SizedBox(height: 20.h),
//
//                 // ✅ Logo
//                 _buildLogo(isDark),
//
//                 SizedBox(height: 24.h),
//
//                 // ✅ Title
//                 _buildTitle(isDark),
//
//                 SizedBox(height: 32.h),
//
//                 // ✅ Form Card
//                 _buildFormCard(isDark),
//
//                 SizedBox(height: 24.h),
//
//                 // ✅ Login Link
//                 _buildLoginLink(isDark),
//
//                 SizedBox(height: 20.h),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// ✅ Back Button
//   Widget _buildBackButton(bool isDark) {
//     return Align(
//       alignment: Alignment.centerRight,
//       child: Container(
//         decoration: BoxDecoration(
//           color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(
//             color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
//           ),
//         ),
//         child: IconButton(
//           icon: Icon(
//             Icons.arrow_back_ios_rounded,
//             color: isDark ? Colors.white : AppColors.black,
//             size: 18.sp,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//     ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.2);
//   }
//
//   /// ✅ Logo
//   Widget _buildLogo(bool isDark) {
//     return Hero(
//       tag: "app_logo",
//       child: Container(
//         height: 120.h,
//         width: 120.w,
//         padding: EdgeInsets.all(15.r),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: isDark
//                 ? [const Color(0xFF2A2A2A), const Color(0xFF1E1E1E)]
//                 : [Colors.white, Colors.grey.shade50],
//           ),
//           shape: BoxShape.circle,
//           border: Border.all(color: AppColors.gold, width: 2.5),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.darkRed.withOpacity(0.2),
//               blurRadius: 20,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//         child: ClipOval(
//           child: Image.asset('assets/images/logo_hd.png', fit: BoxFit.cover),
//         ),
//       ),
//     ).animate().scale(duration: 600.ms, curve: Curves.elasticOut);
//   }
//
//   /// ✅ Title
//   Widget _buildTitle(bool isDark) {
//     return Column(
//       children: [
//         Text(
//           'أنشئ حسابك',
//           style: TextStyle(
//             fontSize: 26.sp,
//             fontWeight: FontWeight.bold,
//             color: isDark ? Colors.white : AppColors.black,
//             fontFamily: 'Cairo',
//           ),
//         ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2),
//         SizedBox(height: 8.h),
//         Text(
//           'ابدأ رحلتك نحو إطلالة أنيقة كل يوم ✨',
//           style: TextStyle(
//             fontSize: 14.sp,
//             color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
//             fontFamily: 'Cairo',
//           ),
//           textAlign: TextAlign.center,
//         ).animate().fadeIn(delay: 300.ms),
//       ],
//     );
//   }
//
//   /// ✅ Form Card
//   Widget _buildFormCard(bool isDark) {
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
//             // ✅ Full Name
//             _buildInputField(
//               controller: _nameController,
//               hint: 'الاسم الكامل',
//               icon: Icons.person_rounded,
//               isDark: isDark,
//               validator: (val) {
//                 if (val == null || val.trim().isEmpty) {
//                   return 'أدخل الاسم الكامل';
//                 }
//                 if (val.trim().length < 3) {
//                   return 'الاسم قصير جداً (3 أحرف على الأقل)';
//                 }
//                 return null;
//               },
//             ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),
//
//             SizedBox(height: 16.h),
//
//             // ✅ Email
//             _buildInputField(
//               controller: _emailController,
//               hint: 'البريد الإلكتروني (اختياري)',  // ✅ إضافة (اختياري)
//               icon: Icons.email_rounded,
//               keyboardType: TextInputType.emailAddress,
//               isDark: isDark,
//               validator: (val) {
//                 // ✅ السماح بترك الحقل فارغاً
//                 if (val == null || val.trim().isEmpty) {
//                   return null; // ✅ لا يوجد خطأ إذا كان فارغاً
//                 }
//
//                 // ✅ التحقق من الصيغة فقط إذا تم إدخال شيء
//                 final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
//                 if (!emailRegex.hasMatch(val.trim())) {
//                   return 'البريد الإلكتروني غير صالح';
//                 }
//
//                 return null;
//               },
//             ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),
//
//
//             SizedBox(height: 16.h),
//
//             // ✅ Phone
//             _buildPhoneInput(isDark)
//                 .animate()
//                 .fadeIn(delay: 600.ms)
//                 .slideX(begin: -0.2),
//
//             SizedBox(height: 16.h),
//
//             // ✅ Password
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
//                   color: isDark ? Colors.grey.shade500 : AppColors.greyMedium,
//                   size: 20.sp,
//                 ),
//                 onPressed: () => setState(() => _showPassword = !_showPassword),
//               ),
//               validator: (val) {
//                 if (val == null || val.trim().isEmpty) {
//                   return 'أدخل كلمة المرور';
//                 }
//                 if (val.length < 6) {
//                   return 'كلمة المرور قصيرة جداً (6 أحرف على الأقل)';
//                 }
//                 return null;
//               },
//             ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.2),
//
//             SizedBox(height: 16.h),
//
//             // ✅ Confirm Password
//             _buildInputField(
//               controller: _confirmPasswordController,
//               hint: 'تأكيد كلمة المرور',
//               icon: Icons.lock_outline_rounded,
//               obscure: !_showConfirmPassword,
//               isDark: isDark,
//               suffixIcon: IconButton(
//                 icon: Icon(
//                   _showConfirmPassword
//                       ? Icons.visibility_rounded
//                       : Icons.visibility_off_rounded,
//                   color: isDark ? Colors.grey.shade500 : AppColors.greyMedium,
//                   size: 20.sp,
//                 ),
//                 onPressed: () => setState(
//                     () => _showConfirmPassword = !_showConfirmPassword),
//               ),
//               validator: (val) {
//                 if (val == null || val.trim().isEmpty) {
//                   return 'أكد كلمة المرور';
//                 }
//                 if (val != _passwordController.text) {
//                   return 'كلمات المرور غير متطابقة';
//                 }
//                 return null;
//               },
//             ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.2),
//
//             SizedBox(height: 16.h),
//
//             // ✅ Address
//             _buildInputField(
//               controller: _addressController,
//               hint: 'العنوان',
//               icon: Icons.location_on_rounded,
//               isDark: isDark,
//               validator: (val) {
//                 if (val == null || val.trim().isEmpty) {
//                   return 'أدخل العنوان';
//                 }
//                 return null;
//               },
//             ).animate().fadeIn(delay: 900.ms).slideX(begin: -0.2),
//
//             SizedBox(height: 20.h),
//
//             // ✅ Terms Checkbox
//             Row(
//               children: [
//                 SizedBox(
//                   width: 24.w,
//                   height: 24.h,
//                   child: Checkbox(
//                     value: _acceptTerms,
//                     onChanged: (val) =>
//                         setState(() => _acceptTerms = val ?? false),
//                     activeColor: AppColors.darkRed,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(4.r),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 8.w),
//                 Expanded(
//                   child: Text(
//                     'أوافق على الشروط والأحكام وسياسة الخصوصية',
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
//                       fontFamily: 'Cairo',
//                     ),
//                   ),
//                 ),
//               ],
//             ).animate().fadeIn(delay: 1000.ms),
//
//             SizedBox(height: 28.h),
//
//             // ✅ Register Button
//             SizedBox(
//               width: double.infinity,
//               height: 52.h,
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _register,
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
//                         height: 24.h,
//                         width: 24.w,
//                         child: const CircularProgressIndicator(
//                           color: Colors.white,
//                           strokeWidth: 2,
//                         ),
//                       )
//                     : Text(
//                         'إنشاء حساب',
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.bold,
//                           fontFamily: 'Cairo',
//                         ),
//                       ),
//               ),
//             )
//                 .animate()
//                 .fadeIn(delay: 1100.ms)
//                 .scale(begin: const Offset(0.95, 0.95)),
//           ],
//         ),
//       ),
//     ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.9, 0.9));
//   }
//
//   /// ✅ Input Field
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
//         fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
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
//           borderSide: const BorderSide(color: AppColors.darkRed, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14.r),
//           borderSide: const BorderSide(color: AppColors.error),
//         ),
//         contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
//       ),
//     );
//   }
//
//   /// ✅ Phone Input
//   Widget _buildPhoneInput(bool isDark) {
//     return TextFormField(
//       controller: _phoneController,
//       keyboardType: TextInputType.phone,
//       maxLength: 9,
//       inputFormatters: [
//         FilteringTextInputFormatter.digitsOnly,
//         LengthLimitingTextInputFormatter(9),
//       ],
//       onChanged: (value) {
//         setState(() {
//           _isPhoneValid = _validatePhone(value) == null && value.length == 9;
//         });
//       },
//       validator: _validatePhone,
//       style: TextStyle(
//         color: isDark ? Colors.white : AppColors.black,
//         fontSize: 14.sp,
//         fontFamily: 'Cairo',
//         letterSpacing: 1.2,
//       ),
//       decoration: InputDecoration(
//         hintText: 'رقم الهاتف (9 أرقام)',
//         hintStyle: TextStyle(
//           color: isDark ? Colors.grey.shade600 : AppColors.greyMedium,
//           fontSize: 13.sp,
//           fontFamily: 'Cairo',
//         ),
//         helperText: 'يبدأ بـ 77، 78، 73 أو 71',
//         helperStyle: TextStyle(
//           fontSize: 11.sp,
//           color: isDark ? Colors.grey.shade500 : AppColors.greyDark,
//           fontFamily: 'Cairo',
//         ),
//         prefixIcon: Icon(
//           Icons.phone_rounded,
//           color: _isPhoneValid ? Colors.green : AppColors.darkRed,
//           size: 20.sp,
//         ),
//         suffixIcon: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (_phoneController.text.isNotEmpty)
//               Icon(
//                 _isPhoneValid ? Icons.check_circle : Icons.error,
//                 color: _isPhoneValid ? Colors.green : Colors.red,
//                 size: 20.sp,
//               ),
//             SizedBox(width: 8.w),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
//               margin: EdgeInsets.only(left: 8.w),
//               decoration: BoxDecoration(
//                 color: AppColors.darkRed.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     countryCode,
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.darkRed,
//                       fontSize: 13.sp,
//                       fontFamily: 'Cairo',
//                     ),
//                     textDirection: ui.TextDirection.ltr,
//                   ),
//                   SizedBox(width: 6.w),
//                   Text(flagEmoji, style: TextStyle(fontSize: 18.sp)),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         counterText: '${_phoneController.text.length}/9',
//         counterStyle: TextStyle(
//           fontSize: 11.sp,
//           color: _phoneController.text.length == 9 ? Colors.green : Colors.grey,
//           fontFamily: 'Cairo',
//         ),
//         filled: true,
//         fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
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
//           borderSide: BorderSide(
//             color: _isPhoneValid ? Colors.green : AppColors.darkRed,
//             width: 2,
//           ),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14.r),
//           borderSide: const BorderSide(color: AppColors.error, width: 1.5),
//         ),
//         contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
//       ),
//     );
//   }
//
//   /// ✅ Login Link
//   Widget _buildLoginLink(bool isDark) {
//     return GestureDetector(
//       onTap: () => Navigator.pop(context),
//       child: RichText(
//         text: TextSpan(
//           style: TextStyle(
//             fontSize: 14.sp,
//             color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
//             fontFamily: 'Cairo',
//           ),
//           children: const [
//             TextSpan(text: 'لديك حساب؟ '),
//             TextSpan(
//               text: 'تسجيل الدخول',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.darkRed,
//                 decoration: TextDecoration.underline,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ).animate().fadeIn(delay: 1200.ms);
//   }
// }





import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:millionaire_barber/core/constants/app_constants.dart';
import 'package:millionaire_barber/core/services/connectivity_service.dart';
import 'package:millionaire_barber/core/services/firebase_messaging_service.dart';
import 'package:millionaire_barber/shared/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui' as ui;

import '../../../../core/constants/app_colors.dart';
import '../../../profile/domain/models/user_model.dart';
import '../../../profile/presentation/providers/user_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;
  bool _isPhoneValid = false;
  bool _acceptTerms = false;

  String countryCode = '+967';
  String flagEmoji = '🇾🇪';

  // ✅ إصلاح 1: nullable بدل late لتجنب LateInitializationError
  StreamSubscription<InternetConnectionStatus>? _internetSubscription;

  // @override
  // void initState() {
  //   super.initState();
  //   // ✅ نفس نهج Login
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _initializeScreen();
  //   });
  // }

  @override
  void initState() {
    super.initState();
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
  }

  // Future<void> _initializeScreen() async {
  //   _internetSubscription =
  //       InternetConnectionChecker().onStatusChange.listen((status) {
  //         if (status == InternetConnectionStatus.disconnected && mounted) {
  //           CustomSnackbar.showInternetError(context);
  //         }
  //       });
  // }




  @override
  void dispose() {
    _internetSubscription?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'أدخل رقم الهاتف';
    }

    final phone = val.trim();

    if (phone.length != 9) {
      return 'رقم الهاتف يجب أن يكون 9 أرقام';
    }

    final validPrefixes = ['77', '78', '73', '71'];
    final hasValidPrefix =
    validPrefixes.any((prefix) => phone.startsWith(prefix));

    if (!hasValidPrefix) {
      return 'يجب أن يبدأ بـ 77 أو 78 أو 73 أو 71';
    }

    return null;
  }

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      CustomSnackbar.showError(context, 'يجب الموافقة على الشروط والأحكام');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ إصلاح 4: لا نوقف التسجيل بـ return، فقط نحاول والـ catch يتعامل مع الخطأ
      final supabase = Supabase.instance.client;
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final fullName = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final address = _addressController.text.trim();

      final checkQuery = StringBuffer('phone.eq.$phone');
      if (email.isNotEmpty) {
        checkQuery.write(',email.eq.$email');
      }

      final existingUser = await supabase
          .from('users')
          .select()
          .or(checkQuery.toString())
          .maybeSingle();

      if (existingUser != null) {
        if ((existingUser['phone'] as String?) == phone) {
          throw Exception('رقم الهاتف مسجل بالفعل');
        }
        if (email.isNotEmpty &&
            (existingUser['email'] as String?) == email) {
          throw Exception('البريد الإلكتروني مسجل بالفعل');
        }
      }

      final hashedPass = hashPassword(password);

      final insertedData = await supabase
          .from('users')
          .insert({
        'full_name': fullName,
        'phone': phone,
        'email': email.isNotEmpty ? email : null,
        'password_hash': hashedPass,
        'address': address,
        'gender': 'male',
        'role': 'client',
        'auth_uid': null,
        'is_active': true,
        'loyalty_points': 0,
        'vip_status': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'registration_date': DateTime.now().toIso8601String(),
      })
          .select()
          .single();

      final newUser = UserModel.fromJson(insertedData);

      if (newUser.id != null) {
        await userProvider.saveCurrentUserId(newUser.id!);

        try {
          final fcmToken = FirebaseMessagingService().fcmToken;
          if (fcmToken != null) {
            await userProvider.saveFCMToken(newUser.id!);
          }
        } catch (_) {}
      }

      userProvider.login(newUser);
      await userProvider.setLoggedIn(true);

      if (!mounted) return;

      CustomSnackbar.showSuccess(
        context,
        "مرحباً $fullName! تم إنشاء حسابك بنجاح 🎉",
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on SocketException {
      // ✅ إصلاح 5: SocketException يُكشف هنا بدل فحص مسبق
      if (mounted) {
        CustomSnackbar.showError(context, 'لا يوجد اتصال بالإنترنت');
      }
    } on TimeoutException {
      if (mounted) {
        CustomSnackbar.showError(
            context, 'انتهت مهلة الاتصال، حاول لاحقاً');
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        String errorMessage = 'حدث خطأ أثناء التسجيل';

        if (e.message.contains('duplicate key') ||
            e.message.contains('unique constraint')) {
          if (e.message.contains('phone')) {
            errorMessage = 'رقم الهاتف مسجل بالفعل';
          } else if (e.message.contains('email')) {
            errorMessage = 'البريد الإلكتروني مسجل بالفعل';
          }
        } else if (e.message.contains('violates foreign key')) {
          errorMessage = 'خطأ في البيانات المدخلة';
        }

        CustomSnackbar.showError(context, errorMessage);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(
          context,
          e is Exception
              ? e.toString().replaceAll('Exception: ', '')
              : 'حدث خطأ أثناء التسجيل',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
        isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              children: [
                _buildBackButton(isDark),
                SizedBox(height: 20.h),
                _buildLogo(isDark),
                SizedBox(height: 24.h),
                _buildTitle(isDark),
                SizedBox(height: 32.h),
                _buildFormCard(isDark),
                SizedBox(height: 24.h),
                _buildLoginLink(isDark),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(bool isDark) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? Colors.white : AppColors.black,
            size: 18.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.2);
  }

  Widget _buildLogo(bool isDark) {
    return Hero(
      tag: "app_logo",
      child: Container(
        height: 120.h,
        width: 120.w,
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
              color: AppColors.darkRed.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset('assets/images/logo_hd.png', fit: BoxFit.cover),
        ),
      ),
    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut);
  }

  Widget _buildTitle(bool isDark) {
    return Column(
      children: [
        Text(
          'أنشئ حسابك',
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.black,
            fontFamily: 'Cairo',
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2),
        SizedBox(height: 8.h),
        Text(
          'ابدأ رحلتك نحو إطلالة أنيقة كل يوم ✨',
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
            fontFamily: 'Cairo',
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildFormCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(24.r),
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
              controller: _nameController,
              hint: 'الاسم الكامل',
              icon: Icons.person_rounded,
              isDark: isDark,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'أدخل الاسم الكامل';
                }
                if (val.trim().length < 3) {
                  return 'الاسم قصير جداً (3 أحرف على الأقل)';
                }
                return null;
              },
            ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),

            SizedBox(height: 16.h),

            _buildInputField(
              controller: _emailController,
              hint: 'البريد الإلكتروني (اختياري)',
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              isDark: isDark,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return null;
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                if (!emailRegex.hasMatch(val.trim())) {
                  return 'البريد الإلكتروني غير صالح';
                }
                return null;
              },
            ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),

            SizedBox(height: 16.h),

            _buildPhoneInput(isDark)
                .animate()
                .fadeIn(delay: 600.ms)
                .slideX(begin: -0.2),

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
                  color:
                  isDark ? Colors.grey.shade500 : AppColors.greyMedium,
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
                  return 'كلمة المرور قصيرة جداً (6 أحرف على الأقل)';
                }
                return null;
              },
            ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.2),

            SizedBox(height: 16.h),

            _buildInputField(
              controller: _confirmPasswordController,
              hint: 'تأكيد كلمة المرور',
              icon: Icons.lock_outline_rounded,
              obscure: !_showConfirmPassword,
              isDark: isDark,
              suffixIcon: IconButton(
                icon: Icon(
                  _showConfirmPassword
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color:
                  isDark ? Colors.grey.shade500 : AppColors.greyMedium,
                  size: 20.sp,
                ),
                onPressed: () => setState(
                        () => _showConfirmPassword = !_showConfirmPassword),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'أكد كلمة المرور';
                }
                if (val != _passwordController.text) {
                  return 'كلمات المرور غير متطابقة';
                }
                return null;
              },
            ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.2),

            SizedBox(height: 16.h),

            _buildInputField(
              controller: _addressController,
              hint: 'العنوان',
              icon: Icons.location_on_rounded,
              isDark: isDark,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'أدخل العنوان';
                }
                return null;
              },
            ).animate().fadeIn(delay: 900.ms).slideX(begin: -0.2),

            SizedBox(height: 20.h),

            Row(
              children: [
                SizedBox(
                  width: 24.w,
                  height: 24.h,
                  child: Checkbox(
                    value: _acceptTerms,
                    onChanged: (val) =>
                        setState(() => _acceptTerms = val ?? false),
                    activeColor: AppColors.darkRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'أوافق على الشروط والأحكام وسياسة الخصوصية',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark
                          ? Colors.grey.shade400
                          : AppColors.greyDark,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 1000.ms),

            SizedBox(height: 28.h),

            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkRed,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
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
                    'إنشاء حساب',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 1100.ms)
                .scale(begin: const Offset(0.95, 0.95)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.9, 0.9));
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
        fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
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
        // ✅ إضافة focusedErrorBorder المفقود
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding:
        EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      ),
    );
  }

  Widget _buildPhoneInput(bool isDark) {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      maxLength: 9,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(9),
      ],
      onChanged: (value) {
        setState(() {
          _isPhoneValid =
              _validatePhone(value) == null && value.length == 9;
        });
      },
      validator: _validatePhone,
      style: TextStyle(
        color: isDark ? Colors.white : AppColors.black,
        fontSize: 14.sp,
        fontFamily: 'Cairo',
        letterSpacing: 1.2,
      ),
      decoration: InputDecoration(
        hintText: 'رقم الهاتف (9 أرقام)',
        hintStyle: TextStyle(
          color: isDark ? Colors.grey.shade600 : AppColors.greyMedium,
          fontSize: 13.sp,
          fontFamily: 'Cairo',
        ),
        helperText: 'يبدأ بـ 77، 78، 73 أو 71',
        helperStyle: TextStyle(
          fontSize: 11.sp,
          color: isDark ? Colors.grey.shade500 : AppColors.greyDark,
          fontFamily: 'Cairo',
        ),
        prefixIcon: Icon(
          Icons.phone_rounded,
          color: _isPhoneValid ? Colors.green : AppColors.darkRed,
          size: 20.sp,
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_phoneController.text.isNotEmpty)
              Icon(
                _isPhoneValid ? Icons.check_circle : Icons.error,
                color: _isPhoneValid ? Colors.green : Colors.red,
                size: 20.sp,
              ),
            SizedBox(width: 8.w),
            Container(
              padding:
              EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              margin: EdgeInsets.only(left: 8.w),
              decoration: BoxDecoration(
                color: AppColors.darkRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    countryCode,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkRed,
                      fontSize: 13.sp,
                      fontFamily: 'Cairo',
                    ),
                    textDirection: ui.TextDirection.ltr,
                  ),
                  SizedBox(width: 6.w),
                  Text(flagEmoji, style: TextStyle(fontSize: 18.sp)),
                ],
              ),
            ),
          ],
        ),
        counterText: '${_phoneController.text.length}/9',
        counterStyle: TextStyle(
          fontSize: 11.sp,
          color: _phoneController.text.length == 9
              ? Colors.green
              : Colors.grey,
          fontFamily: 'Cairo',
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(
            color: _isPhoneValid ? Colors.green : AppColors.darkRed,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        // ✅ إضافة focusedErrorBorder المفقود
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide:
          const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding:
        EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      ),
    );
  }

  Widget _buildLoginLink(bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 14.sp,
            color:
            isDark ? Colors.grey.shade400 : AppColors.greyDark,
            fontFamily: 'Cairo',
          ),
          children: const [
            TextSpan(text: 'لديك حساب؟ '),
            TextSpan(
              text: 'تسجيل الدخول',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkRed,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 1200.ms);
  }
}
