# دليل ربط التطبيق مع Laravel API

## ✅ البنية الحالية

التطبيق جاهز ويعمل مع Laravel API! كل المكونات المطلوبة موجودة:

### 1. **Model (PathModel)**
📁 `lib/data/models/path_model.dart`

- ✅ `PathModel` يعمل كـ Site Model
- ✅ يحتوي على جميع الحقول المطلوبة:
  - `id`, `name`, `nameAr`, `description`, `descriptionAr`
  - `location`, `locationAr`
  - `latitude`, `longitude` (في `coordinates`)
  - `type` (يتم تحديده من خلال `activities` و `difficulty`)
  - `images`, `rating`, `reviewCount`, `price`
- ✅ `fromJson()` method - يدعم أشكال مختلفة من البيانات من Laravel
- ✅ `toJson()` method - لتحويل البيانات إلى JSON

### 2. **Service (ApiService)**
📁 `lib/data/services/api_service.dart`

- ✅ `getSites()` - جلب جميع المواقع من `/api/sites`
- ✅ `getSite(id)` - جلب موقع محدد من `/api/sites/{id}`
- ✅ يدعم:
  - Filter حسب النوع: `type='route'`
  - البحث: `search=query`
  - Pagination: `page=1`
- ✅ يعمل مع/بدون authentication (للمستخدمين الضيوف)
- ✅ Base URL يتم اكتشافه تلقائياً:
  - Flutter Web: `http://localhost:8000/api`
  - Android Emulator: `http://10.0.2.2:8000/api`
  - iOS Simulator: `http://127.0.0.1:8000/api`

### 3. **Repository (PathsRepository)**
📁 `lib/data/repositories/paths_repository.dart`

- ✅ `getAllPaths()` - جلب جميع المسارات من API
- ✅ `getPathById(id)` - جلب مسار محدد
- ✅ `searchPaths(query)` - البحث في المسارات
- ✅ `getFeaturedPaths()` - جلب المسارات المميزة
- ✅ `useApi = true` - ✅ مفعّل
- ✅ `useDummyDataAsFallback = false` - البيانات الوهمية معطلة

### 4. **Provider (PathsProvider)**
📁 `lib/presentation/providers/paths_provider.dart`

- ✅ يدير حالة المسارات في التطبيق
- ✅ `loadPaths()` - تحميل المسارات من API
- ✅ `filteredPaths` - فلترة المسارات حسب النشاط/الصعوبة/الموقع
- ✅ يدعم RefreshIndicator (السحب للتحديث)
- ✅ Caching للعمل offline

### 5. **Screen (PathsScreen)**
📁 `lib/presentation/screens/paths/paths_screen.dart`

- ✅ يعرض قائمة بجميع المسارات
- ✅ `ListView.builder` لعرض المسارات
- ✅ `RefreshIndicator` للتحديث (السحب للأسفل)
- ✅ Filter حسب النوع (Activity, Difficulty, Location)
- ✅ معالجة حالات Loading, Error, Empty

### 6. **AndroidManifest.xml**
📁 `android/app/src/main/AndroidManifest.xml`

- ✅ `INTERNET` permission موجود
- ✅ `usesCleartextTraffic="true"` ✅ تم إضافته

---

## 🔄 كيفية العمل

### 1. عند فتح التطبيق:

```
User opens app
    ↓
PathsProvider.loadPaths()
    ↓
PathsRepository.getAllPaths()
    ↓
ApiService.getSites(type: 'route')
    ↓
GET http://10.0.2.2:8000/api/sites?type=route
    ↓
Laravel API returns sites
    ↓
PathModel.fromJson() converts to PathModel
    ↓
PathsProvider updates state
    ↓
PathsScreen displays paths
```

### 2. عند السحب للتحديث:

```
User pulls down to refresh
    ↓
RefreshIndicator.onRefresh()
    ↓
PathsProvider.loadPaths()
    ↓
API call again
    ↓
Update UI with new data
```

### 3. عند البحث:

```
User types search query
    ↓
PathsRepository.searchPaths(query)
    ↓
ApiService.getSites(search: query, type: 'route')
    ↓
GET http://10.0.2.2:8000/api/sites?type=route&search=query
    ↓
Display filtered results
```

---

## 📋 متطلبات Laravel API

يجب أن يعيد Laravel API البيانات بهذا الشكل:

### GET `/api/sites?type=route`

