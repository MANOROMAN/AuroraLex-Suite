import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/config/firebase_init_provider.dart';
import 'core/controllers/language_controller.dart';
import 'core/controllers/theme_controller.dart';
import 'core/i18n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/splash_screen.dart';

class AuroraLexApp extends ConsumerWidget {
  const AuroraLexApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final firebaseInitialization = ref.watch(firebaseInitializationProvider);

    return firebaseInitialization.when(
      data: (_) {
        final router = ref.watch(appRouterProvider);
        return MaterialApp.router(
          title: 'AuroraLex Suite',
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: const [Locale('tr'), Locale('en')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: theme.light,
          darkTheme: theme.dark,
          themeMode: themeMode,
          routerConfig: router,
        );
      },
      loading: () => MaterialApp(
        title: 'AuroraLex Suite',
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: const [Locale('tr'), Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: theme.light,
        darkTheme: theme.dark,
        themeMode: themeMode,
        home: const AuroraSplashScreen(autoNavigate: false),
      ),
      error: (error, stack) => MaterialApp(
        title: 'AuroraLex Suite',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF101922),
          body: Center(
            child: Text(
              'Başlatma hatası:\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
