// lib/data/models/guide_model.dart
class GuideModel {
  final String id;
  final String? name;
  final String? nameAr;
  final String? bio;
  final String? bioAr;
  final String? phone;
  final String? email;
  final String? languages;
  final double? routePrice;
  final String? imageUrl;
  final double? rating;
  final int? reviewCount;

  GuideModel({
    required this.id,
    this.name,
    this.nameAr,
    this.bio,
    this.bioAr,
    this.phone,
    this.email,
    this.languages,
    this.routePrice,
    this.imageUrl,
    this.rating,
    this.reviewCount,
  });

  factory GuideModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle nested user data if guide includes user info
      Map<String, dynamic>? userData;
      if (json['user'] != null && json['user'] is Map) {
        userData = json['user'] as Map<String, dynamic>;
      }

      // Parse routePrice - دعم String و num
      double? routePrice;
      if (json['route_price'] != null) {
        if (json['route_price'] is String) {
          routePrice = double.tryParse(json['route_price']);
        } else if (json['route_price'] is num) {
          routePrice = (json['route_price'] as num).toDouble();
        }
      } else if (json['price'] != null) {
        if (json['price'] is String) {
          routePrice = double.tryParse(json['price']);
        } else if (json['price'] is num) {
          routePrice = (json['price'] as num).toDouble();
        }
      }

      // Parse rating - دعم String و num
      double? rating;
      if (json['rating'] != null) {
        if (json['rating'] is String) {
          rating = double.tryParse(json['rating']);
        } else if (json['rating'] is num) {
          rating = (json['rating'] as num).toDouble();
        }
      }

      // Parse reviewCount - دعم String و num
      int? reviewCount;
      if (json['review_count'] != null) {
        if (json['review_count'] is String) {
          reviewCount = int.tryParse(json['review_count']);
        } else if (json['review_count'] is num) {
          reviewCount = (json['review_count'] as num).toInt();
        }
      } else if (json['reviews_count'] != null) {
        if (json['reviews_count'] is String) {
          reviewCount = int.tryParse(json['reviews_count']);
        } else if (json['reviews_count'] is num) {
          reviewCount = (json['reviews_count'] as num).toInt();
        }
      }

      return GuideModel(
        id: json['id']?.toString() ?? '0',
        name: userData?['name'] ?? json['name'] ?? json['name_en']?.toString(),
        nameAr: json['name_ar']?.toString() ?? userData?['name_ar']?.toString(),
        bio: json['bio'] ?? json['bio_en']?.toString(),
        bioAr: json['bio_ar']?.toString(),
        phone: json['phone']?.toString() ?? userData?['phone']?.toString(),
        email: userData?['email']?.toString(),
        languages: json['languages']?.toString(),
        routePrice: routePrice,
        imageUrl: json['image_url']?.toString() ?? 
                  json['image']?.toString() ?? 
                  userData?['image_url']?.toString(),
        rating: rating,
        reviewCount: reviewCount,
      );
    } catch (e, stackTrace) {
      print('❌ خطأ في GuideModel.fromJson(): $e');
      print('   StackTrace: ${stackTrace.toString().substring(0, stackTrace.toString().length > 300 ? 300 : stackTrace.toString().length)}...');
      print('   JSON: ${json.toString().substring(0, json.toString().length > 200 ? 200 : json.toString().length)}...');
      
      // Fallback: إرجاع guide افتراضي بدلاً من إيقاف التحويل
      return GuideModel(
        id: json['id']?.toString() ?? '0',
        name: json['name']?.toString() ?? 'Guide',
        nameAr: json['name_ar']?.toString() ?? 'مرشد',
        bio: null,
        bioAr: null,
        phone: null,
        email: null,
        languages: null,
        routePrice: null,
        imageUrl: null,
        rating: null,
        reviewCount: null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'name_en': name,
      'bio': bio,
      'bio_ar': bioAr,
      'bio_en': bio,
      'phone': phone,
      'email': email,
      'languages': languages,
      'route_price': routePrice,
      'price': routePrice,
      'image_url': imageUrl,
      'rating': rating,
      'review_count': reviewCount,
    };
  }

  GuideModel copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? bio,
    String? bioAr,
    String? phone,
    String? email,
    String? languages,
    double? routePrice,
    String? imageUrl,
    double? rating,
    int? reviewCount,
  }) {
    return GuideModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      bio: bio ?? this.bio,
      bioAr: bioAr ?? this.bioAr,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      languages: languages ?? this.languages,
      routePrice: routePrice ?? this.routePrice,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}

