import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:freestyle_speed_dial/freestyle_speed_dial.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:millionaire_barber/core/models/search_result_model.dart';
import 'package:millionaire_barber/features/appointments/domain/models/appointment_model.dart';
import 'package:millionaire_barber/features/appointments/presentation/pages/multi_booking_screen.dart';
import 'package:millionaire_barber/features/home/presentation/providers/banner_provider.dart';
import 'package:millionaire_barber/features/home/presentation/widgets/home_banner_slider.dart';
import 'package:millionaire_barber/features/home/presentation/widgets/shimmer_painter.dart';
import 'package:millionaire_barber/features/packages/domain/models/package_model.dart';
import 'package:millionaire_barber/features/packages/presentation/providers/packages_provider.dart';
import 'package:millionaire_barber/features/products/presentation/providers/cart_provider.dart';
import 'package:millionaire_barber/features/products/presentation/providers/order_provider.dart';
import 'package:millionaire_barber/features/products/presentation/providers/product_provider.dart';
import 'package:millionaire_barber/features/products/presentation/screens/cart_screen.dart';
import 'package:millionaire_barber/features/products/presentation/screens/orders_list_screen.dart';
import 'package:millionaire_barber/features/products/presentation/screens/products_screen.dart';
import 'package:millionaire_barber/features/support/presentation/pages/contact_us_screen.dart';
import 'package:millionaire_barber/features/support/presentation/pages/faq_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../../../services/domain/models/service_model.dart';
import '../../../offers/presentation/providers/offer_provider.dart';
import '../../../appointments/presentation/providers/appointment_provider.dart';
import '../../../appointments/presentation/pages/appointment_details_screen.dart';
import '../../../appointments/presentation/pages/my_appointments_screen.dart';
import '../../../services/presentation/pages/service_detail_screen.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../favorites/presentation/providers/favorite_provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ إضافة

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;
  bool _isInitialized = false;
  bool _isLoading = true; // ✅ إضافة

  // ✅ احفظ references للـ providers
  UserProvider? _userProvider;
  ServicesProvider? _servicesProvider;
  AppointmentProvider? _appointmentProvider;
  NotificationProvider? _notificationProvider;
  OfferProvider? _offerProvider;
  FavoriteProvider? _favoriteProvider;
  PackagesProvider? _packagesProvider; // ✅ إضافة
  final ScrollController _packagesScrollController =
      ScrollController(); // ✅ جديد
  Timer? _autoScrollTimer; // ✅ جديد
  int _currentPackageIndex = 0; // ✅ جديد
  String _appVersion = '';

  // ✅ متغير جديد للتحكم في Shimmer
  bool _showShimmer = false;
  bool _isFirstLoad = true; // ✅ للتحقق من أول تحميل
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _loadAppVersion();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _loadNotificationCount();
      _initializeRealtimeSubscriptions();
      _startPackagesAutoScroll();
      _checkFirstLoad();

      final userId = _userProvider!.user?.id;
      if (userId != null) {
        listenToUserLoyaltyPointsUpdates(userId);
      }

      // ✅ أضف هذين السطرين فقط — Pre-cache لتسريع فتح شاشة الحجز
      final svc = context.read<ServicesProvider>();
      if (svc.categories.isEmpty) svc.fetchCategories();
      if (svc.services.isEmpty) svc.fetchServices();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }


  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = '${info.version}+${info.buildNumber}';
      });
    }
  }


  // ═══════════════════════════════════════════════════════════
  // ✅ التحقق من أول تحميل
  // ═══════════════════════════════════════════════════════════
  Future<void> _checkFirstLoad() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasLoadedBefore = prefs.getBool('home_screen_loaded') ?? false;

      setState(() {
        _isFirstLoad = !hasLoadedBefore;
        _showShimmer = !hasLoadedBefore;
      });

      if (_isFirstLoad) {
        // ✅ حفظ أنه تم التحميل لأول مرة
        await prefs.setBool('home_screen_loaded', true);
      }

      await _initializeData();
    } catch (e) {
      debugPrint('❌ Error checking first load: $e');
      await _initializeData();
    }
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    // ✅ اظهر Shimmer فقط في أول مرة
    if (_isFirstLoad) {
      setState(() => _isLoading = true);
    }
    try {
      await _loadData();
      await _loadNotificationCount();
      _initializeRealtimeSubscriptions();
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ✅ احفظ الـ providers هنا
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_userProvider == null) {
      _userProvider = Provider.of<UserProvider>(context, listen: false);
      _servicesProvider = Provider.of<ServicesProvider>(context, listen: false);
      _appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      _notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      _offerProvider = Provider.of<OfferProvider>(context, listen: false);
      _favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
      _packagesProvider =
          Provider.of<PackagesProvider>(context, listen: false); // ✅ إضافة
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  Future<void> _loadNotificationCount() async {
    final userProvider =
        _userProvider ?? Provider.of<UserProvider>(context, listen: false);
    final notificationProvider = _notificationProvider ??
        Provider.of<NotificationProvider>(context, listen: false);

    if (userProvider.user?.id != null) {
      await notificationProvider.fetchUnreadCount(userProvider.user!.id!);
    }
  }

  // Future<void> _loadData() async {
  //   final userProvider =
  //       _userProvider ?? Provider.of<UserProvider>(context, listen: false);
  //   final servicesProvider = _servicesProvider ??
  //       Provider.of<ServicesProvider>(context, listen: false);
  //   final appointmentProvider = _appointmentProvider ??
  //       Provider.of<AppointmentProvider>(context, listen: false);
  //   final offerProvider =
  //       _offerProvider ?? Provider.of<OfferProvider>(context, listen: false);
  //   final notificationProvider = _notificationProvider ??
  //       Provider.of<NotificationProvider>(context, listen: false);
  //   final packagesProvider = _packagesProvider ??
  //       Provider.of<PackagesProvider>(context, listen: false);
  //   await Future.wait([
  //     servicesProvider.fetchCategories(),
  //     servicesProvider.fetchServices(),
  //     offerProvider.fetchActiveOffers(),
  //     packagesProvider.loadActivePackages(),
  //     if (userProvider.user != null) ...[
  //       appointmentProvider.fetchUserAppointments(userProvider.user!.id!),
  //       notificationProvider.fetchUnreadCount(userProvider.user!.id!),
  //     ],
  //   ]);
  // }


  Future<void> _loadData() async {
    final userProvider =
        _userProvider ?? Provider.of<UserProvider>(context, listen: false);
    final servicesProvider = _servicesProvider ??
        Provider.of<ServicesProvider>(context, listen: false);
    final appointmentProvider = _appointmentProvider ??
        Provider.of<AppointmentProvider>(context, listen: false);
    final offerProvider =
        _offerProvider ?? Provider.of<OfferProvider>(context, listen: false);
    final notificationProvider = _notificationProvider ??
        Provider.of<NotificationProvider>(context, listen: false);
    final packagesProvider = _packagesProvider ??
        Provider.of<PackagesProvider>(context, listen: false);
    final bannerProvider = Provider.of<BannerProvider>(context, listen: false); // ✅ جديد

    await Future.wait([
      servicesProvider.fetchCategories(),
      servicesProvider.fetchServices(),
      offerProvider.fetchActiveOffers(),
      packagesProvider.loadActivePackages(),
      bannerProvider.fetchBanners(), // ✅ جديد
      if (userProvider.user != null) ...[
        appointmentProvider.fetchUserAppointments(userProvider.user!.id!),
        notificationProvider.fetchUnreadCount(userProvider.user!.id!),
      ],
    ]);
  }

  void _initializeRealtimeSubscriptions() {
    if (_isInitialized) return;

    final userId = _userProvider?.user?.id;

    if (userId == null) {
      return;
    }

    _userProvider?.subscribeToUserChanges(userId);
    _servicesProvider?.subscribeToServicesChanges();
    _servicesProvider?.subscribeToCategories();
    _appointmentProvider?.subscribeToUserAppointments(userId);
    _notificationProvider?.subscribeToUserNotifications(userId);
    _offerProvider?.subscribeToActiveOffers();
    _favoriteProvider?.subscribeToUserFavorites(userId);
    _packagesProvider?.initializeRealtime(); // ✅ إضافة

    _isInitialized = true;
  }

  // ✅ إلغاء الاشتراكات بدون استخدام context
  void _cancelAllSubscriptions() {
    if (!_isInitialized) return;

    try {
      _userProvider?.unsubscribeFromUserChanges();
      _servicesProvider?.unsubscribeFromServices();
      _servicesProvider?.unsubscribeFromCategories();
      _appointmentProvider?.unsubscribeFromAppointments();
      _notificationProvider?.unsubscribeFromNotifications();
      _offerProvider?.unsubscribeFromOffers();
      _favoriteProvider?.unsubscribeFromFavorites();

      _isInitialized = false;
    } catch (e) {}
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_showAppBarTitle) {
      setState(() => _showAppBarTitle = true);
    } else if (_scrollController.offset <= 100 && _showAppBarTitle) {
      setState(() => _showAppBarTitle = false);
    }
  }

  // ✅ دالة التمرير التلقائي
  void _startPackagesAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || !_packagesScrollController.hasClients) return;

      final packagesProvider = context.read<PackagesProvider>();
      if (packagesProvider.packages.isEmpty) return;

      _currentPackageIndex =
          (_currentPackageIndex + 1) % packagesProvider.packages.length;

      final targetPosition = _currentPackageIndex * (240.w + 14.w);

      _packagesScrollController.animateTo(
        targetPosition,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void listenToUserUpdates(int? userId) {
    if (userId == null) return;

    final channel = Supabase.instance.client.channel('users-updates-$userId')
      ..onPostgresChanges(
        event: PostgresChangeEvent.update, // استخدم النوع الصحيح
        schema: 'public',
        table: 'users',
        filter: PostgresChangeFilter(
          // استعمل PostgresChangeFilter
          type: PostgresChangeFilterType.eq,
          column: 'id',
          value: userId,
        ),
        callback: (payload) {
          final updatedUser = payload.newRecord;
          if (updatedUser.isNotEmpty) {
            _userProvider?.updateUserFromRealtime(updatedUser);
          }
        },
      )
      ..subscribe();
  }

  void listenToUserLoyaltyPointsUpdates(int userId) {
    final channel = Supabase.instance.client.channel('user-loyalty-$userId');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.update, // الحدث المناسب - تغيير بالسطر
      schema: 'public',
      table: 'users',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: userId,
      ),
      callback: (payload) {
        // السجل الجديد من الداتا بيز
        final updatedUser = payload.newRecord;
        if (updatedUser != null) {
          // يجب تعديل هذا ليناسب UserProvider عندك
          _userProvider
              ?.updateUserFromRealtime(updatedUser as Map<String, dynamic>);
        }
      },
    );

    channel.subscribe();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _packagesScrollController.dispose();
    _autoScrollTimer?.cancel();
    _shimmerController.dispose();
    _cancelAllSubscriptions();
    super.dispose();
  }

  String _formatTime(String time24) {
    try {
      final parts = time24.split(':');
      int hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? parts[1] : '00';

      if (hour == 0) {
        return '12:$minute ص';
      } else if (hour < 12) {
        return '$hour:$minute ص';
      } else if (hour == 12) {
        return '12:$minute م';
      } else {
        return '${hour - 12}:$minute م';
      }
    } catch (e) {
      return time24;
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 0 && hour < 5) {
      return 'ليلة سعيدة 🌃';
    } else if (hour >= 5 && hour < 12) {
      return 'صباح الخير ☀️';
    } else if (hour >= 12 && hour < 17) {
      return 'مساء الخير 🌤️';
    } else if (hour >= 17 && hour < 21) {
      return 'مساء الخير 🌇';
    } else {
      return 'مساء الخير 🌙';
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
        extendBodyBehindAppBar: true,
        drawer: _buildDrawer(isDark),
        body: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.darkRed,
          child: _showShimmer && _isLoading
              ? _buildShimmerLoading(isDark)
              : CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildSliverAppBar(isDark),
              // ✅ البنر
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 20.h, bottom: 4.h),
                  child: const HomeBannerSlider(),
                ),
              ),
              SliverToBoxAdapter(child: _buildQuickActions(isDark)),
              SliverToBoxAdapter(child: _buildPackages(isDark)),
              SliverToBoxAdapter(child: _buildUpcomingAppointments(isDark)),
              SliverToBoxAdapter(child: _buildCategories(isDark)),
              SliverToBoxAdapter(child: _buildOffers(isDark)),
              SliverToBoxAdapter(child: _buildPopularServices(isDark)),
              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: buildFloatingBookButton(isDark),
      ),
    );

    // return Directionality(
    //   textDirection: ui.TextDirection.rtl,
    //   child: Scaffold(
    //     backgroundColor:
    //         isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
    //     extendBodyBehindAppBar: true,
    //     drawer: _buildDrawer(isDark),
    //     body: RefreshIndicator(
    //       onRefresh: _loadData,
    //       color: AppColors.darkRed,
    //       child: _showShimmer && _isLoading
    //           ? _buildShimmerLoading(isDark)
    //           : CustomScrollView(
    //               controller: _scrollController,
    //               slivers: [
    //                 _buildSliverAppBar(isDark),
    //                 SliverToBoxAdapter(child: _buildQuickActions(isDark)),
    //                 SliverToBoxAdapter(
    //                     child: _buildPackages(isDark)),
    //                 SliverToBoxAdapter(
    //                     child: _buildUpcomingAppointments(isDark)),
    //                 SliverToBoxAdapter(child: _buildCategories(isDark)),
    //                 SliverToBoxAdapter(child: _buildOffers(isDark)),
    //                 SliverToBoxAdapter(child: _buildPopularServices(isDark)),
    //                 SliverToBoxAdapter(child: SizedBox(height: 100.h)),
    //               ],
    //             ),
    //     ),
    //     floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    //     floatingActionButton: buildFloatingBookButton(isDark),
    //   ),
    // );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// Sliver AppBar
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 180.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.darkRed,
      leading: Builder(
        builder: (BuildContext context) {
          return Container(
            margin: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedMenu03,
                  color: Colors.white,
                  size: 24.sp),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          );
        },
      ),
      actions: [
        // ✅ نقاط الولاء - محسّن
        Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            final points = userProvider.user?.loyaltyPoints ?? 0;
            return GestureDetector(
              onTap: () => AppRoutes.navigate(context, AppRoutes.loyalty),
              child: Container(
                margin: EdgeInsets.only(right: 8.w, top: 10.h, bottom: 10.h),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedStars,
                      color: AppColors.gold.withValues(alpha: 0.8),
                      size: 16.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '$points',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .then(delay: 3000.ms)
                  .shimmer(
                    duration: 1500.ms,
                    color: AppColors.gold.withValues(alpha: 0.5),
                  ),
            );
          },
        ),

        SizedBox(width: 4.w),

        // ✅ الإشعارات - محسّن
        Consumer<NotificationProvider>(
          builder: (context, notificationProvider, _) {
            final unreadCount = notificationProvider.unreadCount;

            return Container(
              margin: EdgeInsets.only(
                  right: 4.w, left: 12.w, top: 10.h, bottom: 10.h),
              width: 42.w,
              height: 42.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: IconButton(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedNotificationSnooze01,
                        size: 22.sp,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      ),
                      onPressed: () {
                        AppRoutes.navigate(context, AppRoutes.notifications);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),

                  // ✅ Badge العدد - محسّن ومتحرك
                  if (unreadCount > 0)
                    Positioned(
                      right: -2.w,
                      top: -2.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: unreadCount > 9 ? 5.w : 4.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.error, const Color(0xFFC62828)],
                          ),
                          shape: unreadCount > 9
                              ? BoxShape.rectangle
                              : BoxShape.circle,
                          borderRadius: unreadCount > 9
                              ? BorderRadius.circular(10.r)
                              : null,
                          border: Border.all(
                            color: AppColors.darkRed,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.error.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: BoxConstraints(
                          minWidth: 18.w,
                          minHeight: 18.h,
                        ),
                        child: Center(
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                              height: 1,
                              fontFamily: 'Cairo',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                          .animate(onPlay: (controller) => controller.repeat())
                          .scale(
                            duration: 1000.ms,
                            curve: Curves.easeInOut,
                            begin: const Offset(1, 1),
                            end: const Offset(1.1, 1.1),
                          )
                          .then()
                          .scale(
                            duration: 1000.ms,
                            curve: Curves.easeInOut,
                            begin: const Offset(1.1, 1.1),
                            end: const Offset(1, 1),
                          ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [AppColors.darkRed, AppColors.darkRedDark],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  EdgeInsets.fromLTRB(16.w, 50.h, 16.w, 8.h), // ✅ تقليل Padding
              child: Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  final user = userProvider.user;
                  final greeting = _getGreeting();

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final availableWidth = constraints.maxWidth;
                      final availableHeight = constraints.maxHeight; // ✅ إضافة

                      // ✅ Proportional sizing مع مراعاة الارتفاع
                      final avatarRadius =
                          (availableWidth * 0.05).clamp(16.0, 22.0); // ✅ تصغير
                      final borderWidth =
                          (availableWidth * 0.006).clamp(1.5, 2.5);
                      final activeIndicatorSize =
                          (availableWidth * 0.028).clamp(8.0, 12.0);
                      final greetingIconSize =
                          (availableWidth * 0.032).clamp(11.0, 14.0);
                      final greetingFontSize =
                          (availableWidth * 0.03).clamp(10.0, 12.0);
                      final nameFontSize =
                          (availableWidth * 0.045).clamp(15.0, 18.0);
                      final horizontalSpacing =
                          (availableWidth * 0.03).clamp(8.0, 14.0);
                      final verticalSpacing = (availableHeight * 0.08)
                          .clamp(8.0, 14.0); // ✅ من الارتفاع

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              // ✅ Avatar Stack
                              Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.gold,
                                          AppColors.goldLight
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.gold
                                              .withValues(alpha: 0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.all(borderWidth),
                                    child: CircleAvatar(
                                      radius: avatarRadius,
                                      backgroundColor: Colors.white,
                                      child: user?.profileImageUrl != null &&
                                              user!.profileImageUrl!.isNotEmpty
                                          ? ClipOval(
                                              child: Image.network(
                                                user.profileImageUrl!,
                                                width: avatarRadius * 2,
                                                height: avatarRadius * 2,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Icon(
                                                  Icons.person,
                                                  color: AppColors.darkRed,
                                                  size: avatarRadius * 1.1,
                                                ),
                                              ),
                                            )
                                          : Icon(
                                              Icons.person,
                                              color: AppColors.darkRed,
                                              size: avatarRadius * 1.1,
                                            ),
                                    ),
                                  ),
                                  // ✅ Active Indicator
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: activeIndicatorSize,
                                      height: activeIndicatorSize,
                                      decoration: BoxDecoration(
                                        color: AppColors.success,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: borderWidth,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.success
                                                .withValues(alpha: 0.5),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(width: horizontalSpacing),

                              // ✅ User Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          _getGreetingIcon(),
                                          color: AppColors.goldLight,
                                          size: greetingIconSize,
                                        ),
                                        SizedBox(
                                            width: horizontalSpacing * 0.25),
                                        Flexible(
                                          child: Text(
                                            greeting,
                                            style: TextStyle(
                                              fontSize: greetingFontSize,
                                              color: Colors.white
                                                  .withValues(alpha: 0.9),
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Cairo',
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: verticalSpacing * 0.2),
                                    Text(
                                      user != null
                                          ? user.fullName ?? 'عزيزي العميل'
                                          : 'مرحباً بك',
                                      style: TextStyle(
                                        fontSize: nameFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'Cairo',
                                        height: 1.2, // ✅ تقليل line height
                                        shadows: [
                                          Shadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .slideX(begin: -0.2, curve: Curves.easeOutCubic),

                          SizedBox(height: verticalSpacing),

                          // ✅ Search Bar
                          Flexible(
                            // ✅ إضافة Flexible
                            child: _buildSearchBar(isDark)
                                .animate(delay: 200.ms)
                                .fadeIn(duration: 500.ms)
                                .slideY(begin: 0.1, curve: Curves.easeOut),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 17) return Icons.wb_sunny_outlined;
    if (hour < 20) return Icons.nights_stay_rounded;
    return Icons.dark_mode_rounded;
  }

  /// ✅ Enhanced Search Bottom Sheet
  /// ✅ Universal Search Bottom Sheet - بحث شامل
  void _showEnhancedSearchBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) => Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: EdgeInsets.symmetric(vertical: 12.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),

                // Search Field
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  child: TextField(
                    controller: searchController,
                    autofocus: true,
                    textDirection: ui.TextDirection.rtl,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.black,
                      fontSize: 14.sp,
                      fontFamily: 'Cairo',
                    ),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن خدمة، عرض، موعد...',
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade400,
                        fontSize: 14.sp,
                        fontFamily: 'Cairo',
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.darkRed,
                        size: 24.sp,
                      ),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded,
                                  color: Colors.grey.shade400),
                              onPressed: () {
                                searchController.clear();
                                setModalState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF2A2A2A)
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                    ),
                    onChanged: (value) => setModalState(() {}),
                  ),
                ),

                Divider(height: 1.h),

                // Search Results - بحث شامل
                Expanded(
                  child: Consumer4<ServicesProvider, OfferProvider,
                      AppointmentProvider, FavoriteProvider>(
                    builder: (context, servicesProvider, offerProvider,
                        appointmentProvider, favoriteProvider, _) {
                      final searchQuery =
                          searchController.text.toLowerCase().trim();

                      if (searchQuery.isEmpty) {
                        return _buildSearchSuggestions(isDark);
                      }

                      // ✅ البحث في كل شيء
                      final results = _performUniversalSearch(
                        searchQuery,
                        servicesProvider,
                        offerProvider,
                        appointmentProvider,
                      );

                      if (results.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 64.sp, color: Colors.grey.shade400),
                              SizedBox(height: 16.h),
                              Text(
                                'لا توجد نتائج',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey.shade400,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'جرب البحث بكلمات مختلفة',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade400,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: controller,
                        padding: EdgeInsets.all(20.w),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final result = results[index];
                          return _buildUniversalSearchCard(result, isDark);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ البحث الشامل (محسّن مع Generic Types)
  /// ✅ البحث الشامل (مصحّح)
  List<SearchResult> _performUniversalSearch(
    String query,
    ServicesProvider servicesProvider,
    OfferProvider offerProvider,
    AppointmentProvider appointmentProvider,
  ) {
    final results = <SearchResult>[];

    // 🔍 1. البحث في الخدمات
    try {
      final services = servicesProvider.services.where((service) {
        final name = (service.serviceName ?? '').toLowerCase();
        final nameAr = (service.serviceNameAr ?? '').toLowerCase();
        final desc = (service.description ?? '').toLowerCase();
        final descAr = (service.descriptionAr ?? '').toLowerCase();

        return name.contains(query) ||
            nameAr.contains(query) ||
            desc.contains(query) ||
            descAr.contains(query);
      }).toList();

      for (var service in services) {
        results.add(SearchResult(
          title: service.serviceNameAr ?? service.serviceNameAr ?? 'خدمة',
          subtitle:
              '${service.durationMinutes ?? 30} دقيقة - ${service.price ?? 0} ر.ي',
          type: 'service',
          icon: Icons.content_cut_rounded,
          color: AppColors.darkRed,
          data: service,
        ));
      }
    } catch (e) {}

    // 🔍 2. البحث في العروض
    try {
      final offers = (offerProvider.offers ?? []).where((offer) {
        final title = (offer.titleAr ?? '').toLowerCase();
        final desc = (offer.descriptionAr ?? '').toLowerCase();

        return title.contains(query) || desc.contains(query);
      }).toList();

      for (var offer in offers) {
        results.add(SearchResult(
          title: offer.titleAr ?? 'عرض',
          subtitle: offer.descriptionAr ?? '',
          type: 'offer',
          icon: Icons.local_offer_rounded,
          color: AppColors.gold,
          data: offer,
        ));
      }
    } catch (e) {}

    // 🔍 3. البحث في الفئات
    try {
      final categories = servicesProvider.categories.where((category) {
        final name = (category.categoryNameAr ?? '').toLowerCase();
        return name.contains(query);
      }).toList();

      for (var category in categories) {
        results.add(SearchResult(
          title: category.categoryNameAr ?? 'فئة',
          subtitle: 'فئة الخدمات',
          type: 'category',
          icon: Icons.category_rounded,
          color: Colors.purple,
          data: category,
        ));
      }
    } catch (e) {}

    // 🔍 4. البحث في المواعيد (مصحّح)
    try {
      final appointments =
          appointmentProvider.appointments.where((appointment) {
        // ✅ إصلاح: البحث فقط في التاريخ والحالة، ليس في الكلمات العامة
        final date = appointment.appointmentDate.toString();
        final time = appointment.appointmentTime.toLowerCase();
        final status = appointment.status.toLowerCase();

        // البحث في التاريخ، الوقت، أو الحالة
        final dateMatch = date.contains(query);
        final timeMatch = time.contains(query);

        // البحث في الحالات بالعربي
        final statusMatch = (status == 'pending' && query.contains('انتظار')) ||
            (status == 'confirmed' && query.contains('مؤكد')) ||
            (status == 'completed' && query.contains('مكتمل')) ||
            (status == 'cancelled' && query.contains('ملغي'));

        return dateMatch || timeMatch || statusMatch;
      }).toList();

      for (var appointment in appointments) {
        final statusText = appointment.status == 'pending'
            ? 'قيد الانتظار'
            : appointment.status == 'confirmed'
                ? 'مؤكد'
                : appointment.status == 'completed'
                    ? 'مكتمل'
                    : 'ملغي';

        results.add(SearchResult(
          title:
              'موعد ${DateFormat('dd/MM/yyyy', 'ar').format(DateTime.parse(appointment.appointmentDate.toString()))}',
          subtitle: '$statusText - ${_formatTime(appointment.appointmentTime)}',
          type: 'appointment',
          icon: Icons.event_rounded,
          color: Colors.blue,
          data: appointment,
        ));
      }
    } catch (e) {}

    return _sortSearchResults(results, query);
  }

  /// ✅ ترتيب نتائج البحث حسب الأهمية
  List<SearchResult> _sortSearchResults(
      List<SearchResult> results, String query) {
    results.sort((a, b) {
      // 1. الخدمات أولاً
      if (a.type == 'service' && b.type != 'service') return -1;
      if (a.type != 'service' && b.type == 'service') return 1;

      // 2. العروض ثانياً
      if (a.type == 'offer' && b.type != 'offer') return -1;
      if (a.type != 'offer' && b.type == 'offer') return 1;

      // 3. الفئات ثالثاً
      if (a.type == 'category' && b.type != 'category') return -1;
      if (a.type != 'category' && b.type == 'category') return 1;

      // 4. النتائج التي تبدأ بكلمة البحث لها أولوية
      final aStartsWith = a.title.toLowerCase().startsWith(query);
      final bStartsWith = b.title.toLowerCase().startsWith(query);

      if (aStartsWith && !bStartsWith) return -1;
      if (!aStartsWith && bStartsWith) return 1;

      return 0;
    });

    return results;
  }

  /// ✅ معالجة النقر (النسخة النهائية)
  void _handleSearchResultTap(SearchResult result) {
    switch (result.type) {
      case 'service':
        if (result.data is ServiceModel) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ServiceDetailScreen(service: result.data as ServiceModel),
            ),
          );
        }
        break;

      case 'offer':
        Navigator.pushNamed(context, AppRoutes.offers);
        break;

      case 'category':
        Navigator.pushNamed(context, AppRoutes.services);
        break;

      case 'appointment':
        if (result.data is AppointmentModel) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AppointmentDetailsScreen(
                  appointment: result.data as AppointmentModel),
            ),
          );
        }
        break;
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// 📦 Premium Packages Section - تصميم فاخر احترافي
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildPackages(bool isDark) {
    return Consumer<PackagesProvider>(
      builder: (context, packagesProvider, _) {
        if (packagesProvider.packages.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: EdgeInsets.only(top: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Premium Header مع تأثيرات إضاءة
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    colors: [
                                      Color(0xFFFFD700),
                                      Color(0xFFDAA520),
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    'باقات العضوية',
                                    style: TextStyle(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                                Text(
                                  'تجربة فاخرة تليق بك',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ✅ زر عرض الكل
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        AppRoutes.navigate(context, AppRoutes.packages);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.darkRed,
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'عرض الكل',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              LayoutBuilder(
                builder: (context, constraints) {
                  final screenHeight = MediaQuery.of(context).size.height;
                  final cardHeight = (screenHeight * 0.27).clamp(210.0, 250.0);

                  return SizedBox(
                    height: cardHeight,
                    child: ListView.separated(
                      controller: _packagesScrollController,
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      physics: const BouncingScrollPhysics(),
                      itemCount: packagesProvider.packages.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(width: 16.w),
                      itemBuilder: (context, index) {
                        final package = packagesProvider.packages[index];
                        return _buildPremiumPackageCard(
                          package,
                          isDark,
                          index,
                          cardHeight: cardHeight, // ✅ تمرير الارتفاع
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPremiumPackageCard(
    PackageModel package,
    bool isDark,
    int index, {
    required double cardHeight,
  }) {
    final colors = _getPackageColors(package);
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.70).clamp(240.0, 290.0);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.pushNamed(
            context,
            AppRoutes.packages,
            arguments: {'selectedPackageId': package.id},
          );
        },
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Stack(
            children: [
              // ✅ Outer Glow
              Positioned.fill(
                child: Container(
                  margin: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28.r),
                    boxShadow: [
                      BoxShadow(
                        color: colors[0].withValues(alpha: 0.4),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),

              // ✅ Main Card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28.r),
                  gradient: LinearGradient(
                    colors: [
                      colors[0],
                      colors[1].withValues(alpha: 0.95),
                      colors[0].withValues(alpha: 0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: colors[0].withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28.r),
                  child: Stack(
                    children: [
                      // ✅ Background Gradient
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.08),
                                Colors.transparent,
                                colors[0].withValues(alpha: 0.15),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),

                      // ✅ كرات الثلج المتحركة ⛄
                      ...List.generate(8, (i) {
                        return Positioned(
                          top: (i * 30.0 + 10) % cardHeight,
                          left: (i * 45.0 + 20) % cardWidth,
                          child: Container(
                            width: (8 + i * 3).toDouble(),
                            height: (8 + i * 3).toDouble(),
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.25),
                                  Colors.white.withValues(alpha: 0.1),
                                  Colors.transparent,
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                          )
                              .animate(
                                  onPlay: (controller) => controller.repeat())
                              .moveY(
                                duration: (2500 + i * 300).ms,
                                begin: 0,
                                end: 40,
                                curve: Curves.easeInOut,
                              )
                              .then()
                              .moveY(
                                duration: (2500 + i * 300).ms,
                                begin: 40,
                                end: 0,
                              )
                              .scale(
                                duration: (2500 + i * 300).ms,
                                begin: const Offset(1, 1),
                                end: const Offset(1.2, 1.2),
                              )
                              .then()
                              .scale(
                                duration: (2500 + i * 300).ms,
                                begin: const Offset(1.2, 1.2),
                                end: const Offset(1, 1),
                              ),
                        );
                      }),

                      // ✅ Shimmer للباقات المميزة
                      if (package.isFeatured)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withValues(alpha: 0.1),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          )
                              .animate(
                                  onPlay: (controller) => controller.repeat())
                              .moveX(duration: 2000.ms, begin: -200, end: 200),
                        ),

                      // ✅ Content
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final contentHeight = constraints.maxHeight;
                          final contentWidth = constraints.maxWidth;

                          return Padding(
                            padding: EdgeInsets.all(
                                (contentWidth * 0.07).clamp(16.0, 22.0)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ✅ Header
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (package.isFeatured)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 5.h,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFFFD700),
                                              Color(0xFFFFA500)
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFFFD700)
                                                  .withValues(alpha: 0.5),
                                              blurRadius: 12,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.auto_awesome_rounded,
                                              color: Colors.white,
                                              size: 11.sp,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              'مميزة',
                                              style: TextStyle(
                                                fontSize: 9.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontFamily: 'Cairo',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const Spacer(),
                                    Container(
                                      padding: EdgeInsets.all(8.r),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.workspace_premium_rounded,
                                        color: Colors.white,
                                        size: 18.sp,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: contentHeight * 0.055),

                                // ✅ Package Name
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Color(0xFFFFF8DC),
                                      Colors.white
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    package.nameAr,
                                    style: TextStyle(
                                      fontSize: (contentWidth * 0.09)
                                          .clamp(22.0, 28.0),
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      fontFamily: 'Cairo',
                                      letterSpacing: -0.5,
                                      height: 1.1,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.5),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                SizedBox(height: contentHeight * 0.04),

                                // ✅ Services Badge
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 5.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.white,
                                        size: 12.sp,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        '${package.services.length} خدمة',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Spacer(),

                                // ✅ Price Row
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (package.hasDiscount) ...[
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 6.w, vertical: 2.h),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade600,
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                            ),
                                            child: Text(
                                              '-${package.calculatedDiscountPercentage}%',
                                              style: TextStyle(
                                                fontSize: 8.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontFamily: 'Cairo',
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            '${package.originalPrice!.toInt()}',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: Colors.white
                                                  .withValues(alpha: 0.7),
                                              fontFamily: 'Cairo',
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              decorationColor: Colors.white
                                                  .withValues(alpha: 0.7),
                                              decorationThickness: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 6.w),
                                    ],
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Flexible(
                                            child: ShaderMask(
                                              shaderCallback: (bounds) =>
                                                  const LinearGradient(
                                                colors: [
                                                  Colors.white,
                                                  Color(0xFFFFF8DC)
                                                ],
                                              ).createShader(bounds),
                                              child: Text(
                                                '${package.price.toInt()}',
                                                style: TextStyle(
                                                  fontSize:
                                                      (contentWidth * 0.12)
                                                          .clamp(28.0, 36.0),
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                  fontFamily: 'Cairo',
                                                  height: 0.9,
                                                ),
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                bottom: 2.h, right: 3.w),
                                            child: Text(
                                              'ريال',
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white
                                                    .withValues(alpha: 0.9),
                                                fontFamily: 'Cairo',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(8.r),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.25),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Colors.white,
                                        size: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// ✨ Background Circles Animation
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildAnimatedBackgroundCircles() {
    return Stack(
      children: [
        Positioned(
          right: -50.w,
          top: -50.h,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 3),
            tween: Tween(begin: 0.8, end: 1.2),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 150.w,
                  height: 150.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.15 * value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
            onEnd: () {
              // Auto-repeat
            },
          ),
        ),
        Positioned(
          left: -40.w,
          bottom: -40.h,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 4),
            tween: Tween(begin: 0.7, end: 1.1),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 120.w,
                  height: 120.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.1 * value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// 💫 Shimmer Effect
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildShimmerEffect() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 2),
      tween: Tween(begin: -2.0, end: 2.0),
      builder: (context, value, child) {
        return CustomPaint(
          painter: ShimmerPainter(value),
        );
      },
      onEnd: () {
        // Auto-repeat
      },
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// 🎨 تحديد ألوان الباقة
  /// ═══════════════════════════════════════════════════════════════

  List<Color> _getPackageColors(PackageModel package) {
    // ✅ إذا كانت الباقة لها ألوان مخصصة
    if (package.colorPrimary != null && package.colorSecondary != null) {
      return [package.primaryColor, package.secondaryColor];
    }

    // ✅ ألوان افتراضية حسب اسم الباقة
    if (package.nameAr.contains('ذهب')) {
      return [const Color(0xFFD4A056), const Color(0xFFB8860B)];
    } else if (package.nameAr.contains('فض')) {
      return [const Color(0xFFC0C0C0), const Color(0xFF909090)];
    } else if (package.nameAr.contains('برونز')) {
      return [const Color(0xFFCD7F32), const Color(0xFFA0522D)];
    }

    // ✅ اللون الافتراضي
    return [AppColors.darkRed, const Color(0xFF8B1E1E)];
  }

  /// ✅ عرض نتائج البحث الشامل
  Widget _buildUniversalSearchCard(SearchResult result, bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _handleSearchResultTap(result);
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            // Icon with color
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: result.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(result.icon, color: result.color, size: 24.sp),
            ),

            SizedBox(width: 12.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.black,
                      fontFamily: 'Cairo',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    result.subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontFamily: 'Cairo',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Type Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: result.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                _getTypeLabel(result.type),
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: result.color,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ اقتراحات البحث
  Widget _buildSearchSuggestions(bool isDark) {
    final suggestions = [
      {
        'icon': Icons.content_cut_rounded,
        'text': 'حلاقة',
        'color': AppColors.darkRed
      },
      {
        'icon': Icons.face_retouching_natural,
        'text': 'تشذيب اللحية',
        'color': Colors.orange
      },
      {
        'icon': Icons.local_offer_rounded,
        'text': 'عروض خاصة',
        'color': AppColors.gold
      },
      {'icon': Icons.event_rounded, 'text': 'مواعيدي', 'color': Colors.blue},
    ];

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اقتراحات البحث',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.black,
              fontFamily: 'Cairo',
            ),
          ),
          SizedBox(height: 16.h),
          ...suggestions
              .map((suggestion) => ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: (suggestion['color'] as Color)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        suggestion['icon'] as IconData,
                        color: suggestion['color'] as Color,
                        size: 24.sp,
                      ),
                    ),
                    title: Text(
                      suggestion['text'] as String,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? Colors.white : AppColors.black,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    onTap: () {
                      // يمكن تنفيذ البحث مباشرة
                    },
                  ))
              .toList(),
        ],
      ),
    );
  }

  /// ✅ معالجة النقر على نتيجة البحث

  /// ✅ الحصول على نص النوع
  String _getTypeLabel(String type) {
    switch (type) {
      case 'service':
        return 'خدمة';
      case 'offer':
        return 'عرض';
      case 'category':
        return 'فئة';
      case 'appointment':
        return 'موعد';
      default:
        return '';
    }
  }

  Widget _buildSearchBar(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // ✅ استخدام constraints للتكيّف
        final availableWidth = constraints.maxWidth;

        // ✅ حساب نسبي للعناصر
        final horizontalPadding = availableWidth * 0.04; // 4% من العرض
        final verticalPadding = 12.h;
        final iconContainerSize = availableWidth * 0.08; // 8% من العرض
        final spacing = availableWidth * 0.03; // 3% من العرض

        // ✅ Font size نسبي
        final fontSize = (availableWidth * 0.038).clamp(12.0, 16.0);
        final iconSize = (availableWidth * 0.055).clamp(18.0, 22.0);

        return GestureDetector(
          onTap: () => _showEnhancedSearchBottomSheet(),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 48.h, // ✅ Minimum touch target iOS & Android
              maxHeight: 56.h,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppColors.greyLight.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ Search Icon Container
                Container(
                  width: iconContainerSize,
                  height: iconContainerSize,
                  decoration: BoxDecoration(
                    color: AppColors.darkRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.search_rounded,
                      color: AppColors.darkRed,
                      size: iconSize,
                    ),
                  ),
                ),

                SizedBox(width: spacing),

                // ✅ Text
                Expanded(
                  child: Text(
                    'دعنا نساعدك في العثور على ما تبحث عنه...',
                    style: TextStyle(
                      fontSize: fontSize,
                      color: AppColors.greyMedium,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                SizedBox(width: spacing / 2),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(
                begin: 0.3,
                curve: Curves.easeOutCubic,
              ),
        );
      },
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// Quick Actions
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildQuickActions(bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionCard(
              icon: Icons.calendar_today_rounded,
              title: 'حجوزاتي',
              subtitle: 'عرض المواعيد',
              color: AppColors.darkRed,
              isDark: isDark,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MyAppointmentsScreen()),
              ),
            ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildQuickActionCard(
              icon: Icons.local_offer_rounded,
              title: 'العروض',
              subtitle: 'خصومات حصرية',
              color: AppColors.gold,
              isDark: isDark,
              onTap: () => AppRoutes.navigate(context, AppRoutes.offers),
            ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.black,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// Upcoming Appointments
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildUpcomingAppointments(bool isDark) {
    return Consumer<AppointmentProvider>(
      builder: (context, appointmentProvider, _) {
        final upcoming = appointmentProvider.appointments
            .where((a) => a.status == 'pending' || a.status == 'confirmed')
            .take(1)
            .toList();

        if (upcoming.isEmpty) return const SizedBox.shrink();

        final appointment = upcoming.first;

        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'موعدك القادم',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyAppointmentsScreen()),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.darkRed,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                    ),
                    child: Text('عرض الكل', style: TextStyle(fontSize: 14.sp)),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AppointmentDetailsScreen(appointment: appointment),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.darkRed, AppColors.darkRedDark],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkRed.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(Icons.event_available_rounded,
                            color: Colors.white, size: 28.sp),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.services?.first.serviceNameAr ??
                                  'خدمة',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 14.sp,
                                    color: Colors.white.withValues(alpha: 0.9)),
                                SizedBox(width: 6.w),
                                Text(
                                  DateFormat('d MMM yyyy', 'ar')
                                      .format(appointment.appointmentDate),
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Icon(Icons.access_time,
                                    size: 14.sp,
                                    color: Colors.white.withValues(alpha: 0.9)),
                                SizedBox(width: 6.w),
                                Text(
                                  _formatTime(appointment.appointmentTime),
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white, size: 18.sp),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// Categories
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildCategories(bool isDark) {
    return Consumer<ServicesProvider>(
      builder: (context, servicesProvider, _) {
        if (servicesProvider.categories.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'التصنيفات',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        AppRoutes.navigate(context, AppRoutes.services),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.darkRed,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                    ),
                    child: Text('عرض الكل', style: TextStyle(fontSize: 14.sp)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 120.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: servicesProvider.categories.length,
                itemBuilder: (context, index) {
                  final category = servicesProvider.categories[index];
                  return GestureDetector(
                    onTap: () {
                      servicesProvider.filterByCategory(category.id);
                      AppRoutes.navigate(context, AppRoutes.services);
                    },
                    child: Container(
                      width: 100.w,
                      margin: EdgeInsets.only(left: 12.w),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: AppColors.darkRed.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.cut_rounded,
                                color: AppColors.darkRed, size: 28.sp),
                          ),
                          SizedBox(height: 10.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: Text(
                              category.categoryNameAr ??
                                  category.categoryName ??
                                  '',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : AppColors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate(delay: Duration(milliseconds: 100 * index))
                        .fadeIn()
                        .scale(),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// Offers
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildOffers(bool isDark) {
    return Consumer<OfferProvider>(
      builder: (context, offerProvider, _) {
        if (offerProvider.offers.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'العروض الخاصة',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        AppRoutes.navigate(context, AppRoutes.offers),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.darkRed,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                    ),
                    child: Text('عرض الكل', style: TextStyle(fontSize: 14.sp)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 150.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: offerProvider.offers.take(5).length,
                itemBuilder: (context, index) {
                  final offer = offerProvider.offers[index];

                  // ✅ استخدام InkWell للتفاعل مع تأثير Ripple
                  return InkWell(
                    onTap: () {
                      // ✅ الانتقال لشاشة العروض مباشرة
                      Navigator.pushNamed(context, AppRoutes.offers);
                    },
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      width: 280.w,
                      margin: EdgeInsets.only(left: 16.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gold,
                            AppColors.gold.withValues(alpha: 0.7)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // ✅ Decorative Circle
                          Positioned(
                            right: -20.w,
                            top: -20.h,
                            child: Container(
                              width: 80.w,
                              height: 80.h,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),

                          // ✅ Content
                          Padding(
                            padding: EdgeInsets.all(14.r),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.w, vertical: 3.h),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.3),
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                      child: Text(
                                        'عرض خاص',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      offer.titleAr ?? offer.title ?? '',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      offer.descriptionAr ??
                                          offer.description ??
                                          '',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),

                                // ✅ Bottom Row with Arrow
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'خصم ${offer.discountValue}%',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),

                                    // ✅ Arrow with circle background
                                    Container(
                                      padding: EdgeInsets.all(8.r),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.25),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 18.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate(delay: Duration(milliseconds: 100 * index))
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: 0.2, curve: Curves.easeOut)
                      .then()
                      .shimmer(
                        duration: 2000.ms,
                        color: Colors.white.withValues(alpha: 0.1),
                      );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// Popular Services
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildPopularServices(bool isDark) {
    return Consumer<ServicesProvider>(
      builder: (context, servicesProvider, _) {
        if (servicesProvider.services.isEmpty) return const SizedBox.shrink();

        final popularServices = servicesProvider.services.take(6).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الخدمات الشائعة',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        AppRoutes.navigate(context, AppRoutes.services),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.darkRed,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                    ),
                    child: Text('عرض الكل', style: TextStyle(fontSize: 14.sp)),
                  ),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.75,
              ),
              itemCount: popularServices.length,
              itemBuilder: (context, index) {
                return _buildServiceCard(popularServices[index], isDark, index);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildServiceCard(ServiceModel service, bool isDark, int index) {
    return GestureDetector(
      onTap: () => AppRoutes.navigateWithData(
        context,
        ServiceDetailScreen(service: service),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: service.imageUrl != null && service.imageUrl!.isNotEmpty
                    ? Image.network(
                        service.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(isDark),
                      )
                    : _buildPlaceholder(isDark),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(10.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      service.serviceNameAr ?? service.serviceName ?? '',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${service.price.toStringAsFixed(0)} ريال',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 14.sp, color: AppColors.darkRed),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate(delay: Duration(milliseconds: 50 * index)).fadeIn().scale(),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      height: 140.h,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
      child: Center(
        child: Image.asset(
          'assets/images/logo.png',
          height: 80.h,
          fit: BoxFit.contain,
          color: isDark
              ? Colors.grey.shade700
              : null, // اختياري لتأثير بسيط في الوضع الليلي
        ),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// Floating Action Button
  /// ═══════════════════════════════════════════════════════════════
// ─── Floating Book Button ───────────────────────────────────────────────────

  // ─── Floating Speed Dial ──────────────────────────────────────────────────────

  Widget buildFloatingBookButton(bool isDark) {
    return SpeedDial(
      // ── الزر الرئيسي ──────────────────────────────────────────────
      backgroundColor: AppColors.darkRed,
      foregroundColor: Colors.white,
      activeBackgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      activeForegroundColor: AppColors.darkRed,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.r),
      ),
      buttonSize: Size(56.w, 56.h),

      // ── الأيقونة ──────────────────────────────────────────────────
      icon: Icons.calendar_today_rounded,
      activeIcon: Icons.close_rounded,

      // ── النص بجانب الزر ──────────────────────────────────────────
      label: Text(
        'احجز موعدك',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Cairo',
        ),
      ),
      activeLabel: Text(
        'إغلاق',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.darkRed,
          fontFamily: 'Cairo',
        ),
      ),

      // ── Overlay ───────────────────────────────────────────────────
      overlayColor: Colors.black,
      overlayOpacity: 0.4,
      renderOverlay: true,

      // ── Animation ─────────────────────────────────────────────────
      animationDuration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      useRotationAnimation: true,

      // ── Spacing ───────────────────────────────────────────────────
      spaceBetweenChildren: 12,
      childPadding: EdgeInsets.symmetric(vertical: 4.h),

      // ── Callbacks ─────────────────────────────────────────────────
      onOpen: () => HapticFeedback.mediumImpact(),
      onClose: () => HapticFeedback.lightImpact(),

      // ── الأزرار الفرعية ───────────────────────────────────────────
      children: [

        // ✅ حجز فردي
        SpeedDialChild(
          child: Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 24.sp,
          ),
          backgroundColor: AppColors.darkRed,
          foregroundColor: Colors.white,
          label: 'حجز فردي',
          labelBackgroundColor:
          isDark ? const Color(0xFF1E1E1E) : Colors.white,
          labelShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          // ✅ CircleBorder يمنع قطع الأيقونة
          shape: const CircleBorder(),
          elevation: 6,
          onTap: () {
            HapticFeedback.lightImpact();
            AppRoutes.navigate(context, AppRoutes.services);
          },
        ),

        // ✅ حجز جماعي
        SpeedDialChild(
          child: Icon(
            Icons.groups_rounded,
            color: Colors.white,
            size: 24.sp,
          ),
          backgroundColor: const Color(0xFFDAA520),
          foregroundColor: Colors.white,
          label: 'حجز جماعي',
          labelBackgroundColor:
          isDark ? const Color(0xFF1E1E1E) : Colors.white,
          labelShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          // ✅ CircleBorder يمنع قطع الأيقونة
          shape: const CircleBorder(),
          elevation: 6,
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) =>
                const MultiAppointmentScreen(),
                transitionDuration:
                const Duration(milliseconds: 280),
                reverseTransitionDuration:
                const Duration(milliseconds: 220),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.05),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      )),
                      child: child,
                    ),
                  );
                },
              ),
            );
          },
        ),

      ],
    );
  }

  void _showBookingTypeSheet(bool isDark) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle ───────────────────────────────────────────────
              Container(
                margin: EdgeInsets.symmetric(vertical: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              SizedBox(height: 8.h),

              // ── Title ─────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: AppColors.darkRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.darkRed,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نوع الحجز',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.black,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        'اختر طريقة الحجز المناسبة لك',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark
                              ? Colors.grey.shade400
                              : AppColors.greyDark,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // ── خيار: حجز فردي ────────────────────────────────────────
              _buildBookingOption(
                isDark: isDark,
                icon: Icons.person_rounded,
                title: 'حجز فردي',
                subtitle: 'احجز موعداً خاصاً بك',
                color: AppColors.darkRed,
                gradientColors: [
                  AppColors.darkRed,
                  AppColors.darkRedDark,
                ],
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                  AppRoutes.navigate(context, AppRoutes.services);
                },
                delay: 0,
              ),

              SizedBox(height: 14.h),

              // ── خيار: حجز جماعي ──────────────────────────────────────
              _buildBookingOption(
                isDark: isDark,
                icon: Icons.groups_rounded,
                title: 'حجز جماعي',
                subtitle: 'احجز لأكثر من شخص في وقت واحد',
                color: AppColors.gold,
                gradientColors: [
                  const Color(0xFFDAA520),
                  AppColors.gold,
                ],
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) =>
                          const MultiAppointmentScreen(),
                      transitionDuration: const Duration(milliseconds: 280),
                      reverseTransitionDuration:
                          const Duration(milliseconds: 220),
                      transitionsBuilder: (_, animation, __, child) {
                        return FadeTransition(
                          opacity: CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ),
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.05),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            )),
                            child: child,
                          ),
                        );
                      },
                    ),
                  );
                },
                delay: 100,
              ),

              SizedBox(height: 8.h),
            ],
          ),
        );
      },
    );
  }

// ─── Booking Option Card ─────────────────────────────────────────────────────

  Widget _buildBookingOption({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required int delay,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // أيقونة مع خلفية متدرجة
            Container(
              width: 52.w,
              height: 52.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24.sp),
            ),

            SizedBox(width: 14.w),

            // النص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.black,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),

            // سهم
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: color,
                size: 14.sp,
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: Duration(milliseconds: delay), duration: 300.ms)
          .slideY(begin: 0.1, curve: Curves.easeOut),
    );
  }


  /// التحقق من عرض Badge "جديد" بناءً على المدة
  Future<bool> _shouldShowNewBadge(String badgeKey, {int days = 7}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // التحقق إذا كان Badge معروض لأول مرة
      final firstSeenTimestamp = prefs.getInt('${badgeKey}_first_seen');

      if (firstSeenTimestamp == null) {
        // أول مرة يتم عرض Badge، احفظ التاريخ
        await prefs.setInt(
          '${badgeKey}_first_seen',
          DateTime.now().millisecondsSinceEpoch,
        );
        return true; // عرض Badge
      }

      // حساب الفرق بين التاريخ الحالي وتاريخ أول عرض
      final firstSeenDate =
          DateTime.fromMillisecondsSinceEpoch(firstSeenTimestamp);
      final now = DateTime.now();
      final difference = now.difference(firstSeenDate);

      // إخفاء Badge بعد عدد الأيام المُحدد
      return difference.inDays < days;
    } catch (e) {
      return false;
    }
  }

  /// إعادة تعيين Badge (مفيد عند إضافة باقات جديدة فعلاً)
  Future<void> resetPackagesBadge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('packages_badge_first_seen');
  }

// ═══════════════════════════════════════════════════════════
// ✅ MODERN LOGOUT DIALOG
// ═══════════════════════════════════════════════════════════
  void _showModernLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 0.85.sw,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Icon
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 28.sp,
                  ),
                ),

                SizedBox(height: 20.h),

                // ✅ Title
                Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    fontFamily: 'Cairo',
                  ),
                ),

                SizedBox(height: 10.h),

                // ✅ Message
                Text(
                  'هل أنت متأكد من تسجيل الخروج؟\nسيتم إيقاف جميع الإشعارات',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                    fontFamily: 'Cairo',
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 24.h),

                // ✅ Buttons Row
                Row(
                  children: [
                    // ✅ Cancel Button
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          backgroundColor: isDark
                              ? Colors.grey.shade900
                              : Colors.grey.shade100,
                        ),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 12.w),

                    // ✅ Logout Button
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          Navigator.pop(context);

                          // ✅ Show Loading
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => Center(
                              child: Container(
                                padding: EdgeInsets.all(20.w),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1A1A1A)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      color: AppColors.darkRed,
                                      strokeWidth: 3,
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      'جاري تسجيل الخروج...',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );

                          await context.read<UserProvider>().logout();

                          if (context.mounted) {
                            Navigator.pop(context); // Close loading
                            Navigator.pushReplacementNamed(
                                context, AppRoutes.login);
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'تسجيل الخروج',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
        );
      },
    );
  }

  Widget _buildDrawer(bool isDark) {
    return Drawer(
      width: 0.82.sw,
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      child: Column(
        children: [
          _buildModernHeader(isDark),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              physics: const BouncingScrollPhysics(),
              children: [
                // ✅ Main Section
                _buildSectionTitle('القائمة الرئيسية', isDark),
                _buildModernTile(
                  icon: Ionicons.home_outline,
                  title: 'الرئيسية',
                  isDark: isDark,
                  onTap: () => Navigator.pop(context),
                ),

                // ✅ مواعيدي - ديناميكي مع عدد المواعيد القادمة
                Consumer<AppointmentProvider>(
                  builder: (context, appointmentProvider, _) {
                    final upcomingCount = appointmentProvider.appointments
                        .where((apt) =>
                            (apt.status == 'pending' ||
                                apt.status == 'confirmed') &&
                            apt.appointmentDate != null &&
                            apt.appointmentDate!.isAfter(DateTime.now()))
                        .length;

                    return _buildModernTile(
                      icon: Ionicons.calendar_outline,
                      title: 'مواعيدي',
                      badge: upcomingCount > 0 ? '$upcomingCount' : null,
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyAppointmentsScreen()),
                        );
                      },
                    );
                  },
                ),

                _buildModernTile(
                  icon: Ionicons.person_outline,
                  title: 'الملف الشخصي',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    AppRoutes.navigate(context, AppRoutes.profile);
                  },
                ),

                SizedBox(height: 16.h),

                // ✅ Services Section
                _buildSectionTitle('الخدمات', isDark),
                _buildModernTile(
                  icon: Ionicons.cut_outline,
                  title: 'جميع الخدمات',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    AppRoutes.navigate(context, AppRoutes.services);
                  },
                ),

                // ✅ الباقات - مع Badge "جديد" يختفي بعد 7 أيام
                FutureBuilder<bool>(
                  future: _shouldShowNewBadge('packages_badge', days: 2),
                  builder: (context, snapshot) {
                    final showBadge = snapshot.data ?? false;

                    return _buildModernTile(
                      icon: Ionicons.gift_outline,
                      title: 'الباقات المميزة',
                      badge: showBadge ? 'جديد' : null,
                      badgeColor: AppColors.success,
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(context);
                        AppRoutes.navigate(context, AppRoutes.packages);
                      },
                    );
                  },
                ),

                _buildModernTile(
                  icon: Ionicons.pricetags_outline,
                  title: 'العروض الحصرية',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    AppRoutes.navigate(context, AppRoutes.offers);
                  },
                ),

                _buildModernTile(
                  icon: Ionicons.sparkles_outline,
                  title: 'نقاط الولاء',
                  iconColor: AppColors.gold,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    AppRoutes.navigate(context, AppRoutes.loyalty);
                  },
                ),

                SizedBox(height: 16.h),

                // ✅ 🛒 Shopping Section - جديد!
                _buildSectionTitle('المتجر', isDark),

                // المنتجات - مع Badge عدد المنتجات
                Consumer<ProductProvider>(
                  builder: (context, productProvider, _) {
                    return _buildModernTile(
                      icon: Ionicons.storefront_outline,
                      title: 'المنتجات',
                      badge: productProvider.products.isNotEmpty
                          ? '${productProvider.products.length}'
                          : null,
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProductsScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),

                // السلة - مع Badge عدد المنتجات
                Consumer<CartProvider>(
                  builder: (context, cart, _) {
                    return _buildModernTile(
                      icon: Ionicons.cart_outline,
                      title: 'سلة التسوق',
                      badge: cart.itemCount > 0 ? '${cart.itemCount}' : null,
                      badgeColor: Colors.red,
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        );
                      },
                    );
                  },
                ),

                // طلباتي - مع Badge عدد الطلبات القادمة
                Consumer<OrderProvider>(
                  builder: (context, orderProvider, _) {
                    final pendingOrders = orderProvider.userOrders
                        .where((order) =>
                            order.status == 'pending' ||
                            order.status == 'confirmed' ||
                            order.status == 'processing')
                        .length;

                    return _buildModernTile(
                      icon: Ionicons.receipt_outline,
                      title: 'طلباتي',
                      badge: pendingOrders > 0 ? '$pendingOrders' : null,
                      badgeColor: Colors.orange,
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OrdersListScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),

                SizedBox(height: 16.h),

                // ✅ More Section
                _buildSectionTitle('المزيد', isDark),

                _buildModernTile(
                  icon: Ionicons.notifications_outline,
                  title: 'الإشعارات',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    AppRoutes.navigate(context, AppRoutes.notifications);
                  },
                ),

                _buildModernTile(
                  icon: Ionicons.settings_outline,
                  title: 'الإعدادات',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    AppRoutes.navigate(context, AppRoutes.settings);
                  },
                ),

                _buildModernTile(
                  icon: Ionicons.help_outline,
                  title: 'المساعدة',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FAQScreen()),
                    );
                  },
                ),

                _buildModernTile(
                  icon: Ionicons.call_outline,
                  title: 'تواصل معنا',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ContactUsScreen()),
                    );
                  },
                ),

                SizedBox(height: 20.h),

                // ✅ Logout Button
                _buildLogoutButton(isDark),

                SizedBox(height: 12.h),
              ],
            ),
          ),
          _buildModernFooter(isDark),
        ],
      ),
    );
  }

