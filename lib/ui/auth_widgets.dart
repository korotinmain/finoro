import 'dart:ui';
import 'package:flutter/material.dart';

/// Common gradient background used on auth screens.
class AuthGradientBackground extends StatelessWidget {
  const AuthGradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D0F19), Color(0xFF0B0E15), Color(0xFF0A0B12)],
        ),
      ),
    );
  }
}

/// Decorative glow blob.
class GlowBlob extends StatelessWidget {
  const GlowBlob({
    super.key,
    required this.size,
    required this.color1,
    required this.color2,
    this.left,
    this.top,
    this.right,
    this.bottom,
  });
  final double size;
  final Color color1;
  final Color color2;
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
            colors: [
              color1.withValues(alpha: 0.55),
              color2.withValues(alpha: 0.35),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color1.withValues(alpha: 0.35),
              blurRadius: 80,
              spreadRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}

/// Faint currency watermark icons.
class CurrencyWatermark extends StatelessWidget {
  const CurrencyWatermark({super.key});

  @override
  Widget build(BuildContext context) {
    final faint = Colors.white.withValues(alpha: 0.05);
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              left: 24,
              bottom: 80,
              child: Icon(Icons.euro_rounded, size: 54, color: faint),
            ),
            Positioned(
              right: 32,
              top: 120,
              child: Icon(Icons.attach_money_rounded, size: 68, color: faint),
            ),
            Positioned(
              right: 90,
              bottom: 140,
              child: Icon(
                Icons.currency_exchange_rounded,
                size: 46,
                color: faint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gradient pie logo used across auth screens.
class PieLogo extends StatelessWidget {
  const PieLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF6D4AFF), Color(0xFF3EA7FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D4AFF).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.pie_chart_rounded, color: Colors.white),
    );
  }
}

/// Frosted glass card container used to wrap forms.
class AuthGlassCard extends StatelessWidget {
  const AuthGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 28, 24, 24),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Primary gradient button used for auth actions.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 56,
    this.borderRadius = 18,
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final double height;
  final double borderRadius;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6D4AFF), Color(0xFF3EA7FF)],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3EA7FF).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            foregroundColor: Colors.white,
          ),
          onPressed: loading ? null : onPressed,
          child:
              loading
                  ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                  : child,
        ),
      ),
    );
  }
}

/// Reusable gradient filled pill button (general purpose, wider styling control).
class GradientPillButton extends StatelessWidget {
  const GradientPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 56,
    this.gradient = const LinearGradient(
      colors: [Color(0xFF6D4AFF), Color(0xFF3EA7FF)],
    ),
    this.borderRadius = 24,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final LinearGradient gradient;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            height: height,
            alignment: Alignment.center,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: .2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outline ghost pill button.
class GhostPillButton extends StatelessWidget {
  const GhostPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 52,
    this.borderRadius = 24,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.white.withValues(alpha: .22)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            height: height,
            alignment: Alignment.center,
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                letterSpacing: .2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
