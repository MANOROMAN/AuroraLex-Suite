import 'dart:math';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class AuroraBackground extends StatelessWidget {
  const AuroraBackground({super.key, this.child, this.padding});

  final Widget? child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AuroraGlowPainter(),
      child: Container(
        decoration: const BoxDecoration(gradient: AuroraColors.primaryGradient),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Color(0x66000000)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}

class _AuroraGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AuroraColors.magenta.withOpacity(0.35),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.2, size.height * 0.2),
              radius: max(size.width, size.height) * 0.6,
            ),
          );
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
