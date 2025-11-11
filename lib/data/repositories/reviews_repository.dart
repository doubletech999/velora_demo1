// lib/data/repositories/reviews_repository.dart
import '../models/review_model.dart';
import '../services/api_service.dart';

class ReviewsRepository {
  final ApiService _apiService = ApiService();
  
  /// الحصول على جميع التقييمات
  Future<List<ReviewModel>> getReviews({
    String? siteId,
    int? rating,
    int? minRating,
    bool? myReviews,
    int? page,
  }) async {
    try {
      final response = await _apiService.getReviews(
        siteId: siteId != null ? int.tryParse(siteId) : null,
        rating: rating,
        minRating: minRating,
        myReviews: myReviews,
        page: page,
      );

      if (response['status'] == 'success' && response['data'] != null) {
        final List<dynamic> reviewsData = response['data'] is List
            ? response['data']
            : response['data']['reviews'] ?? [];
        
        return reviewsData
            .map((json) => ReviewModel.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('فشل تحميل التقييمات: $e');
    }
  }
  
  /// الحصول على تقييم محدد
  Future<ReviewModel?> getReviewById(String reviewId) async {
    try {
      final response = await _apiService.getReview(int.parse(reviewId));
      
      if (response['status'] == 'success' && response['data'] != null) {
        return ReviewModel.fromJson(response['data']);
      }
      
      return null;
    } catch (e) {
      throw Exception('فشل تحميل التقييم: $e');
    }
  }
  
  /// إضافة تقييم جديد
  Future<ReviewModel> createReview({
    required String? siteId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await _apiService.createReview(
        siteId: siteId != null ? int.tryParse(siteId) : null,
        rating: rating,
        comment: comment,
      );

      if (response['status'] == 'success' && response['data'] != null) {
        return ReviewModel.fromJson(response['data']);
      }
      
      throw Exception(response['message'] ?? 'فشل إضافة التقييم');
    } catch (e) {
      throw Exception('فشل إضافة التقييم: $e');
    }
  }
  
  /// تحديث تقييم
  Future<ReviewModel> updateReview({
    required String reviewId,
    int? rating,
    String? comment,
  }) async {
    try {
      final response = await _apiService.updateReview(
        reviewId: int.parse(reviewId),
        rating: rating,
        comment: comment,
      );

      if (response['status'] == 'success' && response['data'] != null) {
        return ReviewModel.fromJson(response['data']);
      }
      
      throw Exception(response['message'] ?? 'فشل تحديث التقييم');
    } catch (e) {
      throw Exception('فشل تحديث التقييم: $e');
    }
  }
  
  /// حذف تقييم
  Future<bool> deleteReview(String reviewId) async {
    try {
      final response = await _apiService.deleteReview(int.parse(reviewId));
      
      return response['status'] == 'success';
    } catch (e) {
      throw Exception('فشل حذف التقييم: $e');
    }
  }
  
  /// الحصول على إحصائيات التقييمات
  Future<Map<String, dynamic>> getReviewStats({
    String? siteId,
  }) async {
    try {
      final response = await _apiService.getReviewStats(
        siteId: siteId != null ? int.tryParse(siteId) : null,
      );

      if (response['status'] == 'success' && response['data'] != null) {
        return response['data'];
      }
      
      return {};
    } catch (e) {
      throw Exception('فشل تحميل إحصائيات التقييمات: $e');
    }
  }
  
  /// التحقق من إمكانية التقييم
  Future<bool> canReview({String? siteId}) async {
    try {
      final response = await _apiService.canReview(
        siteId: siteId != null ? int.tryParse(siteId) : null,
      );

      if (response['status'] == 'success') {
        return response['data']?['can_review'] ?? false;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
}








