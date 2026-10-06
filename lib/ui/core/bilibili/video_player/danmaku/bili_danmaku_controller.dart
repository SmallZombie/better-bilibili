import 'dart:async';

import 'package:better_bilibili/config/danmaku_config.dart';
import 'package:better_bilibili/data/repositories/bilibili/video_repository/video_repository.dart';
import 'package:better_bilibili/domain/models/bilibili/bilibili.dart';
import 'package:better_bilibili/domain/models/bilibili/danmaku.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/danmaku/danmaku_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/extra_video_controller.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:logger/logger.dart';

/// 提前加载分块的阈值
const _gPreloadThreshold = Duration(seconds: 5);

/// 每次重试时间递增
const _gRetryTimeStep = Duration(seconds: 3);

class Chunk {
  List<Danmaku>? data;
  bool loading;
  int errorCount;
  DateTime nextRetryAt;

  Chunk({
    this.data,
    this.loading = false,
    this.errorCount = 0,
    DateTime? nextRetryAt,
  }) : nextRetryAt = nextRetryAt ?? DateTime.fromMillisecondsSinceEpoch(0);
}

class BiliDanmakuController extends DanmakuController {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'BiliDanmakuController'));

  final BiliContentTypeEnum contentType;
  final String contentId;
  final String episodeId;
  final ExtraVideoController controller;
  final DanmakuConfig config;
  final VideoRepository videoRepository;

  final List<StreamSubscription> _subscriptions = [];

  BiliDanmakuController({
    required this.contentType,
    required this.contentId,
    required this.episodeId,
    required this.controller,
    required this.config,
    required this.videoRepository,
  }) : super(
         showScroll: config.showScroll.value,
         showTop: config.showTop.value,
         showBottom: config.showBottom.value,
         showAdvanced: config.showAdvanced.value,
         displayArea: config.displayArea.value,
         fixedDisplayArea: config.fixedDisplayArea.value,
         scrollSpeed: config.scrollSpeed.value,
         opacity: config.opacity.value,
         carnivalMode: config.carnivalMode.value,
         duplicateMerge: config.duplicateMerge.value,
       ) {
    _subscriptions.addAll([
      controller.stream.position.listen(onPosition),
      controller.stream.playing.listen(onPlaying),
      controller.stream.completed.listen(onCompleted),
      controller.stream.seek.listen(onSeek),

      config.showScroll.stream.listen(super.setShowScroll),
      config.showTop.stream.listen(super.setShowTop),
      config.showBottom.stream.listen(super.setShowBottom),
      config.showAdvanced.stream.listen(super.setShowAdvanced),
      config.displayArea.stream.listen(super.setDisplayArea),
      config.fixedDisplayArea.stream.listen(super.setFixedDisplayArea),
      config.opacity.stream.listen(super.setOpacity),
      config.scrollSpeed.stream.listen(super.setScrollSpeed),
      config.carnivalMode.stream.listen(super.setCarnivalMode),
      config.duplicateMerge.stream.listen(super.setDuplicateMerge),
    ]);

    _initSettings();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    super.dispose();
  }

  void _initSettings() {
    config.enabled.get();
    config.showScroll.get();
    config.showTop.get();
    config.showBottom.get();
    config.showAdvanced.get();
    config.displayArea.get();
    config.fixedDisplayArea.get();
    config.opacity.get();
    config.scrollSpeed.get();
    config.carnivalMode.get();
    config.duplicateMerge.get();
  }

  bool _isVideoEnded = false;

  void onSeek(Duration event) {
    if (!config.enabled.value) return;
    super.onVideoSeek(event);
  }

  final Map<int, Chunk> indexToData = {};

  void onPosition(Duration event) {
    if (!config.enabled.value) return;

    final currentChunkIndex = event.inMinutes ~/ 6 + 1;

    _checkAndFetchChunk(currentChunkIndex);

    final nextChunkIndex = (event + _gPreloadThreshold).inMinutes ~/ 6 + 1;
    if (nextChunkIndex != currentChunkIndex) {
      _checkAndFetchChunk(nextChunkIndex);
    }
  }

  void onCompleted(bool event) {
    if (event) _isVideoEnded = true;
  }

  void onPlaying(bool event) {
    if (event && _isVideoEnded) {
      onSeek(.zero);
      _isVideoEnded = false;
    }
  }

  Future<void> _checkAndFetchChunk(int index) async {
    var chunk = indexToData[index];

    if (chunk == null) {
      chunk = Chunk();
      indexToData[index] = chunk;
    }

    if (chunk.loading || chunk.data != null) return;

    if (DateTime.now().isBefore(chunk.nextRetryAt)) return;

    chunk.loading = true;
    _log.i('start load chunk $index');
    try {
      final data = await videoRepository.getDanmakus(
        index: index,
        videoId: contentId,
        episodeId: episodeId,
        type: contentType,
      );

      final targetChunk = indexToData[index];
      if (targetChunk == null) return;

      switch (data) {
        case Ok(:final value):
          targetChunk.data = value;
          targetChunk.errorCount = 0;
          super.load(value);
          _log.i('chunk $index loaded, length = ${value.length}');
        case Error():
          targetChunk.errorCount++;
          targetChunk.nextRetryAt = DateTime.now().add(_gRetryTimeStep * targetChunk.errorCount);
      }
    } catch (e, s) {
      final retryDelay = _gRetryTimeStep * chunk.errorCount;
      _log.e('chunk load failed, next retry in $retryDelay', error: e, stackTrace: s);
      chunk.errorCount++;
      chunk.nextRetryAt = DateTime.now().add(retryDelay);
    } finally {
      chunk.loading = false;
    }
  }
}
