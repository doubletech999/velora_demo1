import 'package:flutter/material.dart';

import '../../data/models/path_model.dart';
import '../../data/repositories/paths_repository.dart';
import '../../core/services/offline_cache_service.dart';

class PathsProvider extends ChangeNotifier {
  final PathsRepository _repository = PathsRepository();
  final OfflineCacheService _cacheService = OfflineCacheService();

  List<PathModel> _paths = [];
  List<PathModel> _sites = []; // الأماكن السياحية فقط
  List<PathModel> _routesAndCamping = []; // المسارات والتخييمات
  List<PathModel> _featuredPaths = [];
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;
  bool _isOffline = false;

  // Filters
  ActivityType? _selectedActivity;
  DifficultyLevel? _selectedDifficulty;
  String? _selectedLocation;

  List<PathModel> get paths => _paths;
  List<PathModel> get sites => _sites; // الأماكن السياحية
  List<PathModel> get routesAndCamping =>
      _routesAndCamping; // المسارات والتخييمات
  List<PathModel> get featuredPaths => _featuredPaths;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get initialized => _initialized;
  bool get isOffline => _isOffline;

  List<PathModel> get filteredPaths {
    return _paths.where((path) {
      bool matchesActivity =
          _selectedActivity == null ||
          path.activities.contains(_selectedActivity);
      bool matchesDifficulty =
          _selectedDifficulty == null || path.difficulty == _selectedDifficulty;
      bool matchesLocation = _selectedLocation == null;
      if (!matchesLocation && _selectedLocation != null) {
        // Check if path location matches the selected region
        final locationAr = path.locationAr;
        if (_selectedLocation == 'north') {
          matchesLocation =
              locationAr.contains('الشمال') || locationAr.contains('الجليل');
        } else if (_selectedLocation == 'center') {
          matchesLocation =
              locationAr.contains('الوسط') ||
              locationAr.contains('رام الله') ||
              locationAr.contains('نابلس');
        } else if (_selectedLocation == 'south') {
          matchesLocation =
              locationAr.contains('الجنوب') || locationAr.contains('الخليل');
        } else {
          // Fallback to old behavior for backward compatibility
          matchesLocation = locationAr.contains(_selectedLocation!);
        }
      }

      return matchesActivity && matchesDifficulty && matchesLocation;
    }).toList();
  }

  /// فلترة الأماكن السياحية
  List<PathModel> get filteredSites {
    return _sites.where((path) {
      bool matchesActivity =
          _selectedActivity == null ||
          path.activities.contains(_selectedActivity);
      bool matchesDifficulty =
          _selectedDifficulty == null || path.difficulty == _selectedDifficulty;
      bool matchesLocation = _selectedLocation == null;
      if (!matchesLocation && _selectedLocation != null) {
        final locationAr = path.locationAr;
        if (_selectedLocation == 'north') {
          matchesLocation =
              locationAr.contains('الشمال') || locationAr.contains('الجليل');
        } else if (_selectedLocation == 'center') {
          matchesLocation =
              locationAr.contains('الوسط') ||
              locationAr.contains('رام الله') ||
              locationAr.contains('نابلس');
        } else if (_selectedLocation == 'south') {
          matchesLocation =
              locationAr.contains('الجنوب') || locationAr.contains('الخليل');
        } else {
          matchesLocation = locationAr.contains(_selectedLocation!);
        }
      }

      return matchesActivity && matchesDifficulty && matchesLocation;
    }).toList();
  }

  /// فلترة المسارات والتخييمات
  List<PathModel> get filteredRoutesAndCamping {
    return _routesAndCamping.where((path) {
      bool matchesActivity =
          _selectedActivity == null ||
          path.activities.contains(_selectedActivity);
      bool matchesDifficulty =
          _selectedDifficulty == null || path.difficulty == _selectedDifficulty;
      bool matchesLocation = _selectedLocation == null;
      if (!matchesLocation && _selectedLocation != null) {
        final locationAr = path.locationAr;
        if (_selectedLocation == 'north') {
          matchesLocation =
              locationAr.contains('الشمال') || locationAr.contains('الجليل');
        } else if (_selectedLocation == 'center') {
          matchesLocation =
              locationAr.contains('الوسط') ||
              locationAr.contains('رام الله') ||
              locationAr.contains('نابلس');
        } else if (_selectedLocation == 'south') {
          matchesLocation =
              locationAr.contains('الجنوب') || locationAr.contains('الخليل');
        } else {
          matchesLocation = locationAr.contains(_selectedLocation!);
        }
      }

      return matchesActivity && matchesDifficulty && matchesLocation;
    }).toList();
  }

