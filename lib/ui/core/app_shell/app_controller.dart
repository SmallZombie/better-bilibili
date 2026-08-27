import 'package:better_bilibili/config/constants.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/web.dart';
import 'package:window_manager/window_manager.dart';

class AppController extends ChangeNotifier {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'AppController'));

  bool _showTitleBar = true;
  bool get showTitleBar => _showTitleBar;

  void setTitleBarVisible(bool visible) {
    if (_showTitleBar != visible) {
      _showTitleBar = visible;
      notifyListeners();
    }
  }

  final List<TitleSession> titleSessions = [];
  TitleSession requestDisplayTitle(String title) {
    late final TitleSession session;
    session = TitleSession(
      content: title,
      dispose: () => _disposeTitleSession(session),
    );

    titleSessions.add(session);
    _refreshTitle();

    return session;
  }

  void _disposeTitleSession(TitleSession session) {
    titleSessions.remove(session);
    _refreshTitle();
  }

  void _refreshTitle() {
    String title;

    if (titleSessions.isEmpty) {
      title = kDebugMode ? '$kAppName (Debug mode)' : kAppName;
    } else {
      title = titleSessions.map((v) => v.content).join(' & ');
    }

    _log.i('Update title to "$title"');
    windowManager.setTitle(title);
  }
}

class TitleSession {
  final String content;
  final VoidCallback dispose;

  const TitleSession({required this.content, required this.dispose});
}
