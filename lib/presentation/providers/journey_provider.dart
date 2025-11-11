// lib/presentation/providers/journey_provider.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:math';

import '../../data/models/path_model.dart';
import '../../core/services/location_service.dart';

enum JourneyStatus { notStarted, active, paused, completed }

class JourneyProvider extends ChangeNotifier {
  PathModel? _currentPath;
  JourneyStatus _status = JourneyStatus.notStarted;
  Position? _currentPosition;
  final List<Position> _recordedPositions = [];
  double _distanceTraveled = 0.0;
  double _currentSpeed = 0.0;
  int _visitedCheckpoints = 0;
  DateTime? _startTime;
  DateTime? _pauseTime;
  Duration _totalPausedTime = Duration.zero;

  StreamSubscription<Position>? _positionSubscription;

  // Getters
  PathModel? get currentPath => _currentPath;
  JourneyStatus get status => _status;
  Position? get currentPosition => _currentPosition;
  List<Position> get recordedPositions => _recordedPositions;
  double get distanceTraveled => _distanceTraveled;
  double get currentSpeed => _currentSpeed;
  int get visitedCheckpoints => _visitedCheckpoints;
  DateTime? get startTime => _startTime;
  Duration get totalPausedTime => _totalPausedTime;

  // بدء الرحلة
  Future<void> startJourney(PathModel path) async {
    try {
      _currentPath = path;
      _status = JourneyStatus.active;
      _startTime = DateTime.now();
      _recordedPositions.clear();
      _distanceTraveled = 0.0;
      _currentSpeed = 0.0;
      _visitedCheckpoints = 0;
      _totalPausedTime = Duration.zero;

      // بدء تتبع الموقع
      await _startLocationTracking();

      notifyListeners();
    } catch (e) {
      print('خطأ في بدء الرحلة: $e');
    }
  }

  // استئناف الرحلة
  void resumeJourney() {
    if (_status == JourneyStatus.paused) {
      if (_pauseTime != null) {
        _totalPausedTime =
            _totalPausedTime + DateTime.now().difference(_pauseTime!);
        _pauseTime = null;
      }
      _status = JourneyStatus.active;
      notifyListeners();
    }
  }

  // إيقاف الرحلة مؤقتاً
  void pauseJourney() {
    if (_status == JourneyStatus.active) {
      _status = JourneyStatus.paused;
      _pauseTime = DateTime.now();
      notifyListeners();
    }
  }

  // إنهاء الرحلة
  void stopJourney() {
    _status = JourneyStatus.completed;
    _positionSubscription?.cancel();
    notifyListeners();
  }

  // بدء تتبع الموقع
  Future<void> _startLocationTracking() async {
    try {
      // التحقق من صلاحيات الموقع
      final permission = await LocationService.instance.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('لا توجد صلاحيات للوصول إلى الموقع');
      }

      // الحصول على الموقع الحالي أولاً
      final currentPosition =
          await LocationService.instance.getCurrentPosition();
      if (currentPosition != null) {
        _updatePosition(currentPosition);
      }

      // بدء تتبع الموقع
      _positionSubscription = LocationService.instance
          .getPositionStream()
          .listen(
            (Position position) {
              if (_status == JourneyStatus.active) {
                _updatePosition(position);
              }
            },
            onError: (error) {
              print('خطأ في تتبع الموقع: $error');
            },
          );
    } catch (e) {
      print('خطأ في بدء تتبع الموقع: $e');
    }
  }

  // تحديث الموقع
  void _updatePosition(Position newPosition) {
    final previousPosition = _currentPosition;
    _currentPosition = newPosition;
    _recordedPositions.add(newPosition);

    // حساب المسافة المقطوعة
    if (previousPosition != null) {
      final distance = Geolocator.distanceBetween(
        previousPosition.latitude,
        previousPosition.longitude,
        newPosition.latitude,
        newPosition.longitude,
      );
      _distanceTraveled += distance / 1000; // تحويل إلى كيلومتر
    }

    // حساب السرعة الحالية
    _currentSpeed = newPosition.speed * 3.6; // تحويل من م/ث إلى كم/س

    // فحص النقاط المرجعية
    _checkCheckpoints(newPosition);

    notifyListeners();
  }

  // فحص النقاط المرجعية
  void _checkCheckpoints(Position currentPosition) {
    if (_currentPath == null) return;

    for (
      int i = _visitedCheckpoints;
      i < _currentPath!.coordinates.length;
      i++
    ) {
      final checkpoint = _currentPath!.coordinates[i];
      final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        checkpoint.latitude,
        checkpoint.longitude,
      );

      // إذا كان المستخدم قريباً من النقطة المرجعية (50 متر)
      if (distance <= 50) {
        _visitedCheckpoints = i + 1;
        _onCheckpointReached(i);
        break;
      }
    }
  }

  // عند الوصول إلى نقطة مرجعية
  void _onCheckpointReached(int checkpointIndex) {
    // يمكن إضافة إشعار أو صوت هنا
    print('تم الوصول إلى النقطة المرجعية ${checkpointIndex + 1}');

    // إذا وصل إلى النهاية
    if (_visitedCheckpoints >= _currentPath!.coordinates.length) {
      stopJourney();
    }
  }

  // حساب الوقت الفعلي للرحلة (بدون أوقات الإيقاف)
  Duration getActiveJourneyTime() {
    if (_startTime == null) return Duration.zero;

    final now = DateTime.now();
    final totalTime = now.difference(_startTime!);

    Duration pausedTime = _totalPausedTime;
    if (_status == JourneyStatus.paused && _pauseTime != null) {
      pausedTime = pausedTime + now.difference(_pauseTime!);
    }

    return totalTime - pausedTime;
  }

  // حساب النسبة المئوية للإكمال
  double getCompletionPercentage() {
    if (_currentPath == null) return 0.0;
    return _visitedCheckpoints / _currentPath!.coordinates.length;
  }

  // حساب المسافة المتبقية
  double getRemainingDistance() {
    if (_currentPath == null) return 0.0;
    return max(0.0, _currentPath!.length - _distanceTraveled);
  }

  // حساب الوقت المتوقع للوصول
  Duration getEstimatedTimeRemaining() {
    if (_currentSpeed <= 0 || _currentPath == null) {
      return _currentPath?.estimatedDuration ?? Duration.zero;
    }

    final remainingDistance = getRemainingDistance();
    final hours = remainingDistance / _currentSpeed;
    return Duration(milliseconds: (hours * 3600 * 1000).round());
  }

  // إعادة تعيين البيانات
  void reset() {
    _currentPath = null;
    _status = JourneyStatus.notStarted;
    _currentPosition = null;
    _recordedPositions.clear();
    _distanceTraveled = 0.0;
    _currentSpeed = 0.0;
    _visitedCheckpoints = 0;
    _startTime = null;
    _pauseTime = null;
    _totalPausedTime = Duration.zero;
    _positionSubscription?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}
