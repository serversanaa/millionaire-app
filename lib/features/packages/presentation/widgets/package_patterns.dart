import 'package:flutter/material.dart';
import 'dart:math' as math;

/// ═══════════════════════════════════════════════════════════════
/// 🎨 Dynamic Pattern Painters
/// ═══════════════════════════════════════════════════════════════

class WavePatternPainter extends CustomPainter {
  final Color color;
  final double opacity;

  WavePatternPainter({required this.color, this.opacity = 0.12});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    for (int i = 0; i < 12; i++) {
      final path = Path();
      final yOffset = size.height * 0.08 * i;
      path.moveTo(0, yOffset);
      for (double x = 0; x <= size.width; x += 15) {
        final y = yOffset + math.sin((x / size.width) * math.pi * 5) * 18;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CirclePatternPainter extends CustomPainter {
  final Color color;
  final double opacity;

  CirclePatternPainter({required this.color, this.opacity = 0.1});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final centerX = size.width * 0.75;
    final centerY = size.height * 0.25;

    for (int i = 1; i < 15; i++) {
      canvas.drawCircle(Offset(centerX, centerY), i * 18.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GeometricPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;

  GeometricPatternPainter({required this.color, this.opacity = 0.08});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const spacing = 35.0;
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    paint.strokeWidth = 0.6;
    for (double x = -size.height; x <= size.width; x += spacing * 2) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DotsPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;

  DotsPatternPainter({required this.color, this.opacity = 0.15});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += 28) {
      for (double y = 0; y < size.height; y += 28) {
        canvas.drawCircle(Offset(x, y), 2.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SpiralPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;

  SpiralPatternPainter({required this.color, this.opacity = 0.1});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final centerX = size.width * 0.6;
    final centerY = size.height * 0.4;
    final path = Path();

    for (double angle = 0; angle < math.pi * 7; angle += 0.08) {
      final radius = angle * 4.5;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      if (angle == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HexagonPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;

  HexagonPatternPainter({required this.color, this.opacity = 0.09});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const spacing = 45.0;
    final height = spacing * math.sqrt(3) / 2;

    for (double y = 0; y <= size.height + height; y += height * 1.5) {
      for (double x = 0; x <= size.width + spacing; x += spacing * 1.5) {
        final offset =
        (y / (height * 1.5)).toInt() % 2 == 0 ? 0.0 : spacing * 0.75;
        _drawHexagon(canvas, Offset(x + offset, y), spacing / 2, paint);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ═══════════════════════════════════════════════════════════════
/// 🎯 Pattern Selector
/// ═══════════════════════════════════════════════════════════════
class PatternSelector {
  static CustomPainter getPattern(int index, Color color) {
    final patterns = [
      WavePatternPainter(color: color),
      CirclePatternPainter(color: color),
      GeometricPatternPainter(color: color),
      DotsPatternPainter(color: color),
      SpiralPatternPainter(color: color),
      HexagonPatternPainter(color: color),
    ];
    return patterns[index % patterns.length];
  }
}
