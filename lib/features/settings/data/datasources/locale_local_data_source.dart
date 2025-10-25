import 'package:shared_preferences/shared_preferences.dart';

class LocaleLocalDataSource {
  LocaleLocalDataSource({SharedPreferences? sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  static const _localePreferenceKey = 'app_locale';

  final SharedPreferences? _sharedPreferences;

  Future<SharedPreferences> _prefs() async =>
      _sharedPreferences ?? SharedPreferences.getInstance();

  Future<String?> readLocale() async {
    final prefs = await _prefs();
    return prefs.getString(_localePreferenceKey);
  }

  Future<void> writeLocale(String languageCode) async {
    final prefs = await _prefs();
    await prefs.setString(_localePreferenceKey, languageCode);
  }

  Future<void> clearLocale() async {
    final prefs = await _prefs();
    await prefs.remove(_localePreferenceKey);
  }
}
