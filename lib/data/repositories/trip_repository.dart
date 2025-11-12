// lib/data/repositories/trip_repository.dart
import '../models/trip_model.dart';
import '../services/api_service.dart';

class TripRepository {
  final ApiService _apiService = ApiService();

  Future<List<TripModel>> getTrips({
    String? status,
    String? search,
  }) async {
    try {
      String queryString = '';

      if (status != null && status.isNotEmpty) queryString += '&status=$status';
      if (search != null && search.isNotEmpty) queryString += '&search=$search';

      if (queryString.isNotEmpty) {
        queryString = '?${queryString.substring(1)}';
      }

      final response = await _apiService.get(
        '/trips$queryString',
        requiresAuth: true,
      );

      final dynamic data = response is Map ? response['data'] ?? response : response;

      final List<dynamic> tripsList =
          data is List
              ? data
              : data is Map && data['data'] is List
                  ? data['data']
                  : <dynamic>[];

      return tripsList
          .whereType<Map>()
          .map(
            (tripJson) => TripModel.fromJson(
              tripJson.cast<String, dynamic>(),
            ),
          )
          .toList();
    } catch (e, stackTrace) {
      print('❌ TripRepository.getTrips error: $e');
      print(
        '   StackTrace: ${stackTrace.toString().substring(0, stackTrace.toString().length > 400 ? 400 : stackTrace.toString().length)}...',
      );
      rethrow;
    }
  }
}

