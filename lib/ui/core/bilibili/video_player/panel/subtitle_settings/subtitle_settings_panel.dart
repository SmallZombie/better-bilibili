import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/panel_header.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/panel_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/switch_panel_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/subtitle_settings/subtitle_settings_shell.dart';
import 'package:flutter/material.dart';

class SubtitleSettingsPanel extends StatelessWidget {
  final VoidCallback? onBack;

  const SubtitleSettingsPanel({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        PanelHeader(title: const Text('字幕设置'), onBack: onBack),
        Expanded(
          child: ListView(
            children: [
              SwitchPanelTile(
                onChanged: (_) {},
                value: false,
                title: const Text('启用字幕'),
              ),
              PanelTile(
                onTap: () => Navigator.of(context).pushNamed(selectPrimarySubtitleRoute),
                title: const Text('主要字幕'),
                trailing: const Icon(Icons.keyboard_arrow_right_outlined),
              ),
              PanelTile(
                onTap: () => Navigator.of(context).pushNamed(selectSecondarySubtitleRoute),
                title: const Text('次要字幕'),
                trailing: const Icon(Icons.keyboard_arrow_right_outlined),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
