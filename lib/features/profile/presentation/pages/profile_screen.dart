import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:millionaire_barber/features/appointments/presentation/pages/multi_booking_screen.dart';
import 'package:millionaire_barber/features/packages/presentation/pages/my_subscriptions_screen.dart';
import 'package:millionaire_barber/features/profile/domain/models/user_model.dart';
import 'package:millionaire_barber/features/profile/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui' as ui;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../appointments/presentation/pages/my_appointments_screen.dart';
import '../../../appointments/presentation/pages/appointment_history_screen.dart';
import '../../../favorites/presentation/pages/favorites_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user?.id != null) {
      // يمكن إضافة تحديث للبيانات هنا إذا لزم الأمر
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return _buildNotLoggedInState(isDark);
    }

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        body: CustomScrollView(
          slivers: [
            _buildAppBar(user, isDark),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  _buildProfileHeader(user, isDark),
                  SizedBox(height: 20.h),
                  _buildLoyaltyCard(user, isDark),
                  SizedBox(height: 20.h),
                  _buildStatsCards(user, isDark),
                  SizedBox(height: 20.h),
                  _buildMenuSection(isDark),
                  SizedBox(height: 20.h),
                  _buildSettingsButton(isDark),
                  SizedBox(height: 12.h),
                  _buildLogoutButton(isDark),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// NOT LOGGED IN STATE
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildNotLoggedInState(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_rounded,
              size: 80.sp,
              color: isDark ? Colors.grey.shade700 : AppColors.greyMedium,
            ).animate().scale(duration: 600.ms),
            SizedBox(height: 20.h),
            Text(
              'لم يتم تسجيل الدخول',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.black,
                fontFamily: 'Cairo',
              ),
            ).animate().fadeIn(delay: 200.ms),
            SizedBox(height: 8.h),
            Text(
              'يرجى تسجيل الدخول للوصول للملف الشخصي',
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? Colors.grey.shade500 : AppColors.greyDark,
                fontFamily: 'Cairo',
              ),
            ).animate().fadeIn(delay: 300.ms),
            SizedBox(height: 30.h),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkRed,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'تسجيل الدخول',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ).animate().fadeIn(delay: 400.ms).scale(),
          ],
        ),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// APP BAR
  /// ═══════════════════════════════════════════════════════════════

  // Widget _buildAppBar(UserModel user, bool isDark) {
  //   return SliverAppBar(
  //     expandedHeight: 120.h,
  //     floating: false,
  //     pinned: true,
  //     backgroundColor: AppColors.darkRed,
  //     leading: IconButton(
  //       icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.sp),
  //       onPressed: () => Navigator.pop(context),
  //     ),
  //     flexibleSpace: FlexibleSpaceBar(
  //       title: Text(
  //         'الملف الشخصي',
  //         style: TextStyle(
  //           color: Colors.white,
  //           fontSize: 18.sp,
  //           fontWeight: FontWeight.bold,
  //           fontFamily: 'Cairo',
  //         ),
  //       ),
  //       centerTitle: true,
  //       background: Container(
  //         decoration: const BoxDecoration(
  //           gradient: LinearGradient(
  //             colors: [AppColors.darkRed, AppColors.darkRedDark],
  //             begin: Alignment.topCenter,
  //             end: Alignment.bottomCenter,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }


  Widget _buildAppBar(UserModel user, bool isDark) {
    return SliverAppBar(
      expandedHeight: 140.h,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.darkRed,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 16.sp,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ).animate().fadeIn(delay: 200.ms).scale(),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'الملف الشخصي',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        centerTitle: true,
        background: Stack(
          children: [
            // Gradient Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.darkRed, AppColors.darkRedDark],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Animated Pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _HeaderPatternPainter(
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // Shimmer Effect
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                  .moveX(duration: 3000.ms, begin: -200, end: 200),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          width: 1.5,
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkRed.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with Glow
          Stack(
            children: [
              // Glow Effect
              Container(
                width: 96.r,
                height: 96.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.darkRed.withOpacity(0.3),
                      AppColors.darkRed.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(
                duration: 2000.ms,
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
              ),

              // Avatar Container
              Container(
                width: 90.r,
                height: 90.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.darkRed, AppColors.darkRedDark],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkRed.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(3.r),
                child: CircleAvatar(
                  radius: 43.r,
                  backgroundColor: Colors.white,
                  backgroundImage: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                      ? NetworkImage(user.profileImageUrl!)
                      : null,
                  child: user.profileImageUrl == null || user.profileImageUrl!.isEmpty
                      ? Icon(Icons.person, size: 45.sp, color: AppColors.darkRed)
                      : null,
                ),
              ),

              // Camera Button with Animation
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showImagePickerBottomSheet(user, isDark),
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.gold, AppColors.goldDark],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(Icons.camera_alt, size: 16.sp, color: Colors.white),
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                    .then(delay: 2000.ms)
                    .shimmer(duration: 1000.ms, color: Colors.white.withOpacity(0.5))
                    .shake(duration: 500.ms, hz: 2),
              ),
            ],
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

          SizedBox(width: 16.w),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.fullName ?? 'المستخدم',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.black,
                          fontFamily: 'Cairo',
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.vipStatus ?? false)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.gold, AppColors.goldDark],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.workspace_premium, size: 14.sp, color: Colors.white),
                            SizedBox(width: 4.w),
                            Text(
                              'VIP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ).animate(onPlay: (controller) => controller.repeat())
                          .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.email_rounded, size: 14.sp, color: AppColors.darkRed.withOpacity(0.7)),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        user.email ?? '',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                          fontFamily: 'Cairo',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(Icons.phone_rounded, size: 14.sp, color: AppColors.darkRed.withOpacity(0.7)),
                    SizedBox(width: 4.w),
                    Text(
                      user.phone ?? '',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ],
            ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.2),
          ),

          // Edit Button
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => _showEditProfileBottomSheet(user, isDark),
              icon: Icon(Icons.edit_rounded, color: AppColors.darkRed, size: 22.sp),
            ),
          ).animate().scale(delay: 400.ms),
        ],
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// LOYALTY CARD
  /// ═══════════════════════════════════════════════════════════════

  // Widget _buildLoyaltyCard(UserModel user, bool isDark) {
  //   final loyaltyPoints = user.loyaltyPoints ?? 0;
  //   final progress = (loyaltyPoints % 100) / 100;
  //
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 16.w),
  //     padding: EdgeInsets.all(20.r),
  //     decoration: BoxDecoration(
  //       gradient: const LinearGradient(
  //         colors: [AppColors.gold, AppColors.goldDark],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //       borderRadius: BorderRadius.circular(20.r),
  //       boxShadow: [
  //         BoxShadow(
  //           color: AppColors.gold.withOpacity(0.3),
  //           blurRadius: 15,
  //           offset: const Offset(0, 6),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Row(
  //               children: [
  //                 Icon(Icons.diamond, color: Colors.white, size: 30.sp),
  //                 SizedBox(width: 10.w),
  //                 Text(
  //                   'نقاط الولاء',
  //                   style: TextStyle(
  //                     fontSize: 18.sp,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.white,
  //                     fontFamily: 'Cairo',
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             Text(
  //               '$loyaltyPoints',
  //               style: TextStyle(
  //                 fontSize: 32.sp,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.white,
  //                 fontFamily: 'Cairo',
  //               ),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 15.h),
  //         Row(
  //           children: [
  //             Expanded(
  //               child: ClipRRect(
  //                 borderRadius: BorderRadius.circular(10.r),
  //                 child: LinearProgressIndicator(
  //                   value: progress,
  //                   minHeight: 8.h,
  //                   backgroundColor: Colors.white.withOpacity(0.3),
  //                   valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
  //                 ),
  //               ),
  //             ),
  //             SizedBox(width: 10.w),
  //             Text(
  //               '${(progress * 100).toInt()}%',
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 14.sp,
  //                 fontWeight: FontWeight.bold,
  //                 fontFamily: 'Cairo',
  //               ),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 8.h),
  //         Text(
  //           'أكمل ${100 - (loyaltyPoints % 100)} نقطة للوصول إلى المستوى التالي',
  //           style: TextStyle(
  //             fontSize: 12.sp,
  //             color: Colors.white.withOpacity(0.9),
  //             fontFamily: 'Cairo',
  //           ),
  //         ),
  //       ],
  //     ),
  //   ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  // }

  Widget _buildLoyaltyCard(UserModel user, bool isDark) {
    final loyaltyPoints = user.loyaltyPoints ?? 0;
    final progress = (loyaltyPoints % 100) / 100;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.3),
            blurRadius: 25,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            // Background Gradient
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFD700),
                    Color(0xFFFFA500),
                    Color(0xFFFF8C00),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.stars_rounded, color: Colors.white, size: 24.sp),
                              SizedBox(width: 8.w),
                              Text(
                                'نقاط الولاء',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.white, Color(0xFFFFF8DC)],
                            ).createShader(bounds),
                            child: Text(
                              '$loyaltyPoints',
                              style: TextStyle(
                                fontSize: 42.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                fontFamily: 'Cairo',
                                height: 1,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            'نقطة',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white.withOpacity(0.9),
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                        ),
                        child: Icon(Icons.card_giftcard_rounded, size: 32.sp, color: Colors.white),
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                          .scale(duration: 1500.ms, begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'التقدم للمكافأة التالية',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white.withOpacity(0.9),
                              fontFamily: 'Cairo',
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: Stack(
                          children: [
                            Container(
                              height: 12.h,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: progress,
                              child: Container(
                                height: 12.h,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.white, Color(0xFFFFF8DC)],
                                  ),
                                  borderRadius: BorderRadius.circular(10.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ).animate(onPlay: (controller) => controller.repeat())
                                  .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.5)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Animated Background Pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _LoyaltyPatternPainter(color: Colors.white.withOpacity(0.08)),
              ),
            ),

            // Shimmer Effect
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                  .moveX(duration: 3000.ms, begin: -300, end: 300),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2);
  }



  /// ═══════════════════════════════════════════════════════════════
  /// STATS CARDS
  /// ═══════════════════════════════════════════════════════════════

  // Widget _buildStatsCards(bool isDark) {
  //   final userProvider = Provider.of<UserProvider>(context);
  //   const totalAppointments = 12; // استبدل بالقيمة الفعلية
  //   const completedAppointments = 8; // استبدل بالقيمة الفعلية
  //
  //   return Padding(
  //     padding: EdgeInsets.symmetric(horizontal: 16.w),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: _buildStatCard(
  //             icon: Icons.calendar_today_rounded,
  //             title: 'المواعيد',
  //             value: '$totalAppointments',
  //             color: AppColors.darkRed,
  //             isDark: isDark,
  //           ),
  //         ),
  //         SizedBox(width: 12.w),
  //         Expanded(
  //           child: _buildStatCard(
  //             icon: Icons.check_circle_rounded,
  //             title: 'مكتمل',
  //             value: '$completedAppointments',
  //             color: Colors.green,
  //             isDark: isDark,
  //           ),
  //         ),
  //       ],
  //     ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
  //   );
  // }


  // Widget _buildStatCard({
  //   required IconData icon,
  //   required String title,
  //   required String value,
  //   required Color color,
  //   required bool isDark,
  // }) {
  //   return Container(
  //     padding: EdgeInsets.all(16.r),
  //     decoration: BoxDecoration(
  //       color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
  //       borderRadius: BorderRadius.circular(16.r),
  //       border: Border.all(
  //         color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
  //       ),
  //     ),
  //     child: Column(
  //       children: [
  //         Container(
  //           padding: EdgeInsets.all(10.r),
  //           decoration: BoxDecoration(
  //             color: color.withOpacity(0.1),
  //             shape: BoxShape.circle,
  //           ),
  //           child: Icon(icon, color: color, size: 24.sp),
  //         ),
  //         SizedBox(height: 8.h),
  //         Text(
  //           value,
  //           style: TextStyle(
  //             fontSize: 20.sp,
  //             fontWeight: FontWeight.bold,
  //             color: isDark ? Colors.white : AppColors.black,
  //             fontFamily: 'Cairo',
  //           ),
  //         ),
  //         SizedBox(height: 4.h),
  //         Text(
  //           title,
  //           style: TextStyle(
  //             fontSize: 12.sp,
  //             color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
  //             fontFamily: 'Cairo',
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

