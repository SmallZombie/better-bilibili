import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  Future<SharedPreferences>? _prefsFuture;

  Future<SharedPreferences> _prefs() {
    return _prefsFuture ??= SharedPreferences.getInstance();
  }

  Future<String?> getString(String key) async {
    final p = await _prefs();
    return p.getString(key);
  }

  Future<void> setString(String key, String value) async {
    final p = await _prefs();
    await p.setString(key, value);
  }

  Future<int?> getInt(String key) async {
    final p = await _prefs();
    return p.getInt(key);
  }

  Future<void> setInt(String key, int value) async {
    final p = await _prefs();
    await p.setInt(key, value);
  }

  Future<void> remove(String key) async {
    final p = await _prefs();
    await p.remove(key);
  }
}
