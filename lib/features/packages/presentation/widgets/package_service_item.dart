import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/models/package_service_model.dart';

/// ═══════════════════════════════════════════════════════════════
/// 📋 Package Service Item Widget
/// عنصر خدمة واحدة ضمن الباقة (مثل: حلاقة، مساج...)
/// ═══════════════════════════════════════════════════════════════

class PackageServiceItem extends StatelessWidget {
  final PackageServiceModel service;
  final Color? textColor;
  final Color? iconColor;
  final Color? backgroundColor;
  final double? fontSize;
  final bool showDivider;

  const PackageServiceItem({
    Key? key,
    required this.service,
    this.textColor,
    this.iconColor,
    this.backgroundColor,
    this.fontSize,
    this.showDivider = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // ═══════════════════════════════════════════════════════════
            // Number Badge (الدائرة المرقمة)
            // ═══════════════════════════════════════════════════════════
            _buildNumberBadge(),

            SizedBox(width: 12.w),

            // ═══════════════════════════════════════════════════════════
            // Service Name
            // ═══════════════════════════════════════════════════════════
            Expanded(
              child: Text(
                service.nameAr,
                style: TextStyle(
                  fontSize: fontSize ?? 15.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? Colors.white,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),

        // Divider
        if (showDivider) ...[
          SizedBox(height: 8.h),
          Divider(
            color: (textColor ?? Colors.white).withOpacity(0.2),
            thickness: 0.5,
          ),
        ],
      ],
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// Number Badge (الدائرة المرقمة)
  /// ═══════════════════════════════════════════════════════════════
  Widget _buildNumberBadge() {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: (iconColor ?? Colors.white).withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          '${service.iconNumber ?? service.displayOrder}',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: iconColor ?? Colors.white,
          ),
        ),
      ),
    );
  }
}
