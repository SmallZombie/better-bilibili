import 'dart:async';

import 'package:hive_ce_flutter/hive_flutter.dart';

class AsyncConfigItem<T> {
  final LazyBox _box;
  final String key;
  final T defaultValue;

  T _value;
  T get value => _value;

  AsyncConfigItem({
    required LazyBox box,
    required this.key,
    required this.defaultValue,
  }) : _box = box,
       _value = defaultValue {
    get();
  }

  final StreamController<T> _controller = StreamController.broadcast();
  late final Stream<T> stream = _controller.stream;

  Future<T> get() async {
    final value = await _box.get(key) as T;
    if (value != _value) {
      _value = value;
      _controller.add(value);
    }
    return value;
  }

  Future<void> set(T newValue) {
    _value = newValue;
    _controller.add(newValue);

    return _box.put(key, newValue);
  }

  void dispose() {
    _controller.close();
  }
}
