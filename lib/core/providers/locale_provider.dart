import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key for storing locale preference in SharedPreferences
const String localePreferenceKey = 'app_locale';

/// Global notifier for locale changes
final ValueNotifier<Locale?> localeNotifier = ValueNotifier<Locale?>(null);

/// Service for managing app locale
class LocaleService {
  LocaleService._(); // Private constructor

  /// Load saved locale from SharedPreferences
  static Future<Locale?> loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(localePreferenceKey);

      if (localeCode != null) {
        return Locale(localeCode);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Save locale to SharedPreferences and notify listeners
  static Future<void> saveLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(localePreferenceKey, locale.languageCode);
      localeNotifier.value = locale;
    } catch (_) {
      // If saving fails, still update the notifier
      localeNotifier.value = locale;
    }
  }

  /// Clear the saved locale preference (revert to system default)
  static Future<void> clearLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(localePreferenceKey);
      localeNotifier.value = null;
    } catch (_) {
      localeNotifier.value = null;
    }
  }
}
