import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:money_tracker/core/constants/app_strings.dart';

/// Maps Firebase Auth error codes to user-friendly localized messages
class AuthErrorMapper {
  AuthErrorMapper._(); // Private constructor to prevent instantiation

  /// Map error code to localized message for sign-in errors
  static String mapSignInError(String code, AppLocalizations t) {
    switch (code) {
      case AppStrings.errorInvalidEmail:
        return t.errInvalidEmailFormat;
      case AppStrings.errorUserDisabled:
        return t.errAccountDisabled;
      case AppStrings.errorUserNotFound:
        return t.errUserNotFound;
      case AppStrings.errorWrongPassword:
        return t.errWrongPassword;
      default:
        return t.errUnexpected;
    }
  }

  /// Map error code to localized message for sign-up errors
  static String mapSignUpError(String code, AppLocalizations t) {
    switch (code) {
      case AppStrings.errorEmailInUse:
        return t.errEmailInUse;
      case AppStrings.errorInvalidEmail:
        return t.errInvalidEmailFormat;
      case AppStrings.errorOperationNotAllowed:
        return t.errOperationNotAllowed;
      case AppStrings.errorWeakPassword:
        return t.errWeakPassword;
      default:
        return t.errCouldNotCreateAccount;
    }
  }

  /// Map error code to localized message for password reset errors
  static String mapPasswordResetError(String code, AppLocalizations t) {
    switch (code) {
      case AppStrings.errorInvalidEmail:
        return t.errInvalidEmailFormat;
      case AppStrings.errorUserNotFound:
        return t.errUserNotFound;
      default:
        return t.errUnexpected;
    }
  }
}
