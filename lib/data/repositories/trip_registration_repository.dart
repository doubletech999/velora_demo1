// lib/data/repositories/trip_registration_repository.dart
import '../models/trip_registration_model.dart';
import '../services/api_service.dart';

class TripRegistrationRepository {
  final ApiService _apiService = ApiService();
  
  /// الحصول على جميع طلبات التسجيل في الرحلات
  Future<List<TripRegistrationModel>> getTripRegistrations({
    String? pathId,
    String? userId,
    TripStatus? status,
    int? page,
  }) async {
    try {
      // Note: You may need to add this endpoint to ApiService
      // For now, using a generic approach
      final response = await _apiService.get('/trip-registrations', requiresAuth: true);
      
      if (response['status'] == 'success' && response['data'] != null) {
        List<dynamic> registrationsData = response['data'] is List
            ? response['data']
            : response['data']['registrations'] ?? [];
        
        List<TripRegistrationModel> registrations = registrationsData
            .map((json) => TripRegistrationModel.fromJson(json))
            .toList();
        
        // Filter by pathId if provided
        if (pathId != null) {
          registrations = registrations.where((r) => r.pathId == pathId).toList();
        }
        
        // Filter by userId if provided
        if (userId != null) {
          registrations = registrations.where((r) => r.userId == userId).toList();
        }
        
        // Filter by status if provided
        if (status != null) {
          registrations = registrations.where((r) => r.status == status).toList();
        }
        
        return registrations;
      }
      
      return [];
    } catch (e) {
      throw Exception('فشل تحميل طلبات التسجيل: $e');
    }
  }
  
  /// الحصول على طلب تسجيل محدد
  Future<TripRegistrationModel?> getTripRegistrationById(String registrationId) async {
    try {
      final response = await _apiService.get(
        '/trip-registrations/$registrationId',
        requiresAuth: true,
      );
      
      if (response['status'] == 'success' && response['data'] != null) {
        return TripRegistrationModel.fromJson(response['data']);
      }
      
      return null;
    } catch (e) {
      throw Exception('فشل تحميل طلب التسجيل: $e');
    }
  }
  
  /// إنشاء طلب تسجيل جديد
  Future<TripRegistrationModel> createTripRegistration({
    required String pathId,
    required String pathName,
    required String pathLocation,
    required String userId,
    required String organizerName,
    required String organizerPhone,
    required String organizerEmail,
    required int numberOfParticipants,
    required String notes,
    double? pricePerPerson,
    double? totalPrice,
    PaymentMethod? paymentMethod,
  }) async {
    try {
      final response = await _apiService.post(
        '/trip-registrations',
        {
          'path_id': pathId,
          'path_name': pathName,
          'path_location': pathLocation,
          'user_id': userId,
          'organizer_name': organizerName,
          'organizer_phone': organizerPhone,
          'organizer_email': organizerEmail,
          'number_of_participants': numberOfParticipants,
          'notes': notes,
          if (pricePerPerson != null) 'price_per_person': pricePerPerson,
          if (totalPrice != null) 'total_price': totalPrice,
          if (paymentMethod != null) 'payment_method': paymentMethod.name,
        },
        requiresAuth: true,
      );

      if (response['status'] == 'success' && response['data'] != null) {
        return TripRegistrationModel.fromJson(response['data']);
      }
      
      throw Exception(response['message'] ?? 'فشل إنشاء طلب التسجيل');
    } catch (e) {
      throw Exception('فشل إنشاء طلب التسجيل: $e');
    }
  }
  
  /// تحديث طلب تسجيل
  Future<TripRegistrationModel> updateTripRegistration({
    required String registrationId,
    TripStatus? status,
    String? notes,
    PaymentMethod? paymentMethod,
  }) async {
    try {
      Map<String, dynamic> body = {};
      
      if (status != null) body['status'] = status.name;
      if (notes != null) body['notes'] = notes;
      if (paymentMethod != null) body['payment_method'] = paymentMethod.name;
      
      final response = await _apiService.put(
        '/trip-registrations/$registrationId',
        body,
        requiresAuth: true,
      );

      if (response['status'] == 'success' && response['data'] != null) {
        return TripRegistrationModel.fromJson(response['data']);
      }
      
      throw Exception(response['message'] ?? 'فشل تحديث طلب التسجيل');
    } catch (e) {
      throw Exception('فشل تحديث طلب التسجيل: $e');
    }
  }
  
  /// حذف طلب تسجيل
  Future<bool> deleteTripRegistration(String registrationId) async {
    try {
      final response = await _apiService.delete(
        '/trip-registrations/$registrationId',
        requiresAuth: true,
      );
      
      return response['status'] == 'success';
    } catch (e) {
      throw Exception('فشل حذف طلب التسجيل: $e');
    }
  }
}








