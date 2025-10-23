// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/app/app_theme.dart';
import 'package:money_tracker/features/auth/presentation/pages/login_screen.dart';

Widget _wrap(Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.dark,
  home: child,
);

void main() {
  group('LoginScreen', () {
    testWidgets('renders inputs and CTA', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));

      expect(find.text('Finoro'), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);

      // Email + Password inputs exist
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);

      // CTA button exists
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
    });

    testWidgets('shows validation messages on empty submit', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));

      await tester.tap(find.text('Sign In'));
      await tester.pump(); // let validation run

      expect(find.text('Enter your email'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
    });

    testWidgets('shows invalid email message', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));

      // Enter invalid email + some password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'invalid@',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'secret',
      );

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Invalid email'), findsOneWidget);
    });

    testWidgets('submits with valid credentials and shows SnackBar', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'secret123',
      );

      await tester.tap(find.text('Sign In'));

      // Button shows a progress indicator until the stubbed Future.delayed completes (900ms)
      await tester.pump(const Duration(milliseconds: 950));

      // SnackBar from the stubbed sign-in
      expect(find.text('Signed in (stub)'), findsOneWidget);
    });
  });
}
