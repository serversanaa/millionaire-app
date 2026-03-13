import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:millionaire_barber/core/routes/app_routes.dart';
import 'package:millionaire_barber/features/profile/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/package_subscription_provider.dart';
import '../../domain/models/package_subscription_model.dart';

class MySubscriptionsScreen extends StatefulWidget {
  const MySubscriptionsScreen({Key? key}) : super(key: key);

  @override
  State<MySubscriptionsScreen> createState() => _MySubscriptionsScreenState();
}

class _MySubscriptionsScreenState extends State<MySubscriptionsScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryRed = Color(0xFFA62424);
  static const Color primaryGold = Color(0xFFB6862C);

  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PackageSubscriptionProvider>();
      final userProvider = context.read<UserProvider>();

      if (userProvider.user != null) {
        provider.setUserId(userProvider.user!.id.toString());
        provider.loadUserSubscriptions();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F7),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(isDark),
              _buildTabBar(isDark),
              Expanded(child: _buildTabContent(isDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: isDark ? Colors.white70 : Colors.black87,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'باقاتي',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  'إدارة اشتراكاتك',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? Colors.white60 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: primaryRed,
          borderRadius: BorderRadius.circular(10.r),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
        labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold,fontFamily:'Cairo'),
        unselectedLabelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500,fontFamily:'Cairo'),
        tabs: const [
          Tab(text: 'نشطة'),
          Tab(text: 'مُستخدمة'),
          Tab(text: 'منتهية'),
        ],
      ),
    );
  }

  Widget _buildTabContent(bool isDark) {
    return Consumer<PackageSubscriptionProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return _buildLoadingState(isDark);
        }

        if (provider.hasError) {
          return _buildErrorState(provider.error, isDark);
        }

        return TabBarView(
          controller: _tabController,
          children: [
            _buildSubscriptionsList(provider.activeSubscriptions, isDark, 'active'),
            _buildSubscriptionsList(provider.usedSubscriptions, isDark, 'used'),
            _buildSubscriptionsList(provider.expiredSubscriptions, isDark, 'expired'),
          ],
        );
      },
    );
  }

// ✅ الحل الصحيح
  Widget _buildSubscriptionsList(
      List<PackageSubscriptionModel> subscriptions,
      bool isDark,
      String type,
      ) {
    if (subscriptions.isEmpty) {
      return _buildEmptyState(type, isDark);  // ✅ type أولاً ثم isDark
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<PackageSubscriptionProvider>().loadUserSubscriptions();
      },
      color: primaryGold,
      child: ListView.builder(
        padding: EdgeInsets.all(20.r),
        itemCount: subscriptions.length,
        itemBuilder: (context, index) {
          return _buildSubscriptionCard(subscriptions[index], isDark, type);
        },
      ),
    );
  }


  // Empty State
// ✅ Empty State محسّن مع تأثيرات بصرية
  Widget _buildEmptyState(String type, bool isDark) {
    String title;
    String subtitle;
    IconData icon;
    Color iconColor;

    switch (type) {
      case 'active':
        title = 'لا توجد باقات نشطة';
        subtitle = 'اشترك في باقة جديدة للحصول على خصومات حصرية';
        icon = Icons.card_giftcard_rounded;
        iconColor = primaryGold;
        break;
      case 'used':
        title = 'لا توجد باقات مُستخدمة';
        subtitle = 'الباقات المُستخدمة ستظهر هنا';
        icon = Icons.check_circle_outline_rounded;
        iconColor = Colors.green.shade400;
        break;
      case 'expired':
        title = 'لا توجد باقات منتهية';
        subtitle = 'الباقات المنتهية ستظهر هنا';
        icon = Icons.history_rounded;
        iconColor = Colors.grey.shade400;
        break;
      default:
        title = 'لا توجد باقات';
        subtitle = '';
        icon = Icons.inbox_rounded;
        iconColor = Colors.grey.shade400;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ أيقونة مع Glow Effect
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    iconColor.withOpacity(0.2),
                    iconColor.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 70.sp,
                color: iconColor,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

            SizedBox(height: 24.h),

            // ✅ عنوان
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),

            SizedBox(height: 12.h),

            // ✅ وصف
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                  fontFamily: 'Cairo',
                  height: 1.5,
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),

            // ✅ زر استكشاف (فقط للباقات النشطة)
            if (type == 'active') ...[
              SizedBox(height: 32.h),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, AppRoutes.packages);
                  },
                  borderRadius: BorderRadius.circular(16.r),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primaryRed, Color(0xFF8B1A1A)],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: primaryRed.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.explore_rounded,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'تصفح الباقات',
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
              ).animate(delay: 300.ms).scale(),
            ],
          ],
        ),
      ),
    );
  }


