import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/panel_header.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/panel_tile.dart';
import 'package:flutter/material.dart';

class QualityPanelLabel {
  final int id;
  final String? title;
  final String? subtitle;
  final Widget? leading;

  const QualityPanelLabel({
    required this.id,
    this.title,
    this.subtitle,
    this.leading,
  });
}

class QualityPanelValues {
  final int video;
  final int? audio;

  const QualityPanelValues({required this.video, this.audio});
}

class QualityPanel extends StatelessWidget {
  final List<QualityPanelLabel> videoLabels;
  final List<QualityPanelLabel> audioLabels;
  final QualityPanelValues values;
  final VoidCallback? onBack;
  final ValueChanged<QualityPanelValues>? onChange;

  const QualityPanel({
    super.key,
    required this.videoLabels,
    required this.audioLabels,
    required this.values,
    this.onBack,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> videoChildren = [];
    final List<Widget> audioChildren = [];
    for (final i in videoLabels) {
      videoChildren.add(
        PanelTile(
          onTap: () => onChange?.call(QualityPanelValues(video: i.id, audio: values.audio)),
          selected: i.id == values.video,
          title: Text(i.title ?? i.id.toString()),
          subtitle: i.subtitle != null ? Text(i.subtitle!) : null,
        ),
      );
    }
    for (final i in audioLabels) {
      audioChildren.add(
        PanelTile(
          onTap: () => onChange?.call(QualityPanelValues(video: values.video, audio: i.id)),
          selected: i.id == values.audio,
          title: Text(i.title ?? i.id.toString()),
          subtitle: i.subtitle != null ? Text(i.subtitle!) : null,
        ),
      );
    }

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
          PanelHeader(title: Text('选择流'), onBack: onBack),
          Expanded(
            child: Row(
              children: [
                Expanded(child: ListView(children: videoChildren)),
                const Divider(),
                Expanded(child: ListView(children: audioChildren)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
