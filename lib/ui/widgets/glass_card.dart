import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:money_tracker/core/constants/app_colors.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';

/// Reusable glass-morphism card with blur effect
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        borderRadius ?? AppSizes.radiusXXLarge,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding:
              padding ??
              const EdgeInsets.fromLTRB(
                AppSizes.cardPaddingH,
                AppSizes.cardPaddingV,
                AppSizes.cardPaddingH,
                AppSizes.cardPaddingV,
              ),
          decoration: BoxDecoration(
            color:
                backgroundColor ??
                AppColors.cardBackground.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppSizes.radiusXXLarge,
            ),
            border: Border.all(color: borderColor ?? AppColors.white(0.06)),
          ),
          child: child,
        ),
      ),
    );
  }
}
