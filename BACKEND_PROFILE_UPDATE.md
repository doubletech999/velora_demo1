# Backend Requirements for Profile Update
# متطلبات Backend لتحديث الملف الشخصي

---

## Overview / نظرة عامة

This document describes the backend API endpoints required for profile update and password change functionality.

هذا المستند يصف نقاط نهاية API المطلوبة لوظيفة تحديث الملف الشخصي وتغيير كلمة المرور.

---

## Required API Endpoints / نقاط نهاية API المطلوبة

### 1. Update User Profile
### تحديث الملف الشخصي

**Endpoint:** `PUT /api/user/profile`

**Description:** Updates the user's profile information (name, email, phone, etc.).

يقوم بتحديث معلومات الملف الشخصي للمستخدم (الاسم، البريد الإلكتروني، رقم الهاتف، إلخ).

**Headers:**
```
Content-Type: application/json
Accept: application/json
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "name": "أحمد محمد",
  "email": "ahmed@example.com",
  "phone": "0599123456",
  "preferred_language": "ar"
}
```

**Response (200 OK):**
```json
{
  "status": true,
  "message": "Profile updated successfully",
  "user": {
    "id": "1",
    "name": "أحمد محمد",
    "email": "ahmed@example.com",
    "phone": "0599123456",
    "profile_image_url": null,
    "completed_trips": 5,
    "saved_trips": 3,
    "achievements": 0,
    "preferred_language": "ar",
    "role": "user",
    "created_at": "2024-01-01T00:00:00.000000Z",
    "email_verified_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

**Response (422 Validation Error):**
```json
{
  "status": false,
  "message": "The given data was invalid.",
  "errors": {
    "email": [
      "The email has already been taken."
    ],
    "phone": [
      "The phone must be a valid phone number."
    ]
  }
}
```

**Response (401 Unauthorized):**
```json
{
  "status": false,
  "message": "Unauthenticated."
}
```

---

### 2. Update Password
### تحديث كلمة المرور

**Endpoint:** `PUT /api/user/password`

**Description:** Updates the user's password.

يقوم بتحديث كلمة مرور المستخدم.

**Headers:**
```
Content-Type: application/json
Accept: application/json
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "current_password": "old_password123",
  "new_password": "new_password123",
  "new_password_confirmation": "new_password123"
}
```

**Response (200 OK):**
```json
{
  "status": true,
  "message": "Password updated successfully"
}
```

**Response (422 Validation Error):**
```json
{
  "status": false,
  "message": "The given data was invalid.",
  "errors": {
    "current_password": [
      "The current password is incorrect."
    ],
    "new_password": [
      "The password must be at least 8 characters."
    ],
    "new_password_confirmation": [
      "The password confirmation does not match."
    ]
  }
}
```

**Response (401 Unauthorized):**
```json
{
  "status": false,
  "message": "Unauthenticated."
}
```

---

## Laravel Implementation Example
## مثال على التنفيذ في Laravel

### 1. Routes (routes/api.php)

```php
// Profile routes (require authentication)
Route::middleware('auth:sanctum')->group(function () {
    Route::put('/user/profile', [UserProfileController::class, 'updateProfile']);
    Route::put('/user/password', [UserProfileController::class, 'updatePassword']);
});
```

### 2. Controller (app/Http/Controllers/UserProfileController.php)

```php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rules\Password as PasswordRule;
use App\Models\User;

class UserProfileController extends Controller
{
    /**
     * Update user profile
     */
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
            'email' => 'sometimes|required|email|unique:users,email,' . $user->id,
            'phone' => 'sometimes|nullable|string|max:20',
            'preferred_language' => 'sometimes|in:ar,en',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => false,
                'message' => 'The given data was invalid.',
                'errors' => $validator->errors()
            ], 422);
        }

        // Update user data
        if ($request->has('name')) {
            $user->name = $request->name;
        }
        if ($request->has('email')) {
            $user->email = $request->email;
        }
        if ($request->has('phone')) {
            $user->phone = $request->phone;
        }
        if ($request->has('preferred_language')) {
            $user->preferred_language = $request->preferred_language;
        }

        $user->save();

        return response()->json([
            'status' => true,
            'message' => 'Profile updated successfully',
            'user' => $user->load('profile') // Load relationships if needed
        ], 200);
    }

    /**
     * Update user password
     */
    public function updatePassword(Request $request)
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'current_password' => 'required|string',
            'new_password' => ['required', 'string', 'confirmed', PasswordRule::min(8)],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => false,
                'message' => 'The given data was invalid.',
                'errors' => $validator->errors()
            ], 422);
        }

        // Verify current password
        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'status' => false,
                'message' => 'The given data was invalid.',
                'errors' => [
                    'current_password' => ['The current password is incorrect.']
                ]
            ], 422);
        }

        // Update password
        $user->password = Hash::make($request->new_password);
        $user->save();

        return response()->json([
            'status' => true,
            'message' => 'Password updated successfully'
        ], 200);
    }
}
```

### 3. User Model (app/Models/User.php)

Make sure your User model has the `phone` and `preferred_language` fields in the `$fillable` array:

```php
protected $fillable = [
    'name',
    'email',
    'password',
    'phone',
    'preferred_language',
    'role',
    'email_verified_at',
];
```

### 4. Database Migration

If you need to add `phone` and `preferred_language` columns:

```php
Schema::table('users', function (Blueprint $table) {
    $table->string('phone')->nullable()->after('email');
    $table->string('preferred_language', 2)->default('ar')->after('phone');
});
```

---

## Security Considerations / اعتبارات الأمان

1. **Authentication Required:** Both endpoints require authentication
   - كلا النقطتين تتطلبان المصادقة

2. **Password Validation:** 
   - Current password must be verified before updating
   - New password must meet minimum requirements (8+ characters)
   - يجب التحقق من كلمة المرور الحالية قبل التحديث
   - يجب أن تستوفي كلمة المرور الجديدة الحد الأدنى من المتطلبات (8+ أحرف)

3. **Email Uniqueness:** Email must be unique (except for current user)
   - يجب أن يكون البريد الإلكتروني فريداً (باستثناء المستخدم الحالي)

4. **Input Validation:** All inputs should be validated
   - يجب التحقق من جميع المدخلات

---

## Testing / الاختبار

### Test Update Profile

```bash
curl -X PUT https://velorify.pro/api/user/profile \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "name": "أحمد محمد",
    "email": "ahmed@example.com",
    "phone": "0599123456"
  }'
```

### Test Update Password

```bash
curl -X PUT https://velorify.pro/api/user/password \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "current_password": "old_password123",
    "new_password": "new_password123",
    "new_password_confirmation": "new_password123"
  }'
```

---

## Frontend Integration / التكامل مع الواجهة الأمامية

The Flutter app is already configured to use these endpoints. The implementation includes:

التطبيق Flutter مُعد بالفعل لاستخدام هذه النقاط. التنفيذ يتضمن:

1. ✅ `PUT /api/user/profile` - Update profile
2. ✅ `PUT /api/user/password` - Update password
3. ✅ Profile update screen with name, email, phone fields
4. ✅ Password change screen with current/new password fields
5. ✅ Error handling and validation
6. ✅ Success/error messages

---

**Last Updated / آخر تحديث:** 2024

