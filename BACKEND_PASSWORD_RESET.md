# Backend Requirements for Password Reset
# متطلبات Backend لإعادة تعيين كلمة المرور

---

## Overview / نظرة عامة

This document describes the backend API endpoints required for the password reset functionality.

هذا المستند يصف نقاط نهاية API المطلوبة لوظيفة إعادة تعيين كلمة المرور.

---

## Required API Endpoints / نقاط نهاية API المطلوبة

### 1. Send Password Reset Email
### إرسال رابط إعادة تعيين كلمة المرور

**Endpoint:** `POST /api/password/email`

**Description:** Sends a password reset link to the user's email.

يرسل رابط إعادة تعيين كلمة المرور إلى بريد المستخدم الإلكتروني.

**Headers:**
```
Content-Type: application/json
Accept: application/json
```

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response (200 OK):**
```json
{
  "status": true,
  "message": "We have emailed your password reset link!"
}
```

**Response (422 Validation Error):**
```json
{
  "status": false,
  "message": "The given data was invalid.",
  "errors": {
    "email": [
      "The email field is required."
    ]
  }
}
```

**Response (404 Not Found):**
```json
{
  "status": false,
  "message": "We can't find a user with that email address."
}
```

**Response (429 Too Many Requests):**
```json
{
  "status": false,
  "message": "Too many password reset requests. Please try again later."
}
```

---

### 2. Reset Password
### إعادة تعيين كلمة المرور

**Endpoint:** `POST /api/password/reset`

**Description:** Resets the user's password using the token from the email link.

يعيد تعيين كلمة مرور المستخدم باستخدام Token من رابط البريد الإلكتروني.

**Headers:**
```
Content-Type: application/json
Accept: application/json
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "token": "reset_token_from_email",
  "password": "new_password123",
  "password_confirmation": "new_password123"
}
```

**Response (200 OK):**
```json
{
  "status": true,
  "message": "Your password has been reset!"
}
```

**Response (422 Validation Error):**
```json
{
  "status": false,
  "message": "The given data was invalid.",
  "errors": {
    "password": [
      "The password must be at least 8 characters."
    ],
    "password_confirmation": [
      "The password confirmation does not match."
    ]
  }
}
```

**Response (400 Bad Request - Invalid Token):**
```json
{
  "status": false,
  "message": "This password reset token is invalid or has expired."
}
```

---

## Laravel Implementation Example
## مثال على التنفيذ في Laravel

### 1. Routes (routes/api.php)

```php
// Password Reset Routes
Route::post('/password/email', [PasswordResetController::class, 'sendResetLinkEmail'])
    ->name('password.email');

Route::post('/password/reset', [PasswordResetController::class, 'reset'])
    ->name('password.update');
```

### 2. Controller (app/Http/Controllers/PasswordResetController.php)

```php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rules\Password as PasswordRule;
use App\Models\User;

class PasswordResetController extends Controller
{
    /**
     * Send password reset link
     */
    public function sendResetLinkEmail(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email|exists:users,email',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => false,
                'message' => 'The given data was invalid.',
                'errors' => $validator->errors()
            ], 422);
        }

        // Check rate limiting
        $status = Password::sendResetLink(
            $request->only('email')
        );

        if ($status === Password::RESET_LINK_SENT) {
            return response()->json([
                'status' => true,
                'message' => 'We have emailed your password reset link!'
            ], 200);
        }

        return response()->json([
            'status' => false,
            'message' => 'Unable to send reset link. Please try again later.'
        ], 500);
    }

    /**
     * Reset password
     */
    public function reset(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email|exists:users,email',
            'token' => 'required|string',
            'password' => ['required', 'string', 'confirmed', PasswordRule::min(8)],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => false,
                'message' => 'The given data was invalid.',
                'errors' => $validator->errors()
            ], 422);
        }

        $status = Password::reset(
            $request->only('email', 'password', 'password_confirmation', 'token'),
            function ($user, $password) {
                $user->forceFill([
                    'password' => Hash::make($password)
                ])->save();
            }
        );

        if ($status === Password::PASSWORD_RESET) {
            return response()->json([
                'status' => true,
                'message' => 'Your password has been reset!'
            ], 200);
        }

        return response()->json([
            'status' => false,
            'message' => 'This password reset token is invalid or has expired.'
        ], 400);
    }
}
```

### 3. Email Template (resources/views/emails/password-reset.blade.php)

