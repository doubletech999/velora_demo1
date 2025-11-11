# 📋 متطلبات تعديل Laravel Backend

## 🎯 الهدف
تعديل Laravel API لدعم التطبيق Flutter الذي يفصل بين:
- **الأماكن السياحية** (Tourist Sites)
- **المسارات** (Routes)
- **التخييمات** (Camping)

---

## 🔧 التعديلات المطلوبة

### 1. API Endpoint: `/api/sites`

#### المطلوب:
- يجب أن يدعم الـ endpoint معامل `type` للتصنيف:
  - `type=site` → الأماكن السياحية فقط
  - `type=route` → المسارات فقط
  - `type=camping` → التخييمات فقط
  - `type=null` أو بدون معامل → جميع المواقع

#### Request Format:
```
GET /api/sites?type=site&page=1
GET /api/sites?type=route&page=1
GET /api/sites?type=camping&page=1
GET /api/sites?page=1 (جميع المواقع)
```

#### Response Format:
```json
{
  "data": [
    {
      "id": 1,
      "name": "اسم الموقع",
      "name_ar": "اسم الموقع بالعربية",
      "description": "الوصف",
      "description_ar": "الوصف بالعربية",
      "type": "site", // أو "route" أو "camping"
      "location": "الموقع",
      "location_ar": "الموقع بالعربية",
      "latitude": "31.9522",
      "longitude": "35.2332",
      "images": ["url1", "url2"],
      "length": 5.0, // المسافة بالكيلومتر
      "distance": 5.0, // أو distance_km
      "estimated_duration": 2, // الساعات
      "duration": 2, // أو duration_hours
      "difficulty": "easy", // أو "medium" أو "hard"
      "activities": ["hiking", "camping"], // قائمة الأنشطة
      "rating": 4.5,
      "review_count": 10,
      "price": 100.0,
      "guide_id": 1,
      "guide_name": "اسم المرشد",
      "guide_name_ar": "اسم المرشد بالعربية",
      "guide": {
        "id": 1,
        "name": "اسم المرشد",
        "name_ar": "اسم المرشد بالعربية",
        "route_price": 100.0,
        "user": {
          "name": "اسم المستخدم",
          "name_ar": "اسم المستخدم بالعربية"
        }
      }
    }
  ],
  "current_page": 1,
  "last_page": 5,
  "per_page": 10,
  "total": 50
}
```

#### Pagination:
- يجب دعم pagination بشكل كامل
- يجب إرجاع `current_page`, `last_page`, `per_page`, `total`
- Flutter سيجلب جميع الصفحات تلقائياً

---

### 2. تصنيف البيانات حسب Type

#### في Database:
- يجب أن يكون هناك عمود `type` في جدول `sites` أو `paths`
- القيم الممكنة: `'site'`, `'route'`, `'camping'`

#### في Migration:
```php
Schema::table('sites', function (Blueprint $table) {
    $table->enum('type', ['site', 'route', 'camping'])->default('site')->after('id');
});
```

#### في Controller:
```php
public function index(Request $request)
{
    $query = Site::query();
    
    // Filter by type
    if ($request->has('type') && $request->type) {
        $query->where('type', $request->type);
    }
    
    // Pagination
    $sites = $query->paginate(10);
    
    return response()->json($sites);
}
```

---

### 3. Activities Field

#### المطلوب:
- يجب أن يكون `activities` حقل JSON أو علاقة many-to-many
- القيم الممكنة: `["hiking", "camping", "climbing", "religious", "cultural", "nature", "archaeological"]`

#### في Database:
```php
// Option 1: JSON column
$table->json('activities')->nullable();

// Option 2: Many-to-many relationship
// Create activities table and pivot table
```

#### في Model:
```php
protected $casts = [
    'activities' => 'array',
];
```

---

### 4. Guide Information

#### المطلوب:
- يجب أن يحتوي الـ response على معلومات المرشد
- يجب أن يشمل `guide_name` و `guide_name_ar` في الـ response الرئيسي
- يجب أن يشمل `guide` object مع `user` relation

#### في Resource:
```php
public function toArray($request)
{
    return [
        'id' => $this->id,
        'name' => $this->name,
        'name_ar' => $this->name_ar,
        'guide_id' => $this->guide_id,
        'guide_name' => $this->guide->user->name ?? null,
        'guide_name_ar' => $this->guide->user->name_ar ?? null,
        'guide' => [
            'id' => $this->guide->id,
            'name' => $this->guide->user->name ?? null,
            'name_ar' => $this->guide->user->name_ar ?? null,
            'route_price' => $this->guide->route_price,
            'user' => [
                'name' => $this->guide->user->name,
                'name_ar' => $this->guide->user->name_ar,
            ],
        ],
    ];
}
```

---

### 5. Coordinates Format

#### المطلوب:
- يجب أن يكون `latitude` و `longitude` كـ string أو number
- Flutter يدعم كلا النوعين

#### في Database:
```php
$table->decimal('latitude', 10, 8)->nullable();
$table->decimal('longitude', 11, 8)->nullable();
```

#### في Resource:
```php
'latitude' => (string) $this->latitude,
'longitude' => (string) $this->longitude,
// أو
'latitude' => $this->latitude,
'longitude' => $this->longitude,
```

---

### 6. Images Format