// ═══════════════════════════════════════════════════════════
// ✅ MODERN HEADER
// ═══════════════════════════════════════════════════════════

  Widget _buildModernHeader(bool isDark) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;

        return Container(
          padding: EdgeInsets.fromLTRB(20.w, 50.h, 20.w, 20.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.darkRed,
                AppColors.darkRedDark,
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30.r),
              bottomRight: Radius.circular(30.r),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkRed.withValues(alpha: 0.4),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Top Row
                Row(
                  children: [
                    // ✅ Avatar
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [AppColors.gold, AppColors.goldLight],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(3.w),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 30.r,
                              backgroundImage: user?.profileImageUrl != null &&
                                  user!.profileImageUrl!.isNotEmpty
                                  ? NetworkImage(user.profileImageUrl!)
                                  : null,
                              backgroundColor: Colors.white,
                              child: user?.profileImageUrl == null ||
                                  user!.profileImageUrl!.isEmpty
                                  ? Icon(
                                Icons.person,
                                size: 32.sp,
                                color: AppColors.darkRed,
                              )
                                  : null,
                            ),
                          ),
                        ),
                        // ✅ Online Indicator
                        Positioned(
                          bottom: 2.h,
                          right: 2.w,
                          child: Container(
                            width: 14.w,
                            height: 14.h,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.success.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(width: 14.w),

                    // ✅ User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user?.fullName ?? 'مرحباً بك',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Cairo',
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_user,
                                  size: 12.sp,
                                  color: AppColors.goldLight,
                                ),
                                SizedBox(width: 4.w),
                                // ✅ إصلاح الـ overflow
                                Flexible(
                                  child: Text(
                                    user?.phone ?? 'مستخدم نشط',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.white.withValues(alpha: 0.95),
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ✅ Action Buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 4.w),

                        // ✅ زر المفضلة
                        Consumer<FavoriteProvider>(
                          builder: (context, favoriteProvider, _) {
                            return _buildHeaderIconButton(
                              icon: favoriteProvider.favorites.isEmpty
                                  ? Icons.favorite_border_rounded
                                  : Icons.favorite_rounded,
                              iconColor: favoriteProvider.favorites.isEmpty
                                  ? Colors.white
                                  : Colors.red.shade300,
                              showBadge: favoriteProvider.favorites.isNotEmpty,
                              badgeCount: favoriteProvider.favorites.length,
                              onPressed: () {
                                Navigator.pop(context);
                                AppRoutes.navigate(context, AppRoutes.favorites);
                              },
                            );
                          },
                        ),

                        SizedBox(width: 4.w),

                        // ✅ زر التعديل
                        _buildHeaderIconButton(
                          icon: Icons.edit_outlined,
                          onPressed: () {
                            Navigator.pop(context);
                            AppRoutes.navigate(context, AppRoutes.profile);
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // ✅ Loyalty Points Card
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Ionicons.sparkles_sharp,
                              color: AppColors.goldLight,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'نقاط الولاء',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              Text(
                                '${user?.loyaltyPoints ?? 0} نقطة',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            AppRoutes.navigate(context, AppRoutes.loyalty);
                          },
                          borderRadius: BorderRadius.circular(10.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'عرض',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 12.sp,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// ✅ Header Icon Button Helper

  Widget _buildHeaderIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool showBadge = false,
    int badgeCount = 0,
    Color? iconColor,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onPressed();
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.all(6.w), // ✅ من 10 إلى 6
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8.r), // ✅ من 12 إلى 8
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: iconColor ?? Colors.white,
                size: 16.sp, // ✅ من 20 إلى 16
              ),
            ),
          ),
        ),
        if (showBadge && badgeCount > 0)
          Positioned(
            top: -3.h,  // ✅ تعديل موضع البادج
            right: -3.w,
            child: Container(
              padding: EdgeInsets.all(3.w), // ✅ من 4 إلى 3
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.error, const Color(0xFFC62828)],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.darkRed, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.5),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                badgeCount > 9 ? '9+' : '$badgeCount',
                style: TextStyle(
                  fontSize: 8.sp, // ✅ من 9 إلى 8
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
          fontFamily: 'Cairo',
          letterSpacing: 1,
        ),
      ),
    );
  }

