import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:millionaire_barber/features/appointments/domain/models/electronic_wallet_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/services/electronic_wallet_service.dart';

// ══════════════════════════════════════════════════════════
// نموذج نتيجة الدفع
// ══════════════════════════════════════════════════════════
class OrderPaymentResult {
  final String               paymentMethod; // 'cash' | 'wallet'
  final ElectronicWalletModel? wallet;
  final File?                receiptFile;

  const OrderPaymentResult({
    required this.paymentMethod,
    this.wallet,
    this.receiptFile,
  });

  bool get isCash       => paymentMethod == 'cash';
  bool get isElectronic => paymentMethod == 'wallet';
}

// ══════════════════════════════════════════════════════════
// دالة العرض
// ══════════════════════════════════════════════════════════
Future<OrderPaymentResult?> showProductPaymentSheet(
    BuildContext context, {
      required double totalAmount,
    }) {
  return showModalBottomSheet<OrderPaymentResult>(
    context:            context,
    isScrollControlled: true,
    backgroundColor:    Colors.transparent,
    builder: (_) => _ProductPaymentSheet(totalAmount: totalAmount),
  );
}

// ══════════════════════════════════════════════════════════
// Widget الرئيسي
// ══════════════════════════════════════════════════════════
class _ProductPaymentSheet extends StatefulWidget {
  final double totalAmount;
  const _ProductPaymentSheet({required this.totalAmount});

  @override
  State<_ProductPaymentSheet> createState() => _ProductPaymentSheetState();
}

class _ProductPaymentSheetState extends State<_ProductPaymentSheet> {
  final _walletService = ElectronicWalletService();

  String                   _method         = 'cash';
  ElectronicWalletModel?   _selectedWallet;
  File?                    _receiptFile;
  bool                     _isPickingImage  = false;
  bool                     _loadingWallets  = false;
  List<ElectronicWalletModel> _wallets      = [];

  @override
  void initState() {
    super.initState();
    _fetchWallets();
  }

