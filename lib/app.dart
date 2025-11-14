// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/localization/app_localizations.dart';
import 'core/localization/language_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/fcm_service.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/notifications_provider.dart';

class VeloraApp extends StatefulWidget {
  const VeloraApp({super.key});

  @override
  State<VeloraApp> createState() => _VeloraAppState();
}

class _VeloraAppState extends State<VeloraApp> {
  @override
  void initState() {
    super.initState();
    // Setup FCM notification handler after providers are available
    // إعداد معالج إشعارات FCM بعد توفر Providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupFCMNotificationHandler();
    });
  }

  void _setupFCMNotificationHandler() {
    // Get notifications provider from context
    // الحصول على NotificationsProvider من context
    final context = AppRouter.rootNavigatorKey.currentContext;
    if (context != null) {
      final notificationsProvider = Provider.of<NotificationsProvider>(context, listen: false);
      
      // Set callback to add notifications to provider
      // تعيين callback لإضافة الإشعارات إلى Provider
      FCMService.instance.setOnNotificationReceived((RemoteMessage message) {
        notificationsProvider.addNotificationFromMessage(message);
      });
    }
  }

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