```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "name": "Upper Galilee Trail",
      "name_ar": "مسار الجليل الأعلى",
      "description": "A beautiful trail...",
      "description_ar": "مسار جميل...",
      "location": "Upper Galilee",
      "location_ar": "الجليل الأعلى",
      "latitude": 33.0479,
      "longitude": 35.3923,
      "coordinates": [
        {"latitude": 33.0479, "longitude": 35.3923},
        {"latitude": 33.0485, "longitude": 35.3930}
      ],
      "images": ["url1.jpg", "url2.jpg"],
      "image_url": "url1.jpg",
      "length": 12.5,
      "distance": 12.5,
      "estimated_duration": 4,
      "difficulty": "medium",
      "activities": ["hiking", "nature"],
      "rating": 4.7,
      "review_count": 128,
      "price": 250.0,
      "type": "route",
      "guide_id": 1,
      "guide": {
        "id": 1,
        "name": "Ahmed Al-Masri",
        "name_ar": "أحمد المصري",
        "bio": "...",
        "phone": "+970-59-123-4567",
        "languages": "Arabic, English",
        "hourly_rate": 250.0,
        "route_price": 250.0,
        "rating": 4.8,
        "review_count": 45
      }
    }
  ]
}
```

### أو بدون `status`:

```json
{
  "data": [
    {
      "id": 1,
      "name": "...",
      ...
    }
  ]
}
```

---

## 🎯 الشاشات المتاحة

### 1. **الصفحة الرئيسية** (`/`)
- يعرض المسارات المميزة
- يعرض المسارات المقترحة

### 2. **صفحة المسارات** (`/paths`)
- قائمة بجميع المسارات
- Filter حسب النوع
- RefreshIndicator
- البحث

### 3. **تفاصيل المسار** (`/paths/:id`)
- تفاصيل كاملة عن المسار
- الخريطة
- المرشد
- التقييمات

---

## 🔧 الإعدادات

### تفعيل/تعطيل API:

في `lib/data/repositories/paths_repository.dart`:

```dart
bool useApi = true; // ✅ مفعّل
bool useDummyDataAsFallback = false; // ✅ معطّل
```

### تغيير Base URL:

في `lib/data/services/api_service.dart`:

```dart
String get baseUrl {
  if (kIsWeb) {
    return 'http://localhost:8000/api'; // Flutter Web
  } else {
    return 'http://10.0.2.2:8000/api'; // Android Emulator
    // return 'http://192.168.1.100:8000/api'; // Real Device
  }
}
```

---

## ✅ التحقق من أن كل شيء يعمل

1. **شغّل Laravel Server:**
   ```bash
   php artisan serve --host=0.0.0.0 --port=8000
   ```

2. **شغّل Flutter App:**
   ```bash
   flutter run
   ```

3. **راقب Console Logs:**
   - `🔄 جلب المواقع من API...`
   - `✅ تم جلب X موقع من API`
   - `✅ PathsProvider: تم جلب X مسار`

4. **اختبر:**
   - افتح صفحة المسارات
   - اسحب للأسفل للتحديث
   - استخدم Filter
   - ابحث عن مسار

---

## 🐛 استكشاف الأخطاء

### لا تظهر المسارات:

1. ✅ تحقق من أن السيرفر يعمل
2. ✅ تحقق من Console Logs
3. ✅ تحقق من أن `/api/sites?type=route` يعيد البيانات
4. ✅ تحقق من تنسيق البيانات (يجب أن تطابق `PathModel`)

### خطأ في الاتصال:

1. ✅ تحقق من `AndroidManifest.xml` - `usesCleartextTraffic="true"`
2. ✅ تحقق من Base URL
3. ✅ تحقق من CORS في Laravel

---

## 📝 ملاحظات

- ✅ التطبيق يعرض **فقط** البيانات من API
- ✅ البيانات الوهمية معطلة (`useDummyDataAsFallback = false`)
- ✅ إذا فشل API، يعرض قائمة فارغة
- ✅ يدعم العمل offline (Caching)
- ✅ يعمل مع المستخدمين المسجلين والضيوف

---

## 🎉 النتيجة

التطبيق جاهز ويعمل مع Laravel API! كل ما تحتاجه هو:

1. ✅ تأكد من أن Laravel API يعيد البيانات بالشكل الصحيح
2. ✅ شغّل السيرفر: `php artisan serve --host=0.0.0.0 --port=8000`
3. ✅ شغّل التطبيق وسترى المسارات من قاعدة البيانات!


