import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/screens/register_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  group('Password strength bar', () {
    testWidgets('Hidden when strength < 0.2', (tester) async {
      await tester.pumpWidget(_wrap(const PasswordStrengthBar(strength: 0.19)));
      expect(find.text('Very Weak'), findsNothing);
    });

    testWidgets('Shows Very Weak at 0.2', (tester) async {
      await tester.pumpWidget(_wrap(const PasswordStrengthBar(strength: 0.2)));
      expect(find.text('Very Weak'), findsOneWidget);
    });

    testWidgets('Shows Weak at 0.39', (tester) async {
      await tester.pumpWidget(_wrap(const PasswordStrengthBar(strength: 0.39)));
      expect(find.text('Weak'), findsOneWidget);
    });

    testWidgets('Shows Fair at 0.59', (tester) async {
      await tester.pumpWidget(_wrap(const PasswordStrengthBar(strength: 0.59)));
      expect(find.text('Fair'), findsOneWidget);
    });

    testWidgets('Shows Medium at 0.79', (tester) async {
      await tester.pumpWidget(_wrap(const PasswordStrengthBar(strength: 0.79)));
      expect(find.text('Medium'), findsOneWidget);
    });

    testWidgets('Shows Strong at 0.99', (tester) async {
      await tester.pumpWidget(_wrap(const PasswordStrengthBar(strength: 0.99)));
      expect(find.text('Strong'), findsOneWidget);
    });

    testWidgets('Shows Very Strong at 1.0', (tester) async {
      await tester.pumpWidget(_wrap(const PasswordStrengthBar(strength: 1.0)));
      expect(find.text('Very Strong'), findsOneWidget);
    });
  });
}
