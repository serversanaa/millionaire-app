import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:confetti/confetti.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:millionaire_barber/core/constants/app_colors.dart';
import 'package:millionaire_barber/core/routes/app_routes.dart';
import 'dart:ui' as ui;

class BookingSuccessScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const BookingSuccessScreen({
    Key? key,
    required this.bookingData,
  }) : super(key: key);

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  final GlobalKey _captureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _confettiController.play();
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// ═══════════════════════════════════════════════════════════════
  /// BUILD
  /// ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        _navigateToHome();
        return false;
      },
      child: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
          body: Stack(
            children: [
              // ✅ المحتوى القابل للتصوير
              RepaintBoundary(
                key: _captureKey,
                child: Container(
                  color: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                      child: Column(
                        mainAxisSize:MainAxisSize.min,
                        children: [
                          SizedBox(height: 20.h),
                          _buildSuccessIcon(),
                          SizedBox(height: 15.h),
                          _buildTitle(isDark),
                          SizedBox(height: 12.h),
                          _buildSubtitle(isDark),
                          SizedBox(height: 15.h),
                          _buildBookingDetailsCard(isDark),
                          SizedBox(height: 15.h),
                          _buildAdditionalInfo(isDark),
                          SizedBox(height: 10.h),
                          _buildQRCode(isDark),
                          SizedBox(height: 120.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ✅ الأزرار
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.r),
                      topRight: Radius.circular(25.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: _buildActionButtons(isDark),
                  ),
                ),
              ),

              // ✅ Confetti
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  particleDrag: 0.05,
                  emissionFrequency: 0.05,
                  numberOfParticles: 50,
                  gravity: 0.05,
                  shouldLoop: false,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    AppColors.gold,
                    Colors.orange,
                    AppColors.darkRed,
                    Colors.purple,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// SUCCESS ICON
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildSuccessIcon() {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
      child: Container(
        width: 120.w,
        height: 120.h,
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          Icons.check_circle_rounded,
          size: 80.sp,
          color: Colors.green,
        ),
      ),
    ).animate().then().shake(duration: 500.ms);
  }

  /// ═══════════════════════════════════════════════════════════════
  /// TITLE & SUBTITLE
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildTitle(bool isDark) {
    return Text(
      'تم الحجز بنجاح! 🎉',
      style: TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : AppColors.black,
        fontFamily: 'Cairo',
      ),
      textAlign: TextAlign.center,
    ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2);
  }

  Widget _buildSubtitle(bool isDark) {
    return Text(
      'تم تأكيد موعدك بنجاح.\nسيتم إرسال رسالة تأكيد قريباً',
      style: TextStyle(
        fontSize: 16.sp,
        color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
        fontFamily: 'Cairo',
        height: 1.6,
      ),
      textAlign: TextAlign.center,
    ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.2);
  }

  /// ═══════════════════════════════════════════════════════════════
  /// BOOKING DETAILS CARD
  /// ═══════════════════════════════════════════════════════════════

  // Widget _buildBookingDetailsCard(bool isDark) {
  //   // ✅ قراءة آمنة بدون crash
  //   final serviceName   = widget.bookingData['service_name']   as String?   ?? 'خدمات متعددة';
  //   final date          = widget.bookingData['date']            as DateTime? ?? DateTime.now();
  //   final time          = widget.bookingData['time']            as String?   ?? '--';
  //   final finalPrice    = (widget.bookingData['final_price']    as num?)?.toDouble() ?? 0.0;
  //   final discount      = (widget.bookingData['discount']       as num?)?.toDouble();
  //   final pointsEarned  = widget.bookingData['points_earned']   as int?;
  //   final appointmentId = widget.bookingData['appointment_id']  as int?;
  //   final personsCount  = widget.bookingData['persons_count']   as int?;
  //   final isMulti       = widget.bookingData['is_multi']        as bool? ?? false;
  //
  //   // final serviceName = widget.bookingData['service_name'] as String;
  //   // final date = widget.bookingData['date'] as DateTime;
  //   // final time = widget.bookingData['time'] as String;
  //   // final finalPrice = widget.bookingData['final_price'] as double;
  //   // final discount = widget.bookingData['discount'] as double?;
  //   // final pointsEarned = widget.bookingData['points_earned'] as int?;
  //   // final appointmentId = widget.bookingData['appointment_id'] as int?;
  //
  //   return Container(
  //     padding: EdgeInsets.all(24.r),
  //     decoration: BoxDecoration(
  //       color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
  //       borderRadius: BorderRadius.circular(20.r),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.1),
  //           blurRadius: 20,
  //           offset: const Offset(0, 10),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // رقم الحجز
  //         if (appointmentId != null) ...[
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(
  //                 'رقم الحجز',
  //                 style: TextStyle(
  //                   fontSize: 14.sp,
  //                   color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
  //                   fontFamily: 'Cairo',
  //                 ),
  //               ),
  //               Container(
  //                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
  //                 decoration: BoxDecoration(
  //                   color: AppColors.darkRed.withOpacity(0.1),
  //                   borderRadius: BorderRadius.circular(20.r),
  //                 ),
  //                 child: Text(
  //                   '#${appointmentId.toString().padLeft(5, '0')}',
  //                   style: TextStyle(
  //                     fontSize: 14.sp,
  //                     fontWeight: FontWeight.bold,
  //                     color: AppColors.darkRed,
  //                     fontFamily: 'Cairo',
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 16.h),
  //           Divider(height: 1.h),
  //           SizedBox(height: 16.h),
  //         ],
  //
  //         // تفاصيل الحجز
  //         _buildDetailRow(Icons.design_services_rounded, 'الخدمة', serviceName, isDark),
  //         SizedBox(height: 16.h),
  //         _buildDetailRow(
  //           Icons.calendar_today_rounded,
  //           'التاريخ',
  //           DateFormat('EEEE, d MMMM yyyy', 'ar').format(date),
  //           isDark,
  //         ),
  //         SizedBox(height: 16.h),
  //         _buildDetailRow(Icons.access_time_rounded, 'الوقت', time, isDark),
  //         SizedBox(height: 16.h),
  //         _buildDetailRow(
  //           Icons.payments_rounded,
  //           'الإجمالي',
  //           '${finalPrice.toStringAsFixed(0)} ريال',
  //           isDark,
  //           valueColor: AppColors.gold,
  //         ),
  //
  //         // الخصم
  //         if (discount != null && discount > 0) ...[
  //           SizedBox(height: 16.h),
  //           Container(
  //             padding: EdgeInsets.all(12.r),
  //             decoration: BoxDecoration(
  //               color: Colors.green.withOpacity(0.1),
  //               borderRadius: BorderRadius.circular(12.r),
  //               border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
  //             ),
  //             child: Row(
  //               children: [
  //                 Icon(Icons.discount_rounded, color: Colors.green, size: 20.sp),
  //                 SizedBox(width: 12.w),
  //                 Text(
  //                   'وفرت ${discount.toStringAsFixed(0)} ريال',
  //                   style: TextStyle(
  //                     fontSize: 15.sp,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.green,
  //                     fontFamily: 'Cairo',
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //
  //         // نقاط الولاء
  //         if (pointsEarned != null && pointsEarned > 0) ...[
  //           SizedBox(height: 12.h),
  //           Container(
  //             padding: EdgeInsets.all(12.r),
  //             decoration: BoxDecoration(
  //               color: AppColors.gold.withOpacity(0.1),
  //               borderRadius: BorderRadius.circular(12.r),
  //               border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1),
  //             ),
  //             child: Row(
  //               children: [
  //                 Icon(Icons.stars_rounded, color: AppColors.gold, size: 20.sp),
  //                 SizedBox(width: 12.w),
  //                 Text(
  //                   '+$pointsEarned نقطة ولاء',
  //                   style: TextStyle(
  //                     fontSize: 15.sp,
  //                     fontWeight: FontWeight.bold,
  //                     color: AppColors.gold,
  //                     fontFamily: 'Cairo',
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ],
  //     ),
  //   ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3);
  // }

  Widget _buildBookingDetailsCard(bool isDark) {
    // ✅ قراءة آمنة لجميع البيانات
    final serviceName   = widget.bookingData['service_name']   as String?   ?? 'خدمات متعددة';
    final date          = widget.bookingData['date']            as DateTime? ?? DateTime.now();
    final time          = widget.bookingData['time']            as String?   ?? '--:--';
    final finalPrice    = (widget.bookingData['final_price']    as num?)?.toDouble() ?? 0.0;
    final discount      = (widget.bookingData['discount']       as num?)?.toDouble();
    final pointsEarned  = widget.bookingData['points_earned']   as int?;
    final appointmentId = widget.bookingData['appointment_id']  as int?;
    final personsCount  = widget.bookingData['persons_count']   as int?;
    final isMulti       = widget.bookingData['is_multi']        as bool? ?? false;

    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset:     const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── رقم الحجز ───────────────────────────────────────────
          if (appointmentId != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'رقم الحجز',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color:    isDark ? Colors.grey.shade400 : AppColors.greyDark,
                    fontFamily: 'Cairo',
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color:        AppColors.darkRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '#${appointmentId.toString().padLeft(5, '0')}',
                    style: TextStyle(
                      fontSize:   14.sp,
                      fontWeight: FontWeight.bold,
                      color:      AppColors.darkRed,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Divider(height: 1.h),
            SizedBox(height: 16.h),
          ],

          // ── الخدمة ───────────────────────────────────────────────
          _buildDetailRow(
            Icons.design_services_rounded,
            isMulti ? 'الخدمات' : 'الخدمة',
            serviceName,
            isDark,
          ),

          // ── عدد الأشخاص (حجز متعدد) ─────────────────────────────
          if (isMulti && personsCount != null) ...[
            SizedBox(height: 16.h),
            _buildDetailRow(
              Icons.people_outline_rounded,
              'عدد الأشخاص',
              '$personsCount ${personsCount == 1 ? 'شخص' : 'أشخاص'}',
              isDark,
            ),
          ],

          // ── التاريخ ──────────────────────────────────────────────
          SizedBox(height: 16.h),
          _buildDetailRow(
            Icons.calendar_today_rounded,
            'التاريخ',
            DateFormat('EEEE, d MMMM yyyy', 'ar').format(date),
            isDark,
          ),

          // ── الوقت ────────────────────────────────────────────────
          SizedBox(height: 16.h),
          _buildDetailRow(
            Icons.access_time_rounded,
            'الوقت',
            time,
            isDark,
          ),

          // ── السعر الإجمالي ───────────────────────────────────────
          SizedBox(height: 16.h),
          _buildDetailRow(
            Icons.payments_rounded,
            'الإجمالي',
            '${finalPrice.toStringAsFixed(0)} ر.ي',
            isDark,
            valueColor: AppColors.gold,
          ),

          // ── بطاقة الخصم ──────────────────────────────────────────
          if (discount != null && discount > 0) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color:        Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                    color: Colors.green.withOpacity(0.3), width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.discount_rounded,
                      color: Colors.green, size: 20.sp),
                  SizedBox(width: 12.w),
                  Text(
                    'وفّرت ${discount.toStringAsFixed(0)} ر.ي 🎉',
                    style: TextStyle(
                      fontSize:   15.sp,
                      fontWeight: FontWeight.bold,
                      color:      Colors.green,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── بطاقة نقاط الولاء ────────────────────────────────────
          if (pointsEarned != null && pointsEarned > 0) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color:        AppColors.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                    color: AppColors.gold.withOpacity(0.3), width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.stars_rounded,
                      color: AppColors.gold, size: 20.sp),
                  SizedBox(width: 12.w),
                  Text(
                    '+$pointsEarned نقطة ولاء ⭐',
                    style: TextStyle(
                      fontSize:   15.sp,
                      fontWeight: FontWeight.bold,
                      color:      AppColors.gold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── بطاقة الحجز المتعدد ──────────────────────────────────
          if (isMulti) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color:        AppColors.darkRed.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                    color: AppColors.darkRed.withOpacity(0.2), width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.group_rounded,
                      color: AppColors.darkRed, size: 20.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'حجز جماعي - ${personsCount ?? 0} ${(personsCount ?? 0) == 1 ? 'شخص' : 'أشخاص'}',
                      style: TextStyle(
                        fontSize:   14.sp,
                        fontWeight: FontWeight.w600,
                        color:      AppColors.darkRed,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3);
  }

  Widget _buildDetailRow(
      IconData icon,
      String label,
      String value,
      bool isDark, {
        Color? valueColor,
      }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.darkRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: AppColors.darkRed, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                  fontFamily: 'Cairo',
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? (isDark ? Colors.white : AppColors.black),
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// ADDITIONAL INFO
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildAdditionalInfo(bool isDark) {
    final appointmentId  = widget.bookingData['appointment_id'] as int?;
    final employeeName   = widget.bookingData['employee_name']  as String?;
    final status         = widget.bookingData['status']         as String? ?? 'pending';
    final paymentMethod  = widget.bookingData['payment_method'] as String?;

    // ✅ طريقة الدفع ديناميكية
    final paymentText = paymentMethod == 'electronic'
        ? 'تحويل إلكتروني'
        : 'الدفع عند الوصول';

    // final appointmentId = widget.bookingData['appointment_id'] as int?;
    // final employeeName = widget.bookingData['employee_name'] as String?;
    // final status = widget.bookingData['status'] as String? ?? 'pending';

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? const Color(0xFF1E1E1E) : Colors.white,
            isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                'معلومات إضافية',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.black,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(height: 1.h, color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          SizedBox(height: 16.h),

          // رقم الحجز
          if (appointmentId != null) ...[
            _buildInfoRow(
              icon: Icons.confirmation_number_rounded,
              label: 'رقم الحجز',
              value: '#${appointmentId.toString().padLeft(5, '0')}',
              isDark: isDark,
              valueColor: AppColors.darkRed,
              iconColor: AppColors.darkRed,
            ),
            SizedBox(height: 12.h),
          ],

          // تاريخ الإنشاء
          _buildInfoRow(
            icon: Icons.access_time_rounded,
            label: 'تاريخ الإنشاء',
            value: DateFormat('d MMMM yyyy - hh:mm a', 'ar').format(DateTime.now()),
            isDark: isDark,
            iconColor: Colors.blue,
          ),
          SizedBox(height: 12.h),

          // الموظف
          if (employeeName != null && employeeName.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.person_outline_rounded,
              label: 'الحلاق',
              value: employeeName,
              isDark: isDark,
              iconColor: Colors.purple,
            ),
            SizedBox(height: 12.h),
          ],

          // حالة الحجز
          _buildInfoRow(
            icon: Icons.check_circle_outline_rounded,
            label: 'الحالة',
            value: _getStatusText(status),
            isDark: isDark,
            valueColor: _getStatusColor(status),
            iconColor: _getStatusColor(status),
            badge: true,
          ),
          SizedBox(height: 12.h),

          // طريقة الدفع
          _buildInfoRow(
            icon: Icons.payment_rounded,
            label: 'طريقة الدفع',
            // value: 'الدفع عند الوصول',
            value: paymentText,
            isDark: isDark,
            iconColor: AppColors.gold,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2);
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    Color? valueColor,
    Color? iconColor,
    bool badge = false,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.darkRed).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: iconColor ?? AppColors.darkRed, size: 18.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                  fontFamily: 'Cairo',
                ),
              ),
              badge
                  ? Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: (valueColor ?? (isDark ? Colors.white : AppColors.black))
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: (valueColor ?? (isDark ? Colors.white : AppColors.black))
                        .withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? (isDark ? Colors.white : AppColors.black),
                    fontFamily: 'Cairo',
                  ),
                ),
              )
                  : Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? (isDark ? Colors.white : AppColors.black),
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'مؤكد';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return 'قيد الانتظار';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// QR CODE
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildQRCode(bool isDark) {
    final appointmentId = widget.bookingData['appointment_id'] as int?;
    if (appointmentId == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'رمز التحقق',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.black,
              fontFamily: 'Cairo',
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'أظهر هذا الرمز عند وصولك للصالون',
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
              ],
            ),
            child: QrImageView(
              data: 'APPOINTMENT_$appointmentId',
              version: QrVersions.auto,
              size: 180.w,
              backgroundColor: Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).scale();
  }

  /// ═══════════════════════════════════════════════════════════════
  /// ACTION BUTTONS
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton.icon(
            onPressed: _saveAsImage,
            icon: Icon(Icons.download_rounded, size: 20.sp),
            label: Text(
              'حفظ كصورة',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              elevation: 0,
            ),
          ),
        ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.2),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton.icon(
            onPressed: _navigateToHome,
            icon: Icon(Icons.home_rounded, size: 20.sp),
            label: Text(
              'العودة للرئيسية',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              elevation: 0,
            ),
          ),
        ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3),
      ],
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// SAVE AS IMAGE
  /// ═══════════════════════════════════════════════════════════════

  Future<void> _saveAsImage() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    try {

      // ✅ 1. طلب الأذن
      final permission = await _requestStoragePermission();
      if (!permission) {
        _showSnackBar('❌ يرجى السماح بالوصول إلى المعرض', Colors.red);
        return;
      }

      _confettiController.stop();

      // ✅ 2. عرض مؤشر التحميل
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black.withOpacity(0.7),
          builder: (_) => BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.download_rounded,
                              size: 40.sp,
                              color: AppColors.gold,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: 40.w,
                      height: 40.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'جاري حفظ لقطة الشاشة...',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.black,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'يرجى الانتظار',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.8, 0.8)),
            ),
          ),
        );
      }

      // ✅ 3. انتظر قليلاً قبل التقاط الصورة
      await Future.delayed(const Duration(milliseconds: 500));

      // ✅ 4. التقاط الشاشة من RepaintBoundary
      final RenderRepaintBoundary boundary =
      _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // استخدم pixelRatio عالي للجودة العالية
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      // ✅ 5. تحويل الصورة إلى PNG
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('فشل تحويل الصورة إلى بيانات');
      }

      final Uint8List imageBytes = byteData.buffer.asUint8List();

      // ✅ 6. حفظ في المعرض باستخدام image_gallery_saver_plus

      final timestamp = DateTime.now();
      final fileName = 'حجز_${timestamp.year}${timestamp.month}${timestamp.day}_${timestamp.hour}${timestamp.minute}${timestamp.second}';

      final result = await ImageGallerySaverPlus.saveImage(
        imageBytes,
        quality: 100,
        name: fileName,
      );


      // ✅ 7. التحقق من النتيجة
      if (result != null && result is Map) {
        if (result['isSuccess'] == true) {

          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context); // إغلاق مؤشر التحميل
          }

          _showSnackBar('✅ تم حفظ لقطة الشاشة في المعرض بنجاح!', Colors.green);
        } else {
          throw Exception('فشل الحفظ: ${result['error'] ?? 'خطأ غير معروف'}');
        }
      } else if (result == true) {
        // بعض الإصدارات ترجع true مباشرة

        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        _showSnackBar('✅ تم حفظ لقطة الشاشة في المعرض بنجاح!', Colors.green);
      } else {
        throw Exception('نتيجة غير متوقعة من حفظ الصورة');
      }
    } catch (e, stackTrace) {

      // إغلاق مؤشر التحميل في حالة الخطأ
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      _showSnackBar('❌ حدث خطأ: ${e.toString()}', Colors.red);
    }
  }

  /// ✅ دالة طلب الأذونات المحسّنة
  Future<bool> _requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdk = androidInfo.version.sdkInt;


        if (sdk >= 33) {
          // ✅ Android 13+ (API 33+)
          final status = await Permission.photos.request();

          if (status.isPermanentlyDenied) {
            openAppSettings();
            return false;
          }
          return status.isGranted || status.isLimited;

        } else if (sdk >= 30) {
          // ✅ Android 11-12 (API 30-32)
          var status = await Permission.storage.request();

          if (status.isDenied) {
            status = await Permission.manageExternalStorage.request();
          }

          if (status.isPermanentlyDenied) {
            openAppSettings();
            return false;
          }
          return status.isGranted;

        } else {
          // ✅ Android 10 وأقل (API 29-)
          final status = await Permission.storage.request();

          if (status.isPermanentlyDenied) {
            openAppSettings();
            return false;
          }
          return status.isGranted;
        }
      } else if (Platform.isIOS) {
        // ✅ iOS
        final status = await Permission.photosAddOnly.request();

        if (status.isPermanentlyDenied) {
          openAppSettings();
          return false;
        }
        return status.isGranted || status.isLimited;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// ✅ دالة عرض الرسائل
  void _showSnackBar(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            color: Colors.white,
          ),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20.r),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }
  void _navigateToHome() {
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
  }
}