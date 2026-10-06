import 'dart:async';
import 'package:better_bilibili/ui/core/bilibili/video_player/media_session/media_session_data.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:logger/logger.dart';
import 'package:media_kit/media_kit.dart';
import 'package:flutter_media_session/flutter_media_session.dart';
import 'package:flutter_media_session/flutter_media_session_platform_interface.dart';

/// A production-ready adapter to bridge `media_kit` [Player] and [FlutterMediaSession].
/// https://github.com/wyrindev/flutter-media-session/blob/main/doc/usage.md#b-copy-ready-media_kit-adapter
class ExtraVideoPlayerMediaSessionAdapter implements MediaSessionAdapter {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'MediaKitMediaSessionAdapter'));

  final Player player;
  final MediaSessionData mediaSessionData;
  final bool manageLifecycle;

  final List<StreamSubscription> _subscriptions = [];
  FlutterMediaSession? _session;
  bool _isUpdating = false;

  ExtraVideoPlayerMediaSessionAdapter(
    this.player,
    this.mediaSessionData, {
    this.manageLifecycle = false,
  });

  @override
  void bind(FlutterMediaSession session) {
    unbind();
    _session = session;

    if (manageLifecycle) {
      _session?.activate().catchError((e) {
        _log.i('MediaKitAdapter: Failed to activate media session: $e');
      });
    }

    _subscriptions.addAll([
      player.stream.playing.listen((_) => _syncPlaybackState()),
      player.stream.position.listen((_) => _syncPlaybackState()),
      player.stream.duration.listen((_) {
        _syncMetadata();
        _syncPlaybackState();
      }),
      player.stream.rate.listen((_) => _syncPlaybackState()),
      player.stream.buffer.listen((_) => _syncPlaybackState()),
      player.stream.playlist.listen((_) => _syncMetadata()),
      FlutterMediaSessionPlatform.instance.onMediaAction.listen(_handleMediaAction),

      mediaSessionData.stream.title.listen((_) => _syncMetadata),
      mediaSessionData.stream.artist.listen((_) => _syncMetadata),
      mediaSessionData.stream.privacyMode.listen((_) => _syncMetadata()),
    ]);

    _syncMetadata();
    _syncPlaybackState();
  }

  @override
  void unbind() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();

    if (manageLifecycle) {
      _session?.deactivate().catchError((e) {
        _log.i('MediaKitAdapter: Failed to deactivate media session: $e');
      });
    }
    _session = null;
  }

  void _syncMetadata() {
    if (_session == null || _isUpdating) return;

    MediaMetadata metadata;
    if (mediaSessionData.state.privacyMode) {
      metadata = MediaMetadata(
        title: '[Hidden title]',
        artist: mediaSessionData.state.artist,
        duration: player.state.duration,
      );
    } else {
      metadata = MediaMetadata(
        title: mediaSessionData.state.title,
        artist: mediaSessionData.state.artist,
        duration: player.state.duration,
      );
    }

    _isUpdating = true;
    FlutterMediaSessionPlatform.instance
        .updateMetadata(metadata)
        .catchError((e) {
          _log.i('MediaKitAdapter: Failed to update metadata: $e');
        })
        .whenComplete(() => _isUpdating = false);
  }

  void _syncPlaybackState() {
    if (_session == null) return;

    final state = player.state;
    PlaybackStatus status = PlaybackStatus.idle;

    if (state.buffering) {
      status = PlaybackStatus.buffering;
    } else if (state.playing) {
      status = PlaybackStatus.playing;
    } else if (state.completed) {
      status = PlaybackStatus.ended;
    } else {
      status = PlaybackStatus.paused;
    }

    // Set 3-way Repeat mode corresponding to media_kit's playlistMode
    MediaRepeatMode repeatMode = MediaRepeatMode.none;
    if (state.playlistMode == PlaylistMode.single) {
      repeatMode = MediaRepeatMode.one;
    } else if (state.playlistMode == PlaylistMode.loop) {
      repeatMode = MediaRepeatMode.all;
    }

    final playbackState = PlaybackState(
      status: status,
      position: state.position,
      speed: state.rate,
      bufferedPosition: state.buffer,
      repeatMode: repeatMode,
      shuffleModeEnabled: false, // update as needed for media_kit shuffle
    );

    FlutterMediaSessionPlatform.instance.updatePlaybackState(playbackState).catchError((e) {
      _log.i('MediaKitAdapter: Failed to update playback state: $e');
    });

    _syncAvailableActions();
  }

  void _handleMediaAction(MediaAction action) async {
    try {
      switch (action.name) {
        case 'play':
          await player.play();
          break;
        case 'pause':
          await player.pause();
          break;
        case 'stop':
          await player.stop();
          break;
        case 'seekTo':
          if (action.seekPosition != null) {
            await player.seek(action.seekPosition!);
          }
          break;
        case 'skipToNext':
          await player.next();
          break;
        case 'skipToPrevious':
          await player.previous();
          break;
        case 'repeat':
          PlaylistMode nextMode = player.state.playlistMode == PlaylistMode.none
              ? PlaylistMode.loop
              : (player.state.playlistMode == PlaylistMode.loop ? PlaylistMode.single : PlaylistMode.none);
          await player.setPlaylistMode(nextMode);
          _syncAvailableActions();
          break;
      }
    } catch (e) {
      _log.i('MediaKitAdapter: Error handling action ${action.name}: $e');
    }
  }

  void _syncAvailableActions() {
    if (_session == null) return;

    final playlist = player.state.playlist;
    final hasNext = playlist.index < playlist.medias.length - 1;
    final hasPrev = playlist.index > 0;

    final actions = {
      MediaAction.play,
      MediaAction.pause,
      MediaAction.seekTo,
      MediaAction.stop,
      if (hasNext) MediaAction.skipToNext,
      if (hasPrev) MediaAction.skipToPrevious,
      MediaAction.custom(
        name: 'repeat',
        customLabel: 'Repeat',
        customIconResource: player.state.playlistMode == PlaylistMode.single
            ? 'ic_repeat_one'
            : (player.state.playlistMode == PlaylistMode.loop ? 'ic_repeat_on' : 'ic_repeat_off'),
      ),
    };

    FlutterMediaSessionPlatform.instance.updateAvailableActions(actions).catchError((e) {
      _log.i('MediaKitAdapter: Failed to update available actions: $e');
    });
  }

  void updateMetadata() => _syncMetadata();
}
