# 🖼️ متطلبات Laravel للصور المرفوعة من الجهاز

## المشكلة
الصور المرفوعة من الجهاز في Laravel لا تظهر في Flutter App.

## الحلول المطبقة في Flutter

### 1. تحسين `PathModel.fromJson()`
- ✅ دعم جميع أشكال الصور: `images`, `image_url`, `image`, `photo`, `photos`
- ✅ دعم List و String
- ✅ معالجة paths نسبية و URLs كاملة
- ✅ بناء URLs كاملة تلقائياً للصور المرفوعة

### 2. تحسين `_buildImageUrl()`
- ✅ دعم paths نسبية: `/storage/`, `storage/`, `/images/`, `images/`
- ✅ دعم URLs كاملة: `http://`, `https://`
- ✅ تنظيف المسارات (إزالة `public/`, إضافة `/storage/`)
- ✅ بناء URLs حسب البيئة (Web vs Mobile)

---

## متطلبات Laravel Backend

### 1. Laravel يجب أن يرجع URLs كاملة (مفضل)

في `SiteResource` أو `SiteController`:

```php
// Option 1: استخدام asset() helper (مفضل)
'images' => $this->images->map(function ($image) {
    return asset('storage/' . $image->path);
})->toArray(),

// أو إذا كانت الصور في جدول منفصل
'images' => $this->whenLoaded('images', function () {
    return $this->images->map(function ($image) {
        return asset('storage/' . $image->path);
    })->toList();
}),
```

### 2. أو Paths نسبية (مدعوم أيضاً)

```php
// Option 2: Paths نسبية (يعمل أيضاً مع Flutter)
'images' => $this->images->map(function ($image) {
    return '/storage/' . $image->path;
})->toArray(),
```

### 3. التأكد من Storage Link

```bash
php artisan storage:link
```

هذا ينشئ symlink من `public/storage` إلى `storage/app/public`.

### 4. التأكد من Disk Configuration

في `config/filesystems.php`:

```php
'disks' => [
    'public' => [
        'driver' => 'local',
        'root' => storage_path('app/public'),
        'url' => env('APP_URL').'/storage',
        'visibility' => 'public',
    ],
],
```

---

## هيكل البيانات المتوقع من Laravel

### Scenario 1: URLs كاملة (مفضل)
```json
{
  "id": 1,
  "name": "Site Name",
  "images": [
    "http://localhost:8000/storage/images/photo1.jpg",
    "http://localhost:8000/storage/images/photo2.jpg"
  ]
}
```

### Scenario 2: Paths نسبية (مدعوم)
```json
{
  "id": 1,
  "name": "Site Name",
  "images": [
    "/storage/images/photo1.jpg",
    "/storage/images/photo2.jpg"
  ]
}
```

### Scenario 3: Single Image URL
```json
{
  "id": 1,
  "name": "Site Name",
  "image_url": "http://localhost:8000/storage/images/photo1.jpg"
}
```

### Scenario 4: Single Image Path
```json
{
  "id": 1,
  "name": "Site Name",
  "image_url": "/storage/images/photo1.jpg"
}
```

---

## مثال كامل لـ SiteResource

```php
<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class SiteResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'name_ar' => $this->name_ar,
            
            // ⭐ الصور - استخدام asset() لبناء URLs كاملة
            'images' => $this->when($this->relationLoaded('images'), function () {
                return $this->images->map(function ($image) {
                    // Option 1: URL كامل (مفضل)
                    return asset('storage/' . $image->path);
                    
                    // Option 2: Path نسبي (يعمل أيضاً)
                    // return '/storage/' . $image->path;
                })->toArray();
            }, function () {
                // Fallback: إذا لم تكن images relation محملة
                // يمكن استخدام image_url من الموديل مباشرة
                if ($this->image_url) {
                    return [asset('storage/' . $this->image_url)];
                }
                return [];
            }),
            
            // ⭐ صورة واحدة (للتوافق مع الكود القديم)
            'image_url' => $this->image_url 
                ? asset('storage/' . $this->image_url)
                : null,
            
            // ... باقي الحقول
        ];
    }
}
```

---

## كيفية رفع الصور في Laravel

### في Controller:

```php
public function store(Request $request)
{
    $validated = $request->validate([
        'name' => 'required|string',
        'images' => 'nullable|array',
        'images.*' => 'image|mimes:jpeg,png,jpg,gif|max:2048',
    ]);
    
    $site = Site::create([
        'name' => $validated['name'],
        // ... باقي الحقول
    ]);
    
    // رفع الصور
    if ($request->hasFile('images')) {
        foreach ($request->file('images') as $image) {
            $path = $image->store('images', 'public');
            
            // حفظ في جدول images (إذا كان منفصل)
            $site->images()->create([
                'path' => $path,
                'original_name' => $image->getClientOriginalName(),
            ]);
        }
    }
    
    return new SiteResource($site);
}
```

---

## اختبار الصور

### 1. Test Laravel API مباشرة:

```bash
curl http://localhost:8000/api/sites/1
```

### 2. تحقق من Response:
```json
{
  "data": {
    "id": 1,
    "images": [
      "http://localhost:8000/storage/images/photo1.jpg"
    ]
  }
}
```

### 3. Test Image URL مباشرة:
افتح في المتصفح:
```
http://localhost:8000/storage/images/photo1.jpg
```

إذا ظهرت الصورة، فهذا يعني أن Laravel config صحيح.

---

## مشاكل شائعة وحلولها

### المشكلة 1: الصور لا تظهر في المتصفح
**الحل:**
```bash
php artisan storage:link
```

### المشكلة 2: 404 Not Found للصور
**الحل:**
- تحقق من أن الصور موجودة في `storage/app/public/images/`
- تحقق من أن symlink موجود في `public/storage`

### المشكلة 3: CORS Error
**الحل:**
في `config/cors.php`:
```php
'paths' => ['api/*', 'storage/*'],
```

### المشكلة 4: Flutter لا يظهر الصور
**الحل:**
- تحقق من Console logs في Flutter
- تحقق من Network tab في Browser
- تحقق من أن URLs صحيحة

---

## Checklist

- [ ] Laravel يرجع URLs كاملة للصور (استخدام `asset()`)
- [ ] `php artisan storage:link` تم تنفيذه
- [ ] الصور موجودة في `storage/app/public/images/`
- [ ] CORS مُعد بشكل صحيح
- [ ] Flutter يبني URLs صحيحة
- [ ] الصور تظهر في المتصفح مباشرة
- [ ] الصور تظهر في Flutter App

---

## النتيجة المتوقعة

بعد تطبيق هذه التعديلات:
- ✅ Laravel يرجع URLs كاملة للصور
- ✅ Flutter يبني URLs صحيحة للصور المرفوعة
- ✅ الصور تظهر في التطبيق بشكل صحيح
- ✅ الصور تعمل على Web و Mobile

