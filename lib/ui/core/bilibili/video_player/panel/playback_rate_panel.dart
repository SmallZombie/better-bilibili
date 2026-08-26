import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/panel_header.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/panel_tile.dart';
import 'package:flutter/material.dart';

const _labels = [0.1, 0.2, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0];

class PlaybackRatePanel extends StatefulWidget {
  final double value;
  final VoidCallback? onBack;
  final ValueChanged<double>? onChange;

  const PlaybackRatePanel({
    super.key,
    required this.value,
    this.onBack,
    this.onChange,
  });

  @override
  State<PlaybackRatePanel> createState() => _PlaybackRatePanelState();
}

class _PlaybackRatePanelState extends State<PlaybackRatePanel> {
  bool _hasSelectedCustom = false;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];
    for (final i in _labels) {
      children.add(
        PanelTile(
          onTap: () => widget.onChange?.call(i),
          selected: !_hasSelectedCustom && i == widget.value,
          title: Text('${i.toString()}x'),
        ),
      );
    }

    children.add(
      PanelTile(
        onTap: () => setState(() => _hasSelectedCustom = true),
        title: const Text('自定义'),
        selected: _hasSelectedCustom,
        trailing: Icon(
          Icons.keyboard_arrow_right_outlined,
          color: Colors.white.withAlpha(120),
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: .only(
          topLeft: .circular(16.0),
          bottomLeft: .circular(16.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          PanelHeader(title: Text('播放速度'), onBack: widget.onBack),
          Expanded(child: ListView(children: children)),
        ],
      ),
    );
  }
}
