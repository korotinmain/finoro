import 'package:firebase_auth/firebase_auth.dart';

/// Abstract repository interface for authentication operations
/// Follows Dependency Inversion Principle - depend on abstractions, not concrete implementations
abstract class IAuthRepository {
  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;

  /// Get current authenticated user
  User? get currentUser;

  /// Sign in with email and password
  /// Throws [AuthException] on failure
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Create new user with email and password
  /// Throws [AuthException] on failure
  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Send password reset email
  /// Throws [AuthException] on failure
  Future<void> sendPasswordResetEmail(String email);

  /// Sign out current user
  Future<void> signOut();

  /// Send email verification to current user
  Future<void> sendEmailVerification();

  /// Reload current user data
  Future<void> reloadUser();
}
