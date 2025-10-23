import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker/core/routing/app_routes.dart';
import 'package:money_tracker/core/routing/route_guard.dart';
import 'package:money_tracker/core/routing/stream_refresh_notifier.dart';
// Feature Tabs
import 'package:money_tracker/features/dashboard/presentation/dashboard_tab.dart';
import 'package:money_tracker/features/expenses/presentation/expenses_tab.dart';
import 'package:money_tracker/features/history/presentation/history_tab.dart';
import 'package:money_tracker/features/settings/presentation/pages/account_settings_page.dart';
import 'package:money_tracker/features/settings/presentation/pages/help_page.dart';
import 'package:money_tracker/features/settings/presentation/settings_tab.dart';
// App Shell
import 'package:money_tracker/screens/app_shell.dart';
import 'package:money_tracker/screens/email_confirmation_screen.dart';
import 'package:money_tracker/screens/forgot_password_screen.dart';
// Auth Screens
import 'package:money_tracker/screens/launch_screen.dart';
import 'package:money_tracker/screens/login_screen.dart';
import 'package:money_tracker/screens/register_screen.dart';

/// Create a custom page transition with fade and slide effect
CustomTransitionPage<T> _createTransitionPage<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      final offsetTween = Tween<Offset>(
        begin: const Offset(0.08, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOut));

      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: animation.drive(offsetTween),
          child: child,
        ),
      );
    },
  );
}

/// Configure and return the app's GoRouter instance
GoRouter createAppRouter() {
  final auth = FirebaseAuth.instance;
  final routeGuard = RouteGuard(auth);

  return GoRouter(
    initialLocation: AppRoutes.launch,
    redirect: (context, state) => routeGuard.redirect(state.matchedLocation),
    refreshListenable: StreamRefreshNotifier(auth.authStateChanges()),
    routes: [
      // Launch/Splash Screen
      GoRoute(
        path: AppRoutes.launch,
        pageBuilder:
            (context, state) => _createTransitionPage(
              state: state,
              child: const LaunchScreen(),
            ),
      ),

      // Authentication Routes
      GoRoute(
        path: AppRoutes.login,
        pageBuilder:
            (context, state) =>
                _createTransitionPage(state: state, child: const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder:
            (context, state) => _createTransitionPage(
              state: state,
              child: const RegisterScreen(),
            ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder:
            (context, state) => _createTransitionPage(
              state: state,
              child: const ForgotPasswordScreen(),
            ),
      ),
      GoRoute(
        path: AppRoutes.confirmEmail,
        pageBuilder:
            (context, state) => _createTransitionPage(
              state: state,
              child: const EmailConfirmationScreen(),
            ),
      ),

      // Authenticated Shell with Tabs
      ShellRoute(
        pageBuilder:
            (context, state, child) => _createTransitionPage(
              state: state,
              child: AppShell(child: child),
            ),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder:
                (context, state) => _createTransitionPage(
                  state: state,
                  child: const DashboardTab(),
                ),
          ),
          GoRoute(
            path: AppRoutes.expenses,
            pageBuilder:
                (context, state) => _createTransitionPage(
                  state: state,
                  child: const ExpensesTab(),
                ),
          ),
          GoRoute(
            path: AppRoutes.history,
            pageBuilder:
                (context, state) => _createTransitionPage(
                  state: state,
                  child: const HistoryTab(),
                ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder:
                (context, state) => _createTransitionPage(
                  state: state,
                  child: const SettingsTab(),
                ),
          ),
          GoRoute(
            path: AppRoutes.accountSettings,
            pageBuilder:
                (context, state) => _createTransitionPage(
                  state: state,
                  child: const AccountSettingsPage(),
                ),
          ),
          GoRoute(
            path: AppRoutes.help,
            pageBuilder:
                (context, state) => _createTransitionPage(
                  state: state,
                  child: const HelpPage(),
                ),
          ),
        ],
      ),
    ],
  );
}
