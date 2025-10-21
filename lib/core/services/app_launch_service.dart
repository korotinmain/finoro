import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_tracker/core/constants/app_strings.dart';

/// Service for managing app launch state
class AppLaunchService {
  AppLaunchService._(); // Private constructor to prevent instantiation

  /// Check if this is the first time the app has been launched
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyOpened = prefs.getBool(AppStrings.firstLaunchKey) ?? false;

    if (!alreadyOpened) {
      await prefs.setBool(AppStrings.firstLaunchKey, true);
      return true;
    }

    return false;
  }

  /// Mark app as having been launched (for testing purposes)
  static Future<void> markAsLaunched() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppStrings.firstLaunchKey, true);
  }

  /// Reset first launch flag (for testing purposes)
  static Future<void> resetFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppStrings.firstLaunchKey);
  }
}
