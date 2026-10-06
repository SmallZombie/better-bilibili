import 'package:better_bilibili/config/adapter/config_storage_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigPrefsStorage implements ConfigStorageAdapter {
  final SharedPreferencesAsync prefs;

  const ConfigPrefsStorage({required this.prefs});

  @override
  Future<bool?> getBool(String key) {
    return prefs.getBool(key);
  }

  @override
  Future<double?> getDouble(String key) {
    return prefs.getDouble(key);
  }

  @override
  Future<int?> getInt(String key) {
    return prefs.getInt(key);
  }

  @override
  Future<String?> getString(String key) {
    return prefs.getString(key);
  }

  @override
  Future<void> setBool(String key, bool value) {
    return prefs.setBool(key, value);
  }

  @override
  Future<void> setDouble(String key, double value) {
    return prefs.setDouble(key, value);
  }

  @override
  Future<void> setInt(String key, int value) {
    return prefs.setInt(key, value);
  }

  @override
  Future<void> setString(String key, String value) {
    return prefs.setString(key, value);
  }

  @override
  Future<dynamic> getUnknown(String key) {
    // TODO: implement getUnknown
    throw UnimplementedError();
  }

  @override
  Future<void> setUnknown(String key, value) {
    // TODO: implement setUnknown
    throw UnimplementedError();
  }

  @override
  Future<void> clear() {
    return prefs.clear();
  }

  @override
  Future<void> clearWithPrefix(String prefix) async {
    final items = await getWithPrefix(prefix);
    for (final key in items.keys) {
      await prefs.remove(key);
    }
  }

  @override
  Future<Map<String, dynamic>> getAll() {
    return prefs.getAll();
  }

  @override
  Future<Map<String, dynamic>> getWithPrefix(String prefix) async {
    final items = await getAll();
    final Map<String, dynamic> result = {};

    for (final key in items.keys) {
      if (key.startsWith(prefix)) {
        result[key] = items[key];
      }
    }

    return result;
  }

  @override
  Future<void> remove(String key) {
    return prefs.remove(key);
  }
}
