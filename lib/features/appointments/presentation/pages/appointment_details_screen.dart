import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:millionaire_barber/core/constants/app_colors.dart';
import 'package:millionaire_barber/features/appointments/domain/models/appointment_model.dart';
import 'package:millionaire_barber/features/appointments/domain/models/electronic_wallet_model.dart';
import 'package:millionaire_barber/features/appointments/presentation/providers/appointment_provider.dart';
import 'package:millionaire_barber/features/profile/presentation/providers/user_provider.dart';
import 'package:millionaire_barber/shared/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  final AppointmentModel appointment;

  const AppointmentDetailsScreen({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  State<AppointmentDetailsScreen> createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _qrAnimationController;
  static const String phoneNumber = '775999992';
  static const String countryCode = '+967';
  static const String locationUrl = 'https://maps.app.goo.gl/WUB57RSDErzutR528';
  ElectronicWalletModel? _walletData;

  @override
  void initState() {
    super.initState();
    _qrAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _loadWalletIfNeeded();

  }

  // ✅ دالة جلب المحفظة إذا لم تكن موجودة في الـ model
  Future<void> _loadWalletIfNeeded() async {
    // إذا كانت المحفظة موجودة أصلاً، استخدمها مباشرة
    if (widget.appointment.electronicWallet != null) {
      setState(() => _walletData = widget.appointment.electronicWallet);
      return;
    }

    // إذا كان الدفع إلكترونياً لكن المحفظة غير محملة، اجلبها من Supabase
    if (!widget.appointment.isElectronicPayment) return;

    try {
      // جلب الموعد مع join للمحفظة
      final response = await Supabase.instance.client
          .from('appointments')
          .select('electronic_wallet_id, electronic_wallets(*)')
          .eq('id', widget.appointment.id!)
          .single();

      final walletJson = response['electronic_wallets'];
      if (walletJson != null && mounted) {
        setState(() {
          _walletData = ElectronicWalletModel.fromJson(
            walletJson as Map<String, dynamic>,
          );
        });
      }
    } catch (e) {
      debugPrint('⚠️ فشل جلب المحفظة: $e');
    }
  }

  @override
  void dispose() {
    _qrAnimationController.dispose();
    super.dispose();
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
        appBar: _buildAppBar(isDark),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(isDark),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    // ✅ QR Code Card
                    if (widget.appointment.isPending ||
                        widget.appointment.isConfirmed)
                      SizedBox(height: 16.h),
                    _buildStatusCard(isDark),
                    SizedBox(height: 16.h),
                    _buildDetailsCard(isDark),
                    SizedBox(height: 16.h),
                    _buildServicesCard(isDark),
                    SizedBox(height: 16.h),
                    // ✅ جديد: بطاقة الأشخاص (للحجز الجماعي فقط)
                    if (widget.appointment.personsCount > 1) ...[
                      _buildGroupPersonsCard(isDark),
                      SizedBox(height: 16.h),
                    ],

                    _buildEmployeeCard(isDark),
                    SizedBox(height: 16.h),
                    _buildContactActionsCard(isDark),

// ✅ جديد: بطاقة الإيصال (للدفع الإلكتروني فقط)
                    if (widget.appointment.isElectronicPayment) ...[
                      SizedBox(height: 16.h),
                      _buildReceiptCard(isDark),
                    ],

                    // ✅ Contact Actions (Call, WhatsApp, Location)
                    SizedBox(height: 16.h),

                    if (widget.appointment.notes != null &&
                        widget.appointment.notes!.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      _buildNotesCard(isDark),
                    ],
                    if (widget.appointment.discountAmount > 0) ...[
                      SizedBox(height: 16.h),
                      _buildRewardUsedCard(isDark),
                    ],
                    SizedBox(height: 16.h),
                    _buildPaymentCard(isDark),

                    // ✅ Timeline للحالة
                    if (widget.appointment.isPending ||
                        widget.appointment.isConfirmed ||
                        widget.appointment.isInProgress) ...[
                      SizedBox(height: 16.h),
                      _buildStatusTimeline(isDark),
                    ],

                    SizedBox(height: 120.h),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomActions(isDark),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// APP BAR
  /// ═══════════════════════════════════════════════════════════════

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Padding(
        padding: EdgeInsets.all(8.r),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20.sp),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
      actions: [
        // ✅ Share Button
        Padding(
          padding: EdgeInsets.all(8.r),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.share_rounded, color: Colors.white, size: 20.sp),
              onPressed: _shareAppointment,
              padding: EdgeInsets.zero,
            ),
          ),
        ),

        // ✅ QR Code Button - يفتح Overlay Dialog
        if (widget.appointment.isPending || widget.appointment.isConfirmed)
          Padding(
            padding: EdgeInsets.all(8.r),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.qr_code_rounded,
                    color: Colors.white, size: 20.sp),
                onPressed: _showQRCodeOverlay,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
      ],
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// HEADER
  /// ═══════════════════════════════════════════════════════════════
  Widget _buildHeader(bool isDark) {
    return SizedBox(
      height: 260.h,
      child: Stack(
        children: [
          // ✅ Background يملأ كل المساحة بدون SafeArea
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppColors.darkRed,
                    AppColors.darkRed.withOpacity(0.85),
                    AppColors.darkRedDark,
                  ],
                ),
              ),
              child: CustomPaint(
                painter: _HeaderPatternPainter(
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
          ),

          // ✅ Animated Circles
          ...List.generate(6, (i) {
            return Positioned(
              top: (i * 45.0) % 240.h,
              left: (i * 70.0) % MediaQuery.of(context).size.width,
              child: Container(
                width: (20 + i * 8.0).w,
                height: (20 + i * 8.0).h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.12),
                      Colors.white.withOpacity(0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                  .moveY(
                duration: (2500 + i * 400).ms,
                begin: 0,
                end: 35,
                curve: Curves.easeInOut,
              )
                  .then()
                  .moveY(duration: (2500 + i * 400).ms, begin: 35, end: 0),
            );
          }),

          // ✅ Shimmer
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ).animate(onPlay: (controller) => controller.repeat())
                .moveX(duration: 3000.ms, begin: -200, end: 200),
          ),

          // ✅ Content مع SafeArea فقط للمحتوى
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon Stack
                    Flexible(
                      flex: 5,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: 110.w,
                              maxHeight: 110.h,
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _getStatusColor(widget.appointment.status).withOpacity(0.35),
                                  _getStatusColor(widget.appointment.status).withOpacity(0.15),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                              .scale(duration: 2000.ms, begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),

                          // Icon
                          Container(
                            width: 80.w,
                            height: 80.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              _getStatusIcon(widget.appointment.status),
                              size: 42.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                    ),

                    SizedBox(height: 10.h),

                    // Status Text
                    Flexible(
                      flex: 2,
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.white, Color(0xFFFFF8DC), Colors.white],
                        ).createShader(bounds),
                        child: Text(
                          _getStatusText(widget.appointment.status),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontFamily: 'Cairo',
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                    ),

                    SizedBox(height: 8.h),

                    // Badge
                    Flexible(
                      flex: 2,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.25),
                              Colors.white.withOpacity(0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.confirmation_number_rounded,
                                color: Colors.white,
                                size: 14.sp,
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                'رقم الحجز: #${widget.appointment.id?.toString().padLeft(5, '0') ?? ''}',
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
                      ).animate().fadeIn(delay: 300.ms).scale(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  /// ═══════════════════════════════════════════════════════════════
  /// QR CODE CARD
  /// ═══════════════════════════════════════════════════════════════

  /// ═══════════════════════════════════════════════════════════════
  /// QR CODE OVERLAY DIALOG
  /// ═══════════════════════════════════════════════════════════════

  void _showQRCodeOverlay() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'QR Code',
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 30.w),
                    padding: EdgeInsets.all(30.r),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.gold,
                          AppColors.gold.withValues(alpha: 0.9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✅ Close Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.qr_code_scanner_rounded,
                                  color: Colors.white,
                                  size: 28.sp,
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  'رمز التحقق',
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: EdgeInsets.all(6.r),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'أظهر هذا الرمز عند وصولك للصالون',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),

                        // ✅ QR Code
                        Container(
                          padding: EdgeInsets.all(20.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: 'APPOINTMENT_${widget.appointment.id}',
                            version: QrVersions.auto,
                            size: 220.w,
                            backgroundColor: Colors.white,
                            errorCorrectionLevel: QrErrorCorrectLevel.H,
                          ),
                        )
                            .animate(
                                onPlay: (controller) => controller.repeat())
                            .then(delay: 3000.ms)
                            .shimmer(
                                duration: 1500.ms,
                                color: AppColors.gold.withValues(alpha: 0.3)),

                        SizedBox(height: 20.h),

                        // ✅ Appointment ID
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(15.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'رقم الحجز',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '#${widget.appointment.id?.toString().padLeft(5, '0')}',
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // ✅ Info Text
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'اضغط في أي مكان للإغلاق',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// STATUS CARD
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildStatusCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color:
              _getStatusColor(widget.appointment.status).withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(widget.appointment.status)
                .withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: _getStatusColor(widget.appointment.status)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              _getStatusIcon(widget.appointment.status),
              color: _getStatusColor(widget.appointment.status),
              size: 28.sp,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .then(delay: 2000.ms)
              .shimmer(duration: 1000.ms),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حالة الموعد',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _getStatusText(widget.appointment.status),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(widget.appointment.status),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _getStatusColor(widget.appointment.status)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: _getStatusColor(widget.appointment.status)
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              _getStatusText(widget.appointment.status),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(widget.appointment.status),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }


  /// ═══════════════════════════════════════════════════════════════
  /// DETAILS CARD
  /// ═══════════════════════════════════════════════════════════════
  /// ═══════════════════════════════════════════════════════════════
  /// DETAILS CARD
  /// ═══════════════════════════════════════════════════════════════
  Widget _buildDetailsCard(bool isDark) {
    final appointment = widget.appointment;

    // ✅ هذا هو التغيير الوحيد — السطر القديم كان:
    // final wallet = appointment.electronicWallet;
    final wallet = _walletData ?? appointment.electronicWallet;

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(children: [
            Icon(Icons.calendar_month_rounded,
                color: AppColors.darkRed, size: 22.sp),
            SizedBox(width: 10.w),
            Text(
              'تفاصيل الموعد',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.black,
              ),
            ),
          ]),
          Divider(height: 24.h),

          _buildDetailRow(
            Icons.calendar_today_rounded,
            'التاريخ',
            DateFormat('EEEE، d MMMM yyyy', 'ar')
                .format(appointment.appointmentDate),
            isDark,
          ),
          SizedBox(height: 16.h),

          _buildDetailRow(
            Icons.access_time_rounded,
            'الوقت',
            _formatTimeArabic(appointment.appointmentTime),
            isDark,
          ),
          SizedBox(height: 16.h),

          _buildDetailRow(
            Icons.timer_rounded,
            'المدة',
            '${appointment.durationMinutes} دقيقة',
            isDark,
          ),
          SizedBox(height: 16.h),

          _buildDetailRow(
            Icons.person_outline_rounded,
            'اسم العميل',
            appointment.clientName,
            isDark,
          ),
          SizedBox(height: 16.h),

          _buildDetailRow(
            Icons.phone_rounded,
            'رقم الهاتف',
            appointment.clientPhone,
            isDark,
          ),

          if (appointment.personsCount > 1) ...[
            SizedBox(height: 16.h),
            _buildDetailRow(
              Icons.people_rounded,
              'عدد الأشخاص',
              '${appointment.personsCount} أشخاص',
              isDark,
              highlight: true,
            ),
          ],

          if (appointment.paymentMethod != null &&
              appointment.paymentMethod!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildDetailRow(
              appointment.isElectronicPayment
                  ? Icons.account_balance_wallet_rounded
                  : Icons.payments_rounded,
              'طريقة الدفع',
              appointment.isElectronicPayment ? '💳 دفع إلكتروني' : '💵 دفع نقدي',
              isDark,
            ),

            // ✅ الآن wallet يستخدم _walletData أولاً، فلن يكون null
            if (appointment.isElectronicPayment && wallet != null) ...[
              SizedBox(height: 16.h),
              _buildWalletDetailRow(wallet, isDark),
            ],
          ],
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2);
  }

  /// بطاقة المحفظة مع الأيقونة ورقم الهاتف
  // Widget _buildWalletDetailRow(ElectronicWalletModel wallet, bool isDark) {
  //   final name = wallet.walletNameAr.isNotEmpty
  //       ? wallet.walletNameAr
  //       : wallet.walletName;
  //
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: [
  //       // ── أيقونة المحفظة ────────────────────────────────────────
  //       Container(
  //         width: 36.w,
  //         height: 36.h,
  //         decoration: BoxDecoration(
  //           color: const Color(0xFFB8860B).withValues(alpha: 0.1),
  //           borderRadius: BorderRadius.circular(8.r),
  //           border: Border.all(
  //             color: const Color(0xFFB8860B).withValues(alpha: 0.25),
  //           ),
  //         ),
  //         child: ClipRRect(
  //           borderRadius: BorderRadius.circular(8.r),
  //           child: wallet.iconUrl != null && wallet.iconUrl!.isNotEmpty
  //               ? Image.network(
  //             wallet.iconUrl!,
  //             fit: BoxFit.contain,
  //             errorBuilder: (_, __, ___) => _walletFallbackIcon(wallet),
  //           )
  //               : Image.asset(
  //             wallet.iconAsset,
  //             fit: BoxFit.contain,
  //             errorBuilder: (_, __, ___) => _walletFallbackIcon(wallet),
  //           ),
  //         ),
  //       ),
  //       SizedBox(width: 12.w),
  //
  //       // ── اسم المحفظة + رقم الحساب ─────────────────────────────
  //       Expanded(
  //         flex: 3,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               name,
  //               style: TextStyle(
  //                 fontSize: 15.sp,
  //                 fontWeight: FontWeight.bold,
  //                 color: isDark ? Colors.white : AppColors.black,
  //               ),
  //             ),
  //             if (wallet.phoneNumber.isNotEmpty) ...[
  //               SizedBox(height: 2.h),
  //               Text(
  //                 wallet.phoneNumber,
  //                 style: TextStyle(
  //                   fontSize: 12.sp,
  //                   color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
  //                 ),
  //               ),
  //             ],
  //           ],
  //         ),
  //       ),
  //
  //       // ── Badge تأكيد ───────────────────────────────────────────
  //       Container(
  //         padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
  //         decoration: BoxDecoration(
  //           color: const Color(0xFFB8860B).withValues(alpha: 0.1),
  //           borderRadius: BorderRadius.circular(8.r),
  //           border: Border.all(
  //             color: const Color(0xFFB8860B).withValues(alpha: 0.3),
  //           ),
  //         ),
  //         child: Text(
  //           'تم الدفع',
  //           style: TextStyle(
  //             fontSize: 11.sp,
  //             fontWeight: FontWeight.bold,
  //             color: const Color(0xFFB8860B),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // /// أيقونة احتياطية إذا فشل تحميل الصورة
  // Widget _walletFallbackIcon(ElectronicWalletModel wallet) {
  //   return Center(
  //     child: Icon(
  //       Icons.account_balance_wallet_rounded,
  //       color: const Color(0xFFB8860B),
  //       size: 20.sp,
  //     ),
  //   );
  // }


  // Widget _buildDetailsCard(bool isDark) {
  //   return Container(
  //     padding: EdgeInsets.all(20.r),
  //     decoration: BoxDecoration(
  //       color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
  //       borderRadius: BorderRadius.circular(16.r),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: 0.05),
  //           blurRadius: 10,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(children: [
  //           Icon(Icons.calendar_month_rounded,
  //               color: AppColors.darkRed, size: 22.sp),
  //           SizedBox(width: 10.w),
  //           Text('تفاصيل الموعد',
  //               style: TextStyle(
  //                 fontSize: 18.sp,
  //                 fontWeight: FontWeight.bold,
  //                 color: isDark ? Colors.white : AppColors.black,
  //               )),
  //         ]),
  //         Divider(height: 24.h),
  //         _buildDetailRow(
  //           Icons.calendar_today_rounded,
  //           'التاريخ',
  //           DateFormat('EEEE، d MMMM yyyy', 'ar')
  //               .format(widget.appointment.appointmentDate),
  //           isDark,
  //         ),
  //         SizedBox(height: 16.h),
  //         _buildDetailRow(
  //           Icons.access_time_rounded,
  //           'الوقت',
  //           _formatTimeArabic(widget.appointment.appointmentTime),
  //           isDark,
  //         ),
  //         SizedBox(height: 16.h),
  //         _buildDetailRow(
  //           Icons.timer_rounded,
  //           'المدة',
  //           '${widget.appointment.durationMinutes} دقيقة',
  //           isDark,
  //         ),
  //         SizedBox(height: 16.h),
  //         _buildDetailRow(
  //           Icons.person_outline_rounded,
  //           'اسم العميل',
  //           widget.appointment.clientName,
  //           isDark,
  //         ),
  //         SizedBox(height: 16.h),
  //         _buildDetailRow(
  //           Icons.phone_rounded,
  //           'رقم الهاتف',
  //           widget.appointment.clientPhone,
  //           isDark,
  //         ),
  //
  //         // ✅ جديد: عدد الأشخاص
  //         if (widget.appointment.personsCount > 1) ...[
  //           SizedBox(height: 16.h),
  //           _buildDetailRow(
  //             Icons.people_rounded,
  //             'عدد الأشخاص',
  //             '${widget.appointment.personsCount} أشخاص',
  //             isDark,
  //             highlight: true,         // ✅ تمييز بصري
  //           ),
  //         ],
  //
  //         // ✅ جديد: طريقة الدفع
  //         if (widget.appointment.paymentMethod != null &&
  //             widget.appointment.paymentMethod!.isNotEmpty) ...[
  //           SizedBox(height: 16.h),
  //           _buildDetailRow(
  //             Icons.payment_rounded,
  //             'طريقة الدفع',
  //             _getPaymentMethodText(widget.appointment.paymentMethod!),
  //             isDark,
  //           ),
  //         ],
  //       ],
  //     ),
  //   ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2);
  // }


  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'unpaid':   return Colors.orange;
      case 'paid':     return Colors.green;
      case 'partial':  return Colors.blue;
      case 'refunded': return Colors.purple;
      default:         return Colors.grey;
    }
  }

  IconData _getPaymentStatusIcon(String status) {
    switch (status) {
      case 'unpaid':   return Icons.hourglass_empty_rounded;
      case 'paid':     return Icons.check_circle_rounded;
      case 'partial':  return Icons.pending_rounded;
      case 'refunded': return Icons.currency_exchange_rounded;
      default:         return Icons.help_outline_rounded;
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// SERVICES CARD
  /// ═══════════════════════════════════════════════════════════════
  Widget _buildServicesCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.gold.withOpacity(0.2), AppColors.gold.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.design_services_rounded, color: AppColors.gold, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                'الخدمات المطلوبة',
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

          if (widget.appointment.services != null && widget.appointment.services!.isNotEmpty)
            ...widget.appointment.services!.asMap().entries.map((entry) {
              final index = entry.key;
              final service = entry.value;

              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : AppColors.gold.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.gold, AppColors.gold.withOpacity(0.8)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 20.sp),
                    ),

                    SizedBox(width: 14.w),

                    // Service Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.serviceNameAr ?? service.serviceName ?? 'خدمة',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.black,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(Icons.timer_outlined, size: 14.sp, color: AppColors.gold),
                              SizedBox(width: 4.w),
                              Text(
                                '${service.serviceDuration} دقيقة',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Price
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${service.servicePrice.toStringAsFixed(0)} ريال',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: (600 + index * 100).ms).fadeIn().slideX(begin: 0.2);
            }).toList()
          else
            Center(
              child: Padding(
                padding: EdgeInsets.all(40.r),
                child: Column(
                  children: [
                    Icon(
                      Icons.design_services_outlined,
                      size: 70.sp,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'لا توجد خدمات مضافة',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.grey.shade500,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2);
  }
  /// ═══════════════════════════════════════════════════════════════
  /// EMPLOYEE CARD
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildEmployeeCard(bool isDark) {
    // ✅ تحديد إذا كان الموظف محدد أم لا
    final hasEmployee = widget.appointment.employeeName != null &&
        widget.appointment.employeeName!.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_pin_rounded,
                color: AppColors.darkRed,
                size: 22.sp,
              ),
              SizedBox(width: 10.w),
              Text(
                'الموظف',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.black,
                ),
              ),
            ],
          ),
          Divider(height: 24.h),
          Row(
            children: [
              // ✅ Avatar
              CircleAvatar(
                radius: 30.r,
                backgroundColor: hasEmployee
                    ? AppColors.darkRed.withValues(alpha: 0.1)
                    : AppColors.gold.withValues(alpha: 0.1),
                backgroundImage: hasEmployee &&
                        widget.appointment.employeeImageUrl != null &&
                        widget.appointment.employeeImageUrl!.isNotEmpty
                    ? NetworkImage(widget.appointment.employeeImageUrl!)
                    : null,
                child: (widget.appointment.employeeImageUrl == null ||
                        widget.appointment.employeeImageUrl!.isEmpty)
                    ? Icon(
                        hasEmployee ? Icons.person : Icons.autorenew_rounded,
                        size: 30.sp,
                        color: hasEmployee ? AppColors.darkRed : AppColors.gold,
                      )
                    : null,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ اسم الموظف أو "اختيار تلقائي"
                    Text(
                      hasEmployee
                          ? widget.appointment.employeeName!
                          : 'اختيار تلقائي',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // ✅ الوصف
                    Text(
                      hasEmployee ? 'حلاق محترف' : 'سيتم اختيار أول موظف متاح',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // ✅ التقييم (فقط إذا كان الموظف محدد)
              if (hasEmployee)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: AppColors.gold,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '4.8',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
              // ✅ أيقونة "تلقائي" (إذا لم يكن محدد)
              if (!hasEmployee)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.autorenew_rounded,
                        color: AppColors.gold,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'تلقائي',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2);
  }

  /// ═══════════════════════════════════════════════════════════════
  /// CONTACT ACTIONS CARD (Call, WhatsApp, Location)
  /// ═══════════════════════════════════════════════════════════════


  Widget _buildContactActionsCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkRed,
            AppColors.darkRed.withOpacity(0.85),
            AppColors.darkRedDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkRed.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ✅ Pattern Background
          Positioned.fill(
            child: CustomPaint(
              painter: _PatternPainter(color: Colors.white.withOpacity(0.05)),
            ),
          ),

          // ✅ Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.contact_support_rounded,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                  ).animate().scale(duration: 500.ms),

                  SizedBox(width: 10.w),

                  Text(
                    'التواصل مع المركز',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                ],
              ),

              SizedBox(height: 16.h),

              Row(
                children: [
                  // ✅ Call Button
                  Expanded(
                    child: _buildContactButton(
                      icon: Icons.phone_rounded,
                      label: 'اتصال',
                      onTap: () => _makePhoneCall(phoneNumber),
                      color: Colors.green,
                      index: 0,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // ✅ WhatsApp Button
                  Expanded(
                    child: _buildContactButton(
                      icon: Icons.message_rounded,
                      label: 'واتساب',
                      onTap: () => _openWhatsApp(phoneNumber),
                      color: const Color(0xFF25D366),
                      index: 1,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // ✅ Location Button
                  Expanded(
                    child: _buildContactButton(
                      icon: Icons.location_on_rounded,
                      label: 'الموقع',
                      onTap: _openLocation,
                      color: Colors.red,
                      index: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 750.ms).slideY(begin: 0.2);
  }

// ✅ Contact Button المحسّن
  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    required int index,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon مع Glow
              Stack(
                alignment: Alignment.center,
                children: [
                  // Glow Effect
                  Container(
                    width: 45.w,
                    height: 45.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          color.withOpacity(0.3),
                          color.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .scale(duration: 1500.ms, begin: const Offset(1, 1), end: const Offset(1.15, 1.15)),

                  // Icon Circle
                  Container(
                    width: 38.w,
                    height: 38.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.8)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 20.sp),
                  ),
                ],
              ),

              SizedBox(height: 6.h),

              // Label
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (800 + index * 100).ms).fadeIn().scale();
  }

  /// ═══════════════════════════════════════════════════════════════
  /// STATUS TIMELINE
  /// ═══════════════════════════════════════════════════════════════
  Widget _buildStatusTimeline(bool isDark) {
    final statuses = [
      {
        'status': 'pending',
        'label': 'تم الحجز',
        'icon': Icons.check_circle_rounded,
        'color': const Color(0xFFFFA500),
      },
      {
        'status': 'confirmed',
        'label': 'مؤكد',
        'icon': Icons.verified_rounded,
        'color': const Color(0xFF4CAF50),
      },
      {
        'status': 'in_progress',
        'label': 'جارٍ التنفيذ',
        'icon': Icons.pending_rounded,
        'color': const Color(0xFF2196F3),
      },
      {
        'status': 'completed',
        'label': 'مكتمل',
        'icon': Icons.done_all_rounded,
        'color': AppColors.gold,
      },
    ];

    final currentIndex =
    statuses.indexWhere((s) => s['status'] == widget.appointment.status);

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded, color: AppColors.darkRed, size: 22.sp),
              SizedBox(width: 10.w),
              Text(
                'تتبع الحالة',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.black,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 700.ms),

          SizedBox(height: 20.h),

          ...List.generate(statuses.length, (index) {
            final status = statuses[index];
            final isActive = index <= currentIndex;
            final isCurrent = index == currentIndex;
            final statusColor = status['color'] as Color;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    // ✅ Icon مع Glow
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow Effect
                        if (isCurrent)
                          Container(
                            width: 50.w,
                            height: 50.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  statusColor.withOpacity(0.3),
                                  statusColor.withOpacity(0.1),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                              .scale(duration: 1500.ms, begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),

                        // Icon Circle
                        Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            gradient: isActive
                                ? LinearGradient(colors: [statusColor, statusColor.withOpacity(0.8)])
                                : null,
                            color: isActive ? null : Colors.grey.shade300,
                            shape: BoxShape.circle,
                            border: isCurrent ? Border.all(color: AppColors.gold, width: 3) : null,
                            boxShadow: isActive
                                ? [
                              BoxShadow(
                                color: statusColor.withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                                : null,
                          ),
                          child: Icon(status['icon'] as IconData, color: Colors.white, size: 20.sp),
                        ),
                      ],
                    ).animate(delay: (750 + index * 100).ms).fadeIn().scale(),

                    // Line
                    if (index < statuses.length - 1)
                      Container(
                        width: 2,
                        height: 40.h,
                        decoration: BoxDecoration(
                          gradient: isActive
                              ? LinearGradient(
                            colors: [statusColor, statuses[index + 1]['color'] as Color],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                              : null,
                          color: isActive ? null : Colors.grey.shade300,
                        ),
                      ).animate(delay: (800 + index * 100).ms).fadeIn().scaleY(begin: 0, alignment: Alignment.topCenter),
                  ],
                ),

                SizedBox(width: 16.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status['label'] as String,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                          color: isActive
                              ? (isDark ? Colors.white : AppColors.black)
                              : Colors.grey.shade500,
                        ),
                      ),

                      // ✅ Current Badge مع Shimmer
                      if (isCurrent) ...[
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppColors.gold, AppColors.goldDark]),
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withOpacity(0.3),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Text(
                            'الحالة الحالية',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ).animate(onPlay: (controller) => controller.repeat())
                            .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
                      ],

                      SizedBox(height: 20.h),
                    ],
                  ).animate(delay: (800 + index * 100).ms).fadeIn().slideX(begin: 0.2),
                ),
              ],
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2);
  }





  /// ═══════════════════════════════════════════════════════════════
  /// NOTES CARD
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildNotesCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes_rounded, color: AppColors.darkRed, size: 22.sp),
              SizedBox(width: 10.w),
              Text(
                'ملاحظات',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.black,
                ),
              ),
            ],
          ),
          Divider(height: 24.h),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              widget.appointment.notes ?? '',
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.6,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2);
  }

  /// ═══════════════════════════════════════════════════════════════
  /// REWARD USED CARD
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildRewardUsedCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gold, AppColors.gold.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_giftcard_rounded,
                  color: Colors.white, size: 24.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'مكافأة مستبدلة',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'مُطبّق',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'قيمة الخصم',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${widget.appointment.discountAmount.toStringAsFixed(0)} ريال',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                if (widget.appointment.loyaltyPointsUsed > 0) ...[
                  SizedBox(height: 12.h),
                  const Divider(),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Icon(Icons.stars_rounded,
                          color: AppColors.gold, size: 20.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'تم استخدام ${widget.appointment.loyaltyPointsUsed} نقطة ولاء',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 850.ms).slideY(begin: 0.2);
  }

  /// ═══════════════════════════════════════════════════════════════
  /// PAYMENT CARD
  /// ═══════════════════════════════════════════════════════════════
  /// ═══════════════════════════════════════════════════════════════
  /// PAYMENT CARD — بدون إيصال (الإيصال في بطاقة منفصلة)
  /// ═══════════════════════════════════════════════════════════════
  Widget _buildPaymentCard(bool isDark) {
    final hasDiscount    = widget.appointment.discountAmount > 0;
    final willEarnPoints = widget.appointment.loyaltyPointsEarned > 0;
    final isCash         = widget.appointment.paymentMethod == 'cash' ||
        widget.appointment.paymentMethod == null ||
        widget.appointment.paymentMethod!.isEmpty;

    // ✅ استخدم _walletData بدلاً من widget.appointment.electronicWallet
    final wallet = _walletData ?? widget.appointment.electronicWallet;

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gold, AppColors.gold.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── العنوان ─────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.payments_rounded, color: Colors.white, size: 24.sp),
              SizedBox(width: 10.w),
              Text(
                'ملخص الدفع',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Divider(height: 24.h, color: Colors.white.withValues(alpha: 0.3)),

          // ── طريقة الدفع ──────────────────────────────────────────
          _buildPaymentRow(
            'طريقة الدفع',
            isCash ? '💵 دفع نقدي' : '💳 دفع إلكتروني',
          ),
          SizedBox(height: 12.h),

          // ── اسم المحفظة (إلكتروني فقط) ──────────────────────────
          if (!isCash) ...[
            // ✅ إذا كانت المحفظة لا تزال تُحمَّل، أظهر shimmer
            if (_walletData == null && widget.appointment.electronicWallet == null)
              _buildPaymentRow('المحفظة', '⏳ جاري التحميل...')
            else
              _buildPaymentRow(
                'المحفظة',
                wallet != null
                    ? (wallet.walletNameAr.isNotEmpty
                    ? wallet.walletNameAr
                    : wallet.walletName)
                    : '—',
              ),
            SizedBox(height: 12.h),
          ],

          // ── حالة الدفع (نقدي فقط) ───────────────────────────────
          if (isCash) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'حالة الدفع',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: _getPaymentStatusColor(widget.appointment.paymentStatus)
                        .withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: _getPaymentStatusColor(widget.appointment.paymentStatus)
                          .withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getPaymentStatusIcon(widget.appointment.paymentStatus),
                        color: _getPaymentStatusColor(widget.appointment.paymentStatus),
                        size: 14.sp,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        _getPaymentStatusText(widget.appointment.paymentStatus),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: _getPaymentStatusColor(widget.appointment.paymentStatus),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
          ],

          // ── الأسعار ───────────────────────────────────────────────
          Divider(height: 24.h, color: Colors.white.withValues(alpha: 0.3)),

          _buildPaymentRow(
            'السعر الإجمالي',
            '${widget.appointment.totalPrice.toStringAsFixed(0)} ريال',
          ),

          if (hasDiscount) ...[
            SizedBox(height: 12.h),
            _buildPaymentRow(
              'الخصم',
              '- ${widget.appointment.discountAmount.toStringAsFixed(0)} ريال',
            ),
          ],

          if (willEarnPoints) ...[
            SizedBox(height: 12.h),
            _buildPaymentRow(
              'نقاط مكتسبة',
              '🏆 +${widget.appointment.loyaltyPointsEarned} نقطة',
            ),
          ],

          SizedBox(height: 16.h),

          // ── المبلغ النهائي ────────────────────────────────────────
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المبلغ النهائي',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${(widget.appointment.totalPrice - widget.appointment.discountAmount).toStringAsFixed(0)} ريال',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    ).animate().fadeIn(delay: 860.ms).slideY(begin: 0.2);
  }

  /// ═══════════════════════════════════════════════════════════════
  /// WALLET DETAIL ROW (في بطاقة التفاصيل)
  /// ═══════════════════════════════════════════════════════════════
  Widget _buildWalletDetailRow(ElectronicWalletModel wallet, bool isDark) {
    final name = wallet.walletNameAr.isNotEmpty
        ? wallet.walletNameAr
        : wallet.walletName;

    // ✅ FIX: badge ديناميكي بناءً على حالة الإيصال
    final hasReceipt = widget.appointment.paymentReceiptUrl != null &&
        widget.appointment.paymentReceiptUrl!.isNotEmpty;
    final badgeText  = hasReceipt ? 'تم الدفع' : 'في الانتظار';
    final badgeColor = hasReceipt
        ? const Color(0xFFB8860B)
        : Colors.orange;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        // ── أيقونة المحفظة ────────────────────────────────────────
        Container(
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(
            color: const Color(0xFFB8860B).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: const Color(0xFFB8860B).withValues(alpha: 0.25),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: wallet.iconUrl != null && wallet.iconUrl!.isNotEmpty
                ? Image.network(
              wallet.iconUrl!,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _walletFallbackIcon(wallet),
            )
                : Image.asset(
              wallet.iconAsset,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _walletFallbackIcon(wallet),
            ),
          ),
        ),
        SizedBox(width: 12.w),

        // ── اسم المحفظة + رقم الحساب ─────────────────────────────
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.black,
                ),
              ),
              if (wallet.phoneNumber.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  wallet.phoneNumber,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),

        // ✅ Badge ديناميكي ─────────────────────────────────────────
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: badgeColor.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            badgeText,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ),

      ],
    );
  }

  /// أيقونة احتياطية إذا فشل تحميل الصورة
  Widget _walletFallbackIcon(ElectronicWalletModel wallet) {
    return Center(
      child: Icon(
        Icons.account_balance_wallet_rounded,
        color: const Color(0xFFB8860B),
        size: 20.sp,
      ),
    );
  }


  // Widget _buildPaymentCard(bool isDark) {
  //   final hasDiscount    = widget.appointment.discountAmount > 0;
  //   final willEarnPoints = widget.appointment.loyaltyPointsEarned > 0;
  //   final isCash         = widget.appointment.paymentMethod == 'cash' ||
  //       widget.appointment.paymentMethod == null ||
  //       widget.appointment.paymentMethod!.isEmpty;
  //   final wallet         = widget.appointment.electronicWallet;
  //
  //   return Container(
  //     padding: EdgeInsets.all(20.r),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [AppColors.gold, AppColors.gold.withValues(alpha: 0.8)],
  //       ),
  //       borderRadius: BorderRadius.circular(16.r),
  //       boxShadow: [
  //         BoxShadow(
  //           color: AppColors.gold.withValues(alpha: 0.3),
  //           blurRadius: 15,
  //           offset: const Offset(0, 6),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // ── العنوان ─────────────────────────────────────────────
  //         Row(
  //           children: [
  //             Icon(Icons.payments_rounded, color: Colors.white, size: 24.sp),
  //             SizedBox(width: 10.w),
  //             Text(
  //               'ملخص الدفع',
  //               style: TextStyle(
  //                 fontSize: 18.sp,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.white,
  //               ),
  //             ),
  //           ],
  //         ),
  //         Divider(height: 24.h, color: Colors.white.withValues(alpha: 0.3)),
  //
  //         // ── طريقة الدفع ──────────────────────────────────────────
  //         _buildPaymentRow(
  //           'طريقة الدفع',
  //           isCash ? '💵 دفع نقدي' : '💳 دفع إلكتروني',
  //         ),
  //         SizedBox(height: 12.h),
  //
  //         // ── اسم المحفظة (إذا كانت إلكترونية) ───────────────────
  //         if (!isCash) ...[
  //           _buildPaymentRow(
  //             'المحفظة',
  //             wallet != null
  //                 ? (wallet.walletNameAr.isNotEmpty
  //                 ? wallet.walletNameAr
  //                 : wallet.walletName)
  //                 : 'محفظة إلكترونية',
  //           ),
  //           SizedBox(height: 12.h),
  //         ],
  //
  //         // ── حالة الدفع ───────────────────────────────────────────
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               'حالة الدفع',
  //               style: TextStyle(
  //                 fontSize: 14.sp,
  //                 color: Colors.white.withValues(alpha: 0.9),
  //               ),
  //             ),
  //             // ✅ Badge حالة الدفع مع لون ديناميكي
  //             Container(
  //               padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
  //               decoration: BoxDecoration(
  //                 color: _getPaymentStatusColor(widget.appointment.paymentStatus)
  //                     .withValues(alpha: 0.25),
  //                 borderRadius: BorderRadius.circular(20.r),
  //                 border: Border.all(
  //                   color: _getPaymentStatusColor(widget.appointment.paymentStatus)
  //                       .withValues(alpha: 0.6),
  //                   width: 1.5,
  //                 ),
  //               ),
  //               child: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Icon(
  //                     _getPaymentStatusIcon(widget.appointment.paymentStatus),
  //                     color: _getPaymentStatusColor(widget.appointment.paymentStatus),
  //                     size: 14.sp,
  //                   ),
  //                   SizedBox(width: 5.w),
  //                   Text(
  //                     _getPaymentStatusText(widget.appointment.paymentStatus),
  //                     style: TextStyle(
  //                       fontSize: 13.sp,
  //                       fontWeight: FontWeight.bold,
  //                       color: _getPaymentStatusColor(widget.appointment.paymentStatus),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 12.h),
  //
  //         // ── الأسعار ──────────────────────────────────────────────
  //         if (hasDiscount) ...[
  //           _buildPaymentRow(
  //             'السعر الأصلي',
  //             '${widget.appointment.totalPrice.toStringAsFixed(0)} ريال',
  //           ),
  //           SizedBox(height: 8.h),
  //           _buildPaymentRow(
  //             'الخصم',
  //             '-${widget.appointment.discountAmount.toStringAsFixed(0)} ريال',
  //           ),
  //           SizedBox(height: 8.h),
  //         ],
  //
  //         Divider(height: 24.h, color: Colors.white.withValues(alpha: 0.3)),
  //
  //         // ── الإجمالي ─────────────────────────────────────────────
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               'الإجمالي',
  //               style: TextStyle(
  //                 fontSize: 16.sp,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.white,
  //               ),
  //             ),
  //             Text(
  //               '${(widget.appointment.totalPrice - widget.appointment.discountAmount).toStringAsFixed(0)} ريال',
  //               style: TextStyle(
  //                 fontSize: 24.sp,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.white,
  //               ),
  //             ),
  //           ],
  //         ),
  //
  //         // ── نقاط الولاء ──────────────────────────────────────────
  //         if (willEarnPoints) ...[
  //           SizedBox(height: 16.h),
  //           Container(
  //             padding: EdgeInsets.all(12.r),
  //             decoration: BoxDecoration(
  //               color: Colors.white.withValues(alpha: 0.2),
  //               borderRadius: BorderRadius.circular(12.r),
  //             ),
  //             child: Row(
  //               children: [
  //                 Icon(Icons.diamond, color: Colors.white, size: 20.sp),
  //                 SizedBox(width: 8.w),
  //                 Text(
  //                   'سوف تكسب ${widget.appointment.loyaltyPointsEarned} نقطة ولاء',
  //                   style: TextStyle(
  //                     fontSize: 13.sp,
  //                     color: Colors.white,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ],
  //     ),
  //   ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2);
  // }

  // Widget _buildPaymentCard(bool isDark) {
  //   final hasDiscount = widget.appointment.discountAmount > 0;
  //   final willEarnPoints = widget.appointment.loyaltyPointsEarned > 0;
  //
  //   return Container(
  //     padding: EdgeInsets.all(20.r),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [AppColors.gold, AppColors.gold.withValues(alpha: 0.8)],
  //       ),
  //       borderRadius: BorderRadius.circular(16.r),
  //       boxShadow: [
  //         BoxShadow(
  //           color: AppColors.gold.withValues(alpha: 0.3),
  //           blurRadius: 15,
  //           offset: const Offset(0, 6),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Icon(Icons.payments_rounded, color: Colors.white, size: 24.sp),
  //             SizedBox(width: 10.w),
  //             Text(
  //               'ملخص الدفع',
  //               style: TextStyle(
  //                 fontSize: 18.sp,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.white,
  //               ),
  //             ),
  //           ],
  //         ),
  //         Divider(height: 24.h, color: Colors.white.withValues(alpha: 0.3)),
  //         _buildPaymentRow(
  //           'حالة الدفع',
  //           _getPaymentStatusText(widget.appointment.paymentStatus),
  //         ),
  //         SizedBox(height: 12.h),
  //         if (hasDiscount) ...[
  //           _buildPaymentRow(
  //             'السعر الأصلي',
  //             '${widget.appointment.totalPrice.toStringAsFixed(0)} ريال',
  //           ),
  //           SizedBox(height: 8.h),
  //           _buildPaymentRow(
  //             'الخصم',
  //             '-${widget.appointment.discountAmount.toStringAsFixed(0)} ريال',
  //           ),
  //           SizedBox(height: 8.h),
  //         ],
  //         Divider(height: 24.h, color: Colors.white.withValues(alpha: 0.3)),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               'الإجمالي',
  //               style: TextStyle(
  //                 fontSize: 16.sp,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.white,
  //               ),
  //             ),
  //             Text(
  //               '${(widget.appointment.totalPrice - widget.appointment.discountAmount).toStringAsFixed(0)} ريال',
  //               style: TextStyle(
  //                 fontSize: 24.sp,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.white,
  //               ),
  //             ),
  //           ],
  //         ),
  //         if (willEarnPoints) ...[
  //           SizedBox(height: 16.h),
  //           Container(
  //             padding: EdgeInsets.all(12.r),
  //             decoration: BoxDecoration(
  //               color: Colors.white.withValues(alpha: 0.2),
  //               borderRadius: BorderRadius.circular(12.r),
  //             ),
  //             child: Row(
  //               children: [
  //                 Icon(Icons.diamond, color: Colors.white, size: 20.sp),
  //                 SizedBox(width: 8.w),
  //                 Text(
  //                   'سوف تكسب ${widget.appointment.loyaltyPointsEarned} نقطة ولاء',
  //                   style: TextStyle(
  //                     fontSize: 13.sp,
  //                     color: Colors.white,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ],
  //     ),
  //   ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2);
  // }

  /// ═══════════════════════════════════════════════════════════════
  /// BOTTOM ACTIONS
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildBottomActions(bool isDark) {
    if (!widget.appointment.isPending && !widget.appointment.isConfirmed) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _cancelAppointment,
                icon: Icon(Icons.close_rounded, size: 20.sp),
                label: Text('إلغاء', style: TextStyle(fontSize: 14.sp)),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  foregroundColor: AppColors.darkRed,
                  side: const BorderSide(color: AppColors.darkRed, width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showRescheduleDialog,
                icon: Icon(Icons.edit_calendar_rounded, size: 20.sp),
                label: Text('إعادة جدولة', style: TextStyle(fontSize: 14.sp)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  backgroundColor: AppColors.darkRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// HELPER WIDGETS
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildDetailRow(
      IconData icon, String label, String value, bool isDark,
      {bool highlight = false}) {        // ✅ معامل جديد
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            color: highlight ? const Color(0xFFB8860B) : AppColors.darkRed,
            size: 20.sp),
        SizedBox(width: 12.w),
        Expanded(
          flex: 2,
          child: Text(label,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              )),
        ),
        Expanded(
          flex: 3,
          child: highlight
              ? Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: const Color(0xFFB8860B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                  color: const Color(0xFFB8860B).withValues(alpha: 0.3)),
            ),
            child: Text(value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFB8860B),
                )),
          )
              : Text(value,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.black,
              )),
        ),
      ],
    );
  }

  Widget _buildGroupPersonsCard(bool isDark) {
    final persons = widget.appointment.persons ?? [];

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFFB8860B).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB8860B).withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── رأس البطاقة ─────────────────────────────────────
          Row(children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  const Color(0xFFB8860B).withValues(alpha: 0.2),
                  const Color(0xFFB8860B).withValues(alpha: 0.1),
                ]),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.group_rounded,
                  color: const Color(0xFFB8860B), size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الحجز الجماعي',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.black,
                      )),
                  Text('${widget.appointment.personsCount} أشخاص',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFFB8860B),
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),
            // شارة عدد الأشخاص
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB8860B), Color(0xFF8B6914)],
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.people_rounded, color: Colors.white, size: 14.sp),
                SizedBox(width: 4.w),
                Text('${widget.appointment.personsCount}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
              ]),
            ),
          ]),

          SizedBox(height: 16.h),
          Divider(color: const Color(0xFFB8860B).withValues(alpha: 0.2)),
          SizedBox(height: 12.h),

          // ── قائمة الأشخاص ────────────────────────────────────
          if (persons.isNotEmpty)
            ...persons.asMap().entries.map((e) {
              final i = e.key;
              final p = e.value;

              final name = p.personName.isNotEmpty
                  ? p.personName
                  : 'شخص ${i + 1}';

              // الخدمات المرتبطة بهذا الشخص
              final relatedServices = widget.appointment.services
                  ?.where((s) => s.personId == p.id)
                  .toList() ??
                  [];

              return Container(
                margin: EdgeInsets.only(bottom: 10.h),
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFB8860B).withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                      color: const Color(0xFFB8860B).withValues(alpha: 0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // رقم الشخص
                    Container(
                      width: 34.w,
                      height: 34.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB8860B), Color(0xFF8B6914)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB8860B).withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text('${i + 1}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // الاسم والخدمات
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.black,
                              )),
                          if (relatedServices.isNotEmpty) ...[
                            SizedBox(height: 6.h),
                            Wrap(
                              spacing: 6.w,
                              runSpacing: 4.h,
                              children: relatedServices
                                  .map((s) => Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB8860B)
                                      .withValues(alpha: 0.1),
                                  borderRadius:
                                  BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  s.getDisplayName(),
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: const Color(0xFFB8860B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ))
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // مجموع خدمات الشخص
                    if (relatedServices.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB8860B).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          '${relatedServices.fold<double>(0, (sum, s) => sum + s.servicePrice).toStringAsFixed(0)} ر.س',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFB8860B),
                          ),
                        ),
                      ),
                  ],
                ),
              ).animate(delay: (600 + i * 80).ms).fadeIn().slideX(begin: 0.15);
            })
          else
          // fallback — إظهار أرقام فقط
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: List.generate(
                widget.appointment.personsCount,
                    (i) => Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB8860B), Color(0xFF8B6914)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('${i + 1}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )),
                  ),
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.2);
  }
  Widget _buildReceiptCard(bool isDark) {
    final hasReceipt = widget.appointment.hasReceipt;
    final wallet     = widget.appointment.electronicWallet;

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: hasReceipt
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (hasReceipt ? Colors.green : Colors.orange)
                .withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── رأس البطاقة ─────────────────────────────────────
          Row(children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: (hasReceipt ? Colors.green : Colors.orange)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                hasReceipt
                    ? Icons.receipt_long_rounded
                    : Icons.pending_actions_rounded,
                color: hasReceipt ? Colors.green : Colors.orange,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الدفع الإلكتروني',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.black,
                      )),
                  Text(
                    hasReceipt ? 'تم رفع الإيصال ✓' : 'في انتظار الإيصال',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: hasReceipt ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // شارة الحالة
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: (hasReceipt ? Colors.green : Colors.orange)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: (hasReceipt ? Colors.green : Colors.orange)
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                hasReceipt ? 'مؤكد' : 'انتظار',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: hasReceipt ? Colors.green : Colors.orange,
                ),
              ),
            ),
          ]),

          // ── معلومات المحفظة ──────────────────────────────────
          if (wallet != null) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(children: [
                _buildReceiptRow(
                  Icons.account_balance_wallet_rounded,
                  'المحفظة',
                  wallet.walletNameAr.isNotEmpty ? wallet.walletNameAr : wallet.walletName,
                  isDark,
                ),
                SizedBox(height: 8.h),
                _buildReceiptRow(
                  Icons.phone_rounded,
                  'رقم التحويل',
                  wallet.phoneNumber,
                  isDark,
                ),
                if (wallet.accountName != null && wallet.accountName!.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  _buildReceiptRow(
                    Icons.person_outline_rounded,
                    'اسم الحساب',
                    wallet.accountName!,
                    isDark,
                  ),
                ],

              ]),
            ),
          ],

          // ── صورة الإيصال ─────────────────────────────────────
          if (hasReceipt) ...[
            SizedBox(height: 16.h),
            Text('صورة الإيصال',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                )),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 200.h),
                child: Image.network(
                  widget.appointment.paymentReceiptUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 150.h,
                      color: isDark
                          ? const Color(0xFF2A2A2A)
                          : Colors.grey.shade100,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                              : null,
                          color: Colors.green,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    height: 80.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.broken_image_rounded,
                            color: Colors.grey, size: 30.sp),
                        SizedBox(height: 6.h),
                        Text('تعذّر تحميل الإيصال',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 12.sp)),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            // ── لم يرفع الإيصال بعد ───────────────────────────
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.2),
                    style: BorderStyle.solid),
              ),
              child: Row(children: [
                Icon(Icons.info_outline_rounded,
                    color: Colors.orange, size: 18.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'لم يتم رفع إيصال الدفع بعد. سيتم مراجعة الحجز بمجرد رفع الإيصال.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 860.ms).slideY(begin: 0.2);
  }

// ── widget مساعد لصفوف الإيصال ──────────────────────────────
  Widget _buildReceiptRow(
      IconData icon, String label, String value, bool isDark) {
    return Row(children: [
      Icon(icon, size: 16.sp, color: const Color(0xFFB8860B)),
      SizedBox(width: 8.w),
      Text('$label: ',
          style: TextStyle(
            fontSize: 13.sp,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          )),
      Flexible(
        child: Text(value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.black,
            ),
            overflow: TextOverflow.ellipsis),
      ),
    ]);
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'cash':        return 'نقداً';
      case 'electronic':  return 'إلكتروني 💳';
      case 'wallet':      return 'محفظة إلكترونية';
      case 'card':        return 'بطاقة بنكية';
      default:            return method;
    }
  }

  // Widget _buildDetailRow(
  //     IconData icon, String label, String value, bool isDark) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Icon(icon, color: AppColors.darkRed, size: 20.sp),
  //       SizedBox(width: 12.w),
  //       Expanded(
  //         flex: 2,
  //         child: Text(
  //           label,
  //           style: TextStyle(
  //             fontSize: 14.sp,
  //             color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
  //           ),
  //         ),
  //       ),
  //       Expanded(
  //         flex: 3,
  //         child: Text(
  //           value,
  //           textAlign: TextAlign.left,
  //           style: TextStyle(
  //             fontSize: 15.sp,
  //             fontWeight: FontWeight.w600,
  //             color: isDark ? Colors.white : AppColors.black,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildPaymentRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// ACTIONS
  /// ═══════════════════════════════════════════════════════════════

  Future<void> _makePhoneCall(String phoneNumber) async {
    // ✅ تنظيف الرقم
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');

    // ✅ إضافة كود الدولة
    final fullNumber =
        cleanNumber.startsWith('+') ? cleanNumber : '$countryCode$cleanNumber';

    final uri = Uri.parse('tel:$fullNumber');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          CustomSnackbar.showError(context, 'لا يمكن إجراء المكالمة');
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'حدث خطأ أثناء الاتصال');
      }
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    // ✅ تنظيف الرقم
    final cleanNumber = phoneNumber
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('+', '')
        .replaceAll('-', '');

    // ✅ إضافة كود الدولة (967 لليمن)
    final fullNumber =
        cleanNumber.startsWith('967') ? cleanNumber : '967$cleanNumber';

    // ✅ رسالة افتراضية
    const message = 'مرحباً، أود الاستفسار عن موعدي';
    final encodedMessage = Uri.encodeComponent(message);

    final uri = Uri.parse('https://wa.me/$fullNumber?text=$encodedMessage');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          CustomSnackbar.showError(context, 'لا يمكن فتح واتساب');
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'تأكد من تثبيت تطبيق واتساب');
      }
    }
  }

  Future<void> _openLocation() async {
    final uri = Uri.parse(locationUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          CustomSnackbar.showError(context, 'لا يمكن فتح الخريطة');
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'حدث خطأ أثناء فتح الموقع');
      }
    }
  }

  void _shareAppointment() {
    final appointmentDetails = '''
🎯 موعدك في صالون المليونير

📅 التاريخ: ${DateFormat('EEEE، d MMMM yyyy', 'ar').format(widget.appointment.appointmentDate)}
⏰ الوقت: ${_formatTimeArabic(widget.appointment.appointmentTime)}
💈 الخدمات: ${widget.appointment.services?.map((s) => s.serviceNameAr ?? s.serviceName).join('، ') ?? 'غير محدد'}
💰 الإجمالي: ${(widget.appointment.totalPrice - widget.appointment.discountAmount).toStringAsFixed(0)} ريال

📍 الموقع: $locationUrl
📞 للتواصل: $countryCode$phoneNumber
💬 واتساب: https://wa.me/967$phoneNumber
''';

    Share.share(
      appointmentDetails,
      subject: 'موعدي في صالون المليونير',
    );
  }

  Future<void> _showRescheduleDialog() async {
    DateTime? selectedDate;
    String? selectedTime;
    List<String> availableTimeSlots = [];
    bool isLoadingSlots = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, controller) => Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.greyDark : AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
              ),
              child: Column(
                children: [
                  // ═══════════════════════════════════════════════════════════
                  // HEADER
                  // ═══════════════════════════════════════════════════════════
                  Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: AppColors.darkRed,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(25.r)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40.w,
                          height: 4.h,
                          margin: EdgeInsets.only(bottom: 16.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.edit_calendar_rounded,
                                color: Colors.white, size: 28.sp),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'إعادة جدولة الموعد',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close_rounded,
                                  color: Colors.white, size: 24.sp),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ═══════════════════════════════════════════════════════════
                  // CONTENT
                  // ═══════════════════════════════════════════════════════════
                  Expanded(
                    child: ListView(
                      controller: controller,
                      padding: EdgeInsets.all(20.r),
                      children: [
                        // الموعد الحالي
                        Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                                color: Colors.orange.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الموعد الحالي',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      size: 16.sp, color: Colors.orange),
                                  SizedBox(width: 8.w),
                                  Text(
                                    DateFormat('EEEE، d MMMM', 'ar').format(
                                        widget.appointment.appointmentDate),
                                    style: TextStyle(fontSize: 13.sp),
                                  ),
                                  SizedBox(width: 16.w),
                                  Icon(Icons.access_time,
                                      size: 16.sp, color: Colors.orange),
                                  SizedBox(width: 8.w),
                                  Text(
                                    _formatTimeArabic(
                                        widget.appointment.appointmentTime),
                                    style: TextStyle(fontSize: 13.sp),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // اختيار التاريخ الجديد
                        Text(
                          'اختر التاريخ الجديد',
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12.h),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  DateTime.now().add(const Duration(days: 1)),
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 60)),
                              locale: const Locale('ar'),
                            );
                            if (picked != null) {
                              setModalState(() {
                                selectedDate = picked;
                                selectedTime = null;
                                isLoadingSlots = true;
                              });

                              // جلب الأوقات المتاحة
                              final appointmentProvider =
                                  Provider.of<AppointmentProvider>(context,
                                      listen: false);
                              await appointmentProvider.fetchAvailableTimeSlots(
                                picked,
                                widget.appointment.durationMinutes,
                              );

                              setModalState(() {
                                availableTimeSlots =
                                    appointmentProvider.availableTimeSlots;
                                isLoadingSlots = false;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today_rounded),
                          label: Text(
                            selectedDate != null
                                ? DateFormat('EEEE، d MMMM yyyy', 'ar')
                                    .format(selectedDate!)
                                : 'اختر التاريخ',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColors.greyMedium
                                : AppColors.greyLight,
                            foregroundColor:
                                isDark ? Colors.white : AppColors.black,
                            padding: EdgeInsets.symmetric(
                                vertical: 16.h, horizontal: 16.w),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                          ),
                        ),

                        // عرض الأوقات المتاحة
                        if (selectedDate != null) ...[
                          SizedBox(height: 24.h),
                          Text(
                            'اختر الوقت الجديد',
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 12.h),
                          if (isLoadingSlots)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.r),
                                child: const CircularProgressIndicator(
                                    color: AppColors.darkRed),
                              ),
                            )
                          else if (availableTimeSlots.isEmpty)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.r),
                                child: Column(
                                  children: [
                                    Icon(Icons.event_busy_rounded,
                                        size: 48.sp, color: Colors.grey),
                                    SizedBox(height: 12.h),
                                    Text(
                                      'لا توجد أوقات متاحة في هذا اليوم',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14.sp),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            // Grid الأوقات
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 8.w,
                                mainAxisSpacing: 8.h,
                                childAspectRatio: 2.0,
                              ),
                              itemCount: availableTimeSlots.length,
                              itemBuilder: (context, index) {
                                final time = availableTimeSlots[index];
                                final isSelected = selectedTime == time;

                                return GestureDetector(
                                  onTap: () =>
                                      setModalState(() => selectedTime = time),
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.h),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.darkRed
                                          : (isDark
                                              ? AppColors.greyMedium
                                              : AppColors.greyLight),
                                      borderRadius: BorderRadius.circular(10.r),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.darkRed
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: AppColors.darkRed
                                                    .withValues(alpha: 0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        _formatTimeArabic(time),
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : (isDark
                                                  ? Colors.white
                                                  : AppColors.black),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],

                        SizedBox(height: 24.h),

                        // زر التأكيد
                        ElevatedButton(
                          onPressed:
                              selectedDate != null && selectedTime != null
                                  ? () async {
                                      Navigator.pop(context);
                                      await _confirmReschedule(
                                          selectedDate!, selectedTime!);
                                    }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkRed,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: Text(
                            'تأكيد إعادة الجدولة',
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.bold),
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
      ),
    );
  }

  // ✅ تأكيد إعادة الجدولة

  Future<void> _confirmReschedule(DateTime newDate, String newTime) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.greyDark
              : AppColors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_outline,
                    color: Colors.green, size: 28.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text('تأكيد إعادة الجدولة',
                    style: TextStyle(
                        fontSize: 18.sp, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('هل أنت متأكد من إعادة جدولة الموعد إلى:',
                  style: TextStyle(fontSize: 14.sp)),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border:
                      Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16.sp, color: Colors.green),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            DateFormat('EEEE، d MMMM yyyy', 'ar')
                                .format(newDate),
                            style: TextStyle(
                                fontSize: 14.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 16.sp, color: Colors.green),
                        SizedBox(width: 8.w),
                        Text(_formatTimeArabic(newTime),
                            style: TextStyle(
                                fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('إلغاء', style: TextStyle(fontSize: 14.sp)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
              child: const Text('تأكيد'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      await Supabase.instance.client.from('appointments').update({
        'appointment_date': newDate.toIso8601String().split('T')[0],
        'appointment_time': newTime,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', widget.appointment.id!);

      try {
        await Supabase.instance.client.from('notifications').insert({
          'user_id': userProvider.user!.id!,
          'appointment_id': widget.appointment.id,
          'title': 'تم إعادة جدولة الموعد ✅',
          'body':
              'تم إعادة جدولة موعدك بنجاح إلى ${DateFormat('d MMMM', 'ar').format(newDate)} الساعة ${_formatTimeArabic(newTime)}',
          'type': 'appointment',
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
      }

      if (mounted) {
        Navigator.pop(context);
        CustomSnackbar.showSuccess(context, '✅ تم إعادة جدولة الموعد بنجاح');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        CustomSnackbar.showError(context, '❌ فشل إعادة جدولة الموعد');
      }
    }
  }

  Future<void> _cancelAppointment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: AppColors.darkRed, size: 24.sp),
              SizedBox(width: 12.w),
              const Text('إلغاء الموعد'),
            ],
          ),
          content: const Text(
            'هل أنت متأكد من إلغاء هذا الموعد؟ لن تتمكن من التراجع عن هذا الإجراء.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('رجوع'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkRed,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
              child: const Text('تأكيد الإلغاء'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      final success =
          await appointmentProvider.cancelAppointment(widget.appointment.id!);

      if (success && mounted) {
        CustomSnackbar.showSuccess(context, '✅ تم إلغاء الموعد بنجاح');
        Navigator.pop(context, true);
      } else if (mounted) {
        CustomSnackbar.showError(context, '❌ فشل إلغاء الموعد');
      }
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// HELPER METHODS
  /// ═══════════════════════════════════════════════════════════════

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return AppColors.darkRed;
      case 'no_show':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'confirmed':
        return Icons.check_circle_rounded;
      case 'in_progress':
        return Icons.pending_rounded;
      case 'completed':
        return Icons.done_all_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'no_show':
        return Icons.event_busy_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'مؤكد';
      case 'in_progress':
        return 'جارٍ التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغى';
      case 'no_show':
        return 'لم يحضر';
      default:
        return status;
    }
  }

  String _getPaymentStatusText(String status) {
    switch (status) {
      case 'unpaid':
        return 'غير مدفوع';
      case 'paid':
        return 'مدفوع';
      case 'partial':
        return 'مدفوع جزئياً';
      case 'refunded':
        return 'مسترد';
      default:
        return status;
    }
  }

  String _formatTimeArabic(String time24) {
    try {
      final parts = time24.trim().split(':');
      if (parts.isEmpty) return time24;

      int hour = int.parse(parts[0]);
      String minute =
          parts.length > 1 ? parts[1].split(':')[0].padLeft(2, '0') : '00';

      String period;
      String displayHour;

      if (hour == 0) {
        displayHour = '12';
        period = 'ص';
      } else if (hour < 12) {
        displayHour = hour.toString();
        period = 'ص';
      } else if (hour == 12) {
        displayHour = '12';
        period = 'م';
      } else {
        displayHour = (hour - 12).toString();
        period = 'م';
      }

      return '$displayHour:$minute $period';
    } catch (e) {
      return time24;
    }
  }
}



// ✅ Pattern Painter
class _HeaderPatternPainter extends CustomPainter {
  final Color color;

  _HeaderPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += 40) {
      for (double y = 0; y < size.height; y += 40) {
        canvas.drawCircle(Offset(x, y), 3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PatternPainter extends CustomPainter {
  final Color color;

  _PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += 30) {
      for (double y = 0; y < size.height; y += 30) {
        canvas.drawCircle(Offset(x, y), 2.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}