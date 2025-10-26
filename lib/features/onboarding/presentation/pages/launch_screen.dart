import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';
import 'package:money_tracker/core/routing/app_routes.dart';
import 'package:money_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:money_tracker/ui/widgets/glow_blob.dart';

class LaunchScreen extends ConsumerStatefulWidget {
  const LaunchScreen({super.key});

  @override
  ConsumerState<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends ConsumerState<LaunchScreen>
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
      final user = ref.read(getCurrentUserProvider)();
      final router = GoRouter.of(context);
      if (user == null) {
        router.go(AppRoutes.login);
      } else {
        router.go(AppRoutes.dashboard);
      }
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
          GlowBlob.purpleBlue(size: AppSizes.blobMedium, left: -90, top: -70),
          GlowBlob.purpleCyan(
            size: AppSizes.blobLarge,
            right: -80,
            bottom: -90,
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
                          const SizedBox(height: 8),
                          FadeTransition(
                            opacity: _taglineFade,
                            child: SlideTransition(
                              position: _taglineSlide,
                              child: Text(
                                t.splashTagline,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
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

// Removed _GlowBlob - now using shared GlowBlob widget
