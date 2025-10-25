import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker/core/routing/app_router.dart';
import 'package:money_tracker/features/settings/presentation/providers/locale_controller.dart';
import 'package:money_tracker/firebase_options.dart';

import 'app/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MoneyApp()));
}

class MoneyApp extends ConsumerWidget {
  const MoneyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLocale = ref.watch(localeControllerProvider);
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Finoro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      locale: selectedLocale,
      supportedLocales: const [Locale('en'), Locale('uk')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (systemLocale, supported) {
        if (selectedLocale != null &&
            supported.any(
              (supportedLocale) =>
                  supportedLocale.languageCode == selectedLocale.languageCode,
            )) {
          return selectedLocale;
        }
        // Automatically use system language if available
        for (final supportedLocale in supported) {
          if (supportedLocale.languageCode == systemLocale?.languageCode) {
            return supportedLocale;
          }
        }
        return supported.first; // fallback to English
      },
      routerConfig: router,
    );
  }
}
