# Backend Requirements for Booking System with Notifications
# متطلبات Backend لنظام الحجوزات مع الإشعارات

---

## Overview / نظرة عامة

This document describes the backend API requirements for the booking system where:
- Users register for routes/camping trips
- Bookings are stored in the `bookings` table
- Admins can accept or reject bookings
- Users receive notifications when their booking is accepted

هذا المستند يصف متطلبات API للباك إند لنظام الحجوزات حيث:
- المستخدمون يسجلون في مسارات/تخييمات
- الحجوزات تُحفظ في جدول `bookings`
- الادمن يستطيع قبول أو رفض الحجوزات
- المستخدمون يتلقون إشعارات عند قبول حجزهم

---

## 1. Create Booking Endpoint
## إنشاء حجز جديد

### Endpoint: `POST /api/bookings`

**Headers:**
```
Content-Type: application/json
Accept: application/json
Authorization: Bearer {token} (اختياري - للمستخدمين المسجلين)
```

**Request Body:**
```json
{
  "guide_id": 1,
  "path_id": "123",           // معرف المسار/التخييم (مطلوب)
  "site_id": "123",           // معرف الموقع (نفس path_id للتوافق)
  "booking_date": "2025-01-15",
  "start_time": "09:00:00",
  "end_time": "13:00:00",
  "total_price": 250.0,
  "number_of_participants": 2,  // عدد المشاركين (مطلوب)
  "payment_method": "cash",      // طريقة الدفع: "cash" أو "visa" (مطلوب)
  "notes": "ملاحظات المستخدم"
}
```

**Response (Success - 201 Created):**
```json
{
  "status": "success",
  "message": "تم إنشاء الحجز بنجاح",
  "data": {
    "id": 1,
    "user_id": 5,
    "guide_id": 1,
    "path_id": "123",
    "site_id": "123",
    "booking_date": "2025-01-15",
    "start_time": "09:00:00",
    "end_time": "13:00:00",
    "total_price": "250.00",
    "number_of_participants": 2,
    "payment_method": "cash",
    "status": "pending",
    "notes": "ملاحظات المستخدم",
    "created_at": "2025-01-10T10:00:00.000000Z",
    "updated_at": "2025-01-10T10:00:00.000000Z"
  }
}
```

**Response (Error - 422 Validation Error):**
```json
{
  "status": "error",
  "message": "The given data was invalid.",
  "errors": {
    "guide_id": ["The guide id field is required."],
    "path_id": ["The path id field is required."]
  }
}
```

---

## 2. Update Booking Status (Admin Only)
## تحديث حالة الحجز (للادمن فقط)

### Endpoint: `PUT /api/bookings/{id}/status`

**Headers:**
```
Content-Type: application/json
Accept: application/json
Authorization: Bearer {admin_token} (مطلوب - للادمن فقط)
```

**Request Body:**
```json
{
  "status": "confirmed"  // أو "rejected" أو "cancelled"
}
```

**Response (Success - 200 OK):**
```json
{
  "status": "success",
  "message": "تم تحديث حالة الحجز بنجاح",
  "data": {
    "id": 1,
    "user_id": 5,
    "guide_id": 1,
    "path_id": "123",
    "booking_date": "2025-01-15",
    "status": "confirmed",
    "updated_at": "2025-01-10T11:00:00.000000Z"
  }
}
```

**Important / مهم:**
- عند تغيير الحالة إلى `confirmed` (مقبول)، يجب إرسال إشعار FCM للمستخدم
- عند تغيير الحالة إلى `rejected` (مرفوض)، يمكن إرسال إشعار أيضاً (اختياري)

---

## 3. Database Schema
## هيكل قاعدة البيانات

### Bookings Table

```sql
CREATE TABLE bookings (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    guide_id BIGINT NOT NULL,
    path_id VARCHAR(255),           -- معرف المسار/التخييم
    site_id VARCHAR(255),           -- معرف الموقع (نفس path_id)
    booking_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    number_of_participants INT DEFAULT 1,
    payment_method ENUM('cash', 'visa') DEFAULT 'cash',
    status ENUM('pending', 'confirmed', 'rejected', 'cancelled', 'completed') DEFAULT 'pending',
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (guide_id) REFERENCES guides(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_guide_id (guide_id),
    INDEX idx_status (status),
    INDEX idx_booking_date (booking_date)
);
```

---

## 4. Laravel Controller Implementation
## تنفيذ Controller في Laravel

### `app/Http/Controllers/BookingController.php`

