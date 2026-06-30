import 'package:flutter/material.dart';
import 'dart:ui';
import '../utils/app_theme.dart';

class GlassBackground extends StatelessWidget {
  final Widget child;
  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Stack(
        children: [
          // Orb 1 - top left
          Positioned(
            top: -80,
            left: -60,
            child: _glowOrb(280, AppTheme.primary.withValues(alpha: 0.35)),
          ),
          // Orb 2 - middle right
          Positioned(
            top: 280,
            right: -100,
            child: _glowOrb(260, AppTheme.secondary.withValues(alpha: 0.25)),
          ),
          // Orb 3 - bottom left
          Positioned(
            bottom: -100,
            left: -80,
            child: _glowOrb(300, AppTheme.primary.withValues(alpha: 0.2)),
          ),
          // Content
          child,
        ],
      ),
    );
  }

  Widget _glowOrb(double size, Color color) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color,
                color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}