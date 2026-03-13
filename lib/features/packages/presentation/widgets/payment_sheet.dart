// lib/features/packages/presentation/widgets/payment_sheet.dart

import 'dart:io';
import 'dart:math' show cos, sin, pi;
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:millionaire_barber/core/models/payment_result.dart';
import 'package:millionaire_barber/features/appointments/domain/models/electronic_wallet_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/package_model.dart';


// ══════════════════════════════════════════════════════════════════
// DASHED BORDER WIDGET (بديل dotted_border)
// ══════════════════════════════════════════════════════════════════
class _DashedBorderBox extends StatelessWidget {
  final Widget child;
  final Color  color;
  final double radius;
  final double strokeWidth;

  const _DashedBorderBox({
    required this.child,
    required this.color,
    this.radius      = 16,
    this.strokeWidth = 1.8,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedPainter(
        color:       color,
        radius:      radius,
        strokeWidth: strokeWidth,
      ),
      child: child,
    );
  }
}

class _DashedPainter extends CustomPainter {
  final Color  color;
  final double radius;
  final double strokeWidth;

  const _DashedPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color       = color
      ..strokeWidth = strokeWidth
      ..style       = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
        Radius.circular(radius),
      ));

    canvas.drawPath(_buildDashedPath(path), paint);
  }

  Path _buildDashedPath(Path source) {
    const dashLen  = 8.0;
    const gapLen   = 4.0;
    final dest     = Path();
    for (final metric in source.computeMetrics()) {
      double dist = 0;
      bool   draw = true;
      while (dist < metric.length) {
        final len = draw ? dashLen : gapLen;
        if (draw) {
          dest.addPath(
            metric.extractPath(dist, dist + len),
            Offset.zero,
          );
        }
        dist += len;
        draw  = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant _DashedPainter old) =>
      old.color != color ||
          old.radius != radius ||
          old.strokeWidth != strokeWidth;
}

// ══════════════════════════════════════════════════════════════════
// MAIN WIDGET
// ══════════════════════════════════════════════════════════════════
class PaymentMethodSheet extends StatefulWidget {
  final PackageModel package;
  final bool         isDark;
  final List<Color>  packageColors;

  const PaymentMethodSheet({
    Key? key,
    required this.package,
    required this.isDark,
    required this.packageColors,
  }) : super(key: key);

  static Future<PaymentResult?> show({
    required BuildContext context,
    required PackageModel package,
    required bool          isDark,
    required List<Color>   packageColors,
  }) {
    return showModalBottomSheet<PaymentResult>(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      isDismissible:      true,
      useSafeArea:        true,
      builder: (_) => PaymentMethodSheet(
        package:       package,
        isDark:        isDark,
        packageColors: packageColors,
      ),
    );
  }

  @override
  State<PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

// ══════════════════════════════════════════════════════════════════
// STATE
// ══════════════════════════════════════════════════════════════════
class _PaymentMethodSheetState extends State<PaymentMethodSheet> {
  static const _primaryRed = Color(0xFFA62424);

  int  _step         = 0; // 0=اختيار | 1=نقدي | 2=إلكتروني
  bool _cashConfirmed = false;

  List<ElectronicWalletModel> _wallets        = [];
  bool                        _loadingWallets = false;
  ElectronicWalletModel?      _selectedWallet;

  File? _receiptFile;
  bool  _isPickingReceipt = false;

  // ── جلب المحافظ ────────────────────────────────────────────────
  Future<void> _loadWallets() async {
    if (!mounted) return;
    setState(() => _loadingWallets = true);
    try {
      final res = await Supabase.instance.client
          .from('electronic_wallets')
          .select()
          .eq('is_active', true)
          .order('display_order');

      if (mounted) {
        _wallets = (res as List)
            .map((j) => ElectronicWalletModel.fromJson(
            j as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('❌ خطأ في جلب المحافظ: $e');
    } finally {
      if (mounted) setState(() => _loadingWallets = false);
    }
  }

  // ── اختيار الإيصال ─────────────────────────────────────────────
  Future<void> _pickReceipt() async {
    if (_isPickingReceipt) return;
    _isPickingReceipt = true;
    try {
      final choice = await showModalBottomSheet<String>(
        context:         context,
        backgroundColor: Colors.transparent,
        builder:         (_) => _buildPickerChooser(),
      );
      if (choice == null || !mounted) return;

      File? picked;
      switch (choice) {
        case 'camera':
          final img = await ImagePicker()
              .pickImage(source: ImageSource.camera, imageQuality: 100);
          if (img != null) picked = File(img.path);
          break;
        case 'gallery':
          final img = await ImagePicker()
              .pickImage(source: ImageSource.gallery, imageQuality: 100);
          if (img != null) picked = File(img.path);
          break;
        case 'file':
          final res = await FilePicker.platform.pickFiles(
            type:              FileType.custom,
            allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
          );
          if (res?.files.single.path != null) {
            picked = File(res!.files.single.path!);
          }
          break;
      }
      if (picked != null && mounted) {
        setState(() => _receiptFile = picked);
        HapticFeedback.lightImpact();
      }
    } finally {
      _isPickingReceipt = false;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: SafeArea(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve:    Curves.easeOutCubic,
            child: _step == 0
                ? _step0()
                : _step == 1
                ? _step1Cash()
                : _step2Electronic(),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // STEP 0
  // ══════════════════════════════════════════════════════════════
  Widget _step0() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _handle(),
        SizedBox(height: 20.h),
        _sheetHeader(
          icon:     Icons.payments_rounded,
          title:    'طريقة الدفع',
          subtitle:
          '${widget.package.nameAr} • ${widget.package.price.toInt()} ر.ي',
        ),
        SizedBox(height: 20.h),
        _packageSummaryCard(),
        SizedBox(height: 20.h),
        _methodCard(
          icon:     Icons.payments_outlined,
          color:    Colors.green,
          title:    'الدفع نقداً',
          subtitle: 'ادفع عند حضور الجلسة في المركز',
          onTap:    () => setState(() => _step = 1),
        ),
        SizedBox(height: 12.h),
        _methodCard(
          icon:     Icons.account_balance_wallet_rounded,
          color:    const Color(0xFF1565C0),
          title:    'الدفع الإلكتروني',
          subtitle: 'كاش / فلوسك / تيليكاش وغيرها',
          badge:    'يستلزم إيصال',
          onTap:    _goToElectronic,
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // STEP 1: نقدي
  // ══════════════════════════════════════════════════════════════
  Widget _step1Cash() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _handle(),
        SizedBox(height: 12.h),
        _backHeader('الدفع نقداً', Icons.payments_outlined, Colors.green),
        SizedBox(height: 20.h),
        _packageSummaryCard(),
        SizedBox(height: 16.h),

        // تعليمات
        _infoBox(
          color: Colors.green,
          title: 'تعليمات الدفع النقدي',
          notes: [
            'سيتم تفعيل اشتراكك فوراً وستتمكن من حجز الجلسات',
            'يجب الدفع نقداً عند حضور أول جلسة في المركز',
            'في حال عدم الدفع سيتم إيقاف الاشتراك تلقائياً',
          ],
        ),
        SizedBox(height: 16.h),

        // Checkbox
        GestureDetector(
          onTap: () {
            setState(() => _cashConfirmed = !_cashConfirmed);
            HapticFeedback.lightImpact();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:  EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.grey.shade900
                  : const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: _cashConfirmed ? Colors.green : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24.w, height: 24.w,
                decoration: BoxDecoration(
                  color: _cashConfirmed ? Colors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: _cashConfirmed
                        ? Colors.green
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: _cashConfirmed
                    ? Icon(Icons.check_rounded,
                    color: Colors.white, size: 15.sp)
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'أقرّ بالتزامي بالدفع عند حضور أول جلسة',
                  style: TextStyle(
                    fontSize:   14.sp,
                    fontWeight: FontWeight.w600,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ]),
          ),
        ),
        SizedBox(height: 16.h),

        _confirmBtn(
          enabled: _cashConfirmed,
          label:   'تأكيد الاشتراك • ${widget.package.price.toInt()} ر.ي',
          icon:    Icons.workspace_premium_rounded,
          color:   Colors.green,
          onTap:   _confirmCash,
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // STEP 2: إلكتروني
  // ══════════════════════════════════════════════════════════════
  Widget _step2Electronic() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _handle(),
          SizedBox(height: 12.h),
          _backHeader('الدفع الإلكتروني',
              Icons.account_balance_wallet_rounded,
              const Color(0xFF1565C0)),
          SizedBox(height: 20.h),
          _packageSummaryCard(),
          SizedBox(height: 20.h),

          _sectionTitle('اختر المحفظة',
              Icons.account_balance_wallet_rounded),
          SizedBox(height: 12.h),

          if (_loadingWallets)
            Padding(
              padding: EdgeInsets.all(32.h),
              child: Column(children: [
                const CircularProgressIndicator(color: Color(0xFF1565C0)),
                SizedBox(height: 12.h),
                Text('جاري تحميل المحافظ...',
                    style: TextStyle(
                        fontSize: 13.sp, color: Colors.grey.shade500)),
              ]),
            )
          else if (_wallets.isEmpty)
            _emptyWallets()
          else
            ..._wallets.map(_walletCard),

          if (_selectedWallet != null) ...[
            SizedBox(height: 20.h),
            _sectionTitle('إيصال التحويل',
                Icons.receipt_long_rounded,
                isRequired: true),
            SizedBox(height: 10.h),
            _transferInstructions(),
            SizedBox(height: 12.h),
            _receiptFile == null
                ? _uploadReceiptArea()
                : _receiptPreview(),

            if (_receiptFile != null) ...[
              SizedBox(height: 8.h),
              _compressionNote(),
            ],

            SizedBox(height: 20.h),
            _confirmBtn(
              enabled: _receiptFile != null,
              label:
              'تأكيد الاشتراك • ${widget.package.price.toInt()} ر.ي',
              icon:  Icons.workspace_premium_rounded,
              color: const Color(0xFF1565C0),
              onTap: _confirmElectronic,
            ),
          ],
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // SUB WIDGETS
  // ══════════════════════════════════════════════════════════════

  Widget _handle() => Center(
    child: Container(
      width:  40.w, height: 4.h,
      margin: EdgeInsets.only(top: 4.h),
      decoration: BoxDecoration(
        color:        Colors.grey.shade400,
        borderRadius: BorderRadius.circular(2.r),
      ),
    ),
  );

  Widget _sheetHeader({
    required IconData icon,
    required String   title,
    required String   subtitle,
  }) {
    return Row(children: [
      Container(
        width: 52.w, height: 52.w,
        decoration: BoxDecoration(
          gradient:     LinearGradient(colors: widget.packageColors),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Icon(icon, color: Colors.white, size: 26.sp),
      ),
      SizedBox(width: 14.w),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                    fontSize:   21.sp,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  )),
              SizedBox(height: 3.h),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 13.sp, color: Colors.grey.shade600)),
            ]),
      ),
    ]);
  }

  Widget _backHeader(String title, IconData icon, Color color) {
    return Row(children: [
      GestureDetector(
        onTap: () => setState(() {
          _step           = 0;
          _cashConfirmed  = false;
          _selectedWallet = null;
          _receiptFile    = null;
        }),
        child: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: widget.isDark
                ? Colors.white.withOpacity(0.1)
                : const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.arrow_forward_ios_rounded,
              size: 18.sp,
              color: widget.isDark ? Colors.white : Colors.black87),
        ),
      ),
      SizedBox(width: 12.w),
      Container(
        padding:    EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color:        color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, size: 22.sp, color: color),
      ),
      SizedBox(width: 10.w),
      Text(title,
          style: TextStyle(
            fontSize:   19.sp,
            fontWeight: FontWeight.bold,
            color: widget.isDark ? Colors.white : Colors.black87,
          )),
    ]);
  }

  Widget _packageSummaryCard() {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.packageColors
              .map((c) => c.withOpacity(0.08))
              .toList(),
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
            color: widget.packageColors.first.withOpacity(0.25)),
      ),
      child: Row(children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            gradient:     LinearGradient(colors: widget.packageColors),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(Icons.workspace_premium_rounded,
              color: Colors.white, size: 22.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.package.nameAr,
                    style: TextStyle(
                      fontSize:   15.sp,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark ? Colors.white : Colors.black87,
                    )),
                SizedBox(height: 3.h),
                Text(
                  '${widget.package.totalSessions} جلسة • ${widget.package.validityDays} يوم',
                  style: TextStyle(
                      fontSize: 12.sp, color: Colors.grey.shade600),
                ),
              ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (widget.package.hasDiscount)
            Text(
              '${widget.package.originalPrice!.toInt()} ر.ي',
              style: TextStyle(
                fontSize:   11.sp,
                color:      Colors.grey.shade500,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          Text('${widget.package.price.toInt()} ر.ي',
              style: TextStyle(
                fontSize:   20.sp,
                fontWeight: FontWeight.bold,
                color:      widget.packageColors.first,
              )),
        ]),
      ]),
    );
  }

  Widget _methodCard({
    required IconData     icon,
    required Color        color,
    required String       title,
    required String       subtitle,
    String?               badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          color: widget.isDark
              ? Colors.grey.shade900
              : const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: widget.isDark
                ? Colors.grey.shade800
                : Colors.transparent,
          ),
        ),
        child: Row(children: [
          Container(
            width: 52.w, height: 52.w,
            decoration: BoxDecoration(
              color:        color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(icon, color: color, size: 26.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(title,
                      style: TextStyle(
                        fontSize:   16.sp,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark
                            ? Colors.white
                            : Colors.black87,
                      )),
                  if (badge != null) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color:        Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(badge,
                          style: TextStyle(
                            fontSize:   10.sp,
                            color:      Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ],
                ]),
                SizedBox(height: 4.h),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600)),
              ],
            ),
          ),
          Icon(Icons.arrow_back_ios_new_rounded,
              size: 16.sp, color: Colors.grey.shade400),
        ]),
      ),
    );
  }

  Widget _infoBox({
    required Color        color,
    required String       title,
    required List<String> notes,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16.r),
        border:       Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Row(children: [
          Container(
            padding:    EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color:  color.withOpacity(0.15),
              shape:  BoxShape.circle,
            ),
            child: Icon(Icons.info_outline_rounded,
                color: color, size: 20.sp),
          ),
          SizedBox(width: 10.w),
          Text(title,
              style: TextStyle(
                fontSize:   15.sp,
                fontWeight: FontWeight.bold,
                color:      color.withOpacity(0.9),
              )),
        ]),
        SizedBox(height: 12.h),
        ...notes.map((n) => Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 5.h),
                child: Icon(Icons.circle,
                    size: 6.sp, color: color.withOpacity(0.8)),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(n,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color:    color.withOpacity(0.85),
                      height:   1.5,
                    )),
              ),
            ],
          ),
        )),
      ]),
    );
  }

  Widget _sectionTitle(String title, IconData icon,
      {bool isRequired = false}) {
    return Row(children: [
      Icon(icon, size: 18.sp, color: _primaryRed),
      SizedBox(width: 8.w),
      Text(title,
          style: TextStyle(
            fontSize:   16.sp,
            fontWeight: FontWeight.bold,
            color: widget.isDark ? Colors.white : Colors.black87,
          )),
      if (isRequired) ...[
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color:        Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text('مطلوب',
              style: TextStyle(
                fontSize:   10.sp,
                color:      Colors.red,
                fontWeight: FontWeight.bold,
              )),
        ),
      ],
    ]);
  }

  Widget _walletCard(ElectronicWalletModel wallet) {
    final isSelected = _selectedWallet?.id == wallet.id;
    final color      = _walletColor(wallet.walletType);

    return GestureDetector(
      onTap: () {
        setState(() => _selectedWallet = wallet);
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin:   EdgeInsets.only(bottom: 10.h),
        padding:  EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.08)
              : widget.isDark
              ? Colors.grey.shade900
              : const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(children: [
          Container(
            width: 50.w, height: 50.w,
            decoration: BoxDecoration(
              color:        isSelected ? color : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: _walletIcon(wallet, isSelected, color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(wallet.walletNameAr,
                    style: TextStyle(
                      fontSize:   15.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? color
                          : widget.isDark
                          ? Colors.white
                          : Colors.black87,
                    )),
                SizedBox(height: 4.h),
                Row(children: [
                  Icon(Icons.phone_rounded,
                      size: 12.sp, color: Colors.grey.shade500),
                  SizedBox(width: 4.w),
                  Text(wallet.phoneNumber,
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade500)),
                  if (wallet.accountName != null &&
                      wallet.accountName!.isNotEmpty) ...[
                    Text(' • ',
                        style:
                        TextStyle(color: Colors.grey.shade400)),
                    Flexible(
                      child: Text(wallet.accountName!,
                          style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade500),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ]),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isSelected
                ? Container(
              key: const ValueKey('sel'),
              width: 28.w, height: 28.w,
              decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle),
              child: Icon(Icons.check_rounded,
                  color: Colors.white, size: 16.sp),
            )
                : Container(
              key: const ValueKey('unsel'),
              width: 28.w, height: 28.w,
              decoration: BoxDecoration(
                shape:  BoxShape.circle,
                border: Border.all(
                    color: Colors.grey.shade400, width: 2),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _walletIcon(
      ElectronicWalletModel w, bool isSelected, Color color) {
    if (w.iconUrl != null && w.iconUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(13.r),
        child: CachedNetworkImage(
          imageUrl:    w.iconUrl!,
          fit:         BoxFit.cover,
          placeholder: (_, __) =>
              _localWalletIcon(w, isSelected, color),
          errorWidget: (_, __, ___) =>
              _localWalletIcon(w, isSelected, color),
        ),
      );
    }
    return _localWalletIcon(w, isSelected, color);
  }

  Widget _localWalletIcon(
      ElectronicWalletModel w, bool isSelected, Color color) {
    final path = w.iconAsset;
    if (path == 'assets/icons/wallet.png') {
      return Icon(Icons.account_balance_wallet_rounded,
          color: isSelected ? Colors.white : color, size: 24.sp);
    }
    return Padding(
      padding: EdgeInsets.all(8.r),
      child: Image.asset(path,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            Icons.account_balance_wallet_rounded,
            color: isSelected ? Colors.white : color,
            size:  24.sp,
          )),
    );
  }

  Widget _transferInstructions() {
    final color = _walletColor(_selectedWallet!.walletType);
    final steps = [
      'افتح تطبيق ${_selectedWallet!.walletNameAr}',
      'حوّل ${widget.package.price.toInt()} ر.ي إلى: ${_selectedWallet!.phoneNumber}',
      if (_selectedWallet!.accountName != null &&
          _selectedWallet!.accountName!.isNotEmpty)
        'اسم المستلم: ${_selectedWallet!.accountName}',
      'صوّر إيصال التحويل وارفعه أدناه',
    ];

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14.r),
        border:       Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(children: [
        Row(children: [
          Icon(Icons.info_outline_rounded, size: 16.sp, color: color),
          SizedBox(width: 8.w),
          Text('تعليمات التحويل',
              style: TextStyle(
                fontSize:   14.sp,
                fontWeight: FontWeight.bold,
                color:      color,
              )),
        ]),
        SizedBox(height: 12.h),
        ...steps.asMap().entries.map((e) =>
            _instructionRow('${e.key + 1}', e.value, color)),
      ]),
    );
  }

  Widget _instructionRow(String step, String text, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22.w, height: 22.w,
            decoration:
            BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: Text(step,
                  style: TextStyle(
                    fontSize:   11.sp,
                    fontWeight: FontWeight.bold,
                    color:      Colors.white,
                  )),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(text,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: widget.isDark
                      ? Colors.grey.shade300
                      : Colors.grey.shade800,
                  height: 1.5,
                )),
          ),
        ],
      ),
    );
  }

  // ✅ _uploadReceiptArea بدون dotted_border
  Widget _uploadReceiptArea() {
    const borderColor = Color(0xFF1565C0);
    return GestureDetector(
      onTap: _pickReceipt,
      child: _DashedBorderBox(
        color:  borderColor.withOpacity(0.5),
        radius: 16.r,
        child: Container(
          width:   double.infinity,
          padding: EdgeInsets.symmetric(vertical: 32.h),
          decoration: BoxDecoration(
            color:        borderColor.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:    EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color:  borderColor.withOpacity(0.1),
                  shape:  BoxShape.circle,
                ),
                child: Icon(Icons.cloud_upload_rounded,
                    size: 36.sp, color: borderColor),
              ),
              SizedBox(height: 14.h),
              Text('ارفع إيصال التحويل',
                  style: TextStyle(
                    fontSize:   16.sp,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  )),
              SizedBox(height: 4.h),
              Text('صورة أو ملف PDF',
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _receiptPreview() {
    final isPdf = _receiptFile!.path.toLowerCase().endsWith('.pdf');

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
            color: const Color(0xFF1565C0).withOpacity(0.5), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: Stack(children: [
          if (isPdf)
            Container(
              height: 130.h,
              color:  Colors.grey.shade100,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf_rounded,
                        size: 48.sp, color: Colors.red),
                    SizedBox(height: 8.h),
                    Text('ملف PDF',
                        style: TextStyle(
                          fontSize:   14.sp,
                          fontWeight: FontWeight.bold,
                        )),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        _receiptFile!.path.split('/').last,
                        style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade600),
                        overflow:  TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Image.file(_receiptFile!,
                height: 190.h,
                width:  double.infinity,
                fit:    BoxFit.cover),

          Positioned(
            top: 8, left: 8,
            child: Row(children: [
              _receiptBtn(Icons.delete_rounded, Colors.red,
                      () => setState(() => _receiptFile = null)),
              SizedBox(width: 8.w),
              _receiptBtn(Icons.edit_rounded,
                  const Color(0xFF1565C0), _pickReceipt),
            ]),
          ),

          Positioned(
            bottom: 8, left: 8,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color:        Colors.green.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(children: [
                Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 14.sp),
                SizedBox(width: 5.w),
                Text('تم اختيار الإيصال',
                    style: TextStyle(
                      fontSize:   11.sp,
                      color:      Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _compressionNote() {
    final ext = _receiptFile!.path.split('.').last.toLowerCase();
    if (ext == 'pdf') return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color:        Colors.blue.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(children: [
        Icon(Icons.compress_rounded,
            size: 14.sp, color: Colors.blue.shade700),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            'سيتم ضغط الصورة تلقائياً قبل الرفع للتوفير في الحجم',
            style: TextStyle(
                fontSize: 11.sp, color: Colors.blue.shade700),
          ),
        ),
      ]),
    );
  }

  Widget _receiptBtn(
      IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:    EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color:        color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: Colors.white, size: 18.sp),
      ),
    );
  }

  Widget _emptyWallets() => Padding(
    padding: EdgeInsets.all(32.r),
    child: Column(children: [
      Icon(Icons.account_balance_wallet_outlined,
          size: 52.sp, color: Colors.grey.shade400),
      SizedBox(height: 12.h),
      Text('لا توجد محافظ إلكترونية متاحة حالياً',
          style: TextStyle(
              fontSize: 14.sp, color: Colors.grey.shade600)),
    ]),
  );

  Widget _confirmBtn({
    required bool         enabled,
    required String       label,
    required IconData     icon,
    required Color        color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width:  double.infinity,
      height: 56.h,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity:  enabled ? 1.0 : 0.5,
        child: ElevatedButton(
          onPressed: enabled ? onTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: enabled ? color : Colors.grey,
            foregroundColor: Colors.white,
            elevation:       enabled ? 6 : 0,
            shadowColor:     color.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22.sp),
              SizedBox(width: 10.w),
              Text(label,
                  style: TextStyle(
                    fontSize:   16.sp,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerChooser() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _handle(),
        SizedBox(height: 16.h),
        Text('اختر مصدر الإيصال',
            style: TextStyle(
              fontSize:   18.sp,
              fontWeight: FontWeight.bold,
              color: widget.isDark ? Colors.white : Colors.black87,
            )),
        SizedBox(height: 20.h),
        _pickerOption(Icons.camera_alt_rounded, _primaryRed,
            'الكاميرا', 'التقط صورة للإيصال',
                () => Navigator.pop(context, 'camera')),
        SizedBox(height: 10.h),
        _pickerOption(Icons.photo_library_rounded, Colors.blue,
            'معرض الصور', 'اختر من الصور المحفوظة',
                () => Navigator.pop(context, 'gallery')),
        SizedBox(height: 10.h),
        _pickerOption(Icons.folder_rounded, Colors.orange,
            'الملفات', 'اختر ملف PDF أو صورة',
                () => Navigator.pop(context, 'file')),
      ]),
    );
  }

  Widget _pickerOption(IconData icon, Color color, String title,
      String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: widget.isDark
              ? Colors.grey.shade900
              : const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(children: [
          Container(
            padding:    EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color:  color.withOpacity(0.1),
              shape:  BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(width: 14.w),
          Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontSize:   15.sp,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark ? Colors.white : Colors.black87,
                    )),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12.sp, color: Colors.grey.shade500)),
              ]),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // UTILS & ACTIONS
  // ══════════════════════════════════════════════════════════════
  Color _walletColor(String type) {
    switch (type.toLowerCase()) {
      case 'kash':     return const Color(0xFF00897B);
      case 'floosak':  return const Color(0xFF1565C0);
      case 'telecash': return const Color(0xFF6A1B9A);
      default:         return const Color(0xFF37474F);
    }
  }

  Future<void> _goToElectronic() async {
    setState(() => _step = 2);
    if (_wallets.isEmpty) await _loadWallets();
  }

  void _confirmCash() => Navigator.pop(
    context,
    const PaymentResult(
      paymentMethod: 'cash',
      paymentLabel:  'الدفع نقداً عند الاستلام',
    ),
  );

  void _confirmElectronic() => Navigator.pop(
    context,
    PaymentResult(
      paymentMethod: 'electronic',
      wallet:        _selectedWallet,
      receiptFile:   _receiptFile,
      paymentLabel:
      'دفع إلكتروني - ${_selectedWallet!.walletNameAr}',
    ),
  );
}
