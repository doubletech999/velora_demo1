# 🔍 تصنيف المواقع والمسارات حسب Type

## المشكلة
المستخدم يريد:
1. **المواقع (Sites)**: أن تأتي من `sites` table في قاعدة البيانات حيث `type='site'`
2. **المسارات (Routes)**: أن تأتي من الأشياء المضافة في "المسارات والتخييم" - أي `type='route'` أو `type='camping'`

## الحل المطبق

### 1. إضافة حقل `type` إلى `PathModel`
- ✅ إضافة `final String? type;` إلى `PathModel`
- ✅ حفظ `type` من JSON في `fromJson()`
- ✅ حفظ `type` في `toJson()`
- ✅ إضافة `type` إلى `copyWith()`

### 2. تحسين `PathModel.fromJson()`
- ✅ حفظ `type` من JSON مباشرة
- ✅ استخدام `type` لتحديد `activities` تلقائياً:
  - `type='site'` → `activities = [ActivityType.nature]`
  - `type='route'` → `activities = [ActivityType.hiking]`
  - `type='camping'` → `activities = [ActivityType.camping, ActivityType.hiking]`

### 3. تحسين `PathsRepository`
- ✅ `getSites()` يستدعي `_fetchSitesFromApi(type: 'site')` - جلب المواقع فقط
- ✅ `getRoutesAndCamping()` يستدعي:
  - `_fetchSitesFromApi(type: 'route')` - جلب المسارات
  - `_fetchSitesFromApi(type: 'camping')` - جلب التخييمات
  - دمج النتائج

### 4. تحسين `PathsProvider`
- ✅ عند تحميل البيانات من cache، استخدام `path.type` مباشرة للتصنيف
- ✅ للأماكن السياحية: `path.type == 'site'`
- ✅ للمسارات والتخييمات: `path.type == 'route' || path.type == 'camping'`
- ✅ Fallback: استخدام `activities` و `length` إذا لم يكن `type` موجوداً

---

## كيف يعمل التصنيف

### المواقع (Sites):
```dart
// في PathsRepository.getSites()
final sites = await _fetchSitesFromApi(type: 'site', search: null);
// يرسل: GET /api/sites?type=site
// Laravel يرجع: جميع المواقع حيث type='site'
```

### المسارات والتخييمات (Routes & Camping):
```dart
// في PathsRepository.getRoutesAndCamping()
final routes = await _fetchSitesFromApi(type: 'route', search: null);
final camping = await _fetchSitesFromApi(type: 'camping', search: null);
// يرسل: GET /api/sites?type=route
//        GET /api/sites?type=camping
// Laravel يرجع: جميع المسارات حيث type='route' أو type='camping'
```

---

## Laravel Backend Requirements

### في `SiteController`:

```php
public function index(Request $request)
{
    $query = Site::query();
    
    // Filter by type
    if ($request->has('type')) {
        $type = $request->get('type');
        $query->where('type', $type);
    }
    
    // Filter by search
    if ($request->has('search')) {
        $search = $request->get('search');
        $query->where(function($q) use ($search) {
            $q->where('name', 'like', "%{$search}%")
              ->orWhere('name_ar', 'like', "%{$search}%")
              ->orWhere('description', 'like', "%{$search}%")
              ->orWhere('description_ar', 'like', "%{$search}%");
        });
    }
    
    $sites = $query->paginate(10);
    
    return response()->json($sites);
}
```

### Response Format:
```json
{
  "data": [
    {
      "id": 1,
      "name": "Site Name",
      "name_ar": "اسم الموقع",
      "type": "site",  // أو "route" أو "camping"
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

## الاختبار

### 1. Test API مباشرة:

#### جلب المواقع:
```bash
curl -X GET "https://trevally-unpatented-christia.ngrok-free.dev/api/sites?type=site" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "ngrok-skip-browser-warning: true"
```

#### جلب المسارات:
```bash
curl -X GET "https://trevally-unpatented-christia.ngrok-free.dev/api/sites?type=route" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "ngrok-skip-browser-warning: true"
```

#### جلب التخييمات:
```bash
curl -X GET "https://trevally-unpatented-christia.ngrok-free.dev/api/sites?type=camping" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "ngrok-skip-browser-warning: true"
```

### 2. Test Flutter App:
- ✅ افتح Flutter App
- ✅ انتقل إلى صفحة "Explore"
- ✅ اضغط على تبويب "الأماكن السياحية" - يجب أن تظهر المواقع فقط (`type='site'`)
- ✅ اضغط على تبويب "المسارات والتخييم" - يجب أن تظهر المسارات والتخييمات فقط (`type='route'` أو `type='camping'`)
- ✅ تحقق من Console logs

---

## Console Logs المتوقعة

### عند جلب المواقع:
```
🔄 جلب الأماكن السياحية (sites) من API...
🔍 ApiService.getSites: type=site
📄 جلب الصفحة 1...
✅ استجابة API للصفحة 1: {...}
✅ تم جلب 5 مكان سياحي
```

### عند جلب المسارات:
```
🔄 جلب المسارات والتخييمات من API...
🔍 ApiService.getSites: type=route
📄 جلب الصفحة 1...
✅ استجابة API للصفحة 1: {...}
✅ تم جلب 3 مسار
🔍 ApiService.getSites: type=camping
📄 جلب الصفحة 1...
✅ استجابة API للصفحة 1: {...}
✅ تم جلب 2 تخييم
✅ إجمالي المسارات والتخييمات: 5
```

---

## Troubleshooting

### المشكلة 1: لا تظهر المواقع
**الحل:**
- تحقق من Laravel response format
- تأكد من أن Laravel يرجع `type='site'` في response
- تحقق من Console logs
- تأكد من أن `type` parameter يُرسل بشكل صحيح

### المشكلة 2: لا تظهر المسارات
**الحل:**
- تحقق من Laravel response format
- تأكد من أن Laravel يرجع `type='route'` أو `type='camping'` في response
- تحقق من Console logs
- تأكد من أن `type` parameter يُرسل بشكل صحيح

### المشكلة 3: جميع البيانات تظهر في كلا التبويبين
**الحل:**
- تحقق من أن `type` موجود في Laravel response
- تحقق من أن `PathModel.type` يُحفظ بشكل صحيح
- تحقق من Console logs للتصنيف

---

## النتيجة

بعد تطبيق هذه التعديلات:
- ✅ المواقع (Sites) تأتي من `sites` table حيث `type='site'`
- ✅ المسارات (Routes) تأتي من `sites` table حيث `type='route'`
- ✅ التخييمات (Camping) تأتي من `sites` table حيث `type='camping'`
- ✅ التصنيف يعمل بشكل صحيح في التطبيق
- ✅ التصنيف يعمل بشكل صحيح في cache

