import 'dart:async';

import 'package:better_bilibili/config/bsbsb_config.dart';
import 'package:better_bilibili/data/model/bsbsb/segment.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/bsbsb/bsbsb_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/extra_video_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/notice/notice_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/timeline/segment/timeline_segment.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/timeline/segment/timeline_segment_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/timeline/segment/timeline_segment_data_source.dart';
import 'package:better_bilibili/utils/hex_color.dart';
import 'package:flutter/material.dart';

class BsbsbLayer extends StatefulWidget {
  final BsbsbController controller;
  final TimelineSegmentController segmentController;
  final ExtraVideoController videoController;
  final NoticeController noticeController;
  final String episodeId;

  const BsbsbLayer({
    super.key,
    required this.controller,
    required this.segmentController,
    required this.videoController,
    required this.noticeController,
    required this.episodeId,
  });

  @override
  State<BsbsbLayer> createState() => _BsbsbLayerState();
}

class _BsbsbLayerState extends State<BsbsbLayer> {
  BsbsbController get controller => widget.controller;
  TimelineSegmentController get segmentController => widget.segmentController;

  final List<StreamSubscription> _subscriptions = [];

  final TimelineSegmentDataSource dataSource = TimelineSegmentDataSource();

  @override
  void initState() {
    super.initState();

    controller.addListener(_update);
    segmentController.addDataSource(dataSource);
    _update();

    _subscriptions.addAll([
      // controller.config.
    ]);
  }

  @override
  void dispose() {
    controller.removeListener(_update);
    segmentController.removeDataSource(dataSource);
    dataSource.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant BsbsbLayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.episodeId != widget.episodeId) {
      _update();
    }
  }

  String _getSegmentName(SegmentCategoryEnum category) => switch (category) {
    .sponsor => '商业推广',
    .selfpromo => '无偿/自我推广',
    .exclusiveAccess => '独家/抢鲜体验',
    .interaction => '三连/互动提醒',
    .pointsOfInterest => '精彩时刻/重点',
    .intro => '过场/开场动画',
    .outro => '鸣谢/结束画面',
    .preview => '回顾/概要',
    .padding => '填充内容/黑屏',
    .filler => '离题闲聊/玩笑',
    .musicOfftopic => '非音乐部分',
  };

  Future<Color> _getSegmentColor(SegmentCategoryEnum category) async {
    final hex = await switch (category) {
      .sponsor => controller.config.sponsorColor.get(),
      .selfpromo => controller.config.sponsorColor.get(),
      .exclusiveAccess => controller.config.sponsorColor.get(),
      .interaction => controller.config.sponsorColor.get(),
      .pointsOfInterest => controller.config.sponsorColor.get(),
      .intro => controller.config.sponsorColor.get(),
      .outro => controller.config.sponsorColor.get(),
      .preview => controller.config.sponsorColor.get(),
      .padding => controller.config.sponsorColor.get(),
      .filler => controller.config.sponsorColor.get(),
      .musicOfftopic => controller.config.sponsorColor.get(),
    };
    return HexColor(hex);
  }

  Future<SkipOptionsEnum> _getOption(SegmentCategoryEnum category) => switch (category) {
    .sponsor => controller.config.sponsor.get(),
    .selfpromo => controller.config.selfpromo.get(),
    .interaction => controller.config.interaction.get(),
    .pointsOfInterest => controller.config.pointsOfInterest.get(),
    .intro => controller.config.intro.get(),
    .outro => controller.config.outro.get(),
    .preview => controller.config.preview.get(),
    .padding => controller.config.padding.get(),
    .filler => controller.config.filler.get(),
    .musicOfftopic => controller.config.musicOfftopic.get(),
    .exclusiveAccess => Future.value(.disable),
  };

  Future<void> _update() async {
    final segments = controller.data[widget.episodeId] ?? [];
    final List<TimelineSegment> data = [];
    for (final i in segments) {
      final option = await _getOption(i.category);
      if (option == .disable) continue;

      final name = _getSegmentName(i.category);
      data.add(
        TimelineSegment(
          type: .mark,
          start: i.start,
          end: i.end,
          name: name,
          color: await _getSegmentColor(i.category),
          onPreEnter:
              (option == .askOnlyStart ? () => _ask('跳至$name开头?', i.start) : null) ??
              (option == .askOnlyEnd ? () => _ask('跳至$name末尾?', i.end) : null),
          onEnter: (option == .skipToStart ? () => _seek(i.start) : null) ?? (option == .skipToEnd ? () => _seek(i.end) : null),
        ),
      );
    }
    dataSource.data = data;
  }

  void _ask(String message, Duration position) {
    widget.noticeController.show(
      Notice(
        content: Text(message),
        duration: const Duration(seconds: 6),
        action: '跳转',
        onTap: (self) {
          widget.noticeController.dismiss(self);
          widget.videoController.seek(position);
        },
      ),
    );
  }

  void _seek(Duration position) {
    widget.videoController.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
