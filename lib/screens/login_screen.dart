import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:money_tracker/services/app_launch_service.dart';
import 'package:money_tracker/services/auth_service.dart';

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

  Future<void> _onSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final user = await AuthService().signIn(_email.text, _pass.text);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome, ${user?.email ?? "User"}!')),
      );

      // TODO: navigate to your home/dashboard screen here
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
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
      onTap: () => FocusScope.of(context).unfocus(), // dismiss keyboard on tap
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // --- Background gradient ---
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0D0F19),
                    Color(0xFF0B0E15),
                    Color(0xFF0A0B12),
                  ],
                ),
              ),
            ),
            // --- Soft purple/blue glow blobs ---
            Positioned(
              left: -80,
              top: -60,
              child: _GlowBlob(
                size: 220,
                color1: const Color(0xFF6D4AFF),
                color2: const Color(0xFF3EA7FF),
              ),
            ),
            Positioned(
              right: -70,
              bottom: -70,
              child: _GlowBlob(
                size: 260,
                color1: const Color(0xFF8B5CF6),
                color2: const Color(0xFF22D3EE),
              ),
            ),
            // --- Subtle currency icons (very faint) ---
            Positioned.fill(child: _CurrencyWatermark()),

            // --- Content (scrolls when keyboard is up) ---
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
                      bottom: bottomInset + 24, // push above keyboard
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  28,
                                  24,
                                  24,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 30,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 18),
                                    ),
                                  ],
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Logo / pie icon
                                      const _PieLogo(),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Monthly Budget',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _isFirstLaunch
                                            ? t.welcome
                                            : t.welcomeBack,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.75,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Email
                                      TextFormField(
                                        controller: _email,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.username,
                                          AutofillHints.email,
                                        ],
                                        decoration: InputDecoration(
                                          labelText: t.email,
                                          prefixIcon: const Icon(
                                            Icons.mail_rounded,
                                          ),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) {
                                            return t.email;
                                          }
                                          if (!RegExp(
                                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                          ).hasMatch(v.trim())) {
                                            return t.invalidEmail;
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 14),

                                      // Password
                                      TextFormField(
                                        controller: _pass,
                                        obscureText: _obscure,
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (_) => _onSignIn(),
                                        autofillHints: const [
                                          AutofillHints.password,
                                        ],
                                        decoration: InputDecoration(
                                          labelText: t.password,
                                          prefixIcon: const Icon(
                                            Icons.lock_rounded,
                                          ),
                                          suffixIcon: IconButton(
                                            onPressed:
                                                () => setState(
                                                  () => _obscure = !_obscure,
                                                ),
                                            icon: Icon(
                                              _obscure
                                                  ? Icons.visibility_rounded
                                                  : Icons
                                                      .visibility_off_rounded,
                                            ),
                                          ),
                                        ),
                                        validator:
                                            (v) =>
                                                (v == null || v.isEmpty)
                                                    ? 'Enter your password'
                                                    : null,
                                      ),

                                      const SizedBox(height: 22),

                                      // CTA button
                                      SizedBox(
                                        height: 56,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF6D4AFF),
                                                Color(0xFF3EA7FF),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF3EA7FF,
                                                ).withValues(alpha: 0.35),
                                                blurRadius: 20,
                                                spreadRadius: 0,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                              ),
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed:
                                                _loading ? null : _onSignIn,
                                            child:
                                                _loading
                                                    ? const SizedBox(
                                                      width: 22,
                                                      height: 22,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2.4,
                                                          ),
                                                    )
                                                    : Text(
                                                      t.signIn,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                          ),
                                        ),
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

// ---------- Decorative bits ----------
class _PieLogo extends StatelessWidget {
  const _PieLogo();

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

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({
    required this.size,
    required this.color1,
    required this.color2,
  });
  final double size;
  final Color color1;
  final Color color2;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _CurrencyWatermark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final faint = Colors.white.withValues(alpha: 0.05);
    return IgnorePointer(
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
    );
  }
}
