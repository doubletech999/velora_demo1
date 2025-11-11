// lib/data/models/user_model.dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final int completedTrips;
  final int savedTrips;
  final int achievements;
  final String preferredLanguage;
  final String? role;
  final DateTime createdAt;
  final DateTime? emailVerifiedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.completedTrips = 0,
    this.savedTrips = 0,
    this.achievements = 0,
    this.preferredLanguage = 'ar',
    this.role,
    required this.createdAt,
    this.emailVerifiedAt,
  });

  // Create UserModel from JSON (من Laravel API)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profile_image_url'],
      completedTrips: json['completed_trips'] ?? 0,
      savedTrips: json['saved_trips'] ?? 0,
      achievements: json['achievements'] ?? 0,
      preferredLanguage: json['preferred_language'] ?? json['language'] ?? 'ar',
      role: json['role'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
    );
  }

  // Convert UserModel to JSON (لإرسال إلى Laravel API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image_url': profileImageUrl,
      'completed_trips': completedTrips,
      'saved_trips': savedTrips,
      'achievements': achievements,
      'preferred_language': preferredLanguage,
      'language': preferredLanguage,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
    };
  }

  // Copy with method for updates
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    int? completedTrips,
    int? savedTrips,
    int? achievements,
    String? preferredLanguage,
    String? role,
    DateTime? createdAt,
    DateTime? emailVerifiedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      completedTrips: completedTrips ?? this.completedTrips,
      savedTrips: savedTrips ?? this.savedTrips,
      achievements: achievements ?? this.achievements,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserModel &&
      other.id == id &&
      other.name == name &&
      other.email == email;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ email.hashCode;
  }
}