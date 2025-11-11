# 📋 متطلبات Laravel Backend الكاملة - فكرة المسارات الجديدة

## 🎯 الفكرة الأساسية

التطبيق Flutter الآن مبني على أساس أن **المسارات والتخييم** هي المحتوى الأساسي في التطبيق، وليس الأماكن السياحية.

### التصنيف:
- **Routes (المسارات)** - `type='route'` ⭐ **الأساسي**
- **Camping (التخييم)** - `type='camping'` ⭐ **الأساسي**
- **Sites (الأماكن السياحية)** - `type='site'` ⚠️ **ثانوي**

---

## 🗄️ 1. Database Migration

```php
Schema::table('sites', function (Blueprint $table) {
    $table->enum('type', ['site', 'route', 'camping'])
          ->default('site')
          ->after('id');
});
```

**تحديث البيانات الموجودة:**
```php
// المسارات
DB::table('sites')->whereJsonContains('activities', 'hiking')
   ->orWhere('length', '>=', 5.0)
   ->update(['type' => 'route']);

// التخييم
DB::table('sites')->whereJsonContains('activities', 'camping')
   ->update(['type' => 'camping']);

// الباقي
DB::table('sites')->whereNull('type')->update(['type' => 'site']);
```

---

## 🎯 2. API Controller

### `SiteController@index`:

```php
public function index(Request $request)
{
    $query = Site::with(['guide.user', 'reviews']);
    
    // ⭐ Filter by type (مهم جداً)
    if ($request->has('type') && $request->type) {
        $validTypes = ['site', 'route', 'camping'];
        if (in_array($request->type, $validTypes)) {
            $query->where('type', $request->type);
        }
    }
    
    // Search
    if ($request->has('search') && $request->search) {
        $query->where(function ($q) use ($request) {
            $q->where('name', 'like', "%{$request->search}%")
              ->orWhere('name_ar', 'like', "%{$request->search}%");
        });
    }
    
    // Pagination (مهم جداً - Laravel paginate format)
    $sites = $query->paginate(10);
    
    return SiteResource::collection($sites)->response();
}
```

---

## 📦 3. API Resource

### `SiteResource`:

```php
public function toArray($request)
{
    return [
        'id' => $this->id,
        'name' => $this->name,
        'name_ar' => $this->name_ar,
        'type' => $this->type, // ⭐ مهم جداً
        'location' => $this->location,
        'location_ar' => $this->location_ar,
        'latitude' => (string) $this->latitude,
        'longitude' => (string) $this->longitude,
        'images' => $this->images->map(fn($img) => asset('storage/'.$img->path))->toArray(),
        'length' => (float) $this->length,
        'estimated_duration' => (int) $this->estimated_duration,
        'difficulty' => $this->difficulty,
        'activities' => $this->activities ?? [],
        'rating' => (float) $this->rating,
        'review_count' => $this->reviews()->count(),
        'price' => (float) $this->price,
        
        // ⭐ Guide info (مهم جداً)
        'guide_id' => $this->guide_id,
        'guide_name' => $this->guide->user->name ?? null,
        'guide_name_ar' => $this->guide->user->name_ar ?? null,
        
        'guide' => [
            'id' => $this->guide->id,
            'name' => $this->guide->user->name ?? null,
            'name_ar' => $this->guide->user->name_ar ?? null,
            'route_price' => (float) $this->guide->route_price,
            'user' => [
                'name' => $this->guide->user->name,
                'name_ar' => $this->guide->user->name_ar,
            ],
        ],
    ];
}
```

---

## 🎨 4. Admin Panel

### Filter Tabs:

```blade
<ul class="nav nav-tabs">
    <li><a href="?type=all">All</a></li>
    <li><a href="?type=route">Routes (Primary) ⭐</a></li>
    <li><a href="?type=camping">Camping (Primary) ⭐</a></li>
    <li><a href="?type=site">Tourist Sites (Secondary)</a></li>
</ul>
```

### Type Field in Form:

```blade
<select name="type" required>
    <option value="route">Route (Primary) ⭐</option>
    <option value="camping">Camping (Primary) ⭐</option>
    <option value="site">Tourist Site (Secondary)</option>
</select>
```

### Badge in Table:

```blade
@if($site->type == 'route')
    <span class="badge badge-primary">Route Primary</span>
@elseif($site->type == 'camping')
    <span class="badge badge-success">Camping Primary</span>
@else
    <span class="badge badge-secondary">Tourist Site Secondary</span>
@endif
```

---

## 📊 5. Response Format (Laravel Pagination)

```json
{
  "data": [
    {
      "id": 12,
      "name": "Site Name",
      "name_ar": "اسم الموقع",
      "type": "route",
      "guide_name": "Guide Name",
      "guide_name_ar": "اسم المرشد",
      "guide": { ... },
      ...
    }
  ],
  "current_page": 1,
  "last_page": 1,
  "per_page": 10,
  "total": 1
}
```

---

## 🧪 6. Endpoints

```
GET /api/sites?type=route&page=1    → المسارات (الأساسية)
GET /api/sites?type=camping&page=1  → التخييم (الأساسية)
GET /api/sites?type=site&page=1     → الأماكن السياحية (ثانوية)
GET /api/sites?page=1               → جميع المواقع
```

---

## ✅ Checklist

- [ ] Migration: إضافة `type` column
- [ ] Update existing data
- [ ] Controller: دعم `type` filter
- [ ] Resource: إضافة `type`, `guide_name`, `guide_name_ar`
- [ ] Admin Panel: Filter Tabs
- [ ] Admin Panel: Type field in form
- [ ] Admin Panel: Badge in table
- [ ] Admin Panel: Statistics
- [ ] Test API endpoints
- [ ] Test Admin Panel

---

## 🎯 النتيجة

بعد التطبيق:
- ✅ Routes هي المحتوى الأساسي
- ✅ Camping جزء من المحتوى الأساسي
- ✅ Sites محتوى ثانوي
- ✅ Admin Panel يدعم التصنيف
- ✅ API يدعم التصنيف
- ✅ Flutter App يعمل بشكل صحيح

