import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Generic methods
  Future<bool> saveString(String key, String value) async {
    return await _preferences?.setString(key, value) ?? false;
  }

  String? getString(String key) {
    return _preferences?.getString(key);
  }

  Future<bool> saveInt(String key, int value) async {
    return await _preferences?.setInt(key, value) ?? false;
  }

  int? getInt(String key) {
    return _preferences?.getInt(key);
  }

  Future<bool> saveBool(String key, bool value) async {
    return await _preferences?.setBool(key, value) ?? false;
  }

  bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  Future<bool> saveDouble(String key, double value) async {
    return await _preferences?.setDouble(key, value) ?? false;
  }

  double? getDouble(String key) {
    return _preferences?.getDouble(key);
  }

  Future<bool> saveObject(String key, Map<String, dynamic> object) async {
    final String encoded = json.encode(object);
    return await saveString(key, encoded);
  }

  Map<String, dynamic>? getObject(String key) {
    final String? encoded = getString(key);
    if (encoded != null) {
      return json.decode(encoded) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> saveList(String key, List<dynamic> list) async {
    final String encoded = json.encode(list);
    return await saveString(key, encoded);
  }

  List<dynamic>? getList(String key) {
    final String? encoded = getString(key);
    if (encoded != null) {
      return json.decode(encoded) as List<dynamic>;
    }
    return null;
  }

  Future<bool> remove(String key) async {
    return await _preferences?.remove(key) ?? false;
  }

  Future<bool> clear() async {
    return await _preferences?.clear() ?? false;
  }

  bool containsKey(String key) {
    return _preferences?.containsKey(key) ?? false;
  }
}