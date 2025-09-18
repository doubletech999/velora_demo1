// lib/presentation/providers/trip_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../data/models/trip_model.dart';

class TripProvider extends ChangeNotifier {
  List<Trip> _trips = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Trip> get trips => _trips;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Filtered trips
  List<Trip> get upcomingTrips => 
      _trips.where((trip) => trip.status == TripStatus.planned).toList()
        ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  
  List<Trip> get completedTrips => 
      _trips.where((trip) => trip.status == TripStatus.completed).toList()
        ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
  
  List<Trip> get ongoingTrips => 
      _trips.where((trip) => trip.status == TripStatus.ongoing).toList();
  
  List<Trip> get todaysTrips => 
      _trips.where((trip) => trip.isToday && trip.status != TripStatus.cancelled).toList();

  // Storage key
  static const String _tripsKey = 'user_trips';

  TripProvider() {
    _loadTrips();
  }

  // Load trips from local storage
  Future<void> _loadTrips() async {
    _setLoading(true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final tripsJson = prefs.getString(_tripsKey);
      
      if (tripsJson != null) {
        final tripsList = json.decode(tripsJson) as List;
        _trips = tripsList.map((tripJson) => Trip.fromJson(tripJson)).toList();
      }
      
      _error = null;
    } catch (e) {
      _error = 'خطأ في تحميل الرحلات: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Save trips to local storage
  Future<void> _saveTrips() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tripsJson = json.encode(_trips.map((trip) => trip.toJson()).toList());
      await prefs.setString(_tripsKey, tripsJson);
    } catch (e) {
      _error = 'خطأ في حفظ الرحلات: $e';
      notifyListeners();
    }
  }

  // Add new trip
  Future<bool> addTrip(Trip trip) async {
    _setLoading(true);
    
    try {
      // Generate unique ID if not provided
      final tripWithId = trip.id.isEmpty 
          ? trip.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString())
          : trip;
          
      _trips.add(tripWithId);
      await _saveTrips();
      
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'خطأ في إضافة الرحلة: $e';
      _setLoading(false);
      return false;
    }
  }

  // Update trip
  Future<bool> updateTrip(Trip updatedTrip) async {
    _setLoading(true);
    
    try {
      final index = _trips.indexWhere((trip) => trip.id == updatedTrip.id);
      if (index != -1) {
        _trips[index] = updatedTrip;
        await _saveTrips();
        _error = null;
        _setLoading(false);
        return true;
      } else {
        _error = 'الرحلة غير موجودة';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'خطأ في تحديث الرحلة: $e';
      _setLoading(false);
      return false;
    }
  }

  // Delete trip
  Future<bool> deleteTrip(String tripId) async {
    _setLoading(true);
    
    try {
      _trips.removeWhere((trip) => trip.id == tripId);
      await _saveTrips();
      
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'خطأ في حذف الرحلة: $e';
      _setLoading(false);
      return false;
    }
  }

  // Mark trip as completed
  Future<bool> completeTrip(String tripId) async {
    _setLoading(true);
    
    try {
      final tripIndex = _trips.indexWhere((trip) => trip.id == tripId);
      if (tripIndex != -1) {
        _trips[tripIndex] = _trips[tripIndex].copyWith(
          status: TripStatus.completed,
          completedAt: DateTime.now(),
        );
        await _saveTrips();
        
        _error = null;
        _setLoading(false);
        return true;
      }
      return false;
    } catch (e) {
      _error = 'خطأ في إتمام الرحلة: $e';
      _setLoading(false);
      return false;
    }
  }

  // Start trip (mark as ongoing)
  Future<bool> startTrip(String tripId) async {
    _setLoading(true);
    
    try {
      final tripIndex = _trips.indexWhere((trip) => trip.id == tripId);
      if (tripIndex != -1) {
        _trips[tripIndex] = _trips[tripIndex].copyWith(
          status: TripStatus.ongoing,
        );
        await _saveTrips();
        
        _error = null;
        _setLoading(false);
        return true;
      }
      return false;
    } catch (e) {
      _error = 'خطأ في بدء الرحلة: $e';
      _setLoading(false);
      return false;
    }
  }

  // Cancel trip
  Future<bool> cancelTrip(String tripId) async {
    _setLoading(true);
    
    try {
      final tripIndex = _trips.indexWhere((trip) => trip.id == tripId);
      if (tripIndex != -1) {
        _trips[tripIndex] = _trips[tripIndex].copyWith(
          status: TripStatus.cancelled,
        );
        await _saveTrips();
        
        _error = null;
        _setLoading(false);
        return true;
      }
      return false;
    } catch (e) {
      _error = 'خطأ في إلغاء الرحلة: $e';
      _setLoading(false);
      return false;
    }
  }

  // Get trip by ID
  Trip? getTripById(String tripId) {
    try {
      return _trips.firstWhere((trip) => trip.id == tripId);
    } catch (e) {
      return null;
    }
  }

  // Get trips for a specific path
  List<Trip> getTripsForPath(String pathId) {
    return _trips.where((trip) => trip.pathId == pathId).toList()
      ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
  }

  // Get trip statistics
  Map<String, dynamic> getTripStatistics() {
    final completed = completedTrips.length;
    final upcoming = upcomingTrips.length;
    final ongoing = ongoingTrips.length;
    final cancelled = _trips.where((trip) => trip.status == TripStatus.cancelled).length;
    
    final totalDistance = completedTrips.fold<double>(
      0, 
      (sum, trip) => sum + trip.pathLength
    );
    
    final activityBreakdown = <TripActivityType, int>{};
    for (final trip in completedTrips) {
      activityBreakdown[trip.activityType] = 
          (activityBreakdown[trip.activityType] ?? 0) + 1;
    }
    
    return {
      'completed': completed,
      'upcoming': upcoming,
      'ongoing': ongoing,
      'cancelled': cancelled,
      'totalDistance': totalDistance,
      'activityBreakdown': activityBreakdown,
      'totalTrips': _trips.length,
    };
  }

  // Refresh trips
  Future<void> refreshTrips() async {
    await _loadTrips();
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear all trips (for testing or reset)
  Future<void> clearAllTrips() async {
    _trips.clear();
    await _saveTrips();
    notifyListeners();
  }
}