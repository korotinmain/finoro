import 'package:money_tracker/features/settings/domain/entities/app_locale.dart';
import 'package:money_tracker/features/settings/domain/repositories/locale_repository.dart';

class LoadSavedLocale {
  LoadSavedLocale(this._repository);

  final LocaleRepository _repository;

  Future<AppLocale?> call() => _repository.getSavedLocale();
}
