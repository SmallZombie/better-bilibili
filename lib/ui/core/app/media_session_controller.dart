import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_media_session/flutter_media_session.dart';

/// 作为中间层解决因为前方路由的销毁比后方路由的恢复晚发生
/// 导致 [FlutterMediaSession.deactivate] 销毁所有 `session` 的问题
class MediaSessionController {
  final FlutterMediaSession _mediaSession = FlutterMediaSession();
  MediaSession? _currentSession;

  MediaSession createSession(MediaSessionAdapter adapter) {
    late final MediaSession session;

    session = MediaSession(
      adapter: adapter,
      activate: () {
        _mediaSession.unbind();
        _mediaSession.bind(adapter);

        if (_currentSession == null) {
          _mediaSession.activate();
        }
        _currentSession = session;
      },
      deactivate: () {
        if (_currentSession == session) {
          _mediaSession.unbind();
          _mediaSession.deactivate();
          _currentSession = null;
        }
      },
    );

    return session;
  }

  void releaseSession() {}
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
