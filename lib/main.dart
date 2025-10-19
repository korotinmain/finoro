import 'package:flutter/material.dart';
import 'package:money_tracker/screens/launch_screen.dart';
import 'app/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MoneyApp());
}

class MoneyApp extends StatelessWidget {
  const MoneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monthly Budget',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      supportedLocales: const [Locale('uk'), Locale('en')],
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
            return supported.first;
          }
        }
        return supported.first; // fallback to English
      },
      home: const LaunchScreen(),
    );
  }
}
