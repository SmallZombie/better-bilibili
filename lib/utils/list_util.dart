import 'package:flutter/material.dart';

extension WidgetListExtension on List<Widget> {
  /// 在组件之间插入特定的分隔组件
  List<Widget> intersperse(Widget separator) {
    if (isEmpty) return this;
    return expand((widget) => [widget, separator]).toList()..removeLast();
  }
}