// ✅ دالة Error State كاملة
  Widget _buildErrorState(String? error, bool isDark) {
    final errorType = _getErrorType(error);
    final icon = errorType['icon'] as IconData;
    final color = errorType['color'] as Color;
    final title = errorType['title'] as String;
    final message = errorType['message'] as String;
    final showSupport = errorType['showSupport'] as bool;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ أيقونة احترافية مع Glow
            Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60.sp,
                color: color,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

            SizedBox(height: 24.h),

            // ✅ عنوان واضح
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),

            SizedBox(height: 12.h),

            // ✅ وصف بسيط
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? Colors.white60 : Colors.grey.shade600,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),

            SizedBox(height: 32.h),

            // ✅ زر إعادة المحاولة
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.read<PackageSubscriptionProvider>().loadUserSubscriptions();
                },
                borderRadius: BorderRadius.circular(16.r),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryGold, Color(0xFFA67830)],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: primaryGold.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded, color: Colors.white, size: 22.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'إعادة المحاولة',
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
            ).animate(delay: 300.ms).scale(),

            // ✅ زر الدعم (اختياري)
            if (showSupport) ...[
              SizedBox(height: 16.h),
              TextButton.icon(
                onPressed: () => _contactSupport(),
                icon: Icon(Icons.support_agent_rounded, size: 18.sp),
                label: Text(
                  'تواصل مع الدعم',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: color,
                ),
              ).animate(delay: 400.ms).fadeIn(),
            ],
          ],
        ),
      ),
    );
  }

// ✅ دالة تحديد نوع الخطأ
  Map<String, dynamic> _getErrorType(String? error) {
    final errorLower = error?.toLowerCase() ?? '';

    if (errorLower.contains('socket') ||
        errorLower.contains('network') ||
        errorLower.contains('host lookup')) {
      return {
        'icon': Icons.wifi_off_rounded as IconData,
        'color': Colors.orange.shade400 as Color,
        'title': 'لا يوجد اتصال بالإنترنت' as String,
        'message': 'تأكد من اتصالك بالإنترنت وحاول مرة أخرى' as String,
        'showSupport': false as bool,
      };
    }

    if (errorLower.contains('500') || errorLower.contains('server')) {
      return {
        'icon': Icons.dns_outlined as IconData,
        'color': Colors.red.shade400 as Color,
        'title': 'مشكلة في الخادم' as String,
        'message': 'نواجه مشكلة مؤقتة، يرجى المحاولة لاحقاً' as String,
        'showSupport': true as bool,
      };
    }

    if (errorLower.contains('404') || errorLower.contains('not found')) {
      return {
        'icon': Icons.search_off_rounded as IconData,
        'color': Colors.blue.shade400 as Color,
        'title': 'لم نجد ما تبحث عنه' as String,
        'message': 'البيانات المطلوبة غير متوفرة حالياً' as String,
        'showSupport': false as bool,
      };
    }

    if (errorLower.contains('401') || errorLower.contains('unauthorized')) {
      return {
        'icon': Icons.lock_outline_rounded as IconData,
        'color': Colors.amber.shade600 as Color,
        'title': 'انتهت جلستك' as String,
        'message': 'يرجى تسجيل الدخول مرة أخرى' as String,
        'showSupport': false as bool,
      };
    }

    return {
      'icon': Icons.error_outline_rounded as IconData,
      'color': Colors.grey.shade500 as Color,
      'title': 'حدث خطأ غير متوقع' as String,
      'message': 'نعتذر عن الإزعاج، يرجى المحاولة مرة أخرى' as String,
      'showSupport': true as bool,
    };
  }

