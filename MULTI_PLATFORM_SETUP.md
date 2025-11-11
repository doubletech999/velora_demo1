# إعداد التطبيق للعمل على جميع المنصات

## 📱 المنصات المدعومة

التطبيق الآن يدعم العمل على:
1. ✅ **Flutter Web** - المتصفح
2. ✅ **Android Emulator** - محاكي Android
3. ✅ **iOS Simulator** - محاكي iOS
4. ✅ **Real Device** - الأجهزة الحقيقية (Android/iOS)

## 🔧 كيفية العمل

### 1. اكتشاف البيئة التلقائي

`ApiService` يكتشف البيئة تلقائياً ويختار العنوان المناسب:

```dart
String get baseUrl {
  // إذا كان هناك IP مخصص (للاستخدام مع الأجهزة الحقيقية فقط)
  if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
    return _customBaseUrl!;
  }

  // القيم الافتراضية حسب البيئة
  if (kIsWeb) {
    return 'http://localhost:8000/api'; // Flutter Web
  } else {
    return 'http://10.0.2.2:8000/api'; // Android Emulator / iOS Simulator
  }
}
```

### 2. العناوين الافتراضية

| المنصة | العنوان الافتراضي | الشرح |
|--------|-------------------|-------|
| **Flutter Web** | `http://localhost:8000/api` | يعمل مباشرة مع المتصفح |
| **Android Emulator** | `http://10.0.2.2:8000/api` | `10.0.2.2` هو localhost الخاص بالمحاكي |
| **iOS Simulator** | `http://10.0.2.2:8000/api` | نفس Android (يمكن تغييره إلى `127.0.0.1`) |
| **Real Device** | يحتاج `setCustomBaseUrl()` | يجب تعيين IP جهاز الكمبيوتر |

## 🚀 الاستخدام

### للمتصفح والمحاكي (افتراضي)

**لا تحتاج إلى أي إعدادات إضافية!** التطبيق سيعمل تلقائياً:

```dart
// في main.dart - لا حاجة لأي كود إضافي
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConnectivityService().initialize();
  await AuthService.instance.initialize(); // ✅ هذا يكفي
  runApp(MyApp());
}
```

### للأجهزة الحقيقية

إذا كنت تريد استخدام جهاز حقيقي على نفس الشبكة:

```dart
// في main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConnectivityService().initialize();
  
  // ✅ تعيين IP للأجهزة الحقيقية فقط
  final apiService = ApiService.instance;
  await apiService.setCustomBaseUrl('http://192.168.88.4:8000/api');
  
  await AuthService.instance.initialize();
  runApp(MyApp());
}
```

## 📋 خطوات التشغيل

### 1. تشغيل Laravel Server

```bash
# في جميع الحالات، يجب تشغيل السيرفر على 0.0.0.0
php artisan serve --host=0.0.0.0 --port=8000
```

### 2. تشغيل التطبيق

#### Flutter Web:
```bash
flutter run -d chrome
# أو
flutter run -d web-server
```

#### Android Emulator:
```bash
flutter run -d emulator
# أو اختر المحاكي من القائمة
flutter run
```

#### iOS Simulator:
```bash
flutter run -d ios
# أو
open -a Simulator
flutter run
```

#### Real Device:
```bash
# 1. أولاً: أزل التعليق عن setCustomBaseUrl في main.dart
# 2. ثم شغّل:
flutter run -d <device-id>
```

## ⚠️ ملاحظات مهمة

### 1. IP محفوظ في SharedPreferences

إذا قمت بتعيين IP مخصص للأجهزة الحقيقية، سيتم حفظه في `SharedPreferences`. هذا يعني:
- ✅ سيعمل على الجهاز الحقيقي حتى بعد إعادة التشغيل
- ⚠️ **لكن** سيعمل أيضاً على Web/Emulator حتى لو غيرت المنصة!

**الحل**: عند التبديل بين المنصات، احذف IP المحفوظ:

