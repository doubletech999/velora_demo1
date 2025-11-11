// lib/core/services/location_service.dart
import 'package:geolocator/geolocator.dart' hide ActivityType; // إخفاء ActivityType من geolocator
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  LocationService._();
  
  Position? _lastKnownPosition;
  
  // التحقق من توفر خدمات الموقع
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
  
  // التحقق من صلاحيات الموقع
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }
  
  // طلب صلاحيات الموقع
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }
  
  // الحصول على الموقع الحالي
  Future<Position?> getCurrentPosition() async {
    try {
      // التحقق من الخدمات
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('خدمات الموقع غير مفعلة');
      }
      
      // التحقق من الصلاحيات
      LocationPermission permission = await checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('تم رفض صلاحيات الموقع');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('صلاحيات الموقع مرفوضة نهائياً');
      }
      
      // الحصول على الموقع
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      _lastKnownPosition = position;
      return position;
      
    } catch (e) {
      print('خطأ في الحصول على الموقع: $e');
      
      // محاولة الحصول على آخر موقع معروف
      Position? lastPosition = await getLastKnownPosition();
      if (lastPosition != null) {
        return lastPosition;
      }
      
      return null;
    }
  }
  
  // الحصول على آخر موقع معروف
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      print('خطأ في الحصول على آخر موقع معروف: $e');
      return null;
    }
  }
  
  // تتبع الموقع في الوقت الفعلي
  Stream<Position> getPositionStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // التحديث كل 10 متر
    );
    
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
  
  // حساب المسافة بين نقطتين
  double calculateDistance(LatLng from, LatLng to) {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }
  
  // حساب المسافة بالكيلومتر
  double calculateDistanceInKm(LatLng from, LatLng to) {
    return calculateDistance(from, to) / 1000;
  }
  
  // التحقق من وجود المستخدم داخل منطقة معينة
  bool isWithinRadius(LatLng userLocation, LatLng center, double radiusInMeters) {
    double distance = calculateDistance(userLocation, center);
    return distance <= radiusInMeters;
  }
  
  // الحصول على اتجاه البوصلة
  double calculateBearing(LatLng from, LatLng to) {
    return Geolocator.bearingBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }
  
  // تحويل Position إلى LatLng
  LatLng positionToLatLng(Position position) {
    return LatLng(position.latitude, position.longitude);
  }
  
  // آخر موقع معروف
  Position? get lastKnownPosition => _lastKnownPosition;
  
  // فتح إعدادات الموقع
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
  
  // فتح إعدادات الصلاحيات
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}