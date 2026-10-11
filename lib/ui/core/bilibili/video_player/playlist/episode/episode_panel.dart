import 'package:better_bilibili/data/services/bilibili/model/get_video_detail_response.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/playlist/episode/bili_episode_controller.dart';
import 'package:material_ui/material_ui.dart';

class EpisodePanel implements Panel {
  final BiliEpisodeController controller;

  const EpisodePanel(this.controller);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => ListView.builder(
        itemCount: controller.episodes.length,
        itemBuilder: (context, index) {
          final video = controller.episodes[index];
          return _Item(
            video: video,
            active: index == controller.index,
            onTap: () => controller.play(video),
          );
        },
      ),
    );
  }

  @override
  String get id => 'collection';

  @override
  double get width => 360;
}

class _Item extends StatelessWidget {
  final VideoDetailEpisode video;
  final VoidCallback onTap;
  final bool active;

  const _Item({
    required this.video,
    required this.onTap,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: active ? () {} : onTap,
      child: Padding(
        padding: const .symmetric(horizontal: 12.0, vertical: 6.0),
        child: Row(
          crossAxisAlignment: .start,
          spacing: 6.0,
          children: [
            BiliImageWapper(
              url: video.cover,
              width: 120,
              aspectRatio: 16 / 9,
              borderRadius: .circular(8.0),
            ),
            Expanded(
              child: Text(
                video.title,
                style: TextStyle(color: active ? colorScheme.primary : Colors.white),
                maxLines: 3,
                overflow: .ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
