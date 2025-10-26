import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';
import 'package:money_tracker/core/errors/auth_exception.dart';
import 'package:money_tracker/core/routing/app_routes.dart';
import 'package:money_tracker/core/utils/haptic_feedback.dart';
import 'package:money_tracker/features/auth/domain/entities/auth_user.dart';
import 'package:money_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:money_tracker/features/auth/presentation/utils/auth_exception_localization.dart';
import 'package:money_tracker/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:money_tracker/ui/auth_widgets.dart' show PieLogo;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _signingInWithGoogle = false;
  bool _signingInWithApple = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleSignIn({
    required Future<AuthUser?> Function() action,
    required VoidCallback onStart,
    required VoidCallback onComplete,
  }) async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    onStart();
    try {
      final user = await action();
      if (!mounted) return;

      if (user == null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(t.signInCancelledMessage),
            backgroundColor: Colors.red.shade900,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      final ensureWorkspace = ref.read(ensureWorkspaceInitializedProvider);
      final result = await ensureWorkspace(user.uid);

      await HapticFeedbackHelper.success();
      if (!mounted) return;

      if (result.requiresSetup) {
        GoRouter.of(
          context,
        ).go(AppRoutes.workspaceSetup, extra: result.workspaceId);
      } else {
        GoRouter.of(context).go(AppRoutes.dashboard);
      }
    } on AuthException catch (e) {
      await HapticFeedbackHelper.error();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.localizedMessage(t)),
          backgroundColor: Colors.red.shade900,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (_) {
      await HapticFeedbackHelper.error();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(t.signInGenericError),
          backgroundColor: Colors.red.shade900,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      onComplete();
    }
  }

  Future<void> _signInWithGoogle() async {
    await _handleSignIn(
      action: () => ref.read(signInWithGoogleProvider)(),
      onStart: () => setState(() => _signingInWithGoogle = true),
      onComplete: () => setState(() => _signingInWithGoogle = false),
    );
  }

  Future<void> _signInWithApple() async {
    await _handleSignIn(
      action: () => ref.read(signInWithAppleProvider)(),
      onStart: () => setState(() => _signingInWithApple = true),
      onComplete: () => setState(() => _signingInWithApple = false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final primaryButtons = <Widget>[
      SocialSignInButton(
        label: t.signInWithGoogle,
        icon: Icons.g_translate,
        iconWidget: const _GoogleGlyph(),
        backgroundColorOverride: const Color(0xFF1C2135),
        foregroundColorOverride: const Color(0xFFE6EDFF),
        borderColorOverride: const Color(0xFF27304A),
        onPressed: _signingInWithGoogle ? null : _signInWithGoogle,
        isLoading: _signingInWithGoogle,
      ),
    ];

    if (Platform.isIOS || Platform.isMacOS) {
      primaryButtons.addAll([
        const SizedBox(height: AppSizes.spacing16),
        SocialSignInButton(
          label: t.signInWithApple,
          icon: Icons.apple,
          darkBackground: true,
          backgroundColorOverride: const Color(0xFF101827),
          foregroundColorOverride: Colors.white,
          borderColorOverride: const Color(0xFF1F2937),
          onPressed: _signingInWithApple ? null : _signInWithApple,
          isLoading: _signingInWithApple,
        ),
      ]);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF070D1A),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth > 720 ? 72.0 : 24.0;
          final cardMaxWidth =
              constraints.maxWidth > 720 ? 460.0 : double.infinity;

          return Stack(
            children: [
              const _SoftBackground(),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: AppSizes.spacing32,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: cardMaxWidth),
                      child: _LoginCard(
                        title: t.loginHeroTitle,
                        subtitle: t.loginHeroSubtitle,
                        children: [
                          ...primaryButtons,
                          const SizedBox(height: AppSizes.spacing24),
                          Text(
                            t.socialSignInDisclaimer,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFC0C9E5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SoftBackground extends StatelessWidget {
  const _SoftBackground();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF091324), Color(0xFF0B162B), Color(0xFF060B16)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -140,
              left: -80,
              child: _BlurCircle(diameter: 320, baseColor: Color(0xFF3B5BCD)),
            ),
            Positioned(
              bottom: -160,
              right: -60,
              child: _BlurCircle(diameter: 300, baseColor: Color(0xFF7C4DFF)),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({required this.diameter, required this.baseColor});

  final double diameter;
  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            baseColor.withValues(alpha: 0.28),
            baseColor.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.18),
            blurRadius: 90,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing28,
        vertical: AppSizes.spacing32,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1B33),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF1E2A47)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF030712).withValues(alpha: 0.55),
            blurRadius: 60,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: PieLogo()),
          const SizedBox(height: AppSizes.spacing20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: const Color(0xFFF1F5FF),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSizes.spacing12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF9CA9C9),
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSizes.spacing28),
          ...children,
        ],
      ),
    );
  }
}

class SocialSignInButton extends StatelessWidget {
  const SocialSignInButton({
    required this.label,
    required this.icon,
    this.iconWidget,
    this.darkBackground = false,
    this.backgroundColorOverride,
    this.foregroundColorOverride,
    this.borderColorOverride,
    this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final IconData icon;
  final Widget? iconWidget;
  final bool darkBackground;
  final Color? backgroundColorOverride;
  final Color? foregroundColorOverride;
  final Color? borderColorOverride;
  final Future<void> Function()? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        backgroundColorOverride ??
        (darkBackground ? const Color(0xFF1F1F1F) : Colors.white);
    final foregroundColor =
        foregroundColorOverride ??
        (darkBackground ? Colors.white : const Color(0xFF1F2A44));
    final borderColor =
        borderColorOverride ??
        (darkBackground ? Colors.transparent : const Color(0xFFD9E1F4));
    final overlayColor =
        darkBackground
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFF62719A).withValues(alpha: 0.12);
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: foregroundColor,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
    );

    return SizedBox(
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
            side: BorderSide(
              color: borderColor,
              width: darkBackground ? 0 : 1.2,
            ),
          ),
        ).copyWith(overlayColor: WidgetStatePropertyAll(overlayColor)),
        onPressed:
            onPressed == null
                ? null
                : () async {
                  await onPressed!.call();
                },
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                  ),
                )
              else ...[
                iconWidget ?? Icon(icon, color: foregroundColor, size: 22),
                const SizedBox(width: AppSizes.spacing10),
                Text(label, style: textStyle),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: Colors.white,
      height: 1.0,
    );

    return SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: Text(
          'G',
          style:
              textStyle ??
              const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: Colors.white,
                height: 1.0,
              ),
        ),
      ),
    );
  }
}
