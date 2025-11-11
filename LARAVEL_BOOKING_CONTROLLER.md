# Laravel Booking Controller - دليل الإعداد

## 📋 متطلبات Laravel Controller

Laravel Controller يجب أن يحصل على `user_id` من المستخدم المصادق عليه.

---

## 🔧 Laravel Controller المطلوب

### `app/Http/Controllers/BookingController.php`:

```php
<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Guide;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class BookingController extends Controller
{
    /**
     * إنشاء حجز جديد
     */
    public function store(Request $request)
    {
        // التحقق من البيانات
        $validator = Validator::make($request->all(), [
            'guide_id' => 'required|exists:guides,id',
            'booking_date' => 'required|date|after_or_equal:today',
            'start_time' => 'required|date_format:H:i:s',
            'end_time' => 'required|date_format:H:i:s|after:start_time',
            'total_price' => 'nullable|numeric|min:0',
            'notes' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            // الحصول على user_id من المستخدم المصادق عليه
            $userId = auth()->id();
            
            // إذا لم يكن هناك user مصادق عليه، استخدم user_id من request (للمستخدمين الضيوف)
            if (!$userId && $request->has('user_id')) {
                $userId = $request->user_id;
            }
            
            // إذا لم يكن هناك user_id على الإطلاق، أنشئ user مؤقت أو استخدم user افتراضي
            if (!$userId) {
                // خيار 1: إنشاء user مؤقت
                // $user = User::create(['name' => 'Guest', 'email' => 'guest@example.com', ...]);
                // $userId = $user->id;
                
                // خيار 2: استخدام user افتراضي (يجب أن يكون موجود)
                $userId = 1; // ⚠️ تأكد من وجود user برقم 1
                
                // خيار 3: إرجاع خطأ
                // return response()->json([
                //     'status' => 'error',
                //     'message' => 'User authentication required'
                // ], 401);
            }

            // التحقق من وجود guide
            $guide = Guide::findOrFail($request->guide_id);

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

            // تحميل العلاقات
            $booking->load(['user', 'guide.user']);

            return response()->json([
                'status' => 'success',
                'message' => 'تم إنشاء الحجز بنجاح',
                'data' => $booking
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'فشل إنشاء الحجز',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * الحصول على جميع الحجوزات
     */
    public function index(Request $request)
    {
        $query = Booking::with(['user', 'guide.user', 'trip']);

        // Filter by status
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Filter by date
        if ($request->has('date')) {
            $query->whereDate('booking_date', $request->date);
        }

        // Filter by user (if not admin)
        if (auth()->check() && auth()->user()->role !== 'admin') {
            $query->where('user_id', auth()->id());
        }

        $bookings = $query->latest()->paginate(15);

        return response()->json([
            'status' => 'success',
            'data' => $bookings
        ]);
    }

    /**
     * الحصول على حجز محدد
     */
    public function show($id)
    {
        $booking = Booking::with(['user', 'guide.user', 'trip'])->findOrFail($id);

        // التحقق من الصلاحيات
        if (auth()->check() && auth()->user()->role !== 'admin') {
            if ($booking->user_id !== auth()->id()) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Unauthorized'
                ], 403);
            }
        }

        return response()->json([
            'status' => 'success',
            'data' => $booking
        ]);
    }

    /**
     * تحديث حالة الحجز
     */
    public function updateStatus(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'status' => 'required|in:pending,confirmed,cancelled,completed'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Invalid status',
                'errors' => $validator->errors()
            ], 422);
        }

        $booking = Booking::findOrFail($id);
        $booking->status = $request->status;
        $booking->save();

        return response()->json([
            'status' => 'success',
            'message' => 'تم تحديث حالة الحجز',
            'data' => $booking
        ]);
    }

    /**
     * حذف حجز
     */
    public function destroy($id)
    {
        $booking = Booking::findOrFail($id);
        $booking->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'تم حذف الحجز بنجاح'
        ]);
    }
}
```

---

## 🛣️ Routes المطلوبة

### `routes/api.php`:

```php
use App\Http\Controllers\BookingController;

// Bookings routes
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/bookings', [BookingController::class, 'index']);
    Route::post('/bookings', [BookingController::class, 'store']);
    Route::get('/bookings/{id}', [BookingController::class, 'show']);
    Route::put('/bookings/{id}/status', [BookingController::class, 'updateStatus']);
    Route::delete('/bookings/{id}', [BookingController::class, 'destroy']);
});

// للسماح للمستخدمين الضيوف (بدون authentication)
Route::post('/bookings', [BookingController::class, 'store'])->middleware('optional_auth');
```

---

## 🔐 Middleware للسماح بالحجوزات بدون authentication

### `app/Http/Middleware/OptionalAuth.php`:

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class OptionalAuth
{
    public function handle(Request $request, Closure $next)
    {
        // محاولة المصادقة إذا كان هناك token
        if ($request->bearerToken()) {
            auth()->setDefaultDriver('sanctum');
        }
        
        return $next($request);
    }
}
```

---

## ✅ التحقق من البيانات

### 1. تأكد من وجود User برقم 1 (للمستخدمين الضيوف):

```php
// في tinker أو seeder
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

### 2. تأكد من وجود Guide برقم 1:

```php
Guide::firstOrCreate(
    ['id' => 1],
    [
        'user_id' => 1,
        'hourly_rate' => 50.00
    ]
);
```

---

## 🧪 اختبار API

### باستخدام Postman أو cURL:

```bash
# إنشاء حجز (مع authentication)
curl -X POST http://localhost:8000/api/bookings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "guide_id": 1,
    "booking_date": "2025-11-10",
    "start_time": "09:00:00",
    "end_time": "13:00:00",
    "total_price": 250.00,
    "notes": "Test booking"
  }'

# إنشاء حجز (بدون authentication - للمستخدمين الضيوف)
curl -X POST http://localhost:8000/api/bookings \
  -H "Content-Type: application/json" \
  -d '{
    "guide_id": 1,
    "booking_date": "2025-11-10",
    "start_time": "09:00:00",
    "end_time": "13:00:00",
    "total_price": 250.00,
    "notes": "Guest booking"
  }'
```

---

## 📊 التحقق من البيانات في قاعدة البيانات

### استخدام الـ script المرفق:

```bash
php check_bookings.php
```

أو مباشرة في tinker:

```php
php artisan tinker

// عدد الحجوزات
Booking::count();

// آخر 5 حجوزات
Booking::with(['user', 'guide.user'])->latest()->take(5)->get();

// حجوزات اليوم
Booking::whereDate('booking_date', today())->get();
```

---

## ⚠️ ملاحظات مهمة

1. **`user_id`**: Laravel يحصل عليه من `auth()->id()` إذا كان المستخدم مسجل دخول
2. **المستخدمين الضيوف**: إذا لم يكن هناك token، يمكن استخدام user افتراضي (رقم 1)
3. **Validation**: تأكد من أن جميع الحقول المطلوبة موجودة
4. **Relations**: تأكد من تحميل العلاقات (`user`, `guide.user`) لعرضها في لوحة الإدارة

---

## ✅ النتيجة

بعد إضافة هذا Controller، ستظهر الحجوزات في:
- ✅ لوحة الإدارة Laravel
- ✅ جدول `bookings` في قاعدة البيانات
- ✅ API responses


