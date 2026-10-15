import 'dart:math';

import 'package:better_bilibili/domain/models/bilibili/danmaku.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';

class LaunchedDanmaku {
  final Danmaku data;
  final TextPainter painter;
  double left;
  double top;
  double age;
  _Track? track;

  LaunchedDanmaku({
    required this.data,
    required this.painter,
    required this.left,
    required this.top,
    this.age = 0,
    this.track,
  });

  double get width => painter.width;
  double get height => painter.height;
  double get right => left + width;
  double get bottom => top + painter.height;
}

class LaunchedAdvancedDanmaku {
  final Danmaku data;
  final TextPainter painter;
  double age;
  Offset position;
  double alpha;

  ExtraAnimation get extra => data.extra!;

  LaunchedAdvancedDanmaku({
    required this.data,
    required this.painter,
    required this.age,
    required this.position,
    required this.alpha,
  });

  double get currentAlpha {
    if (age >= extra.alphaDuration.inMilliseconds) return extra.endAlpha;

    final double t = age / extra.alphaDuration.inMilliseconds;
    return extra.beginAlpha + (extra.endAlpha - extra.beginAlpha) * t;
  }

  Offset getCurrentPosition(Size viewPortSize) {
    final double moveAge = age - extra.translationStartDelay.inMilliseconds;

    double currentXScale = extra.beginX;
    double currentYScale = extra.beginY;

    if (moveAge > 0 && moveAge < extra.translationDuration.inMilliseconds) {
      double t = moveAge / extra.translationDuration.inMilliseconds;
      if (extra.isQuadraticEaseOut) {
        t = 1 - (1 - t) * (1 - t);
      }
      currentXScale = extra.beginX + (extra.endX - extra.beginX) * t;
      currentYScale = extra.beginY + (extra.endY - extra.beginY) * t;
    } else if (moveAge >= extra.translationDuration.inMilliseconds) {
      currentXScale = extra.endX;
      currentYScale = extra.endY;
    }

    return Offset(currentXScale * viewPortSize.width, currentYScale * viewPortSize.height);
  }

  bool get isDead => age >= extra.duration.inMilliseconds;
}

/// 弹幕每秒经过多少像素
const gBaseScrollSpeed = 150.0;

/// 滚动弹幕无法在原位发射时最多允许延后多少像素发射
const gMaxDelayDistance = 300;

/// 轨道之间的间距
const gTrackGap = 4.0;

/// 弹幕之间的间距
const gItemGap = 30;

/// 固定弹幕存活时间
const gFixedDanmakuSurvivalTime = Duration(seconds: 5);

class _Track {
  final List<LaunchedDanmaku> _items = [];
  double _height = 0;

  List<LaunchedDanmaku> get items => List.unmodifiable(_items);
  double get height => _height;

  void addItem(LaunchedDanmaku item) {
    _items.add(item);
    if (item.height > _height) {
      _height = item.height;
    }
  }

  void removeItem(LaunchedDanmaku item) {
    _items.remove(item);
    if (item.height == _height) {
      _calcNewMaximum();
    }
  }

  void clear() {
    _items.clear();
    _height = 0;
  }

  void _calcNewMaximum() {
    if (_items.isEmpty) {
      _height = 0;
      return;
    }
    _height = _items.reduce((curr, next) => curr.height > next.height ? curr : next).height;
  }
}

class _ControllerState {
  bool showScroll = true;
  bool showTop = true;
  bool showBottom = true;
  bool showAdvanced = true;
  double displayArea = 1.0;
  double fixedDisplayArea = 1.0;
  // 字体大小倍率
  double fontSize = 1.0;
  double scrollSpeed = gBaseScrollSpeed;
  double opacity = 1.0;
  bool carnivalMode = false;
  Size viewPortSize = Size.zero;
  bool duplicateMerge = false;
}

