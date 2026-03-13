import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:millionaire_barber/shared/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../providers/support_provider.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
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
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              SizedBox(height: 24.h),
              _buildQuickActions(isDark),
              SizedBox(height: 24.h),
              _buildSocialMedia(isDark),
              SizedBox(height: 24.h),
              _buildContactForm(isDark),
              SizedBox(height: 24.h),
              _buildContactInfo(isDark),
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
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: isDark ? Colors.white : AppColors.black,
          size: 20.sp,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'اتصل بنا',
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.support_agent_rounded,
              size: 40.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نحن هنا لمساعدتك',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'تواصل معنا عبر القنوات المتاحة',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white.withOpacity(0.9),
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(duration: 600.ms);
  }

  Widget _buildQuickActions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
              'تواصل سريع',
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
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.phone_rounded,
                label: 'اتصال',
                color: Colors.green,
                isDark: isDark,
                onTap: () => _launchPhone('775999992'),
                index: 0,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.chat_rounded,
                label: 'واتساب',
                color: const Color(0xFF25D366),
                isDark: isDark,
                onTap: () => _launchWhatsApp('775999992'),
                index: 1,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.email_rounded,
                label: 'بريد',
                color: Colors.blue,
                isDark: isDark,
                onTap: () => _launchEmail('info@millionaire.com'),
                index: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
    required int index,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
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
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        color.withOpacity(0.2),
                        color.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24.sp),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.black,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn().scale();
  }

  Widget _buildSocialMedia(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
              'تابعنا على',
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
        Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    colors: [Color(0xFF1E1E1E), Color(0xFF2A2A2A)],
                  )
                : LinearGradient(
                    colors: [Colors.white, Colors.grey.shade50],
                  ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),

          // ✅ صف واحد متجاوب (5 عناصر)
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildSocialButton(
                  icon: FaIcon(
                    FontAwesomeIcons.facebookF,
                    color: const Color(0xFF1877F2),
                    size: 20.sp,
                  ),
                  color: const Color(0xFF1877F2),
                  label: 'فيسبوك',
                  isDark: isDark,
                  onTap: () =>
                      _launchUrl('https://www.facebook.com/MillionairMen/'),
                  index: 0,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildSocialButton(
                  icon: FaIcon(
                    FontAwesomeIcons.instagram,
                    color: const Color(0xFFE4405F),
                    size: 20.sp,
                  ),
                  color: const Color(0xFFE4405F),
                  label: 'انستغرام',
                  isDark: isDark,
                  onTap: () => _launchUrl(
                      'https://www.instagram.com/millionair_men?igsh=NHozdG40N3gycHp6'),
                  index: 1,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildSocialButton(
                  icon: FaIcon(
                    FontAwesomeIcons.tiktok,
                    color: Colors.black,
                    size: 20.sp,
                  ),
                  color: Colors.black,
                  label: 'تيك توك',
                  isDark: isDark,
                  onTap: () => _launchUrl(
                      'https://www.tiktok.com/@millionair_men?_r=1&_t=ZS-91oTFwkK0WI'),
                  index: 2,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildSocialButton(
                  icon: FaIcon(
                    FontAwesomeIcons.youtube,
                    color: const Color(0xFFFF0000),
                    size: 20.sp,
                  ),
                  color: const Color(0xFFFF0000),
                  label: 'يوتيوب',
                  isDark: isDark,
                  onTap: () => _launchUrl(
                      'https://www.youtube.com/channel/UCd9uQrr330VlaR6tpL9AWbw'),
                  index: 3,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildSocialButton(
                  icon: FaIcon(
                    FontAwesomeIcons.globe,
                    color: AppColors.darkRed,
                    size: 20.sp,
                  ),
                  color: AppColors.darkRed,
                  label: 'الموقع',
                  isDark: isDark,
                  onTap: () => _launchUrl('http://www.almilunercenter.online/'),
                  index: 4,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildSocialButton({
    required Widget icon,
    required Color color,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
    required int index,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(10.r), // ✅ قلّل البادينغ ليناسب 5 أزرار
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: icon,
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.black,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn().scale();
  }

  Widget _buildContactForm(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF1E1E1E), Color(0xFF2A2A2A)],
              )
            : LinearGradient(
                colors: [Colors.white, Colors.grey.shade50],
              ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                    Icons.message_rounded,
                    color: AppColors.darkRed,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'أرسل لنا رسالة',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.black,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            TextFormField(
              controller: _subjectController,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.black,
                fontFamily: 'Cairo',
              ),
              decoration: InputDecoration(
                labelText: 'الموضوع',
                labelStyle: TextStyle(
                  color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                  fontFamily: 'Cairo',
                ),
                prefixIcon: Icon(
                  Icons.subject_rounded,
                  color: AppColors.darkRed,
                  size: 20.sp,
                ),
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الموضوع';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _messageController,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.black,
                fontFamily: 'Cairo',
              ),
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'الرسالة',
                labelStyle: TextStyle(
                  color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                  fontFamily: 'Cairo',
                ),
                prefixIcon: Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.darkRed,
                  size: 20.sp,
                ),
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الرسالة';
                }
                return null;
              },
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkRed,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'إرسال الرسالة',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildContactInfo(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF1E1E1E), Color(0xFF2A2A2A)],
              )
            : LinearGradient(
                colors: [Colors.white, Colors.grey.shade50],
              ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
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
                  gradient: LinearGradient(
                    colors: [
                      AppColors.darkRed.withOpacity(0.2),
                      AppColors.darkRed.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.darkRed,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'معلومات التواصل',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.black,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildContactInfoItem(
            icon: Icons.location_on_rounded,
            title: 'العنوان',
            subtitle: 'جولة ريماس، شارع حده، صنعاء، اليمن',
            isDark: isDark,
          ),
          Divider(height: 24.h),
          _buildContactInfoItem(
            icon: Icons.phone_rounded,
            title: 'الهاتف',
            subtitle: '775999992',
            isDark: isDark,
          ),
          Divider(height: 24.h),
          _buildContactInfoItem(
            icon: Icons.email_rounded,
            title: 'البريد الإلكتروني',
            subtitle: 'info@millionaire.com',
            isDark: isDark,
          ),
          Divider(height: 24.h),
          _buildContactInfoItem(
            icon: Icons.access_time_rounded,
            title: 'ساعات العمل',
            subtitle: 'السبت - الجمعة: 9 صباحاً - 1 بعد منتصف الليل',
            isDark: isDark,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildContactInfoItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: AppColors.darkRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: AppColors.darkRed, size: 22.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                  fontFamily: 'Cairo',
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.black,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final userProvider = context.read<UserProvider>();
    final supportProvider = context.read<SupportProvider>();

    if (userProvider.user == null) {
      if (mounted) {
        CustomSnackbar.showError(context, 'يجب تسجيل الدخول أولاً');
      }
      setState(() => _isSubmitting = false);
      return;
    }

    final success = await supportProvider.sendMessage(
      userId: userProvider.user!.id!,
      subject: _subjectController.text,
      message: _messageController.text,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        CustomSnackbar.showSuccess(context, '✅ تم إرسال رسالتك بنجاح');
        _subjectController.clear();
        _messageController.clear();
      } else {
        CustomSnackbar.showError(context, 'فشل إرسال الرسالة');
      }
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:+967$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final uri = Uri.parse('https://wa.me/967$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        CustomSnackbar.showError(context, 'تعذر فتح الرابط');
      }
    }
  }
}
