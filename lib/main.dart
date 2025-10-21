import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker/firebase_options.dart';
import 'package:money_tracker/core/routing/app_router.dart';
import 'app/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Firebase projectId: ${Firebase.app().options.projectId}');
  runApp(const MoneyApp());
}

class MoneyApp extends StatelessWidget {
  const MoneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Finoro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      supportedLocales: const [Locale('en'), Locale('uk')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supported) {
        // Automatically use system language if available
        for (final supportedLocale in supported) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supported.first; // fallback to English
      },
      routerConfig: createAppRouter(),
    );
  }
}
