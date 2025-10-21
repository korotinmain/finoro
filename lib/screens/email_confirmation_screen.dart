// lib/screens/email_confirmation_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../router.dart';
import '../ui/auth_widgets.dart';

class EmailConfirmationScreen extends StatefulWidget {
  const EmailConfirmationScreen({super.key, this.email});

  /// If not provided, we'll read FirebaseAuth.currentUser?.email
  final String? email;

  @override
  State<EmailConfirmationScreen> createState() =>
      _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState extends State<EmailConfirmationScreen> {
  final _auth = FirebaseAuth.instance;

  bool _sending = false;
  int _cooldown = 0;
  Timer? _t;

  String get _email =>
      widget.email ?? (_auth.currentUser?.email ?? 'your@email.com');

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
    // Attempt to open a generic mail compose window using a mailto: link.
    final uri = Uri(scheme: 'mailto');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No mail apps installed on this device'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No mail apps installed on this device')),
      );
    }
  }

  Future<void> _resend() async {
    if (_cooldown > 0 || _sending) return;

    setState(() => _sending = true);
    try {
      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No signed-in user.')));
        return;
      }

      // You can pass ActionCodeSettings if you want a custom continueUrl.
      await user.sendEmailVerification();
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.verificationEmailSent(_email))));
      _startCooldown(60);
    } catch (_) {
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.couldNotSendEmail)));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _continueIfVerified() async {
    try {
      await _auth.currentUser?.reload();
      final verified = _auth.currentUser?.emailVerified ?? false;
      if (!mounted) return;
      if (verified) {
        context.go(Routes.dashboard);
      } else {
        final t = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.emailNotVerifiedYet)));
      }
    } catch (_) {
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.couldNotRefreshStatus)));
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color(0xFF5B7CFF);
    const brandPurple = Color(0xFF6C4DFF);
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
                          _email,
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
                            colors: [brandPurple, brandBlue],
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
                                final router = GoRouter.of(context);
                                await FirebaseAuth.instance.signOut();
                                if (!mounted) return;
                                router.go(Routes.login);
                              },
                              child: Text(t.backToSignIn),
                            );
                          },
                        ),

                        const SizedBox(height: 4),

                        // Resend & change email
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed:
                                  (_cooldown > 0 || _sending) ? null : _resend,
                              child: Text(
                                _cooldown > 0
                                    ? t.resendInSeconds(_cooldown)
                                    : t.resendVerification,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: .95,
                                  ),
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
          Positioned(
            left: -100,
            top: -80,
            child: _blob(const Color(0xFF2D2A48), const Size(260, 260)),
          ),
          Positioned(
            right: -80,
            bottom: -60,
            child: _blob(const Color(0xFF2B3C75), const Size(240, 240)),
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

  Widget _blob(Color color, Size size) => Container(
    width: size.width,
    height: size.height,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [
          color.withValues(alpha: .95),
          color.withValues(alpha: .6),
          color.withValues(alpha: .0),
        ],
      ),
    ),
  );
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});
  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF141519);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(28),
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
    const logoColor = Color(0xFF6C7BFF);
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: logoColor,
          ),
          child: const Center(
            child: Icon(Icons.pie_chart_rounded, color: Colors.white),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: 8,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: logoColor.withValues(alpha: .55),
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
