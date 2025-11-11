import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../data/models/path_model.dart';
import '../../data/repositories/paths_repository.dart';

class SavedPathsProvider extends ChangeNotifier {
  final PathsRepository _pathsRepository = PathsRepository();
  List<String> _savedPathIds = [];
  List<PathModel> _savedPaths = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<String> get savedPathIds => _savedPathIds;
  List<PathModel> get savedPaths => _savedPaths;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // SharedPreferences key
  static const String _savedPathIdsKey = 'savedPathIds';

  SavedPathsProvider() {
    _loadSavedPathIds();
  }

  // Load saved path IDs from SharedPreferences
  Future<void> _loadSavedPathIds() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPathIdsJson = prefs.getString(_savedPathIdsKey);
      
      if (savedPathIdsJson != null) {
        final List<dynamic> decodedList = json.decode(savedPathIdsJson);
        _savedPathIds = decodedList.map((item) => item.toString()).toList();
      }
      
      await _fetchSavedPaths();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch saved paths from repository based on saved IDs
  Future<void> _fetchSavedPaths() async {
    if (_savedPathIds.isEmpty) {
      _savedPaths = [];
      return;
    }

    try {
      final allPaths = await _pathsRepository.getAllPaths();
      _savedPaths = allPaths.where((path) => _savedPathIds.contains(path.id)).toList();
    } catch (e) {
      _error = e.toString();
    }
  }

  // Save path IDs to SharedPreferences
  Future<void> _saveSavedPathIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_savedPathIdsKey, json.encode(_savedPathIds));
    } catch (e) {
      _error = e.toString();
    }
  }

  // Check if a path is saved
  bool isPathSaved(String pathId) {
    return _savedPathIds.contains(pathId);
  }

  // Toggle saved status for a path
  Future<void> toggleSavedPath(String pathId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_savedPathIds.contains(pathId)) {
        _savedPathIds.remove(pathId);
      } else {
        _savedPathIds.add(pathId);
      }
      
      await _saveSavedPathIds();
      await _fetchSavedPaths();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a path to saved paths
  Future<void> savePath(String pathId) async {
    if (_savedPathIds.contains(pathId)) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _savedPathIds.add(pathId);
      await _saveSavedPathIds();
      await _fetchSavedPaths();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove a path from saved paths
  Future<void> removeSavedPath(String pathId) async {
    if (!_savedPathIds.contains(pathId)) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _savedPathIds.remove(pathId);
      await _saveSavedPathIds();
      await _fetchSavedPaths();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear all saved paths
  Future<void> clearAllSavedPaths() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _savedPathIds.clear();
      _savedPaths.clear();
      await _saveSavedPathIds();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh saved paths
  Future<void> refreshSavedPaths() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _fetchSavedPaths();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}