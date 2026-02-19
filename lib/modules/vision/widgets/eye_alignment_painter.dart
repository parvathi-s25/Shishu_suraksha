import 'dart:math';
import 'package:flutter/material.dart';

/// Custom painter that draws two animated eye diagrams with real-time
/// iris positions, deviation arcs, and symmetry visualisation.
class EyeAlignmentPainter extends CustomPainter {
  /// Iris horizontal ratio for each eye (0.0 = far left, 0.5 = center, 1.0 = far right)
  final double leftRatio;
  final double rightRatio;

  /// Deviation percentages (0–100) for numeric labels
  final double leftDeviation;
  final double rightDeviation;

  /// Whether the head position is correct (enables green/red tint)
  final bool isHeadCorrect;

  /// Scan progress 0.0–1.0 (drives the outer progress ring)
  final double scanProgress;

  /// Animation phase multiplier (0.0–1.0) for fade-in
  final double animationValue;

  EyeAlignmentPainter({
    required this.leftRatio,
    required this.rightRatio,
    required this.leftDeviation,
    required this.rightDeviation,
    required this.isHeadCorrect,
    this.scanProgress = 0.0,
    this.animationValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = animationValue.clamp(0.0, 1.0);
    if (opacity < 0.01) return;

    final cx = size.width / 2;
    final cy = size.height * 0.42;
    final eyeSpacing = size.width * 0.22;
    final eyeRadiusX = size.width * 0.13;
    final eyeRadiusY = eyeRadiusX * 0.55;
    final irisRadius = eyeRadiusX * 0.42;
    final pupilRadius = irisRadius * 0.45;

    // --- Draw face oval guide ---
    final facePaint = Paint()
      ..color = Colors.black.withOpacity(0.12 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - eyeRadiusY * 0.5), width: eyeSpacing * 3, height: eyeSpacing * 4),
      facePaint,
    );

    // --- Draw each eye ---
    _drawEye(
      canvas: canvas,
      center: Offset(cx - eyeSpacing, cy),
      eyeRx: eyeRadiusX,
      eyeRy: eyeRadiusY,
      irisR: irisRadius,
      pupilR: pupilRadius,
      irisRatio: leftRatio,
      deviation: leftDeviation,
      label: 'L',
      opacity: opacity,
    );

    _drawEye(
      canvas: canvas,
      center: Offset(cx + eyeSpacing, cy),
      eyeRx: eyeRadiusX,
      eyeRy: eyeRadiusY,
      irisR: irisRadius,
      pupilR: pupilRadius,
      irisRatio: rightRatio,
      deviation: rightDeviation,
      label: 'R',
      opacity: opacity,
    );