// ✅ حل بديل بدون تعديل UserModel:
  Widget _buildStatsCards(UserModel user, bool isDark) {
    return FutureBuilder<Map<String, int>>(
      future: _loadUserStats(user.id.toString()),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {'appointments': 0, 'packages': 0};

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.calendar_month_rounded,
                  title: 'الحجوزات',
                  value: '${stats['appointments']}',
                  color: AppColors.darkRed,
                  isDark: isDark,
                  index: 0,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.card_giftcard_rounded,
                  title: 'الباقات',
                  value: '${stats['packages']}',
                  color: AppColors.gold,
                  isDark: isDark,
                  index: 1,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.loyalty_rounded,
                  title: 'النقاط',
                  value: '${user.loyaltyPoints ?? 0}',
                  color: const Color(0xFF4CAF50),
                  isDark: isDark,
                  index: 2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// ✅ Function لجلب الإحصائيات:
  Future<Map<String, int>> _loadUserStats(String? userId) async {
    if (userId == null) return {'appointments': 0, 'packages': 0};

    try {
      // ✅ جلب عدد الحجوزات
      final appointmentsResponse = await Supabase.instance.client
          .from('appointments')
          .select()
          .eq('user_id', userId);

      // ✅ جلب عدد الباقات النشطة
      final packagesResponse = await Supabase.instance.client
          .from('package_subscriptions')
          .select()
          .eq('user_id', userId)
          .or('status.eq.active,status.eq.pending'); // حسب status عندك

      return {
        'appointments': (appointmentsResponse as List).length,
        'packages': (packagesResponse as List).length,
      };
    } catch (e) {
      debugPrint('Error loading stats: $e');
      return {'appointments': 0, 'packages': 0};
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDark,
    required int index,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(duration: 1500.ms, begin: const Offset(1, 1), end: const Offset(1.08, 1.08)),

          SizedBox(height: 12.h),

          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [color, color.withOpacity(0.7)],
            ).createShader(bounds),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontFamily: 'Cairo',
                height: 1,
              ),
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
              fontFamily: 'Cairo',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate(delay: (index * 100).ms).fadeIn().slideY(begin: 0.3);
  }


  /// ═══════════════════════════════════════════════════════════════
  /// QUICK ACTIONS
  /// ═══════════════════════════════════════════════════════════════

  // Widget _buildQuickActionsSection(bool isDark) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(horizontal: 16.w),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'إجراءات سريعة',
  //           style: TextStyle(
  //             fontSize: 16.sp,
  //             fontWeight: FontWeight.bold,
  //             color: isDark ? Colors.white : AppColors.black,
  //             fontFamily: 'Cairo',
  //           ),
  //         ),
  //         SizedBox(height: 12.h),
  //         Row(
  //           children: [
  //             Expanded(
  //               child: _buildQuickActionCard(
  //                 icon: Icons.add_circle_rounded,
  //                 label: 'حجز جديد',
  //                 color: AppColors.darkRed,
  //                 isDark: isDark,
  //                 onTap: () => Navigator.pushNamed(context, AppRoutes.services),
  //               ),
  //             ),
  //             SizedBox(width: 12.w),
  //             Expanded(
  //               child: _buildQuickActionCard(
  //                 icon: Icons.star_rounded,
  //                 label: 'النقاط',
  //                 color: AppColors.gold,
  //                 isDark: isDark,
  //                 onTap: () {
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     const SnackBar(content: Text('النقاط قريباً')),
  //                   );
  //                 },
  //               ),
  //             ),
  //             SizedBox(width: 12.w),
  //             Expanded(
  //               child: _buildQuickActionCard(
  //                 icon: Icons.card_giftcard_rounded,
  //                 label: 'العروض',
  //                 color: Colors.green,
  //                 isDark: isDark,
  //                 onTap: () {
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     const SnackBar(content: Text('العروض قريباً')),
  //                   );
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2);
  // }
  //
  // Widget _buildQuickActionCard({
  //   required IconData icon,
  //   required String label,
  //   required Color color,
  //   required bool isDark,
  //   required VoidCallback onTap,
  // }) {
  //   return InkWell(
  //     onTap: onTap,
  //     borderRadius: BorderRadius.circular(16.r),
  //     child: Container(
  //       padding: EdgeInsets.symmetric(vertical: 16.h),
  //       decoration: BoxDecoration(
  //         color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
  //         borderRadius: BorderRadius.circular(16.r),
  //         border: Border.all(
  //           color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
  //         ),
  //       ),
  //       child: Column(
  //         children: [
  //           Container(
  //             padding: EdgeInsets.all(12.r),
  //             decoration: BoxDecoration(
  //               color: color.withOpacity(0.1),
  //               shape: BoxShape.circle,
  //             ),
  //             child: Icon(icon, color: color, size: 24.sp),
  //           ),
  //           SizedBox(height: 8.h),
  //           Text(
  //             label,
  //             style: TextStyle(
  //               fontSize: 12.sp,
  //               fontWeight: FontWeight.w600,
  //               color: isDark ? Colors.white : AppColors.black,
  //               fontFamily: 'Cairo',
  //             ),
  //             textAlign: TextAlign.center,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }


  Widget _buildQuickActionItem({
    required IconData icon,
    required String title,
    required Color color,
    required bool isDark,
    required int index,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          // Handle action
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
                  : [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26.sp),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(duration: 1500.ms, begin: const Offset(1, 1), end: const Offset(1.05, 1.05)),

              SizedBox(height: 8.h),

              Text(
                title,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.black,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 80).ms).fadeIn().scale();
  }

  /// ═══════════════════════════════════════════════════════════════
  /// MENU SECTION
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildMenuSection(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.calendar_today_rounded,
            title: 'حجوزاتي الحالية',
            subtitle: 'عرض وإدارة الحجوزات',
            isDark: isDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MultiAppointmentScreen()),
            ),
          ),
          _buildMenuItem(
            icon: Icons.card_giftcard_rounded, // 🎁 أيقونة مناسبة للباقات
            title: 'باقاتي',
            subtitle: 'عرض وإدارة الباقات الخاصة بي',
            isDark: isDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MySubscriptionsScreen()),
            ),
          ),

          _buildDivider(isDark),
          _buildMenuItem(
            icon: Icons.history_rounded,
            title: 'سجل الحجوزات',
            subtitle: 'الحجوزات السابقة والمكتملة',
            isDark: isDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AppointmentHistoryScreen()),
            ),
          ),
          _buildDivider(isDark),
          _buildMenuItem(
            icon: Icons.favorite_rounded,
            title: 'المفضلة',
            subtitle: 'الخدمات المفضلة',
            isDark: isDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesScreen()),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2);
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: AppColors.darkRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: AppColors.darkRed, size: 24.sp),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.black,
          fontFamily: 'Cairo',
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: TextStyle(
          fontSize: 13.sp,
          color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
          fontFamily: 'Cairo',
        ),
      )
          : null,
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16.sp,
        color: isDark ? Colors.grey.shade600 : AppColors.greyMedium,
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1.h,
      thickness: 1,
      color: isDark ? Colors.grey.shade800 : AppColors.greyLight,
      indent: 70.w,
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// SETTINGS BUTTON
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildSettingsButton(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      width: double.infinity,
      height: 55.h,
      child:ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.settings);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          foregroundColor: isDark ? Colors.white : AppColors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
            side: BorderSide(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
            ),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings_rounded, color: AppColors.darkRed, size: 24.sp),
            SizedBox(width: 10.w),
            Text(
              'الإعدادات',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 950.ms).slideY(begin: 0.2);
  }

  /// ═══════════════════════════════════════════════════════════════
  /// LOGOUT BUTTON
  /// ═══════════════════════════════════════════════════════════════

  // Widget _buildLogoutButton(bool isDark) {
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 16.w),
  //     width: double.infinity,
  //     height: 55.h,
  //     child: ElevatedButton(
  //       onPressed: () => _showLogoutDialog(isDark),
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: AppColors.error,
  //         foregroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(15.r),
  //         ),
  //         elevation: 4,
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(Icons.logout_rounded, color: Colors.white, size: 24.sp),
  //           SizedBox(width: 10.w),
  //           Text(
  //             'تسجيل الخروج',
  //             style: TextStyle(
  //               fontSize: 16.sp,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.white,
  //               fontFamily: 'Cairo',
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   ).animate().fadeIn(delay: 1000.ms).scale();
  // }

  Widget _buildLogoutButton(bool isDark) {
    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: () => _showLogoutDialog(isDark),
          borderRadius: BorderRadius.circular(16.r),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF5350), Color(0xFFE53935)],
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: Colors.white, size: 22.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'تسجيل الخروج',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3);
  }