class DanmakuController extends SafeChangeNotifier {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'DanmakuController'));

  final _ControllerState _state = _ControllerState();
  final List<_Module> _modules = [];
  late final _ReplicationCoordinator _coordinator;
  late final _ScrollDanmakuModule _scrollModule;
  late final _TopDanmakuModule _topModule;
  late final _BottomDanmakuModule _bottomModule;
  late final _AdvancedDanmakuModule _advancedModule;

  DanmakuController({
    bool? showScroll,
    bool? showTop,
    bool? showBottom,
    bool? showAdvanced,
    double? displayArea,
    double? fixedDisplayArea,
    double? fontSize,
    double? scrollSpeed,
    double? opacity,
    bool? carnivalMode,
    bool? duplicateMerge,
  }) {
    if (showScroll != null) _state.showScroll = showScroll;
    if (showTop != null) _state.showTop = showTop;
    if (showBottom != null) _state.showBottom = showBottom;
    if (showAdvanced != null) _state.showAdvanced = showAdvanced;
    if (displayArea != null) _state.displayArea = displayArea;
    if (fixedDisplayArea != null) _state.fixedDisplayArea = fixedDisplayArea;
    if (fontSize != null) _state.fontSize = fontSize;
    if (scrollSpeed != null) _state.scrollSpeed = scrollSpeed * gBaseScrollSpeed;
    if (opacity != null) _state.opacity = opacity;
    if (carnivalMode != null) _state.carnivalMode = carnivalMode;
    if (duplicateMerge != null) _state.duplicateMerge = duplicateMerge;

    _scrollModule = _ScrollDanmakuModule(state: _state, preLaunch: onPreLaunchScroll);
    _topModule = _TopDanmakuModule(state: _state, preLaunch: onPreLaunchScroll);
    _bottomModule = _BottomDanmakuModule(state: _state, preLaunch: onPreLaunchScroll);
    _advancedModule = _AdvancedDanmakuModule(state: _state);
    _modules.addAll([_scrollModule, _topModule, _bottomModule, _advancedModule]);

    _coordinator = _ReplicationCoordinator(state: _state, topModule: _topModule);
  }

  Duration _currentPosition = Duration.zero;

  void load(List<Danmaku> data) {
    _log.i('load danmaku length=${data.length}');
    for (final item in _modules) {
      item.load(data);
    }
    _coordinator.load(data);

    if (_state.viewPortSize != Size.zero) {
      _updatePosition(_currentPosition.inMilliseconds);
      notifyListeners();
    }
  }

  void onVideoPositionChanged(Duration newPosition, {bool notify = true}) {
    _currentPosition = newPosition;
    if (_state.viewPortSize == Size.zero) return;

    final time = newPosition.inMilliseconds;
    _updatePosition(time);
    if (notify) notifyListeners();
  }

  void onVideoSeek(Duration newPosition) {
    _log.i('onVideoSeek: $newPosition');
    _currentPosition = newPosition;

    for (final item in _modules) {
      item.onSeek(newPosition);
    }

    if (_state.viewPortSize != Size.zero) {
      _updatePosition(newPosition.inMilliseconds);
    }
    notifyListeners();
  }

  void onTick(Duration delta) {
    if (_state.viewPortSize == Size.zero) return;

    final deltaTime = delta.inMilliseconds;
    if (deltaTime <= 0) return;

    bool needRepaint = false;
    for (final item in _modules) {
      if (item.onTick(deltaTime)) {
        needRepaint = true;
      }
    }
    if (needRepaint) notifyListeners();
  }

  void _updatePosition(int time) {
    _coordinator.currentPosition = time;

    if (_state.showScroll) _scrollModule.onPosition(time);
    if (_state.showTop) _topModule.onPosition(time);
    if (_state.showBottom) _bottomModule.onPosition(time);
    if (_state.showAdvanced) _advancedModule.onPosition(time);
  }

  void onPaint(Canvas canvas, Size size) {
    for (final item in _modules) {
      item.onPaint(canvas, size);
    }
  }

  void setViewPortSize(Size newSize) {
    if (newSize == _state.viewPortSize) return;
    _state.viewPortSize = newSize;

    for (final i in _modules) {
      i.onSize(newSize);
    }
  }

  void setFontSize(double newSize) {
    _state.fontSize = newSize;
    notifyListeners();
  }

  void setScrollSpeed(double rate) {
    _state.scrollSpeed = gBaseScrollSpeed * rate;
    notifyListeners();
  }

  void setOpacity(double newValue) {
    _state.opacity = newValue;
    notifyListeners();
  }

  void setCarnivalMode(bool newValue) {
    _state.carnivalMode = newValue;
    notifyListeners();
  }

  void setShowScroll(bool newValue) {
    if (_state.showScroll == newValue) return;
    _state.showScroll = newValue;

    if (!newValue) {
      _scrollModule.clear();
    } else if (_state.viewPortSize != Size.zero) {
      _scrollModule.onPosition(_currentPosition.inMilliseconds);
    }
    notifyListeners();
  }

  void setShowTop(bool newValue) {
    if (_state.showTop == newValue) return;
    _state.showTop = newValue;

    if (!newValue) {
      _topModule.clear();
    } else if (_state.viewPortSize != Size.zero) {
      _topModule.onPosition(_currentPosition.inMilliseconds);
    }
    notifyListeners();
  }

  void setShowBottom(bool newValue) {
    if (_state.showBottom == newValue) return;
    _state.showBottom = newValue;

    if (!newValue) {
      _bottomModule.clear();
    } else if (_state.viewPortSize != Size.zero) {
      _bottomModule.onPosition(_currentPosition.inMilliseconds);
    }
    notifyListeners();
  }

  void setShowAdvanced(bool newValue) {
    if (_state.showAdvanced == newValue) return;
    _state.showAdvanced = newValue;

    if (!newValue) {
      _advancedModule.clear();
    } else if (_state.viewPortSize != Size.zero) {
      _advancedModule.onPosition(_currentPosition.inMilliseconds);
    }
    notifyListeners();
  }

  void setDuplicateMerge(bool newValue) {
    _state.duplicateMerge = newValue;
    notifyListeners();
  }

  void setDisplayArea(double newValue) {
    _state.displayArea = newValue;
    notifyListeners();
  }

  void setFixedDisplayArea(double newValue) {
    _state.fixedDisplayArea = newValue;
    notifyListeners();
  }

  bool onPreLaunchScroll(Danmaku danmaku) {
    return _coordinator.onPreLaunchScroll(danmaku);
  }
}

