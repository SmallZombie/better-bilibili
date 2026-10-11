import 'package:better_bilibili/config/player_config.dart';
import 'package:better_bilibili/domain/models/bilibili/play_info.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/selection_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_header.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_controller.dart';
import 'package:material_ui/material_ui.dart';

class SettingsFallbackCodecPanel implements Panel {
  final PanelController controller;
  final PlayerConfig config;

  const SettingsFallbackCodecPanel({required this.controller, required this.config});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: config.fallbackCodec.stream,
      initialData: config.fallbackCodec.value,
      builder: (context, asyncSnapshot) {
        final fallbackCodec = asyncSnapshot.data!;
        return SelectionPanel(
          onChange: config.fallbackCodec.set,
          value: fallbackCodec,
          header: PanelHeader(title: const Text('选择编码'), onBack: controller.pop),
          items: CodecEnum.values.map((v) => SelectionPanelItem(label: v.value, value: v)).toList(),
        );
      },
    );
  }

  @override
  String get id => 'settings.fallback_codec';

  @override
  double get width => 310;
}
