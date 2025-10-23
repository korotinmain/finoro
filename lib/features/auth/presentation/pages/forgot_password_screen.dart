import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker/core/constants/app_colors.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';
import 'package:money_tracker/core/routing/app_routes.dart';
import 'package:money_tracker/core/utils/haptic_feedback.dart';
import 'package:money_tracker/core/validators/form_validators.dart';
import 'package:money_tracker/services/auth_service.dart';
import 'package:money_tracker/ui/auth_widgets.dart' hide GlowBlob;
import 'package:money_tracker/ui/widgets/glow_blob.dart';

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
    if (!mounted) return;
    setState(() => _loading = true);

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      await _auth.sendPasswordReset(context, _emailCtrl.text);
      if (!mounted) return;

      await HapticFeedbackHelper.success();
      if (!mounted) return;

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
      router.go(AppRoutes.login);
    } on AuthException catch (e) {
      await HapticFeedbackHelper.error();
      if (!mounted) return;
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
      await HapticFeedbackHelper.error();
      if (!mounted) return;
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
                              colors: [
                                AppColors.vibrantPurple,
                                AppColors.primaryPurple,
                              ],
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
                                          if (!context.mounted) return;
                                          context.go(AppRoutes.login);
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
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
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
                  padding: const EdgeInsetsDirectional.only(
                    start: AppSizes.spacing14,
                    end: AppSizes.spacing10,
                  ),
                  child: IconTheme(
                    data: IconThemeData(
                      color: theme.colorScheme.onSurface.withValues(alpha: .75),
                      size: AppSizes.iconMedium,
                    ),
                    child: prefix!,
                  ),
                ),
        prefixIconConstraints: const BoxConstraints(),
        filled: true,
        fillColor: AppColors.glassBackground.withValues(alpha: .85),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacing18,
          vertical: AppSizes.spacing18,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }
}

// Removed unused legacy _GradientButton in favor of shared GradientPillButton.
