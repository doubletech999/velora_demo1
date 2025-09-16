import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/models/path_model.dart';
import '../../data/repositories/paths_repository.dart';

class PathsProvider extends ChangeNotifier {
  final PathsRepository _repository = PathsRepository();
  
  List<PathModel> _paths = [];
  List<PathModel> _featuredPaths = [];
  bool _isLoading = false;
  String? _error;
  bool _initialized = false; // إضافة متغير للتحقق من التهيئة
  
  // Filters
  ActivityType? _selectedActivity;
  DifficultyLevel? _selectedDifficulty;
  String? _selectedLocation;
  
  List<PathModel> get paths => _paths;
  List<PathModel> get featuredPaths => _featuredPaths;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get initialized => _initialized; // إضافة getter للتحقق من التهيئة
  
  List<PathModel> get filteredPaths {
    return _paths.where((path) {
      bool matchesActivity = _selectedActivity == null || 
          path.activities.contains(_selectedActivity);
      bool matchesDifficulty = _selectedDifficulty == null ||
          path.difficulty == _selectedDifficulty;
      bool matchesLocation = _selectedLocation == null ||
          path.locationAr.contains(_selectedLocation!);
      
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
    if (_isLoading) return; // تجنب التحميل المتكرر
    
    _isLoading = true;
    _error = null;
    
    // إشعار المستمعين بعد انتهاء البناء الحالي
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    
    try {
      _paths = await _repository.getAllPaths();
      _featuredPaths = await _repository.getFeaturedPaths();
      _error = null;
      _initialized = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      
      // إشعار المستمعين بعد انتهاء البناء الحالي
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