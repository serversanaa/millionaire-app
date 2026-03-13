import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:millionaire_barber/core/routes/app_routes.dart';
import 'package:millionaire_barber/features/appointments/presentation/pages/book_appointment_screen.dart';
import 'package:millionaire_barber/features/services/domain/models/service_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:millionaire_barber/core/constants/app_colors.dart';
import 'package:millionaire_barber/features/profile/presentation/providers/user_provider.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class OffersScreen extends StatefulWidget {
  const OffersScreen({Key? key}) : super(key: key);

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _floatingController;
  List<Map<String, dynamic>> _offers = [];
  Map<int, bool> _userUsedOffers = {};
  bool _isLoading = true;
  String _selectedFilter = 'all'; // all, active, used
  // ✅ إضافة متغير Realtime
  RealtimeChannel? _offersChannel;
  RealtimeChannel? _usageChannel;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _loadOffers();
    // ✅ الاشتراك في التحديثات الفورية
    _subscribeToOffers();
    _subscribeToUsage();

  }

  /// ═══════════════════════════════════════════════════════════════
  /// Realtime Subscriptions
  /// ═══════════════════════════════════════════════════════════════

  void _subscribeToOffers() {
    _offersChannel = Supabase.instance.client
        .channel('offers_changes')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'offers',
      callback: (payload) {
        _loadOffers(showToast: true); // ✅ إظهار Toast
      },
    )
        .subscribe();
  }


  void _subscribeToUsage() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id;

    if (userId == null) return;


    _usageChannel = Supabase.instance.client
        .channel('offer_usage_changes')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'offer_usage',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) {

        // إعادة تحميل العروض عند استخدام أي عرض
        _loadOffers();
      },
    )
        .subscribe();

  }

  void _unsubscribeFromRealtime() {
    if (_offersChannel != null) {
      _offersChannel!.unsubscribe();
      _offersChannel = null;
    }

    if (_usageChannel != null) {
      _usageChannel!.unsubscribe();
      _usageChannel = null;
    }
  }


  @override
  void dispose() {
    _shimmerController.dispose();
    _floatingController.dispose();
    // ✅ إلغاء الاشتراك عند الخروج
    _unsubscribeFromRealtime();

    super.dispose();
  }

  // Future<void> _loadOffers() async {
  //   setState(() => _isLoading = true);
  //
  //   try {
  //     final userProvider = Provider.of<UserProvider>(context, listen: false);
  //     final userId = userProvider.user?.id;
  //
  //     // جلب العروض النشطة
  //     final offersResponse = await Supabase.instance.client
  //         .from('offers')
  //         .select()
  //         .eq('is_active', true)
  //         .gte('end_date', DateTime.now().toIso8601String().split('T')[0])
  //         .order('start_date', ascending: false);
  //
  //     final offers = List<Map<String, dynamic>>.from(offersResponse as List);
  //
  //     // جلب العروض المستخدمة من قبل المستخدم
  //     if (userId != null) {
  //       final usageResponse = await Supabase.instance.client
  //           .from('offer_usage')
  //           .select('offer_id')
  //           .eq('user_id', userId);
  //
  //       final usedOfferIds = (usageResponse as List)
  //           .map((item) => item['offer_id'] as int)
  //           .toSet();
  //
  //       setState(() {
  //         _userUsedOffers = {for (var id in usedOfferIds) id: true};
  //       });
  //     }
  //
  //     setState(() {
  //       _offers = offers;
  //       _isLoading = false;
  //     });
  //
  //     print('✅ Loaded ${offers.length} offers');
  //   } catch (e) {
  //     print('❌ Error loading offers: $e');
  //     setState(() => _isLoading = false);
  //   }
  // }

  // Future<void> _loadOffers() async {
  //   // لا نغير isLoading إذا كانت إعادة تحميل (من realtime)
  //   if (_offers.isEmpty) {
  //     setState(() => _isLoading = true);
  //   }
  //
  //   try {
  //     final userProvider = Provider.of<UserProvider>(context, listen: false);
  //     final userId = userProvider.user?.id;
  //
  //     print('🔄 Loading offers...');
  //
  //     // جلب العروض النشطة
  //     final offersResponse = await Supabase.instance.client
  //         .from('offers')
  //         .select()
  //         .eq('is_active', true)
  //         .gte('end_date', DateTime.now().toIso8601String().split('T')[0])
  //         .order('start_date', ascending: false);
  //
  //     final offers = List<Map<String, dynamic>>.from(offersResponse as List);
  //
  //     print('📊 Loaded ${offers.length} offers');
  //
  //     // جلب العروض المستخدمة من قبل المستخدم
  //     Map<int, bool> usedOffers = {};
  //     if (userId != null) {
  //       final usageResponse = await Supabase.instance.client
  //           .from('offer_usage')
  //           .select('offer_id')
  //           .eq('user_id', userId);
  //
  //       final usedOfferIds = (usageResponse as List)
  //           .map((item) => item['offer_id'] as int)
  //           .toSet();
  //
  //       usedOffers = {for (var id in usedOfferIds) id: true};
  //
  //       print('📊 User used ${usedOffers.length} offers');
  //     }
  //
  //     if (mounted) {
  //       setState(() {
  //         _offers = offers;
  //         _userUsedOffers = usedOffers;
  //         _isLoading = false;
  //       });
  //     }
  //
  //     print('✅ Offers loaded successfully');
  //   } catch (e) {
  //     print('❌ Error loading offers: $e');
  //     if (mounted) {
  //       setState(() => _isLoading = false);
  //     }
  //   }
  // }



  /// ═══════════════════════════════════════════════════════════════
  /// تحميل العروض من قاعدة البيانات
  /// ═══════════════════════════════════════════════════════════════

  Future<void> _loadOffers({bool showToast = false}) async {
    // ✅ إذا كانت القائمة فارغة، نعرض مؤشر التحميل
    if (_offers.isEmpty) {
      if (mounted) {
        setState(() => _isLoading = true);
      }
    } else if (showToast && mounted) {
      // ✅ إظهار رسالة عند التحديث التلقائي (من Realtime)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.refresh_rounded, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              const Text('تم تحديث العروض'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.r),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
    }

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.id;


      // ✅ 1️⃣ جلب العروض النشطة والصالحة
      final offersResponse = await Supabase.instance.client
          .from('offers')
          .select()
          .eq('is_active', true)
          .gte('end_date', DateTime.now().toIso8601String().split('T')[0])
          .order('start_date', ascending: false);

      final offers = List<Map<String, dynamic>>.from(offersResponse as List);


      // ✅ 2️⃣ جلب العروض المستخدمة من قبل المستخدم
      Map<int, bool> usedOffers = {};

      if (userId != null) {
        try {
          final usageResponse = await Supabase.instance.client
              .from('offer_usage')
              .select('offer_id')
              .eq('user_id', userId);

          final usedOfferIds = (usageResponse as List)
              .map((item) => item['offer_id'] as int)
              .toSet();

          usedOffers = {for (var id in usedOfferIds) id: true};

        } catch (e) {
          // نستمر حتى لو فشل جلب الاستخدام
        }
      } else {
      }

      // ✅ 3️⃣ تحديث الحالة
      if (mounted) {
        setState(() {
          _offers = offers;
          _userUsedOffers = usedOffers;
          _isLoading = false;
        });
      }


    } catch (e) {

      if (mounted) {
        setState(() => _isLoading = false);

        // ✅ إظهار رسالة خطأ للمستخدم
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'فشل تحميل العروض. يرجى المحاولة مرة أخرى',
                    style: TextStyle(fontSize: 13.sp),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16.r),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            action: SnackBarAction(
              label: 'إعادة المحاولة',
              textColor: Colors.white,
              onPressed: () => _loadOffers(),
            ),
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredOffers {
    if (_selectedFilter == 'all') return _offers;
    if (_selectedFilter == 'active') {
      return _offers.where((offer) => !_userUsedOffers.containsKey(offer['id'])).toList();
    }
    return _offers.where((offer) => _userUsedOffers.containsKey(offer['id'])).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA),
        body: Stack(
          children: [
            // خلفية متحركة
            _buildAnimatedBackground(isDark),

            // المحتوى
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(isDark),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      _buildFilterTabs(isDark),
                      SizedBox(height: 20.h),
                      if (_isLoading)
                        _buildLoadingState()
                      else if (_filteredOffers.isEmpty)
                        _buildEmptyState(isDark)
                      else
                        _buildOffersList(isDark),
                      SizedBox(height: 100.h),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// خلفية متحركة
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildAnimatedBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return CustomPaint(
          painter: OffersBackgroundPainter(
            animation: _floatingController,
            isDark: isDark,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// AppBar
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 160.h,
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
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: isDark
                    ? [
                  const Color(0xFF1A1A1A).withValues(alpha:0.95),
                  const Color(0xFF0A0A0A).withValues(alpha:0.9),
                ]
                    : [
                  Colors.white.withValues(alpha:0.95),
                  Colors.white.withValues(alpha:0.9),
                ],
              ),
            ),
            child: FlexibleSpaceBar(
              centerTitle: true,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.darkRed, AppColors.darkRedDark],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkRed.withValues(alpha:0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(Icons.local_offer_rounded, color: Colors.white, size: 20.sp),
                  ).animate(onPlay: (c) => c.repeat())
                      .shimmer(duration: 2000.ms)
                      .rotate(begin: -0.05, end: 0.05, duration: 1000.ms),
                  SizedBox(width: 12.w),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.darkRed, AppColors.darkRedDark],
                    ).createShader(bounds),
                    child: Text(
                      'العروض الخاصة',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      leading: Padding(
        padding: EdgeInsets.all(8.r),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha:0.1)
                : Colors.black.withValues(alpha:0.05),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : AppColors.black,
              size: 20.sp,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        // ✅ مؤشر الاتصال الفوري
        Padding(
          padding: EdgeInsets.all(8.r),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha:0.1)
                  : Colors.black.withValues(alpha:0.05),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                color: isDark ? Colors.white : AppColors.black,
                size: 22.sp,
              ),
              onPressed: _loadOffers,
            ),
          ),
        ),
      ],

    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// Filter Tabs
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildFilterTabs(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(5.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildFilterTab('الكل', 'all', isDark),
            _buildFilterTab('متاحة', 'active', isDark),
            _buildFilterTab('مستخدمة', 'used', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String title, String filter, bool isDark) {
    final isSelected = _selectedFilter == filter;
    int count = 0;

    if (filter == 'all') {
      count = _offers.length;
    } else if (filter == 'active') {
      count = _offers.where((o) => !_userUsedOffers.containsKey(o['id'])).length;
    } else {
      count = _offers.where((o) => _userUsedOffers.containsKey(o['id'])).length;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = filter),
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
                color: AppColors.darkRed.withValues(alpha:0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ]
                : [],
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
              if (count > 0) ...[
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha:0.2)
                        : Colors.grey.withValues(alpha:0.2),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 10.sp,
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
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// Offers List
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildOffersList(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: _filteredOffers.asMap().entries.map((entry) {
          final index = entry.key;
          final offer = entry.value;
          return _buildOfferCard(offer, isDark, index);
        }).toList(),
      ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer, bool isDark, int index) {
    final offerId = offer['id'] as int;
    final title = offer['title_ar'] as String;
    final description = offer['description_ar'] as String?;
    final discountType = offer['discount_type'] as String;
    final discountValue = (offer['discount_value'] as num).toDouble();
    final minPurchase = (offer['min_purchase_amount'] as num?)?.toDouble() ?? 0;
    final imageUrl = offer['image_url'] as String?;
    final promoCode = offer['promo_code'] as String?;
    final startDate = DateTime.parse(offer['start_date'] as String);
    final endDate = DateTime.parse(offer['end_date'] as String);

    final isUsed = _userUsedOffers.containsKey(offerId);
    final daysLeft = endDate.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysLeft <= 3 && daysLeft > 0;

    return GestureDetector(
      onTap: () => _showOfferDetails(offer, isDark),
      child: Container(
        margin: EdgeInsets.only(bottom: 20.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: isUsed
                  ? Colors.grey.withValues(alpha:0.2)
                  : AppColors.darkRed.withValues(alpha:0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Stack(
            children: [
              // الخلفية
              Container(
                height: 200.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isUsed
                        ? [Colors.grey.shade300, Colors.grey.shade400]
                        : [
                      AppColors.darkRed,
                      AppColors.darkRedDark,
                    ],
                  ),
                ),
              ),

              // الصورة
              if (imageUrl != null)
                Positioned.fill(
                  child: Opacity(
                    opacity: isUsed ? 0.5 : 0.3,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade800,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade800,
                        child: Icon(Icons.image_not_supported, size: 40.sp, color: Colors.white),
                      ),
                    ),
                  ),
                ),

              // النمط الهندسي
              Positioned.fill(
                child: CustomPaint(
                  painter: OfferPatternPainter(isUsed: isUsed),
                ),
              ),

              // المحتوى
              Positioned.fill(
                child: Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha:0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Badge الخصم
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: isUsed ? Colors.grey : AppColors.gold,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: (isUsed ? Colors.grey : AppColors.gold)
                                      .withValues(alpha:0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Text(
                              _getDiscountText(discountType, discountValue),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // حالة العرض
                          if (isUsed)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white, size: 14.sp),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'مستخدم',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (isExpiringSoon)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time, color: Colors.white, size: 14.sp),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'ينتهي قريباً',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ).animate(onPlay: (c) => c.repeat())
                                .shimmer(duration: 1500.ms),
                        ],
                      ),
                      const Spacer(),
                      // العنوان والوصف
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha:0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (description != null && description.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white.withValues(alpha:0.9),
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha:0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: 12.h),
                      // معلومات إضافية
                      Row(
                        children: [
                          if (promoCode != null) ...[
                            Icon(Icons.local_offer_outlined, color: Colors.white70, size: 14.sp),
                            SizedBox(width: 4.w),
                            Text(
                              promoCode,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(width: 12.w),
                          ],
                          if (minPurchase > 0) ...[
                            Icon(Icons.shopping_cart_outlined, color: Colors.white70, size: 14.sp),
                            SizedBox(width: 4.w),
                            Text(
                              'من ${minPurchase.toInt()} ر.ي',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                              ),
                            ),
                          ],
                          const Spacer(),
                          Icon(Icons.access_time, color: Colors.white70, size: 14.sp),
                          SizedBox(width: 4.w),
                          Text(
                            'باقي $daysLeft يوم',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate(delay: Duration(milliseconds: 200 + (index * 100)))
          .fadeIn()
          .slideY(begin: 0.3)
          .scale(begin: const Offset(0.9, 0.9)),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// تفاصيل العرض
  /// ═══════════════════════════════════════════════════════════════

  void _showOfferDetails(Map<String, dynamic> offer, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildOfferDetailsSheet(offer, isDark),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// تفاصيل العرض - Bottom Sheet محسّن
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildOfferDetailsSheet(Map<String, dynamic> offer, bool isDark) {
    final offerId = offer['id'] as int;
    final title = offer['title_ar'] as String;
    final description = offer['description_ar'] as String?;
    final discountType = offer['discount_type'] as String;
    final discountValue = (offer['discount_value'] as num).toDouble();
    final minPurchase = (offer['min_purchase_amount'] as num?)?.toDouble() ?? 0;
    final maxDiscount = (offer['max_discount_amount'] as num?)?.toDouble();
    final promoCode = offer['promo_code'] as String?;
    final startDate = DateTime.parse(offer['start_date'] as String);
    final endDate = DateTime.parse(offer['end_date'] as String);
    final isUsed = _userUsedOffers.containsKey(offerId);
    final usageLimit = offer['usage_limit'] as int?;
    final currentUsage = offer['current_usage'] as int? ?? 0;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            SizedBox(height: 20.h),

            // المحتوى
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الخصم
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(24.r),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isUsed
                                ? [Colors.grey, Colors.grey.shade700]
                                : [AppColors.darkRed, AppColors.darkRedDark],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isUsed ? Colors.grey : AppColors.darkRed)
                                  .withValues(alpha:0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Text(
                          _getDiscountText(discountType, discountValue),
                          style: TextStyle(
                            fontSize: 36.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ).animate().scale(delay: 100.ms, curve: Curves.elasticOut),
                    ),

                    SizedBox(height: 30.h),

                    // العنوان
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.black,
                      ),
                    ),

                    if (description != null && description.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                    ],

                    SizedBox(height: 24.h),

                    // التفاصيل
                    _buildDetailRow(
                      icon: Icons.calendar_today_rounded,
                      title: 'صالح من',
                      value: '${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}',
                      isDark: isDark,
                    ),

                    if (minPurchase > 0) ...[
                      SizedBox(height: 16.h),
                      _buildDetailRow(
                        icon: Icons.shopping_cart_outlined,
                        title: 'الحد الأدنى للشراء',
                        value: '${minPurchase.toInt()} ر.س',
                        isDark: isDark,
                      ),
                    ],

                    if (maxDiscount != null) ...[
                      SizedBox(height: 16.h),
                      _buildDetailRow(
                        icon: Icons.savings_outlined,
                        title: 'أقصى خصم',
                        value: '${maxDiscount.toInt()} ر.س',
                        isDark: isDark,
                      ),
                    ],

                    if (usageLimit != null) ...[
                      SizedBox(height: 16.h),
                      _buildDetailRow(
                        icon: Icons.people_outline,
                        title: 'عدد الاستخدامات',
                        value: '$currentUsage / $usageLimit',
                        isDark: isDark,
                      ),
                    ],

                    if (promoCode != null) ...[
                      SizedBox(height: 24.h),
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha:0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_offer_rounded, color: AppColors.gold),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'كود الخصم',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    promoCode,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkRed,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _copyPromoCode(promoCode),
                              icon: const Icon(Icons.copy_rounded, color: AppColors.darkRed),
                              tooltip: 'نسخ الكود',
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (isUsed) ...[
                      SizedBox(height: 24.h),
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Colors.green.withValues(alpha:0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'لقد استخدمت هذا العرض من قبل',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
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
            ),

            // ✨ الأزرار المحسّنة
            _buildBottomSheetActions(offer, promoCode, isUsed, isDark),
          ],
        ),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// أزرار Bottom Sheet
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildBottomSheetActions(
      Map<String, dynamic> offer,
      String? promoCode,
      bool isUsed,
      bool isDark,
      ) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : Colors.grey.shade50,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha:0.1) : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          // ✅ زر نسخ الكود (إذا كان متوفراً)
          if (promoCode != null && !isUsed) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _copyPromoCode(promoCode),
                icon: Icon(Icons.copy_rounded, size: 18.sp),
                label: const Text('نسخ الكود'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  side: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha:0.3) : Colors.grey.shade300,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
          ],

          // ✅ زر المشاركة
          if (!isUsed) ...[
            OutlinedButton(
              onPressed: () => _shareOffer(offer),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                side: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha:0.3) : Colors.grey.shade300,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Icon(
                Icons.share_rounded,
                size: 20.sp,
                color: isDark ? Colors.white : AppColors.black,
              ),
            ),
            SizedBox(width: 12.w),
          ],

          // ✅ الزر الرئيسي
          Expanded(
            flex: isUsed ? 1 : 2,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                if (!isUsed) {
                  _applyOffer(offer);
                }
              },
              icon: Icon(
                isUsed ? Icons.check_rounded : Icons.calendar_today_rounded,
                size: 20.sp,
              ),
              label: Text(
                isUsed ? 'حسناً' : 'احجز الآن',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isUsed ? Colors.grey : AppColors.darkRed,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// نسخ كود الخصم
  /// ═══════════════════════════════════════════════════════════════

  void _copyPromoCode(String promoCode) {
    Clipboard.setData(ClipboardData(text: promoCode));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text('تم نسخ الكود: $promoCode'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.r),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// مشاركة العرض
  /// ═══════════════════════════════════════════════════════════════

  void _shareOffer(Map<String, dynamic> offer) {
    final title = offer['title_ar'] as String;
    final promoCode = offer['promo_code'] as String?;
    final discountType = offer['discount_type'] as String;
    final discountValue = (offer['discount_value'] as num).toDouble();

    final discountText = _getDiscountText(discountType, discountValue);

    String shareText = '🎉 عرض خاص: $title\n';
    shareText += '💰 خصم: $discountText\n';

    if (promoCode != null) {
      shareText += '🏷️ الكود: $promoCode\n';
    }

    shareText += '\nاحجز الآن من تطبيق Millionaire Barber! 💈';

    // TODO: استخدم share_plus package
    // Share.share(shareText);

    // مؤقتاً: نسخ النص
    Clipboard.setData(ClipboardData(text: shareText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.share, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            const Expanded(
              child: Text('تم نسخ تفاصيل العرض للمشاركة'),
            ),
          ],
        ),
        backgroundColor: AppColors.darkRed,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.r),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// تطبيق العرض والانتقال للحجز
  /// ═══════════════════════════════════════════════════════════════

  // void _applyOffer(Map<String, dynamic> offer) {
  //   final promoCode = offer['promo_code'] as String?;
  //   final title = offer['title_ar'] as String;
  //   final offerId = offer['id'] as int;
  //
  //   print('✅ Applying offer: $title (ID: $offerId)');
  //   print('   Promo Code: $promoCode');
  //
  //   // ✅ الانتقال إلى صفحة الحجز مع العرض المطبق
  //   Navigator.pushNamed(
  //     context,
  //     '/appointments', // أو المسار الصحيح
  //     arguments: {
  //       'applied_offer': offer,
  //       'offer_id': offerId,
  //       'promo_code': promoCode,
  //     },
  //   );
  //
  //   // مؤقتاً: عرض رسالة
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Row(
  //         children: [
  //           Icon(Icons.celebration, color: Colors.white, size: 20.sp),
  //           SizedBox(width: 8.w),
  //           Expanded(
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   'تم تطبيق العرض!',
  //                   style: TextStyle(
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 14.sp,
  //                   ),
  //                 ),
  //                 if (promoCode != null)
  //                   Text(
  //                     'الكود: $promoCode',
  //                     style: TextStyle(fontSize: 12.sp),
  //                   ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //       backgroundColor: Colors.green,
  //       duration: const Duration(seconds: 3),
  //       behavior: SnackBarBehavior.floating,
  //       margin: EdgeInsets.all(16.r),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(12.r),
  //       ),
  //     ),
  //   );
  // }


  void _applyOffer(Map<String, dynamic> offer) {
    final promoCode = offer['promo_code'] as String?;
    final title = offer['title_ar'] as String;
    final offerId = offer['id'] as int;


    // ✅ عرض dialog لاختيار الخدمة
    _showSelectServiceDialog(offer, offerId, promoCode);
  }

  /// ═══════════════════════════════════════════════════════════════
  /// Dialog اختيار الخدمة
  /// ═══════════════════════════════════════════════════════════════

  void _showSelectServiceDialog(
      Map<String, dynamic> offer,
      int offerId,
      String? promoCode,
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.darkRed.withValues(alpha:0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.content_cut_rounded, color: AppColors.darkRed, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'اختر الخدمة',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: isDark ? Colors.white : AppColors.black,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'يرجى اختيار الخدمة التي تريد حجزها مع هذا العرض',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 20.h),

              // ✅ زر الانتقال للخدمات
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);

                  // الانتقال لصفحة الخدمات واستقبال الخدمة المختارة
                  final selectedService = await Navigator.pushNamed(
                    context,
                    '/services',
                    arguments: {
                      'select_mode': true, // وضع الاختيار
                      'applied_offer': offer,
                      'offer_id': offerId,
                      'promo_code': promoCode,
                    },
                  );

                  // إذا تم اختيار خدمة
                  if (selectedService != null && selectedService is ServiceModel) {
                    _navigateToBookingWithOffer(
                      selectedService,
                      offer,
                      offerId,
                      promoCode,
                    );
                  }
                },
                icon: Icon(Icons.arrow_forward_rounded, size: 20.sp),
                label: Text('اختر خدمة', style: TextStyle(fontSize: 15.sp)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkRed,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// الانتقال للحجز مع العرض
  /// ═══════════════════════════════════════════════════════════════

  void _navigateToBookingWithOffer(
      ServiceModel service,
      Map<String, dynamic> offer,
      int offerId,
      String? promoCode,
      ) {

    // ✅ الانتقال مع arguments
    Navigator.push(
      context,
      MaterialPageRoute(
        // builder: (context) => BookAppointmentScreen(service: service),
        builder: (context) => BookAppointmentScreen(services: [service]),
        settings: RouteSettings(
          arguments: {
            'applied_offer': offer,
            'offer_id': offerId,
            'promo_code': promoCode,
          },
        ),
      ),
    );
  }


  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: AppColors.darkRed.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: AppColors.darkRed, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// حالات خاصة
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(60.r),
        child: Column(
          children: [
            const CircularProgressIndicator(color: AppColors.darkRed),
            SizedBox(height: 20.h),
            Text(
              'جارٍ تحميل العروض...',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(60.r),
        child: Column(
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 100.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 20.h),
            Text(
              _selectedFilter == 'used'
                  ? 'لم تستخدم أي عروض بعد'
                  : 'لا توجد عروض متاحة حالياً',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// دوال مساعدة
  /// ═══════════════════════════════════════════════════════════════

  String _getDiscountText(String type, double value) {
    if (type == 'percentage') {
      return '${value.toInt()}%';
    } else if (type == 'fixed_amount') {
      return '${value.toInt()} ر.ي';
    } else {
      return 'x${value.toStringAsFixed(1)}';
    }
  }
}

/// ═══════════════════════════════════════════════════════════════
/// Custom Painters
/// ═══════════════════════════════════════════════════════════════

class OffersBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDark;

  OffersBackgroundPainter({required this.animation, required this.isDark})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? AppColors.darkRed : AppColors.gold).withValues(alpha:0.08);

    for (int i = 0; i < 20; i++) {
      final offset = Offset(
        (size.width / 20 * i + animation.value * 100) % size.width,
        size.height / 10 * (i % 10) + math.sin(animation.value * 2 * math.pi + i) * 50,
      );
      canvas.drawCircle(offset, 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class OfferPatternPainter extends CustomPainter {
  final bool isUsed;

  OfferPatternPainter({required this.isUsed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha:isUsed ? 0.05 : 0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawCircle(Offset(i, size.height * 0.3), 20, paint);
      canvas.drawCircle(Offset(i + 20, size.height * 0.7), 15, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}