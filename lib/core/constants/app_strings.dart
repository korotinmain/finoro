/// Non-localized string constants (keys, preferences, etc.)
class AppStrings {
  AppStrings._(); // Private constructor to prevent instantiation

  // Shared Preferences Keys
  static const String firstLaunchKey = 'is_first_launch';

  // Firebase Auth Error Codes
  static const String errorInvalidEmail = 'invalid-email';
  static const String errorUserDisabled = 'user-disabled';
  static const String errorUserNotFound = 'user-not-found';
  static const String errorWrongPassword = 'wrong-password';
  static const String errorOperationNotAllowed = 'operation-not-allowed';

  // Regex Patterns
  static const String emailPattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';

  // Action Code Settings
  static const String actionCodeUrl =
      'https://moneytracker-5c1e6.web.app/auth/action';
  static const String androidPackageName = 'com.korotindenys.moneyTracker';
  static const String androidMinVersion = '21';
  static const String iosBundleId = 'com.korotindenys.moneyTracker';
}
