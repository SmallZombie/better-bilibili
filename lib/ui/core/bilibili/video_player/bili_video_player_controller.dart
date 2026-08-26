import 'dart:async';

import 'package:better_bilibili/config/danmaku_config.dart';
import 'package:better_bilibili/config/player_config.dart';
import 'package:better_bilibili/data/repositories/bilibili/auth_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_extra_play_info_response.dart';
import 'package:better_bilibili/domain/models/bilibili/play_info.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/quality_panel.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:logger/logger.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class BiliVideoPlayerController {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'BiliVideoPlayerViewModel'));

  final AuthRepository _authRepository;
  final PlayerConfig _playerConfig;
  final DanmakuConfig _danmakuConfig;

  final PlayInfo playInfo;
  final GetExtraPlayInfoResponse extraPlayInfo;

  late final Player _player;
  late final VideoController _controller;
  Player get player => _player;
  VideoController get controller => _controller;
  late final BiliVideoPlayerStream stream;
  late BiliVideoPlayerState state;

  BiliVideoPlayerController({
    required AuthRepository authRepository,
    required PlayerConfig playerConfig,
    required DanmakuConfig danmakuConfig,
    required this.playInfo,
    required this.extraPlayInfo,
  }) : _authRepository = authRepository,
       _playerConfig = playerConfig,
       _danmakuConfig = danmakuConfig {
    init = Command0(_init)..execute();

    _player = Player(configuration: PlayerConfiguration(bufferSize: 64 * 1024 * 1024));
    _controller = VideoController(_player);
    stream = BiliVideoPlayerStream(
      rawStream: _player.stream,
      seekStart: _seekStartController.stream,
      seekEnd: _seekEndController.stream,
      videoTrack: _videoTrackController.stream,
      audioTrack: _audioTrackController.stream,
      fullscreen: _fullscreenController.stream,
      windowFullscreen: _windowFullscreenController.stream,
    );
    state = BiliVideoPlayerState(player: player);
  }

  final List<StreamSubscription> _subscriptions = [];
  final StreamController<Duration> _seekStartController = StreamController<Duration>.broadcast();
  final StreamController<Duration> _seekEndController = StreamController<Duration>.broadcast();
  final StreamController<MediaTrack> _videoTrackController = StreamController<MediaTrack>.broadcast();
  final StreamController<MediaTrack?> _audioTrackController = StreamController<MediaTrack?>.broadcast();
  final StreamController<bool> _fullscreenController = StreamController<bool>.broadcast();
  final StreamController<bool> _windowFullscreenController = StreamController<bool>.broadcast();

  void emitSeekStart(Duration position) => _seekStartController.add(position);
  void emitSeekEnd(Duration position) => _seekEndController.add(position);
  void emitFullscreen(bool value) {
    _fullscreenController.add(value);
    state = state.copyWith(fullscreen: value);
  }

  void emitWindowFullscreen(bool toggle) {
    _windowFullscreenController.add(toggle);
    state = state.copyWith(windowFullscreen: toggle);
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    _seekStartController.close();
    _seekEndController.close();
    _videoTrackController.close();
    _audioTrackController.close();
    _fullscreenController.close();
    _windowFullscreenController.close();

    // 这里与 media_kit 官方 demo 一致，只需销毁 player 即可
    _player.dispose();
  }

  late final Command0 init;

  List<MediaTrack> _videoTracks = [];
  List<MediaTrack> get videoTracks => List.unmodifiable(_videoTracks);
  List<MediaTrack> get audioTracks => List.unmodifiable(playInfo.audioTracks);

  QualityPanelValues _quality = QualityPanelValues(video: 0, audio: 0);
  QualityPanelValues get quality => _quality;
  Future<void> setQuality(QualityPanelValues newValue) async {
    if (newValue.video == _quality.video && newValue.audio == _quality.audio) {
      return;
    }

    final restorePlaying = _player.state.playing;
    final restorePosition = _player.state.position;
    final List<Future> futures = [];

    if (_quality.video != newValue.video) {
      final newTrack = _getTrackByQuality(_videoTracks, newValue.video)!;
      futures.add(
        _player.open(
          Media(newTrack.url),
          play: false,
        ),
      );
      _videoTrackController.add(newTrack);
      state = state.copyWith(videoTrack: newTrack);
    }

    final audioTrack = newValue.audio == null ? null : _getTrackByQuality(audioTracks, newValue.audio!);
    if (audioTrack != null) {
      futures.add(_player.setAudioTrack(AudioTrack.uri(audioTrack.url)));
    }
    if (_quality.audio != newValue.audio) {
      _audioTrackController.add(audioTrack);
      state = state.copyWith(audioTrack: audioTrack);
    }

    _quality = newValue;
    _log.i('new quality: ${newValue.video}, ${newValue.audio}');

    await Future.wait(futures);
    _log.i('restore playback state, position=$restorePosition, playing=$restorePlaying');
    // 注意他们的微秒并不相等，所以这里换一种比较思路
    while (restorePosition > Duration.zero && _player.state.position == Duration.zero) {
      await Future.delayed(Duration(milliseconds: 100));
      seek(restorePosition);
    }
    if (restorePlaying) _player.play();
  }

  Future<Result<void>> _init() async {
    await _playerConfig.ensureInitialized();
    await _danmakuConfig.ensureInitialized();

    _player.setVolume(_playerConfig.volume);

    _videoTracks = _getTracksByCodec(playInfo.videoTracks, _playerConfig.preferredCodec);
    if (_videoTracks.isEmpty) {
      if (_playerConfig.fallbackCodec != _playerConfig.preferredCodec) {
        _videoTracks = _getTracksByCodec(playInfo.videoTracks, _playerConfig.fallbackCodec);
      }
      if (_videoTracks.isEmpty) {
        _videoTracks = _getTracksByCodec(playInfo.videoTracks, playInfo.videoTracks.first.codec);
      }
    }

    final videoTrack = _getTrackByQuality(_videoTracks, _playerConfig.videoQuality);
    if (videoTrack != null) {
      _log.i('selected video track: ${videoTrack.url} | ${videoTrack.id} | ${videoTrack.codecProfile}');
    } else {
      _log.i('no audio track selected');
    }

    final audioTrack = _getTrackByQuality(playInfo.audioTracks, _playerConfig.audioQuality);
    if (audioTrack != null) {
      _log.i('selected audio track: ${audioTrack.url} | ${audioTrack.id} | ${audioTrack.codecProfile}');
    } else {
      _log.i('no audio track selected');
    }

    if (_player.platform is NativePlayer) {
      final p = _player.platform as NativePlayer;
      p.setProperty('referrer', 'https://www.bilibili.com/video/${playInfo.bvid}/');
      p.setProperty('user-agent', (await _authRepository.getAccount()).userAgent!);
    }
    setQuality(QualityPanelValues(video: videoTrack?.id ?? 0, audio: audioTrack?.id));

    if (extraPlayInfo.subtitles.isNotEmpty) {
      final subtitle = extraPlayInfo.subtitles.first;
      _log.i('selected subtitle track: ${subtitle.url} | ${subtitle.id} | ${subtitle.code}');
      loadSubtitle(subtitle.url);
    }

    _subscriptions.addAll([
      _player.stream.error.listen((e) => _log.e('onPlayerError', error: e)),
      // 处理循环播放，因为播放结束后需要重新设置音轨，所以这里要手动处理重新播放的逻辑
      _player.stream.completed.listen((e) {
        if (!e) return;
        if (_playerConfig.loopPlayback) {
          if (audioTrack != null) {
            _player.setAudioTrack(AudioTrack.uri(audioTrack.url));
          }
          play();
        }
      }),
      _player.stream.duration.listen((e) {
        _log.i('onDuration: $e');

        if (_playerConfig.autoPlay) {
          play();
        }
      }),
    ]);

    _log.i('init down $hashCode, state: ${player.state.hashCode}');

    return Result.ok(null);
  }

  void playOrPause() => _player.playOrPause();
  void play() => _player.play();
  void pause() => _player.pause();
  void setVolume(double volume) => _player.setVolume(volume);

  Future<void> loadSubtitle(String url) async {
    final client = await _authRepository.getClient();
    final resp = await client.get(url);

    if (resp.statusCode != 200) {
      return;
    }

    final list = resp.data['body'] as List;
    String data = list
        .asMap()
        .entries
        .map((entry) {
          int i = entry.key + 1;
          var item = entry.value;

          String formatTime(double s) {
            int ms = (s * 1000).toInt();
            return '${(ms ~/ 3600000).toString().padLeft(2, '0')}:${((ms ~/ 60000) % 60).toString().padLeft(2, '0')}:${((ms ~/ 1000) % 60).toString().padLeft(2, '0')},${(ms % 1000).toString().padLeft(3, '0')}';
          }

          return '$i\n${formatTime(item['from'] * 1.0)} --> ${formatTime(item['to'] * 1.0)}\n${item['content']}';
        })
        .join('\n\n');

    _player.setSubtitleTrack(SubtitleTrack.data(data));
  }

  /// 返回过滤为目标编码的列表
  List<MediaTrack> _getTracksByCodec(List<MediaTrack> tracks, CodecEnum targetCodec) {
    return tracks.where((v) => v.codec == targetCodec).toList();
  }

  /// 返回目标质量的轨道，否则返回仅次于目标质量的轨道，否则返回首个轨道，否则返回 Null
  MediaTrack? _getTrackByQuality(List<MediaTrack> tracks, int targetQuality) {
    MediaTrack? track = tracks.where((v) => v.id == targetQuality).firstOrNull;
    if (track != null) return track;

    track = (tracks.where((v) => v.id < targetQuality).toList()..sort((a, b) => b.id.compareTo(a.id))).firstOrNull;
    if (track != null) return track;

    track = tracks.firstOrNull;
    if (track != null) return track;

    return null;
  }

  MediaTrack getTrack(int trackId) {
    return playInfo.videoTracks.firstWhere((v) => v.id == trackId);
  }

  void setPlaybackRate(double newValue) {
    _player.setRate(newValue);
  }

  void seek(Duration newPosition) {
    _log.i('seek to $newPosition');
    _player.seek(newPosition);
    emitSeekEnd(newPosition);
  }
}

