# تكامل تسجيل الرحلات مع Laravel Bookings

## ✅ ما تم إنجازه

تم ربط تسجيل الرحلات في التطبيق مع جدول `bookings` في Laravel.

---

## 📋 البيانات المرسلة إلى Laravel

عند تسجيل رحلة جديدة، يتم إرسال البيانات التالية إلى Laravel:

```json
{
  "guide_id": 1,
  "booking_date": "2025-11-07",
  "start_time": "09:00:00",
  "end_time": "13:00:00",
  "total_price": 250.0,
  "notes": "ملاحظات المستخدم\n\nعدد المشاركين: 2\nطريقة الدفع: نقدي"
}
```

### الحقول:

- ✅ **`guide_id`**: رقم المرشد (من `path.guideId`)
- ✅ **`booking_date`**: تاريخ الحجز (تاريخ اليوم - YYYY-MM-DD)
- ✅ **`start_time`**: وقت البداية (9 صباحاً - HH:MM:SS)
- ✅ **`end_time`**: وقت النهاية (حسب مدة المسار - HH:MM:SS)
- ✅ **`total_price`**: السعر الإجمالي (من `trip.totalPrice`)
- ✅ **`notes`**: الملاحظات (تشمل ملاحظات المستخدم + عدد المشاركين + طريقة الدفع)

---

## 🔧 التغييرات في الكود

### 1. `TripRegistrationProvider.registerTrip()`:
- ✅ إرسال البيانات إلى Laravel API
- ✅ الحصول على `guide_id` من `PathModel`
- ✅ حساب التاريخ والوقت تلقائياً
- ✅ حفظ محلي + إرسال إلى Laravel

### 2. `ApiService.createBooking()`:
- ✅ إضافة `totalPrice` كحقل اختياري
- ✅ إضافة logs مفصلة
- ✅ محاولة بدون authentication للمستخدمين الضيوف

### 3. `trip_registration_dialog.dart`:
- ✅ تمرير `path` إلى `registerTrip()`

---

## 📊 تنسيق البيانات في Laravel

### Migration (موجود بالفعل):

```php
Schema::create('bookings', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->foreignId('guide_id')->constrained()->onDelete('cascade');
    $table->date('booking_date');
    $table->time('start_time');
    $table->time('end_time');
    $table->decimal('total_price', 8, 2);
    $table->enum('status', ['pending', 'confirmed', 'cancelled', 'completed'])->default('pending');
    $table->text('notes')->nullable();
    $table->timestamps();
});
```

---

## 🎯 متطلبات Laravel API

### Endpoint: `POST /api/bookings`

**Headers:**
```
Content-Type: application/json
Accept: application/json
Authorization: Bearer {token} (اختياري)
```

**Body:**
```json
{
  "guide_id": 1,
  "booking_date": "2025-11-07",
  "start_time": "09:00:00",
  "end_time": "13:00:00",
  "total_price": 250.0,
  "notes": "ملاحظات..."
}
```

**Response (Success):**
```json
{
  "status": "success",
  "message": "تم إنشاء الحجز بنجاح",
  "data": {
    "id": 1,
    "user_id": 1,
    "guide_id": 1,
    "booking_date": "2025-11-07",
    "start_time": "09:00:00",
    "end_time": "13:00:00",
    "total_price": "250.00",
    "status": "pending",
    "notes": "ملاحظات...",
    "created_at": "2025-11-07T10:00:00.000000Z",
    "updated_at": "2025-11-07T10:00:00.000000Z"
  }
}
```

---

## 🔍 Logs في Console

عند تسجيل رحلة، ستظهر هذه الـ logs:

```
📤 إرسال بيانات الحجز إلى Laravel...
  - guide_id: 1
  - booking_date: 2025-11-07
  - start_time: 09:00:00
  - end_time: 13:00:00
  - total_price: 250.0
  - notes: ملاحظات...

📤 إرسال طلب حجز إلى Laravel:
  URL: http://localhost:8000/api/bookings
  Body: {guide_id: 1, booking_date: 2025-11-07, ...}

✅ استجابة Laravel: {...}
✅ تم إرسال الحجز بنجاح إلى Laravel: {...}
✅ تم إنشاء الحجز في Laravel برقم: 1
```

---

## ⚠️ ملاحظات مهمة

### 1. `guide_id`:
- يتم الحصول عليه من `path.guideId`
- إذا لم يكن موجود، يتم استخدام `1` كافتراضي
- **تأكد من وجود guide برقم 1 في Laravel** أو أضف `guide_id` إلى `sites` table

### 2. التاريخ والوقت:
- **التاريخ**: تاريخ اليوم (يمكن تعديله لاحقاً)
- **وقت البداية**: 9 صباحاً (يمكن تعديله لاحقاً)
- **وقت النهاية**: حسب مدة المسار (`path.estimatedDuration`)

### 3. `user_id`:
- Laravel يجب أن يحصل على `user_id` من token authentication
- إذا لم يكن المستخدم مسجل دخول، قد يحتاج Laravel إلى معالجة خاصة

---

## 🚀 الخطوات التالية (اختيارية)

### 1. إضافة حقول التاريخ والوقت في UI:
يمكن إضافة DatePicker و TimePicker في نموذج التسجيل:

```dart
// في trip_registration_dialog.dart
DateTime? _selectedDate;
TimeOfDay? _selectedStartTime;
```

### 2. تحسين معالجة `user_id`:
- إذا كان المستخدم مسجل دخول، Laravel يحصل على `user_id` من token
- إذا كان ضيف، يمكن إرسال `user_id` كـ null أو إنشاء user مؤقت

### 3. إضافة validation في Laravel:
```php
$request->validate([
    'guide_id' => 'required|exists:guides,id',
    'booking_date' => 'required|date|after_or_equal:today',
    'start_time' => 'required|date_format:H:i:s',
    'end_time' => 'required|date_format:H:i:s|after:start_time',
    'total_price' => 'nullable|numeric|min:0',
    'notes' => 'nullable|string|max:1000',
]);
```

---

## ✅ النتيجة

الآن عند تسجيل رحلة جديدة:
1. ✅ يتم حفظها محلياً في التطبيق
2. ✅ يتم إرسالها إلى Laravel في جدول `bookings`
3. ✅ يمكن للأدمن رؤيتها في لوحة الإدارة

---

## 🧪 اختبار

1. **سجل رحلة جديدة** من التطبيق
2. **راقب Console Logs** - يجب أن ترى:
   - `📤 إرسال بيانات الحجز إلى Laravel...`
   - `✅ تم إرسال الحجز بنجاح...`
3. **تحقق من Laravel** - افتح جدول `bookings` في قاعدة البيانات

---

## 📝 ملاحظات إضافية

- إذا فشل إرسال البيانات إلى Laravel، سيتم الحفظ محلياً فقط
- يمكنك تعديل الكود لجعل التسجيل يفشل تماماً إذا فشل API
- الـ logs ستساعدك في تتبع أي مشاكل


