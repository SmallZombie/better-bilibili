import 'dart:async';

import 'package:better_bilibili/ui/core/bilibili/video_player/timeline/segment/timeline_segment.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/extra_video_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/timeline/segment/timeline_segment_data_source.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';

class TimelineSegmentController extends ChangeNotifier {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'TimelineSegmentController'));

  final ExtraVideoController controller;

  final List<StreamSubscription> subscriptions = [];

  TimelineSegmentController({required this.controller}) {
    subscriptions.addAll([
      controller.stream.duration.listen((_) => _update()),
      controller.stream.position.listen(_handleMark),
    ]);
  }

  @override
  void dispose() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();

    for (final dataSource in _dataSources) {
      dataSource.removeListener(_update);
    }
    _dataSources.clear();

    super.dispose();
  }

  Duration get duration => controller.state.duration;
  Duration get position => controller.state.position;

  final List<TimelineSegmentDataSource> _dataSources = [];

  void addDataSource(TimelineSegmentDataSource dataSource) {
    _dataSources.add(dataSource);
    dataSource.addListener(_update);
    _update();
  }

  void removeDataSource(TimelineSegmentDataSource dataSource) {
    _dataSources.remove(dataSource);
    dataSource.removeListener(_update);
    _update();
  }

  final List<TimelineSegment> _segments = [];

  final List<TimelineSegment> _chapters = [];
  final List<TimelineSegment> _marks = [];
  List<TimelineSegment> get chapters => List.unmodifiable(_chapters);
  List<TimelineSegment> get marks => List.unmodifiable(_marks);

  void _update() {
    if (duration == .zero) return;

    _chapters.clear();
    _marks.clear();

    _segments.clear();
    for (final i in _dataSources) {
      _segments.addAll(i.data);
    }
    if (_segments.isEmpty) return;

    _segments.sort((a, b) => a.start.compareTo(b.start));

    for (int i = 0; i < _segments.length; i++) {
      TimelineSegment segment = _segments[i];

      assert(segment.type != .mark || segment.end != null);
      assert(segment.end == null || segment.end! > segment.start);

      if (segment.start > duration || (segment.end ?? .zero) < .zero) {
        _log.w('Invalid chapter $segment');
        continue;
      }

      if (segment.start < .zero) {
        segment = segment.copyWith(start: .zero);
        _log.w('Invalid start value, corrected to 0. chapter=${_segments[i]}');
      }
      if (segment.end != null && segment.end! > duration) {
        segment = segment.copyWith(end: duration);
        _log.w('Invalid end value, corrected to $duration. chapter=${_segments[i]}');
      }

      if (segment != _segments[i]) {
        _segments[i] = segment;
      }

      switch (segment.type) {
        case .chapter:
          if (_chapters.isNotEmpty) {
            final previous = _chapters.last;

            if (previous.end == null) {
              if (segment.start == previous.start) {
                continue;
              }

              _chapters[_chapters.length - 1] = previous.copyWith(
                end: segment.start,
              );
            } else if (segment.start < previous.end!) {
              continue;
            }
          }

          _chapters.add(segment);
        case .mark:
          _marks.add(segment);
      }
    }
    if (_chapters.isNotEmpty && _chapters.last.end == null) {
      final last = _chapters.last;

      _chapters[_chapters.length - 1] = last.copyWith(end: duration);
    }

    notifyListeners();
  }

  final List<TimelineSegment> _currentMarks = [];
  List<TimelineSegment> get currentMarks => List.unmodifiable(_currentMarks);
  final Set<TimelineSegment> _triggeredPreEnterSet = {};

  void _handleMark(Duration position) {
    final hitMarks = _marks.where((v) => position >= v.start && position < v.end!);

    final Set<TimelineSegment> removeSet = {};
    for (final i in _currentMarks) {
      if (!hitMarks.contains(i)) {
        i.onLeave?.call();
        removeSet.add(i);
        _triggeredPreEnterSet.remove(i);
      }
    }
    _currentMarks.removeWhere(removeSet.contains);

    for (final i in hitMarks) {
      if (!_currentMarks.contains(i)) {
        i.onEnter?.call();
        _currentMarks.add(i);
      }
    }

    final preHitMarks = _marks.where((v) {
      if (v.onPreEnter == null || v.preEnterTime < .zero) {
        return false;
      }

      return position >= v.start - v.preEnterTime && position < v.start;
    });

    for (var i in preHitMarks) {
      if (!_triggeredPreEnterSet.contains(i)) {
        i.onPreEnter?.call();
        _triggeredPreEnterSet.add(i);
      }
    }
  }
}
