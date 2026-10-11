import 'package:better_bilibili/data/services/bilibili/model/get_playlist_videos_response.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/playlist/playlist/bili_playlist_controller.dart';
import 'package:material_ui/material_ui.dart';

class PlaylistPanel implements Panel {
  final BiliPlaylistController controller;

  const PlaylistPanel(this.controller);

  bool _onScroll(ScrollNotification notification) {
    final metrics = notification.metrics;

    // 向前加载更多
    if (metrics.pixels <= 0 && !controller.loadMoreBefore.running && controller.hasMoreBefore) {
      controller.loadMoreBefore.execute();
    }

    // 向后加载更多
    if (metrics.maxScrollExtent - metrics.pixels <= 400 && !controller.loadMoreAfter.running && controller.hasMoreAfter) {
      controller.loadMoreAfter.execute();
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => ListView.builder(
          itemCount: controller.videos.length,
          itemBuilder: (context, index) {
            final video = controller.videos[index];
            return _Item(
              video: video,
              active: video.id == controller.currentVideoId,
              onTap: () => controller.play(video),
            );
          },
        ),
      ),
    );
  }

  @override
  String get id => 'collection';

  @override
  double get width => 360;
}

class _Item extends StatelessWidget {
  final PlaylistVideo video;
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
