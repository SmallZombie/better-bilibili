import 'dart:async';

import 'package:better_bilibili/config/adapter/config_storage_adapter.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:logger/logger.dart';

class ConfigItem<T> {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'ConfigItem'));

  final ConfigStorageAdapter storage;
  final String key;
  final T defaultValue;
  final T Function(String data)? deserialization;
  final String Function(T data)? serialization;

  ConfigItem({
    required this.storage,
    required this.key,
    required this.defaultValue,
    this.deserialization,
    this.serialization,
  });

  T? _value;

  /// value 的值不总是最新的，甚至可能尚未从本地读取，
  /// 确保在使用前至少 get 过一次，在组件中应使用 ConfigBuilder
  T get value {
    if (_value == null) {
      _log.w('value is null, please call get() first');
    }

    return _value ?? defaultValue;
  }

  final StreamController<T> _controller = StreamController.broadcast();
  late final Stream<T> stream = _controller.stream;

  Future<T>? getter;

  Future<T> get() async {
    Future<T> doGet() async {
      final temp = await switch (T) {
        _ when T == bool => storage.getBool(key),
        _ when T == int => storage.getInt(key),
        _ when T == double => storage.getDouble(key),
        _ => storage.getString(key),
      };

      if (temp == null) {
        _value = value;
        return value;
      }

      if (temp is! T) {
        if (deserialization != null) {
          return deserialization!(temp as String);
        } else {
          return value;
        }
      }

      final data = temp as T;
      if (data != value) {
        set(data);
        return data;
      }

      return data ?? value;
    }

    if (getter != null) return getter!;
    getter = doGet();
    getter!.whenComplete(() => getter = null);
    return getter!;
  }

  Future<void> set(T newValue) async {
    _value = newValue;
    _controller.add(newValue);

    return switch (T) {
      _ when T == String => storage.setString(key, _value as String),
      _ when T == bool => storage.setBool(key, _value as bool),
      _ when T == int => storage.setInt(key, _value as int),
      _ when T == double => storage.setDouble(key, _value as double),
      _ => storage.setString(key, serialization?.call(value) ?? _value.toString()),
    };
  }

  void dispose() {
    _controller.close();
  }
}
