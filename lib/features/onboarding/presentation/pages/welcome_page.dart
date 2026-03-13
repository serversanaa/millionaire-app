import 'package:flutter/material.dart';
import 'package:millionaire_barber/features/authentication/presentation/pages/login_screen.dart';
import 'package:millionaire_barber/features/authentication/presentation/pages/register_screen.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    const blackColor = Colors.black;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // الخلفية
            Positioned.fill(
              child: Image.asset(
                'assets/images/welcome_img.png',
                fit: BoxFit.cover,
              ),
            ),
            // التدرج
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.85),   // أعلى - أسود قوي شفاف
                      Colors.black.withOpacity(0.10),   // أسود شفاف جدًا قرب المنتصف
                      Colors.transparent,               // منتصف التدرج شفاف
                      Colors.white.withOpacity(0.85),   // أبيض خفيف تحت المنتصف
                      Colors.white,                     // أسفل - أبيض صريح
                    ],
                    stops: const [
                      0.0,   // بداية التدرج (أعلى)
                      0.18,  // قريب من الأعلى
                      0.2,  // قريب من المنتصف
                      0.82,  // تحت المنتصف
                      1.0,   // نهاية التدرج (أسفل)
                    ],
                  ),
                ),
              ),
            ),


            // المحتوى السفلي
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: screenHeight * 0.04),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: screenHeight * 0.02),

                    // النص الرئيسي
                    Text(
                      'أناقتك تبدأ من هنا',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.065,
                        fontWeight: FontWeight.bold,
                        color: blackColor,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.012),

                    // النص الفرعي
                    Text(
                      'إطلالة جديدة تبدأ من لمسة حلاقة احترافية... وتكتمل بخدمات العناية المتكاملة',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.038,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),

                    // زر تسجيل الدخول
                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.07,
                      child: ElevatedButton(
                        onPressed: () {
                          _navigateWithTransition(
                              context, const LoginScreen());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blackColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'تسجيل الدخول',
                          style: TextStyle(fontSize: screenWidth * 0.045),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    // زر انشاء حساب
                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.07,
                      child: OutlinedButton(
                        onPressed: () {
                          _navigateWithTransition(
                              context, const RegisterScreen());
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: blackColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Colors.black, width: 2),
                        ),
                        child: Text(
                          'انشاء حساب',
                          style: TextStyle(fontSize: screenWidth * 0.045),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // الشعار
            // Positioned(
            //   top: screenHeight * 0.18,
            //   left: 0,
            //   right: 0,
            //   child: Align(
            //     alignment: Alignment.center,
            //     child: Image.asset(
            //       'assets/images/logo.png',
            //       height: screenHeight * 0.14,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  /// دالة الانتقال مع تأثيرات مخصصة
  void _navigateWithTransition(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.2); // يبدأ من الأسفل قليلاً
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          final tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(tween),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