  PathsProvider() {
    // عدم استدعاء loadPaths في constructor
    // سيتم استدعاؤها من خلال initializeIfNeeded
  }

  // دالة للتحقق من التهيئة وتحميل البيانات إذا لم تكن محملة
  Future<void> initializeIfNeeded() async {
    if (!_initialized && !_isLoading) {
      await loadPaths();
    }
  }

  Future<void> loadPaths() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      // جلب البيانات من API (أو البيانات الوهمية إذا فشل)
      print('🔄 PathsProvider: بدء جلب البيانات...');

      // جلب جميع المسارات (للتوافق مع الكود القديم)
      _paths = await _repository.getAllPaths();

      // جلب الأماكن السياحية فقط
      _sites = await _repository.getSites();
      print('✅ PathsProvider: تم جلب ${_sites.length} مكان سياحي');

      // جلب المسارات والتخييمات
      _routesAndCamping = await _repository.getRoutesAndCamping();
      print('✅ PathsProvider: تم جلب ${_routesAndCamping.length} مسار/تخييم');

      // المسارات المميزة من المسارات والتخييمات فقط (المسارات هي الأساسية)
      _featuredPaths = await _repository.getFeaturedPaths();

      print('✅ PathsProvider: تم جلب ${_paths.length} مسار إجمالي');
      print(
        '✅ PathsProvider: تم جلب ${_featuredPaths.length} مسار مميز من المسارات والتخييمات',
      );

      // Cache the data for offline use
      final pathsJson = _paths.map((path) => path.toJson()).toList();
      await _cacheService.cachePaths(pathsJson);

      _error = null;
      _isOffline = false;
      _initialized = true;
    } catch (e) {
      print('❌ PathsProvider: خطأ في جلب البيانات: $e');
      // If loading fails, try to load from cache
      try {
        final cachedData = await _cacheService.getCachedPaths();
        if (cachedData.isNotEmpty) {
          _paths = cachedData.map((json) => PathModel.fromJson(json)).toList();

          // تصنيف البيانات من الـ cache إلى مواقع ومسارات
          // نستخدم type من PathModel مباشرة
          _sites =
              _paths.where((path) {
                // للأماكن السياحية: type='site'
                if (path.type != null) {
                  return path.type!.toLowerCase() == 'site';
                }
                // Fallback: الأماكن السياحية: لا تحتوي على hiking أو camping و length < 5.0
                return !path.activities.contains(ActivityType.hiking) &&
                    !path.activities.contains(ActivityType.camping) &&
                    path.length < 5.0;
              }).toList();

          _routesAndCamping =
              _paths.where((path) {
                // للمسارات والتخييمات: type='route' أو type='camping'
                if (path.type != null) {
                  final type = path.type!.toLowerCase();
                  return type == 'route' || type == 'camping';
                }
                // Fallback: المسارات والتخييمات: تحتوي على hiking أو camping أو length >= 5.0
                return path.activities.contains(ActivityType.hiking) ||
                    path.activities.contains(ActivityType.camping) ||
                    path.length >= 5.0;
              }).toList();

          // المسارات المميزة من المسارات والتخييمات فقط
          _featuredPaths =
              _routesAndCamping.toList()
                ..sort((a, b) => b.rating.compareTo(a.rating));
          _featuredPaths = _featuredPaths.take(5).toList();

          print('✅ PathsProvider: تم تحميل البيانات من الـ cache');
          print('   - المواقع: ${_sites.length}');
          print('   - المسارات: ${_routesAndCamping.length}');
          print('   - المميزة: ${_featuredPaths.length}');

          _error = null;
          _isOffline = true;
          _initialized = true;
        } else {
          print('❌ PathsProvider: لا توجد بيانات في الـ cache');
          _error = e.toString();
        }
      } catch (cacheError) {
        print(
          '❌ PathsProvider: خطأ في تحميل البيانات من الـ cache: $cacheError',
        );
        _error = e.toString();
      }
    } finally {
      _isLoading = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void setActivityFilter(ActivityType? activity) {
    _selectedActivity = activity;
    notifyListeners();
  }

  void setDifficultyFilter(DifficultyLevel? difficulty) {
    _selectedDifficulty = difficulty;
    notifyListeners();
  }

  void setLocationFilter(String? location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void clearFilters() {
    _selectedActivity = null;
    _selectedDifficulty = null;
    _selectedLocation = null;
    notifyListeners();
  }

  PathModel? getPathById(String id) {
    try {
      return _paths.firstWhere((path) => path.id == id);
    } catch (e) {
      return null;
    }
  }
}
