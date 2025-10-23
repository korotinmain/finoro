import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker/core/routing/app_routes.dart';
import 'package:money_tracker/core/utils/haptic_feedback.dart';
import 'package:money_tracker/core/validators/form_validators.dart';
import 'package:money_tracker/services/auth_service.dart';
import 'package:money_tracker/ui/auth_widgets.dart' hide GlowBlob;
import 'package:money_tracker/ui/password_strength_bar.dart';
import 'package:money_tracker/ui/widgets/glow_blob.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _name = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;
  final _auth = AuthService();
  double _strength = 0; // 0..1

  void _updateStrength(String value) {
    // Simple heuristic: length + variety
    int score = 0;
    if (value.length >= 6) score++;
    if (value.length >= 10) score++;
    if (RegExp(r'[A-Z]').hasMatch(value)) score++;
    if (RegExp(r'[0-9]').hasMatch(value)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score++;
    _strength = (score / 5).clamp(0, 1);
    setState(() {});
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    final t = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      await HapticFeedbackHelper.error();
      return;
    }

    await HapticFeedbackHelper.mediumImpact();
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      final messenger = ScaffoldMessenger.of(context);
      final router = GoRouter.of(context);
      final user = await _auth.signUp(context, _email.text.trim(), _pass.text);
      if (!mounted) return;

      // Update display name if provided
      final nameTrimmed = _name.text.trim();
      if (nameTrimmed.isNotEmpty) {
        await user?.updateDisplayName(nameTrimmed);
      }

      // Send verification email; then go to confirmation screen.
      await user?.sendEmailVerification();
      await HapticFeedbackHelper.success();

      messenger.showSnackBar(
        SnackBar(
          content: Text(t.accountCreated),
          backgroundColor: Colors.green.shade900,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      router.go(AppRoutes.confirmEmail);
    } on AuthException catch (e) {
      await HapticFeedbackHelper.error();
      final messenger = ScaffoldMessenger.of(context);
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
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            const AuthGradientBackground(),
            GlowBlob.purpleBlue(left: -80, top: -60),
            GlowBlob.purpleCyan(
              right: -70,
              bottom: -70,
            ),
            const CurrencyWatermark(),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(24, 0, 24, bottomInset + 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: AuthGlassCard(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const PieLogo(),
                                  const SizedBox(height: 12),
                                  Text(
                                    t.createAccount,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    t.startYourJourney,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.75,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  TextFormField(
                                    controller: _name,
                                    enabled: !_loading,
                                    textInputAction: TextInputAction.next,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    autofillHints: const [AutofillHints.name],
                                    decoration: InputDecoration(
                                      labelText: t.name,
                                      hintText: 'Your name',
                                      prefixIcon: const Icon(
                                        Icons.person_rounded,
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return t.enterName;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _email,
                                    enabled: !_loading,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [AutofillHints.email],
                                    decoration: InputDecoration(
                                      labelText: t.email,
                                      hintText: 'your@email.com',
                                      prefixIcon: const Icon(
                                        Icons.mail_rounded,
                                      ),
                                    ),
                                    validator:
                                        (v) =>
                                            FormValidators.validateEmail(v, t),
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _pass,
                                    enabled: !_loading,
                                    obscureText: _obscure1,
                                    textInputAction: TextInputAction.next,
                                    onChanged: _updateStrength,
                                    autofillHints: const [
                                      AutofillHints.newPassword,
                                    ],
                                    decoration: InputDecoration(
                                      labelText: t.password,
                                      hintText: 'Create a strong password',
                                      prefixIcon: const Icon(
                                        Icons.lock_rounded,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () async {
                                          await HapticFeedbackHelper.lightImpact();
                                          setState(
                                            () => _obscure1 = !_obscure1,
                                          );
                                        },
                                        icon: Icon(
                                          _obscure1
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                        ),
                                      ),
                                    ),
                                    validator:
                                        (v) => FormValidators.validatePassword(
                                          v,
                                          t,
                                        ),
                                  ),
                                  if (_strength >= 0.2) ...[
                                    const SizedBox(height: 6),
                                    PasswordStrengthBar(strength: _strength),
                                  ],
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _confirm,
                                    enabled: !_loading,
                                    obscureText: _obscure2,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _onSignUp(),
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    decoration: InputDecoration(
                                      labelText: t.confirmPassword,
                                      hintText: 'Confirm your password',
                                      prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () async {
                                          await HapticFeedbackHelper.lightImpact();
                                          setState(
                                            () => _obscure2 = !_obscure2,
                                          );
                                        },
                                        icon: Icon(
                                          _obscure2
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                        ),
                                      ),
                                    ),
                                    validator:
                                        (v) =>
                                            FormValidators.validatePasswordConfirmation(
                                              v,
                                              _pass.text,
                                              t,
                                            ),
                                  ),
                                  const SizedBox(height: 20),
                                  AuthPrimaryButton(
                                    onPressed: _onSignUp,
                                    loading: _loading,
                                    child: Text(
                                      t.signUp,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed:
                                        _loading
                                            ? null
                                            : () async {
                                              await HapticFeedbackHelper.lightImpact();
                                              if (mounted) {
                                                GoRouter.of(context).pop();
                                              }
                                            },
                                    child: Text(t.backToLogin),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
