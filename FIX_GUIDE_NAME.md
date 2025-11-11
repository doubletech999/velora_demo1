# إصلاح مشكلة عدم ظهور اسم المرشد

## 🔍 المشكلة

اسم المرشد لا يظهر في التطبيق لأن Laravel لا يعيد `guide_name` في استجابة API.

## ✅ الحل في Laravel

### 1. أضف الحقول إلى Migration (إذا لم تكن موجودة):

```php
// في migration الخاص بـ sites
$table->string('guide_name')->nullable();
$table->string('guide_name_ar')->nullable();
$table->unsignedBigInteger('guide_id')->nullable();
```

### 2. أضف الحقول إلى Model:

```php
// في Site.php
protected $fillable = [
    // ... الحقول الأخرى
    'guide_id',
    'guide_name',
    'guide_name_ar',
];
```

### 3. أضف الحقول إلى API Resource:

```php
// في SiteResource.php أو في Controller
return [
    'id' => $this->id,
    'name' => $this->name,
    'name_ar' => $this->name_ar,
    // ... باقي الحقول
    
    // ✅ أضف هذه الحقول
    'guide_id' => $this->guide_id,
    'guide_name' => $this->guide_name,
    'guide_name_ar' => $this->guide_name_ar,
    
    // أو إذا كان لديك relation
    'guide' => $this->whenLoaded('guide', function () {
        return [
            'id' => $this->guide->id,
            'name' => $this->guide->user->name ?? $this->guide_name,
            'name_ar' => $this->guide->user->name_ar ?? $this->guide_name_ar,
        ];
    }),
];
```

### 4. عند إضافة موقع جديد من لوحة الإدارة:

تأكد من إضافة:
- ✅ `guide_id` - رقم المرشد
- ✅ `guide_name` - اسم المرشد بالإنجليزية
- ✅ `guide_name_ar` - اسم المرشد بالعربية

---

## 🔄 الحل البديل (إذا كان لديك Guide Relation)

إذا كان لديك relation بين Site و Guide:

```php
// في Site.php
public function guide()
{
    return $this->belongsTo(Guide::class);
}

// في API Resource
'guide' => $this->whenLoaded('guide', function () {
    return [
        'id' => $this->guide->id,
        'name' => $this->guide->user->name ?? 'Guide',
        'name_ar' => $this->guide->user->name_ar ?? 'مرشد',
    ];
}),
```

ثم في Controller:

```php
public function index()
{
    $sites = Site::with('guide.user')->get();
    return SiteResource::collection($sites);
}
```

---

## 📋 مثال على البيانات المطلوبة من Laravel:

```json
{
  "id": 1,
  "name": "Church of the Nativity",
  "name_ar": "كنيسة المهد",
  "guide_id": 1,
  "guide_name": "Ahmed Al-Masri",
  "guide_name_ar": "أحمد المصري",
  "price": 250.0,
  "distance": 12.5,
  "duration": 4,
  "activities": ["hiking", "cultural"]
}
```

أو مع relation:

```json
{
  "id": 1,
  "name": "Church of the Nativity",
  "guide_id": 1,
  "guide": {
    "id": 1,
    "user": {
      "name": "Ahmed Al-Masri",
      "name_ar": "أحمد المصري"
    }
  }
}
```

---

## 🧪 اختبار الحل

1. **أعد تشغيل التطبيق** (Hot Restart)
2. **افتح Console** وراقب الـ logs:
   - `🔍 تحليل بيانات المرشد:`
   - `  - guide_name: ...`
   - `  - تم استخدام guide object: ...`

3. **إذا رأيت** `⚠️ تم استخدام guide افتراضي`:
   - Laravel لا يعيد `guide_name`
   - أضف الحقول إلى Laravel كما هو موضح أعلاه

---

## ✅ بعد إضافة الحقول في Laravel

1. **أضف موقع جديد** من لوحة الإدارة مع:
   - اسم المرشد
   - السعر
   - المسافة
   - المدة

2. **أعد تحميل التطبيق** - يجب أن يظهر اسم المرشد!

---

## 📝 ملاحظات

- ✅ التطبيق يدعم الآن أشكال مختلفة من بيانات المرشد
- ✅ إذا لم يكن هناك `guide_name`، سيظهر "مرشد" كافتراضي
- ✅ الـ logs ستوضح بالضبط ما يعيده Laravel


