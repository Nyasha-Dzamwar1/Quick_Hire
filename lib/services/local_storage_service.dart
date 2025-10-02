// services/local_storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _USERS = 'users';
  static const _JOBS = 'jobs';
  static const _APPLICATIONS = 'applications';
  static const _CURRENT_USER_ID = 'current_user_id';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);
  Future<bool> remove(String key) => _prefs.remove(key);

  List<Map<String, dynamic>> loadList(String key) {
    final s = _prefs.getString(key);
    print('Loading $key: $s');
    if (s == null) return [];
    final parsed = jsonDecode(s) as List<dynamic>;
    return parsed.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> saveList(String key, List<Map<String, dynamic>> list) async {
    final jsonString = jsonEncode(list);
    print('Saving $key: $jsonString');
    await _prefs.setString(key, jsonEncode(list));
  }

  // convenience wrappers:
  List<Map<String, dynamic>> loadUsers() => loadList(_USERS);
  Future<void> saveUsers(List<Map<String, dynamic>> list) =>
      saveList(_USERS, list);

  List<Map<String, dynamic>> loadJobs() => loadList(_JOBS);
  Future<void> saveJobs(List<Map<String, dynamic>> list) =>
      saveList(_JOBS, list);

  List<Map<String, dynamic>> loadApplications() => loadList(_APPLICATIONS);
  Future<void> saveApplications(List<Map<String, dynamic>> list) =>
      saveList(_APPLICATIONS, list);

  Future<void> setCurrentUserId(String id) =>
      _prefs.setString(_CURRENT_USER_ID, id);
  String? getCurrentUserId() => _prefs.getString(_CURRENT_USER_ID);
  Future<void> clearCurrentUserId() => _prefs.remove(_CURRENT_USER_ID);
}
