# Backend Requirements for Separate Details Screens
# متطلبات Backend لصفحات التفاصيل المنفصلة

---

## Overview / نظرة عامة

This document describes the backend API requirements for separate details screens for different types of locations (Hotels, Restaurants, Routes, Camping, Tourist Sites).

هذا المستند يصف متطلبات API للباك إند لصفحات التفاصيل المنفصلة لأنواع مختلفة من المواقع (الفنادق، المطاعم، المسارات، التخييمات، المواقع السياحية).

---

## Types and Their Specific Fields
## الأنواع والحقول الخاصة بكل نوع

### 1. Routes (المسارات) - `type='route'`

**Required Fields / الحقول المطلوبة:**
```json
{
  "id": 1,
  "name": "Route Name",
  "name_ar": "اسم المسار",
  "description": "Route description",
  "description_ar": "وصف المسار",
  "type": "route",
  "location": "Location",
  "location_ar": "الموقع",
  "latitude": "31.9522",
  "longitude": "35.2332",
  "images": ["url1", "url2"],
  
  // Route-specific fields
  "length": 12.5,                    // المسافة بالكيلومتر (مطلوب)
  "estimated_duration": 4,           // المدة بالساعات (مطلوب)
  "difficulty": "medium",            // easy, medium, hard (مطلوب)
  "activities": ["hiking", "nature"], // الأنشطة (مطلوب)
  "price": 250.0,                    // السعر (مطلوب)
  "guide_id": 1,                     // معرف المرشد (مطلوب)
  "guide": {                         // معلومات المرشد (مطلوب)
    "id": 1,
    "name": "Guide Name",
    "name_ar": "اسم المرشد",
    "route_price": 250.0
  },
  
  // Common fields
  "rating": 4.5,
  "review_count": 10,
  "warnings": ["Warning 1"],
  "warnings_ar": ["تحذير 1"],
  "coordinates": [
    {"latitude": 31.9522, "longitude": 35.2332}
  ]
}
```

**Features / المميزات:**
- ✅ Registration button (زر التسجيل)
- ✅ Registered trips list (قائمة الرحلات المسجلة)
- ✅ Guide information (معلومات المرشد)
- ✅ Route details (المسافة، المدة، الصعوبة)

---

### 2. Camping (التخييمات) - `type='camping'`

**Required Fields / الحقول المطلوبة:**
```json
{
  "id": 1,
  "name": "Camping Site Name",
  "name_ar": "اسم موقع التخييم",
  "description": "Camping description",
  "description_ar": "وصف موقع التخييم",
  "type": "camping",
  "location": "Location",
  "location_ar": "الموقع",
  "latitude": "31.9522",
  "longitude": "35.2332",
  "images": ["url1", "url2"],
  
  // Camping-specific fields
  "length": 0,                       // المسافة (قد تكون 0 للتخييم)
  "estimated_duration": 1,           // المدة (مطلوب)
  "difficulty": "easy",              // easy, medium, hard (مطلوب)
  "activities": ["camping"],         // الأنشطة (يجب أن تحتوي على camping)
  "price": 150.0,                    // السعر (مطلوب)
  "guide_id": 1,                     // معرف المرشد (مطلوب)
  "guide": {                         // معلومات المرشد (مطلوب)
    "id": 1,
    "name": "Guide Name",
    "name_ar": "اسم المرشد",
    "route_price": 150.0
  },
  
  // Camping amenities (optional but recommended)
  "amenities": ["fireplace", "water", "toilet"], // المرافق
  "amenities_ar": ["موقد نار", "ماء", "مرحاض"],
  "capacity": 20,                    // السعة (عدد الأشخاص)
  
  // Common fields
  "rating": 4.5,
  "review_count": 10,
  "warnings": ["Warning 1"],
  "warnings_ar": ["تحذير 1"],
  "coordinates": [
    {"latitude": 31.9522, "longitude": 35.2332}
  ]
}
```

**Features / المميزات:**
- ✅ Registration button (زر التسجيل)
- ✅ Registered trips list (قائمة الرحلات المسجلة)
- ✅ Guide information (معلومات المرشد)
- ✅ Camping amenities (المرافق)
- ✅ Capacity information (معلومات السعة)

---

### 3. Hotels (الفنادق) - `type='hotel'`