```php
<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;

class BookingController extends Controller
{
    /**
     * إنشاء حجز جديد
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'guide_id' => 'required|exists:guides,id',
            'path_id' => 'required|string',
            'site_id' => 'nullable|string',
            'booking_date' => 'required|date',
            'start_time' => 'required|date_format:H:i:s',
            'end_time' => 'required|date_format:H:i:s|after:start_time',
            'total_price' => 'required|numeric|min:0',
            'number_of_participants' => 'required|integer|min:1',
            'payment_method' => 'required|in:cash,visa',
            'notes' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'The given data was invalid.',
                'errors' => $validator->errors()
            ], 422);
        }

        // الحصول على user_id من token (إذا كان مسجل دخول) أو من request
        $userId = $request->user()?->id ?? $request->input('user_id');
        
        if (!$userId) {
            return response()->json([
                'status' => 'error',
                'message' => 'User ID is required.'
            ], 422);
        }

        $booking = Booking::create([
            'user_id' => $userId,
            'guide_id' => $request->guide_id,
            'path_id' => $request->path_id,
            'site_id' => $request->site_id ?? $request->path_id,
            'booking_date' => $request->booking_date,
            'start_time' => $request->start_time,
            'end_time' => $request->end_time,
            'total_price' => $request->total_price,
            'number_of_participants' => $request->number_of_participants,
            'payment_method' => $request->payment_method,
            'status' => 'pending',
            'notes' => $request->notes,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم إنشاء الحجز بنجاح',
            'data' => $booking
        ], 201);
    }

    /**
     * تحديث حالة الحجز (للادمن فقط)
     */
    public function updateStatus(Request $request, $id)
    {
        // التحقق من أن المستخدم هو ادمن
        if (!$request->user() || !$request->user()->is_admin) {
            return response()->json([
                'status' => 'error',
                'message' => 'Unauthorized. Admin access required.'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'status' => 'required|in:pending,confirmed,rejected,cancelled,completed'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Invalid status',
                'errors' => $validator->errors()
            ], 422);
        }

        $booking = Booking::with('user')->findOrFail($id);
        $oldStatus = $booking->status;
        $booking->status = $request->status;
        $booking->save();

        // إرسال إشعار FCM عند قبول الحجز
        if ($request->status === 'confirmed' && $oldStatus !== 'confirmed') {
            $this->sendBookingConfirmationNotification($booking);
        }

        // إرسال إشعار عند رفض الحجز (اختياري)
        if ($request->status === 'rejected' && $oldStatus !== 'rejected') {
            $this->sendBookingRejectionNotification($booking);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تم تحديث حالة الحجز بنجاح',
            'data' => $booking
        ]);
    }

    /**
     * إرسال إشعار قبول الحجز
     */
    private function sendBookingConfirmationNotification(Booking $booking)
    {
        try {
            $user = $booking->user;
            
            if (!$user || !$user->fcm_token) {
                Log::warning("User {$user->id} does not have FCM token");
                return;
            }

            // الحصول على معلومات المسار
            $pathName = $booking->path_id; // يمكن جلب اسم المسار من جدول sites
            
            // إرسال إشعار FCM
            $notificationData = [
                'type' => 'trip_accepted',
                'trip_id' => (string) $booking->id,
                'trip_name' => $pathName ?? 'رحلة',
                'booking_id' => (string) $booking->id,
                'booking_date' => $booking->booking_date,
            ];

            // استخدام Firebase Cloud Messaging
            // يمكن استخدام Laravel Notification أو HTTP Client مباشرة
            $this->sendFCMNotification(
                $user->fcm_token,
                'تم قبول حجزك!',
                'تم قبول حجزك في ' . ($pathName ?? 'الرحلة') . '. استمتع برحلتك!',
                $notificationData
            );

            Log::info("Booking confirmation notification sent to user {$user->id}");
        } catch (\Exception $e) {
            Log::error("Failed to send booking confirmation notification: " . $e->getMessage());
        }
    }

    /**
     * إرسال إشعار رفض الحجز
     */
    private function sendBookingRejectionNotification(Booking $booking)
    {
        try {
            $user = $booking->user;
            
            if (!$user || !$user->fcm_token) {
                return;
            }

            $pathName = $booking->path_id;
            
            $notificationData = [
                'type' => 'trip_rejected',
                'trip_id' => (string) $booking->id,
                'trip_name' => $pathName ?? 'رحلة',
                'booking_id' => (string) $booking->id,
            ];

            $this->sendFCMNotification(
                $user->fcm_token,
                'تم رفض حجزك',
                'نأسف، تم رفض حجزك في ' . ($pathName ?? 'الرحلة') . '.',
                $notificationData
            );

            Log::info("Booking rejection notification sent to user {$user->id}");
        } catch (\Exception $e) {
            Log::error("Failed to send booking rejection notification: " . $e->getMessage());
        }
    }

    /**
     * إرسال إشعار FCM
     */
    private function sendFCMNotification($fcmToken, $title, $body, $data = [])
    {
        // استخدام Firebase Admin SDK أو HTTP Client
        // مثال باستخدام HTTP Client:
        
        $serverKey = config('services.fcm.server_key');
        
        $response = \Http::withHeaders([
            'Authorization' => 'key=' . $serverKey,
            'Content-Type' => 'application/json',
        ])->post('https://fcm.googleapis.com/fcm/send', [
            'to' => $fcmToken,
            'notification' => [
                'title' => $title,
                'body' => $body,
                'sound' => 'default',
            ],
            'data' => $data,
            'priority' => 'high',
        ]);

        return $response->json();
    }

    /**
     * الحصول على جميع الحجوزات (للادمن)
     */
    public function index(Request $request)
    {
        // التحقق من أن المستخدم هو ادمن
        if (!$request->user() || !$request->user()->is_admin) {
            return response()->json([
                'status' => 'error',
                'message' => 'Unauthorized. Admin access required.'
            ], 403);
        }

        $query = Booking::with(['user', 'guide']);

        // Filter by status
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Filter by date range
        if ($request->has('start_date')) {
            $query->where('booking_date', '>=', $request->start_date);
        }
        if ($request->has('end_date')) {
            $query->where('booking_date', '<=', $request->end_date);
        }

        $bookings = $query->orderBy('created_at', 'desc')->paginate(20);

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
        $booking = Booking::with(['user', 'guide'])->findOrFail($id);
        
        return response()->json([
            'status' => 'success',
            'data' => $booking
        ]);
    }
}
```

