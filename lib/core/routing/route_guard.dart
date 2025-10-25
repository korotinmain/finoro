import 'package:money_tracker/core/routing/app_routes.dart';
import 'package:money_tracker/features/auth/domain/repositories/auth_repository.dart';

/// Handles routing logic and authentication-based redirects
/// Follows Single Responsibility Principle
class RouteGuard {
  final AuthRepository _authRepository;

  RouteGuard(this._authRepository);

  /// Determine redirect based on authentication state and destination
  /// Returns null if the route is allowed, or a redirect path otherwise
  String? redirect(String currentLocation) {
    final user = _authRepository.currentUser;
    final isLoggedIn = user != null;
    final isVerified = user?.isEmailVerified ?? false;

    // Always allow splash/launch screen
    if (currentLocation == AppRoutes.launch) {
      return null;
    }

    // If not logged in
    if (!isLoggedIn) {
      // Allow access to auth routes
      if (AppRoutes.isAuthRoute(currentLocation)) {
        return null;
      }
      // Redirect to login for protected routes
      return AppRoutes.login;
    }

    // User is logged in
    if (isLoggedIn) {
      // If email not verified, force to confirmation screen
      if (!isVerified && currentLocation != AppRoutes.confirmEmail) {
        return AppRoutes.confirmEmail;
      }

      // If verified, block access to auth routes
      if (isVerified && AppRoutes.isAuthRoute(currentLocation)) {
        return AppRoutes.dashboard;
      }
    }

    // Allow the route
    return null;
  }
}