**Required Fields / الحقول المطلوبة:**
```json
{
  "id": 1,
  "name": "Hotel Name",
  "name_ar": "اسم الفندق",
  "description": "Hotel description",
  "description_ar": "وصف الفندق",
  "type": "hotel",
  "location": "Location",
  "location_ar": "الموقع",
  "latitude": "31.9522",
  "longitude": "35.2332",
  "images": ["url1", "url2"],
  
  // Hotel-specific fields
  "star_rating": 4,                  // عدد النجوم (1-5) (مطلوب)
  "price_per_night": 300.0,          // سعر الليلة (مطلوب)
  "amenities": [                     // المرافق (مطلوب)
    "wifi",
    "pool",
    "gym",
    "restaurant",
    "parking"
  ],
  "amenities_ar": [                  // المرافق بالعربية (مطلوب)
    "واي فاي",
    "مسبح",
    "صالة رياضية",
    "مطعم",
    "موقف سيارات"
  ],
  "room_count": 50,                  // عدد الغرف (اختياري)
  "check_in_time": "14:00",          // وقت تسجيل الوصول (اختياري)
  "check_out_time": "12:00",         // وقت تسجيل المغادرة (اختياري)
  "contact_phone": "+970591234567",  // رقم الهاتف (اختياري)
  "contact_email": "hotel@example.com", // البريد الإلكتروني (اختياري)
  
  // Common fields
  "rating": 4.5,
  "review_count": 10,
  "coordinates": [
    {"latitude": 31.9522, "longitude": 35.2332}
  ]
}
```

**Features / المميزات:**
- ❌ No registration (لا يوجد تسجيل)
- ✅ Star rating display (عرض عدد النجوم)
- ✅ Price per night (سعر الليلة)
- ✅ Amenities list (قائمة المرافق)
- ✅ Contact information (معلومات الاتصال)
- ✅ Check-in/Check-out times (أوقات تسجيل الوصول/المغادرة)

---

### 4. Restaurants (المطاعم) - `type='restaurant'`

**Required Fields / الحقول المطلوبة:**
```json
{
  "id": 1,
  "name": "Restaurant Name",
  "name_ar": "اسم المطعم",
  "description": "Restaurant description",
  "description_ar": "وصف المطعم",
  "type": "restaurant",
  "location": "Location",
  "location_ar": "الموقع",
  "latitude": "31.9522",
  "longitude": "35.2332",
  "images": ["url1", "url2"],
  
  // Restaurant-specific fields
  "cuisine_type": "palestinian",     // نوع المطبخ (مطلوب)
  "cuisine_type_ar": "فلسطيني",      // نوع المطبخ بالعربية (مطلوب)
  "average_price": 50.0,             // متوسط سعر الوجبة (مطلوب)
  "price_range": "$$",               // نطاق السعر: $, $$, $$$, $$$$ (اختياري)
  "opening_hours": {                 // ساعات العمل (مطلوب)
    "monday": "09:00-22:00",
    "tuesday": "09:00-22:00",
    "wednesday": "09:00-22:00",
    "thursday": "09:00-22:00",
    "friday": "09:00-22:00",
    "saturday": "09:00-22:00",
    "sunday": "09:00-22:00"
  },
  "opening_hours_ar": {              // ساعات العمل بالعربية (اختياري)
    "monday": "09:00-22:00",
    "tuesday": "09:00-22:00",
    "wednesday": "09:00-22:00",
    "thursday": "09:00-22:00",
    "friday": "09:00-22:00",
    "saturday": "09:00-22:00",
    "sunday": "09:00-22:00"
  },
  "contact_phone": "+970591234567",  // رقم الهاتف (اختياري)
  "contact_email": "restaurant@example.com", // البريد الإلكتروني (اختياري)
  "menu_url": "https://example.com/menu",    // رابط القائمة (اختياري)
  
  // Common fields
  "rating": 4.5,
  "review_count": 10,
  "coordinates": [
    {"latitude": 31.9522, "longitude": 35.2332}
  ]
}
```

**Features / المميزات:**
- ❌ No registration (لا يوجد تسجيل)
- ✅ Cuisine type (نوع المطبخ)
- ✅ Average price (متوسط السعر)
- ✅ Opening hours (ساعات العمل)
- ✅ Contact information (معلومات الاتصال)
- ✅ Menu link (رابط القائمة)

---

### 5. Tourist Sites (المواقع السياحية) - `type='site'`

**Required Fields / الحقول المطلوبة:**
```json
{
  "id": 1,
  "name": "Tourist Site Name",
  "name_ar": "اسم الموقع السياحي",
  "description": "Site description",
  "description_ar": "وصف الموقع",
  "type": "site",
  "location": "Location",
  "location_ar": "الموقع",
  "latitude": "31.9522",
  "longitude": "35.2332",
  "images": ["url1", "url2"],
  
  // Tourist site-specific fields
  "historical_period": "Byzantine",  // الفترة التاريخية (اختياري)
  "historical_period_ar": "بيزنطي",  // الفترة التاريخية بالعربية (اختياري)
  "entrance_fee": 20.0,              // رسوم الدخول (اختياري)
  "opening_hours": {                 // ساعات العمل (اختياري)
    "monday": "08:00-18:00",
    "tuesday": "08:00-18:00",
    "wednesday": "08:00-18:00",
    "thursday": "08:00-18:00",
    "friday": "08:00-18:00",
    "saturday": "08:00-18:00",
    "sunday": "08:00-18:00"
  },
  "best_time_to_visit": "spring",    // أفضل وقت للزيارة (اختياري)
  "best_time_to_visit_ar": "الربيع", // أفضل وقت للزيارة بالعربية (اختياري)
  "activities": ["cultural", "historical"], // الأنشطة المتاحة (اختياري)
  
  // Common fields
  "rating": 4.5,
  "review_count": 10,
  "coordinates": [
    {"latitude": 31.9522, "longitude": 35.2332}
  ]
}
```

