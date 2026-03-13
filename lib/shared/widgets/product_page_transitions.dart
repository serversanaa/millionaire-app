// lib/core/animations/product_page_transitions.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// ════════════════════════════════════════════════════════════
/// 🎭 1. CINEMATIC HERO TRANSITION
/// ════════════════════════════════════════════════════════════
class CinematicPageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final Curve curve;
  final Duration duration;

  CinematicPageRoute({
    required this.builder,
    this.curve = Curves.easeOutCubic,
    this.duration = const Duration(milliseconds: 600),
    RouteSettings? settings,
  }) : super(settings: settings, fullscreenDialog: false);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return _CinematicTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      curve: curve,
      child: child,
    );
  }
}

class _CinematicTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Curve curve;
  final Widget child;

  const _CinematicTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.curve,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
    );

    return Stack(
      children: [
        // ✅ Background Blur Effect
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 - (animation.value * 0.1),
              child: Opacity(
                opacity: 1.0 - (animation.value * 0.3),
                child: child,
              ),
            );
          },
          child: Container(color: Colors.black),
        ),

        // ✅ Main Content with Multiple Effects
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(curvedAnimation),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

/// ════════════════════════════════════════════════════════════
/// 🎪 2. REVEAL TRANSITION (CIRCULAR)
/// ════════════════════════════════════════════════════════════
class CircularRevealPageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final Offset? centerOffset;
  final Duration duration;

  CircularRevealPageRoute({
    required this.builder,
    this.centerOffset,
    this.duration = const Duration(milliseconds: 800),
    RouteSettings? settings,
  }) : super(settings: settings);

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    final size = MediaQuery.of(context).size;
    final center = centerOffset ?? Offset(size.width / 2, size.height / 2);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ClipPath(
          clipper: CircularRevealClipper(
            fraction: animation.value,
            centerOffset: center,
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}

class CircularRevealClipper extends CustomClipper<Path> {
  final double fraction;
  final Offset? centerOffset;

  CircularRevealClipper({
    required this.fraction,
    this.centerOffset,
  });

  @override
  Path getClip(Size size) {
    final center = centerOffset ?? Offset(size.width / 2, size.height / 2);
    final radius = math.sqrt(
      math.pow(size.width, 2) + math.pow(size.height, 2),
    );

    return Path()
      ..addOval(
        Rect.fromCircle(
          center: center,
          radius: radius * fraction,
        ),
      );
  }

  @override
  bool shouldReclip(CircularRevealClipper oldClipper) {
    return fraction != oldClipper.fraction;
  }
}

/// ════════════════════════════════════════════════════════════
/// 🌊 3. WAVE TRANSITION
/// ════════════════════════════════════════════════════════════
class WavePageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final Duration duration;

  WavePageRoute({
    required this.builder,
    this.duration = const Duration(milliseconds: 800),
    RouteSettings? settings,
  }) : super(settings: settings);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ClipPath(
          clipper: WaveClipper(animation.value),
          child: child,
        );
      },
      child: child,
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  final double animation;

  WaveClipper(this.animation);

  @override
  Path getClip(Size size) {
    final path = Path();
    final waveHeight = 50.0;

    path.moveTo(0, size.height);

    for (double i = 0; i <= size.width; i++) {
      final y = size.height -
          (size.height * animation) +
          (math.sin((i / size.width * 2 * math.pi) + (animation * math.pi * 2)) *
              waveHeight * (1 - animation));
      path.lineTo(i, y);
    }

    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) {
    return animation != oldClipper.animation;
  }
}

/// ════════════════════════════════════════════════════════════
/// 🎨 4. MORPHING TRANSITION
/// ════════════════════════════════════════════════════════════
class MorphingPageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final Duration duration;
  final Color? backgroundColor;

  MorphingPageRoute({
    required this.builder,
    this.duration = const Duration(milliseconds: 700),
    this.backgroundColor,
    RouteSettings? settings,
  }) : super(settings: settings);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return Stack(
      children: [
        // Background morphing effect
        AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return Container(
              decoration: BoxDecoration(
                color: (backgroundColor ?? const Color(0xFFB8860B))
                    .withOpacity(animation.value * 0.3),
              ),
            );
          },
        ),

        // Content with scale and fade
        ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      ],
    );
  }
}

/// ════════════════════════════════════════════════════════════
/// 🎯 5. ZOOM + ROTATE TRANSITION
/// ════════════════════════════════════════════════════════════
class ZoomRotatePageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final Duration duration;

  ZoomRotatePageRoute({
    required this.builder,
    this.duration = const Duration(milliseconds: 600),
    RouteSettings? settings,
  }) : super(settings: settings);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateZ((1 - animation.value) * 0.5)
            ..scale(0.8 + (animation.value * 0.2)),
          alignment: Alignment.center,
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// ════════════════════════════════════════════════════════════
/// 🌟 6. PARTICLES EXPLOSION TRANSITION
/// ════════════════════════════════════════════════════════════
class ParticlesPageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final Duration duration;
  final Color particleColor;

  ParticlesPageRoute({
    required this.builder,
    this.duration = const Duration(milliseconds: 1000),
    this.particleColor = const Color(0xFFB8860B),
    RouteSettings? settings,
  }) : super(settings: settings);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return Stack(
      children: [
        // Particles background
        ..._buildParticles(animation, particleColor),

        // Main content
        FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
            ),
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
              ),
            ),
            child: child,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildParticles(Animation<double> animation, Color color) {
    return List.generate(30, (index) {
      final angle = (index / 30) * 2 * math.pi;
      final distance = 300.0;

      return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final progress = Curves.easeOut.transform(animation.value);
          final x = math.cos(angle) * distance * progress;
          final y = math.sin(angle) * distance * progress;

          return Positioned(
            left: MediaQuery.of(context).size.width / 2 + x - 4,
            top: MediaQuery.of(context).size.height / 2 + y - 4,
            child: Opacity(
              opacity: (1 - progress) * 0.8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

/// ════════════════════════════════════════════════════════════
/// 🎪 HELPER: NAVIGATION EXTENSIONS
/// ════════════════════════════════════════════════════════════
extension ProductTransitionNavigation on BuildContext {
  // Cinematic transition
  Future<T?> pushCinematic<T>(Widget page) {
    return Navigator.of(this).push<T>(
      CinematicPageRoute(builder: (_) => page),
    );
  }

  // Circular reveal
  Future<T?> pushCircularReveal<T>(Widget page, {Offset? center}) {
    return Navigator.of(this).push<T>(
      CircularRevealPageRoute(builder: (_) => page, centerOffset: center),
    );
  }

  // Wave transition
  Future<T?> pushWave<T>(Widget page) {
    return Navigator.of(this).push<T>(
      WavePageRoute(builder: (_) => page),
    );
  }

  // Morphing transition
  Future<T?> pushMorphing<T>(Widget page, {Color? backgroundColor}) {
    return Navigator.of(this).push<T>(
      MorphingPageRoute(
        builder: (_) => page,
        backgroundColor: backgroundColor,
      ),
    );
  }

  // Zoom rotate
  Future<T?> pushZoomRotate<T>(Widget page) {
    return Navigator.of(this).push<T>(
      ZoomRotatePageRoute(builder: (_) => page),
    );
  }

  // Particles explosion
  Future<T?> pushParticles<T>(Widget page, {Color? particleColor}) {
    return Navigator.of(this).push<T>(
      ParticlesPageRoute(
        builder: (_) => page,
        particleColor: particleColor ?? const Color(0xFFB8860B),
      ),
    );
  }
}
