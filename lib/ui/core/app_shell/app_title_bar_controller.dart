import 'package:flutter/widgets.dart';

class AppTitleBarController extends ChangeNotifier {
  bool _showTitleBar = true;
  bool get showTitleBar => _showTitleBar;

  void setTitleBarVisible(bool visible) {
    if (_showTitleBar != visible) {
      _showTitleBar = visible;
      notifyListeners();
    }
  }
}
