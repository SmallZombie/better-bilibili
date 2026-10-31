import 'dart:async';
import 'dart:ui';

import 'package:better_bilibili/config/danmaku_config.dart';
import 'package:better_bilibili/data/repositories/bilibili/video_repository/video_repository.dart';
import 'package:better_bilibili/domain/models/bilibili/bilibili.dart';
import 'package:better_bilibili/domain/models/bilibili/danmaku.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/danmaku/bili_danmaku_mask_controller.dart';
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
  final String? maskUrl;

  final List<StreamSubscription> _subscriptions = [];
  BiliDanmakuMaskController? maskController;

  BiliDanmakuController({
    required this.contentType,
    required this.contentId,
    required this.episodeId,
    required this.controller,
    required this.config,
    required this.videoRepository,
    this.maskUrl,
  }) : super(
         showScroll: config.showScroll.value,
         showTop: config.showTop.value,
         showBottom: config.showBottom.value,
         showAdvanced: config.showAdvanced.value,
         displayArea: config.displayArea.value,
         fixedDisplayArea: config.fixedDisplayArea.value,
         fontSize: config.fontSize.value,
         scrollSpeed: config.scrollSpeed.value,
         opacity: config.opacity.value,
         carnivalMode: config.carnivalMode.value,
         duplicateMerge: config.duplicateMerge.value,
       ) {
    _subscriptions.addAll([
      controller.stream.position.listen(_onPosition),
      controller.stream.playing.listen(_onPlaying),
      controller.stream.completed.listen(_onCompleted),
      controller.stream.seek.listen(_onSeek),
      controller.stream.rate.listen(_onRate),

      config.showScroll.stream.listen(super.setShowScroll),
      config.showTop.stream.listen(super.setShowTop),
      config.showBottom.stream.listen(super.setShowBottom),
      config.showAdvanced.stream.listen(super.setShowAdvanced),
      config.displayArea.stream.listen(super.setDisplayArea),
      config.fixedDisplayArea.stream.listen(super.setFixedDisplayArea),
      config.opacity.stream.listen(super.setOpacity),
      config.fontSize.stream.listen(super.setFontSize),
      config.scrollSpeed.stream.listen(_onRate),
      config.carnivalMode.stream.listen(super.setCarnivalMode),
      config.duplicateMerge.stream.listen(super.setDuplicateMerge),
      config.antiOcclusion.stream.listen(_onAntiOcclusion),
    ]);

    if (config.antiOcclusion.value && maskUrl != null) {
      maskController = BiliDanmakuMaskController(maskUrl!);
    }
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    maskController?.dispose();

    super.dispose();
  }

  bool _isVideoEnded = false;

  void _onSeek(Duration event) {
    if (!config.enabled.value) return;
    super.onVideoSeek(event);
  }

  final Map<int, Chunk> indexToData = {};

  void _onPosition(Duration event) {
    if (!config.enabled.value) return;

    final currentChunkIndex = event.inMinutes ~/ 6 + 1;

    _checkAndFetchChunk(currentChunkIndex);

    final nextChunkIndex = (event + _gPreloadThreshold).inMinutes ~/ 6 + 1;
    if (nextChunkIndex != currentChunkIndex) {
      _checkAndFetchChunk(nextChunkIndex);
    }

    if (config.antiOcclusion.value) {
      maskController?.onPosition(event);
    }
  }

  void _onCompleted(bool event) {
    if (event) _isVideoEnded = true;
  }

  void _onPlaying(bool event) {
    if (event && _isVideoEnded) {
      _onSeek(.zero);
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
        case Err():
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

  void _onAntiOcclusion(bool event) {
    if (event && maskUrl != null) {
      maskController ??= BiliDanmakuMaskController(maskUrl!);
      maskController!.enable();
      notifyListeners();
    } else {
      maskController?.disable();
      notifyListeners();
    }
  }

  void _onRate(double event) {
    final videoRate = controller.state.rate;
    super.setPlaybackRate(videoRate);

    if (config.syncPlaybackRate.value) {
      if (videoRate == 1) {
        return super.setScrollSpeed(config.scrollSpeed.value);
      }
      super.setScrollSpeed(config.scrollSpeed.value + videoRate);
    } else {
      super.setScrollSpeed(config.scrollSpeed.value);
    }
  }

  @override
  void onPaint(Canvas canvas, Size size) {
    final mask = config.antiOcclusion.value ? maskController?.getClosestPicture(controller.state.position) : null;

    if (mask != null) {
      final bounds = Offset.zero & size;

      canvas.save();
      canvas.saveLayer(bounds, Paint());
      super.onPaint(canvas, size);

      canvas.saveLayer(
        bounds,
        Paint()..blendMode = BlendMode.dstIn,
      );

      canvas.save();
      canvas.scale(size.width / mask.size.width, size.height / mask.size.height);
      canvas.drawPicture(mask.picture);
      canvas.restore();

      canvas.restore(); // 将遮罩以 dstIn 模式合成到文字图层
      canvas.restore(); // 将处理完的文字图层合成到画布

      canvas.restore(); // 恢复裁剪状态
    } else {
      super.onPaint(canvas, size);
    }
  }
}
