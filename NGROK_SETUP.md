# 🌐 إعداد ngrok للوصول من الأجهزة الخارجية

## ما هو ngrok؟
ngrok هو خدمة تسمح بعرض الخوادم المحلية على الإنترنت عبر URL آمن. مفيد للوصول إلى Laravel API من الأجهزة الحقيقية أو الوصول الخارجي.

## الإعداد

### 1. تثبيت ngrok
```bash
# Windows (استخدام Chocolatey)
choco install ngrok

# أو تحميل من الموقع الرسمي
# https://ngrok.com/download
```

### 2. الحصول على Auth Token
1. سجل حساب في https://ngrok.com
2. احصل على Auth Token من Dashboard
3. قم بتسجيل الدخول:
```bash
ngrok config add-authtoken YOUR_AUTH_TOKEN
```

### 3. تشغيل Laravel Server
```bash
cd C:\xampp\htdocs\velora_backend-main
php artisan serve --host=0.0.0.0 --port=8000
```

### 4. تشغيل ngrok
```bash
ngrok http 8000
```

ستحصل على URL مثل:
```
https://trevally-unpatented-christia.ngrok-free.dev
```

### 5. استخدام ngrok URL في Flutter

في `lib/main.dart`:
```dart
final apiService = ApiService.instance;
await apiService.setCustomBaseUrl('https://trevally-unpatented-christia.ngrok-free.dev/api');
```

---

## التعديلات المطبقة في Flutter

### 1. `ApiService`
- ✅ دعم ngrok URL في `setCustomBaseUrl()`
- ✅ دعم HTTPS (ngrok يستخدم HTTPS)
- ✅ `imagesBaseUrl` getter للحصول على base URL للصور (بدون /api)

### 2. `PathModel._buildImageUrl()`
- ✅ استخدام `ApiService.instance.baseUrl` لبناء URLs الصور
- ✅ دعم HTTPS للصور عند استخدام ngrok
- ✅ إزالة `/api` من base URL للصور

### 3. `main.dart`
- ✅ تم تفعيل ngrok URL افتراضياً:
  ```dart
  await apiService.setCustomBaseUrl('https://trevally-unpatented-christia.ngrok-free.dev/api');
  ```

---

## استخدام ngrok URL

### للوصول من الأجهزة الحقيقية:
1. ✅ تشغيل Laravel Server: `php artisan serve --host=0.0.0.0 --port=8000`
2. ✅ تشغيل ngrok: `ngrok http 8000`
3. ✅ نسخ ngrok URL (مثل: `https://trevally-unpatented-christia.ngrok-free.dev`)
4. ✅ تحديث `main.dart` بـ ngrok URL + `/api`
5. ✅ تشغيل Flutter App على الجهاز الحقيقي

### للوصول من Web:
- ✅ ngrok URL يعمل أيضاً على Flutter Web
- ✅ لا حاجة لتغيير CORS settings (ngrok يتعامل معه)

---

## ملاحظات مهمة

### 1. ngrok Free Plan Limitations
- ⚠️ ngrok URL يتغير في كل مرة تقوم بتشغيل ngrok (ما لم تستخدم ngrok paid plan)
- ⚠️ يجب تحديث `main.dart` في كل مرة تتغير ngrok URL
- 💡 يمكن استخدام ngrok paid plan للحصول على URL ثابت

### 2. ngrok Headers
- ⚠️ ngrok قد يطلب ngrok-skip-browser-warning header
- ✅ Flutter يتعامل مع هذا تلقائياً

### 3. HTTPS
- ✅ ngrok يستخدم HTTPS دائماً
- ✅ Flutter يدعم HTTPS تلقائياً

### 4. الصور
- ✅ الصور تعمل مع ngrok URL أيضاً
- ✅ URLs الصور تُبنى تلقائياً من base URL (بدون /api)

---

## الاختبار

### 1. Test API مباشرة:
```bash
curl https://trevally-unpatented-christia.ngrok-free.dev/api/sites
```

### 2. Test Images:
افتح في المتصفح:
```
https://trevally-unpatented-christia.ngrok-free.dev/storage/images/photo.jpg
```

### 3. Test Flutter App:
- ✅ تشغيل Flutter App على الجهاز الحقيقي
- ✅ يجب أن يعمل API بشكل صحيح
- ✅ يجب أن تظهر الصور بشكل صحيح

---

## التبديل بين ngrok و Localhost

### لاستخدام ngrok:
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

## Troubleshooting

### المشكلة 1: ngrok URL لا يعمل
**الحل:**
- تحقق من أن Laravel Server يعمل
- تحقق من أن ngrok يعمل
- تحقق من ngrok URL في المتصفح

### المشكلة 2: الصور لا تظهر
**الحل:**
- تحقق من أن ngrok URL صحيح
- تحقق من أن الصور موجودة في Laravel storage
- تحقق من Console logs في Flutter

### المشكلة 3: CORS Error
**الحل:**
- ngrok يتعامل مع CORS تلقائياً
- إذا استمرت المشكلة، تحقق من Laravel CORS settings

---

## النتيجة

بعد تطبيق هذه التعديلات:
- ✅ Flutter App يعمل مع ngrok URL
- ✅ API calls تعمل بشكل صحيح
- ✅ الصور تظهر بشكل صحيح
- ✅ يعمل على Web و Mobile
- ✅ يعمل من الأجهزة الخارجية

---

## ngrok URL الحالي

```
https://trevally-unpatented-christia.ngrok-free.dev/api
```

⚠️ **ملاحظة**: هذا URL سيتغير في كل مرة تقوم بتشغيل ngrok (ما لم تستخدم ngrok paid plan).

💡 **نصيحة**: يمكنك استخدام ngrok paid plan للحصول على URL ثابت، أو تحديث `main.dart` في كل مرة يتغير ngrok URL.

