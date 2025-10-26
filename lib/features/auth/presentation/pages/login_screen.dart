import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';
import 'package:money_tracker/core/errors/auth_exception.dart';
import 'package:money_tracker/core/routing/app_routes.dart';
import 'package:money_tracker/core/services/app_launch_service.dart';
import 'package:money_tracker/core/utils/haptic_feedback.dart';
import 'package:money_tracker/features/auth/domain/entities/auth_user.dart';
import 'package:money_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:money_tracker/features/auth/presentation/utils/auth_exception_localization.dart';
import 'package:money_tracker/ui/auth_widgets.dart' hide GlowBlob;
import 'package:money_tracker/ui/widgets/glow_blob.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isFirstLaunch = false;
  bool _signingInWithGoogle = false;
  bool _signingInWithApple = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final firstLaunch = await AppLaunchService.isFirstLaunch();
    if (mounted) {
      setState(() => _isFirstLaunch = firstLaunch);
    }
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

      await HapticFeedbackHelper.success();
      if (!mounted) return;
      GoRouter.of(context).go(AppRoutes.dashboard);
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

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const AuthGradientBackground(),
          GlowBlob.purpleBlue(left: -80, top: -60),
          GlowBlob.purpleCyan(right: -70, bottom: -70),
          const CurrencyWatermark(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: AuthGlassCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const PieLogo(),
                        const SizedBox(height: 16),
                        Text(
                          t.appTitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isFirstLaunch ? t.socialWelcomeHeadline : t.socialWelcomeBackHeadline,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SocialSignInButton(
                          label: t.signInWithGoogle,
                          icon: Icons.g_translate,
                          onPressed: _signingInWithGoogle ? null : _signInWithGoogle,
                          isLoading: _signingInWithGoogle,
                        ),
                        if (Platform.isIOS) ...[
                          const SizedBox(height: 16),
                          SocialSignInButton(
                            label: t.signInWithApple,
                            icon: Icons.apple,
                            darkBackground: true,
                            onPressed: _signingInWithApple ? null : _signInWithApple,
                            isLoading: _signingInWithApple,
                          ),
                        ],
                        const SizedBox(height: 24),
                        Text(
                          t.socialSignInDisclaimer,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SocialSignInButton extends StatelessWidget {
  const SocialSignInButton({
    required this.label,
    required this.icon,
    this.darkBackground = false,
    this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool darkBackground;
  final Future<void> Function()? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = darkBackground ? Colors.black : Colors.white;
    final foregroundColor = darkBackground ? Colors.white : Colors.black87;

    return SizedBox(
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          ),
        ),
        onPressed: onPressed == null
            ? null
            : () async {
                await onPressed!.call();
              },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
              Icon(icon, color: foregroundColor),
              const SizedBox(width: AppSizes.spacing10),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
