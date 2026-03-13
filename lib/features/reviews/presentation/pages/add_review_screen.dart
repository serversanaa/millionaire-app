// lib/features/reviews/presentation/pages/add_review_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../appointments/domain/models/appointment_model.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../providers/review_provider.dart';
import 'dart:ui' as ui;

class AddReviewScreen extends StatefulWidget {
  final AppointmentModel appointment;

  const AddReviewScreen({Key? key, required this.appointment})
      : super(key: key);

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  int _serviceRating = 0;
  int _employeeRating = 0;
  final _commentController = TextEditingController();
  bool _isAnonymous = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
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
        appBar: _buildAppBar(isDark),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppointmentCard(isDark),
              const SizedBox(height: 24),
              _buildServiceRating(isDark),
              const SizedBox(height: 24),
              if (widget.appointment.employeeId != null) ...[
                _buildEmployeeRating(isDark),
                const SizedBox(height: 24),
              ],
              _buildCommentSection(isDark),
              const SizedBox(height: 16),
              _buildAnonymousToggle(isDark),
              const SizedBox(height: 32),
              _buildSubmitButton(isDark),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: isDark ? Colors.white : AppColors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'تقييم الخدمة',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.black,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildAppointmentCard(bool isDark) {
    final service = widget.appointment.services?.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.darkRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.content_cut_rounded,
                color: AppColors.darkRed, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service?.serviceNameAr ?? service?.serviceName ?? 'خدمة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.appointment.employeeName ?? 'موظف',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  Widget _buildServiceRating(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تقييم الخدمة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.black,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _serviceRating = index + 1),
                child: Icon(
                  index < _serviceRating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 50,
                  color: index < _serviceRating
                      ? AppColors.gold
                      : Colors.grey.shade400,
                ).animate(delay: Duration(milliseconds: 50 * index)).scale(),
              );
            }),
          ),
        ),
        if (_serviceRating > 0) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              _getRatingText(_serviceRating),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ).animate().fadeIn(),
          ),
        ],
      ],
    );
  }

  Widget _buildEmployeeRating(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تقييم الموظف',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.black,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _employeeRating = index + 1),
                child: Icon(
                  index < _employeeRating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 50,
                  color: index < _employeeRating
                      ? AppColors.gold
                      : Colors.grey.shade400,
                ).animate(delay: Duration(milliseconds: 50 * index)).scale(),
              );
            }),
          ),
        ),
        if (_employeeRating > 0) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              _getRatingText(_employeeRating),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ).animate().fadeIn(),
          ),
        ],
      ],
    );
  }

  Widget _buildCommentSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رأيك (اختياري)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.black,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _commentController,
          maxLines: 5,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'شاركنا تجربتك مع الخدمة...',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.darkRed, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnonymousToggle(bool isDark) {
    return Row(
      children: [
        Switch(
          value: _isAnonymous,
          onChanged: (value) => setState(() => _isAnonymous = value),
          activeColor: AppColors.darkRed,
        ),
        const SizedBox(width: 8),
        Text(
          'نشر التقييم بشكل مجهول',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isDark) {
    final canSubmit = _serviceRating > 0;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canSubmit && !_isSubmitting ? _submitReview : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkRed,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'إرسال التقييم',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 5:
        return 'ممتاز! 🌟';
      case 4:
        return 'جيد جداً 👍';
      case 3:
        return 'جيد 😊';
      case 2:
        return 'مقبول 😐';
      case 1:
        return 'ضعيف 😞';
      default:
        return '';
    }
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

    if (userProvider.user == null) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تسجيل الدخول أولاً')),
      );
      return;
    }

    // إنشاء تقييم الخدمة
    final serviceSuccess = await reviewProvider.createReview(
      userId: userProvider.user!.id!,
      appointmentId: widget.appointment.id!,
      serviceId: widget.appointment.services?.first.serviceId,
      rating: _serviceRating,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
      isAnonymous: _isAnonymous,
    );

    // إنشاء تقييم الموظف إذا كان موجوداً
    if (widget.appointment.employeeId != null && _employeeRating > 0) {
      await reviewProvider.createReview(
        userId: userProvider.user!.id!,
        appointmentId: widget.appointment.id!,
        employeeId: widget.appointment.employeeId,
        rating: _employeeRating,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
        isAnonymous: _isAnonymous,
      );
    }

    setState(() => _isSubmitting = false);

    if (serviceSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ شكراً لتقييمك! رأيك مهم لنا.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فشل إرسال التقييم، حاول مرة أخرى'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
