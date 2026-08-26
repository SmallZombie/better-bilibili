import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/panel_header.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/panel_tile.dart';
import 'package:flutter/material.dart';

class CodecSelectionPanel extends StatelessWidget {
  final VoidCallback? onBack;

  const CodecSelectionPanel({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        PanelHeader(title: const Text('选择编码'), onBack: onBack),
        Expanded(
          child: ListView(
            children: [
              PanelTile(onTap: () {}, selected: true, title: const Text('AVC')),
              PanelTile(onTap: () {}, title: const Text('H.264')),
              PanelTile(onTap: () {}, title: const Text('H.265')),
              PanelTile(onTap: () {}, title: const Text('AV1')),
              PanelTile(onTap: () {}, title: const Text('H.266')),
            ],
          ),
        ),
      ],
    );
  }
}