  Future<void> _fetchWallets() async {
    setState(() => _loadingWallets = true);
    _wallets = await _walletService.getActiveWallets();
    if (mounted) setState(() => _loadingWallets = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color:        isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(isDark),
            SizedBox(height: 16.h),
            _buildTitle(isDark),
            SizedBox(height: 20.h),

            // ── الدفع النقدي
            _buildMethodTile(
              isDark:   isDark,
              value:    'cash',
              icon:     Icons.money_rounded,
              title:    'الدفع عند الاستلام',
              subtitle: 'ادفع نقداً عند استلام طلبك',
              color:    Colors.green,
            ),
            SizedBox(height: 12.h),

            // ── الدفع الإلكتروني
            _buildMethodTile(
              isDark:   isDark,
              value:    'wallet',
              icon:     Icons.account_balance_wallet_rounded,
              title:    'الدفع الإلكتروني',
              subtitle: _wallets.isEmpty
                  ? 'جاري التحميل...'
                  : _wallets.map((w) => w.walletNameAr).join(' · '),
              color:    AppColors.gold,
            ),

            // ── قائمة المحافظ الديناميكية
            if (_method == 'wallet') ...[
              SizedBox(height: 16.h),
              _loadingWallets
                  ? _buildWalletsShimmer()
                  : _buildWalletsList(isDark),
            ],

            // ── تفاصيل المحفظة المختارة
            if (_method == 'wallet' && _selectedWallet != null) ...[
              SizedBox(height: 16.h),
              _buildWalletDetails(isDark),
            ],

            // ── رفع الإيصال
            if (_method == 'wallet' && _selectedWallet != null) ...[
              SizedBox(height: 12.h),
              _buildReceiptUploader(isDark),
            ],

            SizedBox(height: 24.h),
            _buildConfirmButton(isDark),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════
  // Handle
  // ════════════════════════════════════════════════════
  Widget _buildHandle(bool isDark) => Center(
    child: Container(
      width:        40.w,
      height:       4.h,
      decoration:   BoxDecoration(
        color:        isDark ? Colors.grey[700] : Colors.grey[300],
        borderRadius: BorderRadius.circular(2.r),
      ),
    ),
  );

  // ════════════════════════════════════════════════════
  // Title
  // ════════════════════════════════════════════════════
  Widget _buildTitle(bool isDark) {
    return Row(
      children: [
        Container(
          padding:    EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            gradient:     const LinearGradient(
                colors: [AppColors.gold, AppColors.goldDark]),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(Icons.payment_rounded, color: Colors.white, size: 22.sp),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'طريقة الدفع',
              style: TextStyle(
                fontSize:   18.sp,
                fontWeight: FontWeight.bold,
                color:      isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              'الإجمالي: ${widget.totalAmount.toStringAsFixed(2)} ر.ي',
              style: TextStyle(
                fontSize:   13.sp,
                color:      AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  // ════════════════════════════════════════════════════
  // Method Tile
  // ════════════════════════════════════════════════════
  Widget _buildMethodTile({
    required bool     isDark,
    required String   value,
    required IconData icon,
    required String   title,
    required String   subtitle,
    required Color    color,
  }) {
    final isSelected = _method == value;

    return GestureDetector(
      onTap: () => setState(() {
        _method         = value;
        _selectedWallet = null;
        _receiptFile    = null;
      }),
      child: AnimatedContainer(
        duration:   const Duration(milliseconds: 250),
        padding:    EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color:        isSelected
              ? color.withOpacity(isDark ? 0.15 : 0.08)
              : (isDark ? const Color(0xFF2C2C2C) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(16.r),
          border:       Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding:    EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color:        isSelected ? color : Colors.grey[300],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size:  22.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize:   15.sp,
                      fontWeight: FontWeight.bold,
                      color:      isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color:    isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 22.sp)
                  .animate().scale(begin: const Offset(0.5, 0.5)),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════
  // قائمة المحافظ الديناميكية
  // ════════════════════════════════════════════════════
  Widget _buildWalletsList(bool isDark) {
    if (_wallets.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Text(
          'لا توجد محافظ إلكترونية متاحة حالياً',
          style: TextStyle(color: Colors.grey, fontSize: 13.sp),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر المحفظة الإلكترونية',
          style: TextStyle(
            fontSize:   14.sp,
            fontWeight: FontWeight.w600,
            color:      isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        SizedBox(height: 10.h),
        GridView.builder(
          shrinkWrap:  true,
          physics:     const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:   3,
            crossAxisSpacing: 8.w,
            mainAxisSpacing:  8.h,
            childAspectRatio: 0.9,
          ),
          itemCount: _wallets.length,
          itemBuilder: (_, i) => _buildWalletCard(_wallets[i], isDark),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2);
  }

  Widget _buildWalletCard(ElectronicWalletModel wallet, bool isDark) {
    final isSelected = _selectedWallet?.id == wallet.id;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedWallet = wallet;
        _receiptFile    = null;
      }),
      child: AnimatedContainer(
        duration:   const Duration(milliseconds: 200),
        padding:    EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color:        isSelected
              ? AppColors.gold.withOpacity(isDark ? 0.2 : 0.1)
              : (isDark ? const Color(0xFF2C2C2C) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(16.r),
          border:       Border.all(
            color: isSelected ? AppColors.gold : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(
            color:      AppColors.gold.withOpacity(0.25),
            blurRadius: 10,
            offset:     const Offset(0, 4),
          )]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildWalletIcon(wallet, isSelected),
            SizedBox(height: 8.h),
            Text(
              wallet.walletNameAr,
              textAlign: TextAlign.center,
              maxLines:  1,
              overflow:  TextOverflow.ellipsis,
              style: TextStyle(
                fontSize:   12.sp,
                fontWeight: FontWeight.bold,
                color:      isSelected
                    ? AppColors.gold
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            if (isSelected) ...[
              SizedBox(height: 4.h),
              Icon(Icons.check_circle_rounded,
                  color: AppColors.gold, size: 14.sp),
            ],
          ],
        ),
      ),
    );
  }

  // ✅ الأيقونة: icon_url أولاً → iconAsset محلي ثانياً → Icon افتراضي
  Widget _buildWalletIcon(ElectronicWalletModel wallet, bool isSelected) {
    final size = 44.w;

    // 1️⃣ icon_url من Supabase
    if (wallet.iconUrl != null && wallet.iconUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: CachedNetworkImage(
          imageUrl:    wallet.iconUrl!,
          width:       size,
          height:      size,
          fit:         BoxFit.cover,
          placeholder: (_, __) => _localOrDefaultIcon(wallet, size, isSelected),
          errorWidget: (_, __, ___) => _localOrDefaultIcon(wallet, size, isSelected),
        ),
      );
    }

    // 2️⃣ أصل محلي من iconAsset
    return _localOrDefaultIcon(wallet, size, isSelected);
  }

  Widget _localOrDefaultIcon(
      ElectronicWalletModel wallet,
      double size,
      bool isSelected,
      ) {
    // ✅ استخدام iconAsset الموجود في الموديل
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Image.asset(
        wallet.iconAsset,
        width:  size,
        height: size,
        fit:    BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultIcon(size, isSelected),
      ),
    );
  }

  Widget _defaultIcon(double size, bool isSelected) {
    return Container(
      width:        size,
      height:       size,
      decoration:   BoxDecoration(
        gradient:     isSelected
            ? const LinearGradient(
            colors: [AppColors.gold, AppColors.goldDark])
            : null,
        color:        isSelected ? null : Colors.grey[300],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(
        Icons.account_balance_wallet_rounded,
        color: isSelected ? Colors.white : Colors.grey[600],
        size:  24.sp,
      ),
    );
  }

  // ════════════════════════════════════════════════════
  // تفاصيل المحفظة المختارة
  // ════════════════════════════════════════════════════
  Widget _buildWalletDetails(bool isDark) {
    final w = _selectedWallet!;

    return Container(
      width:      double.infinity,
      padding:    EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color:        isDark
            ? AppColors.gold.withOpacity(0.08)
            : AppColors.gold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border:       Border.all(
          color: AppColors.gold.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── عنوان
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: AppColors.gold, size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                'تفاصيل ${w.walletNameAr}',
                style: TextStyle(
                  fontSize:   14.sp,
                  fontWeight: FontWeight.bold,
                  color:      AppColors.gold,
                ),
              ),
            ],
          ),
          Divider(height: 16.h, color: AppColors.gold.withOpacity(0.3)),

          // ── رقم المحفظة مع نسخ
          _buildDetailRow(
            isDark:  isDark,
            icon:    Icons.phone_rounded,
            label:   'رقم المحفظة',
            value:   w.phoneNumber,
            canCopy: true,
          ),

          // ── اسم الحساب (إن وجد)
          if (w.accountName != null && w.accountName!.isNotEmpty) ...[
            SizedBox(height: 10.h),
            _buildDetailRow(
              isDark:  isDark,
              icon:    Icons.person_rounded,
              label:   'اسم الحساب',
              value:   w.accountName!,
              canCopy: false,
            ),
          ],

          // ── نوع المحفظة
          SizedBox(height: 10.h),
          _buildDetailRow(
            isDark:  isDark,
            icon:    Icons.category_rounded,
            label:   'نوع المحفظة',
            value:   w.walletType,
            canCopy: false,
          ),

          SizedBox(height: 12.h),

          // ── تعليمات التحويل
          Container(
            padding:    EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color:        Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
              border:       Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.amber[700], size: 16.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'حوّل المبلغ (${widget.totalAmount.toStringAsFixed(2)} ر.ي) '
                        'ثم ارفع صورة الإيصال أدناه',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color:    Colors.amber[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 50.ms).scale(begin: const Offset(0.97, 0.97));
  }

  Widget _buildDetailRow({
    required bool     isDark,
    required IconData icon,
    required String   label,
    required String   value,
    required bool     canCopy,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.gold.withOpacity(0.8), size: 16.sp),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13.sp,
            color:    isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize:   13.sp,
              fontWeight: FontWeight.bold,
              color:      isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        if (canCopy)
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم نسخ $value',
                    style: TextStyle(fontSize: 13.sp),
                  ),
                  duration:        const Duration(seconds: 2),
                  backgroundColor: AppColors.gold,
                  behavior:        SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              );
            },
            child: Container(
              padding:    EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color:        AppColors.gold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.copy_rounded,
                  color: AppColors.gold, size: 14.sp),
            ),
          ),
      ],
    );
  }

  // ════════════════════════════════════════════════════
  // رفع الإيصال
  // ════════════════════════════════════════════════════
  Widget _buildReceiptUploader(bool isDark) {
    return GestureDetector(
      onTap: _pickReceipt,
      child: AnimatedContainer(
        duration:   const Duration(milliseconds: 250),
        width:      double.infinity,
        padding:    EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color:        _receiptFile != null
              ? Colors.green.withOpacity(0.08)
              : (isDark ? const Color(0xFF2C2C2C) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(16.r),
          border:       Border.all(
            color: _receiptFile != null ? Colors.green : AppColors.gold,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // ── معاينة الصورة أو أيقونة الرفع
            if (_receiptFile != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.file(
                  _receiptFile!,
                  width:  48.w,
                  height: 48.w,
                  fit:    BoxFit.cover,
                ),
              )
            else
              Container(
                padding:    EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color:        AppColors.gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.upload_file_rounded,
                    color: AppColors.gold, size: 22.sp),
              ),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _receiptFile != null
                        ? 'تم رفع الإيصال ✅'
                        : 'ارفع صورة إيصال التحويل',
                    style: TextStyle(
                      fontSize:   14.sp,
                      fontWeight: FontWeight.bold,
                      color:      _receiptFile != null
                          ? Colors.green
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _receiptFile != null
                        ? 'اضغط لتغيير الصورة'
                        : 'صورة أو PDF • حجم أقصى 5MB',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color:    isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            if (_receiptFile != null)
              GestureDetector(
                onTap: () => setState(() => _receiptFile = null),
                child: Icon(Icons.close_rounded,
                    color: Colors.red, size: 20.sp),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2);
  }

  // ════════════════════════════════════════════════════
  // Shimmer Loading
  // ════════════════════════════════════════════════════
  Widget _buildWalletsShimmer() {
    return GridView.builder(
      shrinkWrap:  true,
      physics:     const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:   3,
        crossAxisSpacing: 8.w,
        mainAxisSpacing:  8.h,
        childAspectRatio: 0.9,
      ),
      itemCount: 3,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color:        Colors.grey[300],
          borderRadius: BorderRadius.circular(16.r),
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 1000.ms),
    );
  }

  // ════════════════════════════════════════════════════
  // Confirm Button
  // ════════════════════════════════════════════════════
  Widget _buildConfirmButton(bool isDark) {
    final canConfirm = _method == 'cash' ||
        (_method == 'wallet' &&
            _selectedWallet != null &&
            _receiptFile    != null);

    return SizedBox(
      width:  double.infinity,
      height: 54.h,
      child:  ElevatedButton(
        onPressed: canConfirm ? _confirm : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:         AppColors.gold,
          disabledBackgroundColor: Colors.grey[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation:   6,
          shadowColor: AppColors.gold.withOpacity(0.4),
        ),
        child: Text(
          _method == 'cash'
              ? 'تأكيد — الدفع عند الاستلام'
              : 'تأكيد الدفع الإلكتروني',
          style: TextStyle(
            fontSize:   15.sp,
            fontWeight: FontWeight.bold,
            color:      Colors.white,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Future<void> _pickReceipt() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);

    try {
      final picked = await ImagePicker().pickImage(
        source:       ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null) setState(() => _receiptFile = File(picked.path));
    } finally {
      setState(() => _isPickingImage = false);
    }
  }

  void _confirm() {
    Navigator.pop(
      context,
      OrderPaymentResult(
        paymentMethod: _method,
        wallet:        _selectedWallet,
        receiptFile:   _receiptFile,
      ),
    );
  }
}
