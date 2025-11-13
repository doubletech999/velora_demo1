import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/api_service.dart';
import '../router/app_router.dart';

/// Top-level function to handle background messages
/// دالة على مستوى أعلى للتعامل مع الرسائل في الخلفية
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📱 Background message received: ${message.messageId}');
  print('📱 Title: ${message.notification?.title}');
  print('📱 Body: ${message.notification?.body}');
  print('📱 Data: ${message.data}');
  
  // Handle background notification here
  // التعامل مع الإشعار في الخلفية هنا
}

class FCMService {
  static FCMService? _instance;
  static FCMService get instance => _instance ??= FCMService._internal();
  factory FCMService() => instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final ApiService _apiService = ApiService.instance;
  
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize FCM Service
  /// تهيئة خدمة FCM
  Future<void> initialize() async {
    try {
      // Request notification permissions
      // طلب صلاحيات الإشعارات
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      print('📱 FCM Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ User granted notification permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('⚠️ User granted provisional notification permission');
      } else {
        print('❌ User declined or has not accepted notification permission');
        return;
      }

      // Get FCM Token
      // الحصول على FCM Token
      await _getFCMToken();

      // Configure foreground notification presentation
      // تكوين عرض الإشعارات في المقدمة
      await _configureForegroundNotifications();

      // Set up background message handler
      // إعداد معالج الرسائل في الخلفية
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Listen to foreground messages
      // الاستماع للرسائل في المقدمة
      _setupForegroundMessageHandler();

      // Handle notification taps (when app is in background/terminated)
      // التعامل مع الضغط على الإشعارات (عندما يكون التطبيق في الخلفية/مغلق)
      _setupNotificationTapHandler();

    } catch (e) {
      print('❌ Error initializing FCM: $e');
    }
  }

  /// Get FCM Token
  /// الحصول على FCM Token
  Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      print('✅ FCM Token: $_fcmToken');
      
