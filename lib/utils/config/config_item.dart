import 'dart:async';

import 'package:hive_ce_flutter/hive_flutter.dart';

class ConfigItem<T> {
  final Box _box;
  final String key;
  final T defaultValue;

  T _value;
  T get value => _value;

  ConfigItem({
    required Box box,
    required this.key,
    required this.defaultValue,
  }) : _box = box,
       _value = box.get(key) ?? defaultValue;

  final StreamController<T> _controller = StreamController.broadcast();
  late final Stream<T> stream = _controller.stream;

  void set(T newValue) {
    _value = newValue;
    _controller.add(newValue);

    return unawaited(_box.put(key, newValue));
  }

  void dispose() {
    _controller.close();
  }
}
