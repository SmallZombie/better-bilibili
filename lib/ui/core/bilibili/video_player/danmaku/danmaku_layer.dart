import 'dart:async';

import 'package:better_bilibili/ui/core/bilibili/video_player/danmaku/danmaku_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/extra_video_controller.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/scheduler.dart';

class DanmakuLayer extends StatefulWidget {
  final DanmakuController controller;
  final ExtraVideoController videoController;

  const DanmakuLayer({
    super.key,
    required this.controller,
    required this.videoController,
  });

  @override
  State<DanmakuLayer> createState() => _DanmakuLayerState();
}

class _DanmakuLayerState extends State<DanmakuLayer> with SingleTickerProviderStateMixin {
  DanmakuController get controller => widget.controller;
  ExtraVideoController get videoController => widget.videoController;

  late final Ticker _renderTicker;
  final List<StreamSubscription> subscriptions = [];
  bool _lastPlaying = false;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();

    _renderTicker = createTicker((elapsed) {
      final delta = elapsed - _lastTick;
      _lastTick = elapsed;
      controller.onTick(delta);
    });

    _lastPlaying = !videoController.state.playing;

    subscriptions.addAll([
      videoController.stream.position.listen((position) {
        if (!mounted) return;
        controller.onVideoPositionChanged(
          position,
          notify: !_renderTicker.isActive,
        );
      }),
      videoController.stream.playing.listen(_onPlaying),
    ]);

    if (videoController.state.playing) _onPlaying(true);
  }

  @override
  void dispose() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();

    _renderTicker.stop();
    super.dispose();
  }

  void _onPlaying(bool playing) {
    if (!mounted || playing == _lastPlaying) {
      return;
    }
    _lastPlaying = playing;

    if (playing) {
      if (!_renderTicker.isActive) {
        _lastTick = Duration.zero;
        _renderTicker.start();
      }
    } else if (_renderTicker.isActive) {
      _renderTicker.stop();
      _lastTick = Duration.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        child: SizedBox.expand(
          child: ClipRect(
            child: CustomPaint(
              painter: DanmakuLayerPainter(controller: controller),
            ),
          ),
        ),
      ),
    );
  }
}

class DanmakuLayerPainter extends CustomPainter {
  final DanmakuController controller;

  DanmakuLayerPainter({required this.controller}) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    controller.setViewPortSize(size);
    controller.onPaint(canvas);
  }

  @override
  bool shouldRepaint(covariant DanmakuLayerPainter oldDelegate) => false;
}
