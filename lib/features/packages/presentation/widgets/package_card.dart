import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/models/package_model.dart';
import 'package_service_item.dart';
import '../../../../core/constants/app_colors.dart';

/// ═══════════════════════════════════════════════════════════════
/// 📦 Package Card Widget
/// بطاقة عرض الباقة (مثل: الباقة الذهبية، الفضية...)
/// ═══════════════════════════════════════════════════════════════

class PackageCard extends StatelessWidget {
  final PackageModel package;
  final VoidCallback? onTap;
  final bool showShadow;
  final double? width;
  final double? height;

  const PackageCard({
    Key? key,
    required this.package,
    this.onTap,
    this.showShadow = true,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 350.w,
        height: height ?? 520.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: showShadow
              ? [
            BoxShadow(
              color: package.primaryColor.withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ]
              : null,
        ),
        child: Stack(
          children: [
            // ═══════════════════════════════════════════════════════════
            // Background Gradient
            // ═══════════════════════════════════════════════════════════
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    package.primaryColor,
                    package.secondaryColor,
                    package.secondaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(28.r),
              ),
            ),

            // ═══════════════════════════════════════════════════════════
            // Pattern Overlay
            // ═══════════════════════════════════════════════════════════
            Positioned.fill(
              child: CustomPaint(
                painter: _CardPatternPainter(),
              ),
            ),

            // ═══════════════════════════════════════════════════════════
            // Content
            // ═══════════════════════════════════════════════════════════
            Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ═══════════════════════════════════════════════════════
                  // Header (Logo + Title)
                  // ═══════════════════════════════════════════════════════
                  _buildHeader(),

                  SizedBox(height: 20.h),

                  // ═══════════════════════════════════════════════════════
                  // Services List
                  // ═══════════════════════════════════════════════════════
                  Expanded(
                    child: _buildServicesList(),
                  ),

                  SizedBox(height: 16.h),

                  // ═══════════════════════════════════════════════════════
                  // Price Section
                  // ═══════════════════════════════════════════════════════
                  _buildPriceSection(),

                  SizedBox(height: 16.h),

                  // ═══════════════════════════════════════════════════════
                  // Action Button
                  // ═══════════════════════════════════════════════════════
                  _buildActionButton(),
                ],
              ),
            ),

            // ═══════════════════════════════════════════════════════════
            // Expiring Soon Badge
            // ═══════════════════════════════════════════════════════════
            if (package.isExpiringSoon) _buildExpiringSoonBadge(),

            // ═══════════════════════════════════════════════════════════
            // Discount Badge
            // ═══════════════════════════════════════════════════════════
            if (package.hasDiscount) _buildDiscountBadge(),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Header Section
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            // Logo/Icon
            if (package.iconUrl != null)
              CircleAvatar(
                radius: 24.r,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(
                  Icons.diamond,
                  color: Colors.white,
                  size: 28.sp,
                ),
              )
            else
              Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: 32.sp,
              ),

            SizedBox(height: 12.h),

            // Package Name
            Text(
              package.nameAr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Services List
  // ═══════════════════════════════════════════════════════════════

  Widget _buildServicesList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: package.services.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: PackageServiceItem(
            service: package.services[index],
            textColor: Colors.white,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Price Section
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPriceSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Original Price (crossed out)
        if (package.hasDiscount) ...[
          Text(
            '${package.originalPrice!.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 20.sp,
              color: Colors.white.withOpacity(0.7),
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.white.withOpacity(0.7),
              decorationThickness: 2,
            ),
          ),
          SizedBox(width: 12.w),
        ],

        // Current Price
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'ريال',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              package.price.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 52.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 0.9,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Action Button
  // ═══════════════════════════════════════════════════════════════

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        child: Text(
          'توصل الآن',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Expiring Soon Badge
  // ═══════════════════════════════════════════════════════════════

  Widget _buildExpiringSoonBadge() {
    return Positioned(
      top: 16.h,
      right: 16.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Discount Badge
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDiscountBadge() {
    return Positioned(
      top: 16.h,
      left: 16.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          'خصم ${package.calculatedDiscountPercentage}%',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════
/// 🎨 Card Pattern Painter
/// رسم النمط على الخلفية
/// ═══════════════════════════════════════════════════════════════

class _CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw circles pattern
    for (double i = 0; i < size.width; i += 40) {
      for (double j = 0; j < size.height; j += 40) {
        canvas.drawCircle(Offset(i, j), 2, paint);
      }
    }

    // Draw diagonal lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
