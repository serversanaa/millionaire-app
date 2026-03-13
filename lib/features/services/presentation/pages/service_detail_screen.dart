import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:millionaire_barber/core/routes/app_routes.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:millionaire_barber/features/favorites/presentation/providers/favorite_provider.dart';
import 'package:millionaire_barber/features/profile/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../appointments/presentation/pages/book_appointment_screen.dart';
import '../../../reviews/presentation/providers/review_provider.dart';
import '../../../reviews/presentation/widgets/reviews_section.dart';
import '../../domain/models/service_model.dart';
import '../providers/services_provider.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceModel service;

  const ServiceDetailScreen({Key? key, required this.service}) : super(key: key);

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;
  int _bookingsCount = 0;
  bool _isLoadingBookings = true;
  bool _isLoadingSimilar = true;
  List<ServiceModel> _similarServices = [];

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  /// ═══════════════════════════════════════════════════════════════
  /// INITIALIZATION
  /// ═══════════════════════════════════════════════════════════════

  void _initializeScreen() {
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadScreenData());
  }

  Future<void> _loadScreenData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

    // تحميل المفضلات
    if (userProvider.user != null) {
      favoriteProvider.fetchFavorites(userProvider.user!.id!);
    }

    // تحميل البيانات بالتوازي
    await Future.wait([
      reviewProvider.fetchServiceReviews(widget.service.id),
      _fetchBookingsCount(),
      _loadSimilarServices(),
    ]);
  }

  /// ═══════════════════════════════════════════════════════════════
  /// data FETCHING
  /// ═══════════════════════════════════════════════════════════════

  Future<void> _fetchBookingsCount() async {
    try {
      final response = await Supabase.instance.client
          .from('appointment_services')
          .select('appointment_id')
          .eq('service_id', widget.service.id);

      if (mounted) {
        setState(() {
          _bookingsCount = response.length;
          _isLoadingBookings = false;
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _bookingsCount = 0;
          _isLoadingBookings = false;
        });
      }
    }
  }

  /// ✅ تحميل الخدمات المشابهة
  Future<void> _loadSimilarServices() async {
    try {
      final servicesProvider = Provider.of<ServicesProvider>(context, listen: false);

      // جلب خدمات من نفس الفئة
      final similar = servicesProvider.services
          .where((s) =>
      s.categoryId == widget.service.categoryId &&
          s.id != widget.service.id)
          .take(4)
          .toList();

      if (mounted) {
        setState(() {
          _similarServices = similar;
          _isLoadingSimilar = false;
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSimilar = false;
        });
      }
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// HELPERS
  /// ═══════════════════════════════════════════════════════════════

  void _handleScroll() {
    if (_scrollController.offset > 200 && !_showTitle) {
      setState(() => _showTitle = true);
    } else if (_scrollController.offset <= 200 && _showTitle) {
      setState(() => _showTitle = false);
    }
  }

  String _getCategoryName() {
    try {
      final servicesProvider = Provider.of<ServicesProvider>(context, listen: false);
      final category = servicesProvider.categories.firstWhere(
            (cat) => cat.id == widget.service.categoryId,
      );
      return category.categoryNameAr ?? category.categoryName ?? 'عام';
    } catch (e) {
      return 'عام';
    }
  }

  /// ✅ مشاركة الخدمة
  Future<void> _shareService() async {
    try {
      final serviceName = widget.service.serviceNameAr ?? widget.service.serviceName ?? 'خدمة';
      final price = widget.service.price.toStringAsFixed(0);
      final duration = widget.service.durationMinutes;

      final text = '''
🌟 $serviceName

💰 السعر: $price ريال
⏱️ المدة: $duration دقيقة
📱 احجز الآن من تطبيق Millionaire Barber
      ''';

      await Share.share(
        text,
        subject: serviceName,
      );

    } catch (e) {
      _showSnackBar('حدث خطأ في المشاركة', Colors.red);
    }
  }

  Future<void> _toggleFavorite() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);

    if (userProvider.user == null) {
      _showSnackBar('يرجى تسجيل الدخول أولاً', Colors.orange);
      return;
    }

    final success = await favoriteProvider.toggleFavorite(
      userProvider.user!.id!,
      widget.service.id,
    );

    if (success && mounted) {
      final isFavorite = favoriteProvider.isFavorite(widget.service.id);
      _showSnackBar(
        isFavorite ? '❤️ تمت الإضافة للمفضلة' : '💔 تم الحذف من المفضلة',
        isFavorite ? Colors.green : Colors.orange,
      );
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// ═══════════════════════════════════════════════════════════════
  /// BUILD
  /// ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(isDark),
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildHeroImage(isDark),
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    _buildHeader(isDark),
                    SizedBox(height: 16.h),
                    _buildQuickInfo(isDark),
                    SizedBox(height: 20.h),
                    _buildDescription(isDark),
                    SizedBox(height: 20.h),
                    _buildFeatures(isDark),
                    SizedBox(height: 20.h),
                    _buildReviewsSection(isDark),
                    SizedBox(height: 20.h),
                    _buildSimilarServices(isDark),
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildFloatingBookButton(isDark),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// APP BAR
  /// ═══════════════════════════════════════════════════════════════

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: _showTitle
          ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
          : Colors.transparent,
      leading: Padding(
        padding: EdgeInsets.all(8.r),
        child: Container(
          decoration: BoxDecoration(
            color: _showTitle
                ? (isDark ? const Color(0xFF2A2A2A) : Colors.white)
                : Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
            boxShadow: _showTitle
                ? []
                : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _showTitle
                  ? (isDark ? Colors.white : AppColors.black)
                  : Colors.white,
              size: 20.sp,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      title: AnimatedOpacity(
        opacity: _showTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          widget.service.serviceNameAr ?? widget.service.serviceName ?? '',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.black,
            fontFamily: 'Cairo',
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        // ✅ زر المشاركة
        Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: Container(
            decoration: BoxDecoration(
              color: _showTitle
                  ? (isDark ? const Color(0xFF2A2A2A) : Colors.white)
                  : Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
              boxShadow: _showTitle
                  ? []
                  : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.share_rounded,
                color: _showTitle
                    ? (isDark ? Colors.white : AppColors.black)
                    : Colors.white,
                size: 20.sp,
              ),
              onPressed: _shareService,
            ),
          ),
        ),

        // زر المفضلة
        Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: Consumer<FavoriteProvider>(
            builder: (context, favoriteProvider, _) {
              final isFavorite = favoriteProvider.isFavorite(widget.service.id);

              return Container(
                decoration: BoxDecoration(
                  color: _showTitle
                      ? (isDark ? const Color(0xFF2A2A2A) : Colors.white)
                      : Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                  boxShadow: _showTitle
                      ? []
                      : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFavorite
                        ? Colors.red
                        : (_showTitle
                        ? (isDark ? Colors.white : AppColors.black)
                        : Colors.white),
                    size: 22.sp,
                  ),
                  onPressed: _toggleFavorite,
                ),
              );
            },
          ),
        ),

        SizedBox(width: 8.w),
      ],
    );
  }

