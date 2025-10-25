import 'package:money_tracker/features/settings/data/datasources/locale_local_data_source.dart';
import 'package:money_tracker/features/settings/domain/entities/app_locale.dart';
import 'package:money_tracker/features/settings/domain/repositories/locale_repository.dart';

class LocaleRepositoryImpl implements LocaleRepository {
  LocaleRepositoryImpl(this._localDataSource);

  final LocaleLocalDataSource _localDataSource;

  @override
  Future<AppLocale?> getSavedLocale() async {
    final code = await _localDataSource.readLocale();
    if (code == null || code.isEmpty) {
      return null;
    }
    return AppLocale(code);
  }

  @override
  Future<void> saveLocale(AppLocale locale) =>
      _localDataSource.writeLocale(locale.languageCode);

  @override
  Future<void> clearSavedLocale() =>
      _localDataSource.clearLocale();
}
