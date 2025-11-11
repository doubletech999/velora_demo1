import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  // Default settings
  bool _notificationsEnabled = true;
  String _mapType = 'standard';
  bool _useCelsius = true;
  bool _locationEnabled = true;
  bool _darkModeEnabled = false;
  int _searchHistoryLimit = 10;

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  String get mapType => _mapType; 
  bool get useCelsius => _useCelsius;
  bool get locationEnabled => _locationEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  int get searchHistoryLimit => _searchHistoryLimit;

  // Keys for SharedPreferences
  static const String _notificationsKey = 'notificationsEnabled';
  static const String _mapTypeKey = 'mapType';
  static const String _useCelsiusKey = 'useCelsius';
  static const String _locationEnabledKey = 'locationEnabled';
  static const String _darkModeEnabledKey = 'darkModeEnabled';
  static const String _searchHistoryLimitKey = 'searchHistoryLimit';

  SettingsProvider() {
    _loadSettings();
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? _notificationsEnabled;
    _mapType = prefs.getString(_mapTypeKey) ?? _mapType;
    _useCelsius = prefs.getBool(_useCelsiusKey) ?? _useCelsius;
    _locationEnabled = prefs.getBool(_locationEnabledKey) ?? _locationEnabled;
    _darkModeEnabled = prefs.getBool(_darkModeEnabledKey) ?? _darkModeEnabled;
    _searchHistoryLimit = prefs.getInt(_searchHistoryLimitKey) ?? _searchHistoryLimit;
    
    notifyListeners();
  }

  // Update notifications setting
  Future<void> setNotificationsEnabled(bool value) async {
    if (_notificationsEnabled != value) {
      _notificationsEnabled = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsKey, value);
      notifyListeners();
    }
  }

  // Update map type setting
  Future<void> setMapType(String value) async {
    if (_mapType != value) {
      _mapType = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_mapTypeKey, value);
      notifyListeners();
    }
  }

  // Update temperature unit setting
  Future<void> setUseCelsius(bool value) async {
    if (_useCelsius != value) {
      _useCelsius = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_useCelsiusKey, value);
      notifyListeners();
    }
  }

  // Update location setting
  Future<void> setLocationEnabled(bool value) async {
    if (_locationEnabled != value) {
      _locationEnabled = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_locationEnabledKey, value);
      notifyListeners();
    }
  }

  // Update dark mode setting
  Future<void> setDarkModeEnabled(bool value) async {
    if (_darkModeEnabled != value) {
      _darkModeEnabled = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeEnabledKey, value);
      notifyListeners();
    }
  }

  // Update search history limit
  Future<void> setSearchHistoryLimit(int value) async {
    if (_searchHistoryLimit != value) {
      _searchHistoryLimit = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_searchHistoryLimitKey, value);
      notifyListeners();
    }
  }

  // Reset all settings to default
  Future<void> resetSettings() async {
    _notificationsEnabled = true;
    _mapType = 'standard';
    _useCelsius = true;
    _locationEnabled = true;
    _darkModeEnabled = false;
    _searchHistoryLimit = 10;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsKey);
    await prefs.remove(_mapTypeKey);
    await prefs.remove(_useCelsiusKey);
    await prefs.remove(_locationEnabledKey);
    await prefs.remove(_darkModeEnabledKey);
    await prefs.remove(_searchHistoryLimitKey);
    
    notifyListeners();
  }
}