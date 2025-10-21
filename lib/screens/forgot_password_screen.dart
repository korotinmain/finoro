import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../router.dart';
import '../ui/auth_widgets.dart';
import '../core/utils/haptic_feedback.dart';
import '../core/validators/form_validators.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _auth = AuthService();

  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      await HapticFeedbackHelper.error();
      return;
    }

    await HapticFeedbackHelper.mediumImpact();
    setState(() => _loading = true);

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      await _auth.sendPasswordReset(context, _emailCtrl.text);
      if (!mounted) return;

      await HapticFeedbackHelper.success();

      final t = AppLocalizations.of(context)!;
      messenger.showSnackBar(
        SnackBar(
          content: Text(t.passwordResetEmailSent),
          backgroundColor: Colors.green.shade900,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      router.go(Routes.login);
    } on AuthException catch (e) {
      if (!mounted) return;
      await HapticFeedbackHelper.error();
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red.shade900,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      await HapticFeedbackHelper.error();
      final t = AppLocalizations.of(context)!;
      messenger.showSnackBar(
        SnackBar(
          content: Text(t.errUnexpected),
          backgroundColor: Colors.red.shade900,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color(0xFF5B7CFF);
    const brandPurple = Color(0xFF6C4DFF);

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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _LogoGlow(),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.forgotPassword,
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: .2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.forgotPasswordDescription,
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: .7),
                            ),
                          ),
                          const SizedBox(height: 24),

                          _Field(
                            controller: _emailCtrl,
                            enabled: !_loading,
                            label: AppLocalizations.of(context)!.email,
                            hint: 'your@email.com',
                            keyboardType: TextInputType.emailAddress,
                            validator:
                                (v) => FormValidators.validateEmail(
                                  v,
                                  AppLocalizations.of(context)!,
                                ),
                            prefix: const Icon(Icons.mail_outlined),
                            onSubmitted: _submit,
                          ),
                          const SizedBox(height: 20),

                          GradientPillButton(
                            label: AppLocalizations.of(context)!.sendResetLink,
                            onPressed: _loading ? null : _submit,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [brandPurple, brandBlue],
                            ),
                          ),
                          const SizedBox(height: 12),

                          Builder(
                            builder: (context) {
                              final t = AppLocalizations.of(context)!;
                              return TextButton(
                                onPressed:
                                    _loading
                                        ? null
                                        : () async {
                                          await HapticFeedbackHelper.lightImpact();
                                          if (context.mounted)
                                            context.go(Routes.login);
                                        },
                                child: Text(t.backToSignIn),
                              );
                            },
                          ),
                        ],
                      ),
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

// ---- Reused look (local copies). If you’ve centralized them, import instead. ----
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

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final Widget? prefix;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onSubmitted;
  final bool enabled;

  const _Field({
    required this.controller,
    required this.label,
    this.hint,
    this.prefix,
    this.keyboardType,
    this.validator,
    this.onSubmitted,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide.none,
    );

    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      onFieldSubmitted: (_) => onSubmitted?.call(),
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
            prefix == null
                ? null
                : Padding(
                  padding: const EdgeInsetsDirectional.only(start: 14, end: 10),
                  child: IconTheme(
                    data: IconThemeData(
                      color: theme.colorScheme.onSurface.withValues(alpha: .75),
                      size: 22,
                    ),
                    child: prefix!,
                  ),
                ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: const Color(0xFF1F2126).withValues(alpha: .85),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }
}

// Removed unused legacy _GradientButton in favor of shared GradientPillButton.
