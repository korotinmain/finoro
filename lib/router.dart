// lib/router.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/login_screen.dart';
import 'screens/launch_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';

final _auth = FirebaseAuth.instance;

class Routes {
  static const launch = '/';
  static const login = '/login';
  static const forgot = '/forgot-password';
  static const home = '/home';
}

final appRouter = GoRouter(
  initialLocation: Routes.launch,
  routes: [
    GoRoute(path: Routes.launch, builder: (_, __) => const LaunchScreen()),
    GoRoute(path: Routes.login, builder: (_, __) => const LoginScreen()),
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

    // Allow splash (launch) screen always; it will self-navigate.
    if (state.matchedLocation == Routes.launch) {
      return null;
    }

    final goingToLogin = state.matchedLocation == Routes.login;
    final goingToForgot = state.matchedLocation == Routes.forgot;

    if (!loggedIn && !(goingToLogin || goingToForgot)) {
      return Routes.login;
    }

    if (loggedIn && (goingToLogin || goingToForgot)) {
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