// Logout Dialog
  void _showLogoutDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.logout_rounded, color: Colors.red, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Text(
              'تسجيل الخروج',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                color: isDark ? Colors.white : AppColors.black,
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'Cairo',
            color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(
              'تسجيل الخروج',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.logout();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تسجيل الخروج'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// IMAGE PICKER BOTTOM SHEET
  /// ═══════════════════════════════════════════════════════════════

  void _showImagePickerBottomSheet(UserModel user, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.r),
            topRight: Radius.circular(25.r),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'تحديث الصورة الشخصية',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.black,
                  fontFamily: 'Cairo',
                ),
              ),
              SizedBox(height: 20.h),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, user);
                },
                leading: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.darkRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.camera_alt_rounded, color: AppColors.darkRed, size: 24.sp),
                ),
                title: Text(
                  'التقاط صورة',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.black,
                    fontFamily: 'Cairo',
                  ),
                ),
                subtitle: Text(
                  'استخدام الكاميرا',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                    fontFamily: 'Cairo',
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.sp,
                  color: isDark ? Colors.grey.shade600 : AppColors.greyMedium,
                ),
              ),
              Divider(height: 1.h),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, user);
                },
                leading: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.photo_library_rounded, color: AppColors.gold, size: 24.sp),
                ),
                title: Text(
                  'اختيار من المعرض',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.black,
                    fontFamily: 'Cairo',
                  ),
                ),
                subtitle: Text(
                  'اختر صورة موجودة',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                    fontFamily: 'Cairo',
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.sp,
                  color: isDark ? Colors.grey.shade600 : AppColors.greyMedium,
                ),
              ),
              if (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty) ...[
                Divider(height: 1.h),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    _removeProfileImage(user);
                  },
                  leading: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.delete_rounded, color: AppColors.error, size: 24.sp),
                  ),
                  title: Text(
                    'إزالة الصورة',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  subtitle: Text(
                    'حذف الصورة الحالية',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16.sp,
                    color: isDark ? Colors.grey.shade600 : AppColors.greyMedium,
                  ),
                ),
              ],
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ).animate().slideY(begin: 0.3, duration: 300.ms),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// PICK IMAGE
  /// ═══════════════════════════════════════════════════════════════

  Future<void> _pickImage(ImageSource source, UserModel user) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image == null) return;

      // Show loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E1E1E)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.darkRed),
                  SizedBox(height: 16.h),
                  Text(
                    'جارٍ رفع الصورة...',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.black,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // Upload image
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final success = await userProvider.uploadProfileImage(
        user.id!.toString(),
        image.path,
      );

      // Close loading
      if (mounted) Navigator.pop(context);

      // Show result
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ تم تحديث الصورة بنجاح'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('❌ فشل تحديث الصورة'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
        );
      }
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// REMOVE PROFILE IMAGE
  /// ═══════════════════════════════════════════════════════════════

  Future<void> _removeProfileImage(UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24.sp),
              SizedBox(width: 12.w),
              const Text('إزالة الصورة'),
            ],
          ),
          content: const Text('هل أنت متأكد من إزالة الصورة الشخصية؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: const Text('إزالة'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.updateUser(user.id!, {'profile_image_url': null});

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ تم إزالة الصورة بنجاح'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❌ فشل إزالة الصورة'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
      );
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// EDIT PROFILE BOTTOM SHEET
  /// ═══════════════════════════════════════════════════════════════

  void _showEditProfileBottomSheet(UserModel user, bool isDark) {
    final nameController = TextEditingController(text: user.fullName);
    final phoneController = TextEditingController(text: user.phone);
    final addressController = TextEditingController(text: user.address);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.r),
              topRight: Radius.circular(25.r),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Icon(Icons.edit_rounded, color: AppColors.darkRed, size: 24.sp),
                      SizedBox(width: 12.w),
                      Text(
                        'تعديل الملف الشخصي',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.black,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'الاسم الكامل',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.black,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: nameController,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.black,
                      fontSize: 14.sp,
                      fontFamily: 'Cairo',
                    ),
                    decoration: InputDecoration(
                      hintText: 'أدخل الاسم الكامل',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                        fontSize: 14.sp,
                        fontFamily: 'Cairo',
                      ),
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.darkRed,
                        size: 20.sp,
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: AppColors.darkRed, width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'رقم الهاتف',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.black,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: phoneController,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.black,
                      fontSize: 14.sp,
                      fontFamily: 'Cairo',
                    ),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'أدخل رقم الهاتف',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                        fontSize: 14.sp,
                        fontFamily: 'Cairo',
                      ),
                      prefixIcon: Icon(
                        Icons.phone_rounded,
                        color: AppColors.darkRed,
                        size: 20.sp,
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: AppColors.darkRed, width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'العنوان',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.black,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: addressController,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.black,
                      fontSize: 14.sp,
                      fontFamily: 'Cairo',
                    ),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'أدخل العنوان',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                        fontSize: 14.sp,
                        fontFamily: 'Cairo',
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 50.h),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: AppColors.darkRed,
                          size: 20.sp,
                        ),
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: AppColors.darkRed, width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            side: BorderSide(
                              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            'إلغاء',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            final userProvider = Provider.of<UserProvider>(context, listen: false);

                            final updates = {
                              'full_name': nameController.text.trim(),
                              'phone': phoneController.text.trim(),
                              'address': addressController.text.trim(),
                            };

                            final success = await userProvider.updateUser(user.id!, updates);

                            if (success && mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('✅ تم تحديث البيانات بنجاح'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                              );
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('❌ فشل تحديث البيانات'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkRed,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            'حفظ التغييرات',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ).animate().slideY(begin: 0.3, duration: 300.ms),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// LOGOUT DIALOG
  /// ═══════════════════════════════════════════════════════════════

  // void _showLogoutDialog(bool isDark) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => Directionality(
  //       textDirection: ui.TextDirection.rtl,
  //       child: AlertDialog(
  //         backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
  //         title: Row(
  //           children: [
  //             Container(
  //               padding: EdgeInsets.all(8.r),
  //               decoration: BoxDecoration(
  //                 color: AppColors.error.withOpacity(0.1),
  //                 shape: BoxShape.circle,
  //               ),
  //               child: Icon(Icons.logout_rounded, color: AppColors.error, size: 24.sp),
  //             ),
  //             SizedBox(width: 12.w),
  //             Text(
  //               'تسجيل الخروج',
  //               style: TextStyle(
  //                 color: isDark ? Colors.white : AppColors.black,
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 18.sp,
  //                 fontFamily: 'Cairo',
  //               ),
  //             ),
  //           ],
  //         ),
  //         content: Text(
  //           'هل أنت متأكد من تسجيل الخروج من التطبيق؟',
  //           style: TextStyle(
  //             color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
  //             fontSize: 14.sp,
  //             fontFamily: 'Cairo',
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: Text(
  //               'إلغاء',
  //               style: TextStyle(
  //                 color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
  //                 fontSize: 14.sp,
  //                 fontFamily: 'Cairo',
  //               ),
  //             ),
  //           ),
  //           ElevatedButton(
  //             onPressed: () async {
  //               final userProvider = Provider.of<UserProvider>(context, listen: false);
  //               await userProvider.logout();
  //
  //               if (mounted) {
  //                 Navigator.pop(context);
  //                 Navigator.pushNamedAndRemoveUntil(
  //                   context,
  //                   AppRoutes.login,
  //                       (route) => false,
  //                 );
  //               }
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: AppColors.error,
  //               foregroundColor: Colors.white,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(10.r),
  //               ),
  //             ),
  //             child: Text(
  //               'تسجيل الخروج',
  //               style: TextStyle(
  //                 fontSize: 14.sp,
  //                 fontFamily: 'Cairo',
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

}




// Pattern Painter
class _HeaderPatternPainter extends CustomPainter {
  final Color color;

  _HeaderPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double x = -20; x < size.width + 20; x += 30) {
      for (double y = -20; y < size.height + 20; y += 30) {
        canvas.drawCircle(Offset(x, y), 3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


// Loyalty Pattern Painter
class _LoyaltyPatternPainter extends CustomPainter {
  final Color color;

  _LoyaltyPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += 40) {
      for (double y = 0; y < size.height; y += 40) {
        canvas.drawCircle(Offset(x, y), 4, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}