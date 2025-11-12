// lib/core/constants/app_constants.dart
class AppConstants {
  // إعدادات API
  static const String apiBaseUrl = 'https://api.velora.com/v1/';
  static const Duration apiTimeout = Duration(seconds: 30);

  // مفاتيح التخزين
  static const String languageKey = 'language';
  static const String userTokenKey = 'user_token';
  static const String firstLaunchKey = 'first_launch';
  static const String themeKey = 'theme_mode';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String customApiBaseUrlKey = 'custom_api_base_url';
  static const String remoteApiFallbackUrl = 'https://velorify.pro/api';

  // معلومات التطبيق
  static const String appName = 'Velora';
  static const String appVersion = '1.0.0';
  static const String appEmail = 'mahmoudsharfoush34@gmail.com';
  static const String appPlayStoreUrl =
      'https://play.google.com/store/apps/details?id=com.velora.app';
  static const String appAppStoreUrl =
      'https://apps.apple.com/app/velora/id123456789';

  // إعدادات الخريطة
  static const double defaultMapLatitude = 31.9522;
  static const double defaultMapLongitude = 35.2332;
  static const double defaultMapZoom = 8.0;

  // روابط الصور (للتطوير)
  static const String placeholderImage =
      'https://placehold.co/400x300/556B2F/FFFFFF/png?text=Velora';

  // إعدادات الأصول
  static const String logoPath = 'assets/images/logo.png';
  static const String onboarding1Path = 'assets/images/onboarding1.png';
  static const String onboarding2Path = 'assets/images/onboarding2.png';
  static const String onboarding3Path = 'assets/images/onboarding3.png';

  // إعدادات المصادقة
  static const int otpLength = 6;
  static const Duration otpTimeout = Duration(minutes: 5);

  // إعدادات التطبيق
  static const int searchHistoryLimit = 10;
  static const int reviewMinLength = 10;
  static const int reviewMaxLength = 500;
  static const Duration cacheDuration = Duration(hours: 24);

  // إعدادات الإشعارات
  static const String notificationChannelId = 'velora_notifications';
  static const String notificationChannelName = 'Velora Notifications';
  static const String notificationChannelDescription =
      'Notifications from Velora app';

  // روابط المساعدة
  static const String termsUrl = 'https://velora-explore.netlify.app/';
  static const String privacyUrl = 'https://velora-explore.netlify.app/';
  static const String faqUrl = 'https://velora-explore.netlify.app/';
  static const String supportUrl = 'https://velora-explore.netlify.app/';
}
