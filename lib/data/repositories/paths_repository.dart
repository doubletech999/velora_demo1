// lib/data/repositories/paths_repository.dart
import 'package:latlong2/latlong.dart';

import '../models/path_model.dart';
import '../models/guide_model.dart';
import '../services/api_service.dart';

class PathsRepository {
  final ApiService _apiService = ApiService.instance;

  /// Use API for paths data
  bool useApi = true; // ✅ تم تفعيل API

  /// استخدام البيانات الوهمية كبديل عند فشل API
  bool useDummyDataAsFallback = false; // ✅ تم تعطيل البيانات الوهمية

  /// Helper method لجلب المواقع مع pagination
  Future<List<PathModel>> _fetchSitesFromApi({
    String? type,
    String? search,
  }) async {
    if (!useApi) {
      return [];
    }

    try {
      List<dynamic> allPathsData = [];
      int currentPage = 1;
      bool hasMorePages = true;

      // جلب جميع الصفحات
      while (hasMorePages) {
        print('📄 جلب الصفحة $currentPage...');

        final response = await _apiService.getSites(
          type: type,
          search: search,
          page: currentPage,
        );

        print(
          '✅ استجابة API للصفحة $currentPage: ${response.toString().substring(0, response.toString().length > 200 ? 200 : response.toString().length)}...',
        );

        // معالجة الاستجابة - دعم أشكال مختلفة من الاستجابة
        List<dynamic> pathsData = [];
        int? totalPages;
        int? currentPageNum;
        int? perPage;

        // محاولة 1: إذا كانت الاستجابة قائمة مباشرة
        if (response is List) {
          print('✅ الاستجابة قائمة مباشرة: ${response.length} عنصر');
          pathsData = response;
          hasMorePages = false; // إذا كانت قائمة مباشرة، لا يوجد pagination
        }
        // محاولة 2: Laravel Pagination Format (الأكثر شيوعاً)
        else if (response is Map) {
          // ⭐ Laravel paginate() يرجع pagination info مباشرة في response
          if (response.containsKey('data') &&
              response.containsKey('current_page')) {
            print('✅ Laravel Pagination Format detected');
            currentPageNum = response['current_page'] as int?;
            totalPages = response['last_page'] as int?;
            perPage = response['per_page'] as int?;
            print(
              '📊 Laravel Pagination: الصفحة $currentPageNum من $totalPages ($perPage عنصر لكل صفحة)',
            );

            if (response['data'] is List) {
              pathsData = response['data'] as List;
              print('✅ Laravel data: ${pathsData.length} عنصر');
            } else if (response['data'] is Map) {
              pathsData =
                  response['data']['paths'] ??
                  response['data']['sites'] ??
                  response['data']['data'] ??
                  [];
              print('✅ Laravel data (Map): ${pathsData.length} عنصر');
            }
          }
          // محاولة 3: إذا كان هناك status و data
          else if (response['status'] == 'success' &&
              response['data'] != null) {
            print('✅ تم العثور على status=success و data');

            // التحقق من pagination في meta
            if (response['meta'] != null && response['meta'] is Map) {
              final meta = response['meta'] as Map<String, dynamic>;
              currentPageNum = meta['current_page'] ?? meta['page'];
              totalPages = meta['last_page'] ?? meta['total_pages'];
              perPage = meta['per_page'];
              print(
                '📊 Pagination (meta): الصفحة $currentPageNum من $totalPages',
              );
            } else if (response['pagination'] != null &&
                response['pagination'] is Map) {
              final pagination = response['pagination'] as Map<String, dynamic>;
              currentPageNum = pagination['current_page'] ?? pagination['page'];
              totalPages = pagination['last_page'] ?? pagination['total_pages'];
              perPage = pagination['per_page'];
              print(
                '📊 Pagination (pagination): الصفحة $currentPageNum من $totalPages',
              );
            }

            if (response['data'] is List) {
              pathsData = response['data'] as List;
              print('✅ data هي قائمة: ${pathsData.length} عنصر');
            } else if (response['data'] is Map) {
              pathsData =
                  response['data']['paths'] ??
                  response['data']['sites'] ??
                  response['data']['data'] ??
                  [];
              print('✅ data هي Map، تم استخراج: ${pathsData.length} عنصر');
            }
          }
          // محاولة 4: إذا كان data مباشرة بدون status
          else if (response['data'] != null) {
            print('✅ تم العثور على data مباشرة (بدون status)');

            // التحقق من pagination info في response مباشرة
            if (response.containsKey('current_page')) {
              currentPageNum = response['current_page'] as int?;
              totalPages = response['last_page'] as int?;
              perPage = response['per_page'] as int?;
              print(
                '📊 Pagination (direct): الصفحة $currentPageNum من $totalPages',
              );
            }

            if (response['data'] is List) {
              pathsData = response['data'] as List;
              print('✅ data هي قائمة: ${pathsData.length} عنصر');
            } else if (response['data'] is Map) {
              pathsData =
                  response['data']['paths'] ??
                  response['data']['sites'] ??
                  response['data']['data'] ??
                  [];
              print('✅ data هي Map، تم استخراج: ${pathsData.length} عنصر');
            }
          }
          // محاولة 5: إذا كانت المفاتيح مباشرة في response
          else if (response.containsKey('sites')) {
            pathsData = response['sites'] is List ? response['sites'] : [];
            print('✅ تم العثور على sites مباشرة: ${pathsData.length} عنصر');
          } else if (response.containsKey('paths')) {
            pathsData = response['paths'] is List ? response['paths'] : [];
            print('✅ تم العثور على paths مباشرة: ${pathsData.length} عنصر');
          }

          // ⭐ إذا لم يتم العثور على pagination info، جرب البحث في response مباشرة
          if (totalPages == null && response.containsKey('last_page')) {
            totalPages = response['last_page'] as int?;
            currentPageNum = response['current_page'] as int? ?? currentPage;
            perPage = response['per_page'] as int?;
            print(
              '📊 Pagination (fallback): الصفحة $currentPageNum من $totalPages',
            );
          }
        }

        // إضافة البيانات إلى القائمة الإجمالية
        allPathsData.addAll(pathsData);
        print('✅ إجمالي المواقع حتى الآن: ${allPathsData.length}');

        // التحقق من وجود صفحات أخرى
        if (totalPages != null && currentPageNum != null) {
          hasMorePages = currentPageNum < totalPages;
          if (hasMorePages) {
            currentPage++;
          }
        } else {
          // إذا لم يكن هناك معلومات pagination، توقف إذا كانت الصفحة فارغة
          hasMorePages = pathsData.isNotEmpty;
          if (hasMorePages) {
            currentPage++;
          }
        }

        // حد أقصى للصفحات (لحماية من loops لا نهائية)
        if (currentPage > 100) {
          print('⚠️ تم الوصول للحد الأقصى للصفحات (100)');
          hasMorePages = false;
        }
      }

      print(
        '✅ إجمالي المواقع المستخرجة من جميع الصفحات: ${allPathsData.length}',
      );

      if (allPathsData.isEmpty) {
        print('⚠️ لا توجد بيانات في allPathsData');
        print('   نوع الاستجابة المتوقع: Map مع data و current_page');
        print(
          '   مثال Laravel pagination: {"data": [...], "current_page": 1, "last_page": 1, "per_page": 10, "total": 1}',
        );
        return [];
      }

      print('🔄 بدء تحويل ${allPathsData.length} موقع إلى PathModel...');
      final paths = <PathModel>[];

      for (int i = 0; i < allPathsData.length; i++) {
        try {
          final json = allPathsData[i];
          if (json is Map<String, dynamic>) {
            print(
              '🔄 تحويل الموقع ${i + 1}/${allPathsData.length}: ${json['name_ar'] ?? json['name'] ?? 'unknown'}',
            );
            final path = PathModel.fromJson(json);
            paths.add(path);
            print(
              '✅ تم تحويل الموقع ${i + 1}/${allPathsData.length}: ${path.nameAr} (type: ${json['type'] ?? 'unknown'})',
            );
          } else {
            print('⚠️ الموقع ${i + 1} ليس Map: ${json.runtimeType}');
            print('   JSON: $json');
          }
        } catch (e, stackTrace) {
          print('❌ خطأ في تحويل الموقع ${i + 1}/${allPathsData.length}: $e');
          print(
            '   StackTrace: ${stackTrace.toString().substring(0, stackTrace.toString().length > 300 ? 300 : stackTrace.toString().length)}...',
          );
          print('   JSON: ${allPathsData[i]}');

          // محاولة إنشاء PathModel ببيانات افتراضية بدلاً من تجاهل الموقع
          try {
            final json = allPathsData[i];
            if (json is Map<String, dynamic>) {
              print('   🔄 محاولة إنشاء PathModel ببيانات افتراضية...');
              final fallbackPath = PathModel(
                id: json['id']?.toString() ?? '0',
                name:
                    json['name']?.toString() ??
                    json['name_en']?.toString() ??
                    'Unnamed Site',
                nameAr:
                    json['name_ar']?.toString() ??
                    json['name']?.toString() ??
                    'موقع بدون اسم',
                description: json['description']?.toString() ?? '',
                descriptionAr: json['description_ar']?.toString() ?? '',
                location: json['location']?.toString() ?? 'Unknown Location',
                locationAr: json['location_ar']?.toString() ?? 'موقع غير معروف',
                images: ['assets/images/logo.png'],
                length: 5.0,
                estimatedDuration: const Duration(hours: 2),
                difficulty: DifficultyLevel.medium,
                activities: [ActivityType.hiking],
                coordinates: [LatLng(31.9522, 35.2332)],
                rating: 4.0,
                reviewCount: 0,
                warnings: [],
                warningsAr: [],
                guideId: json['guide_id']?.toString(),
                guide: GuideModel(
                  id: json['guide_id']?.toString() ?? '0',
                  name: 'Guide',
                  nameAr: 'مرشد',
                ),
                price: 0.0,
                type: json['type']?.toString(), // حفظ type
              );
              paths.add(fallbackPath);
              print('   ✅ تم إنشاء PathModel ببيانات افتراضية بنجاح');
            }
          } catch (fallbackError) {
            print(
              '   ❌ فشل أيضاً في إنشاء PathModel ببيانات افتراضية: $fallbackError',
            );
            // تجاهل الموقع إذا فشل حتى مع البيانات الافتراضية
          }
        }
      }

      print('✅ تم تحويل ${paths.length}/${allPathsData.length} موقع بنجاح');

      if (paths.isEmpty && allPathsData.isNotEmpty) {
        print('⚠️ ⚠️ ⚠️ جميع المواقع فشلت في التحويل!');
        print('   تحقق من PathModel.fromJson()');
        print('   مثال على JSON الأول:');
        print('   ${allPathsData[0]}');
      }

      return paths;
    } catch (e, stackTrace) {
      print('❌ ❌ ❌ خطأ في جلب المواقع من API: $e');
      print(
        '   StackTrace: ${stackTrace.toString().substring(0, stackTrace.toString().length > 500 ? 500 : stackTrace.toString().length)}...',
      );
      return [];
    }
  }

