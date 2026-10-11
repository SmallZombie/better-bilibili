import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_user_avatar.dart';
import 'package:better_bilibili/ui/core/bilibili/video/video_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/post/post_tile.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_quill/flutter_quill.dart';

const String kThumbnailSuffix = '@1280w_720h_1c';
const double kCardMaxWidth = 500.0;

class ImageEmbedBuilder extends EmbedBuilder {
  @override
  String get key => BlockEmbed.imageType;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final colorScheme = Theme.of(context).colorScheme;
    final image = embedContext.node.value.data;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BiliImageWapper(
            url: image['url'],
            suffix: '@1192w',
            borderRadius: BorderRadius.circular(16.0),
          ),
          if (image['alt'] != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SelectableText(image['alt'], style: TextStyle(color: colorScheme.outline)),
            ),
        ],
      ),
    );
  }
}

class VideoCardEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'videoCard';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final colorScheme = Theme.of(context).colorScheme;
    final video = embedContext.node.value.data;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: kCardMaxWidth),
        child: VideoTile(
          videoId: video['id'],
          episodeId: video['episodeId'],
          title: video['title'],
          cover: video['cover'],
          viewCount: video['viewCount'],
          danmakuCount: video['danmakuCount'],
          duration: video['duration'],
          style: VideoTileStyle(backgroundColor: colorScheme.surfaceContainer),
        ),
      ),
    );
  }
}

class PostCardEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'postCard';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final colorScheme = Theme.of(context).colorScheme;
    final post = embedContext.node.value.data;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: kCardMaxWidth),
        child: PostTile(
          postId: post['id'],
          title: post['title'],
          summary: post['summary'],
          cover: post['cover'],
          style: PostTileStyle(backgroundColor: colorScheme.surfaceContainer),
        ),
      ),
    );
  }
}

class UserEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'user';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = embedContext.node.value.data;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: kCardMaxWidth),
        child: Material(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8.0,
              children: [
                BiliUserAvatar(url: user['avatar']),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['nickname'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16.0),
                      ),
                      Text(
                        user['description'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colorScheme.outline),
                      ),
                    ],
                  ),
                ),
                FilledButton(onPressed: () {}, child: const Text('关注')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DividerEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'divider';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: const Divider(),
    );
  }
}

class InnerUserEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'inner_user';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = embedContext.node.value.data;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BiliUserAvatar(url: user['avatar'], size: 24.0),
            Text(user['nickname']),
            SizedBox(width: 6.0),
          ],
        ),
      ),
    );
  }
}
