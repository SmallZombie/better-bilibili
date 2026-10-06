import 'package:better_bilibili/config/adapter/config_storage_adapter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ConfigSecureStorage implements ConfigStorageAdapter {
  final FlutterSecureStorage secure;

  const ConfigSecureStorage({required this.secure});

  @override
  Future<bool?> getBool(String key) async {
    final value = await secure.read(key: key);
    if (value == null) return null;

    try {
      return bool.parse(value);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<double?> getDouble(String key) async {
    final value = await secure.read(key: key);
    if (value == null) return null;

    try {
      return double.parse(value);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int?> getInt(String key) async {
    final value = await secure.read(key: key);
    if (value == null) return null;

    try {
      return int.parse(value);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> getString(String key) {
    return secure.read(key: key);
  }

  @override
  Future<void> setBool(String key, bool value) {
    return secure.write(key: key, value: value.toString());
  }

  @override
  Future<void> setDouble(String key, double value) {
    return secure.write(key: key, value: value.toString());
  }

  @override
  Future<void> setInt(String key, int value) {
    return secure.write(key: key, value: value.toString());
  }

  @override
  Future<void> setString(String key, String value) {
    return secure.write(key: key, value: value);
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
    return secure.deleteAll();
  }

  @override
  Future<void> clearWithPrefix(String prefix) async {
    final items = await getWithPrefix(prefix);
    for (final key in items.keys) {
      await secure.delete(key: key);
    }
  }

  @override
  Future<Map<String, dynamic>> getAll() {
    return secure.readAll();
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
    return secure.delete(key: key);
  }
}
