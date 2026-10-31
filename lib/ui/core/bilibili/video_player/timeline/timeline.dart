import 'dart:async';

import 'package:better_bilibili/data/repositories/bilibili/video_repository/video_repository.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/timeline/segment/timeline_segment.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/timeline/segment/timeline_segment_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/extra_video_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/timeline/preview/timeline_preview_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/timeline/waveform/timeline_waveform_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/timeline/waveform/timeline_waveform_render.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';

const _kHoverTransitionDuration = Duration(milliseconds: 150);

class Timeline extends StatefulWidget {
  final ExtraVideoController controller;
  final ValueChanged<Duration>? onSeekStart;
  final ValueChanged<Duration>? onSeekEnd;
  final VideoRepository videoRepository;
  final TimelinePreviewController previewController;
  final TimelineWaveformController? waveformController;
  final TimelineSegmentController segmentController;
  // 因为新增了章节条，所以时间线有时会变得比预期更高，
  // 外面的 overlay 并不知到时间线什么时候会有因为存在章节条而变高，
  // 所以暂时通过这样的方案来传递正确的高度，我觉得这样不够优雅但先这样吧
  final ValueChanged<double>? onHeightChange;

  const Timeline({
    super.key,
    required this.controller,
    this.onSeekStart,
    this.onSeekEnd,
    required this.videoRepository,
    required this.previewController,
    this.waveformController,
    required this.segmentController,
    this.onHeightChange,
  });

  @override
  TimelineState createState() => TimelineState();
}

class TimelineState extends State<Timeline> {
  ExtraVideoController get controller => widget.controller;
  TimelinePreviewController get previewController => widget.previewController;
  TimelineSegmentController get segmentController => widget.segmentController;

  bool hover = false;
  bool click = false;
  double slider = 0.0;

  late bool playing = controller.state.playing;
  late Duration position = controller.state.position;
  late Duration duration = controller.state.duration;
  late Duration buffer = controller.state.buffer;

  final List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    super.initState();

    subscriptions.addAll([
      controller.stream.playing.listen((event) {
        setState(() => playing = event);
      }),
      controller.stream.position.listen((event) {
        setState(() {
          if (!click) position = event;
        });
      }),
      controller.stream.duration.listen((event) {
        setState(() => duration = event);
      }),
      controller.stream.buffer.listen((event) {
        setState(() => buffer = event);
      }),
    ]);

