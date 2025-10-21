import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker/firebase_options.dart';
import 'package:money_tracker/core/routing/app_router.dart';
import 'package:money_tracker/core/providers/locale_provider.dart';
import 'app/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Firebase projectId: ${Firebase.app().options.projectId}');
  runApp(const MoneyApp());
}

class MoneyApp extends StatefulWidget {
  const MoneyApp({super.key});

  @override
  State<MoneyApp> createState() => _MoneyAppState();
}

class _MoneyAppState extends State<MoneyApp> {
  @override
  void initState() {
    super.initState();
    _loadLocale();
    // Listen to locale changes
    localeNotifier.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    localeNotifier.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    setState(() {});
  }

  Future<void> _loadLocale() async {
    final locale = await LocaleService.loadLocale();
    if (mounted) {
      localeNotifier.value = locale;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Finoro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      locale: localeNotifier.value,
      supportedLocales: const [Locale('en'), Locale('uk')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supported) {
        // If user has set a preference, use it
        if (localeNotifier.value != null) {
          return localeNotifier.value;
        }
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
