abstract interface class ConfigStorageAdapter {
  Future<void> setString(String key, String value);
  Future<String?> getString(String key);

  Future<void> setBool(String key, bool value);
  Future<bool?> getBool(String key);

  Future<void> setInt(String key, int value);
  Future<int?> getInt(String key);

  Future<void> setDouble(String key, double value);
  Future<double?> getDouble(String key);

  Future<void> setUnknown(String key, dynamic value);
  Future<dynamic> getUnknown(String key);

  Future<Map<String, dynamic>> getAll();
  Future<Map<String, dynamic>> getWithPrefix(String prefix);

  Future<void> remove(String key);
  Future<void> clear();
  Future<void> clearWithPrefix(String prefix);
}