```blade
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>إعادة تعيين كلمة المرور</title>
</head>
<body>
    <h2>إعادة تعيين كلمة المرور</h2>
    <p>مرحباً،</p>
    <p>لقد تلقيت هذا البريد الإلكتروني لأننا تلقينا طلباً لإعادة تعيين كلمة المرور لحسابك.</p>
    <p>اضغط على الزر أدناه لإعادة تعيين كلمة المرور:</p>
    <a href="{{ $resetUrl }}" style="background-color: #4CAF50; color: white; padding: 14px 20px; text-decoration: none; border-radius: 4px; display: inline-block;">
        إعادة تعيين كلمة المرور
    </a>
    <p>أو انسخ والصق الرابط التالي في المتصفح:</p>
    <p>{{ $resetUrl }}</p>
    <p>هذا الرابط سينتهي خلال 60 دقيقة.</p>
    <p>إذا لم تطلب إعادة تعيين كلمة المرور، لا حاجة لاتخاذ أي إجراء.</p>
    <p>شكراً،<br>فريق Velora</p>
</body>
</html>
```

### 4. Reset URL Format
### تنسيق رابط إعادة التعيين

The reset URL should be in this format:
يجب أن يكون رابط إعادة التعيين بهذا التنسيق:

```
https://your-app-domain.com/reset-password?email=user@example.com&token=reset_token_here
```

Or for mobile app deep linking:
أو للربط العميق في التطبيق:

```
velora://reset-password?email=user@example.com&token=reset_token_here
```

### 5. Notification Class (app/Notifications/ResetPasswordNotification.php)

```php
<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;
use Illuminate\Support\Facades\URL;

class ResetPasswordNotification extends Notification
{
    use Queueable;

    public $token;

    public function __construct($token)
    {
        $this->token = $token;
    }

    public function via($notifiable)
    {
        return ['mail'];
    }

    public function toMail($notifiable)
    {
        $resetUrl = $this->resetUrl($notifiable);

        return (new MailMessage)
            ->subject('إعادة تعيين كلمة المرور')
            ->view('emails.password-reset', [
                'resetUrl' => $resetUrl,
            ]);
    }

    protected function resetUrl($notifiable)
    {
        // For mobile app - use deep link
        // للتطبيق المحمول - استخدم deep link
        $token = $this->token;
        $email = urlencode($notifiable->email);
        
        // Option 1: Web URL (opens in browser, then redirects to app)
        // الخيار 1: رابط ويب (يفتح في المتصفح، ثم يوجه للتطبيق)
        // return url("https://your-app-domain.com/reset-password?email={$email}&token={$token}");
        
        // Option 2: Deep link (directly opens app)
        // الخيار 2: رابط عميق (يفتح التطبيق مباشرة)
        return "velora://reset-password?email={$email}&token={$token}";
        
        // Option 3: Universal link (iOS) / App link (Android)
        // الخيار 3: رابط عالمي (iOS) / رابط التطبيق (Android)
        // return url("https://your-app-domain.com/reset-password?email={$email}&token={$token}");
    }
}
```

---

## Configuration / الإعدادات

### 1. Mail Configuration (.env)

```env
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@velora.com
MAIL_FROM_NAME="${APP_NAME}"
```

### 2. Password Reset Configuration (config/auth.php)

```php
'passwords' => [
    'users' => [
        'provider' => 'users',
        'table' => 'password_reset_tokens',
        'expire' => 60, // Token expires in 60 minutes
        'throttle' => 60, // Max 1 request per minute
    ],
],
```

### 3. Database Migration

Make sure you have the `password_reset_tokens` table:

```php
Schema::create('password_reset_tokens', function (Blueprint $table) {
    $table->string('email')->primary();
    $table->string('token');
    $table->timestamp('created_at')->nullable();
});
```

---

## Security Considerations / اعتبارات الأمان

1. **Rate Limiting:** Limit password reset requests to prevent abuse
   - الحد من طلبات إعادة تعيين كلمة المرور لمنع الإساءة

2. **Token Expiration:** Tokens should expire after a reasonable time (e.g., 60 minutes)
   - يجب أن تنتهي صلاحية Tokens بعد وقت معقول (مثلاً 60 دقيقة)

3. **Token Uniqueness:** Each token should be unique and one-time use
   - يجب أن يكون كل Token فريداً وللاستخدام مرة واحدة

4. **Email Verification:** Only send reset links to verified email addresses
   - إرسال روابط إعادة التعيين فقط للعناوين المؤكدة

---

## Testing / الاختبار

### Test Send Reset Link

```bash
curl -X POST https://velorify.pro/api/password/email \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"email": "user@example.com"}'
```

### Test Reset Password

```bash
curl -X POST https://velorify.pro/api/password/reset \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "user@example.com",
    "token": "reset_token_from_email",
    "password": "new_password123",
    "password_confirmation": "new_password123"
  }'
```

---

## Frontend Integration / التكامل مع الواجهة الأمامية

The Flutter app is already configured to use these endpoints. The implementation includes:

التطبيق Flutter مُعد بالفعل لاستخدام هذه النقاط. التنفيذ يتضمن:

1. ✅ `POST /api/password/email` - Send reset link
2. ✅ `POST /api/password/reset` - Reset password
3. ✅ Reset password screen with token handling
4. ✅ Deep link support for reset URL

---

**Last Updated / آخر تحديث:** 2024

