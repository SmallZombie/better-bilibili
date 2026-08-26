import 'dart:async';

import 'package:better_bilibili/data/repositories/bilibili/video_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/video_report_history.dart';
import 'package:better_bilibili/domain/models/bilibili/play_info.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/bili_video_player_controller.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:logger/logger.dart';

class BiliHistoryReporter {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'BiliHistoryReporter'));

  final BiliVideoPlayerController controller;
  final VideoRepository videoRepository;

  List<StreamSubscription> substcriptions = [];

  BiliHistoryReporter({
    required this.controller,
    required this.videoRepository,
  }) {
    _duration = controller.playInfo.duration;
    if (controller.state.videoTrack != null) {
      _fileName = getFileName(controller.state.videoTrack!);
    }

    substcriptions.addAll([
      controller.stream.playing.listen(_onPlayChanged),
      controller.stream.position.listen(_onPositionChanged),
      controller.stream.videoTrack.listen(_onVideoTrackChanged),
      controller.stream.seekStart.listen(_onSeekStart),
      controller.stream.seekEnd.listen(_onSeekEnd),
      controller.stream.completed.listen(_onCompleted),
    ]);
  }

  bool _playing = false;
  Timer? _timer;
  int _heartbeatCounter = 0;
  int _firstPlaybackTime = 0;
  Duration _realPlaybackTime = Duration.zero;
  late Duration _duration;
  Duration _position = Duration.zero;
  Duration _maxPosition = Duration.zero;
  String? _fileName;
  bool _isFirstPlay = true;
  // 最后开始播放的位置，用于计算 _realPlaybackTime
  Duration _lastStartPlaybackPositon = Duration.zero;

  bool get playing => _playing;
  Timer? get timer => _timer;
  int get heartbeatCounter => _heartbeatCounter;
  int get firstPlaybackTime => _firstPlaybackTime;
  Duration get realPlaybackTime => _realPlaybackTime;
  Duration get lastStartPlaybackPositon => _lastStartPlaybackPositon;
  Duration get duration => _duration;
  Duration get position => _position;
  Duration get maxPosition => _maxPosition;
  String? get fileName => _fileName;
  bool get isFirstPlay => _isFirstPlay;

  void dispose() {
    _timer?.cancel();

    // 这里与 web 端逻辑相同，退出视频时汇报一次，但如果还没开始过播放则跳过
    if (!_playing && _firstPlaybackTime != 0) {
      updateRealPlaybackTime();
      report(.pause);
    }

    for (final substcription in substcriptions) {
      substcription.cancel();
    }
    substcriptions.clear();
  }

  final StreamController _changeController = StreamController.broadcast();
  late final Stream changeStream = _changeController.stream;

  void _onPlayChanged(bool event) {
    _log.i('onPlayChanged: $event');
    _playing = event;

    if (event) {
      _timer ??= Timer.periodic(const Duration(seconds: 15), (_) {
        _heartbeatCounter++;

        updateRealPlaybackTime();

        report(.heartbeat);
        emitChanged();
      });

      if (_firstPlaybackTime == 0) {
        _firstPlaybackTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      }

      _lastStartPlaybackPositon = _position;

      if (_isFirstPlay) {
        report(.start);
        _isFirstPlay = false;
      } else {
        report(.resume);
      }
      // 这里由于设计问题，播放器需要手动处理自动播放，player 自带的自动播放始终会被设置为 false，
      // 但设置自动播放为 false 时会在一开始触发一次 playing=false，我们需要忽略掉这个事件，
      // 说的好像不太清楚，简单来说就是此类第一次汇报心跳类型必须是 start
    } else if (!_isFirstPlay) {
      _timer?.cancel();
      _timer = null;

      updateRealPlaybackTime();

      if (_position != _duration) {
        report(.pause);
      }
    }

    emitChanged();
  }

  void _onPositionChanged(Duration event) {
    _position = event;
    if (event > _maxPosition) {
      _maxPosition = event;
    }

    emitChanged();
  }

  void _onVideoTrackChanged(MediaTrack event) {
    _log.i('onVideoTrackChanged: $event');

    _fileName = getFileName(event);
    emitChanged();
  }

  void _onSeekStart(Duration event) {
    updateRealPlaybackTime();
    emitChanged();
  }

  void _onSeekEnd(Duration event) {
    _lastStartPlaybackPositon = event;
    emitChanged();
  }

  void _onCompleted(bool event) {
    if (!event) return;

    _log.i('onCompleted');

    updateRealPlaybackTime();
    report(.end);
    _lastStartPlaybackPositon = Duration.zero;

    emitChanged();
  }

  void updateRealPlaybackTime() {
    final watchTime = _position - _lastStartPlaybackPositon;
    if (watchTime < Duration.zero) {
      _log.w('watchTime < 0, this is incorrect, did I forget something? watchTime=$watchTime');
      return;
    }

    _realPlaybackTime += watchTime;
    _lastStartPlaybackPositon = _position;
  }

  String getFileName(MediaTrack track) {
    return Uri.parse(track.url).pathSegments.last;
  }

  Future<void> report(ReportHistoryActionTypeEnum actionType) async {
    if (_fileName == null) return;

    try {
      await videoRepository.reportHistory(
        videoId: controller.playInfo.videoId,
        episodeId: controller.playInfo.episodeId,
        firstPlaybackTime: _firstPlaybackTime,
        contentType: .video,
        actionType: actionType,
        realPlaybackTime: _realPlaybackTime.inSeconds,
        duration: _duration.inSeconds,
        position: _position.inSeconds,
        maxPosition: _maxPosition.inSeconds,
        reportCounter: _heartbeatCounter,
        playInfoSession: controller.playInfo.session,
        playInfoId: controller.playInfo.id,
        videoFileName: _fileName!,
      );
    } catch (e, s) {
      _log.e('heartbeat report failed', error: e, stackTrace: s);
    }
  }

  void emitChanged() {
    _changeController.add(null);
  }
}
