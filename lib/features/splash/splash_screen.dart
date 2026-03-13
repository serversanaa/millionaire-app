import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:millionaire_barber/features/authentication/presentation/pages/login_screen.dart';
import 'package:millionaire_barber/features/home/presentation/screens/home_screen.dart';
import 'package:millionaire_barber/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:millionaire_barber/features/profile/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

import '../../../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _navigate();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  Future<void> _navigate() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadUserStatus();

      final prefs = await SharedPreferences.getInstance();
      final onboardingShown = prefs.getBool('onboarding_shown') ?? false;

      await Future.delayed(const Duration(milliseconds: 3000));

      if (!mounted) return;

      if (!onboardingShown) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OnboardingPage(
              onDone: () async {
                await prefs.setBool('onboarding_shown', true);
                if (!mounted) return;
                _navigateAfterOnboarding(userProvider.isLoggedIn);
              },
            ),
          ),
        );
      } else {
        _navigateAfterOnboarding(userProvider.isLoggedIn);
      }
    } catch (e) {
      if (mounted) {
        _navigateAfterOnboarding(false);
      }
    }
  }

  void _navigateAfterOnboarding(bool isLoggedIn) {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return isLoggedIn ? const HomeScreen() : const LoginScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.darkRed,
                AppColors.darkRedDark,
                Color(0xFF1B1B1B),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Background Pattern
              _buildBackgroundPattern(),

              // Main Content
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with animations
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildLogo(),
                      ),

                      SizedBox(height: 40.h),

                      // Title
                      SlideTransition(
                        position: _slideAnimation,
                        child: _buildTitle(),
                      ),

                      SizedBox(height: 12.h),

                      // Subtitle
                      SlideTransition(
                        position: _slideAnimation,
                        child: _buildSubtitle(),
                      ),

                      SizedBox(height: 60.h),

                      // Loading indicator
                      _buildLoadingIndicator(),
                    ],
                  ),
                ),
              ),

              // Bottom branding
              // _buildBottomBranding(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _BackgroundPatternPainter(),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 160.w,
      height: 160.h,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha:0.2),
            Colors.white.withValues(alpha:0.05),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.gold.withValues(alpha:0.5),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha:0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha:0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glow effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withValues(alpha:0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .scale(
              duration: 2000.ms,
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.1, 1.1),
            )
                .then()
                .scale(
              duration: 2000.ms,
              begin: const Offset(1.1, 1.1),
              end: const Offset(0.9, 0.9),
            ),
          ),

          // Logo image
          Center(
            child: ClipOval(
              child: Image.asset(
                "assets/images/logo_splash.png",
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Shine effect
          Positioned(
            top: 15.h,
            right: 25.w,
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha:0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .fadeIn(duration: 1500.ms)
                .then()
                .fadeOut(duration: 1500.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'مركز المليونير',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
            fontFamily: 'Cairo',
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha:0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        )
            .animate(onPlay: (controller) => controller.repeat())
            .then(delay: 1000.ms)
            .shimmer(
          duration: 2000.ms,
          color: AppColors.gold.withValues(alpha:0.5),
        ),
        SizedBox(height: 4.h),
        Container(
          width: 60.w,
          height: 3.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.gold,
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(2.r),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .scaleX(duration: 1500.ms, begin: 0.5, end: 1.0)
            .then()
            .scaleX(duration: 1500.ms, begin: 1.0, end: 0.5),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'للحلاقة و العناية بالرجل',
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: Colors.white.withValues(alpha:0.9),
        letterSpacing: 2,
        fontFamily: 'Cairo',
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 50.r,
          height: 50.r,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
            backgroundColor: Colors.white.withValues(alpha:0.2),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .rotate(duration: 2000.ms),
        SizedBox(height: 16.h),
        Text(
          'جاري التحميل...',
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.white.withValues(alpha:0.7),
            fontFamily: 'Cairo',
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .fadeIn(duration: 1000.ms)
            .then()
            .fadeOut(duration: 1000.ms),
      ],
    );
  }

  // Widget _buildBottomBranding() {
  //   return Positioned(
  //     bottom: 40.h,
  //     left: 0,
  //     right: 0,
  //     child: Column(
  //       children: [
  //         Text(
  //           'تم التطوير بواسطة',
  //           style: TextStyle(
  //             fontSize: 11.sp,
  //             color: Colors.white.withValues(alpha:0.5),
  //             fontFamily: 'Cairo',
  //           ),
  //         ),
  //         SizedBox(height: 4.h),
  //         Text(
  //           'م. عبدالوهاب الربيعي',
  //           style: TextStyle(
  //             fontSize: 13.sp,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.white.withValues(alpha:0.8),
  //             fontFamily: 'Cairo',
  //           ),
  //         ),
  //         SizedBox(height: 2.h),
  //         Text(
  //           '776684112',
  //           style: TextStyle(
  //             fontSize: 12.sp,
  //             color: AppColors.gold.withValues(alpha:0.8),
  //             fontFamily: 'Cairo',
  //           ),
  //         ),
  //       ],
  //     ).animate().fadeIn(delay: 1500.ms).slideY(begin: 0.3),
  //   );
  // }
}

/// Custom painter for background pattern
class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha:0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw circles pattern
    for (var i = 0; i < 5; i++) {
      final radius = (i + 1) * 50.0;
      canvas.drawCircle(
        Offset(size.width * 0.2, size.height * 0.3),
        radius,
        paint,
      );
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.7),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