    // --- Center alignment axis ---
    final axisPaint = Paint()
      ..color = Colors.black.withOpacity(0.25 * opacity)
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(cx, cy - eyeRadiusY * 1.8),
      Offset(cx, cy + eyeRadiusY * 1.8),
      axisPaint,
    );

    // --- Symmetry bar ---
    _drawSymmetryBar(canvas, size, opacity);

    // --- Scan progress ring ---
    if (scanProgress > 0.0) {
      _drawProgressRing(canvas, Offset(cx, cy), eyeSpacing * 2.2, opacity);
    }
  }

  void _drawEye({
    required Canvas canvas,
    required Offset center,
    required double eyeRx,
    required double eyeRy,
    required double irisR,
    required double pupilR,
    required double irisRatio,
    required double deviation,
    required String label,
    required double opacity,
  }) {
    // Sclera (white of eye) — almond shape
    final scleraPaint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    final scleraBorderPaint = Paint()
      ..color = Colors.black.withOpacity(0.15 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final scleraRect = Rect.fromCenter(center: center, width: eyeRx * 2, height: eyeRy * 2);
    canvas.drawOval(scleraRect, scleraPaint);
    canvas.drawOval(scleraRect, scleraBorderPaint);

    // Iris position — map ratio to horizontal offset within eye
    final maxIrisTravel = eyeRx - irisR - 2;
    final irisOffsetX = (irisRatio - 0.5) * 2 * maxIrisTravel;
    final irisCenter = Offset(center.dx + irisOffsetX, center.dy);

    // Iris
    final irisGradient = RadialGradient(
      colors: [
        const Color(0xFF5D4037).withOpacity(opacity),
        const Color(0xFF3E2723).withOpacity(opacity),
      ],
    );
    final irisPaint = Paint()
      ..shader = irisGradient.createShader(
        Rect.fromCircle(center: irisCenter, radius: irisR),
      );
    canvas.drawCircle(irisCenter, irisR, irisPaint);

    // Pupil
    final pupilPaint = Paint()
      ..color = Colors.black.withOpacity(0.95 * opacity);
    canvas.drawCircle(irisCenter, pupilR, pupilPaint);

    // Light reflection
    final reflectionPaint = Paint()
      ..color = Colors.white.withOpacity(0.7 * opacity);
    canvas.drawCircle(
      Offset(irisCenter.dx - pupilR * 0.35, irisCenter.dy - pupilR * 0.35),
      pupilR * 0.25,
      reflectionPaint,
    );

    // Deviation color arc
    final devNorm = (deviation / 30.0).clamp(0.0, 1.0);
    final devColor = Color.lerp(
      Colors.green.withOpacity(0.8 * opacity),
      Colors.red.withOpacity(0.8 * opacity),
      devNorm,
    )!;
    final arcPaint = Paint()
      ..color = devColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    final arcRadius = eyeRx + 6;
    final sweepAngle = devNorm * pi * 0.5;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcRadius),
      -pi / 2 - sweepAngle / 2,
      sweepAngle,
      false,
      arcPaint,
    );

    // Label
    final labelPainter = TextPainter(
      text: TextSpan(
        text: '$label: ${deviation.toStringAsFixed(1)}%',
        style: TextStyle(
          color: devColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();
    labelPainter.paint(canvas, Offset(center.dx - labelPainter.width / 2, center.dy + eyeRy + 14));
  }

  void _drawSymmetryBar(Canvas canvas, Size size, double opacity) {
    final barWidth = size.width * 0.6;
    final barHeight = 6.0;
    final barY = size.height * 0.72;
    final barX = (size.width - barWidth) / 2;

    // Background
    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.1 * opacity)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barX, barY, barWidth, barHeight),
        const Radius.circular(3),
      ),
      bgPaint,
    );

    // Asymmetry = difference between deviations
    final asymmetry = (leftDeviation - rightDeviation).abs();
    final asymNorm = (asymmetry / 20.0).clamp(0.0, 1.0);
    final fillColor = Color.lerp(
      Colors.green.withOpacity(0.8 * opacity),
      Colors.red.withOpacity(0.8 * opacity),
      asymNorm,
    )!;
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    final fillWidth = barWidth * (1.0 - asymNorm);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barX, barY, fillWidth, barHeight),
        const Radius.circular(3),
      ),
      fillPaint,
    );

    // Label
    final symPainter = TextPainter(
      text: TextSpan(
        text: 'Symmetry',
        style: TextStyle(
          color: Colors.black.withOpacity(0.5 * opacity),
          fontSize: 11,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    symPainter.layout();
    symPainter.paint(canvas, Offset((size.width - symPainter.width) / 2, barY + barHeight + 4));
  }

  void _drawProgressRing(Canvas canvas, Offset center, double radius, double opacity) {
    final bgRing = Paint()
      ..color = Colors.black.withOpacity(0.08 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(center, radius, bgRing);

    final progressRing = Paint()
      ..color = Colors.teal.withOpacity(0.8 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * scanProgress,
      false,
      progressRing,
    );
  }

  @override
  bool shouldRepaint(covariant EyeAlignmentPainter oldDelegate) {
    return oldDelegate.leftRatio != leftRatio ||
        oldDelegate.rightRatio != rightRatio ||
        oldDelegate.leftDeviation != leftDeviation ||
        oldDelegate.rightDeviation != rightDeviation ||
        oldDelegate.isHeadCorrect != isHeadCorrect ||
        oldDelegate.scanProgress != scanProgress ||
        oldDelegate.animationValue != animationValue;
  }
}
