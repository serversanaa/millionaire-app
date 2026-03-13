// lib/features/support/presentation/pages/faq_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/support_provider.dart';
import 'dart:ui' as ui;

class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  String? _expandedId;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportProvider>().fetchFAQs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        appBar: _buildAppBar(isDark),
        body: Consumer<SupportProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return _buildLoadingState();
            }

            if (provider.faqs.isEmpty) {
              return _buildEmptyState(isDark);
            }

            final categorizedFAQs = provider.getFAQsByCategory();

            return RefreshIndicator(
              onRefresh: () => provider.fetchFAQs(),
              color: AppColors.darkRed,
              child: ListView(
                padding: EdgeInsets.all(16.r),
                children: [
                  _buildHeader(isDark),
                  SizedBox(height: 24.h),
                  ...categorizedFAQs.entries.map((entry) {
                    return _buildCategorySection(entry.key, entry.value, isDark);
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ✅ AppBar محسّن
  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: isDark ? Colors.white : AppColors.black,
          size: 20.sp,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'الأسئلة الشائعة',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.black,
          fontFamily: 'Cairo',
        ),
      ),
      centerTitle: true,
    );
  }

  // ✅ Loading State محسّن
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.darkRed.withOpacity(0.3),
                      AppColors.darkRed.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                  .scale(duration: 1500.ms, begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),

              Container(
                width: 70.w,
                height: 70.h,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkRed),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            'جاري تحميل الأسئلة...',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              fontFamily: 'Cairo',
            ),
          ).animate(onPlay: (controller) => controller.repeat())
              .fadeIn(duration: 800.ms)
              .then()
              .fadeOut(duration: 800.ms),
        ],
      ),
    );
  }

  // ✅ Header محسّن
  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkRed, AppColors.darkRedDark],
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
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.help_outline_rounded,
              size: 50.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'كيف يمكننا مساعدتك؟',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'اطلع على الأسئلة الأكثر شيوعاً وأجوبتها',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.9),
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn().scale(duration: 600.ms);
  }

  // ✅ Category Section محسّن
  Widget _buildCategorySection(String category, List<dynamic> faqs, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Row(
            children: [
              Container(
                width: 4.w,
                height: 24.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.darkRed, AppColors.darkRedDark],
                  ),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                category,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.black,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
        ...faqs.asMap().entries.map((entry) {
          final faqIndex = entry.key;
          final faq = entry.value;
          // ✅ إنشاء ID فريد لكل سؤال
          final uniqueId = '$category-$faqIndex';
          return _buildFAQItem(
            faq: faq,
            uniqueId: uniqueId,
            isDark: isDark,
          );
        }),
      ],
    );
  }

  // ✅ تعديل الدالة لاستخدام uniqueId بدلاً من index
  Widget _buildFAQItem({
    required dynamic faq,
    required String uniqueId,
    required bool isDark,
  }) {
    final isExpanded = _expandedId == uniqueId;  // ✅ مقارنة بالـ ID

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
          colors: [Color(0xFF1E1E1E), Color(0xFF2A2A2A)],
        )
            : LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isExpanded
              ? AppColors.darkRed
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          width: isExpanded ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isExpanded
                ? AppColors.darkRed.withOpacity(0.15)
                : Colors.black.withOpacity(0.05),
            blurRadius: isExpanded ? 12 : 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                // ✅ إذا كان مفتوح نفس العنصر، أغلقه. وإلا افتح العنصر الجديد
                _expandedId = isExpanded ? null : uniqueId;
              });
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.darkRed.withOpacity(0.2),
                          AppColors.darkRed.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.help_outline_rounded,
                      color: AppColors.darkRed,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      faq.getQuestion().toString(),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.black,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.darkRed,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12.r),
                  bottomRight: Radius.circular(12.r),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppColors.gold,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      faq.getAnswer().toString(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? Colors.grey.shade300 : AppColors.greyDark,
                        height: 1.5,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.2, duration: 300.ms),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.2);
  }
// ✅ Empty State محسّن
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.darkRed.withOpacity(0.2),
                    AppColors.darkRed.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.help_outline_rounded,
                size: 70.sp,
                color: AppColors.darkRed,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            SizedBox(height: 24.h),
            Text(
              'لا توجد أسئلة شائعة حالياً',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.black,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            SizedBox(height: 12.h),
            Text(
              'تواصل معنا مباشرة للحصول على المساعدة',
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? Colors.grey.shade500 : AppColors.greyDark,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),
      ),
    );
  }
}
