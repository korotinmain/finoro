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
import 'screens/app_shell.dart';
import 'screens/tabs.dart';
import 'screens/account_settings_page.dart';

CustomTransitionPage<T> _fadeSlidePage<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, c) {
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
          child: c,
        ),
      );
    },
  );
}

final _auth = FirebaseAuth.instance;

class Routes {
  static const launch = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgot = '/forgot-password';
  static const confirmEmail = '/confirm-email';
  // Shell + tabs
  static const dashboard = '/dashboard';
  static const expenses = '/expenses';
  static const history = '/history';
  static const settings = '/settings';
  static const accountSettings = '/settings/account';
}

final appRouter = GoRouter(
  initialLocation: Routes.launch,
  routes: [
    GoRoute(
      path: Routes.launch,
      pageBuilder:
          (context, state) =>
              _fadeSlidePage(state: state, child: const LaunchScreen()),
    ),
    GoRoute(
      path: Routes.login,
      pageBuilder:
          (context, state) =>
              _fadeSlidePage(state: state, child: const LoginScreen()),
    ),
    GoRoute(
      path: Routes.register,
      pageBuilder:
          (context, state) =>
              _fadeSlidePage(state: state, child: const RegisterScreen()),
    ),
    GoRoute(
      path: Routes.confirmEmail,
      pageBuilder:
          (context, state) => _fadeSlidePage(
            state: state,
            child: const EmailConfirmationScreen(),
          ),
    ),
    GoRoute(
      path: Routes.forgot,
      pageBuilder:
          (context, state) =>
              _fadeSlidePage(state: state, child: const ForgotPasswordScreen()),
    ),
    // --- Authenticated shell with tabs ---
    ShellRoute(
      pageBuilder:
          (context, state, child) =>
              _fadeSlidePage(state: state, child: AppShell(child: child)),
      routes: [
        GoRoute(
          path: Routes.dashboard,
          pageBuilder:
              (context, state) =>
                  _fadeSlidePage(state: state, child: const DashboardTab()),
        ),
        GoRoute(
          path: Routes.expenses,
          pageBuilder:
              (context, state) =>
                  _fadeSlidePage(state: state, child: const ExpensesTab()),
        ),
        GoRoute(
          path: Routes.history,
          pageBuilder:
              (context, state) =>
                  _fadeSlidePage(state: state, child: const HistoryTab()),
        ),
        GoRoute(
          path: Routes.settings,
          pageBuilder:
              (context, state) =>
                  _fadeSlidePage(state: state, child: const SettingsTab()),
        ),
        GoRoute(
          path: Routes.accountSettings,
          pageBuilder:
              (context, state) => _fadeSlidePage(
                state: state,
                child: const AccountSettingsPage(),
              ),
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final loggedIn = _auth.currentUser != null;
    final verified = _auth.currentUser?.emailVerified ?? false;

    // Always allow splash screen.
    if (state.matchedLocation == Routes.launch) return null;

    final loc = state.matchedLocation;
    final goingToLogin = loc == Routes.login;
    final goingToForgot = loc == Routes.forgot;
    final goingToRegister = loc == Routes.register;
    final goingToConfirmEmail = loc == Routes.confirmEmail;
    final goingToShellTab =
        loc.startsWith(Routes.dashboard) ||
        loc.startsWith(Routes.expenses) ||
        loc.startsWith(Routes.history) ||
        loc.startsWith(Routes.settings);

    // Public routes when NOT logged in: login, register, forgot, confirm-email
    if (!loggedIn &&
        (goingToLogin ||
            goingToRegister ||
            goingToForgot ||
            goingToConfirmEmail)) {
      return null; // allow
    }

    if (!loggedIn) {
      if (goingToShellTab) return Routes.login;
      return Routes.login;
    }

    if (loggedIn) {
      // If not verified yet, force user into confirmation flow unless already there.
      if (!verified) {
        if (loc != Routes.confirmEmail) {
          return Routes.confirmEmail;
        }
        // Allow staying on confirm email route.
        return null;
      }
      // Email is verified: block accessing auth flows & confirmation screen.
      if (goingToLogin ||
          goingToRegister ||
          goingToForgot ||
          goingToConfirmEmail) {
        // Redirect verified user to default tab.
        return Routes.dashboard;
      }
      // If user hits root '/', send them to default tab.
      if (loc == Routes.launch) return Routes.dashboard;
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
