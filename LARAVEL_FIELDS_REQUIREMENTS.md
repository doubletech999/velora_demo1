# متطلبات حقول Laravel API

## 📋 الحقول المطلوبة في Laravel API

عند إضافة موقع/مسار جديد من لوحة الإدارة، يجب أن يتضمن Laravel API هذه الحقول:

### ✅ الحقول الأساسية (مطلوبة):

```json
{
  "id": 1,
  "name": "Church of the Nativity",
  "name_ar": "كنيسة المهد",
  "description": "The Church of the Nativity...",
  "description_ar": "كنيسة المهد...",
  "latitude": "31.70400000",
  "longitude": "35.20660000",
  "type": "historical",
  "image_url": "https://example.com/image.jpg"
}
```

### ✅ الحقول الإضافية (اختيارية - لكن موصى بها):

```json
{
  // السعر
  "price": 250.0,
  
  // اسم المرشد
  "guide_id": 1,
  "guide_name": "Ahmed Al-Masri",
  "guide_name_ar": "أحمد المصري",
  
  // أو كائن guide كامل
  "guide": {
    "id": 1,
    "name": "Ahmed Al-Masri",
    "name_ar": "أحمد المصري",
    "route_price": 250.0
  },
  
  // المسافة (بالكيلومتر)
  "distance": 12.5,
  "length": 12.5,
  "distance_km": 12.5,
  
  // المدة (بالساعات)
  "duration": 4,
  "estimated_duration": 4,
  "duration_hours": 4,
  
  // الأنشطة المتاحة
  "activities": ["hiking", "nature", "cultural"],
  // أو
  "activity": "hiking",
  // أو
  "activities": "hiking,nature,cultural",
  
  // مستوى الصعوبة
  "difficulty": "medium", // easy, medium, hard
  
  // الموقع
  "location": "Bethlehem",
  "location_ar": "بيت لحم",
  
  // التقييم
  "rating": 4.7,
  "review_count": 128
}
```

---

## 🔄 كيفية إضافة موقع جديد في Laravel

### 1. من لوحة الإدارة:

عند إضافة موقع جديد، تأكد من إضافة:

- ✅ **السعر** (`price`)
- ✅ **اسم المرشد** (`guide_name` و `guide_name_ar`)
- ✅ **المسافة** (`distance` أو `length`)
- ✅ **المدة** (`duration` أو `estimated_duration`)
- ✅ **الأنشطة** (`activities`)

### 2. مثال على البيانات المطلوبة:

```php
// في Laravel Controller
$site = Site::create([
    'name' => 'Church of the Nativity',
    'name_ar' => 'كنيسة المهد',
    'description' => '...',
    'description_ar' => '...',
    'latitude' => 31.70400000,
    'longitude' => 35.20660000,
    'type' => 'historical',
    'image_url' => 'https://example.com/image.jpg',
    
    // الحقول الجديدة
    'price' => 250.0,
    'guide_id' => 1,
    'guide_name' => 'Ahmed Al-Masri',
    'guide_name_ar' => 'أحمد المصري',
    'distance' => 12.5,
    'duration' => 4,
    'activities' => json_encode(['hiking', 'cultural']),
    'difficulty' => 'medium',
    'location' => 'Bethlehem',
    'location_ar' => 'بيت لحم',
]);
```

---

## 📊 تنسيق الاستجابة من Laravel

### GET `/api/sites`

```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "name": "Church of the Nativity",
      "name_ar": "كنيسة المهد",
      "description": "...",
      "description_ar": "...",
      "latitude": "31.70400000",
      "longitude": "35.20660000",
      "type": "historical",
      "image_url": "https://example.com/image.jpg",
      "price": 250.0,
      "guide_id": 1,
      "guide_name": "Ahmed Al-Masri",
      "guide_name_ar": "أحمد المصري",
      "distance": 12.5,
      "duration": 4,
      "activities": ["hiking", "cultural"],
      "difficulty": "medium",
      "location": "Bethlehem",
      "location_ar": "بيت لحم",
      "rating": 4.7,
      "review_count": 128,
      "created_at": "2025-10-07T19:58:02.000000Z",
      "updated_at": "2025-10-07T19:58:02.000000Z"
    }
  ]
}
```

---

## ✅ ما تم إضافته في Flutter

### 1. **دعم الحقول الجديدة:**
- ✅ `price` - السعر
- ✅ `guide_name` و `guide_name_ar` - اسم المرشد
- ✅ `distance`, `length`, `distance_km` - المسافة
- ✅ `duration`, `estimated_duration`, `duration_hours` - المدة
- ✅ `activities` (List, String, أو مفرد) - الأنشطة
- ✅ `difficulty` - مستوى الصعوبة

### 2. **عرض الحقول في UI:**
- ✅ السعر يظهر في `PathCard`
- ✅ اسم المرشد يظهر في `PathCard`
- ✅ المسافة والمدة تظهر بالفعل
- ✅ الأنشطة تظهر بالفعل

### 3. **دعم الصور من URL:**
- ✅ يدعم `http://` و `https://`
- ✅ يدعم `assets/` للصور المحلية

---

## 🎯 الخطوات التالية

### في Laravel:

1. **أضف الحقول الجديدة إلى Migration:**
   ```php
   $table->decimal('price', 10, 2)->nullable();
   $table->string('guide_name')->nullable();
   $table->string('guide_name_ar')->nullable();
   $table->decimal('distance', 8, 2)->nullable();
   $table->integer('duration')->nullable(); // بالساعات
   $table->json('activities')->nullable();
   $table->enum('difficulty', ['easy', 'medium', 'hard'])->default('medium');
   ```

2. **أضف الحقول إلى Model:**
   ```php
   protected $fillable = [
       'name', 'name_ar', 'description', 'description_ar',
       'latitude', 'longitude', 'type', 'image_url',
       'price', 'guide_id', 'guide_name', 'guide_name_ar',
       'distance', 'duration', 'activities', 'difficulty',
       'location', 'location_ar'
   ];
   ```

3. **أضف الحقول إلى API Resource:**
   ```php
   return [
       'id' => $this->id,
       'name' => $this->name,
       'name_ar' => $this->name_ar,
       'price' => $this->price,
       'guide_name' => $this->guide_name,
       'guide_name_ar' => $this->guide_name_ar,
       'distance' => $this->distance,
       'duration' => $this->duration,
       'activities' => json_decode($this->activities ?? '[]'),
       'difficulty' => $this->difficulty,
       // ... باقي الحقول
   ];
   ```

---

## ✅ النتيجة

الآن عندما تضيف موقع/مسار جديد من لوحة الإدارة مع:
- ✅ السعر
- ✅ اسم المرشد
- ✅ المسافة
- ✅ المدة
- ✅ الأنشطة

**سيظهر تلقائياً في التطبيق Flutter مع جميع هذه المعلومات!** 🎉


