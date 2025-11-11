// lib/presentation/providers/reviews_provider.dart
import 'package:flutter/foundation.dart';
import '../../../data/models/review_model.dart';
import '../../../data/services/api_service.dart';

class ReviewsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService.instance;

  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  String? _error;
  final Map<String, ReviewStats> _stats = {};

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ReviewStats? getStats(String? siteId) => _stats[siteId ?? 'all'];

  Future<void> fetchReviews({
    String? siteId,
    int? rating,
    int? minRating,
    int? page,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔄 ReviewsProvider: بدء جلب التقييمات...');
      print('  siteId: $siteId');

      final response = await _apiService.getReviews(
        siteId: siteId != null ? int.tryParse(siteId) : null,
        rating: rating,
        minRating: minRating,
        page: page,
      );

      print('✅ ReviewsProvider: استجابة API: $response');

      // دعم أشكال مختلفة من الاستجابة
      List<dynamic> reviewsData = [];

      // محاولة 1: Laravel Pagination Format (الأكثر شيوعاً)
      if (response is Map) {
        // إذا كانت الاستجابة تحتوي على data
        if (response['data'] != null) {
          if (response['data'] is List) {
            reviewsData = response['data'] as List;
            print(
              '✅ ReviewsProvider: تم العثور على reviews في data (List): ${reviewsData.length}',
            );
          } else if (response['data'] is Map) {
            // البحث عن reviews في data
            final data = response['data'] as Map<String, dynamic>;
            if (data['reviews'] != null && data['reviews'] is List) {
              reviewsData = data['reviews'] as List;
              print(
                '✅ ReviewsProvider: تم العثور على reviews في data.reviews: ${reviewsData.length}',
              );
            } else if (data.containsKey('id') || data.containsKey('rating')) {
              // إذا كان data هو review واحد
              reviewsData = [data];
              print('✅ ReviewsProvider: تم العثور على review واحد في data');
            }
          }
        }
        // محاولة 2: إذا كانت reviews مباشرة في response
        else if (response['reviews'] != null && response['reviews'] is List) {
          reviewsData = response['reviews'] as List;
          print(
            '✅ ReviewsProvider: تم العثور على reviews مباشرة: ${reviewsData.length}',
          );
        }
        // محاولة 3: إذا كانت الاستجابة قائمة مباشرة
        else if (response is List) {
          reviewsData = response as List;
          print(
            '✅ ReviewsProvider: الاستجابة قائمة مباشرة: ${reviewsData.length}',
          );
        }
      }
      // محاولة 4: إذا كانت الاستجابة قائمة مباشرة (ليس Map)
      else if (response is List) {
        reviewsData = response;
        print(
          '✅ ReviewsProvider: الاستجابة قائمة مباشرة: ${reviewsData.length}',
        );
      }

      print(
        '✅ ReviewsProvider: إجمالي التقييمات المستخرجة: ${reviewsData.length}',
      );

      if (reviewsData.isEmpty) {
        print('⚠️ ReviewsProvider: لا توجد تقييمات في الاستجابة');
        _reviews = [];
        _error = null; // ليس خطأ، فقط لا توجد تقييمات
      } else {
        // تحويل البيانات إلى ReviewModel
        print(
          '🔄 ReviewsProvider: بدء تحويل ${reviewsData.length} تقييم إلى ReviewModel...',
        );
        _reviews = [];

        for (int i = 0; i < reviewsData.length; i++) {
          try {
            final json = reviewsData[i];
            if (json is Map<String, dynamic>) {
              final review = ReviewModel.fromJson(json);
              _reviews.add(review);
              print(
                '✅ ReviewsProvider: تم تحويل التقييم ${i + 1}/${reviewsData.length}: ${review.id}',
              );
            } else {
              print(
                '⚠️ ReviewsProvider: التقييم ${i + 1} ليس Map: ${json.runtimeType}',
              );
            }
          } catch (e, stackTrace) {
            final json = reviewsData[i];
            print(
              '❌ ReviewsProvider: خطأ في تحويل التقييم ${i + 1}/${reviewsData.length}: $e',
            );
            print(
              '   StackTrace: ${stackTrace.toString().substring(0, stackTrace.toString().length > 300 ? 300 : stackTrace.toString().length)}...',
            );
            print('   JSON: $json');
            // تجاهل التقييم الذي فشل تحويله
          }
        }

        print(
          '✅ ReviewsProvider: تم تحويل ${_reviews.length}/${reviewsData.length} تقييم بنجاح',
        );
        _error = null;
      }
    } catch (e, stackTrace) {
      print('❌ ReviewsProvider: خطأ في جلب التقييمات: $e');
      print(
        '   StackTrace: ${stackTrace.toString().substring(0, stackTrace.toString().length > 500 ? 500 : stackTrace.toString().length)}...',
      );
      _error = 'Error loading reviews: $e';
      _reviews = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addReview({
    required String? siteId,
    required int rating,
    String? comment,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.createReview(
        siteId: siteId != null ? int.tryParse(siteId) : null,
        rating: rating,
        comment: comment,
      );

      if (response['status'] == 'success') {
        // Refresh reviews after adding
        await fetchReviews(siteId: siteId);
        // Refresh stats
        await fetchReviewStats(siteId: siteId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to add review';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // معالجة الأخطاء المختلفة بشكل أفضل
      String errorMessage = 'فشل إضافة التقييم';

      final errorStr = e.toString();

      // معالجة خطأ 409 Conflict (المستخدم قد أضاف تقييم مسبقاً)
      if (errorStr.contains('Conflict') ||
          errorStr.contains('409') ||
          errorStr.contains('تعارض') ||
          errorStr.contains('لقد قيمت')) {
        errorMessage =
            'لقد قيمت هذا الموقع مسبقاً. يمكنك تحديث تقييمك من صفحة التقييمات';
      }
      // معالجة خطأ 401 Unauthorized
      else if (errorStr.contains('401') ||
          errorStr.contains('Unauthorized') ||
          errorStr.contains('غير مصرح')) {
        errorMessage = 'يجب تسجيل الدخول لإضافة تقييم';
      }
      // معالجة خطأ 422 Validation
      else if (errorStr.contains('422') ||
          errorStr.contains('Validation') ||
          errorStr.contains('خطأ في التحقق')) {
        errorMessage =
            'البيانات المدخلة غير صحيحة. يرجى التحقق من التقييم والتعليق';
      }
      // معالجة خطأ 404 Not Found
      else if (errorStr.contains('404') ||
          errorStr.contains('Not Found') ||
          errorStr.contains('غير موجود')) {
        errorMessage = 'الموقع غير موجود';
      }
      // استخراج رسالة الخطأ من Exception إذا كانت موجودة
      else if (errorStr.contains('Exception:')) {
        final parts = errorStr.split('Exception:');
        if (parts.length > 1) {
          errorMessage = parts[1].trim();
          // إزالة البادئات العربية إذا كانت موجودة
          errorMessage = errorMessage
              .replaceAll('تعارض: ', '')
              .replaceAll('خطأ في الخادم: ', '')
              .replaceAll('خطأ في الشبكة: ', '')
              .replaceAll('غير مصرح: ', '')
              .replaceAll('طلب غير صالح: ', '');
        }
      }
      // رسالة افتراضية
      else {
        errorMessage = 'فشل إضافة التقييم. يرجى المحاولة مرة أخرى';
      }

      print('❌ ReviewsProvider: خطأ في إضافة التقييم: $errorStr');
      print('   رسالة الخطأ للمستخدم: $errorMessage');

      _error = errorMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateReview({
    required String reviewId,
    int? rating,
    String? comment,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.updateReview(
        reviewId: int.parse(reviewId),
        rating: rating,
        comment: comment,
      );

      if (response['status'] == 'success') {
        // Refresh reviews
        final siteId = _reviews.firstWhere((r) => r.id == reviewId).siteId;
        await fetchReviews(siteId: siteId);
        await fetchReviewStats(siteId: siteId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to update review';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error updating review: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.deleteReview(int.parse(reviewId));

      if (response['status'] == 'success') {
        _reviews.removeWhere((review) => review.id == reviewId);
        final siteId = _reviews.isNotEmpty ? _reviews.first.siteId : null;
        if (siteId != null) {
          await fetchReviewStats(siteId: siteId);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to delete review';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error deleting review: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchReviewStats({String? siteId}) async {
    try {
      final response = await _apiService.getReviewStats(
        siteId: siteId != null ? int.tryParse(siteId) : null,
      );

      if (response['status'] == 'success' && response['data'] != null) {
        final data = response['data'];
        _stats[siteId ?? 'all'] = ReviewStats.fromJson(data);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching review stats: $e');
    }
  }

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
      debugPrint('Error checking if can review: $e');
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearReviews() {
    _reviews = [];
    notifyListeners();
  }
}

class ReviewStats {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // rating -> count

  ReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    return ReviewStats(
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      ratingDistribution: Map<int, int>.from(json['rating_distribution'] ?? {}),
    );
  }
}
