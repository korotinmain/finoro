import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
