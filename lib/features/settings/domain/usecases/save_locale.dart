import 'package:money_tracker/features/settings/domain/entities/app_locale.dart';
import 'package:money_tracker/features/settings/domain/repositories/locale_repository.dart';

class SaveLocale {
  SaveLocale(this._repository);

  final LocaleRepository _repository;

  Future<void> call(AppLocale locale) => _repository.saveLocale(locale);
}
