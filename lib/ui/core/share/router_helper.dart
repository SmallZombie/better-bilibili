import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension RouterHelper on BuildContext {
  void popToRoot() {
    while (canPop()) {
      pop();
    }
  }
}