#### المطلوب:
- يجب أن يكون `images` array من URLs
- يجب أن تكون URLs كاملة (مع http:// أو https://)

#### في Resource:
```php
'images' => $this->images->map(function ($image) {
    return asset('storage/' . $image->path);
})->toArray(),
// أو
'images' => json_decode($this->images) ?? [],
```

---

### 7. Duration Format

#### المطلوب:
- يجب أن يكون `estimated_duration` أو `duration` أو `duration_hours` كـ number (الساعات)
- Flutter ستحولها إلى `Duration`

#### في Database:
```php
$table->integer('estimated_duration')->default(2); // بالساعات
```

#### في Resource:
```php
'estimated_duration' => $this->estimated_duration,
'duration' => $this->estimated_duration,
'duration_hours' => $this->estimated_duration,
```

---

### 8. Price Format

#### المطلوب:
- يجب أن يكون `price` كـ number
- يجب أن يكون `route_price` في `guide` object

#### في Resource:
```php
'price' => (float) $this->price,
'guide' => [
    'route_price' => (float) $this->guide->route_price,
],
```

---

### 9. Rating and Reviews

#### المطلوب:
- يجب أن يكون `rating` كـ number (0-5)
- يجب أن يكون `review_count` أو `reviews_count` كـ number

#### في Resource:
```php
'rating' => (float) $this->rating,
'review_count' => $this->reviews()->count(),
'reviews_count' => $this->reviews()->count(),
```

---

### 10. Authentication (Optional)

#### المطلوب:
- يجب أن يعمل الـ endpoint بدون authentication (للضيف)
- إذا كان هناك Bearer Token، يجب استخدامه
- Flutter سيجرب مع authentication أولاً، ثم بدون

#### في Controller:
```php
public function index(Request $request)
{
    // الـ endpoint يعمل بدون authentication
    // ولكن يمكن الحصول على user إذا كان موجود
    $user = $request->user(); // null إذا لم يكن مسجل دخول
    
    $query = Site::query();
    // ... باقي الكود
}
```

---

### 11. CORS Configuration

#### المطلوب:
- يجب تفعيل CORS للـ Flutter Web
- يجب السماح بـ `localhost` و `10.0.2.2` (Android Emulator)

#### في `config/cors.php`:
```php
'paths' => ['api/*'],
'allowed_methods' => ['*'],
'allowed_origins' => ['http://localhost:*', 'http://10.0.2.2:*'],
'allowed_headers' => ['*'],
'supports_credentials' => true,
```

---

### 12. Search Functionality

#### المطلوب:
- يجب دعم البحث عبر معامل `search`

#### في Controller:
```php
if ($request->has('search') && $request->search) {
    $query->where(function ($q) use ($request) {
        $q->where('name', 'like', '%' . $request->search . '%')
          ->orWhere('name_ar', 'like', '%' . $request->search . '%')
          ->orWhere('description', 'like', '%' . $request->search . '%')
          ->orWhere('description_ar', 'like', '%' . $request->search . '%');
    });
}
```

---

## 📝 ملخص التعديلات

### Database:
1. ✅ إضافة عمود `type` (enum: 'site', 'route', 'camping')
2. ✅ إضافة عمود `activities` (JSON)
3. ✅ التأكد من وجود `latitude`, `longitude`
4. ✅ التأكد من وجود `estimated_duration`
5. ✅ التأكد من وجود `price`
6. ✅ التأكد من وجود `rating`, `review_count`

### API:
1. ✅ دعم معامل `type` في `/api/sites`
2. ✅ دعم pagination
3. ✅ دعم البحث عبر `search`
4. ✅ إرجاع `guide` information
5. ✅ إرجاع `guide_name` و `guide_name_ar` في الـ response الرئيسي

### Response Format:
1. ✅ جميع الحقول المطلوبة موجودة
2. ✅ الصيغة متوافقة مع Flutter
3. ✅ دعم أنواع البيانات المختلفة (string/number)

---

## 🧪 اختبار API

### Test URLs:
```
# الأماكن السياحية
GET http://localhost:8000/api/sites?type=site&page=1

# المسارات
GET http://localhost:8000/api/sites?type=route&page=1

# التخييمات
GET http://localhost:8000/api/sites?type=camping&page=1

# جميع المواقع
GET http://localhost:8000/api/sites?page=1

# البحث
GET http://localhost:8000/api/sites?search=جبل&page=1
```

### Expected Response:
- يجب أن يرجع pagination data
- يجب أن يحتوي كل item على جميع الحقول المطلوبة
- يجب أن يكون `type` موجود في كل item

---

## ✅ Checklist

- [ ] إضافة عمود `type` في migration
- [ ] تعديل Controller لدعم `type` filter
- [ ] تعديل Resource لإرجاع جميع الحقول المطلوبة
- [ ] إضافة `guide_name` و `guide_name_ar` في response
- [ ] التأكد من pagination
- [ ] التأكد من CORS
- [ ] اختبار API endpoints
- [ ] التأكد من توافق Response format مع Flutter

---

## 📞 ملاحظات إضافية

1. **Backward Compatibility**: يجب أن يعمل API بدون `type` (يرجع جميع المواقع)
2. **Performance**: يجب استخدام eager loading للـ relationships (`with('guide.user')`)
3. **Validation**: يجب التحقق من `type` values ('site', 'route', 'camping')
4. **Error Handling**: يجب إرجاع error messages واضحة عند فشل الطلب

---

## 🎯 النتيجة النهائية

بعد تطبيق هذه التعديلات، يجب أن يعمل Flutter App بشكل صحيح مع Laravel API:
- ✅ جلب الأماكن السياحية (`type=site`)
- ✅ جلب المسارات (`type=route`)
- ✅ جلب التخييمات (`type=camping`)
- ✅ عرض جميع البيانات بشكل صحيح
- ✅ دعم pagination
- ✅ دعم البحث

