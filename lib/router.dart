// lib/router.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_tracker/screens/email_confirmation_screen.dart';
import 'package:money_tracker/screens/forgot_password_screen.dart';
import 'package:money_tracker/screens/launch_screen.dart';
import 'screens/register_screen.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

final _auth = FirebaseAuth.instance;

class Routes {
  static const launch = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgot = '/forgot-password';
  static const home = '/home';
  static const confirmEmail = '/confirm-email';
}

final appRouter = GoRouter(
  initialLocation: Routes.launch,
  routes: [
    GoRoute(path: Routes.launch, builder: (_, __) => const LaunchScreen()),
    GoRoute(path: Routes.login, builder: (_, __) => const LoginScreen()),
    GoRoute(path: Routes.register, builder: (_, __) => const RegisterScreen()),
    GoRoute(
      path: Routes.confirmEmail,
      builder: (_, __) => const EmailConfirmationScreen(),
    ),
    GoRoute(
      path: Routes.forgot,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            final offsetTween = Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOut));
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: animation.drive(offsetTween),
                child: child,
              ),
            );
          },
        );
      },
    ),
    GoRoute(path: Routes.home, builder: (_, __) => const HomeScreen()),
  ],
  redirect: (context, state) {
    final loggedIn = _auth.currentUser != null;

    // Always allow splash screen.
    if (state.matchedLocation == Routes.launch) return null;

    final loc = state.matchedLocation;
    final goingToLogin = loc == Routes.login;
    final goingToForgot = loc == Routes.forgot;
    final goingToRegister = loc == Routes.register;
    final goingToConfirmEmail = loc == Routes.confirmEmail;

    // Public routes when NOT logged in: login, register, forgot, confirm-email
    if (!loggedIn &&
        (goingToLogin ||
            goingToRegister ||
            goingToForgot ||
            goingToConfirmEmail)) {
      return null; // allow
    }

    if (!loggedIn) {
      // Redirect other private paths to login.
      return Routes.login;
    }

    // If logged in, block navigating back to auth screens.
    if (loggedIn && (goingToLogin || goingToRegister || goingToForgot)) {
      return Routes.home;
    }

    return null;
  },

  refreshListenable: GoRouterRefreshStream(_auth.authStateChanges()),
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
