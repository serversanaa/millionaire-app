import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../domain/models/package_model.dart';
import '../providers/packages_provider.dart';
import 'package_card.dart';

/// ═══════════════════════════════════════════════════════════════
/// 📦 Packages Grid Widget
/// عرض الباقات في Grid أو Horizontal Scroll
/// ═══════════════════════════════════════════════════════════════

class PackagesGrid extends StatelessWidget {
  final List<PackageModel>? packages;
  final bool isHorizontal;
  final Function(PackageModel)? onPackageTap;
  final EdgeInsets? padding;
  final double? cardWidth;
  final double? cardHeight;

  const PackagesGrid({
    Key? key,
    this.packages,
    this.isHorizontal = false,
    this.onPackageTap,
    this.padding,
    this.cardWidth,
    this.cardHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PackagesProvider>(
      builder: (context, provider, _) {
        final packagesList = packages ?? provider.packages;

        // ═══════════════════════════════════════════════════════════
        // Loading State
        // ═══════════════════════════════════════════════════════════
        if (provider.isLoading && packagesList.isEmpty) {
          return _buildLoadingState();
        }

        // ═══════════════════════════════════════════════════════════
        // Empty State
        // ═══════════════════════════════════════════════════════════
        if (packagesList.isEmpty) {
          return _buildEmptyState();
        }

        // ═══════════════════════════════════════════════════════════
        // Error State
        // ═══════════════════════════════════════════════════════════
        if (provider.hasError) {
          return _buildErrorState(provider.error!, provider);
        }

        // ═══════════════════════════════════════════════════════════
        // Packages Grid/List
        // ═══════════════════════════════════════════════════════════
        return isHorizontal
            ? _buildHorizontalList(packagesList)
            : _buildVerticalGrid(packagesList);
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Horizontal List
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHorizontalList(List<PackageModel> packagesList) {
    return SizedBox(
      height: cardHeight ?? 540.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: padding ?? EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: packagesList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < packagesList.length - 1 ? 20.w : 0,
            ),
            child: PackageCard(
              package: packagesList[index],
              width: cardWidth ?? 350.w,
              height: cardHeight ?? 520.h,
              onTap: () => onPackageTap?.call(packagesList[index]),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Vertical Grid
  // ═══════════════════════════════════════════════════════════════
  Widget _buildVerticalGrid(List<PackageModel> packagesList) {
    return GridView.builder(
      padding: padding ?? EdgeInsets.all(20.r),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.65,
      ),
      itemCount: packagesList.length,
      itemBuilder: (context, index) {
        return PackageCard(
          package: packagesList[index],
          onTap: () => onPackageTap?.call(packagesList[index]),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Loading State
  // ═══════════════════════════════════════════════════════════════
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
          SizedBox(height: 16.h),
          Text(
            'جاري تحميل الباقات...',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Empty State
  // ═══════════════════════════════════════════════════════════════
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد باقات متاحة حالياً',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'يرجى المحاولة مرة أخرى لاحقاً',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Error State
  // ═══════════════════════════════════════════════════════════════
  Widget _buildErrorState(String error, PackagesProvider provider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80.sp,
              color: Colors.red.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                provider.clearError();
                provider.refreshPackages();
              },
              icon: Icon(Icons.refresh),
              label: Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
