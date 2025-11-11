# إصلاح مشكلة الاتصال بالأجهزة الحقيقية

## 🔍 المشكلة

`ApiService` ليس Singleton - كل class ينشئ instance جديد، لذلك عندما نعين Base URL في `main.dart`، الـ instances الأخرى لا تعرف عنه.

## ✅ الحل

### 1. جعل `ApiService` Singleton

في `lib/data/services/api_service.dart`، استبدل:

```dart
class ApiService {
  // IP مخصص للأجهزة الحقيقية
  String? _customBaseUrl;
```

بـ:

```dart
class ApiService {
  // ═══════════════════════════════════════════════════════════════════
  // Singleton Pattern
  // ═══════════════════════════════════════════════════════════════════
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._internal();
  factory ApiService() => instance;
  ApiService._internal() {
    print('🔧 ApiService: تم إنشاء instance (Singleton)');
  }

  // IP مخصص للأجهزة الحقيقية
  String? _customBaseUrl;
```

### 2. تحديث `main.dart`

في `lib/main.dart`، أزل التعليق وعدّل IP:

```dart
// Initialize connectivity service
await ConnectivityService().initialize();

// ✅ تعيين Base URL للأجهزة الحقيقية
final apiService = ApiService.instance;
await apiService.setCustomBaseUrl('http://192.168.88.4:8000/api');

// Initialize authentication service
await AuthService.instance.initialize();
```

### 3. التأكد من أن Laravel Server يعمل

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

### 4. معرفة IP جهازك

في Windows:
```powershell
ipconfig
```

في Linux/Mac:
```bash
ifconfig
```

ابحث عن `IPv4 Address` (مثل `192.168.88.4`).

## 🧪 اختبار

1. شغّل Laravel Server على `0.0.0.0:8000`
2. شغّل التطبيق على الهاتف
3. راقب Console Logs - يجب أن ترى:
   ```
   ✅ ApiService: تم حفظ Base URL المخصص: http://192.168.88.4:8000/api
   🌐 ApiService.baseUrl: http://192.168.88.4:8000/api (مخصص)
   ```

## ⚠️ ملاحظات

1. تأكد من أن الهاتف والكمبيوتر على نفس الشبكة Wi-Fi
2. تأكد من Firewall يسمح بالاتصال على Port 8000
3. إذا غيرت IP الكمبيوتر، عدّل IP في `main.dart`

