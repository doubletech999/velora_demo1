// lib/presentation/providers/trip_registration_provider.dart - النسخة المحدثة
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../data/models/trip_registration_model.dart';
import '../../data/services/api_service.dart';
import '../../data/models/path_model.dart';
import '../../data/services/auth_service.dart';

class TripRegistrationProvider extends ChangeNotifier {
  List<TripRegistrationModel> _trips = [];
  bool _isLoading = false;
  String? _error;
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService.instance;

  // Getters
  List<TripRegistrationModel> get trips => _trips;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get trips by status
  List<TripRegistrationModel> get pendingTrips => 
      _trips.where((trip) => trip.status == TripStatus.pending).toList();
  
  List<TripRegistrationModel> get approvedTrips => 
      _trips.where((trip) => trip.status == TripStatus.approved).toList();
      
  List<TripRegistrationModel> get rejectedTrips => 
      _trips.where((trip) => trip.status == TripStatus.rejected).toList();

  // SharedPreferences key
  static const String _tripsKey = 'registered_trips';

  // Initialize and load trips from storage
  Future<void> loadTrips() async {
    _setLoading(true);
    _setError(null);

    try {
      final prefs = await SharedPreferences.getInstance();
      final tripsJson = prefs.getString(_tripsKey);
      
      if (tripsJson != null) {
        final List<dynamic> decoded = json.decode(tripsJson);
        _trips = decoded.map((trip) => TripRegistrationModel.fromJson(trip)).toList();
        
        // Sort trips by date (newest first)
        _trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } catch (e) {
      _setError('خطأ في تحميل طلبات التسجيل: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Register a new trip
  Future<bool> registerTrip(TripRegistrationModel trip, {PathModel? path}) async {
    _setLoading(true);
    _setError(null);

    try {
      // إرسال البيانات إلى Laravel API
      try {
        // الحصول على guide_id من path
        int? guideId;
        if (path != null && path.guideId != null) {
          guideId = int.tryParse(path.guideId!);
        }
        
        // إذا لم يكن هناك guideId، استخدم 1 كافتراضي (يجب أن يكون موجود في Laravel)
        guideId ??= 1;
        
        // استخدام تاريخ اليوم كافتراضي إذا لم يكن محدد
        final bookingDate = DateTime.now();
        final startTime = DateTime.now().add(const Duration(hours: 9)); // 9 صباحاً
        final durationHours = path?.estimatedDuration.inHours ?? 4;
        final endTime = startTime.add(Duration(hours: durationHours)); // المدة من path
        
        // التحقق من وجود token
        final hasToken = await _authService.hasToken();
        print('🔐 حالة المصادقة: ${hasToken ? "مسجل دخول" : "ضيف"}');
        
        if (!hasToken) {
          print('⚠️ المستخدم غير مسجل دخول - Laravel سيحتاج إلى user_id');
          print('💡 نصيحة: تأكد من أن Laravel Controller يحصل على user_id من request');
        }
        
        print('📤 إرسال بيانات الحجز إلى Laravel...');
        print('  - guide_id: $guideId');
        print('  - booking_date: ${bookingDate.toIso8601String().split('T')[0]}');
        print('  - start_time: ${startTime.toIso8601String().split('T')[1].split('.')[0]}');
        print('  - end_time: ${endTime.toIso8601String().split('T')[1].split('.')[0]}');
        print('  - total_price: ${trip.totalPrice ?? 0.0}');
        print('  - notes: ${trip.notes}');
        print('  - user_id: سيتم الحصول عليه من token في Laravel');
        
        // إرسال إلى Laravel
        final bookingResponse = await _apiService.createBooking(
          guideId: guideId,
          bookingDate: bookingDate.toIso8601String().split('T')[0], // YYYY-MM-DD
          startTime: startTime.toIso8601String().split('T')[1].split('.')[0], // HH:MM:SS
          endTime: endTime.toIso8601String().split('T')[1].split('.')[0], // HH:MM:SS
          totalPrice: trip.totalPrice,
          notes: trip.notes.isNotEmpty ? trip.notes : null,
          pathId: trip.pathId, // إضافة path_id
          numberOfParticipants: trip.numberOfParticipants, // عدد المشاركين
          paymentMethod: trip.paymentMethod?.name, // طريقة الدفع (cash أو visa)
        );
        
        print('✅ تم إرسال الحجز بنجاح إلى Laravel: $bookingResponse');
        
        // إذا كان Laravel يعيد booking_id، احفظه
        if (bookingResponse is Map && bookingResponse['data'] != null) {
          final bookingData = bookingResponse['data'];
          if (bookingData['id'] != null) {
            print('✅ تم إنشاء الحجز في Laravel برقم: ${bookingData['id']}');
          }
        }
      } catch (apiError) {
        print('⚠️ فشل إرسال الحجز إلى Laravel: $apiError');
        
        // إذا كان الخطأ 401 (Unauthenticated)، هذا يعني أن المستخدم غير مسجل دخول
        if (apiError.toString().contains('401') || apiError.toString().contains('Unauthenticated')) {
          print('💡 المستخدم غير مسجل دخول - Laravel يحتاج إلى user_id');
          print('💡 الحل: إما تسجيل الدخول أولاً، أو تعديل Laravel Controller لقبول الحجوزات بدون authentication');
        }
        
        // نستمر في الحفظ المحلي حتى لو فشل API
        // يمكنك إزالة هذا السطر إذا أردت أن يفشل التسجيل تماماً عند فشل API
      }
      
      // Add the new trip locally
      _trips.insert(0, trip);
      
      // Save to storage
      await _saveTrips();
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('خطأ في تسجيل الطلب: ${e.toString()}');
      print('❌ خطأ في تسجيل الطلب: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update trip status
  Future<bool> updateTripStatus(String tripId, TripStatus newStatus) async {
    _setLoading(true);
    _setError(null);

    try {
      final tripIndex = _trips.indexWhere((trip) => trip.id == tripId);
      if (tripIndex != -1) {
        _trips[tripIndex] = _trips[tripIndex].copyWith(status: newStatus);
        await _saveTrips();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('خطأ في تحديث حالة الطلب: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a trip
  Future<bool> deleteTrip(String tripId) async {
    _setLoading(true);
    _setError(null);

    try {
      _trips.removeWhere((trip) => trip.id == tripId);
      await _saveTrips();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('خطأ في حذف الطلب: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get trip by ID
  TripRegistrationModel? getTripById(String tripId) {
    try {
      return _trips.firstWhere((trip) => trip.id == tripId);
    } catch (e) {
      return null;
    }
  }

  // Get trips by path ID
  List<TripRegistrationModel> getTripsByPath(String pathId) {
    return _trips.where((trip) => trip.pathId == pathId).toList();
  }

  // Get statistics
  Map<String, int> getTripStatistics() {
    return {
      'total': _trips.length,
      'pending': pendingTrips.length,
      'approved': approvedTrips.length,
      'rejected': rejectedTrips.length,
    };
  }

  // Private methods
  Future<void> _saveTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final tripsJson = json.encode(_trips.map((trip) => trip.toJson()).toList());
    await prefs.setString(_tripsKey, tripsJson);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    if (error != null) {
      notifyListeners();
    }
  }
}