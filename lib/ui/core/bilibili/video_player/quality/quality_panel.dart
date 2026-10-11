import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_header.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/quality/bili_quality_controller.dart';
import 'package:material_ui/material_ui.dart';

class QualityPanel implements Panel {
  final BiliQualityController controller;
  final PanelController panelController;

  const QualityPanel({required this.controller, required this.panelController});

  @override
  Widget build(BuildContext context) {
    if (controller.state.videoStream == null || controller.state.audioStream == null) {
      return SizedBox.shrink();
    }

    return StreamBuilder(
      stream: controller.stream.videoStream,
      initialData: controller.state.videoStream,
      builder: (context, asyncSnapshot) {
        final videoStream = asyncSnapshot.data;
        return StreamBuilder(
          stream: controller.stream.audioStream,
          initialData: controller.state.audioStream,
          builder: (context, asyncSnapshot) {
            final audioStream = asyncSnapshot.data;

            if (videoStream == null && audioStream == null) {
              return SizedBox.shrink();
            }

            final List<Widget> videoLabels = [];
            final List<Widget> audioLabels = [];

            for (final i in controller.availableVideoStreamsByCodec) {
              final subtitle = controller.getQualityDisplaySubtitle(i.id);
              videoLabels.add(
                PanelTile(
                  onTap: () => controller.switchQuality(video: i, audio: audioStream),
                  selected: videoStream?.id == i.id,
                  title: Text(controller.getQualityDisplayName(i.id)),
                  subtitle: subtitle != null ? Text(subtitle) : null,
                ),
              );
            }
            for (final i in controller.availableAudioStreamsByCodec) {
              final subtitle = controller.getQualityDisplaySubtitle(i.id);
              audioLabels.add(
                PanelTile(
                  onTap: () => controller.switchQuality(video: videoStream, audio: i),
                  selected: audioStream?.id == i.id,
                  title: Text(controller.getQualityDisplayName(i.id)),
                  subtitle: subtitle != null ? Text(subtitle) : null,
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
                  PanelHeader(title: Text('选择流'), onBack: panelController.pop),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: ListView(children: videoLabels)),
                        const Divider(),
                        Expanded(child: ListView(children: audioLabels)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  String get id => 'quality';

  @override
  double get width => 310;
}
