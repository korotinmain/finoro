import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker/features/settings/data/datasources/locale_local_data_source.dart';
import 'package:money_tracker/features/settings/data/repositories/locale_repository_impl.dart';
import 'package:money_tracker/features/settings/domain/entities/app_locale.dart';
import 'package:money_tracker/features/settings/domain/repositories/locale_repository.dart';
import 'package:money_tracker/features/settings/domain/usecases/clear_saved_locale.dart';
import 'package:money_tracker/features/settings/domain/usecases/load_saved_locale.dart';
import 'package:money_tracker/features/settings/domain/usecases/save_locale.dart';

final localeLocalDataSourceProvider =
    Provider<LocaleLocalDataSource>((ref) {
  return LocaleLocalDataSource();
});

final localeRepositoryProvider =
    Provider<LocaleRepository>((ref) {
  return LocaleRepositoryImpl(ref.read(localeLocalDataSourceProvider));
});

final loadSavedLocaleUseCaseProvider =
    Provider<LoadSavedLocale>((ref) {
  return LoadSavedLocale(ref.read(localeRepositoryProvider));
});

final saveLocaleUseCaseProvider =
    Provider<SaveLocale>((ref) {
  return SaveLocale(ref.read(localeRepositoryProvider));
});

final clearSavedLocaleUseCaseProvider =
    Provider<ClearSavedLocale>((ref) {
  return ClearSavedLocale(ref.read(localeRepositoryProvider));
});

final localeControllerProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);

class LocaleController extends Notifier<Locale?> {
  LoadSavedLocale get _loadSavedLocale =>
      ref.read(loadSavedLocaleUseCaseProvider);
  SaveLocale get _saveLocale => ref.read(saveLocaleUseCaseProvider);
  ClearSavedLocale get _clearSavedLocale =>
      ref.read(clearSavedLocaleUseCaseProvider);

  @override
  Locale? build() {
    _loadInitialLocale();
    return null;
  }

  void _loadInitialLocale() {
    Future<void>(() async {
      try {
        final savedLocale = await _loadSavedLocale();
        if (savedLocale != null) {
          state = savedLocale.toLocale();
        }
      } catch (_) {
        // Ignore errors and rely on system locale.
      }
    });
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    try {
      await _saveLocale(AppLocale.fromLocale(locale));
    } catch (_) {
      // Persisting the preference failed; keep in-memory state in sync.
    }
  }

  Future<void> resetToSystemLocale() async {
    state = null;
    try {
      await _clearSavedLocale();
    } catch (_) {
      // Ignore storage errors; the UI already reflects the fallback state.
    }
  }
}
