import 'package:benjii/util/app_color.dart';
import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColor.blush, AppColor.background, Color(0xFFEAF5FF)],
          stops: [0, 0.56, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [const _BackgroundRibbons(), child],
      ),
    );
  }
}

class _BackgroundRibbons extends StatelessWidget {
  const _BackgroundRibbons();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -92,
            right: -112,
            child: Transform.rotate(
              angle: -0.36,
              child: const _Ribbon(
                width: 340,
                height: 150,
                color: AppColor.lilac,
                opacity: 0.72,
              ),
            ),
          ),
          Positioned(
            left: -132,
            bottom: 88,
            child: Transform.rotate(
              angle: -0.28,
              child: const _Ribbon(
                width: 360,
                height: 118,
                color: AppColor.blush,
                opacity: 0.86,
              ),
            ),
          ),
          Positioned(
            right: -120,
            bottom: -48,
            child: Transform.rotate(
              angle: 0.24,
              child: const _Ribbon(
                width: 300,
                height: 88,
                color: Color(0xFFDDF1FF),
                opacity: 0.68,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Ribbon extends StatelessWidget {
  const _Ribbon({
    required this.width,
    required this.height,
    required this.color,
    required this.opacity,
  });

  final double width;
  final double height;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(28),
      ),
      child: SizedBox(width: width, height: height),
    );
  }
}
