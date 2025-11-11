import 'package:latlong2/latlong.dart';
import 'guide_model.dart';
import '../services/api_service.dart';

class PathModel {
  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final String location;
  final String locationAr;
  final List<String> images;
  final double length; // in kilometers
  final Duration estimatedDuration;
  final DifficultyLevel difficulty;
  final List<ActivityType> activities;
  final List<LatLng> coordinates;
  final double rating;
  final int reviewCount;
  final List<String> warnings;
  final List<String> warningsAr;
  final String? guideId;
  final GuideModel guide; // Required - all routes have guides
  final double price; // Required - price from guide
  final String? type; // نوع الموقع: 'site', 'route', 'camping'

  PathModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.location,
    required this.locationAr,
    required this.images,
    required this.length,
    required this.estimatedDuration,
    required this.difficulty,
    required this.activities,
    required this.coordinates,
    required this.rating,
    required this.reviewCount,
    required this.warnings,
    required this.warningsAr,
    this.guideId,
    required this.guide,
    required this.price,
    this.type,
  });

  // Helper method لبناء URL كامل للصورة
  // يدعم جميع الأشكال: URLs كاملة، paths نسبية، file paths محلية
  static String _buildImageUrl(String imagePath) {
    if (imagePath.isEmpty || imagePath == 'null' || imagePath.trim().isEmpty) {
      return 'assets/images/logo.png';
    }
    
    // تنظيف المسار
    imagePath = imagePath.trim();
    
    // إذا كانت URL كاملة (http:// أو https://)، استخدمها مباشرة
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // إذا كانت path نسبية من Laravel storage
    // دعم أشكال مختلفة:
    // - /storage/images/photo.jpg
    // - storage/images/photo.jpg
    // - /images/photo.jpg
    // - images/photo.jpg
    // - /public/storage/images/photo.jpg
    // - public/storage/images/photo.jpg
    if (imagePath.contains('storage/') || 
        imagePath.contains('images/') ||
        imagePath.contains('photos/') ||
        imagePath.contains('uploads/')) {
      
      // تنظيف المسار
      String cleanPath = imagePath;
      
      // إزالة public/ إذا كان موجوداً (Laravel يستخدم storage/app/public)
      if (cleanPath.contains('public/storage/')) {
        cleanPath = cleanPath.replaceAll('public/storage/', 'storage/');
      } else if (cleanPath.contains('public/')) {
        cleanPath = cleanPath.replaceAll('public/', '');
      }
      
      // التأكد من وجود / في البداية
      if (!cleanPath.startsWith('/')) {
        // البحث عن storage/ أو images/ أو photos/ أو uploads/
        if (cleanPath.contains('storage/')) {
          final index = cleanPath.indexOf('storage/');
          cleanPath = '/${cleanPath.substring(index)}';
        } else if (cleanPath.contains('images/')) {
          final index = cleanPath.indexOf('images/');
          cleanPath = '/storage/images/${cleanPath.substring(index + 7)}'; // images/ length = 7
        } else if (cleanPath.contains('photos/')) {
          final index = cleanPath.indexOf('photos/');
          cleanPath = '/storage/photos/${cleanPath.substring(index + 7)}'; // photos/ length = 7
        } else if (cleanPath.contains('uploads/')) {
          final index = cleanPath.indexOf('uploads/');
          cleanPath = '/storage/uploads/${cleanPath.substring(index + 8)}'; // uploads/ length = 8
        } else {
          cleanPath = '/storage/$cleanPath';
        }
      } else {
        // إذا كانت تبدأ بـ /، تأكد من أنها تحتوي على storage/
        if (!cleanPath.startsWith('/storage/') && 
            !cleanPath.startsWith('/images/') &&
            !cleanPath.startsWith('/photos/') &&
            !cleanPath.startsWith('/uploads/')) {
          // إضافة storage/ إذا لم يكن موجوداً
          if (cleanPath.startsWith('/images/')) {
            cleanPath = '/storage$cleanPath';
          } else if (cleanPath.startsWith('/photos/')) {
            cleanPath = '/storage$cleanPath';
          } else if (cleanPath.startsWith('/uploads/')) {
            cleanPath = '/storage$cleanPath';
          } else {
            cleanPath = '/storage$cleanPath';
          }
        }
      }
      
      // بناء base URL حسب البيئة
      // استخدام ApiService للحصول على base URL الصحيح (يدعم ngrok)
      final apiService = ApiService.instance;
      String baseUrl;
      
      // الحصول على images base URL من ApiService (بدون /api)
      final apiBaseUrl = apiService.baseUrl;
      if (apiBaseUrl.endsWith('/api')) {
        baseUrl = apiBaseUrl.substring(0, apiBaseUrl.length - 4); // إزالة '/api'
      } else {
        // إذا كان baseUrl لا ينتهي بـ /api، استخدمه مباشرة
        baseUrl = apiBaseUrl;
      }
      
      // إذا كان baseUrl يحتوي على ngrok، تأكد من استخدام HTTPS
      if (baseUrl.contains('ngrok')) {
        baseUrl = baseUrl.replaceFirst('http://', 'https://');
      }
      
      final fullUrl = '$baseUrl$cleanPath';
      return fullUrl;
    }
    
    // إذا كانت asset path (تبدأ بـ assets/)، استخدمها مباشرة
    if (imagePath.startsWith('assets/')) {
      return imagePath;
    }
    
    // إذا كانت مسار ملف محلي (مثل C:\ أو /home/)، حاول تحويله
    // هذا غير مدعوم عادة، لكن يمكن إرجاعه كما هو للاختبار
    if (imagePath.contains('\\') || imagePath.contains('/')) {
      // محاولة استخراج اسم الملف فقط
      final fileName = imagePath.split(RegExp(r'[\\/]')).last;
      if (fileName.isNotEmpty && fileName.contains('.')) {
        // استخدام ApiService للحصول على base URL الصحيح
        final apiService = ApiService.instance;
        String baseUrl = apiService.baseUrl;
        if (baseUrl.endsWith('/api')) {
          baseUrl = baseUrl.substring(0, baseUrl.length - 4);
        }
        if (baseUrl.contains('ngrok')) {
          baseUrl = baseUrl.replaceFirst('http://', 'https://');
        }
        return '$baseUrl/storage/images/$fileName';
      }
    }
    
    // في حالة أخرى، افترض أنها path نسبي وأضف /storage/
    final apiService = ApiService.instance;
    String baseUrl = apiService.baseUrl;
    if (baseUrl.endsWith('/api')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 4);
    }
    if (baseUrl.contains('ngrok')) {
      baseUrl = baseUrl.replaceFirst('http://', 'https://');
    }
    return '$baseUrl/storage/$imagePath';
  }

  // Create PathModel from JSON (from Laravel API)
  factory PathModel.fromJson(Map<String, dynamic> json) {
    // Parse coordinates
    List<LatLng> coordinates = [];
    if (json['coordinates'] != null) {
      if (json['coordinates'] is List) {
        coordinates = (json['coordinates'] as List).map((coord) {
          if (coord is Map) {
            return LatLng(
              (coord['latitude'] ?? coord['lat'] ?? 0.0).toDouble(),
              (coord['longitude'] ?? coord['lng'] ?? coord['lon'] ?? 0.0).toDouble(),
            );
          }
          return LatLng(0.0, 0.0);
        }).toList();
      }
    } else if (json['latitude'] != null && json['longitude'] != null) {
      // إذا كانت الإحداثيات مباشرة في JSON
      // تحويل من String أو num إلى double
      double lat = 0.0;
      double lng = 0.0;
      
      if (json['latitude'] is String) {
        lat = double.tryParse(json['latitude']) ?? 0.0;
      } else if (json['latitude'] is num) {
        lat = (json['latitude'] as num).toDouble();
      }
      
      if (json['longitude'] is String) {
        lng = double.tryParse(json['longitude']) ?? 0.0;
      } else if (json['longitude'] is num) {
        lng = (json['longitude'] as num).toDouble();
      }
      
      if (lat != 0.0 || lng != 0.0) {
        coordinates = [LatLng(lat, lng)];
      }
    }

    // Parse images - بناء URLs كاملة للصور
    // دعم جميع الأشكال: URLs كاملة، paths نسبية، file paths محلية
    List<String> images = [];
    
    // محاولة 1: images كـ List
    if (json['images'] != null) {
      if (json['images'] is List) {
        final imagesList = json['images'] as List;
        images = imagesList
            .where((img) => img != null && img.toString().isNotEmpty && img.toString() != 'null')
            .map((img) => _buildImageUrl(img.toString()))
            .toList();
        print('🖼️ تم العثور على ${images.length} صورة في images List');
      } else if (json['images'] is String) {
        // دعم images كـ String مفصول بفواصل
        final imagesStr = json['images'].toString();
        if (imagesStr.isNotEmpty && imagesStr != 'null') {
          images = imagesStr.split(',')
              .map((img) => img.trim())
              .where((img) => img.isNotEmpty)
              .map((img) => _buildImageUrl(img))
              .toList();
          print('🖼️ تم العثور على ${images.length} صورة في images String');
        }
      }
    }
    
    // محاولة 2: image_url
    if (images.isEmpty && json['image_url'] != null) {
      final imageUrl = json['image_url'].toString();
      if (imageUrl.isNotEmpty && imageUrl != 'null') {
        images = [_buildImageUrl(imageUrl)];
        print('🖼️ تم العثور على صورة في image_url: $imageUrl');
      }
    }
    
    // محاولة 3: image
    if (images.isEmpty && json['image'] != null) {
      final image = json['image'].toString();
      if (image.isNotEmpty && image != 'null') {
        images = [_buildImageUrl(image)];
        print('🖼️ تم العثور على صورة في image: $image');
      }
    }
    
    // محاولة 4: photo أو photos
    if (images.isEmpty && json['photo'] != null) {
      final photo = json['photo'].toString();
      if (photo.isNotEmpty && photo != 'null') {
        images = [_buildImageUrl(photo)];
        print('🖼️ تم العثور على صورة في photo: $photo');
      }
    }
    
    if (json['photos'] != null && json['photos'] is List) {
      final photosList = json['photos'] as List;
      final photos = photosList
          .where((photo) => photo != null && photo.toString().isNotEmpty && photo.toString() != 'null')
          .map((photo) => _buildImageUrl(photo.toString()))
          .toList();
      if (photos.isNotEmpty) {
        images.addAll(photos);
        print('🖼️ تم العثور على ${photos.length} صورة في photos List');
      }
    }
    
    // إزالة التكرارات
    images = images.toSet().toList();
    
    // إذا لم يتم العثور على صور، استخدم الصورة الافتراضية
    if (images.isEmpty) {
      print('⚠️ لم يتم العثور على صور - سيتم استخدام الصورة الافتراضية');
      images = ['assets/images/logo.png'];
    }
    
    print('✅ إجمالي الصور: ${images.length}');
    for (int i = 0; i < images.length; i++) {
      print('   ${i + 1}. ${images[i]}');
    }

    // Parse activities - دعم أشكال مختلفة
    List<ActivityType> activities = [];
    if (json['activities'] != null && json['activities'] is List) {
      activities = (json['activities'] as List).map((activity) {
        if (activity is String) {
          return ActivityType.values.firstWhere(
            (e) => e.name == activity.toLowerCase(),
            orElse: () => ActivityType.hiking,
          );
        }
        return ActivityType.hiking;
      }).toList();
    } else if (json['activity'] != null) {
      // دعم activity مفرد
      final activityStr = json['activity'].toString().toLowerCase();
      activities = [ActivityType.values.firstWhere(
        (e) => e.name == activityStr,
        orElse: () => ActivityType.hiking,
      )];
    } else if (json['activities'] != null && json['activities'] is String) {
      // دعم activities كـ String مفصول بفواصل
      final activitiesStr = json['activities'].toString().toLowerCase();
      activities = activitiesStr.split(',').map((activity) {
        return ActivityType.values.firstWhere(
          (e) => e.name == activity.trim(),
          orElse: () => ActivityType.hiking,
        );
      }).toList();
    }

    // Parse difficulty
    DifficultyLevel difficulty = DifficultyLevel.medium;
    if (json['difficulty'] != null) {
      final diffStr = json['difficulty'].toString().toLowerCase();
      difficulty = DifficultyLevel.values.firstWhere(
        (e) => e.name == diffStr,
        orElse: () => DifficultyLevel.medium,
      );
    }

    // Parse duration - دعم أشكال مختلفة
    Duration estimatedDuration = const Duration(hours: 2);
    if (json['estimated_duration'] != null) {
      if (json['estimated_duration'] is int) {
        estimatedDuration = Duration(hours: json['estimated_duration']);
      } else if (json['estimated_duration'] is String) {
        final hours = int.tryParse(json['estimated_duration']) ?? 2;
        estimatedDuration = Duration(hours: hours);
      }
    } else if (json['duration'] != null) {
      // دعم duration بدون estimated_
      if (json['duration'] is int) {
        estimatedDuration = Duration(hours: json['duration']);
      } else if (json['duration'] is String) {
        final hours = int.tryParse(json['duration']) ?? 2;
        estimatedDuration = Duration(hours: hours);
      }
    } else if (json['duration_hours'] != null) {
      if (json['duration_hours'] is int) {
        estimatedDuration = Duration(hours: json['duration_hours']);
      } else if (json['duration_hours'] is String) {
        final hours = int.tryParse(json['duration_hours']) ?? 2;
        estimatedDuration = Duration(hours: hours);
      }
    }

    // Parse warnings
    List<String> warnings = [];
    List<String> warningsAr = [];
    if (json['warnings'] != null && json['warnings'] is List) {
      warnings = (json['warnings'] as List).map((w) => w.toString()).toList();
    }
    if (json['warnings_ar'] != null && json['warnings_ar'] is List) {
      warningsAr = (json['warnings_ar'] as List).map((w) => w.toString()).toList();
    }

    // Parse guide - دعم أشكال مختلفة
    String? guideId = json['guide_id']?.toString();
    String? guideName = json['guide_name']?.toString() ?? 
                        json['guide_name_en']?.toString();
    String? guideNameAr = json['guide_name_ar']?.toString();
    
    print('🔍 تحليل بيانات المرشد:');
    print('  - guide_id: $guideId');
    print('  - guide_name: $guideName');
    print('  - guide_name_ar: $guideNameAr');
    print('  - guide object: ${json['guide']}');
    print('  - user object: ${json['user']}');
    
    // دعم guide من user relation
    if (guideName == null && json['user'] != null && json['user'] is Map) {
      final userData = json['user'] as Map<String, dynamic>;
      guideName = userData['name']?.toString();
      guideNameAr = userData['name_ar']?.toString();
      print('  - تم استخراج من user: $guideName');
    }
    
    // دعم guide من guide.user relation
    if (guideName == null && json['guide'] != null && json['guide'] is Map) {
      final guideData = json['guide'] as Map<String, dynamic>;
      if (guideData['user'] != null && guideData['user'] is Map) {
        final userData = guideData['user'] as Map<String, dynamic>;
        guideName = userData['name']?.toString();
        guideNameAr = userData['name_ar']?.toString();
        print('  - تم استخراج من guide.user: $guideName');
      }
    }
    
    GuideModel guide;
    try {
      if (json['guide'] != null && json['guide'] is Map) {
        try {
          guide = GuideModel.fromJson(json['guide'] as Map<String, dynamic>);
          print('  - ✅ تم استخدام guide object: ${guide.name}');
        } catch (e) {
          print('  - ⚠️ فشل تحويل guide object: $e');
          // Fallback: إنشاء guide من guide_name إذا كان موجود
          if (guideName != null && guideName.isNotEmpty) {
            guide = GuideModel(
              id: guideId ?? '0',
              name: guideName,
              nameAr: guideNameAr ?? guideName,
            );
            print('  - ✅ تم إنشاء guide من guide_name (fallback): $guideName');
          } else {
            guide = GuideModel(
              id: guideId ?? '0',
              name: 'Guide',
              nameAr: 'مرشد',
            );
            print('  - ⚠️ تم استخدام guide افتراضي (fallback)');
          }
        }
      } else if (guideName != null && guideName.isNotEmpty) {
        // إذا كان guide_name موجود مباشرة
        guide = GuideModel(
          id: guideId ?? '0',
          name: guideName,
          nameAr: guideNameAr ?? guideName,
        );
        print('  - ✅ تم إنشاء guide من guide_name: $guideName');
      } else {
        // If guide data is missing, create a default guide
        guide = GuideModel(
          id: guideId ?? '0',
          name: 'Guide',
          nameAr: 'مرشد',
        );
        print('  - ⚠️ تم استخدام guide افتراضي (لا توجد بيانات)');
      }
    } catch (e) {
      print('  - ❌ خطأ في معالجة guide: $e');
      // Fallback: إنشاء guide افتراضي
      guide = GuideModel(
        id: guideId ?? '0',
        name: 'Guide',
        nameAr: 'مرشد',
      );
      print('  - ✅ تم استخدام guide افتراضي (error fallback)');
    }

    // Parse location from coordinates if not provided
    String location = json['location'] ?? json['location_en'] ?? '';
    String locationAr = json['location_ar'] ?? json['location'] ?? '';
    
    // إذا لم يكن هناك location، استخدم الإحداثيات
    if (location.isEmpty && coordinates.isNotEmpty) {
      location = '${coordinates.first.latitude}, ${coordinates.first.longitude}';
      locationAr = location;
    }
    
    // Parse type - حفظ type من JSON
    String? type;
    if (json['type'] != null) {
      type = json['type'].toString().toLowerCase();
      print('📌 PathModel: type=$type');
    }
    
    // Parse type and convert to activities if needed
    if (activities.isEmpty && type != null) {
      if (type == 'natural') {
        activities = [ActivityType.nature];
      } else if (type == 'historical' || type == 'archaeological') {
        activities = [ActivityType.archaeological, ActivityType.cultural];
      } else if (type == 'cultural') {
        activities = [ActivityType.cultural];
      } else if (type == 'religious') {
        activities = [ActivityType.religious];
      } else if (type == 'site') {
        // المواقع السياحية: لا نضيف hiking أو camping
        activities = [ActivityType.nature]; // Default for sites
      } else if (type == 'route' || type == 'camping') {
        // المسارات والتخييمات: نضيف hiking أو camping
        if (type == 'camping') {
          activities = [ActivityType.camping, ActivityType.hiking];
        } else {
          activities = [ActivityType.hiking];
        }
      } else {
        activities = [ActivityType.hiking]; // Default
      }
    }
    
    // Default values for missing fields - مع دعم String و num
    double defaultLength = 5.0;
    if (json['length'] != null) {
      defaultLength = json['length'] is String 
          ? (double.tryParse(json['length']) ?? 5.0)
          : (json['length'] as num).toDouble();
    } else if (json['distance'] != null) {
      defaultLength = json['distance'] is String 
          ? (double.tryParse(json['distance']) ?? 5.0)
          : (json['distance'] as num).toDouble();
    } else if (json['distance_km'] != null) {
      defaultLength = json['distance_km'] is String 
          ? (double.tryParse(json['distance_km']) ?? 5.0)
          : (json['distance_km'] as num).toDouble();
    }
    
    double defaultRating = 4.0;
    if (json['rating'] != null) {
      defaultRating = json['rating'] is String 
          ? (double.tryParse(json['rating']) ?? 4.0)
          : (json['rating'] as num).toDouble();
    } else if (json['average_rating'] != null) {
      defaultRating = json['average_rating'] is String 
          ? (double.tryParse(json['average_rating']) ?? 4.0)
          : (json['average_rating'] as num).toDouble();
    }
    
    int defaultReviewCount = 0;
    if (json['review_count'] != null) {
      defaultReviewCount = json['review_count'] is String 
          ? (int.tryParse(json['review_count']) ?? 0)
          : (json['review_count'] as num).toInt();
    } else if (json['reviews_count'] != null) {
      defaultReviewCount = json['reviews_count'] is String 
          ? (int.tryParse(json['reviews_count']) ?? 0)
          : (json['reviews_count'] as num).toInt();
    }
    
    double defaultPrice = guide.routePrice ?? 0.0;
    if (json['price'] != null) {
      defaultPrice = json['price'] is String 
          ? (double.tryParse(json['price']) ?? 0.0)
          : (json['price'] as num).toDouble();
    }
    
    // التحقق من الحقول المطلوبة قبل إنشاء PathModel
    final siteId = json['id']?.toString();
    if (siteId == null || siteId.isEmpty) {
      print('⚠️ ⚠️ ⚠️ تحذير: id مفقود في JSON - سيتم استخدام "0"');
    }
    
    final siteName = json['name'] ?? json['name_en'] ?? 'Unnamed Site';
    final siteNameAr = json['name_ar'] ?? json['name'] ?? siteName;
    
    if (siteName == 'Unnamed Site' && siteNameAr == 'موقع بدون اسم') {
      print('⚠️ ⚠️ ⚠️ تحذير: name و name_ar مفقودان - سيتم استخدام قيم افتراضية');
    }
    
    // التأكد من أن location غير فارغ
    final finalLocation = location.isEmpty ? 'Unknown Location' : location;
    final finalLocationAr = locationAr.isEmpty ? 'موقع غير معروف' : locationAr;
    
      try {
        return PathModel(
          id: siteId ?? '0',
          name: siteName,
          nameAr: siteNameAr,
          description: json['description'] ?? json['description_en'] ?? '',
          descriptionAr: json['description_ar'] ?? json['description'] ?? '',
          location: finalLocation,
          locationAr: finalLocationAr,
          images: images.isEmpty ? ['assets/images/logo.png'] : images, // Default image
          length: defaultLength,
          estimatedDuration: estimatedDuration,
          difficulty: difficulty,
          activities: activities.isEmpty ? [ActivityType.hiking] : activities,
          coordinates: coordinates.isEmpty 
              ? [LatLng(31.9522, 35.2332)] // Default coordinates (Palestine center)
              : coordinates,
          rating: defaultRating,
          reviewCount: defaultReviewCount,
          warnings: warnings,
          warningsAr: warningsAr,
          guideId: guideId,
          guide: guide,
          price: defaultPrice,
          type: type, // حفظ type من JSON
        );
    } catch (e, stackTrace) {
      print('❌ ❌ ❌ خطأ فادح في إنشاء PathModel: $e');
      print('   StackTrace: ${stackTrace.toString().substring(0, stackTrace.toString().length > 500 ? 500 : stackTrace.toString().length)}...');
      print('   JSON keys: ${json.keys.toList()}');
      print('   JSON sample: ${json.toString().substring(0, json.toString().length > 300 ? 300 : json.toString().length)}...');
      print('   Site ID: $siteId');
      print('   Site Name: $siteName');
      print('   Guide ID: ${guide.id}');
      print('   Guide Name: ${guide.name}');
      rethrow; // إعادة رمي الخطأ لمعرفة المشكلة
    }
  }

  // Convert PathModel to JSON (for sending to Laravel API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'name_en': name,
      'description': description,
      'description_ar': descriptionAr,
      'description_en': description,
      'location': location,
      'location_ar': locationAr,
      'location_en': location,
      'images': images,
      'image_url': images.isNotEmpty ? images[0] : null,
      'length': length,
      'distance': length,
      'estimated_duration': estimatedDuration.inHours,
      'difficulty': difficulty.name,
      'activities': activities.map((a) => a.name).toList(),
      'coordinates': coordinates.map((coord) => ({
        'latitude': coord.latitude,
        'longitude': coord.longitude,
        'lat': coord.latitude,
        'lng': coord.longitude,
      })).toList(),
      'rating': rating,
      'review_count': reviewCount,
      'reviews_count': reviewCount,
      'warnings': warnings,
      'warnings_ar': warningsAr,
      'guide_id': guideId,
      'guide': guide.toJson(),
      'price': price,
      'type': type, // حفظ type في JSON
    };
  }

  // Copy with method for updates
  PathModel copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    String? location,
    String? locationAr,
    List<String>? images,
    double? length,
    Duration? estimatedDuration,
    DifficultyLevel? difficulty,
    List<ActivityType>? activities,
    List<LatLng>? coordinates,
    double? rating,
    int? reviewCount,
    List<String>? warnings,
    List<String>? warningsAr,
    String? guideId,
    GuideModel? guide,
    double? price,
    String? type,
  }) {
    return PathModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      location: location ?? this.location,
      locationAr: locationAr ?? this.locationAr,
      images: images ?? this.images,
      length: length ?? this.length,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      difficulty: difficulty ?? this.difficulty,
      activities: activities ?? this.activities,
      coordinates: coordinates ?? this.coordinates,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      warnings: warnings ?? this.warnings,
      warningsAr: warningsAr ?? this.warningsAr,
      guideId: guideId ?? this.guideId,
      guide: guide ?? this.guide,
      price: price ?? this.price,
      type: type ?? this.type,
    );
  }
}

enum DifficultyLevel { easy, medium, hard }

enum ActivityType {
  hiking,
  camping,
  climbing,
  religious,
  cultural,
  nature,
  archaeological,
}