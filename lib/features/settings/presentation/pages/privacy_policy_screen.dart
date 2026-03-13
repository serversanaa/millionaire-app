import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

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
            'سياسة الخصوصية',
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
              icon: Icons.info_outline_rounded,
              title: '1. مقدمة',
              content: 'نحن في مركز المليونير نلتزم بحماية خصوصيتك. توضح سياسة الخصوصية هذه كيفية جمع واستخدام وحماية معلوماتك الشخصية عند استخدام تطبيقنا.',
              isDark: isDark,
            ),
            _buildSection(
              icon: Icons.collections_bookmark_rounded,
              title: '2. المعلومات التي نجمعها',
              content: '''
• **المعلومات الشخصية**: الاسم، البريد الإلكتروني، رقم الهاتف
• **معلومات الحجز**: تاريخ ووقت المواعيد، الخدمات المطلوبة
• **معلومات الدفع**: تفاصيل المعاملات (مشفرة بالكامل)
• **معلومات الجهاز**: نوع الجهاز، نظام التشغيل، معرف الجهاز
• **بيانات الموقع**: لتحديد أقرب فروعنا (بإذنك فقط)
              ''',
              isDark: isDark,
            ),
            _buildSection(
              icon: Icons.lock_rounded,
              title: '3. كيف نستخدم معلوماتك',
              content: '''
• **إدارة الحجوزات**: لتأكيد وإدارة مواعيدك
• **التواصل**: لإرسال التأكيدات والتذكيرات والعروض
• **تحسين الخدمة**: لتطوير وتحسين تجربة المستخدم
• **الأمان**: لحماية حسابك ومنع الاحتيال
• **الامتثال القانوني**: للالتزام بالقوانين المعمول بها
              ''',
              isDark: isDark,
            ),
            _buildSection(
              icon: Icons.shield_rounded,
              title: '4. حماية معلوماتك',
              content: '''
• تشفير جميع البيانات الحساسة باستخدام SSL/TLS
• تخزين آمن في قواعد بيانات محمية
• الوصول المحدود للموظفين المصرح لهم فقط
• مراجعات أمنية دورية
• النسخ الاحتياطي المنتظم للبيانات
              ''',
              isDark: isDark,
            ),
            _buildSection(
              icon: Icons.share_rounded,
              title: '5. مشاركة المعلومات',
              content: 'نحن **لا نبيع** معلوماتك الشخصية لأطراف ثالثة. قد نشارك معلوماتك فقط مع:\n\n• مقدمي الخدمات الموثوق بهم (للمدفوعات والتحليلات)\n• السلطات القانونية (عند الطلب القانوني)\n• شركاء الأعمال (بموافقتك الصريحة)',
              isDark: isDark,
            ),
            _buildSection(
              icon: Icons.cookie_rounded,
              title: '6. ملفات تعريف الارتباط',
              content: 'نستخدم ملفات تعريف الارتباط (Cookies) لتحسين تجربتك وتخصيص المحتوى. يمكنك تعطيلها من إعدادات المتصفح.',
              isDark: isDark,
            ),
            _buildSection(
              icon: Icons.account_circle_rounded,
              title: '7. حقوقك',
              content: '''
لديك الحق في:
• الوصول إلى بياناتك الشخصية
• تصحيح أي معلومات غير دقيقة
• حذف حسابك وبياناتك
• سحب الموافقة في أي وقت
• تقديم شكوى إلى سلطة حماية البيانات
              ''',
              isDark: isDark,
            ),
            _buildSection(
              icon: Icons.child_care_rounded,
              title: '8. خصوصية الأطفال',
              content: 'تطبيقنا غير مخصص للأطفال دون سن 13 عامًا. نحن لا نجمع معلومات شخصية من الأطفال عن عمد.',
              isDark: isDark,
            ),
            _buildSection(
              icon: Icons.update_rounded,
              title: '9. التحديثات',
              content: 'قد نقوم بتحديث سياسة الخصوصية من وقت لآخر. سنقوم بإعلامك بأي تغييرات جوهرية عبر التطبيق أو البريد الإلكتروني.',
              isDark: isDark,
            ),
            _buildSection(
              icon: Icons.contact_mail_rounded,
              title: '10. اتصل بنا',
              content: '''
إذا كان لديك أي أسئلة حول سياسة الخصوصية:

📧 البريد الإلكتروني: privacy@millionairebarber.com
📞 الهاتف:  +967 775 999 992
📍 العنوان: جولة ريماس، شارع حده، صنعاء‎، اليمن
              ''',
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
          Icon(Icons.privacy_tip_rounded, color: Colors.white, size: 64.sp),
          SizedBox(height: 12.h),
          Text(
            'سياسة الخصوصية',
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
    required IconData icon,
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
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.darkRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: AppColors.darkRed, size: 24.sp),
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
