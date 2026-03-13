// lib/features/home/presentation/widgets/home_banner_slider.dart

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:millionaire_barber/features/home/domain/models/banner_model.dart';
import 'package:provider/provider.dart';
import '../providers/banner_provider.dart';

class HomeBannerSlider extends StatefulWidget {
  const HomeBannerSlider({Key? key}) : super(key: key);

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  final _pageController = PageController(viewportFraction: 1.0);
  Timer? _timer;
  int    _current = 0;
  static const int _virtualCount = 10000;

  @override
  void initState() {
    super.initState();
    // ✅ ابدأ من المنتصف حتى يمكن التمرير يساراً ويميناً
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_virtualCount ~/ 2);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
  //
  // void _startTimer(int count) {
  //   _timer?.cancel();
  //   if (count <= 1) return;
  //   _timer = Timer.periodic(const Duration(seconds: 5), (_) {
  //     if (!mounted || !_pageController.hasClients) return;
  //     final next = (_current + 1) % count;
  //     _pageController.animateToPage(
  //       next,
  //       duration: const Duration(milliseconds: 700),
  //       curve:    Curves.easeInOutCubic,
  //     );
  //   });
  // }

  // ✅ عدّل _startTimer — استبدله كاملاً
  void _startTimer(int count) {
    _timer?.cancel();
    if (count <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 700),
        curve:    Curves.easeInOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) return _shimmer();
        if (provider.banners.isEmpty) return const SizedBox.shrink();

        final banners = provider.banners;

        // ابدأ التايمر مرة واحدة
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_timer == null) _startTimer(banners.length);
        });

        return Column(
          children: [
            // ══ Slider ══
            Container(
              margin:      EdgeInsets.symmetric(horizontal: 16.w),
              decoration:  BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color:      Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset:     const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child:// ✅ عدّل build — استبدل PageView.builder
              AspectRatio(
                aspectRatio: 3 / 1,
                child: PageView.builder(
                  controller:    _pageController,
                  itemCount:     _virtualCount,              // ✅ لا نهائي
                  onPageChanged: (i) => setState(
                        () => _current = i % banners.length,    // ✅ الصفحة الحقيقية
                  ),
                  itemBuilder: (_, i) =>
                      _bannerItem(banners[i % banners.length]), // ✅ تكرار البنرات
                ),
              ),

            ),

            // ══ Dots ══
            if (banners.length > 1) ...[
              SizedBox(height: 10.h),
              _dots(banners.length),
            ],
          ],
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08);
      },
    );
  }

  Widget _bannerItem(BannerModel banner) {
    return GestureDetector(
      onTap: () => _onTap(banner),
      child: CachedNetworkImage(
        imageUrl:    banner.imageUrl,
        fit:         BoxFit.cover,
        width:       double.infinity,
        placeholder: (_, __) => _placeholder(),
        errorWidget: (_, __, ___) => _errorWidget(),
      ),
    );
  }

  // ✅ عدّل _dots — بدون تغيير، يعمل مع _current الجديد
  Widget _dots(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == _current; // ✅ _current = i % banners.length
        return AnimatedContainer(
          duration:   const Duration(milliseconds: 300),
          margin:     EdgeInsets.symmetric(horizontal: 3.w),
          width:      active ? 22.w : 7.w,
          height:     7.h,
          decoration: BoxDecoration(
            color:        active
                ? const Color(0xFFB8860B)
                : Colors.grey.withOpacity(0.4),
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }

  // Widget _dots(int count) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: List.generate(count, (i) {
  //       final active = i == _current;
  //       return AnimatedContainer(
  //         duration:   const Duration(milliseconds: 300),
  //         margin:     EdgeInsets.symmetric(horizontal: 3.w),
  //         width:      active ? 22.w : 7.w,
  //         height:     7.h,
  //         decoration: BoxDecoration(
  //           color:        active
  //               ? const Color(0xFFB8860B)
  //               : Colors.grey.withOpacity(0.4),
  //           borderRadius: BorderRadius.circular(4.r),
  //         ),
  //       );
  //     }),
  //   );
  // }


  Widget _placeholder() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          color:       const Color(0xFFB8860B),
          strokeWidth: 2,
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 900.ms, color: isDark ? Colors.white12 : Colors.black12);
  }

  Widget _errorWidget() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_rounded,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
              size:  30.sp),
          SizedBox(height: 6.h),
          Text(
            'تعذّر تحميل البنر',
            style: TextStyle(
              color:    isDark ? Colors.grey[600] : Colors.grey[400],
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin:       EdgeInsets.symmetric(horizontal: 16.w),
      clipBehavior: Clip.antiAlias,
      decoration:   BoxDecoration(
        color:        isDark ? const Color(0xFF2A2A2A) : Colors.grey[200],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: AspectRatio(aspectRatio: 3 / 1),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
      duration: 900.ms,
      color: isDark ? Colors.white10 : Colors.black12,
    );
  }


  void _onTap(BannerModel banner) {
    if (banner.linkType == null || banner.linkType == 'none') return;
    switch (banner.linkType) {
      case 'offer':
        Navigator.pushNamed(context, '/offers');
        break;
      case 'service':
        Navigator.pushNamed(context, '/services');
        break;
      case 'product':
        Navigator.pushNamed(context, '/products');
        break;
    }
  }

}
