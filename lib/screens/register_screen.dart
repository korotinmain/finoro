// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker/services/auth_service.dart';
import 'package:money_tracker/ui/auth_widgets.dart';
import 'package:money_tracker/router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class PasswordStrengthBar extends StatelessWidget {
  const PasswordStrengthBar({super.key, required this.strength});
  final double strength; // 0..1

  Color _color(BuildContext context) {
    if (strength < 0.2) return Colors.redAccent;
    if (strength < 0.4) return Colors.deepOrangeAccent;
    if (strength < 0.6) return Colors.amberAccent.shade700;
    if (strength < 0.8) return Colors.lightGreenAccent.shade700;
    if (strength < 1.0) return Colors.greenAccent.shade400;
    return Colors.greenAccent.shade400; // very strong
  }

  String _label(AppLocalizations t) {
    if (strength < 0.2) return t.passwordStrengthVeryWeak;
    if (strength < 0.4) return t.passwordStrengthWeak;
    if (strength < 0.6) return t.passwordStrengthFair;
    if (strength < 0.8) return t.passwordStrengthMedium;
    if (strength < 1.0) return t.passwordStrengthStrong;
    return t.passwordStrengthVeryStrong;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final color = _color(context);
    return AnimatedOpacity(
      opacity: strength < 0.2 ? 0 : 1,
      duration: const Duration(milliseconds: 250),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Divider appears only when bar visible
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: strength.clamp(0, 1),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.9), color],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _label(t),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: .3,
            ),
          ),
        ],
      ),
    );
  }
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
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final messenger = ScaffoldMessenger.of(context); // capture
      final router = GoRouter.of(context); // capture
      final user = await _auth.signUp(_email.text, _pass.text);
      if (!mounted) return;
      // Update display name if provided
      final nameTrimmed = _name.text.trim();
      if (nameTrimmed.isNotEmpty) {
        await user?.updateDisplayName(nameTrimmed);
      }
      // Send verification email; then go to confirmation screen.
      await user?.sendEmailVerification();
      messenger.showSnackBar(SnackBar(content: Text(t.accountCreated)));
      router.go(Routes.confirmEmail);
    } on AuthException catch (e) {
      final messenger = ScaffoldMessenger.of(context);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _validateEmail(String? v) {
    final t = AppLocalizations.of(context)!;
    if (v == null || v.trim().isEmpty) return t.email;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
      return t.invalidEmail;
    }
    return null;
  }

  String? _validatePassword(String? v) {
    final t = AppLocalizations.of(context)!;
    if (v == null || v.isEmpty) return t.password;
    if (v.length < 6) return t.weakPassword; // basic
    return null;
  }

  String? _validateConfirm(String? v) {
    final t = AppLocalizations.of(context)!;
    if (v == null || v.isEmpty) return t.confirmPassword;
    if (v != _pass.text) return t.passwordsMismatch;
    return null;
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
            const GlowBlob(
              size: 220,
              color1: Color(0xFF6D4AFF),
              color2: Color(0xFF3EA7FF),
              left: -80,
              top: -60,
            ),
            const GlowBlob(
              size: 260,
              color1: Color(0xFF8B5CF6),
              color2: Color(0xFF22D3EE),
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
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [AutofillHints.name],
                                    decoration: InputDecoration(
                                      labelText: t.name,
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
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [AutofillHints.email],
                                    decoration: InputDecoration(
                                      labelText: t.email,
                                      prefixIcon: const Icon(
                                        Icons.mail_rounded,
                                      ),
                                    ),
                                    validator: _validateEmail,
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _pass,
                                    obscureText: _obscure1,
                                    textInputAction: TextInputAction.next,
                                    onChanged: _updateStrength,
                                    autofillHints: const [
                                      AutofillHints.newPassword,
                                    ],
                                    decoration: InputDecoration(
                                      labelText: t.password,
                                      prefixIcon: const Icon(
                                        Icons.lock_rounded,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed:
                                            () => setState(
                                              () => _obscure1 = !_obscure1,
                                            ),
                                        icon: Icon(
                                          _obscure1
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                        ),
                                      ),
                                    ),
                                    validator: _validatePassword,
                                  ),
                                  if (_strength >= 0.2) ...[
                                    const SizedBox(height: 6),
                                    PasswordStrengthBar(strength: _strength),
                                  ],
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _confirm,
                                    obscureText: _obscure2,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _onSignUp(),
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    decoration: InputDecoration(
                                      labelText: t.confirmPassword,
                                      prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed:
                                            () => setState(
                                              () => _obscure2 = !_obscure2,
                                            ),
                                        icon: Icon(
                                          _obscure2
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                        ),
                                      ),
                                    ),
                                    validator: _validateConfirm,
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
                                            : () => GoRouter.of(context).pop(),
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
