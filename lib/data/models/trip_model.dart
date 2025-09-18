// lib/data/models/trip_model.dart
import 'package:flutter/material.dart';

enum TripActivityType {
  hiking,    // مشي
  camping,   // تخييم
  religious, // ديني
  cultural,  // ثقافي
  other,     // آخر
}

enum TripStatus {
  planned,   // مخططة
  ongoing,   // جارية
  completed, // مكتملة
  cancelled, // ملغية
}

class Trip {
  final String id;
  final String pathId;
  final String pathName;
  final String pathLocation;
  final double pathLength;
  final String pathDifficulty;
  final TripActivityType activityType;
  final DateTime scheduledDate;
  final TimeOfDay scheduledTime;
  final int estimatedDurationHours;
  final String notes;
  final List<String> participants;
  final int participantCount;
  final TripStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String userId;

  Trip({
    required this.id,
    required this.pathId,
    required this.pathName,
    required this.pathLocation,
    required this.pathLength,
    required this.pathDifficulty,
    required this.activityType,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.estimatedDurationHours,
    required this.notes,
    required this.participants,
    required this.participantCount,
    required this.status,
    required this.createdAt,
    this.completedAt,
    required this.userId,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pathId': pathId,
      'pathName': pathName,
      'pathLocation': pathLocation,
      'pathLength': pathLength,
      'pathDifficulty': pathDifficulty,
      'activityType': activityType.name,
      'scheduledDate': scheduledDate.toIso8601String(),
      'scheduledTime': '${scheduledTime.hour}:${scheduledTime.minute}',
      'estimatedDurationHours': estimatedDurationHours,
      'notes': notes,
      'participants': participants,
      'participantCount': participantCount,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'userId': userId,
    };
  }

  // Create from JSON
  factory Trip.fromJson(Map<String, dynamic> json) {
    final timeString = json['scheduledTime'] as String;
    final timeParts = timeString.split(':');
    
    return Trip(
      id: json['id'],
      pathId: json['pathId'],
      pathName: json['pathName'],
      pathLocation: json['pathLocation'],
      pathLength: json['pathLength'].toDouble(),
      pathDifficulty: json['pathDifficulty'],
      activityType: TripActivityType.values.byName(json['activityType']),
      scheduledDate: DateTime.parse(json['scheduledDate']),
      scheduledTime: TimeOfDay(
        hour: int.parse(timeParts[0]), 
        minute: int.parse(timeParts[1])
      ),
      estimatedDurationHours: json['estimatedDurationHours'],
      notes: json['notes'],
      participants: List<String>.from(json['participants']),
      participantCount: json['participantCount'],
      status: TripStatus.values.byName(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      userId: json['userId'],
    );
  }

  // Copy with method
  Trip copyWith({
    String? id,
    String? pathId,
    String? pathName,
    String? pathLocation,
    double? pathLength,
    String? pathDifficulty,
    TripActivityType? activityType,
    DateTime? scheduledDate,
    TimeOfDay? scheduledTime,
    int? estimatedDurationHours,
    String? notes,
    List<String>? participants,
    int? participantCount,
    TripStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? userId,
  }) {
    return Trip(
      id: id ?? this.id,
      pathId: pathId ?? this.pathId,
      pathName: pathName ?? this.pathName,
      pathLocation: pathLocation ?? this.pathLocation,
      pathLength: pathLength ?? this.pathLength,
      pathDifficulty: pathDifficulty ?? this.pathDifficulty,
      activityType: activityType ?? this.activityType,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      estimatedDurationHours: estimatedDurationHours ?? this.estimatedDurationHours,
      notes: notes ?? this.notes,
      participants: participants ?? this.participants,
      participantCount: participantCount ?? this.participantCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      userId: userId ?? this.userId,
    );
  }

  // Helper methods
  String getActivityTypeText() {
    switch (activityType) {
      case TripActivityType.hiking:
        return 'مشي';
      case TripActivityType.camping:
        return 'تخييم';
      case TripActivityType.religious:
        return 'ديني';
      case TripActivityType.cultural:
        return 'ثقافي';
      case TripActivityType.other:
        return 'آخر';
    }
  }

  String getStatusText() {
    switch (status) {
      case TripStatus.planned:
        return 'مخططة';
      case TripStatus.ongoing:
        return 'جارية';
      case TripStatus.completed:
        return 'مكتملة';
      case TripStatus.cancelled:
        return 'ملغية';
    }
  }

  Color getStatusColor() {
    switch (status) {
      case TripStatus.planned:
        return Colors.blue;
      case TripStatus.ongoing:
        return Colors.orange;
      case TripStatus.completed:
        return Colors.green;
      case TripStatus.cancelled:
        return Colors.red;
    }
  }

  String getFormattedDateTime() {
    return '${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year} - ${scheduledTime.format(null)}';
  }

  bool get isToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year && 
           scheduledDate.month == now.month && 
           scheduledDate.day == now.day;
  }

  bool get isUpcoming {
    return scheduledDate.isAfter(DateTime.now()) && status == TripStatus.planned;
  }

  Duration get timeUntilTrip {
    if (!isUpcoming) return Duration.zero;
    final tripDateTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );
    return tripDateTime.difference(DateTime.now());
  }
}