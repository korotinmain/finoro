import 'package:money_tracker/features/settings/domain/entities/app_locale.dart';

abstract class LocaleRepository {
  Future<AppLocale?> getSavedLocale();
  Future<void> saveLocale(AppLocale locale);
  Future<void> clearSavedLocale();
}
