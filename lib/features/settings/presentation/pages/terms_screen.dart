import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          title: Text(
            'الشروط والأحكام',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.black,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              size: 20.sp,
              color: isDark ? Colors.white : AppColors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.all(20.r),
          children: [
            _buildHeader(isDark),
            SizedBox(height: 24.h),
            _buildSection(
              number: '1',
              title: 'القبول بالشروط',
              content: 'باستخدامك لتطبيق مركز المليونير، فإنك توافق على الالتزام بهذه الشروط والأحكام. إذا كنت لا توافق على هذه الشروط، يرجى عدم استخدام التطبيق.',
              isDark: isDark,
            ),
            _buildSection(
              number: '2',
              title: 'استخدام التطبيق',
              content: '''
• يجب أن تكون 18 عامًا أو أكبر لاستخدام التطبيق
• يجب تقديم معلومات دقيقة وصحيحة عند التسجيل
• أنت مسؤول عن الحفاظ على سرية حسابك
• لا يجوز استخدام التطبيق لأغراض غير قانونية
              ''',
              isDark: isDark,
            ),
            _buildSection(
              number: '3',
              title: 'الحجوزات والمواعيد',
              content: '''
• جميع الحجوزات تخضع للتوفر
• يجب تأكيد الموعد قبل 24 ساعة على الأقل
• سياسة الإلغاء: إلغاء مجاني قبل 24 ساعة، بعد ذلك قد تطبق رسوم
• التأخر أكثر من 15 دقيقة قد يؤدي لإلغاء الموعد
• نحتفظ بالحق في رفض أو إلغاء أي حجز
              ''',
              isDark: isDark,
            ),
            _buildSection(
              number: '4',
              title: 'الدفع والأسعار',
              content: '''
• جميع الأسعار معروضة بالريال السعودي
• قد تتغير الأسعار دون إشعار مسبق
• الدفع يتم عبر الطرق المعتمدة في التطبيق
• الفواتير غير قابلة للاسترداد بعد تقديم الخدمة
              ''',
              isDark: isDark,
            ),
            _buildSection(
              number: '5',
              title: 'نقاط الولاء',
              content: '''
• نقاط الولاء غير قابلة للتحويل أو الاستبدال نقدًا
• صلاحية النقاط سنة واحدة من تاريخ الكسب
• نحتفظ بالحق في تعديل نظام نقاط الولاء
• استخدام النقاط بطريقة احتيالية يؤدي لإلغاء الحساب
              ''',
              isDark: isDark,
            ),
            _buildSection(
              number: '6',
              title: 'الملكية الفكرية',
              content: 'جميع محتويات التطبيق (الشعار، التصميم، النصوص، الصور) محمية بحقوق الملكية الفكرية ولا يجوز نسخها أو توزيعها دون إذن مسبق.',
              isDark: isDark,
            ),
            _buildSection(
              number: '7',
              title: 'المسؤولية',
              content: '''
• نحن غير مسؤولين عن أي أضرار مباشرة أو غير مباشرة
• التطبيق يُقدم "كما هو" دون أي ضمانات
• نحن غير مسؤولين عن انقطاع الخدمة أو الأخطاء التقنية
              ''',
              isDark: isDark,
            ),
            _buildSection(
              number: '8',
              title: 'التعديلات',
              content: 'نحتفظ بالحق في تعديل هذه الشروط في أي وقت. سيتم إخطارك بأي تغييرات جوهرية. استمرارك في استخدام التطبيق يعني قبولك للشروط المحدثة.',
              isDark: isDark,
            ),
            _buildSection(
              number: '9',
              title: 'إنهاء الحساب',
              content: 'نحتفظ بالحق في تعليق أو إنهاء حسابك في حالة انتهاك هذه الشروط دون إشعار مسبق.',
              isDark: isDark,
            ),
            _buildSection(
              number: '10',
              title: 'القانون الساري',
              content: 'تخضع هذه الشروط لقوانين الجمهورية اليمنية. أي نزاع يُحل وديًا أو عبر المحاكم المختصة في الرياض.',
              isDark: isDark,
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkRed, AppColors.darkRedDark],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(Icons.description_rounded, color: Colors.white, size: 64.sp),
          SizedBox(height: 12.h),
          Text(
            'الشروط والأحكام',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'آخر تحديث: 3 أكتوبر 2025',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String number,
    required String title,
    required String content,
    required bool isDark,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
              Container(
                width: 40.w,
                height: 40.h,
                decoration: const BoxDecoration(
                  color: AppColors.darkRed,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

}
