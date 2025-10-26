import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:money_tracker/core/constants/app_strings.dart';

/// Centralized form validation logic following Single Responsibility Principle
class FormValidators {
  FormValidators._(); // Private constructor to prevent instantiation

  /// Validates email format
  static String? validateEmail(String? value, AppLocalizations t) {
    if (value == null || value.trim().isEmpty) {
      return t.fieldRequired;
    }
    if (!RegExp(AppStrings.emailPattern).hasMatch(value.trim())) {
      return t.errInvalidEmailFormat;
    }
    return null;
  }

  /// Validates required field
  static String? validateRequired(String? value, AppLocalizations t) {
    if (value == null || value.trim().isEmpty) {
      return t.fieldRequired;
    }
    return null;
  }
}