  /// الحصول على جميع المسارات (جميع الأنواع)
  Future<List<PathModel>> getAllPaths() async {
    if (useApi) {
      try {
        print('🔄 جلب جميع المواقع من API...');
        final paths = await _fetchSitesFromApi(type: null, search: null);

        if (paths.isEmpty && useDummyDataAsFallback) {
          print('⚠️ استخدام البيانات الوهمية كبديل');
          return await _getDummyPaths();
        }

        return paths;
      } catch (e) {
        print('❌ خطأ في جلب جميع المسارات: $e');
        if (useDummyDataAsFallback) {
          return await _getDummyPaths();
        }
        return [];
      }
    }

    // إذا كان useApi = false، استخدم البيانات الوهمية
    if (useDummyDataAsFallback) {
      return await _getDummyPaths();
    }
    return [];
  }

  /// الحصول على الأماكن السياحية فقط (type='site')
  /// المواقع السياحية تأتي من sites table حيث type='site'
  Future<List<PathModel>> getSites() async {
    if (useApi) {
      try {
        print('🔄 جلب الأماكن السياحية (sites) من API...');
        print('   📌 نوع الطلب: type=site');
        print(
          '   📌 المتوقع: المواقع السياحية فقط (type=\'site\' في قاعدة البيانات)',
        );
        final sites = await _fetchSitesFromApi(type: 'site', search: null);
        print('✅ تم جلب ${sites.length} مكان سياحي من API');

        // التحقق من type في النتائج
        final sitesWithType =
            sites
                .where(
                  (site) =>
                      site.type != null && site.type!.toLowerCase() == 'site',
                )
                .length;
        print('   📊 المواقع مع type=\'site\': $sitesWithType/${sites.length}');

        if (sitesWithType < sites.length) {
          print('   ⚠️ تحذير: بعض المواقع لا تحتوي على type=\'site\'');
        }

        return sites;
      } catch (e) {
        print('❌ خطأ في جلب الأماكن السياحية: $e');
        return [];
      }
    } else {
      // إذا لم يكن API مفعل، فلتر البيانات الوهمية
      if (useDummyDataAsFallback) {
        final allPaths = await _getDummyPaths();
        return allPaths.where((path) {
          // في البيانات الوهمية، نعتبر الأماكن التي ليست مسارات أو تخييم
          return !path.activities.contains(ActivityType.hiking) ||
              (!path.activities.contains(ActivityType.camping) &&
                  path.length < 5.0);
        }).toList();
      }
      return [];
    }
  }

  Future<List<PathModel>> getRestaurants() async {
    if (useApi) {
      try {
        print('🔄 جلب المطاعم من API (type=restaurant)...');
        final restaurants = await _fetchSitesFromApi(type: 'restaurant', search: null);
        print('✅ PathsRepository: تم جلب ${restaurants.length} مطعم');
        return restaurants;
      } catch (e) {
        print('❌ PathsRepository: خطأ في جلب المطاعم: $e');
        return [];
      }
    } else if (useDummyDataAsFallback) {
      final allPaths = await _getDummyPaths();
      return allPaths.where((path) {
        if (path.type != null) {
          return path.type!.toLowerCase() == 'restaurant';
        }
        return false;
      }).toList();
    }
    return [];
  }

