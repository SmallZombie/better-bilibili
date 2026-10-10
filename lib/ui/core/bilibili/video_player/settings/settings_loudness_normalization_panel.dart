import 'package:better_bilibili/config/player_config.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/selection_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_header.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_controller.dart';
import 'package:flutter/material.dart';

class SettingsLoudnessNormalizationPanel implements Panel {
  final PanelController controller;
  final PlayerConfig config;

  const SettingsLoudnessNormalizationPanel({required this.controller, required this.config});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: config.loudnessNormalization.stream,
      initialData: config.loudnessNormalization.value,
      builder: (context, asyncSnapshot) {
        final loudnessNormalization = asyncSnapshot.data!;
        return SelectionPanel(
          header: PanelHeader(title: const Text('响度均衡'), onBack: controller.pop),
          items: LoudnessNormalizationEnum.values.map((v) {
            return SelectionPanelItem(
              label: switch (v) {
                .off => '关闭',
                .normal => '普通',
                .highDynamic => '高动态',
              },
              value: v,
            );
          }).toList(),
          value: loudnessNormalization,
          onChange: config.loudnessNormalization.set,
        );
      },
    );
  }

  @override
  String get id => 'settings.loudness_normalization';

  @override
  double get width => 310;
}
