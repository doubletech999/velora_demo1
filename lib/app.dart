// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/localization/app_localizations.dart';
import 'core/localization/language_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/settings_provider.dart';

class VeloraApp extends StatelessWidget {
  const VeloraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, SettingsProvider>(
      builder: (context, languageProvider, settingsProvider, child) {
        // إعادة بناء التطبيق عند تغيير اللغة
        return MaterialApp.router(
          title: 'Velora',
          debugShowCheckedModeBanner: false,

          // Theme
          theme: AppTheme.lightTheme(languageProvider.currentLanguage),
          darkTheme: AppTheme.darkTheme(languageProvider.currentLanguage),
          themeMode:
              settingsProvider.darkModeEnabled
                  ? ThemeMode.dark
                  : ThemeMode.light,
          // Localization - تحسين دعم اللغات
          locale: Locale(languageProvider.currentLanguage),
          supportedLocales: const [Locale('en', 'US'), Locale('ar', 'PS')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // تحديد fallback locale في حالة عدم دعم اللغة
          localeResolutionCallback: (locale, supportedLocales) {
            // إذا كانت اللغة المطلوبة مدعومة، استخدمها
            if (locale != null) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }
            }
            // إذا لم تكن مدعومة، استخدم العربية كافتراضي
            return const Locale('ar', 'PS');
          },

          // Routing
          routerConfig: AppRouter.router,

          // Define general text direction based on language
          builder: (context, child) {
            return Directionality(
              textDirection: languageProvider.textDirection,
              child: child!,
            );
          },
        );
      },
    );
  }
}
