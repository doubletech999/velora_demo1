# Frontend API Documentation
# توثيق API للواجهة الأمامية

---

## Table of Contents / جدول المحتويات

- [Overview / نظرة عامة](#overview--نظرة-عامة)
- [Notification Token Endpoint](#notification-token-endpoint)
- [Notification Types / أنواع الإشعارات](#notification-types--أنواع-الإشعارات)
- [Request/Response Examples](#requestresponse-examples)
- [Integration Guide](#integration-guide)

---

## Overview / نظرة عامة

This document describes the API endpoints and notification types for Firebase Cloud Messaging integration.

هذا المستند يصف نقاط نهاية API وأنواع الإشعارات لتكامل Firebase Cloud Messaging.

**Base URL:** `https://velorify.pro/api`

---

## Notification Token Endpoint

### Update FCM Token

**Endpoint:** `POST /api/notifications/update-token`

**Description:** Send FCM token to backend to receive push notifications.

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "fcm_token": "your_fcm_token_here"
}
```

**Response (200 OK):**
```json
{
  "status": true,
  "message": "Token updated successfully",
  "data": {
    "fcm_token": "your_fcm_token_here"
  }
}
```

**Response (401 Unauthorized):**
```json
{
  "status": false,
  "message": "Unauthenticated"
}
```

**When to Call:**
- After user login
- When app launches (if user is logged in)
- When FCM token is refreshed

---

## Notification Types / أنواع الإشعارات

### 1. New Route/Camping Created
### إشعار إنشاء مسار/تخييم جديد

**Type:** `new_route_camping`

**Description:** Sent to all users when a new route or camping site is created.

يُرسل لجميع المستخدمين عند إنشاء مسار أو موقع تخييم جديد.

**Notification Payload:**
```json
{
  "notification": {
    "title": "مسار جديد متاح",
    "body": "تم إنشاء مسار جديد: {site_name}"
  },
  "data": {
    "type": "new_route_camping",
    "site_id": "123",
    "site_type": "route",
    "site_name": "مسار الجليل"
  }
}
```

**Data Fields:**
- `type` (string, required): Always `"new_route_camping"`
- `site_id` (string, required): ID of the created site
- `site_type` (string, required): Either `"route"` or `"camping"`
- `site_name` (string, required): Name of the created site

**Action:** Navigate to site details page: `/site/{site_id}`

---

### 2. Trip Accepted
### إشعار الموافقة على رحلة

**Type:** `trip_accepted`

**Description:** Sent to a user when their trip registration is accepted.

يُرسل للمستخدم عند الموافقة على تسجيله في رحلة.

**Notification Payload:**
```json
{
  "notification": {
    "title": "تم قبول طلبك",
    "body": "تم قبول طلبك للانضمام إلى رحلة: {trip_name}"
  },
  "data": {
    "type": "trip_accepted",
    "trip_id": "456",
    "trip_name": "رحلة إلى القدس"
  }
}
```

**Data Fields:**
- `type` (string, required): Always `"trip_accepted"`
- `trip_id` (string, required): ID of the trip
- `trip_name` (string, required): Name of the trip

**Action:** Navigate to trip details page: `/trip/{trip_id}`

---

## Request/Response Examples

### Example 1: Update FCM Token (Success)

**Request:**
```http
POST /api/notifications/update-token HTTP/1.1
Host: velorify.pro
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc...
Content-Type: application/json

{
  "fcm_token": "dK3jH9fL2mN8pQ5rT7vW0xY3zA6bC9eF2hI5kL8mN1pQ4rT7vW0xY3zA6bC9eF"
}
```

**Response:**
```json
{
  "status": true,
  "message": "Token updated successfully",
  "data": {
    "fcm_token": "dK3jH9fL2mN8pQ5rT7vW0xY3zA6bC9eF2hI5kL8mN1pQ4rT7vW0xY3zA6bC9eF"
  }
}
```

### Example 2: Update FCM Token (Unauthorized)

**Request:**
```http
POST /api/notifications/update-token HTTP/1.1
Host: velorify.pro
Content-Type: application/json

{
  "fcm_token": "dK3jH9fL2mN8pQ5rT7vW0xY3zA6bC9eF2hI5kL8mN1pQ4rT7vW0xY3zA6bC9eF"
}
```

**Response:**
```json
{
  "status": false,
  "message": "Unauthenticated"
}
```

### Example 3: Notification Payload (New Route)

**Full FCM Message:**
```json
{
  "message": {
    "token": "user_fcm_token",
    "notification": {
      "title": "مسار جديد متاح",
      "body": "تم إنشاء مسار جديد: مسار الجليل"
    },
    "data": {
      "type": "new_route_camping",
      "site_id": "123",
      "site_type": "route",
      "site_name": "مسار الجليل"
    }
  }
}
```

### Example 4: Notification Payload (Trip Accepted)

**Full FCM Message:**
```json
{
  "message": {
    "token": "user_fcm_token",
    "notification": {
      "title": "تم قبول طلبك",
      "body": "تم قبول طلبك للانضمام إلى رحلة: رحلة إلى القدس"
    },
    "data": {
      "type": "trip_accepted",
      "trip_id": "456",
      "trip_name": "رحلة إلى القدس"
    }
  }
}
```

---

## Integration Guide

### Step 1: Send Token After Login

```dart
// After successful login
await FCMService.instance.sendTokenToBackend();
```

### Step 2: Handle Notifications

The FCM Service will automatically handle notifications based on their type and navigate to the appropriate page.

### Step 3: Navigation Routes

Make sure your app has these routes:
- `/site/{site_id}` - Site details page
- `/trip/{trip_id}` - Trip details page

---

## Error Handling

### Common Errors

1. **401 Unauthorized:**
   - User is not logged in
   - Token is expired
   - Solution: Re-login and send token again

2. **400 Bad Request:**
   - Invalid FCM token format
   - Missing required fields
   - Solution: Validate token before sending

3. **500 Server Error:**
   - Backend issue
   - Solution: Retry after some time

---

## Testing

### Test Token Update

```bash
curl -X POST https://velorify.pro/api/notifications/update-token \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"fcm_token": "YOUR_FCM_TOKEN"}'
```

### Test Notifications

Use Firebase Console to send test notifications with the payload structure described above.

---

**Last Updated / آخر تحديث:** 2024

