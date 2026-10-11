import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel.dart';
import 'package:material_ui/material_ui.dart';

class PanelController extends ChangeNotifier {
  final List<Panel> _routeStack = [];
  Panel? get activePanel => _routeStack.lastOrNull;

  @override
  void dispose() {
    _routeStack.clear();
    super.dispose();
  }

  void push(Panel panel) {
    _routeStack.add(panel);
    notifyListeners();
  }

  void pop() {
    _routeStack.removeLast();
    notifyListeners();
  }

  void popAll() {
    _routeStack.clear();
    notifyListeners();
  }
}