---

## 5. Routes
## المسارات

### `routes/api.php`

```php
use App\Http\Controllers\BookingController;

// Bookings routes
Route::middleware('auth:sanctum')->group(function () {
    // إنشاء حجز (للمستخدمين المسجلين)
    Route::post('/bookings', [BookingController::class, 'store']);
    
    // الحصول على حجوزاتي
    Route::get('/bookings/my', [BookingController::class, 'myBookings']);
    
    // الحصول على حجز محدد
    Route::get('/bookings/{id}', [BookingController::class, 'show']);
});

// للسماح للمستخدمين الضيوف (بدون authentication)
Route::post('/bookings', [BookingController::class, 'store'])->middleware('optional_auth');

// Admin routes (للادمن فقط)
Route::middleware(['auth:sanctum', 'admin'])->group(function () {
    // الحصول على جميع الحجوزات
    Route::get('/admin/bookings', [BookingController::class, 'index']);
    
    // تحديث حالة الحجز
    Route::put('/bookings/{id}/status', [BookingController::class, 'updateStatus']);
});
```

---

## 6. FCM Notification Format
## تنسيق إشعار FCM

### عند قبول الحجز (trip_accepted):

```json
{
  "to": "user_fcm_token",
  "notification": {
    "title": "تم قبول حجزك!",
    "body": "تم قبول حجزك في [اسم المسار]. استمتع برحلتك!",
    "sound": "default"
  },
  "data": {
    "type": "trip_accepted",
    "trip_id": "1",
    "trip_name": "مسار وادي قانا",
    "booking_id": "1",
    "booking_date": "2025-01-15"
  },
  "priority": "high"
}
```

### عند رفض الحجز (trip_rejected):

```json
{
  "to": "user_fcm_token",
  "notification": {
    "title": "تم رفض حجزك",
    "body": "نأسف، تم رفض حجزك في [اسم المسار].",
    "sound": "default"
  },
  "data": {
    "type": "trip_rejected",
    "trip_id": "1",
    "trip_name": "مسار وادي قانا",
    "booking_id": "1"
  },
  "priority": "high"
}
```

---

## 7. Environment Configuration
## إعدادات البيئة

### `.env`

```env
FCM_SERVER_KEY=your_firebase_server_key_here
```

### `config/services.php`

```php
'fcm' => [
    'server_key' => env('FCM_SERVER_KEY'),
],
```

---

## 8. Summary of Required Changes
## ملخص التعديلات المطلوبة

### Database:
- ✅ إضافة `path_id` و `site_id` في جدول `bookings`
- ✅ إضافة `number_of_participants` في جدول `bookings`
- ✅ إضافة `payment_method` في جدول `bookings`

### API:
- ✅ تحديث `POST /api/bookings` لقبول الحقول الجديدة
- ✅ إضافة `PUT /api/bookings/{id}/status` لتحديث الحالة (للادمن)
- ✅ إرسال إشعار FCM عند قبول/رفض الحجز

### Admin Panel:
- ✅ صفحة لعرض جميع الحجوزات
- ✅ أزرار لقبول/رفض الحجوزات
- ✅ فلترة حسب الحالة

---

**Last Updated / آخر تحديث:** 2024

