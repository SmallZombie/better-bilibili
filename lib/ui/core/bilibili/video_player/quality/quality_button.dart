import 'package:better_bilibili/ui/core/bilibili/video_player/quality/quality_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/extra_video_player.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/quality/bili_quality_controller.dart';
import 'package:material_ui/material_ui.dart';

class QualityButton extends StatelessWidget {
  final PanelController panelController;
  final BiliQualityController qualityController;

  const QualityButton({
    super.key,
    required this.panelController,
    required this.qualityController,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: qualityController.stream.videoStream,
      initialData: qualityController.state.videoStream,
      builder: (context, asyncSnapshot) {
        final videoTrack = asyncSnapshot.data;
        if (videoTrack == null) {
          return ControlButton(
            label: '画质',
            onPressed: () => panelController.push(
              QualityPanel(
                controller: qualityController,
                panelController: panelController,
              ),
            ),
          );
        }

        return ControlButton(
          label: qualityController.getQualityDisplayName(videoTrack.id),
          onPressed: () => panelController.push(
            QualityPanel(
              controller: qualityController,
              panelController: panelController,
            ),
          ),
        );
      },
    );
  }
}
