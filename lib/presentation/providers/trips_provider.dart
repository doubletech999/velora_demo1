// lib/presentation/providers/trips_provider.dart
import 'package:flutter/material.dart';

import '../../data/models/trip_model.dart';
import '../../data/repositories/trip_repository.dart';
import '../../data/repositories/paths_repository.dart';
import '../../data/models/path_model.dart';

class TripsProvider extends ChangeNotifier {
  final TripRepository _repository = TripRepository();
  final PathsRepository _pathsRepository = PathsRepository();

  List<TripModel> _trips = [];
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;
  final Map<String, PathModel> _fallbackPathMap = {};

  List<TripModel> get trips => _trips;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get initialized => _initialized;
  PathModel? getFallbackPath(String tripId) => _fallbackPathMap[tripId];

  Future<void> initializeIfNeeded() async {
    if (!_initialized && !_isLoading) {
      await loadTrips();
    }
  }

  Future<void> loadTrips({String? status}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _trips = await _repository.getTrips(status: status);
      _fallbackPathMap.clear();
      if (_trips.isEmpty) {
        final loaded = await _loadFallbackTrips();
        if (!loaded) {
          _error = null;
        }
      } else {
        _error = null;
      }
      _initialized = true;
    } catch (e) {
      debugPrint('❌ TripsProvider.loadTrips error: $e');
      _error = e.toString();
      if (_trips.isEmpty) {
        final loaded = await _loadFallbackTrips();
        if (loaded) {
          _error = null;
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<TripModel> get adventureTrips =>
      _trips.where((trip) => trip.hasAdventureActivities).toList();

  List<TripModel> get upcomingTrips {
    final now = DateTime.now();
    return _trips.where((trip) {
      if (trip.startDate == null) return false;
      return trip.startDate!.isAfter(now);
    }).toList();
  }

  Future<bool> _loadFallbackTrips() async {
    final originalUseApi = _pathsRepository.useApi;
    try {
      _pathsRepository.useApi = false;
      final List<PathModel> fallbackPaths =
          await _pathsRepository.getRoutesAndCamping();
      if (fallbackPaths.isNotEmpty) {
        _trips = fallbackPaths.map((path) {
          _fallbackPathMap[path.id] = path;
          return TripModel.fromPath(path);
        }).toList();
        return true;
      }
    } catch (e) {
      debugPrint('❌ TripsProvider fallback failed: $e');
    } finally {
      _pathsRepository.useApi = originalUseApi;
    }
    return false;
  }
}

