import 'package:material_ui/material_ui.dart';
import 'package:flutter_media_session/flutter_media_session.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:logger/logger.dart';

/// 作为中间层解决因为前方路由的销毁比后方路由的恢复晚发生
/// 导致 [FlutterMediaSession.deactivate] 销毁所有 `session` 的问题
class MediaSessionController {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'MediaSessionController'));

  final FlutterMediaSession _plugin = FlutterMediaSession();
  MediaSession? _currentSession;

  MediaSession createSession(MediaSessionAdapter adapter) {
    late final MediaSession session;

    session = MediaSession(
      adapter: adapter,
      activate: () async {
        _log.i('activate ${session.hashCode}');
        if (_currentSession == session) return;

        if (_currentSession == null) {
          _currentSession = session;
          await _plugin.activate();
        }

        _plugin.bind(adapter);
      },
      deactivate: () {
        _log.i('deactivate ${session.hashCode}');
        if (_currentSession == session) {
          _currentSession = null;
          _plugin.unbind();
          _plugin.deactivate();
        }
      },
    );

    return session;
  }
}

class MediaSession {
  final MediaSessionAdapter adapter;
  final VoidCallback activate;
  final VoidCallback deactivate;

  const MediaSession({
    required this.adapter,
    required this.activate,
    required this.deactivate,
  });
}