      // Listen for token refresh
      // الاستماع لتحديث Token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        print('🔄 FCM Token refreshed: $newToken');
        // Send updated token to backend
        // إرسال Token المحدث للـ Backend
        _sendTokenToBackend(newToken);
      });

      return _fcmToken;
    } catch (e) {
      print('❌ Error getting FCM Token: $e');
      return null;
    }
  }

  /// Configure foreground notification presentation
  /// تكوين عرض الإشعارات في المقدمة
  Future<void> _configureForegroundNotifications() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Setup foreground message handler
  /// إعداد معالج الرسائل في المقدمة
  void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Foreground message received: ${message.messageId}');
      print('📱 Title: ${message.notification?.title}');
      print('📱 Body: ${message.notification?.body}');
      print('📱 Data: ${message.data}');

      // Handle foreground notification
      // يمكنك عرض إشعار مخصص هنا أو تحديث UI
      // Example: Show local notification or update UI
    });
  }

  /// Setup notification tap handler
  /// إعداد معالج الضغط على الإشعارات
  void _setupNotificationTapHandler() {
    // Handle notification when app is opened from terminated state
    // التعامل مع الإشعار عند فتح التطبيق من حالة الإغلاق
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('📱 App opened from terminated state via notification');
        print('📱 Data: ${message.data}');
        // Delay navigation to ensure app is fully initialized
        // تأخير التنقل لضمان تهيئة التطبيق بالكامل
        Future.delayed(const Duration(seconds: 1), () {
          _handleNotificationNavigation(message.data);
        });
      }
    });

    // Handle notification when app is in background
    // التعامل مع الإشعار عندما يكون التطبيق في الخلفية
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 App opened from background via notification');
      print('📱 Data: ${message.data}');
      _handleNotificationNavigation(message.data);
    });
  }

  /// Handle notification navigation
  /// التعامل مع التنقل عند الضغط على الإشعار
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final notificationType = data['type'] as String?;
    
    if (notificationType == null) {
      print('⚠️ Notification type is null');
      return;
    }

    // Get the context from the root navigator key
    // الحصول على context من root navigator key
    final context = AppRouter.rootNavigatorKey.currentContext;
    
    if (context == null) {
      print('⚠️ Context is null, cannot navigate');
      // Try alternative method
      // محاولة طريقة بديلة
      final routerContext = AppRouter.router.routerDelegate.navigatorKey.currentContext;
      if (routerContext == null) {
        print('⚠️ Router context is also null, cannot navigate');
        return;
      }
      _navigateWithContext(notificationType, data, routerContext);
      return;
    }
    
    _navigateWithContext(notificationType, data, context);
  }

  /// Navigate with context
  /// التنقل باستخدام context
  void _navigateWithContext(
    String notificationType,
    Map<String, dynamic> data,
    BuildContext context,
  ) {

    try {
      switch (notificationType) {
        case 'new_route_camping':
          _handleNewRouteCampingNotification(data, context);
          break;
          
        case 'trip_accepted':
          _handleTripAcceptedNotification(data, context);
          break;
          
        default:
          print('⚠️ Unknown notification type: $notificationType');
      }
    } catch (e) {
      print('❌ Error handling notification navigation: $e');
    }
  }

  /// Handle new route/camping notification
  /// التعامل مع إشعار مسار/تخييم جديد
  void _handleNewRouteCampingNotification(
    Map<String, dynamic> data,
    BuildContext context,
  ) {
    final siteId = data['site_id'] as String?;
    final siteType = data['site_type'] as String?;
    final siteName = data['site_name'] as String?;

    print('📍 New route/camping notification:');
    print('   Site ID: $siteId');
    print('   Site Type: $siteType');
    print('   Site Name: $siteName');

    if (siteId != null && siteId.isNotEmpty) {
      // Navigate to path details page
      // التنقل لصفحة تفاصيل المسار
      context.push('/paths/$siteId');
    } else {
      print('⚠️ Site ID is missing, navigating to paths list');
      context.push('/paths');
    }
  }

  /// Handle trip accepted notification
  /// التعامل مع إشعار الموافقة على رحلة
  void _handleTripAcceptedNotification(
    Map<String, dynamic> data,
    BuildContext context,
  ) {
    final tripId = data['trip_id'] as String?;
    final tripName = data['trip_name'] as String?;

    print('✈️ Trip accepted notification:');
    print('   Trip ID: $tripId');
    print('   Trip Name: $tripName');

    // TODO: Add trip details route when available
    // يمكن إضافة مسار لصفحة تفاصيل الرحلة عندما يكون متاحاً
    // For now, navigate to home or paths
    // حالياً، التنقل للصفحة الرئيسية أو المسارات
    if (tripId != null && tripId.isNotEmpty) {
      // When trip route is available, use: context.push('/trip/$tripId');
      // عندما يكون مسار الرحلة متاحاً، استخدم: context.push('/trip/$tripId');
      print('ℹ️ Trip route not yet implemented, navigating to home');
      context.go('/');
    } else {
      print('⚠️ Trip ID is missing, navigating to home');
      context.go('/');
    }
  }

  /// Send FCM Token to Backend
  /// إرسال FCM Token للـ Backend
  Future<void> sendTokenToBackend() async {
    if (_fcmToken == null || _fcmToken!.isEmpty) {
      await _getFCMToken();
    }
    
    if (_fcmToken != null && _fcmToken!.isNotEmpty) {
      await _sendTokenToBackend(_fcmToken!);
    } else {
      print('⚠️ FCM Token is null or empty, cannot send to backend');
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      print('📤 Sending FCM Token to backend: ${token.substring(0, 20)}...');
      
      final response = await _apiService.post(
        '/notifications/update-token',
        {'fcm_token': token},
        requiresAuth: true,
      );

      print('✅ FCM Token sent successfully: $response');
    } catch (e) {
      print('❌ Error sending FCM Token to backend: $e');
      // Retry logic can be added here
      // يمكن إضافة منطق إعادة المحاولة هنا
      // For now, we'll just log the error
      // حالياً، سنكتفي بتسجيل الخطأ
    }
  }

  /// Delete FCM Token (when user logs out)
  /// حذف FCM Token (عند تسجيل الخروج)
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      print('✅ FCM Token deleted');
    } catch (e) {
      print('❌ Error deleting FCM Token: $e');
    }
  }
}

