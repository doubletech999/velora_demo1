// lib/core/services/connectivity_service.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

enum ConnectivityStatus {
  connected,
  disconnected,
  unknown,
}

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();
  
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;

  Stream<ConnectivityStatus> get statusStream => _statusController.stream;
  ConnectivityStatus get currentStatus => _currentStatus;

  Future<void> initialize() async {
    // Check initial status
    await checkConnectivity();

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _updateStatus(results);
      },
    );
  }

  Future<void> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateStatus(results);
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      _currentStatus = ConnectivityStatus.unknown;
      _statusController.add(_currentStatus);
    }
  }

  void _updateStatus(List<ConnectivityResult> results) {
    ConnectivityStatus newStatus;
    
    if (results.contains(ConnectivityResult.none)) {
      newStatus = ConnectivityStatus.disconnected;
    } else if (results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet) ||
        results.contains(ConnectivityResult.vpn)) {
      newStatus = ConnectivityStatus.connected;
    } else {
      newStatus = ConnectivityStatus.unknown;
    }

    if (_currentStatus != newStatus) {
      _currentStatus = newStatus;
      _statusController.add(_currentStatus);
    }
  }

  bool get isConnected => _currentStatus == ConnectivityStatus.connected;

  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}







