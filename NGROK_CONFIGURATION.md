# 🌐 إعداد ngrok للوصول من الأجهزة الخارجية

## ✅ التعديلات المطبقة

### 1. `ApiService`
- ✅ دعم ngrok URL في `setCustomBaseUrl()`
- ✅ دعم HTTPS (ngrok يستخدم HTTPS)
- ✅ إضافة `ngrok-skip-browser-warning` header تلقائياً
- ✅ `imagesBaseUrl` getter للحصول على base URL للصور (بدون /api)

### 2. `PathModel._buildImageUrl()`
- ✅ استخدام `ApiService.instance.baseUrl` لبناء URLs الصور
- ✅ دعم HTTPS للصور عند استخدام ngrok
- ✅ إزالة `/api` من base URL للصور تلقائياً

### 3. `main.dart`
- ✅ تم تفعيل ngrok URL افتراضياً:
  ```dart
  await apiService.setCustomBaseUrl('https://trevally-unpatented-christia.ngrok-free.dev/api');
  ```

---

## 🚀 الاستخدام

### ngrok URL الحالي:
```
https://trevally-unpatented-christia.ngrok-free.dev/api
```

### للصور:
```
https://trevally-unpatented-christia.ngrok-free.dev/storage/images/photo.jpg
```

---

## 📋 خطوات التشغيل

### 1. تشغيل Laravel Server:
```bash
cd C:\xampp\htdocs\velora_backend-main
php artisan serve --host=0.0.0.0 --port=8000
```

### 2. تشغيل ngrok:
```bash
ngrok http 8000
```

### 3. نسخ ngrok URL:
- افتح ngrok dashboard
- انسخ Forwarding URL (مثل: `https://trevally-unpatented-christia.ngrok-free.dev`)
- أضف `/api` في النهاية: `https://trevally-unpatented-christia.ngrok-free.dev/api`

### 4. تحديث `main.dart` (إن لزم الأمر):
```dart
await apiService.setCustomBaseUrl('https://trevally-unpatented-christia.ngrok-free.dev/api');
```

### 5. تشغيل Flutter App:
- ✅ يعمل على Web
- ✅ يعمل على Mobile (Emulator)
- ✅ يعمل على Mobile (Real Device)
- ✅ يعمل من الأجهزة الخارجية

---

## 🔍 الاختبار

### 1. Test API:
```bash
curl https://trevally-unpatented-christia.ngrok-free.dev/api/sites
```

### 2. Test Images:
افتح في المتصفح:
```
https://trevally-unpatented-christia.ngrok-free.dev/storage/images/photo.jpg
```

### 3. Test Flutter App:
- ✅ افتح Flutter App
- ✅ تحقق من Console logs
- ✅ يجب أن ترى: `🌐 ApiService.baseUrl: https://trevally-unpatented-christia.ngrok-free.dev/api (مخصص)`
- ✅ يجب أن تظهر البيانات والصور

---

## ⚠️ ملاحظات مهمة

### 1. ngrok URL يتغير
- ⚠️ ngrok Free Plan: URL يتغير في كل مرة تقوم بتشغيل ngrok
- ✅ يجب تحديث `main.dart` في كل مرة يتغير ngrok URL
- 💡 يمكن استخدام ngrok Paid Plan للحصول على URL ثابت

### 2. ngrok Headers
- ✅ Flutter يضيف `ngrok-skip-browser-warning` header تلقائياً
- ✅ لا حاجة لإضافة headers يدوياً

### 3. HTTPS
- ✅ ngrok يستخدم HTTPS دائماً
- ✅ Flutter يدعم HTTPS تلقائياً
- ✅ الصور تعمل مع HTTPS

### 4. CORS
- ✅ ngrok يتعامل مع CORS تلقائياً
- ✅ لا حاجة لتعديل CORS settings في Laravel

---

## 🔄 التبديل بين ngrok و Localhost

### لاستخدام ngrok (افتراضي):
```dart
await apiService.setCustomBaseUrl('https://trevally-unpatented-christia.ngrok-free.dev/api');
```

### لاستخدام localhost (للتطوير المحلي):
```dart
await apiService.setCustomBaseUrl(null); // سيستخدم القيمة الافتراضية
```

### لاستخدام IP محلي:
```dart
await apiService.setCustomBaseUrl('http://192.168.88.4:8000/api');
```

---

## 📱 الوصول من الأجهزة الخارجية

### الخطوات:
1. ✅ تشغيل Laravel Server على جهازك
2. ✅ تشغيل ngrok على جهازك
3. ✅ نسخ ngrok URL
4. ✅ تحديث `main.dart` بـ ngrok URL
5. ✅ تشغيل Flutter App على أي جهاز (حتى خارج الشبكة)

### المزايا:
- ✅ الوصول من أي مكان
- ✅ لا حاجة لنفس الشبكة
- ✅ HTTPS آمن
- ✅ يعمل على Web و Mobile

---

## 🐛 Troubleshooting

### المشكلة 1: ngrok URL لا يعمل
**الحل:**
- تحقق من أن Laravel Server يعمل
- تحقق من أن ngrok يعمل
- تحقق من ngrok URL في المتصفح
- تحقق من Console logs في Flutter

### المشكلة 2: الصور لا تظهر
**الحل:**
- تحقق من أن ngrok URL صحيح
- تحقق من أن الصور موجودة في Laravel storage
- تحقق من Console logs في Flutter
- تحقق من Network tab في Browser

### المشكلة 3: CORS Error
**الحل:**
- ngrok يتعامل مع CORS تلقائياً
- إذا استمرت المشكلة، تحقق من Laravel CORS settings

### المشكلة 4: ngrok-skip-browser-warning
**الحل:**
- ✅ Flutter يضيف هذا header تلقائياً
- ✅ لا حاجة لإضافته يدوياً

---

## ✅ النتيجة

بعد تطبيق هذه التعديلات:
- ✅ Flutter App يعمل مع ngrok URL
- ✅ API calls تعمل بشكل صحيح
- ✅ الصور تظهر بشكل صحيح
- ✅ يعمل على Web و Mobile
- ✅ يعمل من الأجهزة الخارجية
- ✅ HTTPS آمن
- ✅ لا حاجة لنفس الشبكة

---

## 📞 ngrok URL الحالي

```
https://trevally-unpatented-christia.ngrok-free.dev/api
```

⚠️ **ملاحظة**: هذا URL سيتغير في كل مرة تقوم بتشغيل ngrok (ما لم تستخدم ngrok paid plan).

💡 **نصيحة**: يمكنك استخدام ngrok paid plan للحصول على URL ثابت، أو تحديث `main.dart` في كل مرة يتغير ngrok URL.

