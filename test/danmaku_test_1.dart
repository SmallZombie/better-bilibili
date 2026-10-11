import 'dart:async';
import 'dart:math';

import 'package:better_bilibili/utils/hex_color.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(useMaterial3: true, primaryColor: Colors.blue),
      home: DanmakuTest1(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class Danmaku {
  final DanmakuType type;
  final String text;
  final int time;
  final String color;
  final bool bold;
  final int size;

  const Danmaku({
    required this.type,
    required this.text,
    required this.time,
    required this.color,
    required this.bold,
    required this.size,
  });
}

class DanmakuTest1 extends StatefulWidget {
  const DanmakuTest1({super.key});

  @override
  State<DanmakuTest1> createState() => _DanmakuTest1State();
}

class _DanmakuTest1State extends State<DanmakuTest1> with SingleTickerProviderStateMixin {
  Duration timeStep = Duration(milliseconds: 10);
  Duration _videoPosition = Duration.zero;
  Timer? _timer;
  final Random _random = Random();

  DanmakuController controller = DanmakuController();
  late Ticker _renderTicker;

  @override
  void initState() {
    super.initState();

    _renderTicker = createTicker((elapsed) {
      controller.onTick(elapsed);
    });
  }

  @override
  void dispose() {
    stopTimer();

    super.dispose();
  }

  void resetTimer() {
    stopTimer();
    setState(() {
      _videoPosition = Duration.zero;
      controller = DanmakuController();

      controller.load(
        // [
        //   Danmaku(
        //     type: .top,
        //     text: '测试顶部弹幕 1',
        //     time: 0,
        //     bold: _random.nextBool(),
        //     color: {
        //       0: '#ffffff',
        //       1: '#ff0000',
        //       2: '#00ff00',
        //       3: '#0000ff',
        //       4: '#ffff00',
        //       5: '#00ffff',
        //       6: '#ff00ff',
        //       7: '#ff8800',
        //       8: '#8888ff',
        //       9: '#00ff88',
        //     }[_random.nextInt(10)]!,
        //     size: _random.nextInt(30) + 15,
        //   ),
        //   Danmaku(
        //     type: .top,
        //     text: '测试顶部弹幕 2',
        //     time: 6000,
        //     bold: _random.nextBool(),
        //     color: {
        //       0: '#ffffff',
        //       1: '#ff0000',
        //       2: '#00ff00',
        //       3: '#0000ff',
        //       4: '#ffff00',
        //       5: '#00ffff',
        //       6: '#ff00ff',
        //       7: '#ff8800',
        //       8: '#8888ff',
        //       9: '#00ff88',
        //     }[_random.nextInt(10)]!,
        //     size: _random.nextInt(30) + 15,
        //   ),
        // ],
        [
          ...List.generate(
            1000,
            (index) => Danmaku(
              type: .scroll,
              text: '测试弹幕 $index',
              time: _random.nextInt(10000),
              bold: _random.nextBool(),
              color: {
                0: '#ffffff',
                1: '#ff0000',
                2: '#00ff00',
                3: '#0000ff',
                4: '#ffff00',
                5: '#00ffff',
                6: '#ff00ff',
                7: '#ff8800',
                8: '#8888ff',
                9: '#00ff88',
              }[_random.nextInt(10)]!,
              size: _random.nextInt(30) + 15,
            ),
          ),
          ...List.generate(
            1000,
            (index) => Danmaku(
              type: .top,
              text: '顶部测试弹幕 $index',
              time: _random.nextInt(10000),
              bold: _random.nextBool(),
              color: {
                0: '#ffffff',
                1: '#ff0000',
                2: '#00ff00',
                3: '#0000ff',
                4: '#ffff00',
                5: '#00ffff',
                6: '#ff00ff',
                7: '#ff8800',
                8: '#8888ff',
                9: '#00ff88',
              }[_random.nextInt(10)]!,
              size: _random.nextInt(30) + 15,
            ),
          ),
          ...List.generate(
            1000,
            (index) => Danmaku(
              type: .bottom,
              text: '底部测试弹幕 $index',
              time: _random.nextInt(10000),
              bold: _random.nextBool(),
              color: {
                0: '#ffffff',
                1: '#ff0000',
                2: '#00ff00',
                3: '#0000ff',
                4: '#ffff00',
                5: '#00ffff',
                6: '#ff00ff',
                7: '#ff8800',
                8: '#8888ff',
                9: '#00ff88',
              }[_random.nextInt(10)]!,
              size: _random.nextInt(30) + 15,
            ),
          ),
        ],
      );
    });
  }

  void startTimer() {
    _renderTicker.start();

    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      setState(() {
        _videoPosition += const Duration(milliseconds: 200);
      });
      controller.onVideoPositionChanged(_videoPosition);
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _renderTicker.stop();
  }

  void seek(Duration position) {
    setState(() {
      _videoPosition = position;
    });
    controller.onVideoSeek(_videoPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DanmakuTest1'),
        actions: [
          IconButton(onPressed: startTimer, icon: const Icon(Icons.play_arrow)),
          IconButton(onPressed: stopTimer, icon: const Icon(Icons.pause)),
          IconButton(onPressed: resetTimer, icon: const Icon(Icons.restore)),
          IconButton(
            onPressed: () => seek(Duration(seconds: 5)),
            icon: const Icon(Icons.ten_k),
            tooltip: 'seek to 5s',
          ),
          IconButton(
            onPressed: () {
              seek(Duration(seconds: 5));
              stopTimer();
            },
            icon: const Icon(Icons.ten_k),
            tooltip: 'seek to 5s and stop',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: .min,
          children: [
            Text('VideoPosition: ${_videoPosition.toString()}'),
            SizedBox(
              width: 1920 / 2,
              height: 1080 / 2,
              child: ClipRect(
                // clipBehavior: .none,
                child: Container(
                  color: Colors.blue,
                  child: CustomPaint(painter: DanmakuLayer(controller: controller)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum DanmakuType {
  scroll,
  top,
  bottom,
}

class LaunchedDanmaku {
  final Danmaku data;
  final TextPainter painter;
  double left;
  double top;
  double age;
  Track? track;

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

/// 弹幕每秒经过多少像素
const gSpeed = 200;

/// 无法在原位发射时最多允许弹幕延后多少像素发射
const gDelayLoadThreshold = 300;

/// 轨道之间的间距
const gTrackGap = 4;

/// 弹幕之间的间距
const gItemGap = 20;

/// 固定弹幕存活时间
const gFixedDanmakuSurvivalTime = Duration(seconds: 5);

const gFixedDanmakuAreaHeight = 0.5;

class Track {
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

  void removeWhere(Set<LaunchedDanmaku> removeSet) {
    _items.removeWhere(removeSet.contains);

    _calcNewMaximum();
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

class DanmakuController extends ChangeNotifier {
  final List<LaunchedDanmaku> launchedList = [];
  final List<Danmaku> unlaunchedList = [];
  final List<Danmaku> disposedList = [];
  Size _viewPortSize = .zero;
  final List<Track> tracks = [];
  final List<LaunchedDanmaku> topTracks = [];
  final List<LaunchedDanmaku> bottomTracks = [];

  Duration _lastTick = Duration.zero;

  void load(List<Danmaku> data) {
    unlaunchedList.addAll(data);
    unlaunchedList.sort((a, b) => a.time - b.time);
  }

  LaunchedDanmaku? tryAssignTrack(int time, Danmaku item, TextPainter painter) {
    final survivalTime = time - item.time;
    final possibleLeft = _viewPortSize.width - (survivalTime / 1000) * gSpeed + gItemGap;

    double top = 0;
    for (final track in tracks) {
      final lastRight = track.items.lastOrNull?.right ?? 0;

      if (track == tracks.last && top + painter.height > _viewPortSize.height) {
        return null;
      }

      if (possibleLeft < lastRight) {
        final newLeft = lastRight + gItemGap;
        if (newLeft <= possibleLeft + gDelayLoadThreshold) {
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

  void onVideoPositionChanged(Duration newPosition) {
    if (_viewPortSize == Size.zero) return;

    final time = newPosition.inMilliseconds;

    final double scrollDanmakuMaxTravelDistance = _viewPortSize.width + 2000;
    final int scrollDanmakuMaxSurvivalTime = (scrollDanmakuMaxTravelDistance / (gSpeed / 1000)).ceil();

    Set<Danmaku> removeSet = {};

    for (final item in unlaunchedList) {
      if (time >= item.time) {
        removeSet.add(item);

        if (item.type == .scroll) {
          if (time - item.time > scrollDanmakuMaxSurvivalTime) {
            disposedList.add(item);
            continue;
          }
        } else if (item.type == .top || item.type == .bottom) {
          if (time > item.time + gFixedDanmakuSurvivalTime.inMilliseconds) {
            disposedList.add(item);
            continue;
          }
        }

        final painter = TextPainter(
          text: TextSpan(
            text: item.text,
            style: TextStyle(
              fontSize: item.size.toDouble(), // 19
              fontWeight: item.bold ? .bold : .normal,
              color: HexColor(item.color),
              height: 1.2,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Color(0xFF000000),
                ),
                Shadow(
                  offset: Offset(0, 0),
                  blurRadius: 1,
                  color: Color(0xFF000000),
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
        )..layout();

        if (item.type == .scroll) {
          final launchedDanmaku = tryAssignTrack(time, item, painter);

          if (launchedDanmaku != null) {
            launchedList.add(launchedDanmaku);
          } else {
            final totalTrackHeight = tracks.fold(0.0, (sum, element) => sum + element.height + gTrackGap);
            if (totalTrackHeight + painter.height <= _viewPortSize.height) {
              tracks.add(Track());
              final launchedDanmaku = tryAssignTrack(time, item, painter);
              if (launchedDanmaku != null) launchedList.add(launchedDanmaku);
            }
          }
        } else if (item.type == .top) {
          double top = 0;
          final double maxBottom = _viewPortSize.height * gFixedDanmakuAreaHeight;

          if (time > item.time && time < item.time + gFixedDanmakuSurvivalTime.inMilliseconds) {}

          for (final track in topTracks) {
            double bottom = top + painter.height;

            if (bottom + gTrackGap <= track.top) {
              break;
            }

            if (top < track.bottom + gTrackGap) {
              top = track.bottom + gTrackGap;
            }
          }

          if (top + painter.height <= maxBottom) {
            final launchedDanmaku = LaunchedDanmaku(
              data: item,
              painter: painter,
              left: _viewPortSize.width / 2 - painter.width / 2,
              top: top,
              age: (time - item.time).toDouble(),
            );

            topTracks.add(launchedDanmaku);
            topTracks.sort((a, b) => a.top.compareTo(b.top));
            launchedList.add(launchedDanmaku);
          }
        } else if (item.type == .bottom) {
          double currentBottom = _viewPortSize.height;
          final double minTop = _viewPortSize.height * (1 - gFixedDanmakuAreaHeight);

          for (final track in bottomTracks) {
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
            final launchedDanmaku = LaunchedDanmaku(
              data: item,
              painter: painter,
              left: _viewPortSize.width / 2 - painter.width / 2,
              top: finalTop,
              age: (time - item.time).toDouble(),
            );

            bottomTracks.add(launchedDanmaku);
            bottomTracks.sort((a, b) => b.bottom.compareTo(a.bottom));
            launchedList.add(launchedDanmaku);
          }
        }
      }
    }

    unlaunchedList.removeWhere(removeSet.contains);
  }

  void onVideoSeek(Duration newPosition) {
    unlaunchedList.addAll(launchedList.map((v) => v.data));
    launchedList.clear();

    unlaunchedList.addAll(disposedList);
    disposedList.clear();

    tracks.clear();
    topTracks.clear();
    bottomTracks.clear();

    unlaunchedList.sort((a, b) => a.time - b.time);
    onVideoPositionChanged(newPosition);
  }

  void onTick(Duration elapsed) {
    if (_viewPortSize == Size.zero) return;

    final deltaTime = (elapsed - _lastTick).inMilliseconds;
    _lastTick = elapsed;

    if (deltaTime <= 0) return;

    Set<LaunchedDanmaku> disposeSet = {};

    for (final item in launchedList) {
      if (item.data.type == .scroll) {
        // 每一帧的位移 = 速度(像素/秒) * (经过的时间/1000)
        item.left -= gSpeed * (deltaTime / 1000.0);

        if (item.left + item.width < 0) {
          disposeSet.add(item);
          disposedList.add(item.data);
        }
      } else if (item.data.type == .top || item.data.type == .bottom) {
        item.age += deltaTime;

        if (item.age >= gFixedDanmakuSurvivalTime.inMilliseconds) {
          disposeSet.add(item);
          disposedList.add(item.data);
        }
      }
    }

    for (final item in disposeSet) {
      launchedList.remove(item);

      if (item.data.type == DanmakuType.scroll) {
        item.track?.removeItem(item);
      } else if (item.data.type == DanmakuType.top) {
        topTracks.remove(item);
      } else if (item.data.type == DanmakuType.bottom) {
        bottomTracks.remove(item);
      }
    }

    notifyListeners();
  }

  void setViewPortSize(Size newSize) {
    if (newSize == _viewPortSize) return;
    _viewPortSize = newSize;
    debugPrint('newSize: $newSize');

    double height = 0;
    Set<Track> disposeSet = {};
    for (final item in tracks) {
      if (item.height + height > newSize.height) {
        disposeSet.add(item);
        disposedList.addAll(item.items.map((v) => v.data));
      }

      height += item.height + gTrackGap;
    }

    tracks.removeWhere(disposeSet.contains);
  }
}

class DanmakuLayer extends CustomPainter {
  final DanmakuController controller;

  DanmakuLayer({required this.controller}) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    controller.setViewPortSize(size);

    for (final item in controller.launchedList) {
      item.painter.paint(canvas, Offset(item.left, item.top));
    }
  }

  @override
  bool shouldRepaint(covariant DanmakuLayer oldDelegate) => false;
}
