import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:money_tracker/core/constants/app_strings.dart';

/// Centralized form validation logic following Single Responsibility Principle
class FormValidators {
  FormValidators._(); // Private constructor to prevent instantiation

  /// Validates email format
  static String? validateEmail(String? value, AppLocalizations t) {
    if (value == null || value.trim().isEmpty) {
      return t.email;
    }
    if (!RegExp(AppStrings.emailPattern).hasMatch(value.trim())) {
      return t.invalidEmail;
    }
    return null;
  }

  /// Validates password with minimum length requirement
  static String? validatePassword(
    String? value,
    AppLocalizations t, {
    int minLength = 6,
  }) {
    if (value == null || value.isEmpty) {
      return t.password;
    }
    if (value.length < minLength) {
      return t.weakPassword;
    }
    return null;
  }

  /// Validates password confirmation matches
  static String? validatePasswordConfirmation(
    String? value,
    String password,
    AppLocalizations t,
  ) {
    if (value == null || value.isEmpty) {
      return t.confirmPassword;
    }
    if (value != password) {
      return t.passwordsMismatch;
    }
    return null;
  }

  /// Validates required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return fieldName;
    }
    return null;
  }
}