```dart
// في main.dart - للأجهزة الحقيقية فقط
final apiService = ApiService.instance;

// للأجهزة الحقيقية: عيّن IP
if (/* جهاز حقيقي */) {
  await apiService.setCustomBaseUrl('http://192.168.88.4:8000/api');
} else {
  // للمتصفح/المحاكي: احذف IP المحفوظ
  await apiService.setCustomBaseUrl(null);
}
```

### 2. اكتشاف المنصة تلقائياً

يمكنك اكتشاف المنصة برمجياً:

```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

bool get isRealDevice {
  if (kIsWeb) return false; // Web
  // للـ Mobile: إذا لم يكن emulator أو simulator
  // يمكنك استخدام package:device_info_plus
  return true; // Real Device (مثال)
}
```

### 3. Laravel Server

⚠️ **مهم جداً**: يجب أن يعمل السيرفر على `0.0.0.0` وليس `localhost` فقط:

```bash
# ✅ صحيح
php artisan serve --host=0.0.0.0 --port=8000

# ❌ خطأ (لن يعمل مع الأجهزة الحقيقية)
php artisan serve --host=localhost --port=8000
```

## 🧪 الاختبار

### اختبار Web:
1. شغّل Laravel: `php artisan serve --host=0.0.0.0 --port=8000`
2. شغّل Flutter: `flutter run -d chrome`
3. افتح المتصفح: يجب أن يعمل على `http://localhost:8000/api`

### اختبار Android Emulator:
1. شغّل Laravel: `php artisan serve --host=0.0.0.0 --port=8000`
2. شغّل Android Emulator
3. شغّل Flutter: `flutter run`
4. يجب أن يعمل على `http://10.0.2.2:8000/api`

### اختبار Real Device:
1. شغّل Laravel: `php artisan serve --host=0.0.0.0 --port=8000`
2. اعرف IP جهازك: `ipconfig` (Windows) أو `ifconfig` (Linux/Mac)
3. في `main.dart`: أزل التعليق عن `setCustomBaseUrl()` وعدّل IP
4. شغّل Flutter على الجهاز الحقيقي
5. يجب أن يعمل على `http://<your-ip>:8000/api`

## 📝 مثال كامل

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConnectivityService().initialize();
  
  // ✅ اكتشاف البيئة تلقائياً:
  // - Web: localhost
  // - Emulator: 10.0.2.2
  // - Real Device: يحتاج setCustomBaseUrl()
  
  // ⚠️ للأجهزة الحقيقية فقط: أزل التعليق وعدّل IP
  // final apiService = ApiService.instance;
  // await apiService.setCustomBaseUrl('http://192.168.88.4:8000/api');
  
  await AuthService.instance.initialize();
  runApp(MyApp());
}
```

## ✅ التحقق من النجاح

عند تشغيل التطبيق، يجب أن ترى في Console:

### Web:
```
🌐 ApiService.baseUrl: http://localhost:8000/api (Web)
```

### Emulator:
```
🌐 ApiService.baseUrl: http://10.0.2.2:8000/api (Mobile - Emulator/Simulator)
💡 للجهاز الحقيقي: استخدم setCustomBaseUrl() في main.dart
```

### Real Device:
```
🌐 ApiService.baseUrl: http://192.168.88.4:8000/api (مخصص - جهاز حقيقي)
```

## 🔄 التبديل بين المنصات

### من Real Device إلى Web/Emulator:

1. **احذف IP المحفوظ:**
   ```dart
   final apiService = ApiService.instance;
   await apiService.setCustomBaseUrl(null);
   ```

2. **أعد تشغيل التطبيق**

### من Web/Emulator إلى Real Device:

1. **عيّن IP:**
   ```dart
   final apiService = ApiService.instance;
   await apiService.setCustomBaseUrl('http://192.168.88.4:8000/api');
   ```

2. **أعد تشغيل التطبيق**

## 🎯 الخلاصة

- ✅ **Web/Emulator**: يعمل تلقائياً بدون أي إعدادات
- ✅ **Real Device**: يحتاج فقط إلى `setCustomBaseUrl()` في `main.dart`
- ✅ **اكتشاف تلقائي**: التطبيق يكتشف البيئة ويختار العنوان المناسب
- ✅ **مرونة**: يمكن التبديل بسهولة بين المنصات

