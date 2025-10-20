import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final Animation<double> _introScale;
  late final Animation<double> _introFade;
  late final AnimationController _breath;
  late final Animation<double> _breathScale;
  late final AnimationController _tagline;
  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;
  late final AnimationController _blink;
  late final Animation<double> _blinkAlpha;
  late final AnimationController _sheen;
  late final Animation<double> _sweepT;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _introScale = Tween<double>(
      begin: 0.86,
      end: 1.0,
    ).chain(CurveTween(curve: Curves.easeOutBack)).animate(_intro);

    _introFade = CurvedAnimation(parent: _intro, curve: Curves.easeOut);

    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _blinkAlpha = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_blink);

    _sheen = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    _sweepT = Tween<double>(begin: 0.0, end: 1.0).animate(_sheen);

    // Gentle breathing scale after intro finishes.
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _breathScale = Tween<double>(
      begin: 1.0,
      end: 1.035,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_breath);
    _breath.repeat(reverse: true);

    // Tagline fade + slide.
    _tagline = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _taglineFade = CurvedAnimation(parent: _tagline, curve: Curves.easeOut);
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.20),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(_tagline);
    // Start tagline after intro a bit.
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _tagline.forward();
    });

    // Slightly longer to let breathing + tagline show.
    Future.delayed(const Duration(milliseconds: 4200), () async {
      if (!mounted) return;
      await _intro.animateBack(
        0.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );

      if (!mounted) return;
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final router = GoRouter.of(context);
      // Use a fade by pushing the target; since splash is initial route we can replace.
      router.go(loggedIn ? Routes.home : Routes.login);
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _blink.dispose();
    _sheen.dispose();
    _breath.dispose();
    _tagline.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgTop = Color(0xFF0D0F19);
    const bgBottom = Color(0xFF0A0B12);

    return Scaffold(
      backgroundColor: bgTop,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [bgTop, bgBottom],
              ),
            ),
          ),
          Positioned(
            left: -90,
            top: -70,
            child: _GlowBlob(
              size: 260,
              color1: const Color(0xFF6D4AFF),
              color2: const Color(0xFF3EA7FF),
            ),
          ),
          Positioned(
            right: -80,
            bottom: -90,
            child: _GlowBlob(
              size: 300,
              color1: const Color(0xFF8B5CF6),
              color2: const Color(0xFF22D3EE),
            ),
          ),
          Builder(
            builder: (context) {
              final pad = MediaQuery.of(context).padding;
              final visualBias = (pad.top - pad.bottom) / 2;

              return Center(
                child: Transform.translate(
                  offset: Offset(0, -visualBias),
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _intro,
                      _blink,
                      _sheen,
                      _breath,
                      _tagline,
                    ]),
                    builder: (_, __) {
                      const double logoSize = 140.0;
                      // Combine intro scale with breathing.
                      final scale = _introScale.value * _breathScale.value;
                      final t = AppLocalizations.of(context)!;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: logoSize + 60,
                            height: logoSize + 60,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                _BlinkingRing(
                                  baseSize: logoSize + 44,
                                  alpha: _blinkAlpha.value,
                                ),
                                Transform.scale(
                                  scale: scale,
                                  child: _SweptLogo(
                                    size: logoSize,
                                    sweepT: _sweepT.value,
                                    asset: 'assets/icon/app_icon.png',
                                    fade: _introFade.value,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Opacity(
                            opacity: _introFade.value,
                            child: Text(
                              t.appTitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          FadeTransition(
                            opacity: _taglineFade,
                            child: SlideTransition(
                              position: _taglineSlide,
                              child: Text(
                                t.splashTagline,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.80),
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// The blinking ring around logo.
class _BlinkingRing extends StatelessWidget {
  const _BlinkingRing({required this.baseSize, required this.alpha});

  final double baseSize;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: baseSize,
      height: baseSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFF6D4AFF).withValues(alpha: 0.25 * alpha),
            const Color(0xFF3EA7FF).withValues(alpha: 0.12 * alpha),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}

/// Logo with animated sheen.
class _SweptLogo extends StatelessWidget {
  const _SweptLogo({
    required this.size,
    required this.sweepT,
    required this.asset,
    required this.fade,
  });

  final double size;
  final double sweepT;
  final String asset;
  final double fade;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: fade,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(size),
              child: Image.asset(
                asset,
                width: size,
                height: size,
                fit: BoxFit.contain,
              ),
            ),
            Positioned.fill(
              child: ShaderMask(
                blendMode: BlendMode.srcATop,
                shaderCallback: (rect) {
                  final dx = rect.width * (sweepT - 0.5);
                  return LinearGradient(
                    begin: Alignment(-1 + 2 * sweepT, -1),
                    end: Alignment(1 + 2 * sweepT, 1),
                    colors: [
                      Colors.white.withValues(alpha: 0.00),
                      Colors.white.withValues(alpha: 0.12),
                      Colors.white.withValues(alpha: 0.00),
                    ],
                    stops: const [0.35, 0.50, 0.65],
                  ).createShader(rect.shift(Offset(dx, -dx)));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(size),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft background glow blobs.
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
