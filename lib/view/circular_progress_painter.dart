import 'package:flutter/material.dart';
import 'dart:math';

// Custom painter for drawing circular progress indicator
class CircularProgressPainter extends CustomPainter {
  final double progress;      // Progress value (0.0 to 1.0)
  final Color backgroundColor; // Background circle color
  final Color progressColor;  // Progress arc color
  final double strokeWidth;   // Width of the circle stroke

  CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final startAngle = -pi / 2; // Start from top (12 o'clock)
    final sweepAngle = 2 * pi * progress; // Calculate arc length

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false, // Don't fill the arc
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}