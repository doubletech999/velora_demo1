# إعدادات Laravel للعمل مع Flutter

## المشكلة الحالية
التطبيق Flutter لا يستطيع الاتصال بالسيرفر Laravel بسبب إعدادات غير صحيحة.

## الحلول المطلوبة

### 1. تحديث ملف `.env` في Laravel

أضف `10.0.2.2` إلى `SANCTUM_STATEFUL_DOMAINS`:

```env
SANCTUM_STATEFUL_DOMAINS=localhost,127.0.0.1,10.0.2.2
```

**ملاحظة:** `10.0.2.2` هو العنوان الخاص الذي يستخدمه Android Emulator للوصول إلى `localhost` على جهازك.

---

### 2. تشغيل السيرفر على جميع الواجهات

**❌ خطأ:**
```bash
php artisan serve
```

**✅ صحيح:**
```bash
php artisan serve --host=0.0.0.0 --port=8000
```

هذا يجعل السيرفر يستمع على جميع الواجهات وليس فقط `localhost`.

---

### 3. التحقق من إعدادات CORS

افتح ملف `config/cors.php` وتأكد من:

```php
'paths' => ['api/*', 'sanctum/csrf-cookie'],

'allowed_methods' => ['*'],

'allowed_origins' => ['*'], // للتطوير المحلي

'allowed_origins_patterns' => [],

'allowed_headers' => ['*'],

'exposed_headers' => [],

'max_age' => 0,

'supports_credentials' => true, // مهم للـ Sanctum
```

---

### 4. التحقق من إعدادات Sanctum

افتح ملف `config/sanctum.php` وتأكد من:

```php
'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', sprintf(
    '%s%s',
    'localhost,localhost:3000,127.0.0.1,127.0.0.1:8000,::1',
    Sanctum::currentApplicationUrlWithPort()
))),
```

---

### 5. إضافة Middleware للـ API Routes

تأكد من أن ملف `routes/api.php` يحتوي على:

```php
Route::middleware(['api'])->group(function () {
    // Routes here
});
```

---

### 6. اختبار الاتصال

#### من المتصفح (اختبار السيرفر):
افتح المتصفح واذهب إلى:
```
http://localhost:8000/api/register
```

#### من Android Emulator:
يجب أن يعمل التطبيق Flutter الآن مع:
```
http://10.0.2.2:8000/api
```

---

## ملخص التغييرات المطلوبة

1. ✅ تحديث `.env`:
   ```env
   SANCTUM_STATEFUL_DOMAINS=localhost,127.0.0.1,10.0.2.2
   ```

2. ✅ تشغيل السيرفر:
   ```bash
   php artisan serve --host=0.0.0.0 --port=8000
   ```

3. ✅ التحقق من `config/cors.php` و `config/sanctum.php`

4. ✅ إعادة تشغيل السيرفر بعد التغييرات

---

## للجهاز الحقيقي (Real Device)

إذا كنت تستخدم جهاز حقيقي بدلاً من المحاكي:

1. اعرف IP جهازك:
   - Windows: `ipconfig` (ابحث عن IPv4 Address)
   - Mac/Linux: `ifconfig` أو `ip addr`

2. حدّث `.env`:
   ```env
   SANCTUM_STATEFUL_DOMAINS=localhost,127.0.0.1,10.0.2.2,192.168.1.100
   ```
   (استبدل `192.168.1.100` بـ IP جهازك)

3. حدّث `lib/data/services/api_service.dart`:
   ```dart
   final String baseUrl = 'http://192.168.1.100:8000/api'; // استبدل 100 بـ IP جهازك
   ```

4. تأكد أن الجهاز والتطبيق على نفس الشبكة WiFi

---

## استكشاف الأخطاء

### الخطأ: "Failed to fetch"
- ✅ تأكد أن السيرفر يعمل: `php artisan serve --host=0.0.0.0 --port=8000`
- ✅ تأكد من إضافة `10.0.2.2` إلى `SANCTUM_STATEFUL_DOMAINS`
- ✅ تأكد من إعدادات CORS

### الخطأ: "CORS policy"
- ✅ تحقق من `config/cors.php`
- ✅ تأكد من `'allowed_origins' => ['*']` للتطوير

### الخطأ: "401 Unauthorized"
- ✅ تحقق من إرسال Token في Header
- ✅ تأكد من أن Token صحيح

---

## نصائح إضافية

1. **استخدم `php artisan config:clear`** بعد تغيير `.env`
2. **استخدم `php artisan cache:clear`** إذا استمرت المشاكل
3. **راقب logs Laravel** في `storage/logs/laravel.log`
4. **استخدم Postman** لاختبار API قبل استخدام Flutter



