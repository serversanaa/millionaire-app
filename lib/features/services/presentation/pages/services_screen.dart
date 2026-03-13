import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:millionaire_barber/features/appointments/presentation/pages/book_appointment_screen.dart';
import 'package:millionaire_barber/features/favorites/presentation/providers/favorite_provider.dart';
import 'package:millionaire_barber/features/profile/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/service_model.dart';
import '../providers/services_provider.dart';
import 'service_detail_screen.dart';


enum SortOption {
  none,
  priceLowToHigh,
  priceHighToLow,
  rating,
  mostPopular,
  duration,
}


class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _animationController;

  // ✅ متغيرات العروض
  bool _isSelectMode = false;
  Map<String, dynamic>? _offerData;
  bool _hasCheckedArguments = false;
  bool _isLoading = true; // ✅ إضافة Loading State

  // ✅ متغيرات الفلترة والترتيب
  SortOption _currentSortOption = SortOption.none;
  double _minPrice = 0;
  double _maxPrice = 0;
  double _selectedMinPrice = 0;
  double _selectedMaxPrice = 0;
  bool _showFilterSheet = false;


  // ✅ متغيرات التحديد المتعدد (أضفها مع باقي المتغيرات)
  final Set<int> _selectedServiceIds = {};

  List<ServiceModel> get _selectedServicesList {
    final provider = Provider.of<ServicesProvider>(context, listen: false);
    return provider.services
        .where((s) => _selectedServiceIds.contains(s.id))
        .toList();
  }


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });

  }
  /// ✅ حساب نطاق الأسعار


  /// ✅ تحميل البيانات مع Loading
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final servicesProvider = Provider.of<ServicesProvider>(context, listen: false);

      await Future.wait([
        if (servicesProvider.categories.isEmpty) servicesProvider.fetchCategories(),
        if (servicesProvider.services.isEmpty) servicesProvider.fetchServices(),
      ]);
      if (mounted) {
        _calculatePriceRange(servicesProvider.services);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في تحميل البيانات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
  }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasCheckedArguments) {
      _hasCheckedArguments = true;

      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;


      if (args != null && args['select_mode'] == true) {
        setState(() {
          _isSelectMode = true;
          _offerData = args;
        });

      } else {
      }
    }
    // ✅ حساب نطاق الأسعار إذا كانت الخدمات محملة
    final servicesProvider = Provider.of<ServicesProvider>(context, listen: false);
    if (servicesProvider.services.isNotEmpty && _maxPrice == 0) {
      _calculatePriceRange(servicesProvider.services);
    }
}

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// ✅ فلترة وترتيب الخدمات
  /// ✅ فلترة وترتيب الخدمات (مصحّح)
  List<ServiceModel> _filterServices(List<ServiceModel> services) {
    var filtered = services;

    // 1. البحث
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((service) {
        final serviceName = (service.serviceNameAr ?? service.serviceName ?? '').toLowerCase();
        final description = (service.descriptionAr ?? service.description ?? '').toLowerCase();
        return serviceName.contains(_searchQuery.toLowerCase()) ||
            description.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // 2. فلترة حسب السعر
    filtered = filtered.where((service) {
      return service.price >= _selectedMinPrice && service.price <= _selectedMaxPrice;
    }).toList();

    // 3. الترتيب
    switch (_currentSortOption) {
      case SortOption.priceLowToHigh:
      // من الأرخص للأغلى
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;

      case SortOption.priceHighToLow:
      // من الأغلى للأرخص
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;

      case SortOption.rating:
      // ✅ إصلاح: استخدام حقل موجود أو ترك الترتيب الافتراضي
      // إذا كان لديك حقل rating في ServiceModel استخدمه، وإلا اتركه
      // filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;

      case SortOption.mostPopular:
      // ✅ إصلاح: يمكن الترتيب حسب عدد المشاهدات أو اسم الخدمة
      // filtered.sort((a, b) => (b.viewsCount ?? 0).compareTo(a.viewsCount ?? 0));
        break;

      case SortOption.duration:
      // ترتيب حسب المدة
        filtered.sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
        break;

      case SortOption.none:
      // الترتيب الافتراضي (حسب ID)
        break;
    }

    return filtered;
  }



  /// ✅ حساب نطاق الأسعار (ديناميكي 100%)
  void _calculatePriceRange(List<ServiceModel> services) {
    if (services.isEmpty) {
      _minPrice = 0;
      _maxPrice = 0;
      _selectedMinPrice = 0;
      _selectedMaxPrice = 0;
      return;
    }

    try {
      // استخراج جميع الأسعار
      final prices = services.map((s) => s.price).toList();

      // حساب الحد الأدنى والأعلى
      _minPrice = prices.reduce((a, b) => a < b ? a : b);
      _maxPrice = prices.reduce((a, b) => a > b ? a : b);

      // التأكد من وجود فرق في الأسعار
      if (_minPrice == _maxPrice) {
        _minPrice = (_minPrice * 0.9).floorToDouble();
        _maxPrice = (_maxPrice * 1.1).ceilToDouble();
      }

      // التأكد من أن الحد الأدنى ليس أقل من صفر
      if (_minPrice < 0) _minPrice = 0;

      // ✅ تعيين القيم المختارة الافتراضية فقط في المرة الأولى
      if (_selectedMinPrice == 0 && _selectedMaxPrice == 0) {
        _selectedMinPrice = _minPrice;
        _selectedMaxPrice = _maxPrice;
      } else {
        // إذا كانت القيم موجودة، تأكد أنها ضمن النطاق الجديد
        if (_selectedMinPrice < _minPrice) _selectedMinPrice = _minPrice;
        if (_selectedMaxPrice > _maxPrice) _selectedMaxPrice = _maxPrice;
      }

    } catch (e) {
      _minPrice = 0;
      _maxPrice = 0;
      _selectedMinPrice = 0;
      _selectedMaxPrice = 0;
    }
  }



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        body: _isLoading
            ? _buildShimmerLoading(isDark) // ✅ Shimmer Loading
            : _buildContent(isDark),
        bottomNavigationBar: _selectedServiceIds.isNotEmpty && !_isSelectMode
            ? _buildMultiBookingBar(isDark)
            : null,
      ),
    );
  }
  Widget _buildMultiBookingBar(bool isDark) {
    final count      = _selectedServiceIds.length;
    final totalPrice = _selectedServicesList.fold(0.0, (s, srv) => s + srv.price);

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),
            blurRadius: 10, offset: const Offset(0, -2))],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // عداد الخدمات
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.darkRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.darkRed.withOpacity(0.3)),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('$count', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold,
                    color: AppColors.darkRed, fontFamily: 'Cairo')),
                Text('خدمات', style: TextStyle(fontSize: 11.sp,
                    color: Colors.grey.shade500, fontFamily: 'Cairo')),
              ]),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الإجمالي', style: TextStyle(fontSize: 12.sp,
                      color: Colors.grey.shade500, fontFamily: 'Cairo')),
                  Text('${totalPrice.toStringAsFixed(0)} ر.ي',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold,
                          color: AppColors.gold, fontFamily: 'Cairo')),
                ],
              ),
            ),
            // زر الحجز
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookAppointmentScreen(
                      services: _selectedServicesList,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.calendar_today_rounded, size: 18.sp),
              label: Text('احجز الآن', style: TextStyle(fontSize: 15.sp,
                  fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkRed,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 1.0).fadeIn();
  }

  /// ✅ Shimmer Loading
  Widget _buildShimmerLoading(bool isDark) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 120.h,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.darkRed.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.arrow_back_ios, size: 18.sp, color: AppColors.darkRed),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ];
      },
      body: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Search Shimmer
              Container(
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              SizedBox(height: 16.h),

              // Categories Shimmer
              SizedBox(
                height: 50.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (_, i) => Container(
                    width: 100.w,
                    margin: EdgeInsets.only(left: 8.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Services Grid Shimmer
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: 6,
                  itemBuilder: (_, i) => Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ المحتوى الرئيسي
  Widget _buildContent(bool isDark) {
    final servicesProvider = Provider.of<ServicesProvider>(context);
    final filteredServices = _filterServices(servicesProvider.services);

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          _buildModernAppBar(innerBoxIsScrolled, isDark),
        ];
      },
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _isLoading = true);
          await servicesProvider.refresh();
          setState(() => _isLoading = false);
        },
        color: AppColors.darkRed,
        child: CustomScrollView(
          slivers: [
            // ✅ بطاقة العرض في الأعلى
            if (_isSelectMode && _offerData != null)
              SliverToBoxAdapter(child: _buildOfferBanner(isDark)),
            SliverToBoxAdapter(child: _buildMultiSelectHint(isDark)),
            SliverToBoxAdapter(child: _buildSearchSection(isDark)),
            SliverToBoxAdapter(child: _buildCategoriesSection(servicesProvider, isDark)),
            SliverToBoxAdapter(child: _buildResultsCount(filteredServices.length, isDark)),

            // ✅ عرض الخدمات
            filteredServices.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState(isDark))
                : SliverPadding(
              padding: EdgeInsets.all(16.w),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final service = filteredServices[index];
                    return _buildModernServiceCard(service, index, isDark);
                  },
                  childCount: filteredServices.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ بطاقة العرض في الأعلى
  Widget _buildOfferBanner(bool isDark) {
    final offer = _offerData!['applied_offer'] as Map<String, dynamic>;
    final title = offer['title_ar'] as String;

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gold, AppColors.goldDark],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha:0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_offer_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اختر خدمة لتطبيق العرض 🎉',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha:0.9),
                    fontFamily: 'Cairo',
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.3);
  }


  /// ✅ Modern AppBar - كامل ومحدث
  Widget _buildModernAppBar(bool innerBoxIsScrolled, bool isDark) {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,

      // ✅ زر الرجوع
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.darkRed.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.arrow_back_ios,
            size: 18.sp,
            color: AppColors.darkRed,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),

      // ✅ الأزرار في الأعلى (Actions)
      actions: [
        // زر الفلترة (فقط في الوضع العادي)
        if (!_isSelectMode)
          Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.darkRed.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 20.sp,
                      color: AppColors.darkRed,
                    ),
                  ),

                  // ✅ Badge للإشارة أن هناك فلتر نشط
                  if (_isFilterActive())
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () => _showFilterBottomSheet(isDark),
            ),
          ),

        // ✅ زر العرض النشط (في وضع الاختيار)
        if (_isSelectMode)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_offer_rounded,
                    size: 16.sp,
                    color: Colors.white,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'عرض نشط',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ✅ مسافة من الحافة
        SizedBox(width: 8.w),
      ],

      // ✅ المحتوى المرن (FlexibleSpace)
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(right: 16.w, bottom: 16.h),

        // العنوان عند التمرير
        title: AnimatedOpacity(
          opacity: innerBoxIsScrolled ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Text(
            _isSelectMode ? 'اختر خدمة' : 'الخدمات',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.black,
              fontFamily: 'Cairo',
            ),
          ),
        ),

        // ✅ الخلفية مع المحتوى
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: isDark
                  ? [
                const Color(0xFF1E1E1E),
                const Color(0xFF2A2A2A),
              ]
                  : [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // العنوان الرئيسي
                  Text(
                    _isSelectMode ? 'اختر خدمة' : 'استكشف',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.black,
                      fontFamily: 'Cairo',
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),

                  SizedBox(height: 4.h),

                  // النص الوصفي
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isSelectMode
                              ? 'اضغط على الخدمة لتطبيق العرض'
                              : 'اختر الخدمة المناسبة لك',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                            fontFamily: 'Cairo',
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                      ),

                      // ✅ عرض عدد الفلاتر النشطة
                      if (!_isSelectMode && _isFilterActive())
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.darkRed.withValues(alpha:0.15),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.filter_alt,
                                size: 14.sp,
                                color: AppColors.darkRed,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'فلتر نشط',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkRed,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ التحقق من وجود فلتر نشط
  bool _isFilterActive() {
    return _currentSortOption != SortOption.none ||
        (_selectedMinPrice > _minPrice || _selectedMaxPrice < _maxPrice);
  }


  Widget _buildMultiSelectHint(bool isDark) {
    // ✅ يختفي تلقائياً بعد تحديد أول خدمة
    if (_selectedServiceIds.isNotEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.touch_app_rounded, color: AppColors.gold, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              '💡 اضغط مطولاً على أي خدمة لتحديد أكثر من خدمة معاً',
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                fontFamily: 'Cairo',
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: -0.2);
  }

  /// ✅ Search Section
  Widget _buildSearchSection(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
        child: TextField(
          controller: _searchController,
          textDirection: TextDirection.rtl,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.black,
            fontFamily: 'Cairo',
          ),
          decoration: InputDecoration(
            hintText: 'ابحث عن خدمة...',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey.shade600 : AppColors.greyMedium,
              fontFamily: 'Cairo',
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: isDark ? Colors.grey.shade600 : AppColors.greyMedium,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
              icon: Icon(
                Icons.clear_rounded,
                color: isDark ? Colors.grey.shade600 : AppColors.greyMedium,
              ),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          ),
        ),
      ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.2),
    );
  }

  /// ✅ Categories Section
  Widget _buildCategoriesSection(ServicesProvider servicesProvider, bool isDark) {
    if (servicesProvider.categories.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 50.h,
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: servicesProvider.categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = servicesProvider.selectedCategoryId == null;
            return _buildModernCategoryChip('الكل', isSelected, () {
              servicesProvider.filterByCategory(null);
            }, index, isDark);
          }

          final category = servicesProvider.categories[index - 1];
          final isSelected = servicesProvider.selectedCategoryId == category.id;

          return _buildModernCategoryChip(
            category.categoryNameAr ?? category.categoryName ?? 'تصنيف',
            isSelected,
                () => servicesProvider.filterByCategory(category.id),
            index,
            isDark,
          );
        },
      ),
    );
  }

  /// ✅ Category Chip
  Widget _buildModernCategoryChip(
      String label,
      bool isSelected,
      VoidCallback onTap,
      int index,
      bool isDark,
      ) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
              colors: [AppColors.darkRed, AppColors.darkRedDark],
            )
                : null,
            color: isSelected ? null : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
            borderRadius: BorderRadius.circular(25.r),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: AppColors.darkRed.withValues(alpha:0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.black),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14.sp,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn().scale(),
    );
  }

  /// ✅ إعادة تعيين الفلاتر
  void _resetFilters() {
    setState(() {
      _currentSortOption = SortOption.none;
      _selectedMinPrice = _minPrice;
      _selectedMaxPrice = _maxPrice;
    });
  }


  /// ✅ Filter Bottom Sheet (مصحّح)
  void _showFilterBottomSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
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

              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الفلترة والترتيب',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.black,
                        fontFamily: 'Cairo',
                      ),
                    ),
                TextButton(
                  onPressed: () {
                    setSheetState(() {
                      _currentSortOption = SortOption.none;
                      _selectedMinPrice = _minPrice;
                      _selectedMaxPrice = _maxPrice;
                    });
                    setState(() {}); // ✅ تحديث الشاشة الرئيسية
                  },
                  child: Text('إعادة تعيين',       style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.darkRed,
                    fontFamily: 'Cairo',
                  )),
                ),



                  ],
                ),
              ),

              Divider(height: 1.h),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الترتيب
                      Text(
                        'الترتيب حسب',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.black,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildSortOption('الافتراضي', SortOption.none, setSheetState, isDark),
                      _buildSortOption('السعر: من الأقل للأعلى', SortOption.priceLowToHigh, setSheetState, isDark),
                      _buildSortOption('السعر: من الأعلى للأقل', SortOption.priceHighToLow, setSheetState, isDark),
                      _buildSortOption('المدة', SortOption.duration, setSheetState, isDark),

                      SizedBox(height: 24.h),

                      // نطاق السعر
                      Text(
                        'نطاق السعر',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.black,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // ✅ عرض النطاق الكامل
                      Text(
                        'النطاق المتاح: ${_minPrice.toInt()} - ${_maxPrice.toInt()} ريال',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? Colors.grey.shade500 : AppColors.greyDark,
                          fontFamily: 'Cairo',
                        ),
                      ),

                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'من',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Text(
                                    '${_selectedMinPrice.toInt()} ر.ي',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : AppColors.black,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'إلى',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Text(
                                    '${_selectedMaxPrice.toInt()} ر.ي',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : AppColors.black,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // ✅ Range Slider محسّن
                      RangeSlider(
                        values: RangeValues(_selectedMinPrice, _selectedMaxPrice),
                        min: _minPrice,
                        max: _maxPrice,
                        divisions: (_maxPrice - _minPrice) > 20 ? 20 : (_maxPrice - _minPrice).toInt(),
                        activeColor: AppColors.darkRed,
                        inactiveColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                        labels: RangeLabels(
                          '${_selectedMinPrice.toInt()} ر.ي',
                          '${_selectedMaxPrice.toInt()} ر.ي',
                        ),
                        onChanged: (values) {
                          setSheetState(() {
                            _selectedMinPrice = values.start;
                            _selectedMaxPrice = values.end;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Apply Button
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // تطبيق الفلتر
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'تطبيق الفلتر',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  /// ✅ Sort Option Widget
  Widget _buildSortOption(String title, SortOption option, StateSetter setSheetState, bool isDark) {
    final isSelected = _currentSortOption == option;

    return InkWell(
      onTap: () {
        setSheetState(() {
          _currentSortOption = option;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.darkRed.withValues(alpha:0.1)
              : (isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.darkRed : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.darkRed : Colors.grey.shade400,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.darkRed
                    : (isDark ? Colors.white : AppColors.black),
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Results Count
  Widget _buildResultsCount(int count, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Text(
        '$count ${count == 1 ? 'خدمة' : 'خدمات'} متاحة',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
          fontFamily: 'Cairo',
        ),
      ).animate().fadeIn(delay: 400.ms),
    );
  }


  /// ✅ Service Card (محسّن)
  // Widget _buildModernServiceCard(ServiceModel service, int index, bool isDark) {
  //   // ✅ فحص إذا كانت الخدمة محددة
  //   final isSelected = _selectedServiceIds.contains(service.id);
  //
  //   return GestureDetector(
  //     onTap:      () => _handleServiceTap(service),
  //     onLongPress: () => _handleServiceLongPress(service), // ✅ إضافة Long Press
  //     child: AnimatedContainer( // ✅ تغيير Container → AnimatedContainer للانتقال السلس
  //       duration: const Duration(milliseconds: 200),
  //       decoration: BoxDecoration(
  //         color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
  //         borderRadius: BorderRadius.circular(20.r),
  //         // ✅ إطار أحمر عند التحديد
  //         border: isSelected
  //             ? Border.all(color: AppColors.darkRed, width: 2.5)
  //             : null,
  //         boxShadow: [
  //           BoxShadow(
  //             color: isSelected
  //                 ? AppColors.darkRed.withValues(alpha: 0.25) // ✅ ظل أحمر عند التحديد
  //                 : (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.1),
  //             blurRadius: isSelected ? 14 : 10,
  //             offset: const Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // صورة الخدمة
  //           Expanded(
  //             flex: 3,
  //             child: Stack(
  //               children: [
  //                 ClipRRect(
  //                   borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
  //                   child: service.getImageUrl() != null && service.getImageUrl()!.isNotEmpty
  //                       ? Image.network(
  //                     service.getImageUrl()!,
  //                     width: double.infinity,
  //                     fit: BoxFit.cover,
  //                     loadingBuilder: (context, child, loadingProgress) {
  //                       if (loadingProgress == null) return child;
  //                       return Container(
  //                         height: 140.h,
  //                         color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
  //                         child: Center(
  //                           child: CircularProgressIndicator(
  //                             value: loadingProgress.expectedTotalBytes != null
  //                                 ? loadingProgress.cumulativeBytesLoaded /
  //                                 loadingProgress.expectedTotalBytes!
  //                                 : null,
  //                             color: AppColors.darkRed,
  //                           ),
  //                         ),
  //                       );
  //                     },
  //                     errorBuilder: (_, __, ___) => _buildPlaceholderImage(isDark),
  //                   )
  //                       : _buildPlaceholderImage(isDark),
  //                 ),
  //
  //                 // ✅ طبقة شفافة عند التحديد
  //                 if (isSelected)
  //                   ClipRRect(
  //                     borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
  //                     child: Container(
  //                       color: AppColors.darkRed.withValues(alpha: 0.15),
  //                     ),
  //                   ),
  //
  //                 // زر المفضلة (فقط في الوضع العادي وغير محدد)
  //                 if (!_isSelectMode && !isSelected)
  //                   Positioned(
  //                     top: 8.h,
  //                     right: 8.w,
  //                     child: Consumer<FavoriteProvider>(
  //                       builder: (context, favoriteProvider, _) {
  //                         final isFavorite = favoriteProvider.isFavorite(service.id);
  //                         return GestureDetector(
  //                           onTap: () => _toggleServiceFavorite(service.id),
  //                           child: Container(
  //                             padding: EdgeInsets.all(8.r),
  //                             decoration: BoxDecoration(
  //                               color: Colors.white,
  //                               shape: BoxShape.circle,
  //                               boxShadow: [
  //                                 BoxShadow(
  //                                   color: Colors.black.withValues(alpha: 0.2),
  //                                   blurRadius: 8,
  //                                   offset: const Offset(0, 2),
  //                                 ),
  //                               ],
  //                             ),
  //                             child: Icon(
  //                               isFavorite ? Icons.favorite : Icons.favorite_border,
  //                               color: isFavorite ? Colors.red : Colors.grey.shade600,
  //                               size: 18.sp,
  //                             ),
  //                           ),
  //                         );
  //                       },
  //                     ),
  //                   ),
  //
  //                 // المدة
  //                 Positioned(
  //                   top: 8.h,
  //                   left: 8.w,
  //                   child: Container(
  //                     padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
  //                     decoration: BoxDecoration(
  //                       color: Colors.black.withValues(alpha: 0.6),
  //                       borderRadius: BorderRadius.circular(20.r),
  //                     ),
  //                     child: Row(
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         Icon(Icons.access_time, size: 12.sp, color: Colors.white),
  //                         SizedBox(width: 4.w),
  //                         Text(
  //                           '${service.durationMinutes} د',
  //                           style: TextStyle(
  //                             color: Colors.white,
  //                             fontSize: 11.sp,
  //                             fontWeight: FontWeight.w600,
  //                             fontFamily: 'Cairo',
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //
  //                 // ✅ أيقونة التحديد ✓ (عند تحديد الخدمة)
  //                 if (isSelected)
  //                   Positioned(
  //                     top: 8.h,
  //                     right: 8.w,
  //                     child: Container(
  //                       padding: EdgeInsets.all(6.r),
  //                       decoration: const BoxDecoration(
  //                         color: AppColors.darkRed,
  //                         shape: BoxShape.circle,
  //                       ),
  //                       child: Icon(
  //                         Icons.check_rounded,
  //                         color: Colors.white,
  //                         size: 16.sp,
  //                       ),
  //                     ).animate().scale(
  //                       duration: const Duration(milliseconds: 200),
  //                       curve: Curves.elasticOut,
  //                     ),
  //                   ),
  //
  //                 // أيقونة العرض (في وضع الاختيار فقط وغير محددة)
  //                 if (_isSelectMode && !isSelected)
  //                   Positioned(
  //                     top: 8.h,
  //                     right: 8.w,
  //                     child: Container(
  //                       padding: EdgeInsets.all(8.r),
  //                       decoration: BoxDecoration(
  //                         color: AppColors.gold,
  //                         shape: BoxShape.circle,
  //                         boxShadow: [
  //                           BoxShadow(
  //                             color: AppColors.gold.withValues(alpha: 0.5),
  //                             blurRadius: 8,
  //                             offset: const Offset(0, 2),
  //                           ),
  //                         ],
  //                       ),
  //                       child: Icon(
  //                         Icons.local_offer_rounded,
  //                         color: Colors.white,
  //                         size: 18.sp,
  //                       ),
  //                     ),
  //                   ),
  //               ],
  //             ),
  //           ),
  //
  //           // معلومات الخدمة
  //           Expanded(
  //             flex: 2,
  //             child: Padding(
  //               padding: EdgeInsets.all(8.r),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Flexible(
  //                     child: Text(
  //                       service.serviceNameAr ?? service.serviceName ?? 'خدمة',
  //                       style: TextStyle(
  //                         fontSize: 14.sp,
  //                         fontWeight: FontWeight.bold,
  //                         color: isDark ? Colors.white : AppColors.black,
  //                         height: 1.2,
  //                         fontFamily: 'Cairo',
  //                       ),
  //                       maxLines: 2,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ),
  //                   Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Row(
  //                         children: [
  //                           Text(
  //                             service.price.toStringAsFixed(0),
  //                             style: TextStyle(
  //                               fontSize: 16.sp,
  //                               fontWeight: FontWeight.bold,
  //                               color: AppColors.gold,
  //                               fontFamily: 'Cairo',
  //                             ),
  //                           ),
  //                           SizedBox(width: 3.w),
  //                           Text(
  //                             'ريال',
  //                             style: TextStyle(
  //                               fontSize: 11.sp,
  //                               color: isDark ? Colors.grey.shade500 : AppColors.greyDark,
  //                               fontFamily: 'Cairo',
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       SizedBox(height: 6.h),
  //                       SizedBox(
  //                         width: double.infinity,
  //                         height: 32.h,
  //                         child: ElevatedButton(
  //                           onPressed: () => _handleServiceTap(service),
  //                           style: ElevatedButton.styleFrom(
  //                             // ✅ لون مختلف عند التحديد
  //                             backgroundColor: isSelected
  //                                 ? Colors.red.shade700
  //                                 : _isSelectMode
  //                                 ? AppColors.gold
  //                                 : AppColors.darkRed,
  //                             foregroundColor: Colors.white,
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(10.r),
  //                             ),
  //                             padding: EdgeInsets.zero,
  //                             elevation: 0,
  //                           ),
  //                           child: Row(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: [
  //                               // ✅ أيقونة مختلفة عند التحديد
  //                               if (isSelected) ...[
  //                                 Icon(Icons.remove_circle_outline_rounded,
  //                                     size: 13.sp, color: Colors.white),
  //                                 SizedBox(width: 4.w),
  //                               ],
  //                               Text(
  //                                 isSelected
  //                                     ? 'إلغاء التحديد'
  //                                     : _isSelectMode
  //                                     ? 'اختر'
  //                                     : 'احجز الآن',
  //                                 style: TextStyle(
  //                                   fontSize: 12.sp,
  //                                   fontWeight: FontWeight.bold,
  //                                   fontFamily: 'Cairo',
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ).animate(delay: Duration(milliseconds: 50 * index)).fadeIn().scale(),
  //   );
  // }

  // Widget _buildModernServiceCard(ServiceModel service, int index, bool isDark) {
  //   return GestureDetector(
  //     onTap: () => _handleServiceTap(service),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
  //         borderRadius: BorderRadius.circular(20.r),
  //         boxShadow: [
  //           BoxShadow(
  //             color: (isDark ? Colors.black : Colors.grey).withValues(alpha:0.1),
  //             blurRadius: 10,
  //             offset: const Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // صورة الخدمة
  //           Expanded(
  //             flex: 3,
  //             child: Stack(
  //               children: [
  //                 // ClipRRect(
  //                 //   borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
  //                 //   child: service.imageUrl != null && service.imageUrl!.isNotEmpty
  //                 //       ? Image.network(
  //                 //     service.imageUrl!,
  //                 //     width: double.infinity,
  //                 //     fit: BoxFit.cover,
  //                 //     loadingBuilder: (context, child, loadingProgress) {
  //                 //       if (loadingProgress == null) return child;
  //                 //       return Container(
  //                 //         height: 140.h,
  //                 //         color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
  //                 //         child: Center(
  //                 //           child: CircularProgressIndicator(
  //                 //             value: loadingProgress.expectedTotalBytes != null
  //                 //                 ? loadingProgress.cumulativeBytesLoaded /
  //                 //                 loadingProgress.expectedTotalBytes!
  //                 //                 : null,
  //                 //             color: AppColors.darkRed,
  //                 //           ),
  //                 //         ),
  //                 //       );
  //                 //     },
  //                 //     errorBuilder: (_, __, ___) => _buildPlaceholderImage(isDark),
  //                 //   )
  //                 //       : _buildPlaceholderImage(isDark),
  //                 // ),
  //                 ClipRRect(
  //                   borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
  //                   child: service.getImageUrl() != null && service.getImageUrl()!.isNotEmpty
  //                       ? Image.network(
  //                     service.getImageUrl()!,
  //                     width: double.infinity,
  //                     fit: BoxFit.cover,
  //                     loadingBuilder: (context, child, loadingProgress) {
  //                       if (loadingProgress == null) return child;
  //                       return Container(
  //                         height: 140.h,
  //                         color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
  //                         child: Center(
  //                           child: CircularProgressIndicator(
  //                             value: loadingProgress.expectedTotalBytes != null
  //                                 ? loadingProgress.cumulativeBytesLoaded /
  //                                 loadingProgress.expectedTotalBytes!
  //                                 : null,
  //                             color: AppColors.darkRed,
  //                           ),
  //                         ),
  //                       );
  //                     },
  //                     errorBuilder: (_, __, ___) => _buildPlaceholderImage(isDark),
  //                   )
  //                       : _buildPlaceholderImage(isDark),
  //                 ),
  //
  //                 // زر المفضلة (فقط في الوضع العادي)
  //                 if (!_isSelectMode)
  //                   Positioned(
  //                     top: 8.h,
  //                     right: 8.w,
  //                     child: Consumer<FavoriteProvider>(
  //                       builder: (context, favoriteProvider, _) {
  //                         final isFavorite = favoriteProvider.isFavorite(service.id);
  //
  //                         return GestureDetector(
  //                           onTap: () => _toggleServiceFavorite(service.id),
  //                           child: Container(
  //                             padding: EdgeInsets.all(8.r),
  //                             decoration: BoxDecoration(
  //                               color: Colors.white,
  //                               shape: BoxShape.circle,
  //                               boxShadow: [
  //                                 BoxShadow(
  //                                   color: Colors.black.withValues(alpha:0.2),
  //                                   blurRadius: 8,
  //                                   offset: const Offset(0, 2),
  //                                 ),
  //                               ],
  //                             ),
  //                             child: Icon(
  //                               isFavorite ? Icons.favorite : Icons.favorite_border,
  //                               color: isFavorite ? Colors.red : Colors.grey.shade600,
  //                               size: 18.sp,
  //                             ),
  //                           ),
  //                         );
  //                       },
  //                     ),
  //                   ),
  //
  //                 // المدة
  //                 Positioned(
  //                   top: 8.h,
  //                   left: 8.w,
  //                   child: Container(
  //                     padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
  //                     decoration: BoxDecoration(
  //                       color: Colors.black.withValues(alpha:0.6),
  //                       borderRadius: BorderRadius.circular(20.r),
  //                     ),
  //                     child: Row(
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         Icon(Icons.access_time, size: 12.sp, color: Colors.white),
  //                         SizedBox(width: 4.w),
  //                         Text(
  //                           '${service.durationMinutes} د',
  //                           style: TextStyle(
  //                             color: Colors.white,
  //                             fontSize: 11.sp,
  //                             fontWeight: FontWeight.w600,
  //                             fontFamily: 'Cairo',
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //
  //                 // أيقونة العرض (في وضع الاختيار)
  //                 if (_isSelectMode)
  //                   Positioned(
  //                     top: 8.h,
  //                     right: 8.w,
  //                     child: Container(
  //                       padding: EdgeInsets.all(8.r),
  //                       decoration: BoxDecoration(
  //                         color: AppColors.gold,
  //                         shape: BoxShape.circle,
  //                         boxShadow: [
  //                           BoxShadow(
  //                             color: AppColors.gold.withValues(alpha:0.5),
  //                             blurRadius: 8,
  //                             offset: const Offset(0, 2),
  //                           ),
  //                         ],
  //                       ),
  //                       child: Icon(
  //                         Icons.local_offer_rounded,
  //                         color: Colors.white,
  //                         size: 18.sp,
  //                       ),
  //                     ),
  //                   ),
  //               ],
  //             ),
  //           ),
  //
  //           // معلومات الخدمة
  //           Expanded(
  //             flex: 2,
  //             child: Padding(
  //               padding: EdgeInsets.all(8.r),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Flexible(
  //                     child: Text(
  //                       service.serviceNameAr ?? service.serviceName ?? 'خدمة',
  //                       style: TextStyle(
  //                         fontSize: 14.sp,
  //                         fontWeight: FontWeight.bold,
  //                         color: isDark ? Colors.white : AppColors.black,
  //                         height: 1.2,
  //                         fontFamily: 'Cairo',
  //                       ),
  //                       maxLines: 2,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ),
  //                   Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Row(
  //                         children: [
  //                           Text(
  //                             '${service.price.toStringAsFixed(0)}',
  //                             style: TextStyle(
  //                               fontSize: 16.sp,
  //                               fontWeight: FontWeight.bold,
  //                               color: AppColors.gold,
  //                               fontFamily: 'Cairo',
  //                             ),
  //                           ),
  //                           SizedBox(width: 3.w),
  //                           Text(
  //                             'ريال',
  //                             style: TextStyle(
  //                               fontSize: 11.sp,
  //                               color: isDark ? Colors.grey.shade500 : AppColors.greyDark,
  //                               fontFamily: 'Cairo',
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       SizedBox(height: 6.h),
  //                       SizedBox(
  //                         width: double.infinity,
  //                         height: 32.h,
  //                         child: ElevatedButton(
  //                           onPressed: () => _handleServiceTap(service),
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: _isSelectMode ? AppColors.gold : AppColors.darkRed,
  //                             foregroundColor: Colors.white,
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(10.r),
  //                             ),
  //                             padding: EdgeInsets.zero,
  //                             elevation: 0,
  //                           ),
  //                           child: Text(
  //                             _isSelectMode ? 'اختر' : 'احجز الآن',
  //                             style: TextStyle(
  //                               fontSize: 12.sp,
  //                               fontWeight: FontWeight.bold,
  //                               fontFamily: 'Cairo',
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ).animate(delay: Duration(milliseconds: 50 * index)).fadeIn().scale(),
  //   );
  // }

  /// ✅ معالجة النقر على الخدمة
  // void _handleServiceTap(ServiceModel service) {
  //
  //   if (_isSelectMode && _offerData != null) {
  //     // وضع الاختيار - الانتقال للحجز مع العرض
  //     final offer = _offerData!['applied_offer'] as Map<String, dynamic>;
  //     final offerId = _offerData!['offer_id'] as int;
  //     final promoCode = _offerData!['promo_code'] as String?;
  //
  //
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => BookAppointmentScreen(service: service),
  //         settings: RouteSettings(
  //           arguments: {
  //             'applied_offer': offer,
  //             'offer_id': offerId,
  //             'promo_code': promoCode,
  //           },
  //         ),
  //       ),
  //     );
  //   } else {
  //     // وضع عادي - فتح تفاصيل الخدمة
  //     Navigator.push(
  //       context,
  //       PageRouteBuilder(
  //         pageBuilder: (context, animation, secondaryAnimation) =>
  //             ServiceDetailScreen(service: service),
  //         transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //           return FadeTransition(opacity: animation, child: child);
  //         },
  //       ),
  //     );
  //   }
  // }

// ✅ النسخة الصحيحة الكاملة
//   void _handleServiceTap(ServiceModel service) {
//     if (_isSelectMode && _offerData != null) {
//       // وضع العرض: انتقل مباشرة للحجز
//       final offer     = _offerData!['appliedoffer'] as Map<String, dynamic>;
//       final offerId   = _offerData!['offerid'] as int;
//       final promoCode = _offerData!['promocode'] as String?;
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => BookAppointmentScreen(services: [service]),
//           settings: RouteSettings(arguments: {
//             'appliedoffer': offer,
//             'offerid':      offerId,
//             'promocode':    promoCode,
//           }),
//         ),
//       );
//     } else if (_selectedServiceIds.isNotEmpty) {
//       // ✅ وضع التحديد المتعدد (فقط إذا بدأ المستخدم بتحديد خدمات)
//       setState(() {
//         if (_selectedServiceIds.contains(service.id)) {
//           _selectedServiceIds.remove(service.id);
//         } else {
//           _selectedServiceIds.add(service.id);
//         }
//       });
//     } else {
//       // ✅ الوضع الافتراضي: انتقل لتفاصيل الخدمة
//       Navigator.push(
//         context,
//         PageRouteBuilder(
//           pageBuilder: (_, __, ___) => ServiceDetailScreen(service: service),
//           transitionsBuilder: (_, animation, __, child) =>
//               FadeTransition(opacity: animation, child: child),
//         ),
//       );
//     }
//   }



// // ✅ Long press لبدء وضع التحديد المتعدد
//   void _handleServiceLongPress(ServiceModel service) {
//     // اهتزاز خفيف
//     HapticFeedback.mediumImpact();
//     setState(() {
//       if (_selectedServiceIds.contains(service.id)) {
//         _selectedServiceIds.remove(service.id);
//       } else {
//         _selectedServiceIds.add(service.id);
//       }
//     });
//   }

//   void _handleServiceLongPress(ServiceModel service) {
//     HapticFeedback.mediumImpact();
//     setState(() => _selectedServiceIds.add(service.id));
//   }


  // ══════════════════════════════════════════════════════════════════
// HANDLE SERVICE TAP
// ══════════════════════════════════════════════════════════════════

  void _handleServiceTap(ServiceModel service) {
    if (_isSelectMode && _offerData != null) {
      // وضع العرض: انتقل للحجز مباشرة
      final offer     = _offerData!['appliedoffer'] as Map<String, dynamic>;
      final offerId   = _offerData!['offerid'] as int;
      final promoCode = _offerData!['promocode'] as String?;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookAppointmentScreen(services: [service]),
          settings: RouteSettings(arguments: {
            'appliedoffer': offer,
            'offerid':      offerId,
            'promocode':    promoCode,
          }),
        ),
      );
    } else if (_selectedServiceIds.isNotEmpty) {
      // ✅ وضع التحديد المتعدد
      setState(() {
        if (_selectedServiceIds.contains(service.id)) {
          _selectedServiceIds.remove(service.id);
        } else {
          _selectedServiceIds.add(service.id);
        }
      });
    } else {
      // ✅ الوضع الافتراضي: تفاصيل الخدمة
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => ServiceDetailScreen(service: service),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    }
  }

// ══════════════════════════════════════════════════════════════════
// ✅ HANDLE LONG PRESS - يبدأ وضع التحديد المتعدد
// ══════════════════════════════════════════════════════════════════

  void _handleServiceLongPress(ServiceModel service) {
    if (_isSelectMode) return; // في وضع العروض لا نحتاج long press
    HapticFeedback.mediumImpact();
    setState(() => _selectedServiceIds.add(service.id));
  }

// ══════════════════════════════════════════════════════════════════
// SERVICE CARD - مع دعم التحديد المتعدد
// ══════════════════════════════════════════════════════════════════

  Widget _buildModernServiceCard(ServiceModel service, int index, bool isDark) {
    final isSelected = _selectedServiceIds.contains(service.id); // ✅

    return GestureDetector(
      onTap:       () => _handleServiceTap(service),
      onLongPress: () => _handleServiceLongPress(service), // ✅
      child: AnimatedContainer( // ✅ انتقال سلس
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          // ✅ إطار أحمر عند التحديد
          border: isSelected
              ? Border.all(color: AppColors.darkRed, width: 2.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.darkRed.withValues(alpha: 0.25)
                  : (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.1),
              blurRadius: isSelected ? 14 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة الخدمة
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                    child: service.getImageUrl() != null && service.getImageUrl()!.isNotEmpty
                        ? Image.network(
                      service.getImageUrl()!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 140.h,
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
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
                      errorBuilder: (_, __, ___) => _buildPlaceholderImage(isDark),
                    )
                        : _buildPlaceholderImage(isDark),
                  ),

                  // ✅ طبقة شفافة حمراء عند التحديد
                  if (isSelected)
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                      child: Container(
                        color: AppColors.darkRed.withValues(alpha: 0.15),
                      ),
                    ),

                  // زر المفضلة (فقط في الوضع العادي وغير محدد)
                  if (!_isSelectMode && !isSelected)
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Consumer<FavoriteProvider>(
                        builder: (context, favoriteProvider, _) {
                          final isFavorite = favoriteProvider.isFavorite(service.id);
                          return GestureDetector(
                            onTap: () => _toggleServiceFavorite(service.id),
                            child: Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey.shade600,
                                size: 18.sp,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // المدة
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time, size: 12.sp, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text(
                            '${service.durationMinutes} د',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ✅ أيقونة التحديد ✓ (عند تحديد الخدمة)
                  if (isSelected)
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: const BoxDecoration(
                          color: AppColors.darkRed,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ).animate().scale(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.elasticOut,
                      ),
                    ),

                  // أيقونة العرض (في وضع العرض فقط وغير محددة)
                  if (_isSelectMode && !isSelected)
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.local_offer_rounded,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // معلومات الخدمة
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        service.serviceNameAr ?? service.serviceName ?? 'خدمة',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.black,
                          height: 1.2,
                          fontFamily: 'Cairo',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${service.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              'ريال',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: isDark ? Colors.grey.shade500 : AppColors.greyDark,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        SizedBox(
                          width: double.infinity,
                          height: 32.h,
                          child: ElevatedButton(
                            onPressed: () => _handleServiceTap(service),
                            style: ElevatedButton.styleFrom(
                              // ✅ لون مختلف حسب الحالة
                              backgroundColor: isSelected
                                  ? Colors.red.shade700
                                  : _isSelectMode
                                  ? AppColors.gold
                                  : AppColors.darkRed,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              padding: EdgeInsets.zero,
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isSelected) ...[
                                  Icon(Icons.remove_circle_outline_rounded,
                                      size: 13.sp, color: Colors.white),
                                  SizedBox(width: 4.w),
                                ],
                                Text(
                                  isSelected
                                      ? 'إلغاء التحديد'
                                      : _isSelectMode
                                      ? 'اختر'
                                      : 'احجز الآن',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ],
                            ),
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
      ).animate(delay: Duration(milliseconds: 50 * index)).fadeIn().scale(),
    );
  }

  /// ✅ إضافة/إزالة من المفضلة
  void _toggleServiceFavorite(int serviceId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);

    if (userProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى تسجيل الدخول أولاً',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
      );
      return;
    }

    final success = await favoriteProvider.toggleFavorite(
      userProvider.user!.id!,
      serviceId,
    );

    if (success && mounted) {
      final isFavorite = favoriteProvider.isFavorite(serviceId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite ? '❤️ تمت الإضافة للمفضلة' : '💔 تم الحذف من المفضلة',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp),
          ),
          backgroundColor: isFavorite ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
      );
    }
  }

  /// ✅ Placeholder Image
  // Widget _buildPlaceholderImage(bool isDark) {
  //   return Container(
  //     height: 140.h,
  //     color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
  //     child: Center(
  //       child: Icon(
  //         Icons.content_cut_rounded,
  //         size: 50.sp,
  //         color: isDark ? Colors.grey.shade700 : AppColors.gold.withValues(alpha:0.5),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildPlaceholderImage(bool isDark) {
    return Container(
      height: 140.h,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
      child: Center(
        child: Image.asset(
          'assets/images/logo.png',
          height: 80.h,
          fit: BoxFit.contain,
          color: isDark ? Colors.grey.shade700 : null, // اختياري لتأثير بسيط في الوضع الليلي
        ),
      ),
    );
  }


  /// ✅ Empty State
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(30.r),
              decoration: BoxDecoration(
                color: (isDark ? Colors.grey.shade900 : AppColors.greyLight).withValues(alpha:0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.inbox_rounded,
                size: 80.sp,
                color: isDark ? Colors.grey.shade700 : AppColors.greyMedium,
              ),
            ).animate().scale(duration: 600.ms),
            SizedBox(height: 5.h),
            Text(
              _searchQuery.isNotEmpty ? 'لا توجد نتائج' : 'لا توجد خدمات متاحة',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.black,
                fontFamily: 'Cairo',
              ),
            ).animate(delay: 200.ms).fadeIn(),
            SizedBox(height: 8.h),
            Text(
              _searchQuery.isNotEmpty ? 'جرب كلمات بحث أخرى' : 'سيتم إضافة خدمات قريباً',
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? Colors.grey.shade500 : AppColors.greyDark,
                fontFamily: 'Cairo',
              ),
            ).animate(delay: 300.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}
