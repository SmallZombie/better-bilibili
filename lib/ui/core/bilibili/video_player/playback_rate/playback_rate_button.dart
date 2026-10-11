import 'package:better_bilibili/ui/core/bilibili/video_player/extra_video_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/extra_video_player.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/playback_rate/playback_rate_panel.dart';
import 'package:material_ui/material_ui.dart';

class PlaybackRateButton extends StatelessWidget {
  final ExtraVideoController controller;
  final PanelController panelController;

  const PlaybackRateButton({super.key, required this.controller, required this.panelController});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: controller.stream.rate,
      initialData: controller.state.rate,
      builder: (context, asyncSnapshot) {
        final rate = asyncSnapshot.data!;
        return ControlButton(
          label: '${rate}x',
          onPressed: () => panelController.push(
            PlaybackRatePanel(
              controller: controller,
              panelController: panelController,
            ),
          ),
        );
      },
    );
  }
}
