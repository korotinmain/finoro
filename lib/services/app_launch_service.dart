import 'package:shared_preferences/shared_preferences.dart';

class AppLaunchService {
  static const _firstLaunchKey = 'is_first_launch';

  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyOpened = prefs.getBool(_firstLaunchKey) ?? false;

    if (!alreadyOpened) {
      await prefs.setBool(_firstLaunchKey, true);
      return true;
    }

    return false;
  }
}
