# إصلاح خطأ 401 Unauthenticated في Bookings

## 🔍 المشكلة

عند محاولة إرسال حجز، تحصل على خطأ `401 Unauthenticated` لأن:
1. المستخدم غير مسجل دخول (لا يوجد token)
2. Laravel Controller يتطلب authentication

---

## ✅ الحلول الممكنة

### الحل 1: تسجيل الدخول أولاً (موصى به)

**في Flutter:**
- اطلب من المستخدم تسجيل الدخول قبل الحجز
- أو سجل دخول تلقائياً كـ "Guest User"

### الحل 2: تعديل Laravel Controller لقبول الحجوزات بدون authentication

**في Laravel `BookingController.php`:**

```php
public function store(Request $request)
{
    // الحصول على user_id
    $userId = auth()->id();
    
    // إذا لم يكن هناك user مصادق عليه (ضيف)
    if (!$userId) {
        // خيار 1: استخدام user افتراضي
        $userId = 1; // ⚠️ تأكد من وجود user برقم 1
        
        // خيار 2: إنشاء user مؤقت
        // $user = User::create([
        //     'name' => 'Guest ' . time(),
        //     'email' => 'guest_' . time() . '@velora.com',
        //     'password' => bcrypt('password'),
        //     'role' => 'guest'
        // ]);
        // $userId = $user->id;
    }
    
    // إنشاء الحجز
    $booking = Booking::create([
        'user_id' => $userId,
        'guide_id' => $request->guide_id,
        'booking_date' => $request->booking_date,
        'start_time' => $request->start_time,
        'end_time' => $request->end_time,
        'total_price' => $request->total_price ?? 0.00,
        'status' => 'pending',
        'notes' => $request->notes,
    ]);
    
    return response()->json([
        'status' => 'success',
        'message' => 'تم إنشاء الحجز بنجاح',
        'data' => $booking
    ], 201);
}
```

### الحل 3: إزالة middleware authentication من Route

**في `routes/api.php`:**

```php
// للسماح بالحجوزات بدون authentication
Route::post('/bookings', [BookingController::class, 'store']);

// أو استخدام middleware اختياري
Route::post('/bookings', [BookingController::class, 'store'])->middleware('optional_auth');
```

---

## 🔧 إصلاح Flutter Code

تم إصلاح مشكلة تحميل Token - الآن يستخدم نفس المفتاح `'user_token'`.

### التحقق من Token:

```dart
// في trip_registration_provider.dart
final hasToken = await _authService.hasToken();
if (!hasToken) {
  print('⚠️ المستخدم غير مسجل دخول');
  // يمكنك إما:
  // 1. طلب تسجيل الدخول
  // 2. أو المتابعة (Laravel سيتعامل معه)
}
```

---

## 📋 خطوات الإصلاح السريع

### 1. في Laravel:

**أضف إلى `BookingController.php`:**

```php
public function store(Request $request)
{
    $userId = auth()->id() ?? 1; // استخدام user 1 كافتراضي للضيوف
    
    $booking = Booking::create([
        'user_id' => $userId,
        'guide_id' => $request->guide_id,
        'booking_date' => $request->booking_date,
        'start_time' => $request->start_time,
        'end_time' => $request->end_time,
        'total_price' => $request->total_price ?? 0.00,
        'status' => 'pending',
        'notes' => $request->notes,
    ]);
    
    return response()->json([
        'status' => 'success',
        'data' => $booking
    ], 201);
}
```

### 2. في Routes:

**في `routes/api.php`:**

```php
// إزالة middleware auth:sanctum للسماح بالحجوزات بدون authentication
Route::post('/bookings', [BookingController::class, 'store']);
```

### 3. تأكد من وجود User برقم 1:

```php
php artisan tinker

User::firstOrCreate(
    ['email' => 'guest@velora.com'],
    [
        'name' => 'Guest User',
        'password' => bcrypt('password'),
        'role' => 'guest'
    ]
);
```

---

## ✅ بعد الإصلاح

1. **أعد تشغيل Laravel Server:**
   ```bash
   php artisan serve --host=0.0.0.0 --port=8000
   ```

2. **اختبر من Flutter:**
   - سجل رحلة جديدة
   - يجب أن تظهر في Laravel بدون خطأ 401

3. **تحقق من Laravel:**
   - افتح جدول `bookings` في phpMyAdmin
   - يجب أن ترى الحجز الجديد

---

## 🧪 اختبار API مباشرة

```bash
# بدون token (للمستخدمين الضيوف)
curl -X POST http://localhost:8000/api/bookings \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "guide_id": 2,
    "booking_date": "2025-11-06",
    "start_time": "08:26:39",
    "end_time": "10:26:39",
    "total_price": 15,
    "notes": "عدد المشاركين: 5"
  }'
```

يجب أن يعيد `201 Created` بدلاً من `401 Unauthenticated`.

---

## 📝 ملاحظات

- ✅ Flutter Code تم إصلاحه - يستخدم مفتاح Token الصحيح
- ⚠️ Laravel يحتاج إلى تعديل للسماح بالحجوزات بدون authentication
- 💡 الحل الأفضل: إما تسجيل الدخول أولاً، أو استخدام user افتراضي في Laravel


