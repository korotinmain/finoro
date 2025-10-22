import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:money_tracker/core/services/app_launch_service.dart';
import 'package:money_tracker/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker/ui/auth_widgets.dart' hide GlowBlob;
import 'package:money_tracker/ui/widgets/glow_blob.dart';
import 'package:money_tracker/router.dart';
import 'package:money_tracker/core/utils/haptic_feedback.dart';
import 'package:money_tracker/core/validators/form_validators.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _isFirstLaunch = false;
  final _authService = AuthService();

  Future<void> _onSignIn() async {
    if (!_formKey.currentState!.validate()) {
      await HapticFeedbackHelper.error();
      return;
    }

    await HapticFeedbackHelper.mediumImpact();
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      final router = GoRouter.of(context); // capture before await
      await _authService.signIn(context, _email.text.trim(), _pass.text);
      if (!mounted) return;

      await HapticFeedbackHelper.success();

      // Route changed: old '/home' replaced by tab shell with dashboard root.
      final user = _authService.currentUser;
      if (user != null && !user.emailVerified) {
        router.go(Routes.confirmEmail);
      } else {
        router.go(Routes.dashboard);
      }
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
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    _isFirstLaunch = await AppLaunchService.isFirstLaunch();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final t = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            const AuthGradientBackground(),
            GlowBlob.purpleBlue(size: AppSizes.blobSmall, left: -80, top: -60),
            GlowBlob.purpleCyan(
              size: AppSizes.blobMedium,
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
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 0,
                      bottom: bottomInset + 24,
                    ),
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
                                    t.appTitle,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _isFirstLaunch ? t.welcome : t.welcomeBack,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.75,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  TextFormField(
                                    controller: _email,
                                    enabled: !_loading,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [
                                      AutofillHints.username,
                                      AutofillHints.email,
                                    ],
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
                                    obscureText: _obscure,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _onSignIn(),
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    decoration: InputDecoration(
                                      labelText: t.password,
                                      hintText: 'Enter your password',
                                      prefixIcon: const Icon(
                                        Icons.lock_rounded,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () async {
                                          await HapticFeedbackHelper.lightImpact();
                                          setState(() => _obscure = !_obscure);
                                        },
                                        icon: Icon(
                                          _obscure
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                        ),
                                      ),
                                    ),
                                    validator:
                                        (v) =>
                                            (v == null || v.isEmpty)
                                                ? t.enterPassword
                                                : null,
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed:
                                          _loading
                                              ? null
                                              : () async {
                                                await HapticFeedbackHelper.lightImpact();
                                                if (mounted) {
                                                  GoRouter.of(
                                                    context,
                                                  ).push(Routes.forgot);
                                                }
                                              },
                                      child: Text(t.forgotPasswordButton),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  AuthPrimaryButton(
                                    onPressed: _onSignIn,
                                    loading: _loading,
                                    child: Text(
                                      t.signIn,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed:
                                        _loading
                                            ? null
                                            : () async {
                                              await HapticFeedbackHelper.lightImpact();
                                              if (mounted) {
                                                GoRouter.of(
                                                  context,
                                                ).push(Routes.register);
                                              }
                                            },
                                    child: Text(t.signUp),
                                  ),
                                  const SizedBox(height: 10),
                                  if (size.height > 760)
                                    const SizedBox(height: 8),
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
