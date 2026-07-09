import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  Future<void> writeString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> readString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> writeBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<bool> readBool(String key, {bool defaultValue = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> writeJson(String key, Object value) {
    return writeString(key, jsonEncode(value));
  }

  Future<dynamic> readJson(String key) async {
    final value = await readString(key);
    if (value == null || value.isEmpty) {
      return null;
    }
    return jsonDecode(value);
  }
}
