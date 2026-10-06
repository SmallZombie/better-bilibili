import 'package:better_bilibili/ui/core/bilibili/video_player/panel/selection_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_header.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/extra_video_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_controller.dart';
import 'package:flutter/material.dart';

class PlaybackRatePanel implements Panel {
  final ExtraVideoController controller;
  final PanelController panelController;

  const PlaybackRatePanel({required this.controller, required this.panelController});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: controller.stream.rate,
      builder: (context, asyncSnapshot) {
        final rate = asyncSnapshot.data ?? controller.state.rate;
        return SelectionPanel(
          header: PanelHeader(
            title: Text('播放速度'),
            onBack: panelController.pop,
          ),
          items: const [
            SelectionPanelItem(label: '0.1x', value: 0.1),
            SelectionPanelItem(label: '0.2x', value: 0.2),
            SelectionPanelItem(label: '0.5x', value: 0.5),
            SelectionPanelItem(label: '1.0x', value: 1.0),
            SelectionPanelItem(label: '1.25x', value: 1.25),
            SelectionPanelItem(label: '1.5x', value: 1.5),
            SelectionPanelItem(label: '2.0x', value: 2.0),
            SelectionPanelItem(label: '2.5x', value: 2.5),
            SelectionPanelItem(label: '3.0x', value: 3.0),
          ],
          value: rate,
          onChange: controller.setPlaybackRate,
        );
      },
    );
  }

  @override
  String get id => 'playback_rate';

  @override
  double get width => 310;
}
