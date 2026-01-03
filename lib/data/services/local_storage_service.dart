import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static LocalStorageService? _instance;
  static SharedPreferences? _preferences;

  static Future<LocalStorageService> getInstance() async {
    _instance ??= LocalStorageService();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  Future<bool> saveData(String key, dynamic value) async {
    if (value is String) {
      return await _preferences!.setString(key, value);
    } else if (value is int) {
      return await _preferences!.setInt(key, value);
    } else if (value is double) {
      return await _preferences!.setDouble(key, value);
    } else if (value is bool) {
      return await _preferences!.setBool(key, value);
    } else if (value is List<String>) {
      return await _preferences!.setStringList(key, value);
    }
    return false;
  }

  dynamic getData(String key) {
    return _preferences!.get(key);
  }

  Future<bool> saveJson(String key, Map<String, dynamic> json) async {
    return await _preferences!.setString(key, jsonEncode(json));
  }

  Map<String, dynamic>? getJson(String key) {
    final jsonString = _preferences!.getString(key);
    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> saveJsonList(String key, List<Map<String, dynamic>> list) async {
    final jsonString = jsonEncode(list);
    return await _preferences!.setString(key, jsonString);
  }

  List<Map<String, dynamic>>? getJsonList(String key) {
    final jsonString = _preferences!.getString(key);
    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    }
    return null;
  }

  Future<bool> remove(String key) async {
    return await _preferences!.remove(key);
  }

  Future<bool> clearAll() async {
    return await _preferences!.clear();
  }
}
