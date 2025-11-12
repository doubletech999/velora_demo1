// lib/data/models/trip_model.dart
import 'package:collection/collection.dart';

import 'path_model.dart';

class TripModel {
  final String id;
  final String name;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? price;
  final String? guideName;
  final double? distance;
  final String? durationText;
  final List<String> activities;
  final List<TripSiteModel> sites;
  final String? customRoute;
  final String? status;
  final String? travelerName;
  final String? travelerEmail;

  TripModel({
    required this.id,
    required this.name,
    this.description,
    this.startDate,
    this.endDate,
    this.price,
    this.guideName,
    this.distance,
    this.durationText,
    required this.activities,
    required this.sites,
    this.customRoute,
    this.status,
    this.travelerName,
    this.travelerEmail,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    List<String> parseActivities(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value
            .whereType<String>()
            .map((activity) => activity.toLowerCase())
            .toList();
      }
      if (value is String) {
        return value
            .split(',')
            .map((activity) => activity.trim().toLowerCase())
            .where((activity) => activity.isNotEmpty)
            .toList();
      }
      return [];
    }

    List<TripSiteModel> parseSites(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value
            .whereType<Map>()
            .map(
              (siteJson) => TripSiteModel.fromJson(
                siteJson.cast<String, dynamic>(),
              ),
            )
            .toList();
      }

      // دعم قائمة من الـ IDs فقط
      if (value is String || value is num) {
        return [TripSiteModel(id: value.toString())];
      }

      return [];
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return TripModel(
      id: json['id']?.toString() ?? '',
      name: json['trip_name']?.toString() ?? json['name']?.toString() ?? 'Trip',
      description: json['description']?.toString(),
      startDate: parseDate(json['start_date']),
      endDate: parseDate(json['end_date']),
      price: parseDouble(json['price'] ?? json['total_price']),
      guideName: json['guide_name']?.toString() ??
          (json['guide'] is Map ? json['guide']['name']?.toString() : null),
      distance: parseDouble(json['distance']),
      durationText: json['duration']?.toString(),
      activities: parseActivities(json['activities']),
      sites: parseSites(json['sites']),
      customRoute: json['custom_sites']?.toString(),
      status: json['status']?.toString(),
      travelerName: (json['user'] is Map)
          ? json['user']['name']?.toString()
          : json['traveler_name']?.toString(),
      travelerEmail: (json['user'] is Map)
          ? json['user']['email']?.toString()
          : json['traveler_email']?.toString(),
    );
  }

  TripSiteModel? get primarySite => sites.firstWhereOrNull(
        (site) => site.images.isNotEmpty,
      ) ??
      sites.firstOrNull;

  String? get primarySiteId {
    final site = primarySite;
    if (site == null) return null;
    return site.id.isNotEmpty ? site.id : null;
  }

  String get displayImage =>
      primarySite?.primaryImage ?? 'assets/images/logo.png';

  bool get hasAdventureActivities =>
      activities.contains('camping') || activities.contains('hiking');

  int get siteCount => sites.length;

  String get dateRange {
    if (startDate == null && endDate == null) return '';
    if (startDate != null && endDate != null) {
      final start = '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}';
      final end = '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}';
      return '$start → $end';
    }
    final date = startDate ?? endDate;
    return '${date!.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  int get durationInDays {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays.abs() + 1;
  }

  static TripModel fromPath(PathModel path) {
    return TripModel(
      id: path.id,
      name: path.nameAr.isNotEmpty ? path.nameAr : path.name,
      description:
          path.descriptionAr.isNotEmpty ? path.descriptionAr : path.description,
      startDate: null,
      endDate: null,
      price: path.price > 0 ? path.price : null,
      guideName:
          path.guide.nameAr?.isNotEmpty == true ? path.guide.nameAr : path.guide.name,
      distance: path.length,
      durationText: _formatDuration(path.estimatedDuration),
      activities: path.activities.map((activity) => activity.name).toList(),
      sites: [TripSiteModel.fromPath(path)],
      customRoute: null,
      status: null,
      travelerName: null,
      travelerEmail: null,
    );
  }

  static String? _formatDuration(Duration duration) {
    if (duration == Duration.zero) return null;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0 && minutes > 0) {
      return '$hours ساعة ${minutes} دقيقة';
    }
    if (hours > 0) {
      return '$hours ساعة';
    }
    return '$minutes دقيقة';
  }
}

class TripSiteModel {
  final String id;
  final String? name;
  final String? nameAr;
  final String? type;
  final String? description;
  final String? descriptionAr;
  final String? location;
  final String? locationAr;
  final List<String> images;

  TripSiteModel({
    required this.id,
    this.name,
    this.nameAr,
    this.type,
    this.description,
    this.descriptionAr,
    this.location,
    this.locationAr,
    List<String>? images,
  }) : images = images ?? const [];

  factory TripSiteModel.fromJson(Map<String, dynamic> json) {
    List<String> parseImages(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value
            .whereType<String>()
            .where((url) => url.isNotEmpty)
            .toList();
      }
      if (value is String && value.isNotEmpty) {
        return [value];
      }
      return [];
    }

    return TripSiteModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString(),
      nameAr: json['name_ar']?.toString(),
      type: json['type']?.toString(),
      description: json['description']?.toString(),
      descriptionAr: json['description_ar']?.toString(),
      location: json['location']?.toString(),
      locationAr: json['location_ar']?.toString(),
      images: parseImages(json['images'] ?? json['image'] ?? json['image_url']),
    );
  }

  String get displayName => nameAr?.isNotEmpty == true ? nameAr! : (name ?? '');

  String get primaryImage =>
      images.isNotEmpty ? images.first : 'assets/images/logo.png';

  factory TripSiteModel.fromPath(PathModel path) {
    return TripSiteModel(
      id: path.id,
      name: path.name,
      nameAr: path.nameAr,
      type: path.type,
      description: path.description,
      descriptionAr: path.descriptionAr,
      location: path.location,
      locationAr: path.locationAr,
      images: path.images,
    );
  }
}

