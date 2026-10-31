import 'package:better_bilibili/utils/bilibili/danmaku_mask_parser.dart';
import 'package:dio/dio.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BiliDanmakuMaskController {
  static const _cacheTimeWindow = Duration(seconds: 3);

  final String maskUrl;

  BiliDanmakuMaskController(this.maskUrl) {
    _getData();
  }

  void dispose() {
    _client.close(force: true);

    for (final value in _pictureInfoBuffer.values) {
      value.picture.dispose();
    }
    _pictureInfoBuffer.clear();
  }

  final Dio _client = Dio();
  DanmakuMask? _data;
  List<DanmakuMaskFrame> _searchIndex = [];

  Future<void> _getData() async {
    final result = await _client.get(maskUrl, options: Options(responseType: .bytes));

    final mask = BiliDanmakuMaskParser.parse(result.data as List<int>);
    _data = mask;

    _searchIndex = List.unmodifiable(mask.segments.expand((segment) => segment.frames));
  }

  final Map<DanmakuMaskFrame, PictureInfo> _pictureInfoBuffer = {};

  void onPosition(Duration event) {
    if (_data == null || !_enabled) return;

    final Set<DanmakuMaskFrame> removeSet = {};
    for (final i in _pictureInfoBuffer.keys) {
      if (i.timestamp < event.inMilliseconds - _cacheTimeWindow.inMilliseconds / 2 ||
          i.timestamp > event.inMilliseconds + _cacheTimeWindow.inMilliseconds / 2) {
        removeSet.add(i);
        _pictureInfoBuffer[i]?.picture.dispose();
      }
    }
    _pictureInfoBuffer.removeWhere((key, value) => removeSet.contains(key));

    final frames = findFramesBetween(
      (event.inMilliseconds - _cacheTimeWindow.inMilliseconds / 2).toInt(),
      (event.inMilliseconds + _cacheTimeWindow.inMilliseconds / 2).toInt(),
    );
    for (final i in frames) {
      _tryPreloadFrame(i);
    }
  }

  final Set<DanmakuMaskFrame> _pendingFrameSet = {};

  Future<void> _tryPreloadFrame(DanmakuMaskFrame frame) async {
    if (_pictureInfoBuffer.containsKey(frame) || _pendingFrameSet.contains(frame)) {
      return;
    }

    _pendingFrameSet.add(frame);

    final pictureInfo = await vg.loadPicture(SvgStringLoader(frame.svgText), null);
    _pictureInfoBuffer[frame] = pictureInfo;

    _pendingFrameSet.remove(frame);
  }

  /// 查找距离给定时间最近的一张遮罩
  PictureInfo? getClosestPicture(Duration position, [int maxDelta = 100]) {
    final timestamp = position.inMilliseconds;

    final frames = _searchIndex;
    var low = 0;
    var high = frames.length;

    while (low < high) {
      final mid = low + ((high - low) >> 1);

      if (frames[mid].timestamp < timestamp) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }

    final frame = low < frames.length ? frames[low] : null;
    if (frame == null) return null;

    if (frame.timestamp - timestamp > maxDelta) {
      return null;
    }

    return _pictureInfoBuffer[frame];
  }

  /// 查找指定时间范围内的所有帧，包含起止时间
  Iterable<DanmakuMaskFrame> findFramesBetween(int startTime, int endTime) sync* {
    if (startTime > endTime) return;

    final start = _lowerBound(startTime);
    final end = _upperBound(endTime);

    for (var i = start; i < end; i++) {
      yield _searchIndex[i];
    }
  }

  /// 查找第一个 timestamp >= 目标值的索引
  int _lowerBound(int timestamp) {
    var low = 0;
    var high = _searchIndex.length;

    while (low < high) {
      final mid = low + ((high - low) >> 1);

      if (_searchIndex[mid].timestamp < timestamp) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }

    return low;
  }

  /// 查找第一个 timestamp > 目标值的索引
  int _upperBound(int timestamp) {
    var low = 0;
    var high = _searchIndex.length;

    while (low < high) {
      final mid = low + ((high - low) >> 1);

      if (_searchIndex[mid].timestamp <= timestamp) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }

    return low;
  }

  bool _enabled = true;

  void enable() {
    _enabled = true;
  }

  void disable() {
    _enabled = false;
  }
}
