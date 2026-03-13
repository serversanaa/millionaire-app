import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:millionaire_barber/features/products/data/models/order_model.dart';
import 'package:millionaire_barber/features/products/data/repositories/order_repository.dart';
import 'package:millionaire_barber/features/products/presentation/widgets/product_payment_sheet.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui' as ui;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../providers/cart_provider.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with TickerProviderStateMixin {
  // ✅ Controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  // ✅ Animation Controllers
  late AnimationController _headerAnimController;
  late AnimationController _formAnimController;
  late AnimationController _buttonAnimController;
  late Animation<double> _headerAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // ✅ State Variables
  bool _isLoading = false;
  String _selectedPaymentMethod = 'cash'; // cash only


  OrderPaymentResult? _paymentResult;
  final _orderRepository = OrderRepository();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
  }

  void _initializeAnimations() {
    _headerAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _formAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _buttonAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerAnimController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formAnimController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = CurvedAnimation(
      parent: _buttonAnimController,
      curve: Curves.elasticOut,
    );

    _headerAnimController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _formAnimController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _buttonAnimController.forward();
    });
  }

  Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user != null) {
      setState(() {
        _nameController.text = user.fullName ?? '';
        _phoneController.text = user.phone ?? '';
        _addressController.text = user.address ?? '';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _headerAnimController.dispose();
    _formAnimController.dispose();
    _buttonAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = Provider.of<CartProvider>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F7FA),
          body: Stack(
            children: [
              // ✅ Animated Background
              _buildAnimatedBackground(isDark),

              // ✅ Main Content
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildAppBar(isDark),
                  SliverToBoxAdapter(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _formAnimController,
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildOrderSummaryCard(cart, isDark),
                                SizedBox(height: 20.h),
                                _buildCustomerInfoSection(isDark),
                                SizedBox(height: 20.h),
                                _buildPaymentMethodSection(isDark),
                                SizedBox(height: 100.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ✅ Floating Complete Button
              _buildFloatingCompleteButton(cart, isDark),

              // ✅ Loading Overlay
              if (_isLoading) _buildLoadingOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // ✅ ANIMATED BACKGROUND
  // ════════════════════════════════════════════════════════════

  Widget _buildAnimatedBackground(bool isDark) {
    return Positioned.fill(
      child: Stack(
        children: List.generate(20, (index) {
          return Positioned(
            left: (index * 80.0) % 1.sw,
            top: (index * 120.0) % 1.sh,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 2000 + (index * 100)),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, -value * 60),
                  child: Opacity(
                    opacity: (1 - value) * 0.3,
                    child: Container(
                      width: 6.w,
                      height: 6.h,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            AppColors.gold.withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // ✅ APP BAR
  // ════════════════════════════════════════════════════════════

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 160.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: ScaleTransition(
        scale: _headerAnimation,
        child: Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.1),
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : Colors.black87,
              size: 20.sp,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: FadeTransition(
          opacity: _headerAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: isDark
                    ? [
                  const Color(0xFF1A1A1A),
                  const Color(0xFF2C2C2C),
                ]
                    : [
                  AppColors.gold.withOpacity(0.1),
                  AppColors.darkRed.withOpacity(0.05),
                ],
              ),
            ),
            child: Stack(
              children: [
                // ✅ Animated Circles
                ..._buildHeaderCircles(),

                // ✅ Content
                Positioned(
                  bottom: 30.h,
                  right: 20.w,
                  left: 20.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.gold, AppColors.goldDark],
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.gold.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.shopping_bag_rounded,
                              color: Colors.white,
                              size: 28.sp,
                            ),
                          )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3))
                              .scale(duration: 1500.ms, begin: const Offset(1, 1), end: const Offset(1.05, 1.05)),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'إتمام الطلب',
                                  style: TextStyle(
                                    fontSize: 26.sp,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : AppColors.black,
                                    height: 1.2,
                                  ),
                                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                                SizedBox(height: 4.h),
                                Text(
                                  'خطوة واحدة لإتمام طلبك',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: isDark ? Colors.grey[400] : AppColors.greyDark,
                                  ),
                                ).animate().fadeIn(delay: 300.ms),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildHeaderCircles() {
    return List.generate(3, (index) {
      return Positioned(
        right: -50.w + (index * 100.w),
        top: -50.h + (index * 60.h),
        child: Container(
          width: 150.w,
          height: 150.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.gold.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
          duration: Duration(milliseconds: 2000 + index * 500),
          begin: const Offset(1, 1),
          end: const Offset(1.2, 1.2),
        ),
      );
    });
  }

  // ════════════════════════════════════════════════════════════
  // ✅ ORDER SUMMARY CARD
  // ════════════════════════════════════════════════════════════

  Widget _buildOrderSummaryCard(CartProvider cart, bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          width: 1.5,
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.gold,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'ملخص الطلب',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.black,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
          SizedBox(height: 20.h),
          _buildOrderRow('عدد المنتجات', '${cart.itemCount}', isDark, 0),
          _buildOrderRow('المجموع الفرعي', '${cart.subtotal.toStringAsFixed(2)} ر.ي', isDark, 1),
          // _buildOrderRow('الشحن', 'مجاني', isDark, 2),
          Divider(height: 32.h, thickness: 1.5),
          _buildOrderRow(
            'الإجمالي',
            '${cart.totalPrice.toStringAsFixed(2)} ر.ي',
            isDark,
            3,
            isTotal: true,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildOrderRow(String label, String value, bool isDark, int index, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTotal ? 0 : 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18.sp : 15.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isDark
                  ? (isTotal ? Colors.white : Colors.grey[400])
                  : (isTotal ? AppColors.black : AppColors.greyDark),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 20.sp : 16.sp,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
              color: isTotal ? AppColors.gold : (isDark ? Colors.white : AppColors.black),
            ),
          ),
        ],
      ).animate().fadeIn(delay: Duration(milliseconds: 300 + index * 50)).slideX(begin: 0.1),
    );
  }

  // ════════════════════════════════════════════════════════════
  // ✅ CUSTOMER INFO SECTION
  // ════════════════════════════════════════════════════════════

  Widget _buildCustomerInfoSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          width: 1.5,
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkRed.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.darkRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.darkRed,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'معلومات العميل',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.black,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 250.ms).slideX(begin: -0.2),
          SizedBox(height: 20.h),
          _buildAnimatedTextField(
            controller: _nameController,
            label: 'الاسم',
            hint: 'أدخل اسمك الكامل',
            icon: Icons.person_outline,
            isDark: isDark,
            delay: 300,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الرجاء إدخال الاسم';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          _buildAnimatedTextField(
            controller: _phoneController,
            label: 'رقم الجوال',
            hint: 'أدخل رقم جوالك',
            icon: Icons.phone_outlined,
            isDark: isDark,
            delay: 350,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الرجاء إدخال رقم الجوال';
              }
              if (value.length < 9) {
                return 'رقم الجوال غير صحيح';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          _buildAnimatedTextField(
            controller: _addressController,
            label: 'عنوان التوصيل',
            hint: 'أدخل عنوان التوصيل',
            icon: Icons.location_on_outlined,
            isDark: isDark,
            delay: 400,
            maxLines: 2,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الرجاء إدخال عنوان التوصيل';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          _buildAnimatedTextField(
            controller: _notesController,
            label: 'ملاحظات إضافية (اختياري)',
            hint: 'أضف أي ملاحظات للطلب',
            icon: Icons.note_outlined,
            isDark: isDark,
            delay: 450,
            maxLines: 3,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    required int delay,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[300] : AppColors.greyDark,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 15.sp,
            color: isDark ? Colors.white : AppColors.black,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
              fontSize: 14.sp,
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.gold,
              size: 22.sp,
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(
                color: AppColors.gold,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          ),
        ),
      ],
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.1);
  }

  // ════════════════════════════════════════════════════════════
  // ✅ PAYMENT METHOD SECTION
  // ════════════════════════════════════════════════════════════

  Widget _buildPaymentMethodSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          width: 1.5,
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color:      Colors.green.withOpacity(0.08),
            blurRadius: 20,
            offset:     const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header (نفس التصميم الأصلي)
          Row(
            children: [
              Container(
                padding:    EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color:        Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.payment_rounded,
                  color: Colors.green,
                  size:  24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'طريقة الدفع',
                style: TextStyle(
                  fontSize:   20.sp,
                  fontWeight: FontWeight.bold,
                  color:      isDark ? Colors.white : AppColors.black,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),

          SizedBox(height: 20.h),

          // ── زر اختيار طريقة الدفع
          GestureDetector(
            onTap: () async {
              final cart   = Provider.of<CartProvider>(context, listen: false);
              final result = await showProductPaymentSheet(
                context,
                totalAmount: cart.total,
              );
              if (result != null) {
                setState(() => _paymentResult = result);
              }
            },
            child: AnimatedContainer(
              duration:   const Duration(milliseconds: 300),
              padding:    EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color:        _paymentResult != null
                    ? AppColors.gold.withOpacity(isDark ? 0.15 : 0.08)
                    : (isDark ? const Color(0xFF2C2C2C) : Colors.grey[100]),
                borderRadius: BorderRadius.circular(16.r),
                border:       Border.all(
                  color: _paymentResult != null
                      ? AppColors.gold
                      : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                  width: _paymentResult != null ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding:    EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      gradient: _paymentResult != null
                          ? const LinearGradient(
                          colors: [AppColors.gold, AppColors.goldDark])
                          : null,
                      color:        _paymentResult == null
                          ? (isDark ? Colors.grey[800] : Colors.grey[300])
                          : null,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      _paymentResult == null
                          ? Icons.payment_outlined
                          : (_paymentResult!.isCash
                          ? Icons.money_rounded
                          : Icons.account_balance_wallet_rounded),
                      color: _paymentResult != null ? Colors.white : Colors.grey[600],
                      size:  24.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _paymentResult == null
                              ? 'اختر طريقة الدفع'
                              : (_paymentResult!.isCash
                              ? 'الدفع عند الاستلام'

                              : 'دفع إلكتروني — ${_paymentResult!.wallet?.walletType ?? ''}'),
                          style: TextStyle(
                            fontSize:   16.sp,
                            fontWeight: FontWeight.bold,
                            color:      isDark ? Colors.white : AppColors.black,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _paymentResult == null
                              ? 'نقدي أو دفع إلكتروني'
                              : (_paymentResult!.isCash
                              ? 'ادفع نقداً عند استلام طلبك'
                              : _paymentResult!.receiptFile != null
                              ? 'تم رفع الإيصال ✅'
                              : ''),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color:    isDark ? Colors.grey[400] : AppColors.greyDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _paymentResult != null
                        ? Icons.check_circle_rounded
                        : Icons.chevron_left_rounded,
                    color: _paymentResult != null ? AppColors.gold : Colors.grey,
                    size:  24.sp,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 450.ms).scale(begin: const Offset(0.95, 0.95)),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }

  // Widget _buildPaymentMethodSection(bool isDark) {
  //   return Container(
  //     padding: EdgeInsets.all(20.w),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: isDark
  //             ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
  //             : [Colors.white, Colors.grey.shade50],
  //       ),
  //       borderRadius: BorderRadius.circular(24.r),
  //       border: Border.all(
  //         width: 1.5,
  //         color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
  //       ),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.green.withOpacity(0.08),
  //           blurRadius: 20,
  //           offset: const Offset(0, 10),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Container(
  //               padding: EdgeInsets.all(8.w),
  //               decoration: BoxDecoration(
  //                 color: Colors.green.withOpacity(0.1),
  //                 borderRadius: BorderRadius.circular(12.r),
  //               ),
  //               child: Icon(
  //                 Icons.payment_rounded,
  //                 color: Colors.green,
  //                 size: 24.sp,
  //               ),
  //             ),
  //             SizedBox(width: 12.w),
  //             Text(
  //               'طريقة الدفع',
  //               style: TextStyle(
  //                 fontSize: 20.sp,
  //                 fontWeight: FontWeight.bold,
  //                 color: isDark ? Colors.white : AppColors.black,
  //               ),
  //             ),
  //           ],
  //         ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),
  //         SizedBox(height: 20.h),
  //         _buildPaymentOption(
  //           title: 'الدفع عند الاستلام',
  //           subtitle: 'ادفع نقداً عند استلام الطلب',
  //           icon: Icons.money_rounded,
  //           value: 'cash',
  //           isDark: isDark,
  //         ).animate().fadeIn(delay: 450.ms).scale(begin: const Offset(0.95, 0.95)),
  //       ],
  //     ),
  //   ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.95, 0.95));
  // }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required bool isDark,
  }) {
    final isSelected = _selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.gold.withOpacity(0.15) : AppColors.gold.withOpacity(0.1))
              : (isDark ? const Color(0xFF2C2C2C) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.gold : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                  colors: [AppColors.gold, AppColors.goldDark],
                )
                    : null,
                color: isSelected ? null : (isDark ? Colors.grey[800] : Colors.grey[300]),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark ? Colors.grey[400] : AppColors.greyDark,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.gold, AppColors.goldDark],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20.sp,
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.5))
                  .scale(duration: 300.ms, begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
          ],
        ),
      ),
    );
  }


  // ════════════════════════════════════════════════════════════
  // ✅ FLOATING COMPLETE BUTTON
  // ════════════════════════════════════════════════════════════

  Widget _buildFloatingCompleteButton(CartProvider cart, bool isDark) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 10.h,
            bottom: 10.h,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 48.h,
              maxHeight: 64.h,
            ),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _completeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  disabledBackgroundColor: Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.gold.withOpacity(0.4),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'تأكيد الطلب',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '(${cart.totalPrice.toStringAsFixed(2)} ر.ي)',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // ✅ LOADING OVERLAY
  // ════════════════════════════════════════════════════════════

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1500),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value * 2 * 3.14159,
                    child: Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.gold, AppColors.goldDark],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_bag_rounded,
                        color: Colors.white,
                        size: 30.sp,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20.h),
              Text(
                'جاري معالجة الطلب...',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // ✅ COMPLETE ORDER
  // ════════════════════════════════════════════════════════════

// ✅ الكود المصحح لـ _completeOrder

  // Future<void> _completeOrder() async {
  //   if (!_formKey.currentState!.validate()) return;
  //
  //   setState(() => _isLoading = true);
  //
  //   try {
  //     final cart = Provider.of<CartProvider>(context, listen: false);
  //     final userProvider = Provider.of<UserProvider>(context, listen: false);
  //     final user = userProvider.user;
  //
  //     if (user == null) throw Exception('يجب تسجيل الدخول أولاً');
  //
  //     // ✅ Orders data مصححة
  //     final orderData = {
  //       'user_id': user.id,
  //       'order_number': 'ORD-${DateTime.now().millisecondsSinceEpoch}',
  //       'customer_name': _nameController.text.trim(),
  //       'customer_phone': _phoneController.text.trim(),
  //       'delivery_address': _addressController.text.trim(),
  //       'delivery_notes': _notesController.text.trim(),
  //       'payment_method': _selectedPaymentMethod,
  //       'payment_status': 'unpaid',
  //       'delivery_method': 'home_delivery',
  //       'status': 'pending',
  //       'subtotal': cart.subtotal,
  //       'delivery_fee': cart.deliveryFee,
  //       // 'tax_amount': cart.tax,
  //       'discount_amount': 0.0,
  //       'total_amount': cart.total,
  //       'loyalty_points_used': 0,
  //       'loyalty_points_earned': (cart.total * 0.01).round(),
  //     };
  //
  //     final orderResponse = await Supabase.instance.client
  //         .from('orders')
  //         .insert(orderData)
  //         .select()
  //         .single();
  //
  //     final orderId = orderResponse['id'];
  //
  //     // ✅ Order Items data مصححة
  //     final orderItems = cart.items.entries.map((entry) {
  //       final item = entry.value;
  //       return {
  //         'order_id': orderId,
  //         'product_id': item.product.id,
  //         'product_name': item.product.name,
  //         'product_name_en': item.product.nameEn ?? '',
  //         'product_image_url': item.product.imageUrl,
  //         'unit_price': item.product.finalPrice,
  //         'quantity': item.quantity,
  //         'discount_percentage': item.product.discountPercentage ?? 0.0,
  //         'discount_amount': 0.0,
  //         'subtotal': item.product.finalPrice * item.quantity,
  //         'total': item.totalPrice,
  //       };
  //     }).toList();
  //
  //     await Supabase.instance.client.from('order_items').insert(orderItems);
  //
  //     cart.clear();
  //     final order = Order.fromJson(orderResponse as Map<String, dynamic>);
  //
  //     if (mounted) {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
  //       );
  //     }
  //
  //     _showSnackBar('تم إنشاء الطلب بنجاح!');
  //   } catch (e) {
  //     debugPrint('❌ Error: $e');
  //     _showSnackBar('حدث خطأ: ${e.toString()}', isError: true);
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }



  // Future<void> _completeOrder() async {
  //   if (!_formKey.currentState!.validate()) return;
  //
  //   setState(() => _isLoading = true);
  //
  //   try {
  //     final cart = Provider.of<CartProvider>(context, listen: false);
  //     final userProvider = Provider.of<UserProvider>(context, listen: false);
  //     final user = userProvider.user;
  //
  //     if (user == null) throw Exception('يجب تسجيل الدخول أولاً');
  //
  //     // ✅ 1. إنشاء Order
  //     final orderData = {
  //       'user_id': user.id,
  //       'order_number': 'ORD-${DateTime.now().millisecondsSinceEpoch}',
  //       'customer_name': _nameController.text.trim(),
  //       'customer_phone': _phoneController.text.trim(),
  //       'delivery_address': _addressController.text.trim(),
  //       'delivery_notes': _notesController.text.trim(),
  //       'payment_method': _selectedPaymentMethod,
  //       'payment_status': 'unpaid',
  //       'delivery_method': 'home_delivery',
  //       'status': 'pending',
  //       'subtotal': cart.subtotal,
  //       'delivery_fee': cart.deliveryFee,
  //       'tax_amount': 0.0, // أو cart.tax إذا كان موجود
  //       'discount_amount': 0.0,
  //       'total_amount': cart.total,
  //       'loyalty_points_used': 0,
  //       'loyalty_points_earned': (cart.total * 0.01).round(),
  //       'created_at': DateTime.now().toIso8601String(),
  //       'updated_at': DateTime.now().toIso8601String(),
  //     };
  //
  //     final orderResponse = await Supabase.instance.client
  //         .from('orders')
  //         .insert(orderData)
  //         .select()
  //         .single();
  //
  //     final orderId = orderResponse['id'] as String;
  //     debugPrint('✅ Order created: $orderId');
  //
  //     // ✅ 2. إضافة Order Items
  //     final orderItems = cart.items.entries.map((entry) {
  //       final item = entry.value;
  //       return {
  //         'order_id': orderId,
  //         'product_id': item.product.id,
  //         'product_name': item.product.name,
  //         'product_name_en': item.product.nameEn ?? '',
  //         'product_image_url': item.product.imageUrl,
  //         'unit_price': item.product.finalPrice,
  //         'quantity': item.quantity,
  //         'discount_percentage': item.product.discountPercentage ?? 0.0,
  //         'discount_amount': 0.0,
  //         'subtotal': item.product.finalPrice * item.quantity,
  //         'total': item.totalPrice,
  //         'notes': null,
  //       };
  //     }).toList();
  //
  //     await Supabase.instance.client
  //         .from('order_items')
  //         .insert(orderItems);
  //
  //     debugPrint('✅ Inserted ${orderItems.length} items');
  //
  //     // ✅ 3. جلب Order كامل مع Items
  //     final completeOrderResponse = await Supabase.instance.client
  //         .from('orders')
  //         .select('*, order_items(*)')  // ✅ جلب المنتجات معه
  //         .eq('id', orderId)
  //         .single();
  //
  //     debugPrint('✅ Fetched complete order with items');
  //
  //     // ✅ 4. تحويل إلى Order Model
  //     final order = Order.fromJson(completeOrderResponse as Map<String, dynamic>);
  //
  //     debugPrint('✅ Order has ${order.items?.length ?? 0} items');
  //
  //     // ✅ 5. مسح السلة
  //     cart.clear();
  //
  //     // ✅ 6. الانتقال لشاشة النجاح
  //     if (mounted) {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (_) => OrderSuccessScreen(order: order),
  //         ),
  //       );
  //       _showSnackBar('تم إنشاء الطلب بنجاح! ✓');
  //     }
  //
  //   } catch (e, stackTrace) {
  //     debugPrint('❌ Error: $e');
  //     debugPrint('Stack: $stackTrace');
  //     _showSnackBar('حدث خطأ: ${e.toString()}', isError: true);
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }


  // ═══ استبدل _completeOrder ═══
  Future<void> _completeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ التحقق من طريقة الدفع
    if (_paymentResult == null) {
      _showSnackBar('الرجاء اختيار طريقة الدفع', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cart         = Provider.of<CartProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user         = userProvider.user;

      if (user == null || user.id == null) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      final order = await _orderRepository.createOrder(
        userId:          user.id!,
        customerName:    _nameController.text.trim(),
        customerPhone:   _phoneController.text.trim(),
        deliveryAddress: _addressController.text.trim(),
        deliveryNotes:   _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        subtotal:        cart.subtotal,
        deliveryFee:     cart.deliveryFee,
        totalAmount:     cart.total,
        cartItems:       cart.items.values.toList(),
        paymentResult:   _paymentResult!,
      );

      cart.clear();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderSuccessScreen(order: order),
          ),
        );

        final msg = _paymentResult!.isCash
            ? 'تم إنشاء طلبك! ادفع عند الاستلام 💰'
            : 'تم إنشاء طلبك! سنراجع إيصالك قريباً ✅';
        _showSnackBar(msg);
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      _showSnackBar('حدث خطأ: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }
}
