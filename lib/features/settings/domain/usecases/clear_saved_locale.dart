import 'package:money_tracker/features/settings/domain/repositories/locale_repository.dart';

class ClearSavedLocale {
  ClearSavedLocale(this._repository);

  final LocaleRepository _repository;

  Future<void> call() => _repository.clearSavedLocale();
}