// ═══════════════════════════════════════════════════════════
// ✅ MODERN TILE
// ═══════════════════════════════════════════════════════════
  Widget _buildModernTile({
    required IconData icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
    String? badge,
    Color? badgeColor,
    Color? iconColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22.sp,
                  color:
                      iconColor ?? (isDark ? Colors.white : AppColors.darkRed),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: badgeColor ?? AppColors.darkRed,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14.sp,
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// ═══════════════════════════════════════════════════════════
// ✅ LOGOUT BUTTON
// ═══════════════════════════════════════════════════════════
  Widget _buildLogoutButton(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          _showCleanLogoutDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
          foregroundColor: AppColors.error,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Ionicons.log_out_sharp, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              'تسجيل الخروج',
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFooter(bool isDark) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'طُور بـ ',
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade600,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  TextSpan(
                    text: '❤️',
                    style: TextStyle(fontSize: 10.sp),
                  ),
                  TextSpan(
                    // ✅ مباشر بدون FutureBuilder
                    text: ' م. عبدالوهاب الربيعي • v$_appVersion',
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  final url = Uri.parse('https://wa.me/967776684112');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedWhatsapp,
                  color: const Color(0xFF25D366),
                  size: 18.sp,
                ),
                padding: EdgeInsets.all(6.w),
                constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
              ),
              IconButton(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  final url = Uri.parse('tel:+967776684112');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedCall02,
                  color: AppColors.success,
                  size: 18.sp,
                ),
                padding: EdgeInsets.all(6.w),
                constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCleanLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          contentPadding: EdgeInsets.all(24.w),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: Icon(Icons.logout, color: AppColors.error, size: 32.sp),
              ),
              SizedBox(height: 20.h),
              Text('تسجيل الخروج',
                  style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo')),
              SizedBox(height: 12.h),
              Text('هل أنت متأكد؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                      fontFamily: 'Cairo')),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                      child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r))),
                          child: Text('إلغاء',
                              style: TextStyle(fontFamily: 'Cairo')))),
                  SizedBox(width: 12.w),
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await context.read<UserProvider>().logout();
                            if (context.mounted)
                              Navigator.pushReplacementNamed(
                                  context, AppRoutes.login);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r))),
                          child: Text('خروج',
                              style: TextStyle(
                                  fontFamily: 'Cairo', color: Colors.white)))),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// ✅ Shimmer Loading
  Widget _buildShimmerLoading(bool isDark) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 180.h,
          pinned: true,
          backgroundColor: AppColors.darkRed,
        ),
        SliverToBoxAdapter(
          child: Shimmer.fromColors(
            baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  // Quick Actions Shimmer
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 120.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Container(
                          height: 120.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Section Title
                  Container(
                    height: 24.h,
                    width: 150.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    alignment: Alignment.centerRight,
                  ),

                  SizedBox(height: 16.h),

                  // Categories Shimmer
                  SizedBox(
                    height: 120.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      itemBuilder: (_, i) => Container(
                        width: 100.w,
                        margin: EdgeInsets.only(left: 12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Services Grid Shimmer
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: 6,
                    itemBuilder: (_, i) => Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
