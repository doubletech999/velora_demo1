# Firebase Cloud Messaging Integration Guide
# دليل تكامل Firebase Cloud Messaging

---

## Table of Contents / جدول المحتويات

- [Overview / نظرة عامة](#overview--نظرة-عامة)
- [Prerequisites / المتطلبات](#prerequisites--المتطلبات)
- [Setup Steps / خطوات الإعداد](#setup-steps--خطوات-الإعداد)
  - [Flutter Setup](#flutter-setup)
  - [Android Setup](#android-setup)
  - [iOS Setup](#ios-setup)
- [Implementation / التنفيذ](#implementation--التنفيذ)
  - [1. Initialize Firebase](#1-initialize-firebase)
  - [2. Get FCM Token](#2-get-fcm-token)
  - [3. Send Token to Backend](#3-send-token-to-backend)
  - [4. Handle Notifications](#4-handle-notifications)
- [Code Examples / أمثلة الكود](#code-examples--أمثلة-الكود)
- [Testing / الاختبار](#testing--الاختبار)
- [Troubleshooting / حل المشاكل](#troubleshooting--حل-المشاكل)

---

## Overview / نظرة عامة

This guide explains how to integrate Firebase Cloud Messaging (FCM) into your Flutter application to receive push notifications.

هذا الدليل يشرح كيفية تكامل Firebase Cloud Messaging (FCM) في تطبيق Flutter لاستقبال الإشعارات الفورية.

### Key Features / الميزات الرئيسية:
- ✅ Get FCM Token / الحصول على FCM Token
- ✅ Send Token to Backend / إرسال Token للـ Backend
- ✅ Handle Foreground Notifications / التعامل مع الإشعارات في المقدمة
- ✅ Handle Background Notifications / التعامل مع الإشعارات في الخلفية
- ✅ Handle Terminated App Notifications / التعامل مع الإشعارات عند إغلاق التطبيق
- ✅ Navigate to Specific Pages / التنقل للصفحات المناسبة

---

## Prerequisites / المتطلبات

### Required Packages / الحزم المطلوبة:

The following packages should already be in your `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.5.0
  firebase_messaging: ^15.0.0
```

### Firebase Configuration Files / ملفات إعداد Firebase:

- ✅ `android/app/google-services.json` (Already added / موجود)
- ✅ `ios/Runner/GoogleService-Info.plist` (Should be added / يجب إضافته)

---

## Setup Steps / خطوات الإعداد

### Flutter Setup

1. **Install Dependencies / تثبيت الحزم:**

```bash
flutter pub get
```

2. **Verify Firebase Configuration / التحقق من إعداد Firebase:**

Make sure `firebase_core` and `firebase_messaging` are in your `pubspec.yaml`.

تأكد من وجود `firebase_core` و `firebase_messaging` في `pubspec.yaml`.

### Android Setup

1. **Update `android/app/build.gradle.kts`:**

The file should already have the Google Services plugin. Verify it includes:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ✅ Should be present
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-messaging")
}
```

2. **Update `android/build.gradle.kts`:**

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

3. **Permissions in `AndroidManifest.xml`:**

Add these permissions in `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <!-- Internet permission -->
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <!-- FCM permissions -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    
    <application>
        <!-- ... -->
    </application>
</manifest>
```

### iOS Setup

1. **Add GoogleService-Info.plist:**

Download `GoogleService-Info.plist` from Firebase Console and add it to:
```
ios/Runner/GoogleService-Info.plist
```

2. **Update `ios/Runner/Info.plist`:**

Add notification permissions (if not already present):

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

3. **Enable Push Notifications in Xcode:**

- Open `ios/Runner.xcworkspace` in Xcode
- Select the Runner target
- Go to "Signing & Capabilities"
- Add "Push Notifications" capability
- Add "Background Modes" capability and enable "Remote notifications"

4. **Update `ios/Podfile`:**

Make sure the minimum iOS version is 12.0 or higher:

```ruby
platform :ios, '12.0'
```

Then run:

```bash
cd ios
pod install
cd ..
```

---

## Implementation / التنفيذ

### 1. Initialize Firebase

Create a new file: `lib/core/services/fcm_service.dart`

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../data/services/api_service.dart';

/// Top-level function to handle background messages
/// دالة على مستوى أعلى للتعامل مع الرسائل في الخلفية
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📱 Background message received: ${message.messageId}');
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
      // يمكنك عرض إشعار مخصص هنا
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
        _handleNotificationNavigation(message.data);
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
    
    if (notificationType == null) return;

    // You'll need to access your router/navigator here
    // ستحتاج للوصول إلى router/navigator هنا
    // Example implementation:
    /*
    final router = GoRouter.of(context);
    
    switch (notificationType) {
      case 'new_route_camping':
        final siteId = data['site_id'] as String?;
        final siteType = data['site_type'] as String?;
        if (siteId != null) {
          router.push('/site/$siteId');
        }
        break;
        
      case 'trip_accepted':
        final tripId = data['trip_id'] as String?;
        if (tripId != null) {
          router.push('/trip/$tripId');
        }
        break;
    }
    */
  }

  /// Send FCM Token to Backend
  /// إرسال FCM Token للـ Backend
  Future<void> sendTokenToBackend() async {
    if (_fcmToken == null || _fcmToken!.isEmpty) {
      await _getFCMToken();
    }
    
    if (_fcmToken != null && _fcmToken!.isNotEmpty) {
      await _sendTokenToBackend(_fcmToken!);
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      print('📤 Sending FCM Token to backend: $token');
      
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
    }
  }
}
```

### 2. Update `lib/main.dart`

Add FCM initialization in your `main()` function:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'core/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // تهيئة Firebase
  await Firebase.initializeApp();

  // Initialize FCM Service
  // تهيئة خدمة FCM
  await FCMService.instance.initialize();

  // ... rest of your initialization code
  // ... باقي كود التهيئة

  runApp(
    MultiProvider(
      providers: [
        // ... your providers
      ],
      child: const VeloraApp(),
    ),
  );
}
```

### 3. Send Token After Login

Update your login method in `lib/data/services/auth_service.dart`:

```dart
Future<AuthLoginResult> login({
  required String email,
  required String password,
  bool rememberMe = false,
}) async {
  try {
    // ... existing login code ...
    
    // After successful login, send FCM token
    // بعد تسجيل الدخول بنجاح، أرسل FCM token
    try {
      await FCMService.instance.sendTokenToBackend();
    } catch (e) {
      print('⚠️ Failed to send FCM token: $e');
      // Don't fail login if FCM token sending fails
      // لا تفشل عملية تسجيل الدخول إذا فشل إرسال FCM token
    }

    return AuthLoginResult(
      success: true,
      message: response['message']?.toString() ?? 'تم تسجيل الدخول بنجاح',
      token: token,
      user: user,
    );
  } catch (e) {
    // ... error handling ...
  }
}
```

### 4. Send Token on App Launch

You can also send the token when the app launches (if user is already logged in):

```dart
// In your app initialization or after checking if user is logged in
// في تهيئة التطبيق أو بعد التحقق من تسجيل الدخول
Future<void> initialize() async {
  // ... existing initialization ...
  
  // Check if user is logged in
  final isLoggedIn = await AuthService.instance.isLoggedIn();
  if (isLoggedIn) {
    // Send FCM token to backend
    await FCMService.instance.sendTokenToBackend();
  }
}
```

---

## Code Examples / أمثلة الكود

### Complete FCM Service Example

See the full implementation above in the [Implementation section](#implementation--التنفيذ).

### Navigation Handler Example

To properly handle navigation, you'll need to integrate with your routing system. Here's an example using `go_router`:

```dart
import 'package:go_router/go_router.dart';

class NotificationNavigationHandler {
  static void handleNotification(Map<String, dynamic> data, BuildContext context) {
    final notificationType = data['type'] as String?;
    
    if (notificationType == null) return;

    switch (notificationType) {
      case 'new_route_camping':
        final siteId = data['site_id'] as String?;
        final siteType = data['site_type'] as String?;
        final siteName = data['site_name'] as String?;
        
        if (siteId != null) {
          context.push('/site/$siteId');
        }
        break;
        
      case 'trip_accepted':
        final tripId = data['trip_id'] as String?;
        final tripName = data['trip_name'] as String?;
        
        if (tripId != null) {
          context.push('/trip/$tripId');
        }
        break;
        
      default:
        print('Unknown notification type: $notificationType');
    }
  }
}
```

Then update `_handleNotificationNavigation` in `FCMService`:

```dart
void _handleNotificationNavigation(Map<String, dynamic> data) {
  // You'll need to pass context or use a global navigator key
  // ستحتاج لتمرير context أو استخدام global navigator key
  // Example with global navigator key:
  final context = navigatorKey.currentContext;
  if (context != null) {
    NotificationNavigationHandler.handleNotification(data, context);
  }
}
```

---

## Testing / الاختبار

### Test FCM Token Retrieval

1. Run your app
2. Check console logs for: `✅ FCM Token: ...`
3. Verify token is sent to backend: Check API logs

### Test Notifications

1. **Foreground Test:**
   - Keep app open
   - Send test notification from Firebase Console
   - Check console logs

2. **Background Test:**
   - Put app in background
   - Send test notification
   - Tap notification
   - Verify navigation works

3. **Terminated Test:**
   - Close app completely
   - Send test notification
   - Tap notification
   - Verify app opens and navigates correctly

### Test Notification Payload

Use this payload structure when testing:

```json
{
  "notification": {
    "title": "Test Notification",
    "body": "This is a test notification"
  },
  "data": {
    "type": "new_route_camping",
    "site_id": "123",
    "site_type": "camping",
    "site_name": "Test Site"
  }
}
```

---

## Troubleshooting / حل المشاكل

### Common Issues / المشاكل الشائعة

1. **Token is null:**
   - Check Firebase configuration files
   - Verify permissions are granted
   - Check internet connection

2. **Notifications not received:**
   - Verify FCM token is sent to backend
   - Check notification payload structure
   - Verify app has notification permissions

3. **Navigation not working:**
   - Ensure router/navigator is properly set up
   - Check notification data structure
   - Verify notification type matches expected values

4. **iOS-specific issues:**
   - Ensure APNs certificates are configured in Firebase
   - Verify Push Notifications capability is enabled
   - Check `GoogleService-Info.plist` is in correct location

5. **Android-specific issues:**
   - Verify `google-services.json` is in `android/app/`
   - Check Google Services plugin is applied
   - Ensure minimum SDK version is 21+

### Debug Tips / نصائح التصحيح

- Enable verbose logging in Firebase
- Check device logs: `flutter logs`
- Test with Firebase Console first
- Verify backend endpoint is working with Postman/curl

---

## Next Steps / الخطوات التالية

1. ✅ Implement FCM Service
2. ✅ Integrate with login flow
3. ✅ Add navigation handlers
4. ✅ Test all notification scenarios
5. ✅ Handle edge cases (token refresh, network errors, etc.)

---

## Support / الدعم

For more information, refer to:
- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire Documentation](https://firebase.flutter.dev/docs/messaging/overview)

---

**Last Updated / آخر تحديث:** 2024

