import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:millionaire_barber/features/authentication/presentation/pages/login_screen.dart';
import 'package:millionaire_barber/features/home/presentation/screens/home_screen.dart';
import 'package:millionaire_barber/features/profile/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ════════════════════════════════════════════════════════════════════════════
// ✅ Brand Colors
// ════════════════════════════════════════════════════════════════════════════

const Color kBrandBlack = Color(0xFF000000);
const Color kBrandWhite = Color(0xFFFFFFFF);
const Color kBrandRed = Color(0xFFA62424);
const Color kBrandGold = Color(0xFFB6862C);
const Color kBrandDarkGold = Color(0xFF8B6B20);

// ════════════════════════════════════════════════════════════════════════════
// ✅ Onboarding Page - Optimized Design
// ════════════════════════════════════════════════════════════════════════════

class OnboardingPage extends StatefulWidget {
  final VoidCallback? onDone;

  const OnboardingPage({Key? key, this.onDone}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _rotationController;
  late PageController _pageController;
  int currentPage = 0;

  final pageAssets = [
    'assets/images/onboardingscreen1.png',
    'assets/images/onboardingscreen2.png',
    'assets/images/onboardingscreen3.png',
    'assets/images/onboardingscreen4.png',
  ];

  final titles = [
    "قصات شعر عصرية",
    "أناقة طبيعية",
    "عناية فاخرة",
    "تجربة استثنائية",
  ];

  final bodies = [
    "إطلالة مثالية تبدأ بقصة شعر احترافية\nصممت خصيصاً لك",
    "استعد ثقتك مع تصفيفة تناسب شخصيتك\nوتبرز أناقتك الطبيعية",
    "عناية متكاملة لبشرتك ووجهك\nرفاهية تستحقها في كل زيارة",
    "خدمات حصرية للرجل المميز\nتجربة لا تُنسى في صالون المليونير",
  ];

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _pageController = PageController();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _rotationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleOnDone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_shown', true);

      if (!mounted) return;

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final isLoggedIn = userProvider.isLoggedIn;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => isLoggedIn ? const HomeScreen() : const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _nextPage() {
    if (currentPage < pageAssets.length - 1) {
      _pageController.animateToPage(
        currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  /// ════════════════════════════════════════════════════════════════
  /// ✅ Build Animated Background
  /// ════════════════════════════════════════════════════════════════

  Widget _buildArabicPatternBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -120.h,
              right: -120.w,
              child: Transform.rotate(
                angle: _rotationController.value * 2 * pi,
                child: Container(
                  width: 320.w,
                  height: 320.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: kBrandGold.withOpacity(0.08),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -180.h,
              left: -180.w,
              child: Transform.rotate(
                angle: -_rotationController.value * 2 * pi,
                child: Container(
                  width: 450.w,
                  height: 450.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: kBrandRed.withOpacity(0.05),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// ════════════════════════════════════════════════════════════════
  /// ✅ Build Animated Image
  /// ════════════════════════════════════════════════════════════════

  Widget _buildAnimatedImage(String assetName, int index) {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        final offset = sin(_floatingController.value * 2 * pi) * 12;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Glow Effect
            Container(
              width: 280.w,
              height: 280.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    kBrandGold.withOpacity(0.15),
                    kBrandGold.withOpacity(0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Main Image
            Transform.translate(
              offset: Offset(0, offset * 0.3),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: kBrandGold.withOpacity(0.2),
                      blurRadius: 35,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Image.asset(
                  assetName,
                  width: 250.w,
                  height: 250.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// ════════════════════════════════════════════════════════════════
  /// ✅ Build Page Content
  /// ════════════════════════════════════════════════════════════════

  Widget _buildPageContent(String title, String body, String asset, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ✅ Number Badge (محسّن)
        Container(
          width: 60.w,
          height: 60.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kBrandGold, kBrandDarkGold],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: kBrandGold.withOpacity(0.35),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w900,
                color: kBrandWhite,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        )
            .animate()
            .scale(duration: 500.ms, curve: Curves.easeOutBack)
            .fadeIn(duration: 400.ms),

        SizedBox(height: 28.h),

        // ✅ Title (محسّن)
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 34.sp,
            fontWeight: FontWeight.w900,
            color: isDark ? kBrandGold : kBrandRed,
            fontFamily: 'Cairo',
            height: 1.2,
            letterSpacing: -0.5,
            shadows: [
              Shadow(
                color: (isDark ? kBrandGold : kBrandRed).withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        )
            .animate()
            .slideX(duration: 500.ms, begin: 0.3, curve: Curves.easeOut)
            .fadeIn(duration: 500.ms),

        SizedBox(height: 20.h),

        // ✅ Decorative Divider (محسّن)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50.w,
              height: 2.5.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, kBrandGold],
                ),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 14.w),
              width: 10.w,
              height: 10.h,
              decoration: BoxDecoration(
                color: kBrandGold,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kBrandGold.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            Container(
              width: 50.w,
              height: 2.5.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kBrandGold, Colors.transparent],
                ),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ],
        )
            .animate()
            .scale(duration: 600.ms, delay: 200.ms)
            .fadeIn(duration: 400.ms),

        SizedBox(height: 35.h),

        // ✅ Image (محسّن)
        _buildAnimatedImage(asset, index)
            .animate()
            .scale(duration: 700.ms, curve: Curves.elasticOut)
            .fadeIn(duration: 500.ms),

        SizedBox(height: 35.h),

        // ✅ Body Text (محسّن)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 45.w),
          child: Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? Colors.white.withOpacity(0.9)
                  : kBrandBlack.withOpacity(0.75),
              fontFamily: 'Cairo',
              height: 1.8,
              letterSpacing: 0.3,
            ),
          )
              .animate()
              .slideX(
                  duration: 500.ms,
                  delay: 300.ms,
                  begin: -0.3,
                  curve: Curves.easeOut)
              .fadeIn(duration: 500.ms, delay: 300.ms),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLastPage = currentPage == pageAssets.length - 1;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0a0a0a) : kBrandWhite,
        body: Column(
          children: [
            // ✅ Main Content
            Expanded(
              child: Stack(
                children: [
                  // Background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                const Color(0xFF0a0a0a),
                                const Color(0xFF1a1510),
                              ]
                            : [
                                kBrandWhite,
                                const Color(0xFFFFF8F0),
                              ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  _buildArabicPatternBackground(isDark),

                  // Page View
                  PageView(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => currentPage = index),
                    children: List.generate(
                      pageAssets.length,
                      (index) => SingleChildScrollView(
                        child: SizedBox(
                          height: 1.sh - 140.h,
                          child: Center(
                            child: _buildPageContent(
                              titles[index],
                              bodies[index],
                              pageAssets[index],
                              index,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Skip Button
                  if (!isLastPage)
                    Positioned(
                      top: 50.h,
                      left: 24.w,
                      child: SafeArea(
                        child: _buildSkipButton(isDark),
                      ),
                    ),
                ],
              ),
            ),

            // ✅ Bottom Navigation
            SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 22.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0a0a0a) : kBrandWhite,
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? kBrandGold.withOpacity(0.12)
                          : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomDotsIndicator(
                      dotsCount: pageAssets.length,
                      position: currentPage,
                      activeColor: kBrandRed,
                      inactiveColor:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                    ),
                    if (isLastPage)
                      _buildDoneButton()
                    else
                      _buildNextButton(isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ════════════════════════════════════════════════════════════════
  /// ✅ Skip Button (محسّن)
  /// ════════════════════════════════════════════════════════════════

  Widget _buildSkipButton(bool isDark) {
    return GestureDetector(
      onTap: _handleOnDone,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 11.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              kBrandRed.withOpacity(0.15),
              kBrandRed.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: kBrandRed.withOpacity(0.35),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              color: kBrandRed,
              size: 20.sp,
            ),
            SizedBox(width: 7.w),
            Text(
              'تخطي',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: kBrandRed,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.3);
  }

  /// ════════════════════════════════════════════════════════════════
  /// ✅ Next Button (محسّن)
  /// ════════════════════════════════════════════════════════════════

  Widget _buildNextButton(bool isDark) {
    return GestureDetector(
      onTap: _nextPage,
      child: Container(
        width: 68.w,
        height: 68.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kBrandGold, kBrandDarkGold],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: kBrandGold.withOpacity(0.45),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          color: kBrandWhite,
          size: 30.sp,
        ),
      ),
    )
        .animate()
        .scale(duration: 450.ms, curve: Curves.easeOut)
        .then()
        .shimmer(duration: 2000.ms, color: kBrandWhite.withOpacity(0.25));
  }

  /// ════════════════════════════════════════════════════════════════
  /// ✅ Done Button (محسّن)
  /// ════════════════════════════════════════════════════════════════

  Widget _buildDoneButton() {
    return GestureDetector(
      onTap: _handleOnDone,
      child: Container(
        width: 76.w,
        height: 76.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kBrandGold, kBrandDarkGold],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: kBrandGold.withOpacity(0.55),
              blurRadius: 25,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Icon(
          Icons.content_cut_rounded,
          color: kBrandWhite,
          size: 38.sp,
        ),
      ),
    )
        .animate()
        .scale(duration: 550.ms, curve: Curves.elasticOut)
        .then()
        .shimmer(duration: 1500.ms, color: kBrandWhite.withOpacity(0.4))
        .then(delay: 500.ms)
        .shake(duration: 350.ms, hz: 3);
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ✅ Custom Dots Indicator (محسّن)
// ════════════════════════════════════════════════════════════════════════════

class CustomDotsIndicator extends StatelessWidget {
  final int dotsCount;
  final int position;
  final Color activeColor;
  final Color inactiveColor;

  const CustomDotsIndicator({
    Key? key,
    required this.dotsCount,
    required this.position,
    required this.activeColor,
    required this.inactiveColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.rtl,
      children: List.generate(dotsCount, (index) {
        final isActive = index == position;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          width: isActive ? 38.w : 13.w,
          height: 13.h,
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [activeColor, activeColor.withOpacity(0.75)],
                  )
                : null,
            color: isActive ? null : inactiveColor,
            borderRadius: BorderRadius.circular(7.r),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.45),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        )
            .animate(target: isActive ? 1 : 0)
            .scale(duration: 250.ms, curve: Curves.easeOut);
      }),
    );
  }
}