class InitConfig {
  final String userAgent;
  final double volume;
  final CodecEnum preferredCodec;
  final CodecEnum fallbackCodec;
  final int videoQuality;
  final int audioQuality;
  final bool isAmbientLightEnabled;
  final bool autoPlay;
  final bool loopPlayback;

  const InitConfig({
    required this.userAgent,
    required this.volume,
    required this.preferredCodec,
    required this.fallbackCodec,
    required this.videoQuality,
    required this.audioQuality,
    required this.isAmbientLightEnabled,
    required this.autoPlay,
    required this.loopPlayback,
  });
}

class BiliVideoPlayerState implements PlayerState {
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

  const BiliVideoPlayerState({
    required Player player,
    this.fullscreen = false,
    this.windowFullscreen = false,
    this.videoTrack,
    this.audioTrack,
  }) : _player = player;

  final bool fullscreen;
  final bool windowFullscreen;
  final MediaTrack? videoTrack;
  final MediaTrack? audioTrack;

  @override
  BiliVideoPlayerState copyWith({
    Player? player,
    bool? fullscreen,
    bool? windowFullscreen,
    MediaTrack? videoTrack,
    MediaTrack? audioTrack,

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
    return BiliVideoPlayerState(
      player: _player,
      fullscreen: fullscreen ?? this.fullscreen,
      windowFullscreen: windowFullscreen ?? this.windowFullscreen,
      videoTrack: videoTrack ?? this.videoTrack,
      audioTrack: audioTrack ?? this.audioTrack,
    );
  }
}

class BiliVideoPlayerStream implements PlayerStream {
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
  Stream<Duration> get duration => _rawStream.duration;
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

  final Stream<MediaTrack> videoTrack;
  final Stream<MediaTrack?> audioTrack;
  final Stream<Duration> seekStart;
  final Stream<Duration> seekEnd;
  final Stream<bool> fullscreen;
  final Stream<bool> windowFullscreen;

  const BiliVideoPlayerStream({
    required PlayerStream rawStream,
    required this.videoTrack,
    required this.audioTrack,
    required this.seekStart,
    required this.seekEnd,
    required this.fullscreen,
    required this.windowFullscreen,
  }) : _rawStream = rawStream;
}
