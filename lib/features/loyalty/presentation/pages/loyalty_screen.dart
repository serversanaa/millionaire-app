import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:millionaire_barber/features/coupons/domain/models/coupon_model.dart';
import 'package:millionaire_barber/features/loyalty/domain/models/loyalty_transaction_model.dart';
import 'package:millionaire_barber/features/loyalty/domain/models/milestone_model.dart';
import 'package:millionaire_barber/features/loyalty/presentation/providers/loyalty_transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

import '../../../../core/constants/app_colors.dart';
import '../../../profile/presentation/providers/user_provider.dart';

/// ═══════════════════════════════════════════════════════════════
/// شاشة نقاط الولاء - النسخة النهائية الكاملة
/// مع تمييز الكوبونات المستخدمة
/// ═══════════════════════════════════════════════════════════════
class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({Key? key}) : super(key: key);

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _shimmerController;
  late AnimationController _glowController;

  int _selectedTab = 0;
  LoyaltyTransactionProvider? _loyaltyProvider;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loyaltyProvider == null) {
      _loyaltyProvider = Provider.of<LoyaltyTransactionProvider>(
        context,
        listen: false,
      );
    }
  }

  @override
  void dispose() {
    _loyaltyProvider?.unsubscribeFromLoyaltyUpdates();
    _loyaltyProvider?.unsubscribeFromSettingsUpdates();

    _pulseController.dispose();
    _rotateController.dispose();
    _shimmerController.dispose();
    _glowController.dispose();

    super.dispose();
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.user == null || _loyaltyProvider == null) return;

    final userId = userProvider.user!.id!;

    await _loyaltyProvider!.loadLoyaltyData(userId);

    if (mounted) {
      _loyaltyProvider!.subscribeToLoyaltyUpdates(userId);
      _loyaltyProvider!.subscribeToSettingsUpdates();
    }
  }

  Future<void> _refreshData() async {
    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.user == null || _loyaltyProvider == null) return;

    HapticFeedback.mediumImpact();
    await _loyaltyProvider!.refreshLoyaltyData(userProvider.user!.id!);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    if (user == null) {
      return _buildNotLoggedIn(isDark);
    }

    return Consumer<LoyaltyTransactionProvider>(
      builder: (context, loyaltyProvider, child) {
        _loyaltyProvider = loyaltyProvider;

        return Directionality(
          textDirection: ui.TextDirection.rtl,
          child: WillPopScope(
            onWillPop: () async {
              HapticFeedback.lightImpact();
              loyaltyProvider.unsubscribeFromLoyaltyUpdates();
              loyaltyProvider.unsubscribeFromSettingsUpdates();
              return true;
            },
            child: Scaffold(
              backgroundColor: isDark
                  ? const Color(0xFF0A0A0A)
                  : const Color(0xFFF8F9FA),
              body: Stack(
                children: [
                  _buildAnimatedBackground(isDark),
                  RefreshIndicator(
                    onRefresh: _refreshData,
                    color: AppColors.darkRed,
                    backgroundColor:
                    isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        _buildSliverAppBar(isDark, loyaltyProvider),
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              SizedBox(height: 20.h),
                              _buildPointsCard(isDark, loyaltyProvider),
                              SizedBox(height: 20.h),
                              _buildQuickStats(isDark, loyaltyProvider),
                              SizedBox(height: 30.h),
                              _buildTabSelector(isDark, loyaltyProvider),
                              SizedBox(height: 20.h),

                              if (loyaltyProvider.isLoading)
                                _buildLoadingState()
                              else ...[
                                if (_selectedTab == 0)
                                  _buildTransactionsTab(isDark, loyaltyProvider)
                                else if (_selectedTab == 1)
                                  _buildMilestonesTab(isDark, loyaltyProvider)
                                else if (_selectedTab == 2)
                                    _buildCouponsTab(isDark, loyaltyProvider)
                              ],

                              SizedBox(height: 100.h),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {
        return CustomPaint(
          painter: LoyaltyBackgroundPainter(
            animation: _rotateController,
            isDark: isDark,
          ),
          size: Size.infinite,
        );
      },
    );
  }
  // ═══════════════════════════════════════════════════════════════
  // APPBAR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSliverAppBar(bool isDark, LoyaltyTransactionProvider provider) {
    return SliverAppBar(
      expandedHeight: 140.h,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                  const Color(0xFF1A1A1A).withOpacity(0.95),
                  const Color(0xFF0A0A0A).withOpacity(0.9),
                ]
                    : [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.9),
                ],
              ),
            ),
            child: FlexibleSpaceBar(
              centerTitle: true,
              title: AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        AppColors.gold,
                        AppColors.goldDark,
                        AppColors.gold.withOpacity(0.5 + _glowController.value * 0.5),
                      ],
                    ).createShader(bounds),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.diamond, color: Colors.white, size: 22.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'نقاط الولاء',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      leading: Padding(
        padding: EdgeInsets.all(8.r),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(50),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : AppColors.black,
                size: 20.sp,
              ),
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.all(8.r),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: provider.isLoading ? null : _refreshData,
              borderRadius: BorderRadius.circular(50),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(8.r),
                child: provider.isLoading
                    ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkRed),
                  ),
                )
                    : Icon(
                  Icons.refresh_rounded,
                  color: isDark ? Colors.white : AppColors.black,
                  size: 22.sp,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // POINTS CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPointsCard(bool isDark, LoyaltyTransactionProvider provider) {
    final points = provider.totalPoints;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Hero(
        tag: 'loyalty_points_card',
        child: Container(
          height: 220.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkRed.withOpacity(0.3),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: AppColors.gold.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.darkRed,
                      AppColors.darkRedDark,
                      Color(0xFF5D0000),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28.r),
                ),
              ),
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: CardPatternPainter(
                        animation: _shimmerController.value,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'رصيدك الحالي',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  AnimatedBuilder(
                                    animation: _glowController,
                                    builder: (context, child) {
                                      return ShaderMask(
                                        shaderCallback: (bounds) => LinearGradient(
                                          colors: [Colors.white, AppColors.gold],
                                        ).createShader(bounds),
                                        child: Text(
                                          points.toString(),
                                          style: TextStyle(
                                            fontSize: 52.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            height: 1,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(width: 6.w),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8.h),
                                    child: Text(
                                      'نقطة',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (_pulseController.value * 0.15),
                              child: Container(
                                padding: EdgeInsets.all(18.r),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.gold.withOpacity(
                                        0.4 * _pulseController.value,
                                      ),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.stars_rounded,
                                  size: 36.sp,
                                  color: AppColors.gold,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.emoji_events, color: AppColors.gold, size: 18.sp),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'استمر في جمع النقاط لفتح معالم جديدة! 🎯',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).scale(duration: 400.ms),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // QUICK STATS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildQuickStats(bool isDark, LoyaltyTransactionProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickStatCard(
              icon: Icons.trending_up,
              label: 'مكتسبة',
              value: provider.totalEarnedPoints.toString(),
              color: Colors.green,
              isDark: isDark,
            ).animate(delay: 300.ms).fadeIn().scale(),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildQuickStatCard(
              icon: Icons.card_giftcard,
              label: 'كوبونات',
              value: provider.availableCouponsCount.toString(),
              color: AppColors.gold,
              isDark: isDark,
            ).animate(delay: 400.ms).fadeIn().scale(),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildQuickStatCard(
              icon: Icons.emoji_events,
              label: 'معالم',
              value: provider.achievedMilestonesCount.toString(),
              color: Colors.orange,
              isDark: isDark,
            ).animate(delay: 500.ms).fadeIn().scale(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => HapticFeedback.selectionClick(),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.black,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB SELECTOR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTabSelector(bool isDark, LoyaltyTransactionProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(5.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildTab(
              title: 'العمليات',
              icon: Icons.history_rounded,
              index: 0,
              isDark: isDark,
              count: provider.transactionCount,
            ),
            _buildTab(
              title: 'المعالم',
              icon: Icons.emoji_events_rounded,
              index: 1,
              isDark: isDark,
              count: provider.achievedMilestonesCount,
            ),
            _buildTab(
              title: 'الكوبونات',
              icon: Icons.card_giftcard_rounded,
              index: 2,
              isDark: isDark,
              count: provider.availableCouponsCount,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required IconData icon,
    required int index,
    required bool isDark,
    required int count,
  }) {
    final isSelected = _selectedTab == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedTab = index);
          },
          borderRadius: BorderRadius.circular(14.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                colors: [AppColors.darkRed, AppColors.darkRedDark],
              )
                  : null,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: AppColors.darkRed.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
                  : [],
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 20.sp,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
                SizedBox(height: 4.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                ),
                if (count > 0) ...[
                  SizedBox(height: 3.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.25)
                          : Colors.grey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TRANSACTIONS TAB
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTransactionsTab(bool isDark, LoyaltyTransactionProvider provider) {
    final completedTransactions = provider.transactions
        .where((t) => t.status == 'completed')
        .toList();

    if (completedTransactions.isEmpty) {
      return _buildEmptyState(
        isDark,
        'لا توجد عمليات بعد',
        Icons.receipt_long_outlined,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: completedTransactions.asMap().entries.map((entry) {
          return _buildTransactionCard(entry.value, isDark, entry.key);
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionCard(
      LoyaltyTransactionModel transaction,
      bool isDark,
      int index,
      ) {
    final isPositive = transaction.transactionType == 'earned' ||
        transaction.transactionType == 'bonus';
    final date = transaction.createdAt ?? DateTime.now();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => HapticFeedback.selectionClick(),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPositive ? Icons.add : Icons.remove,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description ?? transaction.transactionType,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      DateFormat('dd MMM yyyy، hh:mm a', 'ar').format(date),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isPositive ? '+' : '-'}${transaction.pointsAmount}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ).animate(delay: Duration(milliseconds: 100 + (index * 50)))
          .fadeIn()
          .slideX(begin: 0.2),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MILESTONES TAB
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMilestonesTab(bool isDark, LoyaltyTransactionProvider provider) {
    if (provider.isLoadingMilestones) {
      return _buildLoadingState();
    }

    if (provider.milestones.isEmpty) {
      return _buildEmptyState(
        isDark,
        'لا توجد معالم متاحة',
        Icons.emoji_events_outlined,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.darkRed, AppColors.darkRedDark],
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkRed.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.stars, color: AppColors.gold, size: 32.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نقاطك الحالية',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${provider.totalPoints} نقطة',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                if (provider.nextMilestone != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'المعلم التالي',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.gold.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          '${provider.nextMilestone!.pointsToGo}',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ).animate().fadeIn().scale(),
          SizedBox(height: 24.h),
          ...provider.milestones.asMap().entries.map((entry) {
            final index = entry.key;
            final milestone = entry.value;
            return _buildMilestoneCard(milestone, isDark, index);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(MilestoneModel milestone, bool isDark, int index) {
    final isAchieved = milestone.isAchieved;
    final progress = milestone.progressPercentage;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => HapticFeedback.selectionClick(),
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          margin: EdgeInsets.only(bottom: 14.h),
          padding: EdgeInsets.all(18.r),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isAchieved
                  ? AppColors.gold.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.2),
              width: isAchieved ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isAchieved
                    ? AppColors.gold.withOpacity(0.2)
                    : Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: isAchieved
                          ? AppColors.gold.withOpacity(0.15)
                          : Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isAchieved
                          ? Icons.emoji_events
                          : Icons.emoji_events_outlined,
                      color: isAchieved ? AppColors.gold : Colors.grey,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${milestone.pointsRequired} نقطة',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.black,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          milestone.descriptionAr ??
                              'خصم ${milestone.discountPercentage}%',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isAchieved)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gold.withOpacity(0.8),
                            AppColors.goldDark,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withOpacity(0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.white, size: 16.sp),
                          SizedBox(width: 6.w),
                          Text(
                            'محقق',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'متبقي ${milestone.pointsToGo}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                ],
              ),
              if (!isAchieved) ...[
                SizedBox(height: 16.h),
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.darkRed),
                        minHeight: 10.h,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}% مكتمل',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${milestone.pointsRequired - milestone.pointsToGo} / ${milestone.pointsRequired}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
              if (isAchieved && milestone.couponCode != null) ...[
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.gold.withOpacity(0.1),
                        AppColors.gold.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: AppColors.gold.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.card_giftcard,
                          color: AppColors.gold, size: 22.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'كود الكوبون',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              milestone.couponCode!,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            HapticFeedback.mediumImpact();
                            await Clipboard.setData(
                                ClipboardData(text: milestone.couponCode!));
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('تم نسخ الكود ✓'),
                                  backgroundColor: AppColors.gold,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(10.r),
                          child: Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(Icons.copy,
                                color: AppColors.gold, size: 20.sp),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ).animate(delay: Duration(milliseconds: 100 + (index * 60)))
          .fadeIn()
          .slideX(begin: 0.2),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // COUPONS TAB
  // ═══════════════════════════════════════════════════════════════

  Widget _buildCouponsTab(bool isDark, LoyaltyTransactionProvider provider) {
    if (provider.isLoadingCoupons) {
      return _buildLoadingState();
    }

    if (provider.coupons.isEmpty) {
      return _buildEmptyState(
        isDark,
        'لا توجد كوبونات بعد',
        Icons.card_giftcard_outlined,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.availableCoupons.isNotEmpty) ...[
            _buildSectionHeader('الكوبونات المتاحة', isDark, Icons.card_giftcard),
            SizedBox(height: 12.h),
            ...provider.availableCoupons.asMap().entries.map((entry) {
              final index = entry.key;
              final coupon = entry.value;
              return _buildCouponCard(coupon, isDark, index, true);
            }).toList(),
            SizedBox(height: 20.h),
          ],
          if (provider.usedCoupons.isNotEmpty) ...[
            _buildSectionHeader('الكوبونات المستخدمة', isDark, Icons.check_circle),
            SizedBox(height: 12.h),
            ...provider.usedCoupons.asMap().entries.map((entry) {
              final index = entry.key;
              final coupon = entry.value;
              return _buildCouponCard(coupon, isDark, index, false);
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.darkRed, AppColors.darkRedDark],
            ),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: Colors.white, size: 18.sp),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildCouponCard(
      CouponModel coupon,
      bool isDark,
      int index,
      bool isAvailable,
      ) {
    final bool isUsed = coupon.isUsed ?? false;
    final bool isExpired = coupon.isExpiredNow;

    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (isUsed) {
      statusText = 'مستخدم';
      statusColor = Colors.grey;
      statusIcon = Icons.check_circle;
    } else if (isExpired) {
      statusText = 'منتهي';
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    } else {
      statusText = 'متاح';
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => HapticFeedback.selectionClick(),
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          margin: EdgeInsets.only(bottom: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isAvailable && !isUsed && !isExpired
                  ? [
                AppColors.darkRed,
                AppColors.darkRedDark,
                const Color(0xFF5D0000),
              ]
                  : [
                Colors.grey.shade500,
                Colors.grey.shade600,
                Colors.grey.shade700,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: isAvailable && !isUsed && !isExpired
                    ? AppColors.darkRed.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (isUsed)
                Positioned(
                  top: 20.h,
                  right: -30.w,
                  child: Transform.rotate(
                    angle: 0.785398,
                    child: Container(
                      width: 150.w,
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700.withOpacity(0.9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: CouponPatternPainter(
                        animation: _shimmerController.value,
                        isActive: isAvailable && !isUsed && !isExpired,
                      ),
                    );
                  },
                ),
              ),
              if (isUsed || isExpired)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.discount,
                              color: AppColors.gold, size: 28.sp),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'خصم ${coupon.discountValue.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (coupon.maxDiscount != null)
                                Text(
                                  'حد أقصى ${coupon.maxDiscount!.toStringAsFixed(0)} ريال',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.white70,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: statusColor.withOpacity(0.6),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                statusIcon,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'كود الكوبون',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  coupon.code,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                    decoration: isUsed
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    decorationColor: Colors.white,
                                    decorationThickness: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isUsed && !isExpired)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  HapticFeedback.mediumImpact();
                                  await coupon.copyCode();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.check_circle,
                                                color: Colors.white),
                                            SizedBox(width: 12.w),
                                            const Text('تم نسخ الكود بنجاح'),
                                          ],
                                        ),
                                        backgroundColor: AppColors.gold,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12.r),
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(12.r),
                                child: Container(
                                  padding: EdgeInsets.all(12.r),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(Icons.copy,
                                      color: Colors.white, size: 22.sp),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Icon(
                          isUsed ? Icons.check_circle_outline : Icons.access_time,
                          color: Colors.white70,
                          size: 16.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            isUsed
                                ? 'تم الاستخدام${coupon.usedAt != null ? ' في ${DateFormat('dd/MM/yyyy', 'ar').format(coupon.usedAt!)}' : ''}'
                                : isExpired
                                ? 'منتهي الصلاحية منذ ${DateFormat('dd/MM/yyyy', 'ar').format(coupon.endDate)}'
                                : 'صالح حتى ${DateFormat('dd MMM yyyy', 'ar').format(coupon.endDate)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        if (!isUsed && !isExpired && coupon.isExpiringSoon) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: Colors.orangeAccent.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    color: Colors.orangeAccent, size: 14.sp),
                                SizedBox(width: 4.w),
                                Text(
                                  'ينتهي قريباً!',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.orangeAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate(delay: Duration(milliseconds: 100 + (index * 60)))
            .fadeIn()
            .scale(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // UTILITY WIDGETS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(60.r),
        child: Column(
          children: [
            SizedBox(
              width: 60.w,
              height: 60.h,
              child: const CircularProgressIndicator(
                color: AppColors.darkRed,
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'جاري التحميل...',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, String message, IconData icon) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(60.r),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(30.r),
              decoration: BoxDecoration(
                color: Colors.grey.shade200.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 80.sp, color: Colors.grey.shade400),
            ),
            SizedBox(height: 24.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ).animate().fadeIn().scale(),
      ),
    );
  }

  Widget _buildNotLoggedIn(bool isDark) {
    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(40.r),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.loyalty_outlined,
                  size: 100.sp, color: Colors.grey.shade400),
            ),
            SizedBox(height: 30.h),
            Text(
              'يرجى تسجيل الدخول',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.black,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'سجل دخولك للاستفادة من نقاط الولاء',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ).animate().fadeIn().scale(),
      ),
    );
  }
}
// ═══════════════════════════════════════════════════════════════
// CUSTOM PAINTERS
// ═══════════════════════════════════════════════════════════════

/// خلفية متحركة للشاشة
class LoyaltyBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDark;

  LoyaltyBackgroundPainter({
    required this.animation,
    required this.isDark,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? AppColors.gold : AppColors.darkRed)
          .withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // رسم دوائر متحركة
    for (int i = 0; i < 20; i++) {
      final offsetX =
          (size.width / 20 * i + animation.value * 100) % size.width;
      final offsetY = size.height / 10 * (i % 10) +
          math.sin(animation.value * 2 * math.pi + i) * 50;

      canvas.drawCircle(
        Offset(offsetX, offsetY),
        3 + math.sin(animation.value * 2 * math.pi + i) * 1,
        paint,
      );
    }

    // خطوط منحنية
    final linePaint = Paint()
      ..color = (isDark ? AppColors.gold : AppColors.darkRed)
          .withOpacity(0.03)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      final path = Path();
      path.moveTo(0, size.height / 5 * i);

      for (double x = 0; x <= size.width; x += 50) {
        final y = size.height / 5 * i +
            math.sin((x / size.width * math.pi * 2) +
                (animation.value * 2 * math.pi)) *
                30;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// نمط متحرك لبطاقة النقاط
class CardPatternPainter extends CustomPainter {
  final double animation;

  CardPatternPainter({this.animation = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03 + animation * 0.02)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // دوائر متداخلة
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawCircle(
        Offset(i, size.height * 0.3),
        20 + math.sin(animation * 2 * math.pi) * 3,
        paint,
      );
      canvas.drawCircle(
        Offset(i + 20, size.height * 0.7),
        15 + math.cos(animation * 2 * math.pi) * 2,
        paint,
      );
    }

    // نجوم صغيرة
    final starPaint = Paint()
      ..color = Colors.white.withOpacity(0.05 + animation * 0.03)
      ..style = PaintingStyle.fill;

    for (double i = 0; i < size.width; i += 60) {
      for (double j = 0; j < size.height; j += 60) {
        _drawStar(canvas, Offset(i, j), 3, starPaint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - math.pi / 2;
      final x = center.dx + size * math.cos(angle);
      final y = center.dy + size * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// نمط للكوبونات
class CouponPatternPainter extends CustomPainter {
  final double animation;
  final bool isActive;

  CouponPatternPainter({
    this.animation = 0,
    this.isActive = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
          .withOpacity(isActive ? 0.04 + animation * 0.02 : 0.02)
      ..style = PaintingStyle.fill;

    // نقاط متباعدة
    for (double i = 0; i < size.width; i += 35) {
      for (double j = 0; j < size.height; j += 35) {
        canvas.drawCircle(
          Offset(i, j),
          2 + (isActive ? math.sin(animation * 2 * math.pi) * 0.5 : 0),
          paint,
        );
      }
    }

    // خطوط قطرية
    if (isActive) {
      final linePaint = Paint()
        ..color = Colors.white.withOpacity(0.02 + animation * 0.01)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      for (double i = -size.height; i < size.width + size.height; i += 50) {
        canvas.drawLine(
          Offset(i, 0),
          Offset(i + size.height, size.height),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