  Future<List<PathModel>> getHotels() async {
    if (useApi) {
      try {
        print('🔄 جلب الفنادق من API (type=hotel)...');
        final hotels = await _fetchSitesFromApi(type: 'hotel', search: null);
        print('✅ PathsRepository: تم جلب ${hotels.length} فندق');
        return hotels;
      } catch (e) {
        print('❌ PathsRepository: خطأ في جلب الفنادق: $e');
        return [];
      }
    } else if (useDummyDataAsFallback) {
      final allPaths = await _getDummyPaths();
      return allPaths.where((path) {
        if (path.type != null) {
          return path.type!.toLowerCase() == 'hotel';
        }
        return false;
      }).toList();
    }
    return [];
  }

  /// الحصول على المسارات والتخييمات (type='route' أو type='camping')
  /// المسارات والتخييمات تأتي من sites table حيث type='route' أو type='camping'
  Future<List<PathModel>> getRoutesAndCamping() async {
    if (useApi) {
      try {
        print('🔄 جلب المسارات والتخييمات من API...');
        print('   📌 نوع الطلب: type=route و type=camping');
        print(
          '   📌 المتوقع: المسارات والتخييمات فقط (type=\'route\' أو type=\'camping\' في قاعدة البيانات)',
        );

        // جلب المسارات (routes)
        print('   🔄 جلب المسارات (type=route)...');
        final routes = await _fetchSitesFromApi(type: 'route', search: null);
        print('✅ تم جلب ${routes.length} مسار من API');

        // التحقق من type في النتائج
        final routesWithType =
            routes
                .where(
                  (route) =>
                      route.type != null &&
                      route.type!.toLowerCase() == 'route',
                )
                .length;
        print(
          '   📊 المسارات مع type=\'route\': $routesWithType/${routes.length}',
        );

        // جلب التخييمات (camping)
        print('   🔄 جلب التخييمات (type=camping)...');
        final camping = await _fetchSitesFromApi(type: 'camping', search: null);
        print('✅ تم جلب ${camping.length} تخييم من API');

        // التحقق من type في النتائج
        final campingWithType =
            camping
                .where(
                  (camp) =>
                      camp.type != null &&
                      camp.type!.toLowerCase() == 'camping',
                )
                .length;
        print(
          '   📊 التخييمات مع type=\'camping\': $campingWithType/${camping.length}',
        );

        // دمج النتائج
        final allRoutesAndCamping = [...routes, ...camping];
        print('✅ إجمالي المسارات والتخييمات: ${allRoutesAndCamping.length}');
        print('   - المسارات: ${routes.length}');
        print('   - التخييمات: ${camping.length}');

        if (routesWithType < routes.length ||
            campingWithType < camping.length) {
          print('   ⚠️ تحذير: بعض المسارات/التخييمات لا تحتوي على type الصحيح');
        }

        return allRoutesAndCamping;
      } catch (e) {
        print('❌ خطأ في جلب المسارات والتخييمات: $e');
        return [];
      }
    } else {
      // إذا لم يكن API مفعل، فلتر البيانات الوهمية
      if (useDummyDataAsFallback) {
        final allPaths = await _getDummyPaths();
        return allPaths.where((path) {
          // في البيانات الوهمية، نعتبر المسارات والتخييمات
          return path.activities.contains(ActivityType.hiking) ||
              path.activities.contains(ActivityType.camping) ||
              path.length >= 5.0;
        }).toList();
      }
      return [];
    }
  }