    widget.segmentController.addListener(_onSegmentChanged);
    _onSegmentChanged();
  }

  @override
  void dispose() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }

    widget.segmentController.removeListener(_onSegmentChanged);

    super.dispose();
  }

  void onPointerDown() {
    widget.onSeekStart?.call(duration * slider);
    setState(() {
      click = true;
    });
  }

  void onPointerMove(PointerMoveEvent e, BoxConstraints constraints) {
    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      hover = true;
      slider = percent.clamp(0.0, 1.0);
    });

    previewController.updatePreview(duration * slider);
  }

  void onPointerUp() {
    widget.onSeekEnd?.call(duration * slider);
    setState(() {
      // Explicitly set the position to prevent the slider from jumping.
      click = false;
      position = duration * slider;

      if (_exited) hover = false;
    });
    controller.seek(duration * slider);
  }

  void onHover(PointerHoverEvent e, BoxConstraints constraints) {
    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      hover = true;
      slider = percent.clamp(0.0, 1.0);
    });

    previewController.updatePreview(duration * slider);
  }

  bool _exited = false;

  void onEnter(PointerEnterEvent e, BoxConstraints constraints) {
    _exited = false;

    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      hover = true;
      slider = percent.clamp(0.0, 1.0);
    });
  }

  void onExit(PointerExitEvent e, BoxConstraints constraints) {
    _exited = true;

    setState(() {
      hover = false;
      slider = 0.0;
    });
  }

  /// Returns the current playback position in percentage.
  double get positionPercent {
    if (position == Duration.zero || duration == Duration.zero) {
      return 0.0;
    } else {
      final value = position.inMilliseconds / duration.inMilliseconds;
      return value.clamp(0.0, 1.0);
    }
  }

  /// Returns the current playback buffer position in percentage.
  double get bufferPercent {
    if (buffer == Duration.zero || duration == Duration.zero) {
      return 0.0;
    } else {
      final value = buffer.inMilliseconds / duration.inMilliseconds;
      return value.clamp(0.0, 1.0);
    }
  }

  final height = 3.2;
  final hoverHeight = 5.6;
  final triggerPadding = 8.0;
  final chapterBarHeight = 24.0;

  void _onSegmentChanged() {
    widget.onHeightChange?.call(
      segmentController.chapters.isEmpty ? hoverHeight + triggerPadding * 2 : hoverHeight + triggerPadding + chapterBarHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final hasChapterBar = segmentController.chapters.isNotEmpty;

    return Row(
      crossAxisAlignment: .end,
      children: [
        SizedBox(width: 12.0),
        Text(
          position.label(reference: duration),
          style: textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
        SizedBox(width: 8.0),
        Expanded(
          child: Column(
            mainAxisSize: .min,
            children: [
              if (widget.waveformController != null)
                Transform.translate(
                  offset: Offset(0, hasChapterBar ? 4 : 10),
                  child: TimelineWaveformRender(controller: widget.waveformController!),
                ),
              Column(
                mainAxisSize: .min,
                children: [
                  if (hasChapterBar) _buildChapterBar(),
                  _buildProgressBar(hasChapterBar),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 8.0),
        Text(
          duration.label(reference: duration),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: Colors.white),
        ),
        SizedBox(width: 12.0),
      ],
    );
  }

  /// [moreTopArea] 取消上方额外手势区域
  Widget _buildProgressBar([bool moreTopArea = false]) {
    final colorScheme = Theme.of(context).colorScheme;

    final dotSize = 12.0;

    return Container(
      clipBehavior: .none,
      child: LayoutBuilder(
        builder: (context, constraints) => MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (e) => onHover(e, constraints),
          onEnter: (e) => onEnter(e, constraints),
          onExit: (e) => onExit(e, constraints),
          child: Listener(
            onPointerMove: (e) => onPointerMove(e, constraints),
            onPointerDown: (_) => onPointerDown(),
            onPointerUp: (_) => onPointerUp(),
            child: Container(
              color: Colors.transparent,
              width: constraints.maxWidth,
              padding: moreTopArea ? .only(top: 3, bottom: triggerPadding) : .symmetric(vertical: triggerPadding),
              child: SizedBox(
                height: hoverHeight,
                child: Stack(
                  clipBehavior: .none,
                  alignment: .centerLeft,
                  children: [
                    if (hover) _buildHoverPreview(constraints),
                    AnimatedContainer(
                      height: hover ? hoverHeight : height,
                      alignment: .centerLeft,
                      duration: _kHoverTransitionDuration,
                      color: colorScheme.outline.withAlpha(100),
                      child: Stack(
                        clipBehavior: .none,
                        alignment: .centerLeft,
                        children: [
                          // hover
                          Container(
                            width: constraints.maxWidth * slider,
                            color: const Color(0x3DFFFFFF),
                          ),
                          // buffered
                          Container(
                            width: constraints.maxWidth * bufferPercent,
                            color: const Color(0x3DFFFFFF),
                          ),
                          // position
                          Container(
                            width: click ? constraints.maxWidth * slider : constraints.maxWidth * positionPercent,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                    ...segmentController.marks.map(
                      (v) => Positioned(
                        left: v.start.inMilliseconds / duration.inMilliseconds * constraints.maxWidth,
                        child: AnimatedContainer(
                          duration: _kHoverTransitionDuration,
                          width: (v.end!.inMilliseconds - v.start.inMilliseconds) / duration.inMilliseconds * constraints.maxWidth,
                          height: hover ? hoverHeight : height,
                          color: v.color,
                        ),
                      ),
                    ),
                    Positioned(
                      // top: -dotSize / 2,
                      left: click ? constraints.maxWidth * slider - dotSize / 2 : constraints.maxWidth * positionPercent - dotSize / 2,
                      child: AnimatedContainer(
                        width: hover || click || segmentController.currentMarks.isNotEmpty ? dotSize : 0.0,
                        height: hover || click || segmentController.currentMarks.isNotEmpty ? dotSize : 0.0,
                        duration: _kHoverTransitionDuration,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: .circular(dotSize / 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHoverPreview(BoxConstraints constraints) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final previewWidth = 200.0;

    final hoverX = constraints.maxWidth * slider;
    final previewLeft = (hoverX - previewWidth / 2).clamp(
      0.0,
      constraints.maxWidth - previewWidth,
    );

    TimelineSegment? hitChapter;
    List<TimelineSegment> hitMarks = [];
    if (hover) {
      final hoverPosition = duration * slider;

      for (final i in segmentController.chapters) {
        if (hoverPosition >= i.start && hoverPosition <= i.end!) {
          hitChapter = i;
          break;
        }
      }
      for (final i in segmentController.marks) {
        if (hoverPosition >= i.start && hoverPosition <= i.end!) {
          hitMarks.add(i);
        }
      }
    }

    return OverflowBox(
      alignment: .bottomLeft,
      minWidth: 0,
      minHeight: 0,
      maxWidth: .infinity,
      maxHeight: .infinity,
      child: Transform.translate(
        offset: Offset(previewLeft, -40.0),
        child: Column(
          mainAxisSize: .min,
          spacing: 4.0,
          children: [
            Container(
              width: 200,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.outline.withAlpha(100),
                borderRadius: .circular(8.0),
                border: .all(color: Colors.white, width: 1.0),
              ),
              child: ClipRRect(
                borderRadius: .circular(8.0),
                child: RepaintBoundary(
                  child: ListenableBuilder(
                    listenable: previewController,
                    builder: (context, child) {
                      if (previewController.currentImage == null || previewController.currentRect == null) {
                        return const SizedBox.shrink();
                      }

                      return CustomPaint(
                        painter: _PreviewPainter(controller: previewController),
                      );
                    },
                  ),
                ),
              ),
            ),
            Container(
              padding: const .symmetric(horizontal: 10.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(100),
                borderRadius: .circular(32.0),
              ),
              child: Row(
                mainAxisSize: .min,
                spacing: 6.0,
                children: [
                  Text(
                    (duration * slider).label(reference: duration),
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  if (hitChapter != null)
                    Text(
                      hitChapter.name,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            if (hitMarks.isNotEmpty)
              Container(
                padding: const .symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(100),
                  borderRadius: .circular(32.0),
                ),
                child: Row(
                  mainAxisSize: .min,
                  spacing: 4.0,
                  children: hitMarks.map((v) {
                    return Text(
                      v.name,
                      style: textTheme.bodyMedium?.copyWith(
                        color: v.color,
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterBar() {
    List<Widget> children = [];
    for (int i = 0; i < segmentController.chapters.length; i++) {
      final chapter = segmentController.chapters[i];
      final isLast = i == segmentController.chapters.length - 1;

      children.add(
        Expanded(
          // 最后一个章节的末尾并不总是等于视频总时间
          flex: isLast
              ? duration.inMilliseconds - chapter.start.inMilliseconds
              : chapter.end!.inMilliseconds - chapter.start.inMilliseconds + 1,
          child: InkWell(
            onTap: () => controller.seek(chapter.start),
            mouseCursor: SystemMouseCursors.click,
            child: Container(
              color: chapter.color ?? Colors.white12,
              height: chapterBarHeight,
              padding: const .symmetric(vertical: 2.0),
              child: Text(chapter.name),
            ),
          ),
        ),
      );
    }

    return Transform.translate(
      offset: const Offset(0, 2),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Color(0xffffffff), fontSize: 13.0),
        textAlign: .center,
        maxLines: 1,
        overflow: .ellipsis,
        child: Row(spacing: 2.0, children: children),
      ),
    );
  }
}

class _PreviewPainter extends CustomPainter {
  final TimelinePreviewController controller;

  _PreviewPainter({required this.controller}) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    assert(controller.currentImage != null && controller.currentRect != null);

    canvas.drawImageRect(
      controller.currentImage!,
      controller.currentRect!,
      Offset.zero & size,
      Paint(),
    );
  }

  @override
  bool shouldRepaint(covariant _PreviewPainter oldDelegate) => false;
}
