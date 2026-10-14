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
import 'package:material_ui/material_ui.dart';

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

  Color _getSegmentColor(SegmentCategoryEnum category) {
    return HexColor(switch (category) {
      .sponsor => controller.config.sponsorColor.value,
      .selfpromo => controller.config.selfpromoColor.value,
      .exclusiveAccess => throw Exception('Unreachable branch'),
      .interaction => controller.config.interactionColor.value,
      .pointsOfInterest => controller.config.pointsOfInterestColor.value,
      .intro => controller.config.introColor.value,
      .outro => controller.config.outroColor.value,
      .preview => controller.config.previewColor.value,
      .padding => controller.config.paddingColor.value,
      .filler => controller.config.fillerColor.value,
      .musicOfftopic => controller.config.musicOfftopicColor.value,
    });
  }

  SkipOptionsEnum _getOption(SegmentCategoryEnum category) => switch (category) {
    .sponsor => controller.config.sponsor.value,
    .selfpromo => controller.config.selfpromo.value,
    .interaction => controller.config.interaction.value,
    .pointsOfInterest => controller.config.pointsOfInterest.value,
    .intro => controller.config.intro.value,
    .outro => controller.config.outro.value,
    .preview => controller.config.preview.value,
    .padding => controller.config.padding.value,
    .filler => controller.config.filler.value,
    .musicOfftopic => controller.config.musicOfftopic.value,
    .exclusiveAccess => .disable,
  };

  void _update() {
    final segments = controller.data[widget.episodeId] ?? [];
    final List<TimelineSegment> data = [];
    for (final i in segments) {
      final option = _getOption(i.category);
      if (option == .disable) continue;

      final name = _getSegmentName(i.category);
      data.add(
        TimelineSegment(
          type: .mark,
          start: i.start,
          end: i.end,
          name: name,
          color: _getSegmentColor(i.category),
          onPreEnter:
              (option == .askOnlyStart ? () => _ask('跳转至$name?', i.start) : null) ??
              (option == .askOnlyEnd ? () => _ask('跳过$name?', i.end) : null),
          onEnter:
              (option == .skipToStart ? () => _seek('已跳至$name', i.start) : null) ??
              (option == .skipToEnd ? () => _seek('已跳过$name', i.end) : null),
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

  void _seek(String message, Duration position) {
    final positionBak = widget.videoController.state.position;
    widget.videoController.seek(position);

    widget.noticeController.show(
      Notice(
        content: Text(message),
        duration: const Duration(seconds: 6),
        action: '撤销',
        onTap: (self) {
          widget.noticeController.dismiss(self);
          widget.videoController.seek(positionBak);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
