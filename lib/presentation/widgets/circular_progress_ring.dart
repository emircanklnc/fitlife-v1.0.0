import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CircularProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final Widget? child;

  const CircularProgressRing({
    Key? key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 12,
    this.progressColor,
    this.backgroundColor,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CircularProgressPainter(
          progress: progress.clamp(0.0, 1.0),
          strokeWidth: strokeWidth,
          progressColor: progressColor ?? AppColors.primary,
          backgroundColor: backgroundColor ?? AppColors.grey200,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Simple progress ring with text inside
class ProgressRingWithText extends StatelessWidget {
  final double progress;
  final String text;
  final String? subtitle;
  final double size;
  final Color? color;

  const ProgressRingWithText({
    Key? key,
    required this.progress,
    required this.text,
    this.subtitle,
    this.size = 120,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircularProgressRing(
      progress: progress,
      size: size,
      progressColor: color,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: AppTextStyles.h2,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTextStyles.caption,
            ),
          ],
        ],
      ),
    );
  }
}

