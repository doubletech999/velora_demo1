# إعداد الاتصال بالأجهزة الحقيقية

## 📱 استخدام IP محلي للاتصال من هاتف على نفس الشبكة

### المشكلة:
عند استخدام هاتف حقيقي (Real Device) على نفس الشبكة، لا يمكن استخدام `localhost` أو `10.0.2.2` للاتصال بـ Laravel API.

### الحل:
استخدام IP المحلي لجهاز الكمبيوتر (مثل `192.168.88.4`) للاتصال من الهاتف.

---

## 🔧 خطوات الإعداد

### 1. معرفة IP جهاز الكمبيوتر

#### على Windows:
```powershell
ipconfig
```
ابحث عن `IPv4 Address` تحت `Wireless LAN adapter Wi-Fi` أو `Ethernet adapter`.

مثال: `192.168.88.4`

#### على macOS/Linux:
```bash
ifconfig
# أو
ip addr
```

---

### 2. تشغيل Laravel Server على 0.0.0.0

**مهم جداً:** يجب تشغيل السيرفر على `0.0.0.0` وليس `localhost` فقط.

```bash
cd path/to/velora_backend-main
php artisan serve --host=0.0.0.0 --port=8000
```

يجب أن ترى:
```
INFO Server running on [http://0.0.0.0:8000].
```

---

### 3. تعيين IP المخصص في Flutter

#### الطريقة 1: من الكود (موصى به للاختبار)

افتح `lib/data/services/api_service.dart` وأضف في `main.dart`:

```dart
import 'data/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تعيين IP مخصص للأجهزة الحقيقية
  final apiService = ApiService();
  await apiService.setCustomBaseUrl('http://192.168.88.4:8000/api');
  
  // ... باقي الكود
}
```

#### الطريقة 2: حفظ دائم (من SharedPreferences)

سيتم حفظ IP المخصص تلقائياً عند استخدام `setCustomBaseUrl()`.

---

### 4. إزالة IP المخصص (للرجوع للقيم الافتراضية)

```dart
final apiService = ApiService();
await apiService.setCustomBaseUrl(null);
```

---

## 📋 مثال كامل في `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/services/api_service.dart';
import 'data/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تعيين IP مخصص للأجهزة الحقيقية
  // ⚠️ غير 192.168.88.4 إلى IP جهازك
  final apiService = ApiService();
  await apiService.setCustomBaseUrl('http://192.168.88.4:8000/api');
  
  // تهيئة المصادقة (يحمّل Token و Custom Base URL)
  await AuthService.instance.initialize();
  
  runApp(MyApp());
}
```

---

## 🧪 اختبار الاتصال

### 1. من الهاتف:
- افتح المتصفح على الهاتف
- اذهب إلى: `http://192.168.88.4:8000/api/sites`
- يجب أن ترى استجابة JSON

### 2. من Flutter App:
- شغّل التطبيق على الهاتف
- راقب Console Logs - يجب أن ترى:
  ```
  ✅ تم تحميل Base URL المخصص: http://192.168.88.4:8000/api
  ```

---

## ⚠️ ملاحظات مهمة

### 1. Firewall
تأكد من أن Firewall يسمح بالاتصال على Port 8000:
- Windows: افتح `Windows Defender Firewall` → `Allow an app`
- أضف `php` أو Port `8000`

### 2. CORS
إذا كنت تواجه مشاكل CORS في Flutter Web:
- تأكد من إعدادات CORS في Laravel
- أضف IP الهاتف إلى `SANCTUM_STATEFUL_DOMAINS` في `.env`

### 3. IP يتغير
⚠️ إذا تغير IP جهازك، يجب تحديث IP في الكود أو إعادة تعيينه.

### 4. نفس الشبكة
⚠️ تأكد من أن الهاتف والكمبيوتر على نفس الشبكة Wi-Fi.

---

## 🔄 استكشاف الأخطاء

### المشكلة: "Connection refused" أو "Failed to connect"

**الحل:**
1. تأكد أن Laravel Server يعمل على `0.0.0.0:8000`
2. تأكد من IP الصحيح (`ipconfig` على Windows)
3. تأكد من Firewall
4. تأكد أن الهاتف والكمبيوتر على نفس الشبكة

### المشكلة: "Timeout"

**الحل:**
1. تحقق من سرعة الشبكة
2. تأكد أن Laravel Server يعمل بشكل صحيح
3. جرب Ping من الهاتف: `ping 192.168.88.4`

### المشكلة: "CORS error" (في Flutter Web)

**الحل:**
1. في Laravel `.env`:
   ```env
   SANCTUM_STATEFUL_DOMAINS=localhost,127.0.0.1,192.168.88.4
   ```
2. في `config/cors.php`:
   ```php
   'allowed_origins' => ['*'],
   'allowed_origins_patterns' => [],
   'allowed_headers' => ['*'],
   ```

---

## 📝 ملخص

1. ✅ اعرف IP جهازك (`ipconfig`)
2. ✅ شغّل Laravel: `php artisan serve --host=0.0.0.0 --port=8000`
3. ✅ عيّن IP في Flutter: `apiService.setCustomBaseUrl('http://192.168.88.4:8000/api')`
4. ✅ اختبر الاتصال من الهاتف
5. ✅ شغّل التطبيق على الهاتف

---

## 🎯 مثال سريع

```dart
// في main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ⚠️ غير 192.168.88.4 إلى IP جهازك
  final apiService = ApiService();
  await apiService.setCustomBaseUrl('http://192.168.88.4:8000/api');
  
  await AuthService.instance.initialize();
  
  runApp(MyApp());
}
```

---

## 📞 دعم

إذا واجهت مشاكل:
1. تحقق من Console Logs في Flutter
2. تحقق من Laravel Logs: `storage/logs/laravel.log`
3. تأكد من إعدادات Firewall و CORS

