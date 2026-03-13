import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:millionaire_barber/core/models/payment_result.dart';
import 'package:millionaire_barber/features/packages/presentation/providers/package_subscription_provider.dart';
import 'package:millionaire_barber/features/packages/presentation/widgets/payment_sheet.dart';
import 'package:millionaire_barber/features/profile/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vibration/vibration.dart';

import '../../data/repositories/package_subscription_repository.dart';
import '../../domain/models/package_model.dart';
import '../providers/packages_provider.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({Key? key}) : super(key: key);

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen>
    with TickerProviderStateMixin {
  static const Color primaryRed = Color(0xFFA62424);
  static const Color primaryGold = Color(0xFFB6862C);
  static const String patternImage = 'assets/images/pattern1.png';

  late AnimationController _staggerController;
  late AnimationController _filterAnimController;
  late AnimationController _indicatorController;

  String _selectedFilter = 'all';
  double _minPrice = 0;
  double _maxPrice = 10000;
  RangeValues? _currentPriceRange; // ✅ جعله nullable

  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // ✅ تأجيل التحميل بعد اكتمال البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPackages();
    });

  }

  void _initializeAnimations() {
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _staggerController.forward();

    _filterAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }



  Future<void> _loadPackages() async {
    final provider = context.read<PackagesProvider>();
    if (!provider.isRealtimeInitialized) {
      await provider.initializeRealtime();
    }
    await provider.loadActivePackages();

    if (_isFirstLoad) {
      setState(() {
        _isFirstLoad = false;
      });
    }

    // ✅ بعد التحميل، افحص إذا كان هناك باقة محددة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForSelectedPackage();
    });
  }

  void _checkForSelectedPackage() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null && args['selectedPackageId'] != null) {
      // ✅ حل آمن يدعم int أو String
      final packageIdRaw = args['selectedPackageId'];
      final int packageId;

      if (packageIdRaw is int) {
        packageId = packageIdRaw;
      } else if (packageIdRaw is String) {
        packageId = int.tryParse(packageIdRaw) ?? 0;
      } else {
        return;
      }

      final isDark = Theme.of(context).brightness == Brightness.dark;

      // ✅ ابحث عن الباقة
      final provider = context.read<PackagesProvider>();

      if (provider.packages.isNotEmpty) {
        final package = provider.packages.firstWhere(
              (p) => p.id == packageId,
          orElse: () => provider.packages.first,
        );

        // ✅ افتح التفاصيل بعد 300ms
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _showPackageDetails(package, isDark);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _filterAnimController.dispose();
    _indicatorController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F7),
      body: Column(
        children: [
          _buildGradientHeader(isDark),
          Expanded(child: _buildPackagesList(isDark)),
        ],
      ),
    );
  }

  Widget _buildGradientHeader(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : const Color(0xFFF5F5F7),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: isDark ? Colors.white : Colors.black87,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showFilterSheet(isDark),
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha:0.1)
                            : const Color(0xFFFEF0F0),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: primaryRed,
                        size: 22.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'باقات العضوية',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'اختر الباقة المناسبة لك',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            _buildPremiumFilterChips(isDark),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Align(
                alignment: Alignment.centerRight,
                child: Consumer<PackagesProvider>(
                  builder: (context, provider, _) {
                    final filtered = _applyFilters(provider.packages);
                    return Text(
                      '${filtered.length} باقات متاحة',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumFilterChips(bool isDark) {
    return Container(
      height: 58.h,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildModernChip(
            label: 'الكل',
            value: 'all',
            icon: Icons.apps_rounded,
            isDark: isDark,
          ),
          SizedBox(width: 10.w),
          _buildModernChip(
            label: 'المميزة',
            value: 'featured',
            icon: Icons.star_rounded,
            isDark: isDark,
          ),
          SizedBox(width: 10.w),
          _buildModernChip(
            label: 'الموسمية',
            value: 'seasonal',
            icon: Icons.local_fire_department_rounded,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildModernChip({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _selectedFilter == value;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = value);
        _filterAnimController.forward(from: 0.0);
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryRed
              : isDark
                  ? Colors.white.withValues(alpha:0.1)
                  : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? primaryRed
                : isDark
                    ? Colors.white.withValues(alpha:0.2)
                    : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryRed.withValues(alpha:0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : isDark
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : isDark
                        ? Colors.grey.shade300
                        : Colors.grey.shade700,
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: 8.w),
              Consumer<PackagesProvider>(
                builder: (context, provider, _) {
                  final filtered = _applyFilters(provider.packages);
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.3),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '${filtered.length}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(bool isDark) {
    String tempFilter = _selectedFilter;
    RangeValues? tempRange = _currentPriceRange; // ✅ nullable

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'فلترة الباقات',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade300),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نوع الباقة',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildFilterOptionModal(
                          title: 'جميع الباقات',
                          value: 'all',
                          icon: Icons.apps_rounded,
                          isDark: isDark,
                          currentFilter: tempFilter,
                          onTap: () {
                            setModalState(() {
                              tempFilter = 'all';
                            });
                          },
                        ),
                        _buildFilterOptionModal(
                          title: 'الباقات المميزة',
                          value: 'featured',
                          icon: Icons.star_rounded,
                          isDark: isDark,
                          currentFilter: tempFilter,
                          onTap: () {
                            setModalState(() {
                              tempFilter = 'featured';
                            });
                          },
                        ),
                        _buildFilterOptionModal(
                          title: 'العروض الموسمية',
                          value: 'seasonal',
                          icon: Icons.celebration_rounded,
                          isDark: isDark,
                          currentFilter: tempFilter,
                          onTap: () {
                            setModalState(() {
                              tempFilter = 'seasonal';
                            });
                          },
                        ),
                        SizedBox(height: 32.h),
                        Text(
                          'نطاق السعر',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Consumer<PackagesProvider>(
                          builder: (context, provider, _) {
                            if (provider.packages.isEmpty) {
                              return const SizedBox();
                            }

                            final prices = provider.packages
                                .map((p) => p.price)
                                .toList()
                              ..sort();
                            final minPrice = prices.first;
                            final maxPrice = prices.last;

                            // ✅ تحديد النطاق إذا كان null
                            if (tempRange == null) {
                              tempRange = RangeValues(minPrice, maxPrice);
                            }

                            return Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16.r),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey.shade900
                                        : const Color(0xFFF5F5F7),
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'من',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            '${tempRange!.start.toInt()} ريال',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: primaryRed,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.grey.shade400,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'إلى',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            '${tempRange!.end.toInt()} ريال',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: primaryRed,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                RangeSlider(
                                  values: tempRange!,
                                  min: minPrice,
                                  max: maxPrice,
                                  divisions: ((maxPrice - minPrice) / 100)
                                      .round()
                                      .clamp(1, 100),
                                  activeColor: primaryRed,
                                  inactiveColor: Colors.grey.shade300,
                                  labels: RangeLabels(
                                    '${tempRange!.start.toInt()} ريال',
                                    '${tempRange!.end.toInt()} ريال',
                                  ),
                                  onChanged: (RangeValues values) {
                                    setModalState(() {
                                      tempRange = values;
                                    });
                                  },
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.w),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${minPrice.toInt()} ريال',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      Text(
                                        '${maxPrice.toInt()} ريال',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedFilter = tempFilter;
                          _currentPriceRange = tempRange; // ✅ nullable
                        });
                        Navigator.pop(context);
                        HapticFeedback.mediumImpact();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        'تطبيق الفلتر',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterOptionModal({
    required String title,
    required String value,
    required IconData icon,
    required bool isDark,
    required String currentFilter,
    required VoidCallback onTap,
  }) {
    final isSelected = currentFilter == value;

    return GestureDetector(
      onTap: () {
        onTap();
        HapticFeedback.lightImpact();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryRed.withValues(alpha:0.1)
              : isDark
                  ? Colors.grey.shade900
                  : const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? primaryRed : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryRed
                    : isDark
                        ? Colors.white.withValues(alpha:0.1)
                        : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : isDark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? primaryRed
                      : isDark
                          ? Colors.white
                          : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: primaryRed,
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackagesList(bool isDark) {
    return Consumer<PackagesProvider>(
      builder: (context, provider, _) {
        if (_isFirstLoad && provider.isLoading) {
          return _buildShimmerLoading(isDark);
        }

        if (provider.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64.sp,
                  color: Colors.red.shade300,
                ),
                SizedBox(height: 16.h),
                Text(
                  'حدث خطأ',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  provider.error ?? 'خطأ غير معروف',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (provider.packages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 80.sp,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 16.h),
                Text(
                  'لا توجد باقات متاحة',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        List<PackageModel> filteredPackages = _applyFilters(provider.packages);

        return RefreshIndicator(
          onRefresh: () => provider.refreshPackages(),
          color: primaryRed,
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
            itemCount: filteredPackages.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _staggerController,
                builder: (context, child) {
                  final animValue = Curves.easeOutCubic.transform(
                    ((_staggerController.value - (index * 0.1))
                        .clamp(0.0, 1.0)),
                  );
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - animValue)),
                    child: Opacity(
                      opacity: animValue,
                      child: child,
                    ),
                  );
                },
                child: _buildEnhancedPackageCard(
                  filteredPackages[index],
                  isDark,
                  index,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoading(bool isDark) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
          period: const Duration(milliseconds: 1500),
          child: Container(
            margin: EdgeInsets.only(bottom: 24.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 200.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32.r),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(24.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4.w,
                            height: 20.h,
                            color: Colors.white,
                          ),
                          SizedBox(width: 12.w),
                          Container(
                            width: 150.w,
                            height: 18.h,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      ...List.generate(4, (i) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Row(
                            children: [
                              Container(
                                width: 28.w,
                                height: 28.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Container(
                                  height: 15.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      SizedBox(height: 20.h),
                      Container(
                        width: double.infinity,
                        height: 52.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
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

  List<PackageModel> _applyFilters(List<PackageModel> packages) {
    var filtered = packages;

    if (_selectedFilter == 'featured') {
      filtered = filtered.where((p) => p.isFeatured).toList();
    } else if (_selectedFilter == 'seasonal') {
      filtered = filtered.where((p) => p.isSeasonal).toList();
    }

    // ✅ فلتر السعر فقط إذا كان محدد
    if (_currentPriceRange != null) {
      filtered = filtered.where((p) {
        return p.price >= _currentPriceRange!.start &&
            p.price <= _currentPriceRange!.end;
      }).toList();
    }

    return filtered;
  }

  Widget _buildEnhancedPackageCard(
      PackageModel package, bool isDark, int index) {
    final colors = _getPackageColors(package);
    final hasImage = package.imageUrl != null && package.imageUrl!.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      child: GestureDetector(
        onTap: () => _showPackageDetails(package, isDark),
        child: package.isFeatured
            ? AnimatedBorderCard(
                borderColors: [
                  Colors.amber,
                  primaryGold,
                  Colors.amber.shade700,
                  primaryGold,
                  Colors.amber,
                ],
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(29.r),
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha:0.5),
                        blurRadius: 30,
                        spreadRadius: 3,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(29.r),
                    child: Column(
                      children: [
                        _buildCardHeader(package, colors, hasImage, isDark),
                        _buildServicesSection(package, colors, isDark),
                      ],
                    ),
                  ),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32.r),
                  boxShadow: [
                    BoxShadow(
                      color: colors[0].withValues(alpha:0.3),
                      blurRadius: 25,
                      spreadRadius: 2,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32.r),
                  child: Column(
                    children: [
                      _buildCardHeader(package, colors, hasImage, isDark),
                      _buildServicesSection(package, colors, isDark),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildCardHeader(
      PackageModel package, List<Color> colors, bool hasImage, bool isDark) {
    return Container(
      height: 200.h,
      child: Stack(
        children: [
          Positioned.fill(
            child: hasImage
                ? CachedNetworkImage(
                    imageUrl: package.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        _buildPatternBackground(colors),
                    errorWidget: (context, url, error) =>
                        _buildPatternBackground(colors),
                  )
                : _buildPatternBackground(colors),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha:0.8),
                    Colors.black.withValues(alpha:0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24.r),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52.w,
                        height: 52.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha:0.3),
                              Colors.white.withValues(alpha:0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha:0.4),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.white,
                          size: 28.sp,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        package.nameAr,
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha:0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.checklist_rounded,
                            color: Colors.white70,
                            size: 18.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '${package.services.length} خدمات متضمنة',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (package.hasDiscount) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'خصم ${package.calculatedDiscountPercentage}%',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${package.originalPrice!.toInt()}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white60,
                              decoration: TextDecoration.lineThrough,
                              decorationThickness: 2,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                      ],
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${package.price.toInt()}',
                          style: TextStyle(
                            fontSize: 48.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 0.9,
                          ),
                        ),
                      ),
                      Text(
                        'ريال',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (package.isFeatured)
            Positioned(
              top: 16.h,
              right: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha:0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'مميزة',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildServicesSection(
      PackageModel package, List<Color> colors, bool isDark) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(
          top: BorderSide(
            color: colors[0].withValues(alpha:0.2),
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 20.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'الخدمات المتضمنة',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...package.services.take(4).map((service) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors[0].withValues(alpha:0.2),
                          colors[1].withValues(alpha:0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: colors[0],
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      service.nameAr,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          if (package.services.length > 4) ...[
            SizedBox(height: 8.h),
            InkWell(
              onTap: () => _showPackageDetails(package, isDark),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+ ${package.services.length - 4} خدمات أخرى',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: colors[0],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: colors[0],
                    size: 12.sp,
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () => _showPackageDetails(package, isDark),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors[0],
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: colors[0].withValues(alpha:0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'اشترك الآن',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_forward_rounded, size: 20.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternBackground(List<Color> colors) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
        ),
        Image.asset(
          patternImage,
          fit: BoxFit.cover,
          color: Colors.white.withValues(alpha:0.15),
          colorBlendMode: BlendMode.overlay,
          errorBuilder: (context, error, stackTrace) => const SizedBox(),
        ),
      ],
    );
  }

  List<Color> _getPackageColors(PackageModel package) {
    if (package.colorPrimary != null && package.colorSecondary != null) {
      return [package.primaryColor, package.secondaryColor];
    }
    if (package.nameAr.contains('ذهب')) {
      return [const Color(0xFFD4A056), const Color(0xFFB8860B)];
    } else if (package.nameAr.contains('فض')) {
      return [const Color(0xFFC0C0C0), const Color(0xFFA8A8A8)];
    } else if (package.nameAr.contains('برونز')) {
      return [const Color(0xFFCD7F32), const Color(0xFFA0522D)];
    }
    return [primaryRed, const Color(0xFF8B1E1E)];
  }

  void _showPackageDetails(PackageModel package, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetailsSheet(package, isDark),
    );
  }

  Widget _buildDetailsSheet(PackageModel package, bool isDark) {
    final colors = _getPackageColors(package);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              package.nameAr,
                              style: TextStyle(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (package.isFeatured)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.white, size: 14.sp),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'مميزة',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade900
                              : const Color(0xFFF5F5F7),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50.w,
                              height: 50.w,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: colors),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Icon(
                                Icons.local_offer_rounded,
                                color: Colors.white,
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'سعر الباقة',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (package.hasDiscount) ...[
                                        Text(
                                          '${package.originalPrice!.toInt()}',
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            color: Colors.grey.shade500,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            decorationThickness: 2,
                                            decorationColor: Colors.red,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                      ],
                                      Text(
                                        '${package.price.toInt()}',
                                        style: TextStyle(
                                          fontSize: 32.sp,
                                          fontWeight: FontWeight.w900,
                                          color: colors[0],
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
                                            fontWeight: FontWeight.bold,
                                            color: colors[0],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (package.hasDiscount)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  '${package.calculatedDiscountPercentage}%',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (package.descriptionAr != null) ...[
                        SizedBox(height: 24.h),
                        Text(
                          'عن الباقة',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          package.descriptionAr!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade700,
                            height: 1.6,
                          ),
                        ),
                      ],
                      SizedBox(height: 24.h),
                      Row(
                        children: [
                          Container(
                            width: 4.w,
                            height: 24.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: colors),
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'الخدمات المتضمنة',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: colors[0].withValues(alpha:0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              '${package.services.length}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: colors[0],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      ...package.services.asMap().entries.map((entry) {
                        final index = entry.key;
                        final service = entry.value;
                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.shade900
                                : const Color(0xFFF5F5F7),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32.w,
                                height: 32.w,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      colors[0].withValues(alpha:0.2),
                                      colors[1].withValues(alpha:0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: colors[0],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  service.nameAr,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.green,
                                size: 22.sp,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: () => _handleSubscribe(package, isDark),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryRed,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          child: Text(
                            'اشترك الآن',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// ═══════════════════════════════════════════════════════════════
// ✅ Method محدّث مع معالجة أفضل للأخطاء
// ═══════════════════════════════════════════════════════════════

  // ═══════════════════════════════════════════════════════════════
// ✅ Step 1: إغلاق Sheet التفاصيل → فتح اختيار طريقة الدفع
// ═══════════════════════════════════════════════════════════════
  Future<void> _handleSubscribe(PackageModel package, bool isDark) async {
    Navigator.pop(context);

    final user = context.read<UserProvider>().user;
    if (user == null) {
      _showWarningSnackBar('يجب تسجيل الدخول أولاً');
      _vibrateError();
      return;
    }

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    final result = await PaymentMethodSheet.show(
      context:       context,
      package:       package,
      isDark:        isDark,
      packageColors: _getPackageColors(package),
    );

    if (result == null || !mounted) return;

    await _processSubscription(
      package:       package,
      isDark:        isDark,
      paymentResult: result,
    );
  }


  Future<void> _processSubscription({
    required PackageModel  package,
    required bool          isDark,
    required PaymentResult paymentResult,
  }) async {
    // ✅ جلب المستخدم أولاً
    final user = context.read<UserProvider>().user;
    if (user == null) {
      _showWarningSnackBar('يرجى تسجيل الدخول أولاً');
      return;
    }

    final userId = user.id.toString().trim();
    if (userId.isEmpty) {
      _showWarningSnackBar('بيانات المستخدم غير مكتملة');
      return;
    }

    debugPrint('✅ _processSubscription userId: "$userId"');

    _showLoadingDialog(isDark);

    try {
      final subProvider = context.read<PackageSubscriptionProvider>();

      final success = await subProvider.subscribeToPackage(
        package:        package,
        paymentResult:  paymentResult,
        overrideUserId: userId, // ✅ تمرير صريح دائماً
      );

      if (!mounted) return;
      Navigator.pop(context); // إغلاق loading

      if (!success) {
        _vibrateError();
        _showErrorSnackBar(subProvider.error ?? 'حدث خطأ أثناء الاشتراك');
        return;
      }

      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) await Vibration.vibrate(duration: 50);

      final msg = paymentResult.paymentMethod == 'cash'
          ? 'اشتراكك فعّال! ادفع عند أول جلسة 💰'
          : 'جاري مراجعة إيصالك وتفعيل الاشتراك ✅';

      _showSuccessSnackBar(
        '${package.nameAr}\n$msg',
        onActionPressed: () =>
            Navigator.pushNamed(context, '/my-subscriptions'),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _vibrateError();
      _showErrorSnackBar('حدث خطأ أثناء الاشتراك، حاول مرة أخرى');
    }
  }

  // Future<void> _processSubscription({
  //   required PackageModel  package,
  //   required bool          isDark,
  //   required PaymentResult paymentResult,
  // }) async {
  //   final user = context.read<UserProvider>().user;
  //   if (user == null) {
  //     _showWarningSnackBar('يرجى تسجيل الدخول أولاً');
  //     return;
  //   }
  //
  //   _showLoadingDialog(isDark);
  //
  //   try {
  //     final success = await context
  //         .read<PackageSubscriptionProvider>()
  //         .subscribeToPackage(
  //       package:        package,
  //       paymentResult:  paymentResult,
  //       overrideUserId: user.id.toString(), // ✅ تمرير مباشر
  //     );
  //
  //     if (!mounted) return;
  //     Navigator.pop(context);
  //
  //     if (!success) {
  //       _vibrateError();
  //       _showErrorSnackBar(
  //         context.read<PackageSubscriptionProvider>().error ??
  //             'حدث خطأ أثناء الاشتراك',
  //       );
  //       return;
  //     }
  //
  //     final hasVibrator = await Vibration.hasVibrator() ?? false;
  //     if (hasVibrator) await Vibration.vibrate(duration: 50);
  //
  //     final msg = paymentResult.paymentMethod == 'cash'
  //         ? 'اشتراكك فعّال! ادفع عند أول جلسة 💰'
  //         : 'جاري مراجعة إيصالك وتفعيل الاشتراك ✅';
  //
  //     _showSuccessSnackBar(
  //       '${package.nameAr}\n$msg',
  //       onActionPressed: () =>
  //           Navigator.pushNamed(context, '/my-subscriptions'),
  //     );
  //   } catch (e) {
  //     if (!mounted) return;
  //     Navigator.pop(context);
  //     _vibrateError();
  //     _showErrorSnackBar('حدث خطأ أثناء الاشتراك، حاول مرة أخرى');
  //   }
  // }

  // Future<void> _processSubscription({
  //   required PackageModel  package,
  //   required bool          isDark,
  //   required PaymentResult paymentResult,
  // }) async {
  //   _showLoadingDialog(isDark);
  //   try {
  //     // ✅ استخدام Provider بدلاً من Repository مباشرة
  //     final provider = context.read<PackageSubscriptionProvider>();
  //     final success  = await provider.subscribeToPackage(
  //       package:       package,
  //       paymentResult: paymentResult,
  //     );
  //
  //     if (!mounted) return;
  //     Navigator.pop(context); // إغلاق loading
  //
  //     if (!success) {
  //       _vibrateError();
  //       _showErrorSnackBar(provider.error ?? 'حدث خطأ أثناء الاشتراك');
  //       return;
  //     }
  //
  //     final hasVibrator = await Vibration.hasVibrator() ?? false;
  //     if (hasVibrator) await Vibration.vibrate(duration: 50);
  //
  //     final msg = paymentResult.paymentMethod == 'cash'
  //         ? 'اشتراكك فعّال! ادفع عند أول جلسة 💰'
  //         : 'جاري مراجعة إيصالك وتفعيل الاشتراك ✅';
  //
  //     _showSuccessSnackBar(
  //       '${package.nameAr}\n$msg',
  //       onActionPressed: () =>
  //           Navigator.pushNamed(context, '/my-subscriptions'),
  //     );
  //   } catch (e) {
  //     if (!mounted) return;
  //     Navigator.pop(context);
  //     _vibrateError();
  //     _showErrorSnackBar('حدث خطأ أثناء الاشتراك، حاول مرة أخرى');
  //   }
  // }

//   Future<void> _handleSubscribe(PackageModel package, bool isDark) async {
//     // إغلاق sheet التفاصيل أولاً
//     Navigator.pop(context);
//
//     // التحقق من تسجيل الدخول
//     final userProvider = context.read<UserProvider>();
//     if (userProvider.user == null) {
//       _showWarningSnackBar('يجب تسجيل الدخول أولاً');
//       _vibrateError();
//       return;
//     }
//
//     // فتح sheet اختيار طريقة الدفع
//     await Future.delayed(const Duration(milliseconds: 200));
//     if (!mounted) return;
//     _showPaymentMethodSheet(package, isDark);
//   }

// ═══════════════════════════════════════════════════════════════
// 💳 Step 2: Bottom Sheet اختيار طريقة الدفع
// ═══════════════════════════════════════════════════════════════
//   void _showPaymentMethodSheet(PackageModel package, bool isDark) {
//     final colors = _getPackageColors(package);
//
//     // طرق الدفع المتاحة
//     final List<Map<String, dynamic>> paymentMethods = [
//       {
//         'id':       'cash',
//         'label':    'الدفع عند الاستلام',
//         'subtitle': 'ادفع نقداً عند حضور الجلسة',
//         'icon':     Icons.payments_rounded,
//         'color':    Colors.green,
//       },
//       {
//         'id':       'card',
//         'label':    'البطاقة الائتمانية',
//         'subtitle': 'Visa / Mastercard / Mada',
//         'icon':     Icons.credit_card_rounded,
//         'color':    const Color(0xFF1565C0),
//       },
//       {
//         'id':       'wallet',
//         'label':    'المحفظة الإلكترونية',
//         'subtitle': 'Apple Pay / STC Pay / Mada Pay',
//         'icon':     Icons.account_balance_wallet_rounded,
//         'color':    const Color(0xFF6A1B9A),
//       },
//       {
//         'id':       'bank_transfer',
//         'label':    'تحويل بنكي',
//         'subtitle': 'تحويل مباشر عبر التطبيق البنكي',
//         'icon':     Icons.account_balance_rounded,
//         'color':    const Color(0xFF00838F),
//       },
//     ];
//
//     String? selectedMethodId;
//
//     showModalBottomSheet(
//       context:            context,
//       isScrollControlled: true,
//       backgroundColor:    Colors.transparent,
//       builder: (ctx) => StatefulBuilder(
//         builder: (context, setSheetState) {
//           return Container(
//             decoration: BoxDecoration(
//               color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
//             ),
//             child: SafeArea(
//               child: Padding(
//                 padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // ── Handle ─────────────────────────────────────
//                     Container(
//                       width: 40.w, height: 4.h,
//                       decoration: BoxDecoration(
//                         color:        Colors.grey.shade400,
//                         borderRadius: BorderRadius.circular(2.r),
//                       ),
//                     ),
//                     SizedBox(height: 20.h),
//
//                     // ── Header ─────────────────────────────────────
//                     Row(
//                       children: [
//                         Container(
//                           width: 48.w, height: 48.w,
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(colors: colors),
//                             borderRadius: BorderRadius.circular(14.r),
//                           ),
//                           child: Icon(
//                             Icons.workspace_premium_rounded,
//                             color: Colors.white, size: 24.sp,
//                           ),
//                         ),
//                         SizedBox(width: 14.w),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'اختر طريقة الدفع',
//                                 style: TextStyle(
//                                   fontSize:   20.sp,
//                                   fontWeight: FontWeight.bold,
//                                   color: isDark ? Colors.white : Colors.black87,
//                                 ),
//                               ),
//                               SizedBox(height: 2.h),
//                               Text(
//                                 '${package.nameAr} • ${package.price.toInt()} ريال',
//                                 style: TextStyle(
//                                   fontSize: 13.sp,
//                                   color:    Colors.grey.shade600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 20.h),
//
//                     // ── قائمة طرق الدفع ────────────────────────────
//                     ...paymentMethods.map((method) {
//                       final isSelected = selectedMethodId == method['id'];
//                       final methodColor = method['color'] as Color;
//
//                       return GestureDetector(
//                         onTap: () {
//                           setSheetState(() => selectedMethodId = method['id'] as String);
//                           HapticFeedback.lightImpact();
//                         },
//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 200),
//                           curve:    Curves.easeOutCubic,
//                           margin:   EdgeInsets.only(bottom: 12.h),
//                           padding:  EdgeInsets.all(16.r),
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? methodColor.withOpacity(0.08)
//                                 : isDark
//                                 ? Colors.grey.shade900
//                                 : const Color(0xFFF5F5F7),
//                             borderRadius: BorderRadius.circular(18.r),
//                             border: Border.all(
//                               color: isSelected
//                                   ? methodColor
//                                   : Colors.transparent,
//                               width: 2,
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               // ── أيقونة طريقة الدفع ───────────────
//                               AnimatedContainer(
//                                 duration: const Duration(milliseconds: 200),
//                                 width: 48.w, height: 48.w,
//                                 decoration: BoxDecoration(
//                                   color: isSelected
//                                       ? methodColor
//                                       : methodColor.withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(14.r),
//                                 ),
//                                 child: Icon(
//                                   method['icon'] as IconData,
//                                   color: isSelected
//                                       ? Colors.white
//                                       : methodColor,
//                                   size: 24.sp,
//                                 ),
//                               ),
//                               SizedBox(width: 14.w),
//
//                               // ── نص طريقة الدفع ───────────────────
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       method['label'] as String,
//                                       style: TextStyle(
//                                         fontSize:   15.sp,
//                                         fontWeight: FontWeight.bold,
//                                         color: isSelected
//                                             ? methodColor
//                                             : isDark
//                                             ? Colors.white
//                                             : Colors.black87,
//                                       ),
//                                     ),
//                                     SizedBox(height: 3.h),
//                                     Text(
//                                       method['subtitle'] as String,
//                                       style: TextStyle(
//                                         fontSize: 12.sp,
//                                         color:    Colors.grey.shade500,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//
//                               // ── مؤشر الاختيار ────────────────────
//                               AnimatedSwitcher(
//                                 duration: const Duration(milliseconds: 200),
//                                 child: isSelected
//                                     ? Container(
//                                   key: const ValueKey('selected'),
//                                   width: 26.w, height: 26.w,
//                                   decoration: BoxDecoration(
//                                     color: methodColor,
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: Icon(
//                                     Icons.check_rounded,
//                                     color: Colors.white,
//                                     size: 16.sp,
//                                   ),
//                                 )
//                                     : Container(
//                                   key: const ValueKey('unselected'),
//                                   width: 26.w, height: 26.w,
//                                   decoration: BoxDecoration(
//                                     border: Border.all(
//                                       color: Colors.grey.shade400,
//                                       width: 2,
//                                     ),
//                                     shape: BoxShape.circle,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }).toList(),
//
//                     SizedBox(height: 8.h),
//
//                     // ── ملاحظة الأمان ──────────────────────────────
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                           horizontal: 14.w, vertical: 10.h),
//                       decoration: BoxDecoration(
//                         color: Colors.green.withOpacity(0.07),
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.lock_rounded,
//                               size: 14.sp, color: Colors.green),
//                           SizedBox(width: 6.w),
//                           Text(
//                             'معاملاتك محمية وآمنة',
//                             style: TextStyle(
//                               fontSize: 12.sp,
//                               color:    Colors.green.shade700,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     SizedBox(height: 16.h),
//
//                     // ── زر تأكيد الاشتراك ──────────────────────────
//                     SizedBox(
//                       width: double.infinity,
//                       height: 56.h,
//                       child: AnimatedOpacity(
//                         duration: const Duration(milliseconds: 200),
//                         opacity:  selectedMethodId != null ? 1.0 : 0.5,
//                         child: ElevatedButton(
//                           onPressed: selectedMethodId == null
//                               ? null
//                               : () {
//                             Navigator.pop(context);
//                             _processSubscription(
//                               package:       package,
//                               isDark:        isDark,
//                               paymentMethod: selectedMethodId!,
//                               paymentLabel: (paymentMethods.firstWhere(
//                                     (m) => m['id'] == selectedMethodId,
//                               )['label'] as String),
//                             );
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: selectedMethodId != null
//                                 ? primaryRed
//                                 : Colors.grey,
//                             foregroundColor: Colors.white,
//                             elevation: selectedMethodId != null ? 4 : 0,
//                             shadowColor: primaryRed.withOpacity(0.4),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16.r),
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.workspace_premium_rounded,
//                                   size: 22.sp),
//                               SizedBox(width: 10.w),
//                               Text(
//                                 selectedMethodId == null
//                                     ? 'اختر طريقة الدفع أولاً'
//                                     : 'تأكيد الاشتراك • ${package.price.toInt()} ريال',
//                                 style: TextStyle(
//                                   fontSize:   17.sp,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 16.h),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
// // ═══════════════════════════════════════════════════════════════
// // ✅ Step 3: تنفيذ الاشتراك بعد اختيار طريقة الدفع
// // ═══════════════════════════════════════════════════════════════
//   Future<void> _processSubscription({
//     required PackageModel package,
//     required bool         isDark,
//     required String       paymentMethod,
//     required String       paymentLabel,
//   }) async {
//     final userProvider = context.read<UserProvider>();
//
//     _showLoadingDialog(isDark);
//
//     try {
//       final repository = PackageSubscriptionRepository();
//
//       await repository.subscribeToPackage(
//         userId:        userProvider.user!.id.toString(),
//         package:       package,
//         paymentMethod: paymentMethod,
//       );
//
//       if (!mounted) return;
//       Navigator.pop(context); // إغلاق loading
//
//       // اهتزاز النجاح
//       final hasVibrator = await Vibration.hasVibrator() ?? false;
//       if (hasVibrator) await Vibration.vibrate(duration: 50);
//
//       _showSuccessSnackBar(
//         'تم الاشتراك في ${package.nameAr} بنجاح! 🎉\nطريقة الدفع: $paymentLabel',
//         onActionPressed: () {
//           Navigator.pushNamed(context, '/my-subscriptions');
//         },
//       );
//     } catch (e) {
//       if (!mounted) return;
//       Navigator.pop(context); // إغلاق loading
//
//       final errorMessage = e.toString();
//
//       if (errorMessage.contains('لديك اشتراك نشط')) {
//         _vibrateError();
//         _showWarningSnackBar(
//             'لديك اشتراك نشط في هذه الباقة.\nيرجى إنهاء الاشتراك الحالي أولاً.');
//       } else if (errorMessage.contains('الباقة غير نشطة')) {
//         _vibrateError();
//         _showErrorSnackBar('هذه الباقة غير متاحة حالياً');
//       } else if (errorMessage.contains('الباقة منتهية')) {
//         _vibrateError();
//         _showErrorSnackBar('انتهت صلاحية هذه الباقة');
//       } else if (errorMessage.contains('الباقة لم تبدأ بعد')) {
//         _vibrateError();
//         _showWarningSnackBar('هذه الباقة ستكون متاحة قريباً');
//       } else {
//         _vibrateError();
//         _showErrorSnackBar('حدث خطأ أثناء الاشتراك. حاول مرة أخرى');
//       }
//     }
//   }

  // Future<void> _handleSubscribe(PackageModel package, bool isDark) async {
  //   // إغلاق الـ bottom sheet
  //   Navigator.pop(context);
  //
  //   // التحقق من تسجيل الدخول
  //   final userProvider = context.read<UserProvider>();
  //   if (userProvider.user == null) {
  //     _showWarningSnackBar('يجب تسجيل الدخول أولاً');
  //     _vibrateError(); // ✅ اهتزاز
  //     return;
  //   }
  //
  //   // عرض loading dialog
  //   _showLoadingDialog(isDark);
  //
  //   try {
  //     final repository = PackageSubscriptionRepository();
  //
  //     // الاشتراك في الباقة
  //     await repository.subscribeToPackage(
  //       userId: userProvider.user!.id.toString(),
  //       package: package,
  //       paymentMethod: 'نقد',
  //     );
  //
  //     if (!mounted) return;
  //
  //     // إغلاق loading dialog
  //     Navigator.pop(context);
  //
  //     // ✅ اهتزاز النجاح (خفيف)
  //     final hasVibrator = await Vibration.hasVibrator() ?? false;
  //     if (hasVibrator) {
  //       await Vibration.vibrate(duration: 50);
  //     }
  //
  //     // رسالة النجاح
  //     _showSuccessSnackBar(
  //       'تم الاشتراك في ${package.nameAr} بنجاح! 🎉',
  //       onActionPressed: () {
  //         // الانتقال لشاشة "باقاتي"
  //         Navigator.pushNamed(context, '/my-subscriptions');
  //       },
  //     );
  //   } catch (e) {
  //     if (!mounted) return;
  //     Navigator.pop(context);
  //
  //     final errorMessage = e.toString();
  //
  //     if (errorMessage.contains('لديك اشتراك نشط')) {
  //       _vibrateError(); // ✅ اهتزاز خطأ مكرر
  //       _showWarningSnackBar(
  //         'لديك اشتراك نشط في هذه الباقة بالفعل.\nيرجى إنهاء أو إلغاء الاشتراك الحالي أولاً.',
  //       );
  //     } else if (errorMessage.contains('الباقة غير نشطة')) {
  //       _vibrateError();
  //       _showErrorSnackBar('هذه الباقة غير متاحة حالياً');
  //     } else if (errorMessage.contains('الباقة منتهية')) {
  //       _vibrateError();
  //       _showErrorSnackBar('انتهت صلاحية هذه الباقة');
  //     } else if (errorMessage.contains('الباقة لم تبدأ بعد')) {
  //       _vibrateError();
  //       _showWarningSnackBar('هذه الباقة ستكون متاحة قريباً');
  //     } else {
  //       _vibrateError();
  //       _showErrorSnackBar('حدث خطأ أثناء الاشتراك. حاول مرة أخرى');
  //     }
  //   }
  // }

// ═══════════════════════════════════════════════════════════════
// 🎨 Helper Methods للـ Dialogs والـ SnackBars
// ═══════════════════════════════════════════════════════════════

  void _showLoadingDialog(bool isDark) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(32.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFFB6862C),
                  ),
                  strokeWidth: 3,
                ),
                SizedBox(height: 20.h),
                Text(
                  'جاري الاشتراك...',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message, {VoidCallback? onActionPressed}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.r),
        action: onActionPressed != null
            ? SnackBarAction(
          label: 'عرض',
          textColor: Colors.white,
          onPressed: onActionPressed,
        )
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.r),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.r),
      ),
    );
  }
// ═══════════════════════════════════════════════════════════════
// 📳 Vibration Helper Method
// ═══════════════════════════════════════════════════════════════

  Future<void> _vibrateError() async {
    // التحقق من دعم الهاتف للاهتزاز
    final hasVibrator = await Vibration.hasVibrator() ?? false;
    if (hasVibrator) {
      // اهتزاز قصير مرتين (مثل رفض الإجراء)
      await Vibration.vibrate(duration: 100);
      await Future.delayed(const Duration(milliseconds: 100));
      await Vibration.vibrate(duration: 100);
    }
  }

}

class AnimatedBorderCard extends StatefulWidget {
  final Widget child;
  final List<Color> borderColors;

  const AnimatedBorderCard({
    Key? key,
    required this.child,
    required this.borderColors,
  }) : super(key: key);

  @override
  State<AnimatedBorderCard> createState() => _AnimatedBorderCardState();
}

class _AnimatedBorderCardState extends State<AnimatedBorderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _AnimatedBorderPainter(
            animation: _controller,
            colors: widget.borderColors,
          ),
          child: Container(
            margin: EdgeInsets.all(6.w),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _AnimatedBorderPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Color> colors;

  _AnimatedBorderPainter({
    required this.animation,
    required this.colors,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(32.r),
    );

    final gradient = SweepGradient(
      colors: [
        const Color(0xFFFFD700),
        Colors.amber,
        const Color(0xFFFF8C00),
        Colors.amber.shade700,
        const Color(0xFFFFD700),
        Colors.transparent,
        Colors.transparent,
      ],
      stops: const [0.0, 0.15, 0.25, 0.35, 0.45, 0.6, 1.0],
      transform: GradientRotation(animation.value * 2 * 3.14159),
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.w;

    canvas.drawRRect(rrect, paint);

    final shadowPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha:0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.w
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawRRect(rrect, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}