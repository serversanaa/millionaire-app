// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:millionaire_barber/core/services/password_service.dart';
// import 'package:millionaire_barber/core/themes/theme_provider.dart';
// import 'package:provider/provider.dart';
// import 'dart:ui' as ui;
//
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/routes/app_routes.dart';
// import '../../../profile/presentation/providers/user_provider.dart';
// import '../providers/settings_provider.dart';
// import 'privacy_policy_screen.dart';
// import 'terms_screen.dart';
//
// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({Key? key}) : super(key: key);
//
//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }
//
// class _SettingsScreenState extends State<SettingsScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadSettings();
//     });
//   }
//
//   Future<void> _loadSettings() async {
//     final userProvider = Provider.of<UserProvider>(context, listen: false);
//     final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
//     await settingsProvider.refresh(userId: userProvider.user?.id);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Directionality(
//       textDirection: ui.TextDirection.rtl,
//       child: Scaffold(
//         backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
//         appBar: _buildAppBar(isDark),
//         body: Consumer<SettingsProvider>(
//           builder: (context, settingsProvider, _) {
//             if (settingsProvider.isLoading) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             return _buildBody(isDark);
//           },
//         ),
//       ),
//     );
//   }
//
//   PreferredSizeWidget _buildAppBar(bool isDark) {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: AppColors.darkRed,
//       title: Text(
//         'الإعدادات',
//         style: TextStyle(
//           fontSize: 20.sp,
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//           fontFamily: 'Cairo',
//         ),
//       ),
//       centerTitle: true,
//       leading: IconButton(
//         icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp, color: Colors.white),
//         onPressed: () => Navigator.pop(context),
//       ),
//     );
//   }
//
//   Widget _buildBody(bool isDark) {
//     return ListView(
//       padding: EdgeInsets.symmetric(vertical: 16.h),
//       children: [
//         // قسم المظهر
//         _buildSectionHeader('المظهر', isDark),
//         _buildThemeSettings(isDark),
//
//         SizedBox(height: 24.h),
//
//         // قسم الإشعارات
//         _buildSectionHeader('الإشعارات', isDark),
//         _buildNotificationSettings(isDark),
//
//         SizedBox(height: 24.h),
//
//         // قسم الأمان والخصوصية
//         _buildSectionHeader('الأمان والخصوصية', isDark),
//         _buildSecuritySettings(isDark),
//
//         SizedBox(height: 24.h),
//
//         // قسم الحساب
//         _buildSectionHeader('الحساب', isDark),
//         _buildAccountSettings(isDark),
//
//         SizedBox(height: 24.h),
//
//         // قسم المعلومات
//         _buildSectionHeader('المعلومات', isDark),
//         _buildInformationSettings(isDark),
//
//         SizedBox(height: 24.h),
//
//         // قسم خطير
//         _buildDangerZone(isDark),
//
//         SizedBox(height: 40.h),
//       ],
//     );
//   }
//
//   Widget _buildSectionHeader(String title, bool isDark) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 14.sp,
//           fontWeight: FontWeight.bold,
//           color: AppColors.darkRed,
//           letterSpacing: 0.5,
//           fontFamily: 'Cairo',
//         ),
//       ),
//     ).animate().fadeIn(duration: 300.ms);
//   }
//
//   Widget _buildThemeSettings(bool isDark) {
//     return Consumer<ThemeProvider>(
//       builder: (context, themeProvider, _) {
//         return Container(
//           margin: EdgeInsets.symmetric(horizontal: 20.w),
//           decoration: BoxDecoration(
//             color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//             borderRadius: BorderRadius.circular(16.r),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha:0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: _buildSettingTile(
//             icon: Icons.brightness_6_rounded,
//             title: 'الوضع الداكن',
//             subtitle: themeProvider.isDarkMode ? 'مفعّل' : 'غير مفعّل',
//             isDark: isDark,
//             trailing: Switch(
//               value: themeProvider.isDarkMode,
//               onChanged: (value) async {
//                 await themeProvider.toggleTheme();
//                 if (mounted) {
//                   _showSuccessSnackBar(
//                     value ? '🌙 تم تفعيل الوضع الليلي' : '☀️ تم تفعيل الوضع الفاتح',
//                   );
//                 }
//               },
//               activeColor: AppColors.darkRed,
//             ),
//           ),
//         ).animate().fadeIn(delay: 100.ms, duration: 300.ms).slideY(begin: 0.1);
//       },
//     );
//   }
//
//   Widget _buildNotificationSettings(bool isDark) {
//     return Consumer<SettingsProvider>(
//       builder: (context, settingsProvider, _) {
//         return Container(
//           margin: EdgeInsets.symmetric(horizontal: 20.w),
//           decoration: BoxDecoration(
//             color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//             borderRadius: BorderRadius.circular(16.r),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha:0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               _buildSettingTile(
//                 icon: Icons.notifications_rounded,
//                 title: 'الإشعارات',
//                 subtitle: 'تلقي إشعارات التطبيق',
//                 isDark: isDark,
//                 trailing: Switch(
//                   value: settingsProvider.notificationsEnabled,
//                   onChanged: (value) async {
//                     final userProvider = Provider.of<UserProvider>(context, listen: false);
//                     await settingsProvider.toggleNotifications(
//                       value,
//                       userId: userProvider.user?.id,
//                     );
//                   },
//                   activeColor: AppColors.darkRed,
//                 ),
//               ),
//               if (settingsProvider.notificationsEnabled) ...[
//                 Divider(height: 1.h, indent: 70.w, endIndent: 20.w),
//                 _buildSettingTile(
//                   icon: Icons.email_rounded,
//                   title: 'إشعارات البريد',
//                   subtitle: 'تلقي إشعارات عبر البريد',
//                   isDark: isDark,
//                   trailing: Switch(
//                     value: settingsProvider.emailNotifications,
//                     onChanged: (value) async {
//                       final userProvider = Provider.of<UserProvider>(context, listen: false);
//                       await settingsProvider.toggleEmailNotifications(
//                         value,
//                         userId: userProvider.user?.id,
//                       );
//                     },
//                     activeColor: AppColors.darkRed,
//                   ),
//                 ),
//                 Divider(height: 1.h, indent: 70.w, endIndent: 20.w),
//                 _buildSettingTile(
//                   icon: Icons.sms_rounded,
//                   title: 'إشعارات الرسائل',
//                   subtitle: 'تلقي إشعارات عبر SMS',
//                   isDark: isDark,
//                   trailing: Switch(
//                     value: settingsProvider.smsNotifications,
//                     onChanged: (value) async {
//                       final userProvider = Provider.of<UserProvider>(context, listen: false);
//                       await settingsProvider.toggleSmsNotifications(
//                         value,
//                         userId: userProvider.user?.id,
//                       );
//                     },
//                     activeColor: AppColors.darkRed,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ).animate().fadeIn(delay: 200.ms, duration: 300.ms).slideY(begin: 0.1);
//       },
//     );
//   }
//
//   Widget _buildSecuritySettings(bool isDark) {
//     return Consumer<SettingsProvider>(
//       builder: (context, settingsProvider, _) {
//         return Container(
//           margin: EdgeInsets.symmetric(horizontal: 20.w),
//           decoration: BoxDecoration(
//             color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//             borderRadius: BorderRadius.circular(16.r),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha:0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               // ✅ البصمة البيومترية
//               if (settingsProvider.biometricAvailable)
//                 _buildSettingTile(
//                   icon: Icons.fingerprint_rounded,
//                   title: 'المصادقة البيومترية',
//                   subtitle: settingsProvider.biometricEnabled
//                       ? 'مفعّلة - استخدم البصمة لتسجيل الدخول'
//                       : 'غير مفعّلة',
//                   isDark: isDark,
//                   trailing: Switch(
//                     value: settingsProvider.biometricEnabled,
//                     onChanged: (value) async {
//                       final userProvider = Provider.of<UserProvider>(context, listen: false);
//                       final success = await settingsProvider.toggleBiometric(
//                         value,
//                         userId: userProvider.user?.id,
//                       );
//
//                       if (mounted) {
//                         if (success) {
//                           _showSuccessSnackBar(
//                             value
//                                 ? '✅ تم تفعيل المصادقة البيومترية'
//                                 : '❌ تم إلغاء المصادقة البيومترية',
//                           );
//                         } else {
//                           _showErrorSnackBar(
//                             settingsProvider.error ?? 'فشل تحديث الإعدادات',
//                           );
//                         }
//                       }
//                     },
//                     activeColor: AppColors.darkRed,
//                   ),
//                 ),
//
//               if (!settingsProvider.biometricAvailable)
//                 _buildSettingTile(
//                   icon: Icons.fingerprint_rounded,
//                   title: 'المصادقة البيومترية',
//                   subtitle: 'غير متاحة على هذا الجهاز',
//                   isDark: isDark,
//                   trailing: Icon(
//                     Icons.block,
//                     color: Colors.grey,
//                     size: 20.sp,
//                   ),
//                 ),
//
//               if (settingsProvider.biometricAvailable)
//                 Divider(height: 1.h, indent: 70.w, endIndent: 20.w),
//
//               _buildSettingTile(
//                 icon: Icons.lock_reset_rounded,
//                 title: 'تغيير كلمة المرور',
//                 subtitle: 'تحديث كلمة مرورك',
//                 isDark: isDark,
//                 trailing: Icon(
//                   Icons.arrow_forward_ios_rounded,
//                   size: 16.sp,
//                   color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
//                 ),
//                 onTap: () => _showChangePasswordDialog(isDark),
//               ),
//             ],
//           ),
//         ).animate().fadeIn(delay: 300.ms, duration: 300.ms).slideY(begin: 0.1);
//       },
//     );
//   }
//
//   Widget _buildAccountSettings(bool isDark) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 20.w),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha:0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           _buildSettingTile(
//             icon: Icons.person_rounded,
//             title: 'تعديل الملف الشخصي',
//             subtitle: 'تحديث بياناتك الشخصية',
//             isDark: isDark,
//             trailing: Icon(
//               Icons.arrow_forward_ios_rounded,
//               size: 16.sp,
//               color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
//             ),
//             onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
//           ),
//           Divider(height: 1.h, indent: 70.w, endIndent: 20.w),
//           _buildSettingTile(
//             icon: Icons.logout_rounded,
//             title: 'تسجيل الخروج',
//             subtitle: 'الخروج من حسابك',
//             isDark: isDark,
//             iconColor: Colors.orange,
//             trailing: Icon(
//               Icons.arrow_forward_ios_rounded,
//               size: 16.sp,
//               color: Colors.orange,
//             ),
//             onTap: () => _showLogoutDialog(isDark),
//           ),
//         ],
//       ),
//     ).animate().fadeIn(delay: 400.ms, duration: 300.ms).slideY(begin: 0.1);
//   }
//
//   Widget _buildInformationSettings(bool isDark) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 20.w),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha:0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           _buildSettingTile(
//             icon: Icons.info_outline_rounded,
//             title: 'عن التطبيق',
//             subtitle: 'الإصدار 1.0.0',
//             isDark: isDark,
//             trailing: Icon(
//               Icons.arrow_forward_ios_rounded,
//               size: 16.sp,
//               color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
//             ),
//             onTap: () => _showAboutDialog(isDark),
//           ),
//           Divider(height: 1.h, indent: 70.w, endIndent: 20.w),
//           _buildSettingTile(
//             icon: Icons.privacy_tip_rounded,
//             title: 'سياسة الخصوصية',
//             subtitle: 'اطلع على سياستنا',
//             isDark: isDark,
//             trailing: Icon(
//               Icons.arrow_forward_ios_rounded,
//               size: 16.sp,
//               color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
//             ),
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
//             ),
//           ),
//           Divider(height: 1.h, indent: 70.w, endIndent: 20.w),
//           _buildSettingTile(
//             icon: Icons.description_rounded,
//             title: 'الشروط والأحكام',
//             subtitle: 'اقرأ شروط الاستخدام',
//             isDark: isDark,
//             trailing: Icon(
//               Icons.arrow_forward_ios_rounded,
//               size: 16.sp,
//               color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
//             ),
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const TermsScreen()),
//             ),
//           ),
//         ],
//       ),
//     ).animate().fadeIn(delay: 500.ms, duration: 300.ms).slideY(begin: 0.1);
//   }
//
//   Widget _buildDangerZone(bool isDark) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 20.w),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(color: Colors.red.withValues(alpha:0.3)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.red.withValues(alpha:0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: _buildSettingTile(
//         icon: Icons.delete_forever_rounded,
//         title: 'حذف الحساب',
//         subtitle: 'حذف حسابك نهائياً',
//         isDark: isDark,
//         iconColor: Colors.red,
//         titleColor: Colors.red,
//         trailing: Icon(
//           Icons.arrow_forward_ios_rounded,
//           size: 16.sp,
//           color: Colors.red,
//         ),
//         onTap: () => _showDeleteAccountDialog(isDark),
//       ),
//     ).animate().fadeIn(delay: 600.ms, duration: 300.ms).slideY(begin: 0.1);
//   }
//
//   Widget _buildSettingTile({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required bool isDark,
//     Widget? trailing,
//     Color? iconColor,
//     Color? titleColor,
//     VoidCallback? onTap,
//   }) {
//     return ListTile(
//       contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
//       leading: Container(
//         padding: EdgeInsets.all(10.r),
//         decoration: BoxDecoration(
//           color: (iconColor ?? AppColors.darkRed).withValues(alpha:0.1),
//           borderRadius: BorderRadius.circular(12.r),
//         ),
//         child: Icon(
//           icon,
//           color: iconColor ?? AppColors.darkRed,
//           size: 24.sp,
//         ),
//       ),
//       title: Text(
//         title,
//         style: TextStyle(
//           fontSize: 15.sp,
//           fontWeight: FontWeight.w600,
//           color: titleColor ?? (isDark ? Colors.white : AppColors.black),
//           fontFamily: 'Cairo',
//         ),
//       ),
//       subtitle: Text(
//         subtitle,
//         style: TextStyle(
//           fontSize: 12.sp,
//           color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
//           fontFamily: 'Cairo',
//         ),
//       ),
//       trailing: trailing,
//       onTap: onTap,
//     );
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // DIALOGS
//   // ════════════════════════════════════════════════════════════════════════════
//
//   void _showChangePasswordDialog(bool isDark) {
//     final oldPasswordController = TextEditingController();
//     final newPasswordController = TextEditingController();
//     final confirmPasswordController = TextEditingController();
//     bool showOldPassword = false;
//     bool showNewPassword = false;
//     bool showConfirmPassword = false;
//
//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setState) => Directionality(
//           textDirection: ui.TextDirection.rtl,
//           child: AlertDialog(
//             backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
//             title: Text(
//               'تغيير كلمة المرور',
//               style: TextStyle(
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.bold,
//                 color: isDark ? Colors.white : AppColors.black,
//                 fontFamily: 'Cairo',
//               ),
//             ),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: oldPasswordController,
//                     obscureText: !showOldPassword,
//                     style: TextStyle(fontSize: 14.sp, fontFamily: 'Cairo'),
//                     decoration: InputDecoration(
//                       labelText: 'كلمة المرور الحالية',
//                       labelStyle: TextStyle(fontSize: 13.sp, fontFamily: 'Cairo'),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           showOldPassword ? Icons.visibility_off : Icons.visibility,
//                           size: 20.sp,
//                         ),
//                         onPressed: () => setState(() => showOldPassword = !showOldPassword),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16.h),
//                   TextField(
//                     controller: newPasswordController,
//                     obscureText: !showNewPassword,
//                     style: TextStyle(fontSize: 14.sp, fontFamily: 'Cairo'),
//                     decoration: InputDecoration(
//                       labelText: 'كلمة المرور الجديدة',
//                       labelStyle: TextStyle(fontSize: 13.sp, fontFamily: 'Cairo'),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           showNewPassword ? Icons.visibility_off : Icons.visibility,
//                           size: 20.sp,
//                         ),
//                         onPressed: () => setState(() => showNewPassword = !showNewPassword),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16.h),
//                   TextField(
//                     controller: confirmPasswordController,
//                     obscureText: !showConfirmPassword,
//                     style: TextStyle(fontSize: 14.sp, fontFamily: 'Cairo'),
//                     decoration: InputDecoration(
//                       labelText: 'تأكيد كلمة المرور',
//                       labelStyle: TextStyle(fontSize: 13.sp, fontFamily: 'Cairo'),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           showConfirmPassword ? Icons.visibility_off : Icons.visibility,
//                           size: 20.sp,
//                         ),
//                         onPressed: () => setState(() => showConfirmPassword = !showConfirmPassword),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text('إلغاء', style: TextStyle(fontSize: 14.sp, fontFamily: 'Cairo')),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   // TODO: Implement password change logic
//                   Navigator.pop(context);
//                   _showSuccessSnackBar('✅ تم تغيير كلمة المرور بنجاح');
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.darkRed,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//                 ),
//                 child: Text('تحديث', style: TextStyle(fontSize: 14.sp, fontFamily: 'Cairo')),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showLogoutDialog(bool isDark) {
//     showDialog(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: ui.TextDirection.rtl,
//         child: AlertDialog(
//           backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
//           title: Row(
//             children: [
//               Icon(Icons.logout_rounded, color: Colors.orange, size: 28.sp),
//               SizedBox(width: 12.w),
//               Text(
//                 'تسجيل الخروج',
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                   color: isDark ? Colors.white : AppColors.black,
//                   fontFamily: 'Cairo',
//                 ),
//               ),
//             ],
//           ),
//           content: Text(
//             'هل أنت متأكد من تسجيل الخروج؟',
//             style: TextStyle(
//               fontSize: 14.sp,
//               color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
//               fontFamily: 'Cairo',
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('إلغاء', style: TextStyle(fontSize: 14.sp, fontFamily: 'Cairo')),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.pop(context);
//                 final userProvider = Provider.of<UserProvider>(context, listen: false);
//                 await userProvider.logout();
//
//                 if (mounted) {
//                   Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.orange,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//               ),
//               child: Text('خروج', style: TextStyle(fontSize: 14.sp, fontFamily: 'Cairo')),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showDeleteAccountDialog(bool isDark) {
//     showDialog(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: ui.TextDirection.rtl,
//         child: AlertDialog(
//           backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
//           title: Row(
//             children: [
//               Icon(Icons.warning_rounded, color: Colors.red, size: 28.sp),
//               SizedBox(width: 12.w),
//               Text(
//                 'تحذير',
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.red,
//                   fontFamily: 'Cairo',
//                 ),
//               ),
//             ],
//           ),
//           content: Text(
//             'هل أنت متأكد من حذف حسابك؟ هذا الإجراء لا يمكن التراجع عنه.',
//             style: TextStyle(
//               fontSize: 14.sp,
//               color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
//               height: 1.5,
//               fontFamily: 'Cairo',
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('إلغاء', style: TextStyle(fontSize: 14.sp, fontFamily: 'Cairo')),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.pop(context);
//                 final userProvider = Provider.of<UserProvider>(context, listen: false);
//                 if (userProvider.user?.id != null) {
//                   await userProvider.deleteUser(userProvider.user!.id!);
//                   if (mounted) {
//                     Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
//                   }
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//               ),
//               child: Text('حذف', style: TextStyle(fontSize: 14.sp, fontFamily: 'Cairo')),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showAboutDialog(bool isDark) {
//     showDialog(
//       context: context,
//       barrierColor: Colors.black.withValues(alpha:0.7),
//       builder: (context) => Directionality(
//         textDirection: ui.TextDirection.rtl,
//         child: Dialog(
//           backgroundColor: Colors.transparent,
//           child: Container(
//             constraints: BoxConstraints(maxWidth: 350.w),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: isDark
//                     ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
//                     : [Colors.white, Colors.grey.shade50],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(24.r),
//               border: Border.all(
//                 color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
//                 width: 1.5,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha:0.3),
//                   blurRadius: 30,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // ✅ Header مع Gradient
//                 Container(
//                   width:double.infinity,
//                   padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [AppColors.darkRed, AppColors.darkRedDark],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(24.r),
//                       topRight: Radius.circular(24.r),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       // ✅ Logo Container مع تأثيرات
//                       Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           // Glow Effect
//                           Container(
//                             width: 110.w,
//                             height: 110.h,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               gradient: RadialGradient(
//                                 colors: [
//                                   Colors.white.withValues(alpha: 0.3),
//                                   Colors.white.withValues(alpha:0.1),
//                                   Colors.transparent,
//                                 ],
//                               ),
//                             ),
//                           ).animate(onPlay: (controller) => controller.repeat(reverse: true))
//                               .scale(duration: 2000.ms),
//
//                           // Logo Circle
//                           Container(
//                             width: 90.w,
//                             height: 90.h,
//                             padding: EdgeInsets.all(16.r),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               shape: BoxShape.circle,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withValues(alpha:0.2),
//                                   blurRadius: 15,
//                                   offset: const Offset(0, 5),
//                                 ),
//                               ],
//                             ),
//                             child: // بدلاً من Icon
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(45.r),
//                               child: Image.asset(
//                                 'assets/images/logo_hd.png',
//                                 width: 90.w,
//                                 height: 90.h,
//                                 fit: BoxFit.contain,
//                               ),
//                             ),
//
//                           ),
//                         ],
//                       ),
//
//                       SizedBox(height: 16.h),
//
//                       // ✅ App Name
//                       Text(
//                         'مركز المليونير',
//                         style: TextStyle(
//                           fontSize: 24.sp,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           fontFamily: 'Cairo',
//                           letterSpacing: 1.2,
//                         ),
//                       ),
//
//                       SizedBox(height: 4.h),
//
//                       // ✅ Tagline
//                       Container(
//                         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withValues(alpha:0.2),
//                           borderRadius: BorderRadius.circular(20.r),
//                         ),
//                         child: Text(
//                           'للحلاقة والعناية بالرجل',
//                           style: TextStyle(
//                             fontSize: 12.sp,
//                             color: Colors.white.withValues(alpha:0.95),
//                             fontFamily: 'Cairo',
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // ✅ Content
//                 Padding(
//                   padding: EdgeInsets.all(24.r),
//                   child: Column(
//                     children: [
//                       // Version Badge
//                       Container(
//                         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               AppColors.gold.withValues(alpha:0.2),
//                               AppColors.gold.withValues(alpha:0.1),
//                             ],
//                           ),
//                           borderRadius: BorderRadius.circular(20.r),
//                           border: Border.all(
//                             color: AppColors.gold.withValues(alpha:0.3),
//                             width: 1,
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               Icons.verified_rounded,
//                               color: AppColors.gold,
//                               size: 16.sp,
//                             ),
//                             SizedBox(width: 6.w),
//                             Text(
//                               'الإصدار 1.0.0',
//                               style: TextStyle(
//                                 fontSize: 13.sp,
//                                 color: isDark ? Colors.white : AppColors.black,
//                                 fontWeight: FontWeight.bold,
//                                 fontFamily: 'Cairo',
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       SizedBox(height: 20.h),
//
//                       // Description
//                       Text(
//                         'تطبيق حجز مواعيد صالون المليونير',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 15.sp,
//                           fontWeight: FontWeight.bold,
//                           color: isDark ? Colors.white : AppColors.black,
//                           fontFamily: 'Cairo',
//                         ),
//                       ),
//
//                       SizedBox(height: 8.h),
//
//                       Text(
//                         'تجربة حلاقة فاخرة ومريحة\nأفضل الخدمات بأيدي محترفين',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 13.sp,
//                           color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//                           height: 1.6,
//                           fontFamily: 'Cairo',
//                         ),
//                       ),
//
//                       SizedBox(height: 20.h),
//
//                       // Features
//                       _buildFeatureRow(
//                         icon: Icons.calendar_today_rounded,
//                         text: 'حجز سريع ومرن',
//                         isDark: isDark,
//                       ),
//                       SizedBox(height: 8.h),
//                       _buildFeatureRow(
//                         icon: Icons.card_giftcard_rounded,
//                         text: 'عروض وباقات حصرية',
//                         isDark: isDark,
//                       ),
//                       SizedBox(height: 8.h),
//                       _buildFeatureRow(
//                         icon: Icons.star_rounded,
//                         text: 'خدمات متميزة',
//                         isDark: isDark,
//                       ),
//
//                       SizedBox(height: 24.h),
//
//                       // Close Button
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () => Navigator.pop(context),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.darkRed,
//                             foregroundColor: Colors.white,
//                             padding: EdgeInsets.symmetric(vertical: 14.h),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12.r),
//                             ),
//                             elevation: 0,
//                           ),
//                           child: Text(
//                             'حسناً',
//                             style: TextStyle(
//                               fontSize: 16.sp,
//                               fontWeight: FontWeight.bold,
//                               fontFamily: 'Cairo',
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
//         ),
//       ),
//     );
//   }
//
// // ✅ Helper Widget
//   Widget _buildFeatureRow({
//     required IconData icon,
//     required String text,
//     required bool isDark,
//   }) {
//     return Row(
//       children: [
//         Container(
//           padding: EdgeInsets.all(6.r),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 AppColors.darkRed.withValues(alpha:0.2),
//                 AppColors.darkRed.withValues(alpha:0.1),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(8.r),
//           ),
//           child: Icon(
//             icon,
//             color: AppColors.darkRed,
//             size: 16.sp,
//           ),
//         ),
//         SizedBox(width: 10.w),
//         Text(
//           text,
//           style: TextStyle(
//             fontSize: 13.sp,
//             color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
//             fontFamily: 'Cairo',
//           ),
//         ),
//       ],
//     );
//   }
//
//
//
//
//
//   void _showErrorSnackBar(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.error_rounded, color: Colors.white, size: 20.sp),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: Text(message, style: TextStyle(fontSize: 14.sp, fontFamily: 'Cairo')),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//         margin: EdgeInsets.all(16.r),
//       ),
//     );
//   }
//
//   void _showSuccessSnackBar(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.check_circle_rounded, color: Colors.white, size: 20.sp),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: Text(message, style: TextStyle(fontSize: 14.sp, fontFamily: 'Cairo')),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//         margin: EdgeInsets.all(16.r),
//       ),
//     );
//   }
// }
//
//
//
//
// class _ChangePasswordDialog extends StatefulWidget {
//   final bool isDark;
//
//   const _ChangePasswordDialog({required this.isDark});
//
//   @override
//   State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
// }
//
// class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
//   late final TextEditingController currentPasswordController;
//   late final TextEditingController newPasswordController;
//   late final TextEditingController confirmPasswordController;
//
//   bool obscureCurrentPassword = true;
//   bool obscureNewPassword = true;
//   bool obscureConfirmPassword = true;
//
//   String strengthMessage = '';
//   Color strengthColor = Colors.grey;
//
//   @override
//   void initState() {
//     super.initState();
//     currentPasswordController = TextEditingController();
//     newPasswordController = TextEditingController();
//     confirmPasswordController = TextEditingController();
//   }
//
//   @override
//   void dispose() {
//     currentPasswordController.dispose();
//     newPasswordController.dispose();
//     confirmPasswordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       backgroundColor: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
//       title: Row(
//         children: [
//           Icon(Icons.lock_reset_rounded, color: AppColors.darkRed, size: 28.sp),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Text(
//               'تغيير كلمة المرور',
//               style: TextStyle(
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.bold,
//                 color: widget.isDark ? Colors.white : AppColors.black,
//               ),
//             ),
//           ),
//         ],
//       ),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // كلمة المرور الحالية
//             TextField(
//               controller: currentPasswordController,
//               obscureText: obscureCurrentPassword,
//               style: TextStyle(
//                 color: widget.isDark ? Colors.white : AppColors.black,
//                 fontSize: 14.sp,
//               ),
//               decoration: InputDecoration(
//                 labelText: 'كلمة المرور الحالية',
//                 labelStyle: TextStyle(
//                   color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//                   fontSize: 13.sp,
//                 ),
//                 prefixIcon: Icon(
//                   Icons.lock_outline_rounded,
//                   color: widget.isDark ? Colors.grey.shade500 : Colors.grey.shade600,
//                   size: 20.sp,
//                 ),
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     obscureCurrentPassword
//                         ? Icons.visibility_off_rounded
//                         : Icons.visibility_rounded,
//                     color: widget.isDark ? Colors.grey.shade500 : Colors.grey.shade600,
//                     size: 20.sp,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       obscureCurrentPassword = !obscureCurrentPassword;
//                     });
//                   },
//                 ),
//                 filled: true,
//                 fillColor: widget.isDark ? Colors.grey.shade900 : Colors.grey.shade100,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//
//             SizedBox(height: 16.h),
//
//             // كلمة المرور الجديدة
//             TextField(
//               controller: newPasswordController,
//               obscureText: obscureNewPassword,
//               style: TextStyle(
//                 color: widget.isDark ? Colors.white : AppColors.black,
//                 fontSize: 14.sp,
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   strengthMessage = PasswordService.getPasswordStrengthMessage(value);
//
//                   if (strengthMessage.contains('✓')) {
//                     strengthColor = Colors.green;
//                   } else if (value.isEmpty) {
//                     strengthColor = Colors.grey;
//                   } else {
//                     strengthColor = Colors.orange;
//                   }
//                 });
//               },
//               decoration: InputDecoration(
//                 labelText: 'كلمة المرور الجديدة',
//                 labelStyle: TextStyle(
//                   color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//                   fontSize: 13.sp,
//                 ),
//                 prefixIcon: Icon(
//                   Icons.lock_rounded,
//                   color: widget.isDark ? Colors.grey.shade500 : Colors.grey.shade600,
//                   size: 20.sp,
//                 ),
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     obscureNewPassword
//                         ? Icons.visibility_off_rounded
//                         : Icons.visibility_rounded,
//                     color: widget.isDark ? Colors.grey.shade500 : Colors.grey.shade600,
//                     size: 20.sp,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       obscureNewPassword = !obscureNewPassword;
//                     });
//                   },
//                 ),
//                 filled: true,
//                 fillColor: widget.isDark ? Colors.grey.shade900 : Colors.grey.shade100,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//
//             if (strengthMessage.isNotEmpty) ...[
//               SizedBox(height: 8.h),
//               Row(
//                 children: [
//                   Icon(
//                     strengthMessage.contains('✓')
//                         ? Icons.check_circle_rounded
//                         : Icons.info_rounded,
//                     color: strengthColor,
//                     size: 16.sp,
//                   ),
//                   SizedBox(width: 6.w),
//                   Expanded(
//                     child: Text(
//                       strengthMessage,
//                       style: TextStyle(
//                         fontSize: 11.sp,
//                         color: strengthColor,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//
//             SizedBox(height: 16.h),
//
//             // تأكيد كلمة المرور
//             TextField(
//               controller: confirmPasswordController,
//               obscureText: obscureConfirmPassword,
//               style: TextStyle(
//                 color: widget.isDark ? Colors.white : AppColors.black,
//                 fontSize: 14.sp,
//               ),
//               decoration: InputDecoration(
//                 labelText: 'تأكيد كلمة المرور',
//                 labelStyle: TextStyle(
//                   color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//                   fontSize: 13.sp,
//                 ),
//                 prefixIcon: Icon(
//                   Icons.lock_rounded,
//                   color: widget.isDark ? Colors.grey.shade500 : Colors.grey.shade600,
//                   size: 20.sp,
//                 ),
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     obscureConfirmPassword
//                         ? Icons.visibility_off_rounded
//                         : Icons.visibility_rounded,
//                     color: widget.isDark ? Colors.grey.shade500 : Colors.grey.shade600,
//                     size: 20.sp,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       obscureConfirmPassword = !obscureConfirmPassword;
//                     });
//                   },
//                 ),
//                 filled: true,
//                 fillColor: widget.isDark ? Colors.grey.shade900 : Colors.grey.shade100,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text(
//             'إلغاء',
//             style: TextStyle(
//               color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//               fontSize: 14.sp,
//             ),
//           ),
//         ),
//         ElevatedButton(
//           onPressed: () => _handleChangePassword(context),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.darkRed,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12.r),
//             ),
//             padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
//           ),
//           child: Text('تغيير', style: TextStyle(fontSize: 14.sp)),
//         ),
//       ],
//     );
//   }
//
//   Future<void> _handleChangePassword(BuildContext context) async {
//     // التحقق من الحقول
//     if (currentPasswordController.text.isEmpty) {
//       _showErrorSnackBar(context, 'الرجاء إدخال كلمة المرور الحالية');
//       return;
//     }
//
//     if (newPasswordController.text.isEmpty) {
//       _showErrorSnackBar(context, 'الرجاء إدخال كلمة المرور الجديدة');
//       return;
//     }
//
//     if (!PasswordService.isPasswordStrong(newPasswordController.text)) {
//       _showErrorSnackBar(context, 'كلمة المرور ضعيفة، الرجاء اتباع الإرشادات');
//       return;
//     }
//
//     if (newPasswordController.text != confirmPasswordController.text) {
//       _showErrorSnackBar(context, 'كلمة المرور غير متطابقة');
//       return;
//     }
//
//     // تغيير كلمة المرور
//     try {
//       final userProvider = Provider.of<UserProvider>(context, listen: false);
//
//       await userProvider.changePassword(
//         currentPassword: currentPasswordController.text,
//         newPassword: newPasswordController.text,
//       );
//
//       if (context.mounted) {
//         Navigator.pop(context);
//         _showSuccessSnackBar(context, '✅ تم تغيير كلمة المرور بنجاح');
//       }
//     } catch (e) {
//       if (context.mounted) {
//         _showErrorSnackBar(context, e.toString().replaceAll('Exception: ', ''));
//       }
//     }
//   }
//
//   void _showErrorSnackBar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.error_rounded, color: Colors.white, size: 20.sp),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: Text(message, style: TextStyle(fontSize: 14.sp)),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//         margin: EdgeInsets.all(16.r),
//       ),
//     );
//   }
//
//   void _showSuccessSnackBar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.check_circle_rounded, color: Colors.white, size: 20.sp),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: Text(message, style: TextStyle(fontSize: 14.sp)),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//         margin: EdgeInsets.all(16.r),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:millionaire_barber/core/services/password_service.dart';
import 'package:millionaire_barber/core/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../providers/settings_provider.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  Future<void> _loadSettings() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    // ✅ التأكد من التهيئة أولاً
    if (!settingsProvider.isInitialized) {
      await settingsProvider.initialize();
    }

    await settingsProvider.refresh(userId: userProvider.user?.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        appBar: _buildAppBar(isDark),
        body: Consumer<SettingsProvider>(
          builder: (context, settingsProvider, _) {
            // ✅ انتظار التهيئة أولاً
            if (!settingsProvider.isInitialized || settingsProvider.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.darkRed),
                    SizedBox(height: 16.h),
                    Text(
                      'جاري تحميل الإعدادات...',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              );
            }

            return _buildBody(isDark);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.darkRed,
      title: Text(
        'الإعدادات',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Cairo',
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            size: 20.sp, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      children: [
        _buildSectionHeader('المظهر', isDark),
        _buildThemeSettings(isDark),
        SizedBox(height: 24.h),
        _buildSectionHeader('الإشعارات', isDark),
        _buildNotificationSettings(isDark),
        SizedBox(height: 24.h),
        _buildSectionHeader('الأمان والخصوصية', isDark),
        _buildSecuritySettings(isDark),
        SizedBox(height: 24.h),
        _buildSectionHeader('الحساب', isDark),
        _buildAccountSettings(isDark),
        SizedBox(height: 24.h),
        _buildSectionHeader('المعلومات', isDark),
        _buildInformationSettings(isDark),
        SizedBox(height: 24.h),
        _buildDangerZone(isDark),
        SizedBox(height: 40.h),
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.darkRed,
          letterSpacing: 0.5,
          fontFamily: 'Cairo',
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildThemeSettings(bool isDark) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _buildSettingTile(
            icon: Icons.brightness_6_rounded,
            title: 'الوضع الداكن',
            subtitle: themeProvider.isDarkMode ? 'مفعّل' : 'غير مفعّل',
            isDark: isDark,
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) async {
                await themeProvider.toggleTheme();
                if (mounted) {
                  _showSuccessSnackBar(
                    value
                        ? '🌙 تم تفعيل الوضع الليلي'
                        : '☀️ تم تفعيل الوضع الفاتح',
                  );
                }
              },
              activeColor: AppColors.darkRed,
            ),
          ),
        ).animate().fadeIn(delay: 100.ms, duration: 300.ms).slideY(begin: 0.1);
      },
    );
  }

  Widget _buildNotificationSettings(bool isDark) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingTile(
                icon: Icons.notifications_rounded,
                title: 'الإشعارات',
                subtitle: 'تلقي إشعارات التطبيق',
                isDark: isDark,
                trailing: Switch(
                  value: settingsProvider.notificationsEnabled,
                  onChanged: (value) async {
                    final userProvider =
                        Provider.of<UserProvider>(context, listen: false);
                    await settingsProvider.toggleNotifications(
                      value,
                      userId: userProvider.user?.id,
                    );
                  },
                  activeColor: AppColors.darkRed,
                ),
              ),
              if (settingsProvider.notificationsEnabled) ...[
                Divider(height: 1.h, indent: 70.w, endIndent: 20.w),
                _buildSettingTile(
                  icon: Icons.email_rounded,
                  title: 'إشعارات البريد',
                  subtitle: 'تلقي إشعارات عبر البريد',
                  isDark: isDark,
                  trailing: Switch(
                    value: settingsProvider.emailNotifications,
                    onChanged: (value) async {
                      final userProvider =
                          Provider.of<UserProvider>(context, listen: false);
                      await settingsProvider.toggleEmailNotifications(
                        value,
                        userId: userProvider.user?.id,
                      );
                    },
                    activeColor: AppColors.darkRed,
                  ),
                ),
                Divider(height: 1.h, indent: 70.w, endIndent: 20.w),
                _buildSettingTile(
                  icon: Icons.sms_rounded,
                  title: 'إشعارات الرسائل',
                  subtitle: 'تلقي إشعارات عبر SMS',
                  isDark: isDark,
                  trailing: Switch(
                    value: settingsProvider.smsNotifications,
                    onChanged: (value) async {
                      final userProvider =
                          Provider.of<UserProvider>(context, listen: false);
                      await settingsProvider.toggleSmsNotifications(
                        value,
                        userId: userProvider.user?.id,
                      );
                    },
                    activeColor: AppColors.darkRed,
                  ),
                ),
              ],
            ],
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 300.ms).slideY(begin: 0.1);
      },
    );
  }

  Widget _buildSecuritySettings(bool isDark) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // ✅ البصمة البيومترية - متاحة
              if (settingsProvider.biometricAvailable)
                _buildSettingTile(
                  icon: Icons.fingerprint_rounded,
                  title: 'المصادقة البيومترية',
                  subtitle: settingsProvider.biometricEnabled
                      ? 'مفعّلة - استخدم البصمة لتسجيل الدخول'
                      : 'غير مفعّلة',
                  isDark: isDark,
                  trailing: Switch(
                    value: settingsProvider.biometricEnabled,
                    onChanged: (value) async {
                      final userProvider =
                          Provider.of<UserProvider>(context, listen: false);
                      final success = await settingsProvider.toggleBiometric(
                        value,
                        userId: userProvider.user?.id,
                      );

                      if (mounted) {
                        if (success) {
                          _showSuccessSnackBar(
                            value
                                ? '✅ تم تفعيل المصادقة البيومترية'
                                : '❌ تم إلغاء المصادقة البيومترية',
                          );
                        } else {
                          _showErrorSnackBar(
                            settingsProvider.error ?? 'فشل تحديث الإعدادات',
                          );
                        }
                      }
                    },
                    activeColor: AppColors.darkRed,
                  ),
                ),

              // ✅ البصمة البيومترية - غير متاحة
              if (!settingsProvider.biometricAvailable) ...[
                _buildSettingTile(
                  icon: Icons.fingerprint_rounded,
                  title: 'المصادقة البيومترية',
                  subtitle: 'غير متاحة - تأكد من تفعيل البصمة',
                  isDark: isDark,
                  trailing: Icon(
                    Icons.block,
                    color: Colors.grey,
                    size: 20.sp,
                  ),
                  onTap: () => _showBiometricInfoDialog(isDark),
                ),

                // ✅ زر إعادة الفحص
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await settingsProvider.recheckBiometric();
                        if (mounted) {
                          if (settingsProvider.biometricAvailable) {
                            _showSuccessSnackBar(
                                '✅ تم اكتشاف البيومترية بنجاح');
                          } else {
                            _showErrorSnackBar(
                                '❌ البيومترية غير متاحة على هذا الجهاز');
                          }
                        }
                      },
                      icon: Icon(Icons.refresh_rounded, size: 18.sp),
                      label: Text(
                        'إعادة فحص البيومترية',
                        style: TextStyle(fontSize: 13.sp, fontFamily: 'Cairo'),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkRed,
                        side: BorderSide(
                            color: AppColors.darkRed.withValues(alpha: 0.3)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              if (settingsProvider.biometricAvailable)
                Divider(height: 1.h, indent: 70.w, endIndent: 20.w),

              _buildSettingTile(
                icon: Icons.lock_reset_rounded,
                title: 'تغيير كلمة المرور',
                subtitle: 'تحديث كلمة مرورك',
                isDark: isDark,
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.sp,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
                onTap: () => _showChangePasswordDialog(isDark),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 300.ms).slideY(begin: 0.1);
      },
    );
  }

  Widget _buildAccountSettings(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.person_rounded,
            title: 'تعديل الملف الشخصي',
            subtitle: 'تحديث بياناتك الشخصية',
            isDark: isDark,
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.sp,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          Divider(height: 1.h, indent: 70.w, endIndent: 20.w),
          _buildSettingTile(
            icon: Icons.logout_rounded,
            title: 'تسجيل الخروج',
            subtitle: 'الخروج من حسابك',
            isDark: isDark,
            iconColor: Colors.orange,
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.sp,
              color: Colors.orange,
            ),
            onTap: () => _showLogoutDialog(isDark),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildInformationSettings(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.info_outline_rounded,
            title: 'عن التطبيق',
            subtitle: 'الإصدار 1.0.0',
            isDark: isDark,
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.sp,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            onTap: () => _showAboutDialog(isDark),
          ),
          Divider(height: 1.h, indent: 70.w, endIndent: 20.w),
          _buildSettingTile(
            icon: Icons.privacy_tip_rounded,
            title: 'سياسة الخصوصية',
            subtitle: 'اطلع على سياستنا',
            isDark: isDark,
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.sp,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            ),
          ),
          Divider(height: 1.h, indent: 70.w, endIndent: 20.w),
          _buildSettingTile(
            icon: Icons.description_rounded,
            title: 'الشروط والأحكام',
            subtitle: 'اقرأ شروط الاستخدام',
            isDark: isDark,
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.sp,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsScreen()),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildDangerZone(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildSettingTile(
        icon: Icons.delete_forever_rounded,
        title: 'حذف الحساب',
        subtitle: 'حذف حسابك نهائياً',
        isDark: isDark,
        iconColor: Colors.red,
        titleColor: Colors.red,
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16.sp,
          color: Colors.red,
        ),
        onTap: () => _showDeleteAccountDialog(isDark),
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    Widget? trailing,
    Color? iconColor,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      leading: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.darkRed).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.darkRed,
          size: 24.sp,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: titleColor ?? (isDark ? Colors.white : AppColors.black),
          fontFamily: 'Cairo',
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          fontFamily: 'Cairo',
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  // ✅ Dialog للبيومترية غير المتاحة
  void _showBiometricInfoDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(Icons.info_rounded, color: AppColors.darkRed, size: 28.sp),
              SizedBox(width: 12.w),
              Text(
                'المصادقة البيومترية',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.black,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          content: Text(
            'المصادقة البيومترية غير متاحة على هذا الجهاز.\n\n'
            'للتمكين:\n'
            '1. تأكد من دعم جهازك للبصمة أو Face ID\n'
            '2. فعّل البصمة من إعدادات الجهاز\n'
            '3. أضف بصمة واحدة على الأقل\n'
            '4. اضغط على "إعادة فحص البيومترية"',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              height: 1.5,
              fontFamily: 'Cairo',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'حسناً',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Cairo',
                  color: AppColors.darkRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => _ChangePasswordDialog(isDark: isDark),
    );
  }

  void _showLogoutDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.orange, size: 28.sp),
              SizedBox(width: 12.w),
              Text(
                'تسجيل الخروج',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.black,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          content: Text(
            'هل أنت متأكد من تسجيل الخروج؟',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              fontFamily: 'Cairo',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء',
                  style: TextStyle(fontSize: 14.sp, fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                await userProvider.logout();

                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.login, (route) => false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text('خروج',
                  style: TextStyle(fontSize: 14.sp, fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.red, size: 28.sp),
              SizedBox(width: 12.w),
              Text(
                'تحذير',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          content: Text(
            'هل أنت متأكد من حذف حسابك؟ هذا الإجراء لا يمكن التراجع عنه.',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              height: 1.5,
              fontFamily: 'Cairo',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء',
                  style: TextStyle(fontSize: 14.sp, fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                if (userProvider.user?.id != null) {
                  await userProvider.deleteUser(userProvider.user!.id!);
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, AppRoutes.login, (route) => false);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text('حذف',
                  style: TextStyle(fontSize: 14.sp, fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(bool isDark) {
    // استخدم الكود من الملف الأصلي
    // ...  (نفس الكود الموجود في paste.txt)
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_rounded, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(message,
                  style: TextStyle(fontSize: 14.sp, fontFamily: 'Cairo')),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.all(16.r),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(message,
                  style: TextStyle(fontSize: 14.sp, fontFamily: 'Cairo')),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.all(16.r),
      ),
    );
  }
}

// ✅ Dialog تغيير كلمة المرور (استخدم الكود من paste.txt)
class _ChangePasswordDialog extends StatefulWidget {
  final bool isDark;

  const _ChangePasswordDialog({required this.isDark});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  // ... (نفس الكود من paste.txt)
  late final TextEditingController currentPasswordController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  bool obscureCurrentPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  String strengthMessage = '';
  Color strengthColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // استخدم الكود من paste.txt...
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: AlertDialog(
          // ... (باقي الكود)
          ),
    );
  }

  Future<void> _handleChangePassword(BuildContext context) async {
    // استخدم الكود من paste.txt...
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    // استخدم الكود من paste.txt...
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    // استخدم الكود من paste.txt...
  }
}
