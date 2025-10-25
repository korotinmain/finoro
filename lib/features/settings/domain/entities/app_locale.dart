import 'package:flutter/material.dart';

/// Domain representation of a user-selected locale.
class AppLocale {
  const AppLocale(this.languageCode);

  final String languageCode;

  Locale toLocale() => Locale(languageCode);

  static AppLocale fromLocale(Locale locale) =>
      AppLocale(locale.languageCode);
}