**Features / المميزات:**
- ❌ No registration (لا يوجد تسجيل)
- ✅ Historical information (المعلومات التاريخية)
- ✅ Entrance fee (رسوم الدخول)
- ✅ Opening hours (ساعات العمل)
- ✅ Best time to visit (أفضل وقت للزيارة)
- ✅ Activities (الأنشطة المتاحة)

---

## Database Schema Requirements
## متطلبات قاعدة البيانات

### Sites Table Structure

```sql
CREATE TABLE sites (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    type ENUM('site', 'route', 'camping', 'hotel', 'restaurant') NOT NULL DEFAULT 'site',
    
    -- Basic fields
    name VARCHAR(255) NOT NULL,
    name_ar VARCHAR(255) NOT NULL,
    description TEXT,
    description_ar TEXT,
    location VARCHAR(255),
    location_ar VARCHAR(255),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    
    -- Images
    images JSON, -- Array of image URLs
    
    -- Route/Camping specific
    length DECIMAL(8, 2), -- in kilometers
    estimated_duration INT, -- in hours
    difficulty ENUM('easy', 'medium', 'hard'),
    activities JSON, -- Array of activity types
    guide_id BIGINT,
    price DECIMAL(10, 2),
    
    -- Hotel specific
    star_rating TINYINT, -- 1-5
    price_per_night DECIMAL(10, 2),
    hotel_amenities JSON, -- Array of amenities
    hotel_amenities_ar JSON, -- Array of amenities in Arabic
    room_count INT,
    check_in_time TIME,
    check_out_time TIME,
    
    -- Restaurant specific
    cuisine_type VARCHAR(100),
    cuisine_type_ar VARCHAR(100),
    average_price DECIMAL(10, 2),
    price_range VARCHAR(10), -- $, $$, $$$, $$$$
    opening_hours JSON, -- Object with day:time pairs
    opening_hours_ar JSON,
    menu_url VARCHAR(500),
    
    -- Tourist site specific
    historical_period VARCHAR(100),
    historical_period_ar VARCHAR(100),
    entrance_fee DECIMAL(10, 2),
    best_time_to_visit VARCHAR(50),
    best_time_to_visit_ar VARCHAR(50),
    
    -- Camping specific
    camping_amenities JSON,
    camping_amenities_ar JSON,
    capacity INT,
    
    -- Common fields
    rating DECIMAL(3, 2) DEFAULT 0.0,
    review_count INT DEFAULT 0,
    warnings JSON,
    warnings_ar JSON,
    coordinates JSON, -- Array of {latitude, longitude} objects
    
    -- Contact (for hotels and restaurants)
    contact_phone VARCHAR(20),
    contact_email VARCHAR(255),
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (guide_id) REFERENCES guides(id) ON DELETE SET NULL,
    INDEX idx_type (type),
    INDEX idx_location (latitude, longitude)
);
```

---

## API Response Format
## تنسيق استجابة API

### Single Site Endpoint

**Endpoint:** `GET /api/sites/{id}`

**Response:**
```json
{
  "status": true,
  "data": {
    "id": 1,
    "name": "Site Name",
    "name_ar": "اسم الموقع",
    "type": "route", // or "camping", "hotel", "restaurant", "site"
    // ... all fields based on type
  }
}
```

---

## Summary of Required Backend Changes
## ملخص التعديلات المطلوبة في الباك إند

### 1. Database Migration
- ✅ Add `type` column (if not exists)
- ✅ Add hotel-specific columns
- ✅ Add restaurant-specific columns
- ✅ Add camping-specific columns
- ✅ Add tourist site-specific columns

### 2. API Response
- ✅ Return all type-specific fields in API response
- ✅ Ensure `type` field is always present
- ✅ Return appropriate fields based on `type`

### 3. Validation
- ✅ Validate required fields based on `type`
- ✅ Ensure routes and camping have `guide_id` and `price`
- ✅ Ensure hotels have `star_rating` and `price_per_night`
- ✅ Ensure restaurants have `cuisine_type` and `average_price`

---

**Last Updated / آخر تحديث:** 2024

