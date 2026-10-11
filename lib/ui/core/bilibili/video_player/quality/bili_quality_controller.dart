import 'dart:async';

import 'package:better_bilibili/config/player_config.dart';
import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/domain/models/bilibili/play_info.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/extra_video_controller.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:material_ui/material_ui.dart';
import 'package:logger/logger.dart';
import 'package:media_kit/media_kit.dart';

class BiliQualityController extends ChangeNotifier {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'BiliQualityController'));

  final ExtraVideoController controller;
  final PlayerConfig config;
  final PlayInfo playInfo;
  final AuthRepository authRepository;

  final List<StreamSubscription> _subscriptions = [];
  bool _disposed = false;

  Player get player => controller.player;
  CodecEnum get preferredCodec => config.preferredCodec.value;
  CodecEnum get fallbackCodec => config.fallbackCodec.value;
  int get videoQuality => config.videoQuality.value;
  int get audioQuality => config.audioQuality.value;

  BiliQualityController({
    required this.controller,
    required this.config,
    required this.playInfo,
    required this.authRepository,
  }) {
    init();

    _subscriptions.addAll([
      config.preferredCodec.stream.listen(_onPreferredCodecChanged),
      config.fallbackCodec.stream.listen(_onFallbackCodecChanged),
    ]);
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;

    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _stream.dispose();

    super.dispose();
  }

  BiliQualityState _state = BiliQualityState();
  final BiliQualityStream _stream = BiliQualityStream();
  BiliQualityState get state => _state;
  BiliQualityStream get stream => _stream;

  List<MediaStream> _availableVideoStreamsByCodec = [];
  List<MediaStream> _availableAudioStreamsByCodec = [];
  List<MediaStream> get availableVideoStreamsByCodec => List.unmodifiable(_availableVideoStreamsByCodec);
  List<MediaStream> get availableAudioStreamsByCodec => List.unmodifiable(_availableAudioStreamsByCodec);

  bool _useFallbackCodec = false;
  bool get useFallbackCodec => _useFallbackCodec;

  Future<void> init() async {
    final videoQuality = config.videoQuality.value;
    final audioQuality = config.audioQuality.value;

    if (player.platform is NativePlayer) {
      final p = player.platform as NativePlayer;

      await p.setProperty('referrer', 'https://www.bilibili.com/video/${playInfo.bvid}/');
      if (_disposed) return;
      await p.setProperty('user-agent', (await authRepository.getAccount()).userAgent);
      if (_disposed) return;
    }

    _reloadAvailableStreams();

    final videoStream = _findClosestQuality(_availableVideoStreamsByCodec, videoQuality);
    final audioStream = _findClosestQuality(_availableAudioStreamsByCodec, audioQuality);
    unawaited(switchQuality(video: videoStream, audio: audioStream));
  }

  /// 返回目标质量的流，否则返回仅次于目标质量的流，否则返回首个流，否则返回 Null
  MediaStream? _findClosestQuality(List<MediaStream> streams, int targetQuality) {
    MediaStream? stream = streams.where((v) => v.id == targetQuality).firstOrNull;
    if (stream != null) return stream;

    stream = (streams.where((v) => v.id < targetQuality).toList()..sort((a, b) => b.id.compareTo(a.id))).firstOrNull;
    if (stream != null) return stream;

    stream = streams.firstOrNull;
    if (stream != null) return stream;

    return null;
  }

  void _reloadAvailableStreams() {
    /// 返回目标编码方式的列表
    List<MediaStream> getStreamByCodec(List<MediaStream> streams, CodecEnum targetCodec) {
      return streams.where((v) => v.codec == targetCodec).toList();
    }

    // 尝试优先使用设置的编码格式
    _availableVideoStreamsByCodec = getStreamByCodec(playInfo.videoStreams, preferredCodec);
    if (_availableVideoStreamsByCodec.isEmpty) {
      _useFallbackCodec = true;

      // 否则使用回退编码格式
      if (fallbackCodec != preferredCodec) {
        _availableVideoStreamsByCodec = getStreamByCodec(playInfo.videoStreams, fallbackCodec);
      }

      // 否则使用首个流所使用的编码格式
      if (_availableVideoStreamsByCodec.isEmpty) {
        _availableVideoStreamsByCodec = getStreamByCodec(playInfo.videoStreams, playInfo.videoStreams.first.codec);
      }
    } else {
      _useFallbackCodec = false;
    }

    _availableAudioStreamsByCodec = playInfo.audioStreams;
  }

  Future<void> switchQuality({MediaStream? video, MediaStream? audio}) async {
    if (_disposed) return;
    if (video == _state.videoStream && audio == _state.audioStream) {
      return;
    }

    bool restorePlaying;
    Duration restorePosition;
    if (_state.videoStream != null || _state.audioStream != null) {
      restorePlaying = controller.state.playing;
      restorePosition = controller.state.position;
    } else {
      restorePlaying = true;
      restorePosition = .zero;
    }

    final future = controller.open(
      video: video != null ? Media(_getNextUrl(video)) : null,
      audio: audio != null ? Media(_getNextUrl(audio)) : null,
      initPosition: restorePosition != .zero ? restorePosition : null,
    );

    final newState = _state.copyWith(videoStream: video, audioStream: audio);
    if (_state.videoStream != newState.videoStream) {
      _stream._videoStreamController.add(video);
    }
    if (_state.audioStream != newState.audioStream) {
      _stream._audioStreamController.add(audio);
    }
    _state = newState;

    _log.i('new quality: video=$video, audio=$audio');
    await future;
    if (!_disposed && restorePlaying) controller.play();
  }

  void _onPreferredCodecChanged(CodecEnum event) {
    if (_disposed) return;
    _reloadAvailableStreams();

    final newStream = _findClosestQuality(_availableVideoStreamsByCodec, videoQuality);
    switchQuality(video: newStream, audio: state.audioStream);
  }

  void _onFallbackCodecChanged(CodecEnum event) {
    if (_disposed) return;
    if (_useFallbackCodec) {
      _reloadAvailableStreams();

      final newStream = _findClosestQuality(_availableVideoStreamsByCodec, videoQuality);
      switchQuality(video: newStream, audio: state.audioStream);
    }
  }

  String getQualityDisplayName(int id) => switch (id) {
    // video
    129 => 'HDR Vivid',
    127 => '4320P',
    126 => 'DolbyVision',
    125 => 'HDR',
    120 => '2160P',
    116 => '1080P60',
    112 => '1080P+',
    100 => 'AI修复',
    80 => '1080P',
    74 => '720P+',
    64 => '720P',
    32 => '480P',
    16 => '360P',
    6 => '240P',
    // audio
    40251 => 'Hi-Res',
    40250 => 'DolbyAtmos',
    // ??? => '320K', // 疑似有 320K 的音频流，但我始终没找到测试视频
    30280 => '192K',
    30232 => '132K',
    30216 => '64K',
    _ => 'Unknown quality',
  };

  String? getQualityDisplaySubtitle(int id) => switch (id) {
    // video
    127 => '8K',
    120 => '4K',
    112 => '更高码率',
    116 => '更高帧率',
    // audio
    40251 => '无损',
    40250 => '无损',
    _ => null,
  };

  final Map<MediaStream, int> _mediaUrlToIndexMap = {};

  bool _hasNextUrl(MediaStream media) {
    final index = _mediaUrlToIndexMap[media] ?? 0;
    if (index >= media.urls.length - 1) {
      return false;
    }

    return true;
  }

  /// 从给定的 MediaStream.urls 中依次给出 url，调用后会使计数器 +1，
  /// 找不到则抛出错误，使用 _hasNextUrl 提前检查是否存在下一个可用 url
  String _getNextUrl(MediaStream media) {
    final index = _mediaUrlToIndexMap[media] ?? 0;
    return media.urls[index + 1];
  }
}

class BiliQualityState {
  final MediaStream? videoStream;
  final MediaStream? audioStream;

  const BiliQualityState({this.videoStream, this.audioStream});

  BiliQualityState copyWith({
    MediaStream? videoStream,
    MediaStream? audioStream,
  }) {
    return BiliQualityState(
      videoStream: videoStream ?? this.videoStream,
      audioStream: audioStream ?? this.audioStream,
    );
  }
}

class BiliQualityStream {
  final StreamController<MediaStream?> _videoStreamController = StreamController.broadcast();
  final StreamController<MediaStream?> _audioStreamController = StreamController.broadcast();

  late final Stream<MediaStream?> videoStream = _videoStreamController.stream;
  late final Stream<MediaStream?> audioStream = _audioStreamController.stream;

  bool _disposed = false;

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _videoStreamController.close();
    _audioStreamController.close();
  }
}
