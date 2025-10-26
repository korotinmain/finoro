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
      case AppStrings.errorOperationNotAllowed:
        return t.errOperationNotAllowed;
      case AppStrings.errorUserNotFound:
        return t.errUserNotFound;
      case AppStrings.errorWrongPassword:
        return t.errWrongPassword;
      default:
        return t.errUnexpected;
    }
  }
}
