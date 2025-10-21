import 'package:flutter/material.dart';
import 'package:money_tracker/core/constants/app_colors.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';

/// Reusable decorative glow blob for backgrounds
class GlowBlob extends StatelessWidget {
  const GlowBlob({
    super.key,
    required this.size,
    required this.colors,
    this.opacity = 0.3,
    this.left,
    this.top,
    this.right,
    this.bottom,
  });

  final double size;
  final List<Color> colors;
  final double opacity;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: colors
                .map((c) => c.withValues(alpha: opacity))
                .toList(growable: false),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: opacity * 0.6),
              blurRadius: 80,
              spreadRadius: 10,
            ),
          ],
        ),
      ),
    );
  }

  /// Preset purple-blue glow blob
  factory GlowBlob.purpleBlue({
    double size = AppSizes.blobSmall,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return GlowBlob(
      size: size,
      colors: const [AppColors.primaryPurple, AppColors.lightBlue],
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }

  /// Preset light purple-cyan glow blob
  factory GlowBlob.purpleCyan({
    double size = AppSizes.blobMedium,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return GlowBlob(
      size: size,
      colors: const [AppColors.lightPurple, AppColors.cyan],
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }
}
