import 'dart:async';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class ExtraVideoController extends VideoController {
  ExtraVideoController([String? title])
    : super(
        Player(
          configuration: PlayerConfiguration(
            bufferSize: 64 * 1024 * 1024,
            title: title ?? 'package:media_kit',
          ),
        ),
      ) {
    state = ExtraPlayerState(player: player);
    stream = ExtraPlayerStream(rawStream: player.stream);
  }

  late ExtraPlayerState state;
  late final ExtraPlayerStream stream;
  StreamSubscription<Duration>? _pendingSeekSubscription;

  bool _disposed = false;
  void dispose() {
    if (_disposed) return;
    _disposed = true;

    _pendingSeekSubscription?.cancel();
    _pendingSeekSubscription = null;

    stream.dispose();
    player.dispose();
  }

  void playOrPause() => player.playOrPause();
  void play() => player.play();
  void pause() => player.pause();
  void setVolume(double volume) {
    player.setVolume(volume);

    if (state.muted) {
      state = state.copyWith(muted: false);
      stream._mutedController.add(false);
    }
  }

  void setPlaybackRate(double newValue) => player.setRate(newValue);
  void seek(Duration newPosition) {
    if (_disposed) return;

    if (state.duration == .zero) {
      _pendingSeekSubscription?.cancel();
      _pendingSeekSubscription = stream.duration.listen((_) {
        if (_disposed) return;

        player.seek(newPosition);
        stream._seekController.add(newPosition);

        _pendingSeekSubscription?.cancel();
        _pendingSeekSubscription = null;
      });
    } else {
      player.seek(newPosition);
      stream._seekController.add(newPosition);
    }
  }

  bool get muted => state.volume == 0;
  double _volumeBak = 0;
  void setMuted(bool muted) {
    if (muted && !state.muted) {
      _volumeBak = state.volume;
      player.setVolume(0);
      state = state.copyWith(muted: muted);
      stream._mutedController.add(muted);
    } else if (!muted && state.muted) {
      player.setVolume(_volumeBak);
      state = state.copyWith(muted: muted);
      stream._mutedController.add(muted);
    }
  }

  void enterFullscreen() {
    state = state.copyWith(fullscreen: true);
    stream._fullscreenController.add(true);
  }

  void exitFullscreen() {
    state = state.copyWith(fullscreen: false);
    stream._fullscreenController.add(false);
  }

  void enterWindowFullscreen() {
    state = state.copyWith(windowFullscreen: true);
    stream._windowFullscreenController.add(true);
  }

  void exitWindowFullscreen() {
    state = state.copyWith(windowFullscreen: false);
    stream._windowFullscreenController.add(false);
  }

  Duration? _initPosition;

  Future<void> open({Media? video, Media? audio, Duration? initPosition}) async {
    final List<Future<void>> futures = [];

    if (video != null) {
      futures.add(player.open(video, play: false));
    }
    if (audio != null) {
      futures.add(player.setAudioTrack(AudioTrack.uri(audio.uri)));
    }

    await Future.wait(futures);

    final position = initPosition ?? _initPosition;
    if (position != null) {
      seek(position);
      _initPosition = null;
    }
  }

  Future<void> stop() {
    return player.stop();
  }

  /// 设置下次 open 时的初始播放位置(一次性)
  void setInitPosition(Duration position) {
    _initPosition = position;
  }
}

class ExtraPlayerState implements PlayerState {
  final Player _player;

  @override
  Playlist get playlist => _player.state.playlist;
  @override
  bool get playing => _player.state.playing;
  @override
  bool get completed => _player.state.completed;
  @override
  Duration get position => _player.state.position;
  @override
  Duration get duration => _player.state.duration;
  @override
  double get volume => _player.state.volume;
  @override
  double get rate => _player.state.rate;
  @override
  double get pitch => _player.state.pitch;
  @override
  bool get buffering => _player.state.buffering;
  @override
  Duration get buffer => _player.state.buffer;
  @override
  double get bufferingPercentage => _player.state.bufferingPercentage;
  @override
  PlaylistMode get playlistMode => _player.state.playlistMode;
  @override
  bool get shuffle => _player.state.shuffle;
  @override
  AudioParams get audioParams => _player.state.audioParams;
  @override
  VideoParams get videoParams => _player.state.videoParams;
  @override
  double? get audioBitrate => _player.state.audioBitrate;
  @override
  AudioDevice get audioDevice => _player.state.audioDevice;
  @override
  List<AudioDevice> get audioDevices => _player.state.audioDevices;
  @override
  Track get track => _player.state.track;
  @override
  Tracks get tracks => _player.state.tracks;
  @override
  int? get width => _player.state.width;
  @override
  int? get height => _player.state.height;
  @override
  List<String> get subtitle => _player.state.subtitle;

