import 'package:flutter/material.dart';

enum SegmentTypeEnum { chapter, mark }

class TimelineSegment {
  final SegmentTypeEnum type;
  final Duration start;
  final Duration? end;
  final String name;
  final VoidCallback? onEnter;
  final VoidCallback? onLeave;
  final Color? color;

  final Duration preEnterTime = const Duration(seconds: 5);
  final VoidCallback? onPreEnter;

  /// 用于描述时间线中的一段章节或标记
  ///
  /// 当类型为 chapter 时可以省略 end,
  /// Timeline 会尝试将章节排序然后使他们首尾相接,
  /// 位于最后的章节将自动延申至末尾
  ///
  /// 当类型为 mark 时不可省略 end
  ///
  /// end 若存在则必须大于 start
  ///
  /// chapter 不可重叠，mark 则可以，但时间线只会在重叠的 mark 中选择一个显示
  const TimelineSegment({
    required this.type,
    required this.start,
    this.end,
    required this.name,
    this.onEnter,
    this.color,
    this.onLeave,
    this.onPreEnter,
  });

  TimelineSegment copyWith({
    SegmentTypeEnum? type,
    Duration? start,
    Duration? end,
    String? name,
    VoidCallback? onEnter,
    VoidCallback? onLeave,
    Color? color,
    VoidCallback? onPreEnter,
  }) {
    return TimelineSegment(
      type: type ?? this.type,
      start: start ?? this.start,
      end: end ?? this.end,
      name: name ?? this.name,
      onEnter: onEnter ?? this.onEnter,
      onLeave: onLeave ?? this.onLeave,
      color: color ?? this.color,
      onPreEnter: onPreEnter ?? this.onPreEnter,
    );
  }

  @override
  String toString() {
    return 'TimelineSegment('
        'type: $type, '
        'start: $start, '
        'end: $end, '
        'name: "$name", '
        'color: $color, '
        'preEnterTime: $preEnterTime'
        ')';
  }
}
