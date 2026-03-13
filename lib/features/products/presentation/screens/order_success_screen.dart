import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:confetti/confetti.dart';
import '../../data/models/order_model.dart';
import 'order_details_screen.dart';
import '../../../../core/constants/app_colors.dart';

class OrderSuccessScreen extends StatefulWidget {
  final Order order;

  const OrderSuccessScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _bounceAnimation;

  final ConfettiController _confetti = ConfettiController(
    duration: const Duration(seconds: 3),
  );

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _confetti.play();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _pulseAnimation =
        Tween<double>(begin: 1.0, end: 1.08).animate(CurvedAnimation(
          parent: _pulseController,
          curve: Curves.easeInOut,
        ));

    _bounceAnimation =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
            .animate(CurvedAnimation(
          parent: _bounceController,
          curve: Curves.elasticOut,
        ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0B0B) : const Color(0xFFF7FAFF),

      body: Stack(
        children: [
          /// confetti
          ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.05,
            gravity: 0.12,
            numberOfParticles: 22,
            colors: const [
              AppColors.gold,
              Colors.blue,
              Colors.green,
              Colors.purple,
              Colors.orange
            ],
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(20.w),

                child: Column(
                  children: [
                    SizedBox(height: 60.h),

                    /// animated success icon
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: SlideTransition(
                        position: _bounceAnimation,
                        child: Container(
                          width: 150.w,
                          height: 150.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.gold,
                                AppColors.goldDark,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withOpacity(0.5),
                                blurRadius: 30,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 70.sp,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 22.h),

                    Text(
                      "تم الطلب بنجاح",
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      "شكراً لثقتك بنا ✨",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),

                    SizedBox(height: 30.h),

                    /// order card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF131313), const Color(0xFF1F1F1F)]
                              : [Colors.white, const Color(0xFFF2F4F8)],
                        ),
                        borderRadius: BorderRadius.circular(22.r),
                        border: Border.all(
                          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          _row(Icons.receipt_long, "رقم الطلب",
                              "#${widget.order.orderNumber}", isDark),

                          SizedBox(height: 14.h),

                          // السطر الحالي صحيح:
                          _row(Icons.shopping_bag_outlined, "عدد المنتجات",
                              "${widget.order.items?.length ?? 0}", isDark),


                          SizedBox(height: 14.h),

                          _row(Icons.attach_money, "الإجمالي",
                              "${widget.order.totalAmount} ر.ي", isDark),

                          SizedBox(height: 14.h),

                          _row(Icons.info_outline, "الحالة",
                              widget.order.statusText ?? "قيد التنفيذ", isDark),
                        ],
                      ),
                    ),

                    SizedBox(height: 35.h),

                    /// details button
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderDetailsScreen(order: widget.order),
                            ),
                          );
                        },
                        icon: Icon(Icons.visibility, size: 22.sp),

                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "عرض تفاصيل الطلب",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                          backgroundColor: AppColors.gold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    /// go home
                    TextButton.icon(
                      onPressed: () =>
                          Navigator.of(context).popUntil((r) => r.isFirst),
                      icon: const Icon(Icons.home_outlined),
                      label: const Text("العودة للرئيسية"),
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

  Widget _row(IconData icon, String title, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: AppColors.gold),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        )
      ],
    );
  }
}