  const ExtraPlayerState({
    required Player player,
    this.fullscreen = false,
    this.windowFullscreen = false,
    this.muted = false,
  }) : _player = player;

  final bool fullscreen;
  final bool windowFullscreen;
  final bool muted;

  @override
  ExtraPlayerState copyWith({
    Player? player,
    bool? fullscreen,
    bool? windowFullscreen,
    bool? muted,

    Playlist? playlist,
    bool? playing,
    bool? completed,
    Duration? position,
    Duration? duration,
    double? volume,
    double? rate,
    double? pitch,
    bool? buffering,
    Duration? buffer,
    double? bufferingPercentage,
    PlaylistMode? playlistMode,
    bool? shuffle,
    AudioParams? audioParams,
    VideoParams? videoParams,
    double? audioBitrate,
    AudioDevice? audioDevice,
    List<AudioDevice>? audioDevices,
    Track? track,
    Tracks? tracks,
    int? width,
    int? height,
    List<String>? subtitle,
  }) {
    return ExtraPlayerState(
      player: _player,
      fullscreen: fullscreen ?? this.fullscreen,
      windowFullscreen: windowFullscreen ?? this.windowFullscreen,
      muted: muted ?? this.muted,
    );
  }
}

class ExtraPlayerStream implements PlayerStream {
  final PlayerStream _rawStream;

  @override
  Stream<Playlist> get playlist => _rawStream.playlist;
  @override
  Stream<bool> get playing => _rawStream.playing;
  @override
  Stream<bool> get completed => _rawStream.completed;
  @override
  Stream<Duration> get position => _rawStream.position;
  @override
  Stream<double> get volume => _rawStream.volume;
  @override
  Stream<double> get rate => _rawStream.rate;
  @override
  Stream<double> get pitch => _rawStream.pitch;
  @override
  Stream<bool> get buffering => _rawStream.buffering;
  @override
  Stream<double> get bufferingPercentage => _rawStream.bufferingPercentage;
  @override
  Stream<Duration> get buffer => _rawStream.buffer;
  @override
  Stream<PlaylistMode> get playlistMode => _rawStream.playlistMode;
  @override
  Stream<bool> get shuffle => _rawStream.shuffle;
  @override
  Stream<AudioParams> get audioParams => _rawStream.audioParams;
  @override
  Stream<VideoParams> get videoParams => _rawStream.videoParams;
  @override
  Stream<double?> get audioBitrate => _rawStream.audioBitrate;
  @override
  Stream<AudioDevice> get audioDevice => _rawStream.audioDevice;
  @override
  Stream<List<AudioDevice>> get audioDevices => _rawStream.audioDevices;
  @override
  Stream<Track> get track => _rawStream.track;
  @override
  Stream<Tracks> get tracks => _rawStream.tracks;
  @override
  Stream<int?> get width => _rawStream.width;
  @override
  Stream<int?> get height => _rawStream.height;
  @override
  Stream<List<String>> get subtitle => _rawStream.subtitle;
  @override
  Stream<PlayerLog> get log => _rawStream.log;
  @override
  Stream<String> get error => _rawStream.error;

  late final _durationController = StreamController<Duration>.broadcast();
  @override
  late final Stream<Duration> duration = _durationController.stream;

  late final _fullscreenController = StreamController<bool>.broadcast();
  late final Stream<bool> fullscreen = _fullscreenController.stream;

  late final _windowFullscreenController = StreamController<bool>.broadcast();
  late final Stream<bool> windowFullscreen = _windowFullscreenController.stream;

  late final _mutedController = StreamController<bool>.broadcast();
  late final Stream<bool> muted = _mutedController.stream;

  late final _seekController = StreamController<Duration>.broadcast();
  late final Stream<Duration> seek = _seekController.stream;

  final List<StreamSubscription> _subscriptions = [];

  ExtraPlayerStream({required PlayerStream rawStream}) : _rawStream = rawStream {
    _subscriptions.add(
      _rawStream.duration.listen((event) {
        if (event != .zero) {
          _durationController.add(event);
        }
      }),
    );
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    _durationController.close();
    _fullscreenController.close();
    _windowFullscreenController.close();
    _mutedController.close();
    _seekController.close();
  }
}
