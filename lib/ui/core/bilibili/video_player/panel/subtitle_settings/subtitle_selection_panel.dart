import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/panel_header.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/panel_tile.dart';
import 'package:flutter/material.dart';

class SubtitleSelectionPanel extends StatelessWidget {
  final VoidCallback? onBack;

  const SubtitleSelectionPanel({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(160),
        borderRadius: .only(
          topLeft: .circular(8.0),
          bottomLeft: .circular(8.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          PanelHeader(title: Text('选择字幕'), onBack: onBack),
          Expanded(
            child: ListView(
              children: [
                PanelTile(
                  onTap: () {},
                  selected: true,
                  title: const Text('简体中文'),
                ),
                PanelTile(
                  onTap: () {},
                  title: const Text('简体中文(自动生成)'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
