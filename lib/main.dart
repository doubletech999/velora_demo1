// lib/main.dart - تحديث لإضافة TripRegistrationProvider مع JourneyProvider
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_colors.dart';
import 'core/localization/language_provider.dart';
import 'presentation/providers/paths_provider.dart';
import 'presentation/providers/user_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/saved_paths_provider.dart';
import 'presentation/providers/journey_provider.dart';
import 'presentation/providers/trip_registration_provider.dart'; // إضافة جديدة
import 'presentation/providers/reviews_provider.dart';
import 'core/services/connectivity_service.dart';
import 'data/services/auth_service.dart';
import 'data/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize connectivity service
  await ConnectivityService().initialize();

  // ✅ اكتشاف البيئة تلقائياً:
  // - Flutter Web: http://localhost:8000/api
  // - Android Emulator: http://10.0.2.2:8000/api
  // - iOS Simulator: http://127.0.0.1:8000/api
  // - Real Device (ngrok): https://trevally-unpatented-christia.ngrok-free.dev/api
  // - Real Device (Custom IP): يمكن تعيينه عبر setCustomBaseUrl()

  // 🌐 لاستخدام ngrok (للأجهزة الحقيقية أو الوصول الخارجي):
  // قم بإلغاء التعليق عن السطر التالي لاستخدام ngrok URL
  final apiService = ApiService.instance;
  await apiService.loadCustomBaseUrl();

  const customBaseUrl = String.fromEnvironment(
    'CUSTOM_API_BASE_URL',
    defaultValue: '',
  );
  if (customBaseUrl.isNotEmpty) {
    await apiService.setCustomBaseUrl(customBaseUrl);
  } else if (!apiService.hasCustomBaseUrl) {
    try {
      if (Platform.isIOS) {
        final deviceInfo = DeviceInfoPlugin();
        final iosInfo = await deviceInfo.iosInfo;
        if (iosInfo.isPhysicalDevice) {
          await apiService.setCustomBaseUrl(AppConstants.remoteApiFallbackUrl);
        }
      }
    } catch (e) {
      // إذا فشل التعرف على الجهاز، احتفظ بالإعداد الافتراضي
      print('Failed to detect device type for base URL: $e');
    }
  }

  // ✅ Initialize authentication service (يحمّل Token + Custom Base URL إن وجد)
  await AuthService.instance.initialize();

  // معالجة أخطاء التطبيق
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  // تعيين معالج أخطاء غير متوقعة
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.warning_circle,
                color: AppColors.error,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'حدث خطأ غير متوقع',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'يرجى المحاولة مرة أخرى أو إعادة تشغيل التطبيق',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  };

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.primary,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PathsProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SavedPathsProvider()),
        ChangeNotifierProvider(create: (_) => JourneyProvider()),
        ChangeNotifierProvider(
          create: (_) => TripRegistrationProvider(),
        ), // إضافة جديدة
        ChangeNotifierProvider(create: (_) => ReviewsProvider()),
      ],
      child: const VeloraApp(),
    ),
  );
}