abstract interface class _Module {
  void load(List<Danmaku> data);
  void onSize(Size size);
  void onPosition(int time);
  void onSeek(Duration position);
  bool onTick(int deltaTime);
  void clear();
  void onPaint(Canvas canvas, Size size);
}

class _ScrollDanmakuModule implements _Module {
  final _ControllerState state;
  final bool Function(Danmaku)? preLaunch;

  _ScrollDanmakuModule({required this.state, this.preLaunch});

  final List<LaunchedDanmaku> launchedList = [];
  final List<Danmaku> unlaunchedList = [];
  final List<Danmaku> disposedList = [];

  final List<_Track> tracks = [];

  @override
  void load(List<Danmaku> data) {
    unlaunchedList.addAll(data.where((v) => v.type == .scroll));
    unlaunchedList.sort((a, b) => a.time - b.time);
  }

  @override
  void onSize(Size size) {
    Set<_Track> disposeTrackSet = {};
    Set<LaunchedDanmaku> disposeDankamuSet = {};

    double height = 0;
    for (final item in tracks) {
      if (item.height + height > size.height) {
        disposeTrackSet.add(item);
        disposedList.addAll(item.items.map((v) => v.data));
        disposeDankamuSet.addAll(item.items);
      }
      height += item.height + gTrackGap;
    }

    tracks.removeWhere(disposeTrackSet.contains);
    launchedList.removeWhere(disposeDankamuSet.contains);
  }

  LaunchedDanmaku? tryAssignTrack(int time, Danmaku item, TextPainter painter, [bool random = false]) {
    final survivalTime = time - item.time;
    final possibleLeft = state.viewPortSize.width - (survivalTime / 1000) * state.scrollSpeed + gItemGap;

    if (random) {
      final trackIndex = Random().nextInt(tracks.length);
      final track = tracks[trackIndex];

      double top = 0;
      for (final i in tracks) {
        if (i == track) {
          break;
        } else {
          top += i.height + gTrackGap;
        }
      }

      final launchedDanmaku = LaunchedDanmaku(
        data: item,
        painter: painter,
        left: possibleLeft,
        top: top,
        track: track,
      );
      track.addItem(launchedDanmaku);
      return launchedDanmaku;
    }

    double top = 0;
    for (final track in tracks) {
      if (top + painter.height > state.viewPortSize.height * state.displayArea) {
        return null;
      }

      final lastRight = track.items.lastOrNull?.right ?? 0;

      if (track == tracks.last && top + painter.height > state.viewPortSize.height) {
        return null;
      }

      if (possibleLeft < lastRight) {
        final newLeft = lastRight + gItemGap;
        if (newLeft <= possibleLeft + gMaxDelayDistance) {
          final launchedDanmaku = LaunchedDanmaku(
            data: item,
            painter: painter,
            left: newLeft,
            top: top,
            track: track,
          );
          track.addItem(launchedDanmaku);
          return launchedDanmaku;
        }
      } else {
        final launchedDanmaku = LaunchedDanmaku(
          data: item,
          painter: painter,
          left: possibleLeft,
          top: top,
          track: track,
        );
        track.addItem(launchedDanmaku);
        return launchedDanmaku;
      }

      top += track.height + gTrackGap;
    }

    return null;
  }

