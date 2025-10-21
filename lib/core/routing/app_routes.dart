/// Route constants for type-safe navigation
/// Centralized location for all app routes following DRY principle
class AppRoutes {
  AppRoutes._(); // Private constructor to prevent instantiation

  // Auth Routes
  static const String launch = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String confirmEmail = '/confirm-email';

  // Main App Routes (Authenticated Shell)
  static const String dashboard = '/dashboard';
  static const String expenses = '/expenses';
  static const String history = '/history';
  static const String settings = '/settings';
  static const String accountSettings = '/settings/account';

  /// Check if a route is an auth route (unauthenticated)
  static bool isAuthRoute(String route) {
    return route == login ||
        route == register ||
        route == forgotPassword ||
        route == confirmEmail ||
        route == launch;
  }

  /// Check if a route is a protected route (requires authentication)
  static bool isProtectedRoute(String route) {
    return route.startsWith(dashboard) ||
        route.startsWith(expenses) ||
        route.startsWith(history) ||
        route.startsWith(settings);
  }
}
