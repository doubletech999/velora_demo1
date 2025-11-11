// lib/data/models/trip_registration_model.dart
class TripRegistrationModel {
  final String id;
  final String pathId;
  final String pathName;
  final String pathLocation;
  final String userId;
  final String organizerName;
  final String organizerPhone;
  final String organizerEmail;
  final int numberOfParticipants;
  final String notes;
  final TripStatus status;
  final DateTime createdAt;
  final double? pricePerPerson;
  final double? totalPrice;
  final PaymentMethod? paymentMethod;

  TripRegistrationModel({
    required this.id,
    required this.pathId,
    required this.pathName,
    required this.pathLocation,
    required this.userId,
    required this.organizerName,
    required this.organizerPhone,
    required this.organizerEmail,
    required this.numberOfParticipants,
    required this.notes,
    this.status = TripStatus.pending,
    required this.createdAt,
    this.pricePerPerson,
    this.totalPrice,
    this.paymentMethod,
  });

  factory TripRegistrationModel.fromJson(Map<String, dynamic> json) {
    return TripRegistrationModel(
      id: json['id'],
      pathId: json['path_id'],
      pathName: json['path_name'],
      pathLocation: json['path_location'],
      userId: json['user_id'],
      organizerName: json['organizer_name'],
      organizerPhone: json['organizer_phone'],
      organizerEmail: json['organizer_email'],
      numberOfParticipants: json['number_of_participants'] ?? 1,
      notes: json['notes'] ?? '',
      status: TripStatus.values.byName(json['status'] ?? 'pending'),
      createdAt: DateTime.parse(json['created_at']),
      pricePerPerson: json['price_per_person']?.toDouble(),
      totalPrice: json['total_price']?.toDouble(),
      paymentMethod: json['payment_method'] != null 
          ? PaymentMethod.values.byName(json['payment_method'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path_id': pathId,
      'path_name': pathName,
      'path_location': pathLocation,
      'user_id': userId,
      'organizer_name': organizerName,
      'organizer_phone': organizerPhone,
      'organizer_email': organizerEmail,
      'number_of_participants': numberOfParticipants,
      'notes': notes,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'price_per_person': pricePerPerson,
      'total_price': totalPrice,
      'payment_method': paymentMethod?.name,
    };
  }

  TripRegistrationModel copyWith({
    String? id,
    String? pathId,
    String? pathName,
    String? pathLocation,
    String? userId,
    String? organizerName,
    String? organizerPhone,
    String? organizerEmail,
    int? numberOfParticipants,
    String? notes,
    TripStatus? status,
    DateTime? createdAt,
    double? pricePerPerson,
    double? totalPrice,
    PaymentMethod? paymentMethod,
  }) {
    return TripRegistrationModel(
      id: id ?? this.id,
      pathId: pathId ?? this.pathId,
      pathName: pathName ?? this.pathName,
      pathLocation: pathLocation ?? this.pathLocation,
      userId: userId ?? this.userId,
      organizerName: organizerName ?? this.organizerName,
      organizerPhone: organizerPhone ?? this.organizerPhone,
      organizerEmail: organizerEmail ?? this.organizerEmail,
      numberOfParticipants: numberOfParticipants ?? this.numberOfParticipants,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      pricePerPerson: pricePerPerson ?? this.pricePerPerson,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

enum TripStatus {
  pending,     // قيد المراجعة
  approved,    // تم القبول
  rejected,    // تم الرفض
  cancelled,   // ملغي
}

enum PaymentMethod {
  cash,        // نقدي
  visa,        // فيزا
  none,        // بدون دفع (مثلاً للرقص الحجز)
}

extension TripStatusExtension on TripStatus {
  String get displayNameAr {
    switch (this) {
      case TripStatus.pending:
        return 'قيد المراجعة';
      case TripStatus.approved:
        return 'تم القبول';
      case TripStatus.rejected:
        return 'تم الرفض';
      case TripStatus.cancelled:
        return 'ملغي';
    }
  }

  String get description {
    switch (this) {
      case TripStatus.pending:
        return 'طلبك قيد المراجعة من قبل الإدارة';
      case TripStatus.approved:
        return 'تم قبول طلبك، سيتم التواصل معك قريباً';
      case TripStatus.rejected:
        return 'عذراً، لم يتم قبول طلبك';
      case TripStatus.cancelled:
        return 'تم إلغاء الطلب';
    }
  }
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayNameAr {
    switch (this) {
      case PaymentMethod.cash:
        return 'نقدي';
      case PaymentMethod.visa:
        return 'بطاقة فيزا';
      case PaymentMethod.none:
        return 'بدون دفع';
    }
  }
}