  @override
  void onPosition(int time) {
    final double scrollDanmakuMaxTravelDistance = state.viewPortSize.width + 2000 * (state.scrollSpeed);
    final int scrollDanmakuMaxSurvivalTime = (scrollDanmakuMaxTravelDistance / (state.scrollSpeed / 1000)).ceil();

    Set<Danmaku> launchedSet = {};

    for (final item in unlaunchedList) {
      if (item.time > time) {
        break;
      }

      launchedSet.add(item);

      // 超时
      if (time - item.time > scrollDanmakuMaxSurvivalTime) {
        disposedList.add(item);
        continue;
      }

      // 被拦截
      if (preLaunch != null && !preLaunch!(item)) {
        disposedList.add(item);
        continue;
      }

      final color = item.color.withAlpha((255 * state.opacity).toInt());
      final shadowColor = Color(0xFF000000).withAlpha((255 * state.opacity).toInt());
      final painter = TextPainter(
        text: TextSpan(
          text: item.text,
          style: TextStyle(
            fontSize: item.size.toDouble() * state.fontSize,
            color: color,
            height: 1.2,
            shadows: [
              Shadow(offset: Offset(1, 1), blurRadius: 2, color: shadowColor),
              Shadow(offset: Offset(0, 0), blurRadius: 1, color: shadowColor),
            ],
          ),
        ),
        textDirection: .ltr,
      )..layout();

      LaunchedDanmaku? launchedDanmaku = tryAssignTrack(time, item, painter);

      if (launchedDanmaku == null) {
        final totalTrackHeight = tracks.fold(0.0, (sum, element) => sum + element.height + gTrackGap);

        // 未超出底部且未超出设定区域
        if (totalTrackHeight + painter.height <= state.viewPortSize.height * state.displayArea) {
          tracks.add(_Track());
          launchedDanmaku = tryAssignTrack(time, item, painter);
        } else if (state.carnivalMode) {
          launchedDanmaku = tryAssignTrack(time, item, painter, true);
        }
      }

      if (launchedDanmaku == null) {
        disposedList.add(item);
      } else {
        launchedList.add(launchedDanmaku);
      }
    }

    unlaunchedList.removeWhere(launchedSet.contains);
  }

  @override
  void onSeek(Duration position) => clear();

  @override
  void clear() {
    unlaunchedList.addAll(launchedList.map((v) => v.data));
    launchedList.clear();

    unlaunchedList.addAll(disposedList);
    disposedList.clear();

    tracks.clear();
    unlaunchedList.sort((a, b) => a.time - b.time);
  }

  @override
  bool onTick(int deltaTime) {
    bool needRepaint = launchedList.isNotEmpty;

    Set<LaunchedDanmaku> disposeSet = {};
    for (final item in launchedList) {
      item.left -= state.scrollSpeed * (deltaTime / 1000.0);
      if (item.left + item.width < 0) {
        disposeSet.add(item);
        disposedList.add(item.data);
      }
    }

    for (final item in disposeSet) {
      launchedList.remove(item);
      item.track?.removeItem(item);
    }

    return needRepaint;
  }

  @override
  void onPaint(Canvas canvas, Size size) {
    for (final item in launchedList) {
      item.painter.paint(canvas, Offset(item.left, item.top));
    }
  }
}

// 提供 painter 和递增方法
// 递增时检查是否存在相同弹幕，如果存在则对应 counter + 1，并触发重绘
// 否则尝试新增一个 item
//
// 新增 item 需要检查视口宽度是否足够，足够则新增并触发重绘，否则跳过
class _CounterTrack {
  final _ControllerState state;
  final VoidCallback? afterPaint;

  _CounterTrack({required this.state, this.afterPaint});

  final Map<String, _CounterDanmaku> counterToItemMap = {};
  TextPainter? painter;
  // 因为宽度不足而被忽略的列表，防止重复检查
  final List<String> ignoreList = [];

  List<_CounterDanmaku> get items => List.unmodifiable(counterToItemMap.values);
  double get width => painter?.width ?? 0;
  double get height => counterToItemMap.isEmpty ? 0 : painter?.height ?? 0;
  double get left => state.viewPortSize.width / 2 - width / 2;
  double get top => 0;

  void incrementCounter(Danmaku danmaku) {
    if (counterToItemMap.containsKey(danmaku.cleanText)) {
      counterToItemMap.update(danmaku.cleanText, (v) {
        v.count++;
        v.age = 0;
        return v;
      });
      _rePaint();
    } else {
      _tryAppendItem(danmaku);
    }
  }

  void clear() {
    counterToItemMap.clear();
    painter?.dispose();
    painter = null;
  }