// ... سأكمل في الرد التالي (Hero Image, Similar Services, إلخ)
  /// ═══════════════════════════════════════════════════════════════
  /// HERO IMAGE
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildHeroImage(bool isDark) {
    return SliverAppBar(
      expandedHeight: 350.h,
      pinned: false,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'service_${widget.service.id}',
          child: GestureDetector(  // ✅ إضافة GestureDetector
            onTap: () {
              if (widget.service.getImageUrl() != null) {
                _showFullScreenImage(context, widget.service.getImageUrl()!);
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (widget.service.getImageUrl() != null)
                  Image.network(
                    widget.service.getImageUrl()!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(isDark),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade200,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                            color: AppColors.darkRed,
                          ),
                        ),
                      );
                    },
                  )
                else
                  _buildPlaceholder(isDark),

                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),

                // ✅ أيقونة Zoom في الزاوية
                if (widget.service.getImageUrl() != null)
                  Positioned(
                    bottom: 16.h,
                    left: 16.w,
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.zoom_in_rounded,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'اضغط للتكبير',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildHeroImage(bool isDark) {
  //   return SliverAppBar(
  //     expandedHeight: 350.h,
  //     pinned: false,
  //     automaticallyImplyLeading: false,
  //     backgroundColor: Colors.transparent,
  //     flexibleSpace: FlexibleSpaceBar(
  //       background: Hero(
  //         tag: 'service_${widget.service.id}',
  //         child: Stack(
  //           fit: StackFit.expand,
  //           children: [
  //             if (widget.service.getImageUrl() != null)
  //               Image.network(
  //                 widget.service.getImageUrl()!,  // ✅
  //                 fit: BoxFit.cover,
  //                 errorBuilder: (_, __, ___) => _buildPlaceholder(isDark),
  //                 loadingBuilder: (context, child, loadingProgress) {
  //                   if (loadingProgress == null) return child;
  //                   return Container(
  //                     color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade200,
  //                     child: Center(
  //                       child: CircularProgressIndicator(
  //                         value: loadingProgress.expectedTotalBytes != null
  //                             ? loadingProgress.cumulativeBytesLoaded /
  //                             loadingProgress.expectedTotalBytes!
  //                             : null,
  //                         color: AppColors.darkRed,
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               )
  //             else
  //               _buildPlaceholder(isDark),
  //
  //             // Gradient overlay
  //             Container(
  //               decoration: BoxDecoration(
  //                 gradient: LinearGradient(
  //                   begin: Alignment.topCenter,
  //                   end: Alignment.bottomCenter,
  //                   colors: [
  //                     Colors.transparent,
  //                     Colors.black.withValues(alpha: 0.7),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildPlaceholder(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final logoSize = constraints.maxWidth * 0.8; // 30% من عرض الحاوية مثلاً

        return Container(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade200,
          child: Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: logoSize,
              height: logoSize,
              fit: BoxFit.contain,
              color: isDark
                  ? Colors.grey.shade600.withOpacity(0.9)
                  : AppColors.gold.withOpacity(0.5),
              colorBlendMode: BlendMode.modulate,
            ),
          ),
        );
      },
    );
  }


  /// ═══════════════════════════════════════════════════════════════
  /// HEADER
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.darkRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.category_rounded, size: 14.sp, color: AppColors.darkRed),
                SizedBox(width: 6.w),
                Text(
                  _getCategoryName(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkRed,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
          SizedBox(height: 12.h),
          Text(
            widget.service.serviceNameAr ?? widget.service.serviceName ?? 'خدمة',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.black,
              height: 1.3,
              fontFamily: 'Cairo',
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideX(begin: -0.2),
        ],
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// QUICK INFO CARDS
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildQuickInfo(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoCard(
              icon: Icons.access_time_rounded,
              label: 'المدة',
              value: '${widget.service.durationMinutes} دقيقة',
              color: AppColors.darkRed,
              isDark: isDark,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildInfoCard(
              icon: Icons.wallet_rounded,
              label: 'السعر',
              value: '${widget.service.price.toStringAsFixed(0)} ريال',
              color: AppColors.gold,
              isDark: isDark,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildInfoCard(
              icon: Icons.people_rounded,
              label: 'الحجوزات',
              value: _isLoadingBookings ? '...' : '$_bookingsCount+',
              color: const Color(0xFF4CAF50),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(height: 10.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
              fontFamily: 'Cairo',
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.black,
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).scale();
  }

  /// ═══════════════════════════════════════════════════════════════
  /// DESCRIPTION
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildDescription(bool isDark) {
    final description = widget.service.descriptionAr ?? widget.service.description;

    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.darkRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.description_rounded,
                    color: AppColors.darkRed,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'الوصف',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.black,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              description,
              style: TextStyle(
                fontSize: 15.sp,
                height: 1.8,
                color: isDark ? Colors.grey.shade300 : AppColors.greyDark,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// FEATURES
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildFeatures(bool isDark) {
    final features = [
      {'icon': Icons.verified_user_rounded, 'text': 'حلاقين محترفين ومدربين'},
      {'icon': Icons.stars_rounded, 'text': 'استخدام منتجات عالية الجودة'},
      {'icon': Icons.health_and_safety_rounded, 'text': 'أدوات معقمة ونظيفة'},
      {'icon': Icons.timer_rounded, 'text': 'خدمة سريعة ومريحة'},
      {'icon': Icons.refresh_rounded, 'text': 'إمكانية إعادة الحجز'},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.gold,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'المميزات',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.black,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ...features.asMap().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        entry.value['icon'] as IconData,
                        size: 16.sp,
                        color: AppColors.gold,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        entry.value['text'] as String,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: isDark ? Colors.grey.shade300 : AppColors.greyDark,
                          height: 1.5,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                )
                    .animate(delay: Duration(milliseconds: 600 + (entry.key * 100)))
                    .fadeIn()
                    .slideX(begin: -0.2),
              );
            }),
          ],
        ),
      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// REVIEWS SECTION
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildReviewsSection(bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
      child: ReviewsSection(serviceId: widget.service.id),
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2);
  }

  /// ═══════════════════════════════════════════════════════════════
  /// SIMILAR SERVICES
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildSimilarServices(bool isDark) {
    if (_isLoadingSimilar) {
      return _buildSimilarServicesShimmer(isDark);
    }

    if (_similarServices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'خدمات مشابهة',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.black,
                  fontFamily: 'Cairo',
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.services),
                child: Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.darkRed,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 200.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _similarServices.length,
              itemBuilder: (context, index) {
                final service = _similarServices[index];
                return _buildSimilarServiceCard(service, index, isDark);
              },
            ),
          ),
        ],
      ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
    );
  }

  Widget _buildSimilarServiceCard(ServiceModel service, int index, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailScreen(service: service),
          ),
        );
      },
      child: Container(
        width: 150.w,
        margin: EdgeInsets.only(left: 12.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: service.getImageUrl() != null
                    ? Image.network(
                  service.getImageUrl()!,  // ✅
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildDefaultLogo(isDark),
                )
                    : _buildDefaultLogo(isDark),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.serviceNameAr ?? service.serviceName ?? '',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.black,
                      fontFamily: 'Cairo',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '${service.price.toStringAsFixed(0)} ريال',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate(delay: Duration(milliseconds: 800 + (index * 100))).fadeIn().scale(),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _FullScreenImageViewer(imageUrl: imageUrl),
      ),
    );
  }

  Widget _buildDefaultLogo(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final logoSize = constraints.maxWidth * 0.80; // نسبة مرنة من عرض العنصر

        return Container(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200,
          child: Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: logoSize,
              height: logoSize,
              fit: BoxFit.contain,
              color:isDark ? Colors.grey.shade700 : null, // اختياري لتأثير بسيط في الوضع الليلي

              colorBlendMode: BlendMode.modulate,
            ),
          ),
        );
      },
    );
  }


  /// ✅ Shimmer للخدمات المشابهة
  Widget _buildSimilarServicesShimmer(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  height: 200.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (_, i) => Container(
                      width: 150.w,
                      margin: EdgeInsets.only(left: 12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// FLOATING BOOK BUTTON
  /// ═══════════════════════════════════════════════════════════════

  // Widget _buildFloatingBookButton(bool isDark) {
  //   return Container(
  //     padding: EdgeInsets.all(20.r),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(25.r),
  //         topRight: Radius.circular(25.r),
  //       ),
  //       color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: 0.1),
  //           blurRadius: 20,
  //           offset: const Offset(0, -5),
  //         ),
  //       ],
  //     ),
  //     child: SafeArea(
  //       child: Row(
  //         children: [
  //           Expanded(
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   'السعر الإجمالي',
  //                   style: TextStyle(
  //                     fontSize: 13.sp,
  //                     color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
  //                     fontFamily: 'Cairo',
  //                   ),
  //                 ),
  //                 SizedBox(height: 4.h),
  //                 Row(
  //                   children: [
  //                     Text(
  //                       '${widget.service.price.toStringAsFixed(0)}',
  //                       style: TextStyle(
  //                         fontSize:25.sp,
  //                         fontWeight: FontWeight.w900,
  //                         color: AppColors.gold,
  //                         fontFamily: 'Cairo',
  //                       ),
  //                     ),
  //                     SizedBox(width: 6.w),
  //                     Text(
  //                       'ريال',
  //                       style: TextStyle(
  //                         fontSize: 16.sp,
  //                         color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
  //                         fontFamily: 'Cairo',
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //           SizedBox(width: 10.w),
  //           Expanded(
  //             flex: 2,
  //             child: Container(
  //               height: 56.h,
  //               decoration: BoxDecoration(
  //                 gradient: const LinearGradient(
  //                   colors: [AppColors.darkRed, AppColors.darkRedDark],
  //                 ),
  //                 borderRadius: BorderRadius.circular(16.r),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: AppColors.darkRed.withValues(alpha: 0.4),
  //                     blurRadius: 12,
  //                     offset: const Offset(0, 6),
  //                   ),
  //                 ],
  //               ),
  //               child: ElevatedButton(
  //                 onPressed: () {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (context) => BookAppointmentScreen(service: widget.service),
  //                     ),
  //                   );
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors.transparent,
  //                   shadowColor: Colors.transparent,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(16.r),
  //                   ),
  //                 ),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Icon(Icons.calendar_today_rounded, size: 20.sp, color: Colors.white),
  //                     SizedBox(width: 10.w),
  //                     Text(
  //                       'احجز الآن',
  //                       style: TextStyle(
  //                         fontSize: 16.sp,
  //                         fontWeight: FontWeight.bold,
  //                         color: Colors.white,
  //                         fontFamily: 'Cairo',
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ).animate(onPlay: (controller) => controller.repeat())
  //                   .shimmer(duration: 2000.ms, delay: 1000.ms),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }


  // Widget _buildFloatingBookButton(bool isDark) {
  //   return Container(
  //     padding: EdgeInsets.all(20.r),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(25.r),
  //         topRight: Radius.circular(25.r),
  //       ),
  //       color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: 0.1),
  //           blurRadius: 20,
  //           offset: const Offset(0, -5),
  //         ),
  //       ],
  //     ),
  //     child: SafeArea(
  //       child: Row(
  //         children: [
  //           // ✅ قسم السعر - مع FittedBox
  //           Expanded(
  //             child: FittedBox(
  //               fit: BoxFit.scaleDown,
  //               alignment: Alignment.centerRight,
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     'السعر الإجمالي',
  //                     style: TextStyle(
  //                       fontSize: 13.sp,
  //                       color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
  //                       fontFamily: 'Cairo',
  //                     ),
  //                   ),
  //                   SizedBox(height: 4.h),
  //                   Row(
  //                     mainAxisSize: MainAxisSize.min,
  //                     crossAxisAlignment: CrossAxisAlignment.baseline,
  //                     textBaseline: TextBaseline.alphabetic,
  //                     children: [
  //                       Text(
  //                         '${widget.service.price.toStringAsFixed(0)}',
  //                         style: TextStyle(
  //                           fontSize: 22.sp,  // ✅ تصغير من 25
  //                           fontWeight: FontWeight.w900,
  //                           color: AppColors.gold,
  //                           fontFamily: 'Cairo',
  //                         ),
  //                       ),
  //                       SizedBox(width: 4.w),  // ✅ تصغير من 6
  //                       Text(
  //                         'ريال',
  //                         style: TextStyle(
  //                           fontSize: 14.sp,  // ✅ تصغير من 16
  //                           color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
  //                           fontFamily: 'Cairo',
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           SizedBox(width: 12.w),
  //
  //           // ✅ زر الحجز
  //           Expanded(
  //             flex: 2,
  //             child: Container(
  //               height: 56.h,
  //               decoration: BoxDecoration(
  //                 gradient: const LinearGradient(
  //                   colors: [AppColors.darkRed, AppColors.darkRedDark],
  //                 ),
  //                 borderRadius: BorderRadius.circular(16.r),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: AppColors.darkRed.withValues(alpha: 0.4),
  //                     blurRadius: 12,
  //                     offset: const Offset(0, 6),
  //                   ),
  //                 ],
  //               ),
  //               child: ElevatedButton(
  //                 // ✅ في buildFloatingBookButton، استبدل NavigatorPush بـ:
  //                 onPressed: () => Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (_) => BookAppointmentScreen(
  //                       services: [widget.service], // ✅ تمرير كقائمة
  //                     ),
  //                   ),
  //                 ),
  //
  //                 // onPressed: () {
  //                 //   Navigator.push(
  //                 //     context,
  //                 //     MaterialPageRoute(
  //                 //       builder: (context) =>
  //                 //
  //                 //           BookAppointmentScreen(service: widget.service),
  //                 //     ),
  //                 //   );
  //                 // },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors.transparent,
  //                   shadowColor: Colors.transparent,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(16.r),
  //                   ),
  //                 ),
  //                 child: FittedBox(  // ✅ إضافة FittedBox
  //                   fit: BoxFit.scaleDown,
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Icon(Icons.calendar_today_rounded, size: 20.sp, color: Colors.white),
  //                       SizedBox(width: 8.w),
  //                       Text(
  //                         'احجز الآن',
  //                         style: TextStyle(
  //                           fontSize: 16.sp,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.white,
  //                           fontFamily: 'Cairo',
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ).animate(onPlay: (controller) => controller.repeat())
  //                   .shimmer(duration: 2000.ms, delay: 1000.ms),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildFloatingBookButton(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // السعر
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'السعر',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Text(
                    '${widget.service.price.toStringAsFixed(0)} ريال',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
            // زر الحجز
            Expanded(
              flex: 2,
              child: Container(
                height: 56.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.darkRed, AppColors.darkRedDark],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkRed.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  // ✅ الإصلاح هنا: services بدل service
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookAppointmentScreen(
                          services: [widget.service],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 20.sp, color: Colors.white),
                        SizedBox(width: 8.w),
                        Text(
                          'احجز الآن',
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
                ).animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 2000.ms, delay: 1000.ms),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;

  const _FullScreenImageViewer({required this.imageUrl});

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  final TransformationController _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      // إذا كانت الصورة مكبرة، أرجعها للحجم الطبيعي
      _transformationController.value = Matrix4.identity();
    } else {
      // تكبير الصورة عند النقر المزدوج
      final position = _doubleTapDetails!.localPosition;
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(3.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.share_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              onPressed: () async {
                // مشاركة رابط الصورة
                await Share.share(widget.imageUrl);
              },
            ),
          ],
        ),
        body: GestureDetector(
          onDoubleTapDown: _handleDoubleTapDown,
          onDoubleTap: _handleDoubleTap,
          child: Center(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 1.0,
              maxScale: 4.0,
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                      color: AppColors.gold,
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image_rounded,
                        size: 80.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'فشل تحميل الصورة',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16.sp,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withValues(alpha: 0.8),
                Colors.transparent,
              ],
            ),
          ),
          child: SafeArea(
            child: Text(
              '✨ اسحب بإصبعين للتكبير • انقر مرتين للزووم',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ),
      ),
    );
  }
}