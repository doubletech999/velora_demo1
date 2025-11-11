// lib/data/models/review_model.dart
class ReviewModel {
  final String id;
  final String userId;
  final String? userName;
  final String? userImageUrl;
  final String? siteId;
  final String? guideId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ReviewModel({
    required this.id,
    required this.userId,
    this.userName,
    this.userImageUrl,
    this.siteId,
    this.guideId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // استخراج user_id
    String userId = json['user_id']?.toString() ?? '';
    
    // استخراج user_name من مصادر مختلفة
    String? userName;
    if (json['user_name'] != null) {
      userName = json['user_name'].toString();
    } else if (json['user'] != null && json['user'] is Map) {
      final userData = json['user'] as Map<String, dynamic>;
      userName = userData['name']?.toString() ?? 
                 userData['name_ar']?.toString() ??
                 userData['user_name']?.toString();
      // إذا لم يكن user_id موجود، جربه من user object
      if (userId.isEmpty) {
        userId = userData['id']?.toString() ?? '';
      }
    }
    
    // استخراج user_image_url من مصادر مختلفة
    String? userImageUrl;
    if (json['user_image_url'] != null) {
      userImageUrl = json['user_image_url'].toString();
    } else if (json['user'] != null && json['user'] is Map) {
      final userData = json['user'] as Map<String, dynamic>;
      userImageUrl = userData['image_url']?.toString() ??
                     userData['profile_image_url']?.toString() ??
                     userData['avatar']?.toString();
    }
    
    // استخراج rating
    int rating;
    if (json['rating'] is int) {
      rating = json['rating'] as int;
    } else if (json['rating'] is num) {
      rating = (json['rating'] as num).toInt();
    } else if (json['rating'] is String) {
      rating = int.tryParse(json['rating']) ?? 0;
    } else {
      rating = 0;
    }
    
    // استخراج site_id و guide_id
    String? siteId = json['site_id']?.toString();
    if (siteId == null || siteId.isEmpty) {
      siteId = json['site']?['id']?.toString();
    }
    
    String? guideId = json['guide_id']?.toString();
    if (guideId == null || guideId.isEmpty) {
      guideId = json['guide']?['id']?.toString();
    }
    
    return ReviewModel(
      id: json['id']?.toString() ?? '',
      userId: userId,
      userName: userName,
      userImageUrl: userImageUrl,
      siteId: siteId,
      guideId: guideId,
      rating: rating,
      comment: json['comment']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_image_url': userImageUrl,
      'site_id': siteId,
      'guide_id': guideId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}








