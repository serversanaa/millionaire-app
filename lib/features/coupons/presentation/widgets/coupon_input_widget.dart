// lib/features/coupons/presentation/widgets/coupon_input_widget.dart

import 'package:flutter/material.dart';
import 'package:millionaire_barber/features/coupons/presentation/providers/coupon_provider.dart';
import 'package:millionaire_barber/features/loyalty/presentation/providers/loyalty_transaction_provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../profile/presentation/providers/user_provider.dart';

class CouponInputWidget extends StatefulWidget {
  final double amount;
  final Function(double discountAmount)? onCouponApplied;

  const CouponInputWidget({
    Key? key,
    required this.amount,
    this.onCouponApplied,
  }) : super(key: key);

  @override
  State<CouponInputWidget> createState() => _CouponInputWidgetState();
}

class _CouponInputWidgetState extends State<CouponInputWidget> {
  final TextEditingController _couponController = TextEditingController();
  bool _isApplying = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    if (_couponController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال كود الكوبون')),
      );
      return;
    }

    setState(() => _isApplying = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final couponProvider = Provider.of<CouponProvider>(context, listen: false);

    // ✅ إضافة LoyaltyTransactionProvider للتحديث
    final loyaltyProvider = Provider.of<LoyaltyTransactionProvider>(context, listen: false);

    if (userProvider.user == null) {
      setState(() => _isApplying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب تسجيل الدخول أولاً')),
      );
      return;
    }

    final success = await couponProvider.validateAndApplyCoupon(
      code: _couponController.text,
      userId: userProvider.user!.id!,
      amount: widget.amount,
      isVip: userProvider.user!.vipStatus ?? false,
    );

    setState(() => _isApplying = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${couponProvider.validationResult!.message}'),
          backgroundColor: Colors.green,
        ),
      );

      // ✅ تحديث قائمة الكوبونات في الخلفية
      loyaltyProvider.refreshLoyaltyData(userProvider.user!.id!);

      if (widget.onCouponApplied != null) {
        widget.onCouponApplied!(couponProvider.discountAmount!);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${couponProvider.error ?? "فشل تطبيق الكوبون"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<CouponProvider>(
      builder: (context, couponProvider, _) {
        if (couponProvider.appliedCoupon != null) {
          return _buildAppliedCouponCard(couponProvider, isDark);
        }

        return _buildCouponInput(isDark);
      },
    );
  }

  Widget _buildCouponInput(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // ignore: prefer_const_constructors
              Icon(Icons.local_offer_rounded, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Text(
                'هل لديك كود خصم؟',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  enabled: !_isApplying,
                  textCapitalization: TextCapitalization.characters,
                  style: TextStyle(color: isDark ? Colors.white : AppColors.black),
                  decoration: InputDecoration(
                    hintText: 'أدخل الكود هنا',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isApplying ? null : _applyCoupon,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isApplying
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text('تطبيق'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppliedCouponCard(CouponProvider provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_circle, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تم تطبيق الكوبون',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.appliedCoupon!.code,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  provider.removeCoupon();
                  _couponController.clear();
                },
                icon: const Icon(Icons.close, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الخصم',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                Text(
                  '- ${provider.discountAmount!.toStringAsFixed(2)} ريال',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