// ✅ دالة التواصل مع الدعم
  void _contactSupport() async {
    final url = Uri.parse('https://wa.me/967776684112');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ✅ Shimmer Animation
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer Ring
              Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      primaryGold.withOpacity(0.3),
                      primaryRed.withOpacity(0.3),
                    ],
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                  .rotate(duration: 2000.ms),

              // Inner Circle
              Container(
                width: 70.w,
                height: 70.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryGold),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          Text(
            'جاري التحميل...',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
              fontFamily: 'Cairo',
            ),
          ).animate(onPlay: (controller) => controller.repeat())
              .fadeIn(duration: 800.ms)
              .then()
              .fadeOut(duration: 800.ms),
        ],
      ),
    );
  }
  // ✅ دالة Empty State كاملة





  Widget _buildSubscriptionCard(
      PackageSubscriptionModel subscription,
      bool isDark,
      String type,
      ) {
    final package = subscription.package;
    if (package == null) return const SizedBox();

    final isActive = type == 'active';
    final isUsed = type == 'used';
    final isExpired = type == 'expired';

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: Stack(
        children: [
          // ✨ Glow Effect للباقات النشطة
          if (isActive)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: package.primaryColor.withOpacity(0.4),
                      blurRadius: 24,
                      spreadRadius: 4,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(
              duration: 2000.ms,
              color: package.primaryColor.withOpacity(0.3),
            ),

          // 🎴 البطاقة الرئيسية
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isUsed
                    ? [Colors.grey.shade400, Colors.grey.shade600]
                    : isExpired
                    ? [Colors.grey.shade300, Colors.grey.shade500]
                    : [
                  package.primaryColor,
                  package.secondaryColor,
                ],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(
                  decoration: BoxDecoration(
                    // ✨ Pattern overlay
                    image: DecorationImage(
                      image: const AssetImage('assets/images/pattern1.png'),
                      fit: BoxFit.cover,
                      opacity: 0.05,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showSubscriptionDetails(subscription, isDark),
                      borderRadius: BorderRadius.circular(24.r),
                      splashColor: Colors.white.withOpacity(0.1),
                      highlightColor: Colors.white.withOpacity(0.05),
                      child: Padding(
                        padding: EdgeInsets.all(24.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 📌 Header Row
                            Row(
                              children: [
                                // أيقونة الباقة
                                Container(
                                  padding: EdgeInsets.all(12.r),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(14.r),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.workspace_premium_rounded,
                                    color: Colors.white,
                                    size: 28.sp,
                                  ),
                                )
                                    .animate()
                                    .scale(
                                  duration: 600.ms,
                                  curve: Curves.elasticOut,
                                )
                                    .then()
                                    .shimmer(duration: 1500.ms),

                                SizedBox(width: 16.w),

                                // اسم الباقة
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        package.nameAr,
                                        style: TextStyle(
                                          fontSize: 22.sp,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(0.3),
                                              offset: const Offset(0, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4.r),
                                        ),
                                        child: Text(
                                          'ID: ${subscription.id}',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Badge الحالة
                                _buildAnimatedStatusBadge(subscription, type),
                              ],
                            ),

                            SizedBox(height: 24.h),

                            // 💰 قسم السعر
                            Container(
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.payments_rounded,
                                    color: Colors.white,
                                    size: 24.sp,
                                  ),
                                  SizedBox(width: 12.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'قيمة الباقة',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${subscription.price.toInt()}',
                                            style: TextStyle(
                                              fontSize: 32.sp,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                              height: 1,
                                            ),
                                          ),
                                          SizedBox(width: 6.w),
                                          Padding(
                                            padding: EdgeInsets.only(bottom: 4.h),
                                            child: Text(
                                              'ريال',
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                color: Colors.white.withOpacity(0.9),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                                .animate()
                                .slideX(
                              begin: -0.2,
                              duration: 400.ms,
                              curve: Curves.easeOut,
                            )
                                .fadeIn(),

                            SizedBox(height: 20.h),

                            // 📊 المعلومات السريعة
                            Row(
                              children: [
                                Expanded(
                                  child: _buildGlassInfoChip(
                                    icon: Icons.calendar_today_rounded,
                                    label: 'المدة المتبقية',
                                    value: subscription.isExpired
                                        ? 'منتهية'
                                        : '${subscription.daysRemaining} يوم',
                                    isActive: isActive,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: _buildGlassInfoChip(
                                    icon: Icons.confirmation_number_rounded,
                                    label: 'الجلسات',
                                    value: subscription.remainingSessions > 0
                                        ? '${subscription.remainingSessions}'
                                        : 'مُستخدمة',
                                    isActive: isActive,
                                  ),
                                ),
                              ],
                            )
                                .animate()
                                .slideY(
                              begin: 0.2,
                              duration: 500.ms,
                              curve: Curves.easeOut,
                            )
                                .fadeIn(),

                            SizedBox(height: 16.h),

                            // 🔥 Progress Bar (للباقات النشطة)
                            if (isActive && !subscription.isExpired)
                              _buildProgressBar(subscription),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
              .animate()
              .scale(
            begin: const Offset(0.95, 0.95),
            duration: 400.ms,
            curve: Curves.easeOut,
          )
              .fadeIn(duration: 300.ms),

          // ✨ شريط ضوئي متحرك (للباقات النشطة فقط)
          if (isActive)
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Container(
                height: 4.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.8),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .slideX(
                begin: -1,
                end: 1,
                duration: 2000.ms,
                curve: Curves.easeInOut,
              ),
            ),
        ],
      ),
    );
  }

// ═══════════════════════════════════════════════════════════════
// 🎯 Badge الحالة المتحرك
// ═══════════════════════════════════════════════════════════════

  Widget _buildAnimatedStatusBadge(PackageSubscriptionModel subscription, String type) {
    final data = type == 'active'
        ? ('نشطة', Colors.green, Icons.check_circle_rounded)
        : type == 'used'
        ? ('مُستخدمة', Colors.blue, Icons.done_all_rounded)
        : ('منتهية', Colors.orange, Icons.access_time_rounded);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: data.$2,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: data.$2.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.$3, size: 16.sp, color: Colors.white),
          SizedBox(width: 6.w),
          Text(
            data.$1,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3));
  }

// ═══════════════════════════════════════════════════════════════
// 🔮 Glass Info Chip
// ═══════════════════════════════════════════════════════════════

  Widget _buildGlassInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required bool isActive,
  }) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isActive ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: Colors.white),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

// ═══════════════════════════════════════════════════════════════
// 📊 Progress Bar
// ═══════════════════════════════════════════════════════════════

  Widget _buildProgressBar(PackageSubscriptionModel subscription) {
    final progress = subscription.usedSessions / subscription.totalSessions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الاستخدام',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: Stack(
            children: [
              // Background
              Container(
                height: 10.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              // Progress
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 10.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 2000.ms),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSubscriptionDetails(PackageSubscriptionModel subscription, bool isDark) {
    final package = subscription.package;
    if (package == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Package name
                    Text(
                      package.nameAr,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Status & Date Row
                    Row(
                      children: [
                        Icon(
                          subscription.statusIcon,
                          size: 16.sp,
                          color: subscription.statusColor,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          subscription.statusText,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: subscription.statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Icon(
                          Icons.access_time,
                          size: 16.sp,
                          color: isDark ? Colors.white60 : Colors.grey,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          subscription.isExpired
                              ? 'منتهية'
                              : 'ينتهي في ${subscription.daysRemaining} يوم',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark ? Colors.white60 : Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Price Info
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'السعر',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Text(
                                    '${subscription.price.toInt()}',
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                      color: primaryGold,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'ريال',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: isDark ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (subscription.hasDiscount)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'السعر الأصلي',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: isDark ? Colors.white60 : Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  '${subscription.originalPrice!.toInt()} ريال',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    decoration: TextDecoration.lineThrough,
                                    color: isDark ? Colors.white38 : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Services Section
                    Text(
                      'الخدمات المتضمنة',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Services List
                    ...package.services.map((service) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: primaryGold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.check_circle,
                                color: primaryGold,
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.nameAr,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    SizedBox(height: 24.h),

                    // Payment Info
                    Text(
                      'معلومات الدفع',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),

                    SizedBox(height: 12.h),

                    _buildInfoRow(
                      'طريقة الدفع',
                      subscription.paymentMethod ?? 'نقدي',
                      isDark,
                    ),
                    _buildInfoRow(
                      'حالة الدفع',
                      subscription.paymentStatusText,
                      isDark,
                    ),
                    _buildInfoRow(
                      'تاريخ الاشتراك',
                      '${subscription.startDate.day}/${subscription.startDate.month}/${subscription.startDate.year}',
                      isDark,
                    ),
                    _buildInfoRow(
                      'تاريخ الانتهاء',
                      '${subscription.endDate.day}/${subscription.endDate.month}/${subscription.endDate.year}',
                      isDark,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Helper method for info rows
  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.white60 : Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }


}
