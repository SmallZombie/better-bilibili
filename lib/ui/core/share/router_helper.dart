import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

extension RouterHelper on BuildContext {
  void popToRoot() {
    while (canPop()) {
      pop();
    }
  }
}