  void _rePaint() {
    if (counterToItemMap.isEmpty) {
      painter?.dispose();
      painter = null;
      afterPaint?.call();
    }

    final color = Color(0xFFFFFFFF).withAlpha((255 * state.opacity).toInt());
    final shadowColor = Color(0xFF000000).withAlpha((100 * state.opacity).toInt());

    final List<InlineSpan> spans = [];
    for (final item in counterToItemMap.entries) {
      spans.add(TextSpan(text: '  '));
      spans.add(TextSpan(text: '${item.value.text} x${item.value.count}'));
    }

    final newPainter = TextPainter(
      text: TextSpan(
        children: spans,
        style: TextStyle(
          fontSize: 28,
          // fontWeight: .bold,
          color: color,
          height: 1.5,
          shadows: [
            Shadow(offset: Offset(1, 1), blurRadius: 2, color: shadowColor),
            Shadow(offset: Offset(0, 0), blurRadius: 1, color: shadowColor),

            // border
            Shadow(offset: Offset(-1, -1), blurRadius: 0, color: shadowColor),
            Shadow(offset: Offset(0, -1), blurRadius: 0, color: shadowColor),
            Shadow(offset: Offset(1, -1), blurRadius: 0, color: shadowColor),
            Shadow(offset: Offset(-1, 0), blurRadius: 0, color: shadowColor),
            Shadow(offset: Offset(1, 0), blurRadius: 0, color: shadowColor),
            Shadow(offset: Offset(-1, 1), blurRadius: 0, color: shadowColor),
            Shadow(offset: Offset(0, 1), blurRadius: 0, color: shadowColor),
            Shadow(offset: Offset(1, 1), blurRadius: 0, color: shadowColor),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter?.dispose();
    painter = newPainter;

    afterPaint?.call();
  }

  void _tryAppendItem(Danmaku danmaku) {
    assert(!counterToItemMap.containsKey(danmaku.cleanText));

    if (ignoreList.contains(danmaku.cleanText)) {
      return;
    }

    final tempPainter = TextPainter(
      text: TextSpan(
        text: '${danmaku.text} x1',
        style: TextStyle(fontSize: 28, fontWeight: .bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    if (width + tempPainter.width > state.viewPortSize.width) {
      ignoreList.add(danmaku.cleanText);
    } else {
      counterToItemMap[danmaku.cleanText] = _CounterDanmaku(data: danmaku)..count = 1;
      _rePaint();
    }
  }

  void onTick(int deltaTime) {
    Set<String> disposeSet = {};
    for (final item in counterToItemMap.values) {
      if (item.age > gMergeTimeout.inMilliseconds) {
        disposeSet.add(item.cleanText);
      } else {
        item.age += deltaTime;
      }
    }
    counterToItemMap.removeWhere((key, value) => disposeSet.contains(key));

    if (disposeSet.isNotEmpty) {
      _rePaint();
      ignoreList.clear();
    }
  }
}

class _CounterDanmaku {
  final Danmaku data;
  double age = 0;
  int count = 0;

  _CounterDanmaku({required this.data});

  String get text => data.text;
  String get cleanText => data.cleanText;
}

class _TopDanmakuModule implements _Module {
  final _ControllerState state;
  late final _CounterTrack counterTrack;
  final bool Function(Danmaku)? preLaunch;

  _TopDanmakuModule({required this.state, this.preLaunch}) {
    counterTrack = _CounterTrack(state: state, afterPaint: onAfterPaint);
  }

  final List<LaunchedDanmaku> launchedList = [];
  final List<Danmaku> unlaunchedList = [];
  final List<Danmaku> disposedList = [];

  @override
  void load(List<Danmaku> data) {
    unlaunchedList.addAll(data.where((v) => v.type == .top));
    unlaunchedList.sort((a, b) => a.time - b.time);
  }

  @override
  void onSize(Size size) {
    final Set<LaunchedDanmaku> disposeSet = {};
    for (final item in launchedList) {
      if (item.bottom > size.height) {
        disposeSet.add(item);
        disposedList.add(item.data);
        continue;
      }

      item.left = size.width / 2 - item.width / 2;
    }
    launchedList.removeWhere(disposeSet.contains);
  }

  @override
  void onPosition(int time) {
    Set<Danmaku> launchedSet = {};

    for (final item in unlaunchedList) {
      if (item.time > time) {
        break;
      }

      launchedSet.add(item);

      // 超时
      if (time > item.time + gFixedDanmakuSurvivalTime.inMilliseconds) {
        disposedList.add(item);
        continue;
      }

      // 被拦截
      if (preLaunch != null && !preLaunch!(item)) {
        disposedList.add(item);
        continue;
      }

      final color = item.color.withAlpha((255 * state.opacity).toInt());
      final shadowColor = Color(0xFF000000).withAlpha((255 * state.opacity).toInt());
      final painter = TextPainter(
        text: TextSpan(
          text: item.text,
          style: TextStyle(
            fontSize: item.size.toDouble() * state.fontSize,
            color: color,
            height: 1.2,
            shadows: [
              Shadow(offset: Offset(1, 1), blurRadius: 2, color: shadowColor),
              Shadow(offset: Offset(0, 0), blurRadius: 1, color: shadowColor),
            ],
          ),
        ),
        textDirection: .ltr,
      )..layout();

      double top = 0 + counterTrack.height + (counterTrack.height > 0 ? gTrackGap : 0);
      final double maxBottom = state.viewPortSize.height * state.fixedDisplayArea;

      for (final track in launchedList) {
        double bottom = top + painter.height;
        if (bottom + gTrackGap <= track.top) {
          break;
        }
        if (top < track.bottom + gTrackGap) {
          top = track.bottom + gTrackGap;
        }
      }

      if (top + painter.height <= maxBottom) {
        // _log.i('launch danmaku: TOP ${item.time} ${item.text}');
        final launchedDanmaku = LaunchedDanmaku(
          data: item,
          painter: painter,
          left: state.viewPortSize.width / 2 - painter.width / 2,
          top: top,
          age: (time - item.time).toDouble(),
        );

        launchedList.add(launchedDanmaku);
        launchedList.sort((a, b) => a.top.compareTo(b.top));
      } else if (state.carnivalMode) {
        final rand = launchedList[Random().nextInt(launchedList.length)];
        final launchedDanmaku = LaunchedDanmaku(
          data: item,
          painter: painter,
          left: state.viewPortSize.width / 2 - painter.width / 2,
          top: rand.top,
          age: (time - item.time).toDouble(),
        );

        launchedList.add(launchedDanmaku);
        launchedList.sort((a, b) => a.top.compareTo(b.top));
      }
    }

    unlaunchedList.removeWhere(launchedSet.contains);
  }

  @override
  void onSeek(Duration position) => clear();

  @override
  bool onTick(int deltaTime) {
    bool needRepaint = launchedList.isNotEmpty || counterTrack.painter != null;

    Set<LaunchedDanmaku> disposeSet = {};
    for (final item in launchedList) {
      item.age += deltaTime;
      if (item.age >= gFixedDanmakuSurvivalTime.inMilliseconds) {
        disposeSet.add(item);
        disposedList.add(item.data);
      }
    }
    launchedList.removeWhere(disposeSet.contains);

    counterTrack.onTick(deltaTime);

    return needRepaint;
  }

  @override
  void clear() {
    unlaunchedList.addAll(launchedList.map((v) => v.data));
    launchedList.clear();

    unlaunchedList.addAll(disposedList);
    disposedList.clear();

    unlaunchedList.sort((a, b) => a.time - b.time);

    counterTrack.clear();
  }

  @override
  void onPaint(Canvas canvas, Size size) {
    if (counterTrack.painter != null) {
      counterTrack.painter!.paint(canvas, Offset(counterTrack.left, counterTrack.top));
    }

    for (final item in launchedList) {
      item.painter.paint(canvas, Offset(item.left, item.top));
    }
  }

  double lastCounterTrackHeight = 0;

  void onAfterPaint() {
    if (lastCounterTrackHeight == counterTrack.height) {
      return;
    }

    lastCounterTrackHeight = counterTrack.height;

    final Set<LaunchedDanmaku> disposeSet = {};
    for (final item in launchedList) {
      if (counterTrack.height > 0) {
        item.top += counterTrack.height + gTrackGap;
      }

      if (item.bottom > state.viewPortSize.height * state.fixedDisplayArea) {
        disposeSet.add(item);
        disposedList.add(item.data);
      }
    }
    launchedList.removeWhere(disposeSet.contains);
  }
}

class _BottomDanmakuModule implements _Module {
  final _ControllerState state;
  final bool Function(Danmaku)? preLaunch;

  _BottomDanmakuModule({required this.state, this.preLaunch});

  final List<LaunchedDanmaku> launchedList = [];
  final List<Danmaku> unlaunchedList = [];
  final List<Danmaku> disposedList = [];

  @override
  void load(List<Danmaku> data) {
    unlaunchedList.addAll(data.where((v) => v.type == .bottom));
    unlaunchedList.sort((a, b) => a.time - b.time);
  }

  @override
  void onSize(Size size) {
    final Set<LaunchedDanmaku> disposeSet = {};
    for (final item in launchedList) {
      if (item.bottom > size.height) {
        disposeSet.add(item);
        disposedList.add(item.data);
        continue;
      }

      item.left = size.width / 2 - item.width / 2;
    }
    launchedList.removeWhere(disposeSet.contains);
  }

  @override
  void onPosition(int time) {
    Set<Danmaku> launchedSet = {};

    for (final item in unlaunchedList) {
      if (item.time > time) {
        break;
      }

      launchedSet.add(item);

      // 超时
      if (time > item.time + gFixedDanmakuSurvivalTime.inMilliseconds) {
        disposedList.add(item);
        continue;
      }

      // 被拦截
      if (preLaunch != null && !preLaunch!(item)) {
        disposedList.add(item);
        continue;
      }

      final color = item.color.withAlpha((255 * state.opacity).toInt());
      final shadowColor = Color(0xFF000000).withAlpha((255 * state.opacity).toInt());
      final painter = TextPainter(
        text: TextSpan(
          text: item.text,
          style: TextStyle(
            fontSize: item.size.toDouble() * state.fontSize,
            color: color,
            height: 1.2,
            shadows: [
              Shadow(offset: Offset(1, 1), blurRadius: 2, color: shadowColor),
              Shadow(offset: Offset(0, 0), blurRadius: 1, color: shadowColor),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      double currentBottom = state.viewPortSize.height;
      final double minTop = state.viewPortSize.height * (1 - state.fixedDisplayArea);

      for (final track in launchedList) {
        double currentTop = currentBottom - painter.height;
        if (currentTop - gTrackGap >= track.bottom) {
          break;
        }
        if (currentBottom > track.top - gTrackGap) {
          currentBottom = track.top - gTrackGap;
        }
      }

      double finalTop = currentBottom - painter.height;
      if (finalTop >= minTop) {
        // _log.i('launch danmaku: BOTTOM ${item.time} ${item.text}');
        final launchedDanmaku = LaunchedDanmaku(
          data: item,
          painter: painter,
          left: state.viewPortSize.width / 2 - painter.width / 2,
          top: finalTop,
          age: (time - item.time).toDouble(),
        );

        launchedList.add(launchedDanmaku);
        launchedList.sort((a, b) => b.bottom.compareTo(a.bottom));
      } else if (state.carnivalMode) {
        final rand = launchedList[Random().nextInt(launchedList.length)];
        final launchedDanmaku = LaunchedDanmaku(
          data: item,
          painter: painter,
          left: state.viewPortSize.width / 2 - painter.width / 2,
          top: rand.top,
          age: (time - item.time).toDouble(),
        );

        launchedList.add(launchedDanmaku);
        launchedList.sort((a, b) => a.top.compareTo(b.top));
      }
    }

    unlaunchedList.removeWhere(launchedSet.contains);
  }

  @override
  void onSeek(Duration position) => clear();

  @override
  bool onTick(int deltaTime) {
    bool needRepaint = launchedList.isNotEmpty;

    Set<LaunchedDanmaku> disposeSet = {};
    for (final item in launchedList) {
      item.age += deltaTime;
      if (item.age >= gFixedDanmakuSurvivalTime.inMilliseconds) {
        disposeSet.add(item);
        disposedList.add(item.data);
      }
    }
    launchedList.removeWhere(disposeSet.contains);

    return needRepaint;
  }

  @override
  void clear() {
    unlaunchedList.addAll(launchedList.map((v) => v.data));
    launchedList.clear();

    unlaunchedList.addAll(disposedList);
    disposedList.clear();

    unlaunchedList.sort((a, b) => a.time - b.time);
  }

  @override
  void onPaint(Canvas canvas, Size size) {
    for (final item in launchedList) {
      item.painter.paint(canvas, Offset(item.left, item.top));
    }
  }
}

class _AdvancedDanmakuModule implements _Module {
  final _ControllerState state;

  _AdvancedDanmakuModule({required this.state});

  final List<LaunchedAdvancedDanmaku> launchedList = [];
  final List<Danmaku> unlaunchedList = [];
  final List<Danmaku> disposedList = [];

  @override
  void load(List<Danmaku> data) {
    unlaunchedList.addAll(data.where((v) => v.type == .advanced));
    unlaunchedList.sort((a, b) => a.time - b.time);
  }

  @override
  void onSize(Size size) {}

  @override
  void onPosition(int time) {
    Set<Danmaku> disposeSet = {};

    for (final item in unlaunchedList) {
      if (time >= item.time) {
        disposeSet.add(item);

        final color = item.color.withAlpha((255 * state.opacity).toInt());
        final shadowColor = Color(0xFF000000).withAlpha((255 * state.opacity).toInt());
        final painter = TextPainter(
          text: TextSpan(
            text: item.text,
            style: TextStyle(
              fontSize: item.size.toDouble() * state.fontSize,
              color: color,
              height: 1.2,
              fontFamily: item.extra?.fontFamily,
              shadows: [
                Shadow(offset: Offset(1, 1), blurRadius: 2, color: shadowColor),
                Shadow(offset: Offset(0, 0), blurRadius: 1, color: shadowColor),

                // border
                Shadow(offset: Offset(-1, -1), blurRadius: 0, color: shadowColor),
                Shadow(offset: Offset(0, -1), blurRadius: 0, color: shadowColor),
                Shadow(offset: Offset(1, -1), blurRadius: 0, color: shadowColor),
                Shadow(offset: Offset(-1, 0), blurRadius: 0, color: shadowColor),
                Shadow(offset: Offset(1, 0), blurRadius: 0, color: shadowColor),
                Shadow(offset: Offset(-1, 1), blurRadius: 0, color: shadowColor),
                Shadow(offset: Offset(0, 1), blurRadius: 0, color: shadowColor),
                Shadow(offset: Offset(1, 1), blurRadius: 0, color: shadowColor),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        if (time < item.time + item.extra!.duration.inMilliseconds) {
          // _log.i('launch danmaku: ADVANCED ${item.time} ${item.text}');
          final launchedDanmaku = LaunchedAdvancedDanmaku(
            data: item,
            painter: painter,
            age: (time - item.time).toDouble(),
            position: Offset.zero,
            alpha: 1,
          );
          launchedList.add(launchedDanmaku);
          launchedDanmaku.position = launchedDanmaku.getCurrentPosition(state.viewPortSize);
        } else {
          disposedList.add(item);
        }
      }
    }

    unlaunchedList.removeWhere(disposeSet.contains);
  }

  @override
  void onSeek(Duration position) => clear();

  @override
  bool onTick(int deltaTime) {
    bool needRepaint = launchedList.isNotEmpty;

    Set<LaunchedAdvancedDanmaku> disposeSet = {};
    for (final item in launchedList) {
      if (item.age >= item.extra.duration.inMilliseconds) {
        // _log.i('dispose danmaku: ADVANCED ${item.data.text} ${item.age}');
        disposeSet.add(item);
        disposedList.add(item.data);
      } else {
        item.age += deltaTime;
        item.position = item.getCurrentPosition(state.viewPortSize);
        item.alpha = item.currentAlpha;
      }
    }
    launchedList.removeWhere(disposeSet.contains);

    return needRepaint;
  }

  @override
  void clear() {
    unlaunchedList.addAll(launchedList.map((v) => v.data));
    launchedList.clear();

    unlaunchedList.addAll(disposedList);
    disposedList.clear();

    unlaunchedList.sort((a, b) => a.time - b.time);
  }

  @override
  void onPaint(Canvas canvas, Size size) {
    for (final item in launchedList) {
      if (item.alpha <= 0) continue;

      final extra = item.extra;

      canvas.save();

      canvas.translate(
        item.position.dx,
        item.position.dy,
      );

      if (extra.rotateY != 0 || extra.rotateZ != 0) {
        final matrix = Matrix4.identity();

        if (extra.rotateY != 0) {
          matrix.rotateY(extra.rotateY * pi / 180);
        }

        if (extra.rotateZ != 0) {
          matrix.rotateZ(extra.rotateZ * pi / 180);
        }

        canvas.transform(matrix.storage);
      }

      item.painter.paint(canvas, Offset.zero);

      canvas.restore();
    }
  }
}

// 每多长时间进行一次统计
const gMergeTimeWindow = Duration(seconds: 5);

// 重复合并阈值
const gMergeThreshold = 20;

// 最多可以触发合并的字符长度
const gMergeMaxLength = 30;

// 计数停止增长后多久销毁
const gMergeTimeout = Duration(seconds: 3);

class _ReplicationCoordinator {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'ScrollDanmakuModule'));

  final _ControllerState state;
  late final _TopDanmakuModule _topDanmakuModule;
  int currentPosition = 0;

  _ReplicationCoordinator({
    required this.state,
    required _TopDanmakuModule topModule,
  }) {
    _topDanmakuModule = topModule;
  }

  final List<Danmaku> scrollDanmakus = [];
  final Map<int, Set<String>> indexToMergeSet = {};

  void load(List<Danmaku> data) {
    scrollDanmakus.addAll(data.where((v) => const [DanmakuType.scroll, DanmakuType.top, DanmakuType.bottom].contains(v.type)));
    scrollDanmakus.sort((a, b) => a.time - b.time);
    reCalculate();
    _log.i('indexToMergeSet: $indexToMergeSet');
  }

  void reCalculate() {
    void updateMergeSetByCounterMap(int index, Map<String, int> counter) {
      for (final item in counter.entries) {
        if (item.value >= gMergeThreshold) {
          indexToMergeSet.update(index, (v) {
            v.add(item.key);
            return v;
          }, ifAbsent: () => {item.key});
        }
      }
    }

    int currentIndex = 0;
    // 统计当前时间块中所有弹幕的出现次数
    final Map<String, int> counterMap = {};

    for (final item in scrollDanmakus) {
      final index = item.time ~/ gMergeTimeWindow.inMilliseconds;

      if (index != currentIndex) {
        updateMergeSetByCounterMap(currentIndex, counterMap);
        counterMap.clear();
        currentIndex = index;
      }

      if (item.text.length <= gMergeMaxLength) {
        counterMap.update(item.cleanText, (v) => ++v, ifAbsent: () => 1);
      }
    }

    if (counterMap.isNotEmpty) {
      updateMergeSetByCounterMap(currentIndex, counterMap);
    }
  }

  bool onPreLaunchScroll(Danmaku danmaku) {
    if (!state.duplicateMerge) return true;
    if (currentPosition - danmaku.time > gMergeTimeout.inMilliseconds) return true;

    final index = danmaku.time ~/ gMergeTimeWindow.inMilliseconds;
    if (indexToMergeSet.containsKey(index) && indexToMergeSet[index]!.contains(danmaku.cleanText)) {
      _topDanmakuModule.counterTrack.incrementCounter(danmaku);
      return false;
    }

    return true;
  }
}
