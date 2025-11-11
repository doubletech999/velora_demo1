// lib/core/services/offline_cache_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class OfflineCacheService {
  static final OfflineCacheService _instance = OfflineCacheService._internal();
  factory OfflineCacheService() => _instance;
  OfflineCacheService._internal();

  static const String _pathsCacheKey = 'cached_paths';
  static const String _pathsCacheTimestampKey = 'cached_paths_timestamp';
  static const String _pendingActionsKey = 'pending_actions';
  static const Duration _cacheExpirationDuration = Duration(hours: 24);

  /// Save paths data to cache
  Future<void> cachePaths(List<Map<String, dynamic>> pathsData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(pathsData);
      await prefs.setString(_pathsCacheKey, jsonString);
      await prefs.setInt(_pathsCacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
      debugPrint('Paths cached successfully: ${pathsData.length} paths');
    } catch (e) {
      debugPrint('Error caching paths: $e');
    }
  }

  /// Get cached paths data
  Future<List<Map<String, dynamic>>> getCachedPaths() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_pathsCacheKey);
      
      if (jsonString == null) {
        return [];
      }

      final decoded = json.decode(jsonString) as List<dynamic>;
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Error getting cached paths: $e');
      return [];
    }
  }

  /// Check if cache is valid (not expired)
  Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_pathsCacheTimestampKey);
      
      if (timestamp == null) {
        return false;
      }

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(cacheTime);

      return difference < _cacheExpirationDuration;
    } catch (e) {
      debugPrint('Error checking cache validity: $e');
      return false;
    }
  }

  /// Clear paths cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pathsCacheKey);
      await prefs.remove(_pathsCacheTimestampKey);
      debugPrint('Cache cleared');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Add action to pending queue
  Future<void> addPendingAction(Map<String, dynamic> action) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingActions = await getPendingActions();
      existingActions.add({
        ...action,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      await prefs.setString(_pendingActionsKey, json.encode(existingActions));
      debugPrint('Action added to queue: ${action['type']}');
    } catch (e) {
      debugPrint('Error adding pending action: $e');
    }
  }

  /// Get all pending actions
  Future<List<Map<String, dynamic>>> getPendingActions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_pendingActionsKey);
      
      if (jsonString == null) {
        return [];
      }

      final decoded = json.decode(jsonString) as List<dynamic>;
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Error getting pending actions: $e');
      return [];
    }
  }

  /// Clear pending actions
  Future<void> clearPendingActions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingActionsKey);
      debugPrint('Pending actions cleared');
    } catch (e) {
      debugPrint('Error clearing pending actions: $e');
    }
  }

  /// Remove a specific pending action
  Future<void> removePendingAction(int index) async {
    try {
      final actions = await getPendingActions();
      if (index >= 0 && index < actions.length) {
        actions.removeAt(index);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_pendingActionsKey, json.encode(actions));
      }
    } catch (e) {
      debugPrint('Error removing pending action: $e');
    }
  }
}