  /// Get dummy paths data (fallback)
  Future<List<PathModel>> _getDummyPaths() async {
    return [
      PathModel(
        id: '1',
        name: 'Upper Galilee Trail',
        nameAr: 'مسار الجليل الأعلى',
        description:
            'A beautiful trail through the Upper Galilee region, offering breathtaking views of the Mediterranean Sea and surrounding mountains. The path passes through historic Palestinian villages and ancient olive groves.',
        descriptionAr:
            'مسار جميل عبر منطقة الجليل الأعلى، يوفر إطلالات خلابة على البحر المتوسط والجبال المحيطة. يمر المسار عبر قرى فلسطينية تاريخية وبساتين زيتون قديمة.',
        location: 'Upper Galilee, Northern Palestine',
        locationAr: 'الجليل الأعلى، شمال فلسطين',
        images: ['assets/images/galilee3.jpg'],
        length: 12.5,
        estimatedDuration: const Duration(hours: 4),
        difficulty: DifficultyLevel.medium,
        activities: [
          ActivityType.hiking,
          ActivityType.nature,
          ActivityType.camping,
        ],
        coordinates: [
          LatLng(33.0479, 35.3923),
          LatLng(33.0485, 35.3930),
          LatLng(33.0490, 35.3940),
          LatLng(33.0495, 35.3950),
        ],
        rating: 4.7,
        reviewCount: 128,
        warnings: [
          'Bring plenty of water',
          'Start early in summer',
          'Some sections may be slippery after rain',
        ],
        warningsAr: [
          'احرص على أخذ كمية كافية من الماء',
          'يُنصح بالبدء في الصباح الباكر في فصل الصيف',
          'بعض المقاطع قد تكون زلقة بعد المطر',
        ],
        guide: GuideModel(
          id: '1',
          name: 'Ahmed Al-Masri',
          nameAr: 'أحمد المصري',
          bio:
              'Experienced hiking guide with over 10 years of experience leading tours in the Upper Galilee region. Specializes in nature photography and cultural heritage tours.',
          bioAr:
              'مرشد سياحي ذو خبرة تزيد عن 10 سنوات في قيادة الجولات في منطقة الجليل الأعلى. متخصص في التصوير الفوتوغرافي للطبيعة وجولات التراث الثقافي.',
          phone: '+970-59-123-4567',
          languages: 'Arabic, English, Hebrew',
          routePrice: 250.0,
          rating: 4.8,
          reviewCount: 45,
        ),
        price: 250.0,
      ),
      PathModel(
        id: '2',
        name: 'Wadi Qelt Hike',
        nameAr: 'مسار وادي القلط',
        description:
            'A dramatic desert canyon hike in the wilderness east of Jerusalem. Wadi Qelt features ancient aqueducts, monasteries carved into cliffs, and lush oases in the midst of the desert.',
        descriptionAr:
            'مسار مذهل في وادي صحراوي شرق القدس. يضم وادي القلط قنوات مياه قديمة وأديرة منحوتة في الصخور وواحات خضراء وسط الصحراء.',
        location: 'Jericho, West Bank',
        locationAr: 'أريحا، الضفة الغربية',
        images: [
          'assets/images/wadi_qelt1.jpg',
          'assets/images/wadi_qelt2.jpg',
          'assets/images/wadi_qelt3.jpg',
        ],
        length: 15.0,
        estimatedDuration: const Duration(hours: 6),
        difficulty: DifficultyLevel.hard,
        activities: [
          ActivityType.hiking,
          ActivityType.nature,
          ActivityType.archaeological,
          ActivityType.religious,
        ],
        coordinates: [
          LatLng(31.8389, 35.3360),
          LatLng(31.8380, 35.3370),
          LatLng(31.8375, 35.3380),
          LatLng(31.8370, 35.3390),
        ],
        rating: 4.9,
        reviewCount: 235,
        warnings: [
          'Extremely hot in summer months',
          'Carry at least 3 liters of water per person',
          'Wear sun protection',
          'Some sections require scrambling',
        ],
        warningsAr: [
          'حار جداً في أشهر الصيف',
          'احمل ما لا يقل عن 3 لترات من الماء للشخص',
          'ارتدِ واقٍ من الشمس',
          'بعض المقاطع تتطلب التسلق',
        ],
        guide: GuideModel(
          id: '2',
          name: 'Fatima Al-Khalil',
          nameAr: 'فاطمة الخليل',
          bio:
              'Desert guide specializing in historical and religious sites. Expert in desert survival and navigation. Fluent in Arabic, English, and French.',
          bioAr:
              'مرشدة صحراوية متخصصة في المواقع التاريخية والدينية. خبيرة في البقاء في الصحراء والملاحة. تتحدث العربية والإنجليزية والفرنسية بطلاقة.',
          phone: '+970-59-987-6543',
          languages: 'Arabic, English, French',
          routePrice: 300.0,
          rating: 4.9,
          reviewCount: 67,
        ),
        price: 300.0,
      ),
      PathModel(
        id: '3',
        name: 'Battir Terraces Trail',
        nameAr: 'مسار مدرجات بتير',
        description:
            'Explore the UNESCO World Heritage ancient agricultural terraces of Battir. This trail takes you through a landscape of remarkable beauty with traditional Palestinian agricultural practices dating back thousands of years.',
        descriptionAr:
            'استكشف المدرجات الزراعية القديمة في بتير المدرجة في قائمة التراث العالمي لليونسكو. يأخذك هذا المسار عبر منظر طبيعي ذي جمال استثنائي مع ممارسات زراعية فلسطينية تقليدية يعود تاريخها إلى آلاف السنين.',
        location: 'Battir, Bethlehem',
        locationAr: 'بتير، بيت لحم',
        images: [
          'assets/images/battir1.jpg',
          'assets/images/battir2.jpg',
          'assets/images/battir3.jpg',
        ],
        length: 8.0,
        estimatedDuration: const Duration(hours: 3),
        difficulty: DifficultyLevel.easy,
        activities: [
          ActivityType.hiking,
          ActivityType.cultural,
          ActivityType.nature,
        ],
        coordinates: [
          LatLng(31.7269, 35.1399),
          LatLng(31.7260, 35.1390),
          LatLng(31.7255, 35.1385),
          LatLng(31.7250, 35.1380),
        ],
        rating: 4.6,
        reviewCount: 98,
        warnings: [
          'Respect private agricultural areas',
          'Stay on marked trails',
        ],
        warningsAr: [
          'احترم المناطق الزراعية الخاصة',
          'ابق على المسارات المحددة',
        ],
        guide: GuideModel(
          id: '3',
          name: 'Omar Al-Battir',
          nameAr: 'عمر البتير',
          bio:
              'Cultural heritage guide specializing in UNESCO World Heritage sites. Expert in traditional Palestinian agriculture and historical terraces.',
          bioAr:
              'مرشد تراث ثقافي متخصص في مواقع التراث العالمي لليونسكو. خبير في الزراعة الفلسطينية التقليدية والمدرجات التاريخية.',
          phone: '+970-59-234-5678',
          languages: 'Arabic, English',
          routePrice: 200.0,
          rating: 4.7,
          reviewCount: 52,
        ),
        price: 200.0,
      ),
      PathModel(
        id: '4',
        name: 'Sebastia Archaeological Site',
        nameAr: 'الموقع الأثري سبسطية',
        description:
            'Walk through the ancient ruins of Sebastia, a site with layers of history from Canaanite, Israelite, Hellenistic, Herodian, Roman, Byzantine, and Ottoman periods. Explore Roman colonnades, a Crusader cathedral, and an ancient theater.',
        descriptionAr:
            'تجول بين أنقاض سبسطية القديمة، موقع يحتوي على طبقات من التاريخ من الفترات الكنعانية والإسرائيلية والهلنستية والهيرودية والرومانية والبيزنطية والعثمانية. استكشف الأعمدة الرومانية وكاتدرائية الصليبيين والمسرح القديم.',
        location: 'Nablus, West Bank',
        locationAr: 'نابلس، الضفة الغربية',
        images: [
          'assets/images/sebastia1.jpg',
          'assets/images/sebastia2.jpg',
          'assets/images/sebastia3.jpg',
        ],
        length: 3.5,
        estimatedDuration: const Duration(hours: 2),
        difficulty: DifficultyLevel.easy,
        activities: [
          ActivityType.archaeological,
          ActivityType.cultural,
          ActivityType.hiking,
        ],
        coordinates: [
          LatLng(32.2761, 35.1869),
          LatLng(32.2755, 35.1865),
          LatLng(32.2750, 35.1860),
          LatLng(32.2745, 35.1855),
        ],
        rating: 4.5,
        reviewCount: 79,
        warnings: [
          'Limited shade in summer',
          'Wear comfortable shoes for uneven terrain',
        ],
        warningsAr: [
          'ظل محدود في الصيف',
          'ارتدِ أحذية مريحة للتضاريس غير المستوية',
        ],
        guide: GuideModel(
          id: '4',
          name: 'Sami Al-Nablusi',
          nameAr: 'سامي النابلسي',
          bio:
              'Archaeological guide with deep knowledge of ancient civilizations. Specializes in Roman, Byzantine, and Ottoman history.',
          bioAr:
              'مرشد أثري ذو معرفة عميقة بالحضارات القديمة. متخصص في التاريخ الروماني والبيزنطي والعثماني.',
          phone: '+970-59-345-6789',
          languages: 'Arabic, English, Turkish',
          routePrice: 180.0,
          rating: 4.6,
          reviewCount: 41,
        ),
        price: 180.0,
      ),
      PathModel(
        id: '5',
        name: 'Mar Saba Monastery Trail',
        nameAr: 'مسار دير مار سابا',
        description:
            'A desert hike to the spectacular Mar Saba Monastery, clinging to the cliffs of the Kidron Valley. Built in the 5th century, this Greek Orthodox monastery offers stunning architecture in a dramatic setting.',
        descriptionAr:
            'رحلة صحراوية إلى دير مار سابا المذهل، المتشبث بمنحدرات وادي قدرون. بُني هذا الدير الأرثوذكسي اليوناني في القرن الخامس، ويوفر هندسة معمارية مذهلة في إطار مثير.',
        location: 'Bethlehem, West Bank',
        locationAr: 'بيت لحم، الضفة الغربية',
        images: [
          'assets/images/mar_saba1.jpg',
          'assets/images/mar_saba2.jpg',
          'assets/images/mar_saba3.jpg',
        ],
        length: 10.0,
        estimatedDuration: const Duration(hours: 4),
        difficulty: DifficultyLevel.medium,
        activities: [
          ActivityType.hiking,
          ActivityType.religious,
          ActivityType.nature,
        ],
        coordinates: [
          LatLng(31.7025, 35.3417),
          LatLng(31.7020, 35.3420),
          LatLng(31.7015, 35.3425),
          LatLng(31.7010, 35.3430),
        ],
        rating: 4.8,
        reviewCount: 112,
        warnings: [
          'Very hot in summer, start early',
          'No water sources along the trail',
          'Note: Women are not allowed inside the monastery but can view from outside',
        ],
        warningsAr: [
          'حار جداً في الصيف، ابدأ مبكراً',
          'لا توجد مصادر مياه على طول المسار',
          'ملاحظة: لا يُسمح للنساء بدخول الدير ولكن يمكنهن المشاهدة من الخارج',
        ],
        guide: GuideModel(
          id: '5',
          name: 'George Al-Bethlehem',
          nameAr: 'جورج بيت لحم',
          bio:
              'Religious sites guide specializing in Christian heritage and monasteries. Expert in Byzantine and Orthodox traditions.',
          bioAr:
              'مرشد مواقع دينية متخصص في التراث المسيحي والأديرة. خبير في التقاليد البيزنطية والأرثوذكسية.',
          phone: '+970-59-456-7890',
          languages: 'Arabic, English, Greek',
          routePrice: 220.0,
          rating: 4.8,
          reviewCount: 68,
        ),
        price: 220.0,
      ),
      PathModel(
        id: '6',
        name: 'Jericho Oasis Walk',
        nameAr: 'مسار واحة أريحا',
        description:
            'Explore the lush oasis of Jericho, one of the oldest continuously inhabited cities in the world. Visit the ancient Tel es-Sultan, Hisham\'s Palace, and walk through date palm groves and banana plantations.',
        descriptionAr:
            'استكشف واحة أريحا الخصبة، إحدى أقدم المدن المأهولة باستمرار في العالم. قم بزيارة تل السلطان القديم وقصر هشام والمشي عبر بساتين النخيل وزراعات الموز.',
        location: 'Jericho, West Bank',
        locationAr: 'أريحا، الضفة الغربية',
        images: [
          'assets/images/jericho1.jpg',
          'assets/images/jericho2.jpg',
          'assets/images/jericho3.jpg',
        ],
        length: 5.0,
        estimatedDuration: const Duration(hours: 2, minutes: 30),
        difficulty: DifficultyLevel.easy,
        activities: [
          ActivityType.cultural,
          ActivityType.archaeological,
          ActivityType.nature,
        ],
        coordinates: [
          LatLng(31.8711, 35.4444),
          LatLng(31.8715, 35.4440),
          LatLng(31.8720, 35.4435),
          LatLng(31.8725, 35.4430),
        ],
        rating: 4.4,
        reviewCount: 165,
        warnings: [
          'Extremely hot in summer (lowest elevation on Earth)',
          'Bring plenty of water',
        ],
        warningsAr: [
          'حار للغاية في الصيف (أخفض ارتفاع على الأرض)',
          'أحضر الكثير من الماء',
        ],
        guide: GuideModel(
          id: '6',
          name: 'Yusuf Al-Jericho',
          nameAr: 'يوسف أريحا',
          bio:
              'Oasis guide specializing in ancient city tours and agricultural heritage. Expert in Jericho\'s 10,000-year history.',
          bioAr:
              'مرشد واحة متخصص في جولات المدن القديمة والتراث الزراعي. خبير في تاريخ أريحا الذي يمتد لـ 10,000 عام.',
          phone: '+970-59-567-8901',
          languages: 'Arabic, English',
          routePrice: 190.0,
          rating: 4.6,
          reviewCount: 55,
        ),
        price: 190.0,
      ),
      PathModel(
        id: '7',
        name: 'Makhrour Valley Trail',
        nameAr: 'مسار وادي المخرور',
        description:
            'A picturesque hike through Makhrour Valley near Bethlehem, featuring traditional Palestinian agricultural terraces, olive groves, and seasonal wildflowers. The valley is known for its natural springs and biodiversity.',
        descriptionAr:
            'رحلة خلابة عبر وادي المخرور بالقرب من بيت لحم، تضم مدرجات زراعية فلسطينية تقليدية وبساتين زيتون وزهور برية موسمية. يشتهر الوادي بينابيعه الطبيعية وتنوعه البيولوجي.',
        location: 'Bethlehem, West Bank',
        locationAr: 'بيت لحم، الضفة الغربية',
        images: [
          'assets/images/makhrour1.jpg',
          'assets/images/makhrour2.jpg',
          'assets/images/makhrour3.jpg',
        ],
        length: 7.5,
        estimatedDuration: const Duration(hours: 3),
        difficulty: DifficultyLevel.medium,
        activities: [
          ActivityType.hiking,
          ActivityType.nature,
          ActivityType.cultural,
        ],
        coordinates: [
          LatLng(31.7172, 35.1613),
          LatLng(31.7165, 35.1620),
          LatLng(31.7160, 35.1625),
          LatLng(31.7155, 35.1630),
        ],
        rating: 4.6,
        reviewCount: 88,
        warnings: ['Some steep sections', 'Trail can be overgrown in spring'],
        warningsAr: [
          'بعض المقاطع الحادة',
          'يمكن أن يكون المسار مغطى بالأعشاب في الربيع',
        ],
        guide: GuideModel(
          id: '7',
          name: 'Khalil Al-Bethlehem',
          nameAr: 'خليل بيت لحم',
          bio:
              'Nature guide specializing in valleys and agricultural terraces. Expert in Palestinian flora, fauna, and traditional farming.',
          bioAr:
              'مرشد طبيعة متخصص في الوديان والمدرجات الزراعية. خبير في النباتات والحيوانات الفلسطينية والزراعة التقليدية.',
          phone: '+970-59-678-9012',
          languages: 'Arabic, English',
          routePrice: 210.0,
          rating: 4.7,
          reviewCount: 61,
        ),
        price: 210.0,
      ),
      PathModel(
        id: '8',
        name: 'Umm Qais Ancient City',
        nameAr: 'مدينة أم قيس القديمة',
        description:
            'Explore the ancient Greco-Roman city of Gadara (modern Umm Qais) with spectacular views over the Sea of Galilee, Golan Heights, and Jordan Valley. This archaeological site includes a well-preserved theater, colonnaded street, and Byzantine church.',
        descriptionAr:
            'استكشف مدينة جدارا اليونانية الرومانية القديمة (أم قيس الحديثة) مع إطلالات مذهلة على بحيرة طبريا، مرتفعات الجولان، ووادي الأردن. يتضمن هذا الموقع الأثري مسرحًا جيد الحفظ وشارعًا معمدًا وكنيسة بيزنطية.',
        location: 'Northern Jordan Valley',
        locationAr: 'شمال وادي الأردن',
        images: [
          'assets/images/umm_qais1.jpg',
          'assets/images/umm_qais2.jpg',
          'assets/images/umm_qais3.jpg',
        ],
        length: 4.0,
        estimatedDuration: const Duration(hours: 2),
        difficulty: DifficultyLevel.easy,
        activities: [
          ActivityType.archaeological,
          ActivityType.cultural,
          ActivityType.hiking,
        ],
        coordinates: [
          LatLng(32.6533, 35.6852),
          LatLng(32.6530, 35.6855),
          LatLng(32.6525, 35.6860),
          LatLng(32.6520, 35.6865),
        ],
        rating: 4.5,
        reviewCount: 76,
        warnings: [
          'Limited shade in archaeological areas',
          'Wear good walking shoes for ancient stone paths',
        ],
        warningsAr: [
          'ظل محدود في المناطق الأثرية',
          'ارتدِ أحذية مشي جيدة للمسارات الحجرية القديمة',
        ],
        guide: GuideModel(
          id: '8',
          name: 'Hassan Al-Umm Qais',
          nameAr: 'حسان أم قيس',
          bio:
              'Archaeological guide specializing in Greco-Roman ruins. Expert in ancient Decapolis cities and their history.',
          bioAr:
              'مرشد أثري متخصص في الآثار اليونانية الرومانية. خبير في مدن الديكابوليس القديمة وتاريخها.',
          phone: '+970-59-789-0123',
          languages: 'Arabic, English, Greek',
          routePrice: 195.0,
          rating: 4.5,
          reviewCount: 48,
        ),
        price: 195.0,
      ),
      PathModel(
        id: '9',
        name: 'Rashayda Desert Camp',
        nameAr: 'مخيم الرشايدة الصحراوي',
        description:
            'Experience traditional Bedouin hospitality in the eastern desert near the Dead Sea. This camping trip includes cultural experiences with local communities, stargazing, and short desert hikes.',
        descriptionAr:
            'جرب الضيافة البدوية التقليدية في الصحراء الشرقية بالقرب من البحر الميت. تتضمن هذه الرحلة التخييمية تجارب ثقافية مع المجتمعات المحلية ومراقبة النجوم ورحلات صحراوية قصيرة.',
        location: 'Dead Sea Region, West Bank',
        locationAr: 'منطقة البحر الميت، الضفة الغربية',
        images: [
          'assets/images/rashayda1.jpg',
          'assets/images/rashayda2.jpg',
          'assets/images/rashayda3.jpg',
        ],
        length: 6.0,
        estimatedDuration: const Duration(hours: 20), // Overnight
        difficulty: DifficultyLevel.medium,
        activities: [
          ActivityType.camping,
          ActivityType.cultural,
          ActivityType.hiking,
        ],
        coordinates: [
          LatLng(31.6100, 35.3972),
          LatLng(31.6095, 35.3975),
          LatLng(31.6090, 35.3980),
          LatLng(31.6085, 35.3985),
        ],
        rating: 4.9,
        reviewCount: 58,
        warnings: [
          'Very hot during day, cold at night',
          'No cellular service in some areas',
          'Bring sleeping bag or warm clothes for night',
        ],
        warningsAr: [
          'حار جداً خلال النهار، بارد في الليل',
          'لا توجد خدمة خلوية في بعض المناطق',
          'أحضر كيس نوم أو ملابس دافئة لليل',
        ],
        guide: GuideModel(
          id: '9',
          name: 'Mohammad Al-Rashayda',
          nameAr: 'محمد الرشايدة',
          bio:
              'Bedouin guide specializing in desert camping and cultural experiences. Expert in traditional Bedouin hospitality and desert survival.',
          bioAr:
              'مرشد بدوي متخصص في التخييم الصحراوي والتجارب الثقافية. خبير في الضيافة البدوية التقليدية والبقاء في الصحراء.',
          phone: '+970-59-890-1234',
          languages: 'Arabic, English',
          routePrice: 350.0,
          rating: 4.9,
          reviewCount: 58,
        ),
        price: 350.0,
      ),
      PathModel(
        id: '10',
        name: 'Hebron Old City Tour',
        nameAr: 'جولة مدينة الخليل القديمة',
        description:
            'Discover the historical and cultural significance of Hebron\'s Old City, with its traditional markets, ancient architecture, and religious sites including the Ibrahimi Mosque/Cave of the Patriarchs.',
        descriptionAr:
            'اكتشف الأهمية التاريخية والثقافية لمدينة الخليل القديمة، بأسواقها التقليدية وعمارتها القديمة ومواقعها الدينية بما في ذلك المسجد الإبراهيمي/مغارة البطاركة.',
        location: 'Hebron, West Bank',
        locationAr: 'الخليل، الضفة الغربية',
        images: [
          'assets/images/hebron1.jpg',
          'assets/images/hebron2.jpg',
          'assets/images/hebron3.jpg',
        ],
        length: 3.0,
        estimatedDuration: const Duration(hours: 3),
        difficulty: DifficultyLevel.easy,
        activities: [ActivityType.cultural, ActivityType.religious],
        coordinates: [
          LatLng(31.5294, 35.1007),
          LatLng(31.5290, 35.1010),
          LatLng(31.5285, 35.1015),
          LatLng(31.5280, 35.1020),
        ],
        rating: 4.7,
        reviewCount: 105,
        warnings: [
          'Respect dress codes at religious sites',
          'Be aware of security checkpoints in the area',
        ],
        warningsAr: [
          'احترم قواعد اللباس في المواقع الدينية',
          'كن على دراية بنقاط التفتيش الأمنية في المنطقة',
        ],
        guide: GuideModel(
          id: '10',
          name: 'Ibrahim Al-Hebron',
          nameAr: 'إبراهيم الخليل',
          bio:
              'Cultural guide specializing in Hebron\'s Old City and religious heritage. Expert in traditional markets and historical architecture.',
          bioAr:
              'مرشد ثقافي متخصص في مدينة الخليل القديمة والتراث الديني. خبير في الأسواق التقليدية والعمارة التاريخية.',
          phone: '+970-59-901-2345',
          languages: 'Arabic, English',
          routePrice: 175.0,
          rating: 4.7,
          reviewCount: 63,
        ),
        price: 175.0,
      ),
      PathModel(
        id: '11',
        name: 'Gaza Beach Walk',
        nameAr: 'مشي على شاطئ غزة',
        description:
            'A peaceful coastal walk along Gaza\'s Mediterranean shoreline. Experience the beauty of the sea while visiting local fishing communities and enjoying fresh seafood at beachside cafes.',
        descriptionAr:
            'نزهة ساحلية هادئة على طول شاطئ غزة المتوسطي. استمتع بجمال البحر أثناء زيارة مجتمعات الصيد المحلية والاستمتاع بالمأكولات البحرية الطازجة في المقاهي الساحلية.',
        location: 'Gaza City, Gaza Strip',
        locationAr: 'مدينة غزة، قطاع غزة',
        images: [
          'assets/images/gaza1.jpg',
          'assets/images/gaza2.jpg',
          'assets/images/gaza3.jpg',
        ],
        length: 5.0,
        estimatedDuration: const Duration(hours: 2),
        difficulty: DifficultyLevel.easy,
        activities: [ActivityType.nature, ActivityType.cultural],
        coordinates: [
          LatLng(31.5250, 34.4450),
          LatLng(31.5255, 34.4455),
          LatLng(31.5260, 34.4460),
          LatLng(31.5265, 34.4465),
        ],
        rating: 4.6,
        reviewCount: 94,
        warnings: [
          'Check current conditions before planning visit',
          'Swimming may not be safe in some areas',
        ],
        warningsAr: [
          'تحقق من الظروف الحالية قبل التخطيط للزيارة',
          'قد لا تكون السباحة آمنة في بعض المناطق',
        ],
        guide: GuideModel(
          id: '11',
          name: 'Mahmoud Al-Gaza',
          nameAr: 'محمود غزة',
          bio:
              'Coastal guide specializing in Mediterranean beaches and fishing communities. Expert in Gaza\'s maritime heritage and local culture.',
          bioAr:
              'مرشد ساحلي متخصص في الشواطئ المتوسطية ومجتمعات الصيد. خبير في التراث البحري لقطاع غزة والثقافة المحلية.',
          phone: '+970-59-012-3456',
          languages: 'Arabic, English',
          routePrice: 160.0,
          rating: 4.6,
          reviewCount: 47,
        ),
        price: 160.0,
      ),
      PathModel(
        id: '12',
        name: 'Dead Sea Floating Experience',
        nameAr: 'تجربة الطفو في البحر الميت',
        description:
            'Experience the unique feeling of floating in the Dead Sea, the lowest point on Earth. Cover yourself with the famous mineral-rich mud known for its therapeutic properties.',
        descriptionAr:
            'استمتع بتجربة الطفو الفريدة في البحر الميت، أخفض نقطة على الأرض. غطِ نفسك بالطين الغني بالمعادن المشهور بخصائصه العلاجية.',
        location: 'Dead Sea, West Bank',
        locationAr: 'البحر الميت، الضفة الغربية',
        images: [
          'assets/images/dead_sea1.jpg',
          'assets/images/dead_sea2.jpg',
          'assets/images/dead_sea3.jpg',
        ],
        length: 1.0,
        estimatedDuration: const Duration(hours: 3),
        difficulty: DifficultyLevel.easy,
        activities: [ActivityType.nature],
        coordinates: [
          LatLng(31.5569, 35.4731),
          LatLng(31.5565, 35.4735),
          LatLng(31.5560, 35.4740),
          LatLng(31.5555, 35.4745),
        ],
        rating: 4.9,
        reviewCount: 212,
        warnings: [
          'Do not shave 24 hours before visit',
          'Avoid getting saltwater in eyes',
          'Extremely hot in summer months',
          'Bring fresh water to rinse off after swimming',
        ],
        warningsAr: [
          'لا تحلق قبل 24 ساعة من الزيارة',
          'تجنب دخول المياه المالحة في العينين',
          'حار للغاية في أشهر الصيف',
          'أحضر ماء عذب للشطف بعد السباحة',
        ],
        guide: GuideModel(
          id: '12',
          name: 'Amjad Al-Dead Sea',
          nameAr: 'أمجد البحر الميت',
          bio:
              'Dead Sea specialist guide with expertise in therapeutic mud treatments and mineral benefits. Expert in the unique ecosystem of the Dead Sea region.',
          bioAr:
              'مرشد متخصص في البحر الميت ذو خبرة في علاجات الطين العلاجية وفوائد المعادن. خبير في النظام البيئي الفريد لمنطقة البحر الميت.',
          phone: '+970-59-123-4567',
          languages: 'Arabic, English, Hebrew',
          routePrice: 240.0,
          rating: 4.9,
          reviewCount: 89,
        ),
        price: 240.0,
      ),
      PathModel(
        id: '13',
        name: 'Mount Gerizim Samaritan Trail',
        nameAr: 'مسار جبل جرزيم السامري',
        description:
            'Explore Mount Gerizim, home to the ancient Samaritan community. This trail offers incredible views of Nablus city and insights into one of the world\'s oldest and smallest religious communities.',
        descriptionAr:
            'استكشف جبل جرزيم، موطن المجتمع السامري القديم. يوفر هذا المسار إطلالات رائعة على مدينة نابلس ونظرة عميقة على واحد من أقدم وأصغر المجتمعات الدينية في العالم.',
        location: 'Nablus, West Bank',
        locationAr: 'نابلس، الضفة الغربية',
        images: [
          'assets/images/gerizim1.jpg',
          'assets/images/gerizim2.jpg',
          'assets/images/gerizim3.jpg',
        ],
        length: 6.0,
        estimatedDuration: const Duration(hours: 3),
        difficulty: DifficultyLevel.medium,
        activities: [
          ActivityType.hiking,
          ActivityType.cultural,
          ActivityType.religious,
        ],
        coordinates: [
          LatLng(32.2006, 35.2846),
          LatLng(32.2000, 35.2850),
          LatLng(32.1995, 35.2855),
          LatLng(32.1990, 35.2860),
        ],
        rating: 4.5,
        reviewCount: 67,
        warnings: [
          'Respect local Samaritan community',
          'Dress modestly when visiting religious sites',
        ],
        warningsAr: [
          'احترم المجتمع السامري المحلي',
          'ارتدِ ملابس محتشمة عند زيارة المواقع الدينية',
        ],
        guide: GuideModel(
          id: '13',
          name: 'Yacoub Al-Nablusi',
          nameAr: 'يعقوب النابلسي',
          bio:
              'Religious and cultural guide specializing in Samaritan community and Mount Gerizim. Expert in ancient religious traditions and local history.',
          bioAr:
              'مرشد ديني وثقافي متخصص في المجتمع السامري وجبل جرزيم. خبير في التقاليد الدينية القديمة والتاريخ المحلي.',
          phone: '+970-59-234-5678',
          languages: 'Arabic, English, Hebrew',
          routePrice: 185.0,
          rating: 4.5,
          reviewCount: 38,
        ),
        price: 185.0,
      ),
      PathModel(
        id: '14',
        name: 'Tent of Nations Farm Experience',
        nameAr: 'تجربة مزرعة خيمة الأمم',
        description:
            'Visit the inspirational Tent of Nations farm, an environmental and educational peace project on a 100-acre hilltop farm near Bethlehem. Participate in olive harvesting, tree planting, or other seasonal agricultural activities.',
        descriptionAr:
            'زر مزرعة خيمة الأمم الملهمة، وهي مشروع سلام بيئي وتعليمي على مزرعة تبلغ مساحتها 100 فدان على قمة تل بالقرب من بيت لحم. شارك في حصاد الزيتون، زراعة الأشجار، أو غيرها من الأنشطة الزراعية الموسمية.',
        location: 'Bethlehem, West Bank',
        locationAr: 'بيت لحم، الضفة الغربية',
        images: [
          'assets/images/tent_nations1.jpg',
          'assets/images/tent_nations2.jpg',
          'assets/images/tent_nations3.jpg',
        ],
        length: 3.0,
        estimatedDuration: const Duration(hours: 4),
        difficulty: DifficultyLevel.easy,
        activities: [
          ActivityType.nature,
          ActivityType.cultural,
          ActivityType.camping,
        ],
        coordinates: [
          LatLng(31.6892, 35.1478),
          LatLng(31.6890, 35.1480),
          LatLng(31.6885, 35.1485),
          LatLng(31.6880, 35.1490),
        ],
        rating: 4.8,
        reviewCount: 82,
        warnings: [
          'Call ahead to arrange visit',
          'Facilities are simple and eco-friendly',
        ],
        warningsAr: [
          'اتصل مسبقاً لترتيب الزيارة',
          'المرافق بسيطة وصديقة للبيئة',
        ],
        guide: GuideModel(
          id: '14',
          name: 'Daoud Al-Bethlehem',
          nameAr: 'داود بيت لحم',
          bio:
              'Environmental and peace guide specializing in sustainable agriculture and community projects. Expert in olive cultivation and ecological farming.',
          bioAr:
              'مرشد بيئي وسلام متخصص في الزراعة المستدامة ومشاريع المجتمع. خبير في زراعة الزيتون والزراعة البيئية.',
          phone: '+970-59-345-6789',
          languages: 'Arabic, English, German',
          routePrice: 230.0,
          rating: 4.8,
          reviewCount: 56,
        ),
        price: 230.0,
      ),
      PathModel(
        id: '15',
        name: 'Ramallah Cultural Tour',
        nameAr: 'جولة ثقافية في رام الله',
        description:
            'Explore the vibrant cultural scene of Ramallah, the de facto administrative capital of Palestine. Visit museums, galleries, cafes, and the bustling old market.',
        descriptionAr:
            'استكشف المشهد الثقافي النابض بالحياة في رام الله، العاصمة الإدارية الفعلية لفلسطين. زر المتاحف والمعارض والمقاهي والسوق القديم المزدحم.',
        location: 'Ramallah, West Bank',
        locationAr: 'رام الله، الضفة الغربية',
        images: [
          'assets/images/ramallah1.jpg',
          'assets/images/ramallah2.jpg',
          'assets/images/ramallah3.jpg',
        ],
        length: 4.0,
        estimatedDuration: const Duration(hours: 5),
        difficulty: DifficultyLevel.easy,
        activities: [ActivityType.cultural],
        coordinates: [
          LatLng(31.9031, 35.2042),
          LatLng(31.9035, 35.2045),
          LatLng(31.9040, 35.2050),
          LatLng(31.9045, 35.2055),
        ],
        rating: 4.4,
        reviewCount: 103,
        warnings: [
          'Traffic can be heavy in city center',
          'Some museums closed on Mondays',
        ],
        warningsAr: [
          'حركة المرور قد تكون كثيفة في وسط المدينة',
          'بعض المتاحف مغلقة أيام الاثنين',
        ],
        guide: GuideModel(
          id: '15',
          name: 'Lina Al-Ramallah',
          nameAr: 'لينا رام الله',
          bio:
              'Urban cultural guide specializing in Ramallah\'s art scene, contemporary Palestinian culture, and modern city life. Expert in museums, galleries, and cultural events.',
          bioAr:
              'مرشدة ثقافية حضرية متخصصة في المشهد الفني لرام الله والثقافة الفلسطينية المعاصرة والحياة المدنية الحديثة. خبيرة في المتاحف والمعارض والفعاليات الثقافية.',
          phone: '+970-59-456-7890',
          languages: 'Arabic, English, French',
          routePrice: 170.0,
          rating: 4.7,
          reviewCount: 71,
        ),
        price: 170.0,
      ),
    ];
  }

