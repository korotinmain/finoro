import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker/core/constants/app_colors.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';
import 'package:money_tracker/core/errors/auth_exception.dart';
import 'package:money_tracker/core/routing/app_routes.dart';
import 'package:money_tracker/core/utils/haptic_feedback.dart';
import 'package:money_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:money_tracker/features/auth/presentation/utils/auth_exception_localization.dart';
import 'package:money_tracker/ui/auth_widgets.dart' hide GlowBlob;
import 'package:money_tracker/ui/widgets/glow_blob.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailConfirmationScreen extends ConsumerStatefulWidget {
  const EmailConfirmationScreen({super.key, this.email});

  /// If not provided, we'll read the currently authenticated user's email.
  final String? email;

  @override
  ConsumerState<EmailConfirmationScreen> createState() =>
      _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState
    extends ConsumerState<EmailConfirmationScreen> {
  bool _sending = false;
  int _cooldown = 0;
  Timer? _t;
  String get _fallbackEmail => widget.email ?? 'your@email.com';

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  void _startCooldown([int seconds = 60]) {
    setState(() => _cooldown = seconds);
    _t?.cancel();
    _t = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_cooldown <= 1) {
        timer.cancel();
        setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown--);
      }
    });
  }

  Future<void> _openMail() async {
    await HapticFeedbackHelper.lightImpact();

    if (!mounted) return;
    final uri = Uri(scheme: 'mailto');
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (await canLaunchUrl(uri)) {
        await HapticFeedbackHelper.success();
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        await HapticFeedbackHelper.error();
        messenger.showSnackBar(
          SnackBar(
            content: const Text('No mail apps installed on this device'),
            backgroundColor: Colors.red.shade900,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      await HapticFeedbackHelper.error();
      messenger.showSnackBar(
        SnackBar(
          content: const Text('No mail apps installed on this device'),
          backgroundColor: Colors.red.shade900,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _resend() async {
    if (_cooldown > 0 || _sending) return;

    await HapticFeedbackHelper.mediumImpact();
    if (!mounted) return;
    setState(() => _sending = true);

    final messenger = ScaffoldMessenger.of(context);

    try {
      final sendVerification = ref.read(sendEmailVerificationProvider);
      await sendVerification();
      if (!mounted) return;

      await HapticFeedbackHelper.success();
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      final email =
          widget.email ??
          ref.read(currentAuthUserProvider)?.email ??
          _fallbackEmail;
      messenger.showSnackBar(
        SnackBar(
          content: Text(t.verificationEmailSent(email)),
          backgroundColor: Colors.green.shade900,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      _startCooldown();
    } on AuthException catch (e) {
      await HapticFeedbackHelper.error();
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
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
      final t = AppLocalizations.of(context)!;
      messenger.showSnackBar(
        SnackBar(
          content: Text(t.couldNotSendEmail),
          backgroundColor: Colors.red.shade900,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _continueIfVerified() async {
    await HapticFeedbackHelper.mediumImpact();

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      final reload = ref.read(reloadCurrentUserProvider);
      final user = await reload();
      final verified = user?.isEmailVerified ?? false;
      if (!mounted) return;

      if (verified) {
        await HapticFeedbackHelper.success();
        if (!mounted) return;
        router.go(AppRoutes.dashboard);
      } else {
        await HapticFeedbackHelper.error();
        if (!mounted) return;
        final t = AppLocalizations.of(context)!;
        messenger.showSnackBar(
          SnackBar(
            content: Text(t.emailNotVerifiedYet),
            backgroundColor: Colors.orange.shade900,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } on AuthException catch (e) {
      await HapticFeedbackHelper.error();
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          const _BackgroundBlobs(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _LogoGlow(),
                        const SizedBox(height: 16),
                        Text(
                          t.appTitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: .2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t.pleaseCheckInbox,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: .85,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.email ??
                              ref.watch(currentAuthUserProvider)?.email ??
                              _fallbackEmail,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          t.verificationEmailDescription,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: .7,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Open Mail
                        GradientPillButton(
                          label: t.openMail,
                          onPressed: _openMail,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.vibrantPurple,
                              AppColors.primaryPurple,
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // I've verified — Continue
                        GhostPillButton(
                          label: t.iveVerifiedContinue,
                          onPressed: _continueIfVerified,
                        ),

                        const SizedBox(height: 8),

                        // Go to Login (sign out then navigate)
                        Builder(
                          builder: (context) {
                            final t = AppLocalizations.of(context)!;
                            return TextButton(
                              onPressed: () async {
                                await HapticFeedbackHelper.lightImpact();
                                if (!context.mounted) return;
                                final router = GoRouter.of(context);
                                final signOut = ref.read(signOutProvider);
                                await signOut();
                                if (!context.mounted) return;
                                router.go(AppRoutes.login);
                              },
                              child: Text(t.backToSignIn),
                            );
                          },
                        ),

                        const SizedBox(height: 4),

                        // Resend
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed:
                                  (_cooldown > 0 || _sending) ? null : _resend,
                              child:
                                  _sending
                                      ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(
                                            theme.colorScheme.primary,
                                          ),
                                        ),
                                      )
                                      : Text(
                                        _cooldown > 0
                                            ? t.resendInSeconds(_cooldown)
                                            : t.resendVerification,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme.colorScheme.primary
                                                  .withValues(alpha: .95),
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                            ),
                          ],
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

/// === Shared visual pieces (local copies to keep this file drop-in) ===

class _BackgroundBlobs extends StatelessWidget {
  const _BackgroundBlobs();
  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surface;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [base, base.withValues(alpha: .95)],
        ),
      ),
      child: Stack(
        children: [
          GlowBlob.purpleBlue(size: AppSizes.blobMedium, left: -100, top: -80),
          GlowBlob.purpleCyan(
            size: AppSizes.blobSmall,
            right: -80,
            bottom: -60,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.4),
                  radius: 1.2,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: .35),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spacing24,
        AppSizes.spacing28,
        AppSizes.spacing24,
        AppSizes.spacing24,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(AppSizes.radiusXXLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .45),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: .04),
            blurRadius: 12,
            spreadRadius: -6,
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
      ),
      child: child,
    );
  }
}

class _LogoGlow extends StatelessWidget {
  const _LogoGlow();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: AppSizes.iconXLarge,
          height: AppSizes.iconXLarge,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryPurple,
          ),
          child: const Center(
            child: Icon(Icons.pie_chart_rounded, color: Colors.white),
          ),
        ),
        const SizedBox(height: AppSizes.spacing4),
        Container(
          width: 60,
          height: 8,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withValues(alpha: .55),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// (Local private button widgets replaced by shared GradientPillButton & GhostPillButton.)
