import 'dart:async';

import 'package:better_bilibili/ui/core/bilibili/video_player/danmaku/danmaku_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/extra_video_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class DanmakuLayer extends StatefulWidget {
  final DanmakuController controller;
  final ExtraVideoController videoController;
  final Stream<Duration> positionStream;
  final Stream<bool> playingStream;

  const DanmakuLayer({
    super.key,
    required this.controller,
    required this.videoController,
    required this.positionStream,
    required this.playingStream,
  });

  @override
  State<DanmakuLayer> createState() => _DanmakuLayerState();
}

class _DanmakuLayerState extends State<DanmakuLayer> with SingleTickerProviderStateMixin {
  late final Ticker _renderTicker;
  final List<StreamSubscription> subscriptions = [];
  bool _lastPlaying = false;

  @override
  void initState() {
    super.initState();

    _renderTicker = createTicker((elapsed) {
      widget.controller.onTick(elapsed);
    });

    _lastPlaying = !widget.videoController.state.playing;

    subscriptions.addAll([
      widget.positionStream.listen((position) {
        if (!mounted) return;
        widget.controller.onVideoPositionChanged(position);
      }),
      widget.playingStream.listen(_onPlaying),
    ]);

    if (widget.videoController.state.playing) _onPlaying(true);
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
        _renderTicker.start();
      }
    } else if (_renderTicker.isActive) {
      _renderTicker.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: ClipRect(
          child: CustomPaint(
            painter: DanmakuLayerPainter(controller: widget.controller),
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
