import 'package:flutter/foundation.dart';

class PanelPlayerState extends ChangeNotifier {
  String? _activePanel;

  String? get activePanel => _activePanel;

  bool get hasActivePanel => _activePanel != null;

  void openPanel(String id) {
    if (_activePanel == id) {
      return;
    }
    _activePanel = id;
    notifyListeners();
  }

  void closePanel() {
    if (_activePanel == null) {
      return;
    }
    _activePanel = null;
    notifyListeners();
  }

  void togglePanel(String id) {
    if (_activePanel == id) {
      closePanel();
    } else {
      openPanel(id);
    }
  }
}
