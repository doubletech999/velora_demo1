// lib/presentation/providers/map_provider.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' hide ActivityType; // إخفاء ActivityType من geolocator

import '../../core/services/location_service.dart';
import '../../core/services/maps_service.dart';
import '../../data/models/path_model.dart'; // ActivityType من هنا

class MapProvider extends ChangeNotifier {
  GoogleMapController? _mapController;
  Position? _userPosition;
  bool _isLoading = false;
  String? _error;
  
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  
  // Filters
  DifficultyLevel? _selectedDifficulty;
  ActivityType? _selectedActivity;
  String? _selectedPathId;
  
  // Getters
  GoogleMapController? get mapController => _mapController;
  Position? get userPosition => _userPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  DifficultyLevel? get selectedDifficulty => _selectedDifficulty;
  ActivityType? get selectedActivity => _selectedActivity;
  String? get selectedPathId => _selectedPathId;
  
  LatLng get currentLocation {
    if (_userPosition != null) {
      return LatLng(_userPosition!.latitude, _userPosition!.longitude);
    }
    return MapsService.palestineCenter;
  }
  
  // تهيئة الخريطة
  Future<void> initializeMap() async {
    _setLoading(true);
    
    try {
      // الحصول على الموقع الحالي
      Position? position = await LocationService.instance.getCurrentPosition();
      if (position != null) {
        _userPosition = position;
      }
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('خطأ في تهيئة الخريطة: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // تعيين متحكم الخريطة
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }
  
  // تحديث المسارات على الخريطة
  Future<void> updatePaths(List<PathModel> paths) async {
    Set<Marker> markers = {};
    Set<Polyline> polylines = {};
    
    // إضافة marker لموقع المستخدم
    if (_userPosition != null) {
      markers.add(
        MapsService.createMarker(
          markerId: 'user_location',
          position: LatLng(_userPosition!.latitude, _userPosition!.longitude),
          title: 'موقعك الحالي',
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
    
    // تطبيق الفلترة
    final filteredPaths = _filterPaths(paths);
    
    // إضافة markers و polylines للمسارات
    for (PathModel path in filteredPaths) {
      if (path.coordinates.isNotEmpty) {
        // marker البداية
        markers.add(
          MapsService.createMarker(
            markerId: 'path_start_${path.id}',
            position: LatLng(
              path.coordinates.first.latitude,
              path.coordinates.first.longitude,
            ),
            title: path.nameAr,
            snippet: path.locationAr,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _getDifficultyHue(path.difficulty),
            ),
          ),
        );
        
        // marker النهاية
        if (path.coordinates.length > 1) {
          markers.add(
            MapsService.createMarker(
              markerId: 'path_end_${path.id}',
              position: LatLng(
                path.coordinates.last.latitude,
                path.coordinates.last.longitude,
              ),
              title: 'نهاية ${path.nameAr}',
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
          );
        }
        
        // polyline المسار
        polylines.add(
          MapsService.createPolyline(
            polylineId: 'path_${path.id}',
            points: path.coordinates.map((coord) => 
              LatLng(coord.latitude, coord.longitude)
            ).toList(),
            color: path.id == _selectedPathId
                ? const Color(0xFFFF4B4B) // AppColors.secondary
                : _getDifficultyColor(path.difficulty),
            width: path.id == _selectedPathId ? 6.0 : 4.0,
          ),
        );
      }
    }
    
    _markers = markers;
    _polylines = polylines;
    notifyListeners();
  }
  
  // فلترة المسارات
  List<PathModel> _filterPaths(List<PathModel> paths) {
    return paths.where((path) {
      if (_selectedDifficulty != null && path.difficulty != _selectedDifficulty) {
        return false;
      }
      
      if (_selectedActivity != null && !path.activities.contains(_selectedActivity)) {
        return false;
      }
      
      return true;
    }).toList();
  }
  
  // تعيين فلتر الصعوبة
  void setDifficultyFilter(DifficultyLevel? difficulty) {
    _selectedDifficulty = difficulty;
    notifyListeners();
  }
  
  // تعيين فلتر النشاط
  void setActivityFilter(ActivityType? activity) {
    _selectedActivity = activity;
    notifyListeners();
  }
  
  // تحديد مسار معين
  void selectPath(String? pathId) {
    _selectedPathId = pathId;
    notifyListeners();
  }
  
  // مسح الفلاتر
  void clearFilters() {
    _selectedDifficulty = null;
    _selectedActivity = null;
    _selectedPathId = null;
    notifyListeners();
  }
  
  // تحديث الموقع الحالي
  Future<void> updateCurrentLocation() async {
    _setLoading(true);
    
    try {
      Position? position = await LocationService.instance.getCurrentPosition();
      if (position != null) {
        _userPosition = position;
        _error = null;
      }
    } catch (e) {
      _error = e.toString();
      print('خطأ في تحديث الموقع: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // التحرك إلى الموقع الحالي
  Future<void> moveToCurrentLocation() async {
    if (_mapController == null) return;
    
    if (_userPosition != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_userPosition!.latitude, _userPosition!.longitude),
          15.0,
        ),
      );
    } else {
      await updateCurrentLocation();
      if (_userPosition != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(_userPosition!.latitude, _userPosition!.longitude),
            15.0,
          ),
        );
      }
    }
  }
  
  // التحرك إلى مسار معين
  Future<void> moveToPath(PathModel path) async {
    if (_mapController == null || path.coordinates.isEmpty) return;
    
    selectPath(path.id);
    
    if (path.coordinates.length == 1) {
      // نقطة واحدة فقط
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(path.coordinates.first.latitude, path.coordinates.first.longitude),
          14.0,
        ),
      );
    } else {
      // عدة نقاط - عرض المسار كاملاً
      LatLngBounds bounds = MapsService.calculateBounds(
        path.coordinates.map((coord) => 
          LatLng(coord.latitude, coord.longitude)
        ).toList(),
      );
      
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100.0),
      );
    }
  }
  
  // عرض جميع المسارات
  Future<void> fitAllPaths(List<PathModel> paths) async {
    if (_mapController == null || paths.isEmpty) return;
    
    List<LatLng> allPoints = [];
    for (var path in paths) {
      allPoints.addAll(path.coordinates.map((coord) => 
        LatLng(coord.latitude, coord.longitude)
      ));
    }
    
    if (allPoints.isNotEmpty) {
      LatLngBounds bounds = MapsService.calculateBounds(allPoints);
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100.0),
      );
    }
  }
  
  // تكبير الخريطة
  Future<void> zoomIn() async {
    if (_mapController != null) {
      await _mapController!.animateCamera(CameraUpdate.zoomIn());
    }
  }
  
  // تصغير الخريطة
  Future<void> zoomOut() async {
    if (_mapController != null) {
      await _mapController!.animateCamera(CameraUpdate.zoomOut());
    }
  }
  
  // الحصول على المسافة إلى مسار معين
  double? getDistanceToPath(PathModel path) {
    if (_userPosition == null || path.coordinates.isEmpty) return null;
    
    LatLng userLocation = LatLng(_userPosition!.latitude, _userPosition!.longitude);
    LatLng pathStart = LatLng(path.coordinates.first.latitude, path.coordinates.first.longitude);
    
    return LocationService.instance.calculateDistanceInKm(userLocation, pathStart);
  }
  
  // ترتيب المسارات حسب القرب من المستخدم
  List<PathModel> sortPathsByDistance(List<PathModel> paths) {
    if (_userPosition == null) return paths;
    
    List<PathModel> sortedPaths = List.from(paths);
    sortedPaths.sort((a, b) {
      double? distanceA = getDistanceToPath(a);
      double? distanceB = getDistanceToPath(b);
      
      if (distanceA == null && distanceB == null) return 0;
      if (distanceA == null) return 1;
      if (distanceB == null) return -1;
      
      return distanceA.compareTo(distanceB);
    });
    
    return sortedPaths;
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  double _getDifficultyHue(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return BitmapDescriptor.hueGreen;
      case DifficultyLevel.medium:
        return BitmapDescriptor.hueOrange;
      case DifficultyLevel.hard:
        return BitmapDescriptor.hueRed;
    }
  }
  
  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return const Color(0xFF4CAF50); // AppColors.difficultyEasy
      case DifficultyLevel.medium:
        return const Color(0xFFFFC107); // AppColors.difficultyMedium
      case DifficultyLevel.hard:
        return const Color(0xFFF44336); // AppColors.difficultyHard
    }
  }
  
  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}