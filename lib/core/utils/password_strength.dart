/// Utility for calculating password strength
class PasswordStrength {
  PasswordStrength._(); // Private constructor to prevent instantiation

  /// Calculate password strength on a scale of 0.0 to 1.0
  ///
  /// Criteria:
  /// - Length >= 6 characters: +1 point
  /// - Length >= 10 characters: +1 point
  /// - Contains uppercase letters: +1 point
  /// - Contains numbers: +1 point
  /// - Contains special characters: +1 point
  ///
  /// Total: 5 points = 100% strength
  static double calculate(String password) {
    int score = 0;

    if (password.length >= 6) score++;
    if (password.length >= 10) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;

    return (score / 5).clamp(0.0, 1.0);
  }

  /// Get password strength level
  static PasswordStrengthLevel getLevel(double strength) {
    if (strength < 0.4) return PasswordStrengthLevel.weak;
    if (strength < 0.7) return PasswordStrengthLevel.medium;
    return PasswordStrengthLevel.strong;
  }
}

enum PasswordStrengthLevel { weak, medium, strong }