  /// الحصول على المسارات المميزة (من المسارات والتخييمات فقط)
  /// المسارات هي الأساسية - نعرض فقط المسارات والتخييمات المميزة
  Future<List<PathModel>> getFeaturedPaths() async {
    // جلب المسارات والتخييمات فقط (المسارات هي الأساسية)
    final routesAndCamping = await getRoutesAndCamping();
    // ترتيب حسب التقييم وإرجاع أفضل 5
    routesAndCamping.sort((a, b) => b.rating.compareTo(a.rating));
    return routesAndCamping.take(5).toList();
  }

  Future<List<PathModel>> getPathsByActivity(ActivityType activity) async {
    final allPaths = await getAllPaths();
    return allPaths
        .where((path) => path.activities.contains(activity))
        .toList();
  }

  Future<List<PathModel>> getPathsByDifficulty(
    DifficultyLevel difficulty,
  ) async {
    final allPaths = await getAllPaths();
    return allPaths.where((path) => path.difficulty == difficulty).toList();
  }

  /// البحث في المسارات
  Future<List<PathModel>> searchPaths(String query) async {
    if (useApi) {
      try {
        print('🔍 البحث في المواقع: $query');
        final response = await _apiService.getSites(
          type: null, // البحث في جميع الأنواع
          search: query,
          page: null,
        );

        // معالجة الاستجابة - دعم أشكال مختلفة
        List<dynamic> pathsData = [];

        if (response['status'] == 'success' && response['data'] != null) {
          if (response['data'] is List) {
            pathsData = response['data'];
          } else if (response['data'] is Map) {
            pathsData =
                response['data']['paths'] ??
                response['data']['sites'] ??
                response['data']['data'] ??
                [];
          }
        } else if (response['data'] != null) {
          if (response['data'] is List) {
            pathsData = response['data'];
          } else if (response['data'] is Map) {
            pathsData =
                response['data']['paths'] ??
                response['data']['sites'] ??
                response['data']['data'] ??
                [];
          }
        }

        if (pathsData.isNotEmpty) {
          print('✅ تم العثور على ${pathsData.length} موقع');
          return pathsData
              .map((json) {
                try {
                  return PathModel.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  print('⚠️ خطأ في تحويل الموقع: $e');
                  return null;
                }
              })
              .whereType<PathModel>()
              .toList();
        }
        // لا توجد نتائج من API
        return [];
      } catch (e) {
        print('❌ خطأ في البحث من API: $e');
        // إرجاع قائمة فارغة عند فشل API
        return [];
      }
    }

    // إذا كان useApi = false، استخدم البحث المحلي
    final allPaths = await getAllPaths();
    final lowerQuery = query.toLowerCase();

    return allPaths.where((path) {
      return path.name.toLowerCase().contains(lowerQuery) ||
          path.nameAr.contains(lowerQuery) ||
          path.description.toLowerCase().contains(lowerQuery) ||
          path.descriptionAr.contains(lowerQuery) ||
          path.location.toLowerCase().contains(lowerQuery) ||
          path.locationAr.contains(lowerQuery);
    }).toList();
  }

  /// الحصول على مسار محدد
  Future<PathModel?> getPathById(String id) async {
    if (useApi) {
      try {
        print('🔍 جلب الموقع برقم: $id');
        final siteId = int.tryParse(id) ?? 0;
        if (siteId == 0) {
          print('⚠️ رقم الموقع غير صحيح: $id');
          return null;
        }

        final response = await _apiService.getSite(siteId);

        // معالجة الاستجابة
        Map<String, dynamic>? siteData;

        if (response['status'] == 'success' && response['data'] != null) {
          siteData =
              response['data'] is Map
                  ? response['data'] as Map<String, dynamic>
                  : null;
        } else if (response['data'] != null && response['data'] is Map) {
          siteData = response['data'] as Map<String, dynamic>;
        }

        if (siteData != null) {
          print('✅ تم جلب الموقع بنجاح');
          return PathModel.fromJson(siteData);
        }
      } catch (e) {
        print('❌ خطأ في جلب الموقع من API: $e');
      }
    }

    // Fallback to local search
    final allPaths = await getAllPaths();
    try {
      return allPaths.firstWhere((path) => path.id == id);
    } catch (e) {
      return null;
    }
  }
}
