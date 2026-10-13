import 'dart:math';

import 'package:better_bilibili/config/eagle_config.dart';
import 'package:better_bilibili/data/repositories/eagle/eagle_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/uploaded_image.dart';
import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:better_bilibili/ui/core/bilibili/movie/movie_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/tier_required_prompt.dart';
import 'package:better_bilibili/ui/core/bilibili/video/video_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/post/post_feed_tile/post_feed_tile_view_model.dart';
import 'package:better_bilibili/ui/core/bilibili/post/post_tile.dart';
import 'package:better_bilibili/ui/core/share/image_viewer.dart';
import 'package:better_bilibili/ui/core/share/image_wapper.dart';
import 'package:better_bilibili/ui/core/share/mini_text_button.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PostFeedTile extends StatelessWidget {
  final PostFeedTileViewModel viewModel;
  final EagleConfig eagleConfig;
  final EagleRepository eagleRepository;
  final bool compact;

  const PostFeedTile({
    super.key,
    required this.viewModel,
    required this.eagleConfig,
    required this.eagleRepository,
    this.compact = false,
  });

  String getSourceUrl() {
    return eagleConfig.useExternalLinks.value
        ? 'https://www.bilibili.com/opus/${viewModel.post.id}'
        : 'bilibili://post/${viewModel.post.id}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final vm = context.watch<PostFeedTileViewModel>();

    final List<Widget> children = [];

    if (vm.post.title != null) {
      children.add(
        SelectableText(
          vm.post.title!,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    if (vm.post.content != null) {
      children.add(
        InkWell(
          onTap: () => context.push(Routes.buildPostDetail(vm.post.id)),
          child: Text(vm.post.content!),
        ),
      );
    }

    if (vm.post.images.isNotEmpty) {
      children.add(
        _ImageGroup(
          images: vm.post.images,
          eagleConfig: eagleConfig,
          eagleRepository: eagleRepository,
          getSourceUrl: getSourceUrl,
        ),
      );
    }

    if (vm.post.hashTag != null) {
      children.add(Text(vm.post.hashTag!.name));
    }

    if (vm.post.relatedVideo != null) {
      children.add(const SizedBox(height: 8.0));
      children.add(
        _buildTitledPart(
          context,
          '发布视频',
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: colorScheme.surfaceContainerLow,
            ),
            child: VideoTile(
              videoId: vm.post.relatedVideo!.id,
              title: vm.post.relatedVideo!.title,
              cover: vm.post.relatedVideo!.cover,
              nickname: vm.post.relatedVideo!.owner.nickname,
              duration: vm.post.relatedVideo!.duration,
              viewCount: vm.post.relatedVideo!.stats.view,
              danmakuCount: vm.post.relatedVideo!.stats.danmaku,
            ),
          ),
        ),
      );
    }

    if (vm.post.relatedArticle != null) {
      final article = vm.post.relatedArticle!;
      children.add(const SizedBox(height: 8.0));
      children.add(
        _buildTitledPart(
          context,
          '发布文章',
          PostTile(
            postId: article.id,
            cover: article.cover,
            title: article.title,
            summary: article.summary,
            nickname: article.owner.nickname,
          ),
        ),
      );
    }

    if (vm.post.relatedGame != null) {
      children.add(const SizedBox(height: 8.0));
      _buildTitledPart(
        context,
        '相关游戏',
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: colorScheme.surfaceContainerLow,
          ),
          child: Row(
            children: [
              ImageWapper(
                image: NetworkImage(vm.post.relatedGame!.cover),
                width: 60,
                height: 60,
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vm.post.relatedGame!.name),
                  Text(
                    vm.post.relatedGame!.description,
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.outline, fontSize: 12.0),
                  ),
                  Text(
                    vm.post.relatedGame!.tags.join('/'),
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.outline, fontSize: 12.0),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (vm.post.quotedPost != null) {
      children.add(const SizedBox(height: 8.0));
      children.add(
        _buildTitledPart(
          context,
          '转发动态',
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: colorScheme.outline.withAlpha(50)),
            ),
            child: ChangeNotifierProvider(
              create: (context) => PostFeedTileViewModel(postRepository: context.read(), post: vm.post.quotedPost!),
              builder: (context, _) => PostFeedTile(
                viewModel: context.read(),
                eagleConfig: eagleConfig,
                eagleRepository: eagleRepository,
                compact: true,
              ),
            ),
          ),
        ),
      );
    }

    if (vm.post.relatedCollection != null) {
      final collection = vm.post.relatedCollection!;
      children.add(const SizedBox(height: 8.0));
      children.add(
        _buildTitledPart(
          context,
          '更新合集 · ${collection.name}',
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: colorScheme.surfaceContainerLow,
            ),
            child: VideoTile(
              videoId: collection.videoId,
              title: collection.videoTitle,
              cover: collection.videoCover,
              nickname: collection.videoOwner.nickname,
              duration: collection.videoDuration,
              viewCount: collection.videoViewCount,
              danmakuCount: collection.videoDanmakuCount,
            ),
          ),
        ),
      );
    }

    if (vm.post.relatedMovie != null) {
      final movie = vm.post.relatedMovie!;
      children.add(const SizedBox(height: 8.0));
      children.add(
        _buildTitledPart(
          context,
          '番剧更新',
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: colorScheme.surfaceContainerLow,
            ),
            child: MovieTile(
              movieId: movie.id,
              title: movie.title,
              cover: movie.cover,
              viewCount: movie.stats.view,
              danmakuCount: movie.stats.danmaku,
            ),
          ),
        ),
      );
    }

    if (vm.post.requiredTier != null) {
      children.add(
        _buildTitledPart(
          context,
          '赞助者专属',
          TierRequiredPrompt(requiredTier: vm.post.requiredTier!),
        ),
      );
    }

    late Widget content;
    if (compact) {
      content = Column(
        crossAxisAlignment: .start,
        spacing: 2.0,
        children: [
          Row(
            crossAxisAlignment: .center,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircleAvatar(backgroundImage: NetworkImage(vm.post.owner.avatar)),
              ),
              SizedBox(width: 8.0),
              MiniTextButton(
                onTap: vm.post.owner.id == null ? null : () => context.push(Routes.buildUserDetail(vm.post.owner.id!)),
                child: Text('@${vm.post.owner.nickname}'),
              ),
              Text(
                ' · ',
                style: TextStyle(color: colorScheme.outline, fontSize: 12.0),
              ),
              Text(
                formatTimeToHumanReadable(vm.post.creationTime),
                style: TextStyle(color: colorScheme.outline, fontSize: 12.0),
              ),
            ],
          ),
          ...children,
        ],
      );
    } else {
      content = Row(
        crossAxisAlignment: .start,
        spacing: 8.0,
        children: [
          CircleAvatar(backgroundImage: NetworkImage(vm.post.owner.avatar)),
          Expanded(
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: [
                Row(
                  spacing: 4.0,
                  children: [
                    MiniTextButton(
                      onTap: vm.post.owner.id == null ? null : () => context.push(Routes.buildUserDetail(vm.post.owner.id!)),
                      child: Text('@${vm.post.owner.nickname}'),
                    ),
                    Text(
                      formatTimeToHumanReadable(vm.post.creationTime),
                      style: TextStyle(color: colorScheme.outline, fontSize: 12.0),
                    ),
                  ],
                ),
                ...children,
                Padding(
                  padding: const .only(top: 10.0),
                  child: Selector<PostFeedTileViewModel, ({bool hasLiked, int likeCount})>(
                    selector: (context, vm) => (hasLiked: vm.post.isLiked, likeCount: vm.post.stats!.like),
                    builder: (context, state, child) => _PostAction(
                      shareCount: vm.post.stats!.share,
                      commentCount: vm.post.stats!.comment,
                      likeCount: state.likeCount,
                      hasLiked: state.hasLiked,
                      onTapLike: vm.like.execute,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.all(compact ? 6.0 : 12.0),
      child: content,
    );
  }

  Widget _buildTitledPart(BuildContext context, String title, Widget child) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4.0,
      children: [
        Text(
          title,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 13.0,
            color: colorScheme.outline,
          ),
        ),
        child,
      ],
    );
  }
}

class _ImageGroup extends StatelessWidget {
  final List<UploadedImage> images;
  final EagleConfig eagleConfig;
  final EagleRepository eagleRepository;
  final String Function() getSourceUrl;

  static const _gap = 4.0;
  static const _suffix = '@600h'; // @406h

  const _ImageGroup({
    required this.images,
    required this.eagleConfig,
    required this.eagleRepository,
    required this.getSourceUrl,
  });

  String _getThumbUrl(String url) {
    return '$url$_suffix';
  }

  void _onTap(BuildContext context, int index) {
    context.openImageViewer(
      images.map((v) => ImageViewerItem(thumbUrl: _getThumbUrl(v.src), url: v.src, width: v.width, height: v.height)).toList(),
      initialIndex: index,
      actionsBuilder: (context, image, index, images) {
        if (!eagleConfig.enable.value) return [];

        return eagleRepository.imageViewerActionsBuilder(
          context: context,
          image: image,
          index: index,
          images: images,
          sourceUrl: getSourceUrl(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = min(MediaQuery.sizeOf(context).height * 0.3, 500.0);

    Widget widget;
    if (images.length == 1) {
      final image = images.first;

      widget = GestureDetector(
        onTap: () => _onTap(context, 0),
        child: Hero(
          tag: _getThumbUrl(image.src),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double height = min(image.height.toDouble(), maxHeight);
              double width = height * (image.width / image.height);

              if (width > constraints.maxWidth) {
                width = constraints.maxWidth;
                height = width * (image.height / image.width);
              }

              return BiliImageWapper(
                url: image.src,
                suffix: _suffix,
                width: width,
                height: height,
              );
            },
          ),
        ),
      );
    } else if (images.length == 2) {
      widget = LayoutBuilder(
        builder: (context, constraints) {
          final height = (min(constraints.maxWidth, constraints.maxHeight) - _gap) / 2.0;

          final List<Widget> children = [];
          for (int i = 0; i < images.length; i++) {
            children.add(
              _buildImage(
                context,
                image: images[i],
                index: i,
                width: height,
                height: height,
              ),
            );
          }

          return Row(spacing: _gap, children: children);
        },
      );
    } else if (images.length == 3) {
      final List<Widget> children = [];
      for (int i = 1; i < images.length; i++) {
        children.add(
          Expanded(
            child: _buildImage(
              context,
              image: images[i],
              index: i,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        );
      }

      widget = Row(
        spacing: _gap,
        children: [
          Expanded(
            child: _buildImage(
              context,
              image: images.first,
              index: 0,
              height: maxHeight,
            ),
          ),
          Expanded(
            child: SizedBox(
              height: maxHeight,
              child: Column(spacing: _gap, children: children),
            ),
          ),
        ],
      );
    } else if (images.length == 4) {
      widget = _buildGrid(context, 2);
    } else if (images.length <= 9) {
      widget = _buildGrid(context, 3);
    } else {
      final height = min(
        images.reduce((current, next) => current.height > next.height ? current : next).height.toDouble(),
        maxHeight,
      );

      widget = ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {.mouse, .touch}),
        child: SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            separatorBuilder: (_, _) => SizedBox(width: _gap),
            itemBuilder: (context, index) {
              final item = images[index];
              return _buildImage(
                context,
                image: item,
                index: index,
                // width: height,
                height: height,
              );
            },
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const .all(.circular(8.0)),
      child: widget,
    );
  }

  Widget _buildImage(
    BuildContext context, {
    required UploadedImage image,
    required int index,
    double? width,
    double? height,
  }) {
    return GestureDetector(
      onTap: () => _onTap(context, index),
      child: Hero(
        tag: _getThumbUrl(image.src),
        child: BiliImageWapper(
          url: image.src,
          suffix: _suffix,
          width: width,
          height: height,
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, int crossAxisCount) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rowCount = (images.length / crossAxisCount).ceil();
        final maxByWidth = (constraints.maxWidth - _gap * (crossAxisCount - 1)) / crossAxisCount;
        final maxByHeight = (constraints.maxHeight - _gap * (rowCount - 1)) / rowCount;
        final cellSize = min(maxByWidth, maxByHeight);

        return Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          spacing: _gap,
          children: [
            for (var r = 0; r < rowCount; r++)
              Row(
                mainAxisSize: .min,
                spacing: _gap,
                children: [
                  for (var c = 0; c < crossAxisCount && r * crossAxisCount + c < images.length; c++)
                    SizedBox(
                      width: cellSize,
                      height: cellSize,
                      child: _buildImage(context, image: images[r * crossAxisCount + c], index: r * crossAxisCount + c),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _PostAction extends StatelessWidget {
  final int shareCount;
  final int commentCount;
  final int likeCount;
  final bool hasShared;
  final bool hasCommented;
  final bool hasLiked;
  final VoidCallback? onTapLike;

  const _PostAction({
    required this.shareCount,
    required this.commentCount,
    required this.likeCount,
    this.hasShared = false,
    this.hasCommented = false,
    this.hasLiked = false,
    this.onTapLike,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: () {},
          icon: Icon(
            Icons.share_outlined,
            color: hasShared ? colorScheme.primary : colorScheme.outline,
          ),
          label: Text(
            '分享',
            style: TextStyle(
              color: hasShared ? colorScheme.primary : colorScheme.outline,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: () {},
          icon: Icon(Icons.format_quote_outlined, color: colorScheme.outline),
          label: Text(
            shareCount == 0 ? '引用' : formatCountToHumanReadable(shareCount),
            style: TextStyle(color: colorScheme.outline),
          ),
        ),
        TextButton.icon(
          onPressed: () {},
          icon: Icon(
            Icons.comment_outlined,
            color: hasCommented ? colorScheme.primary : colorScheme.outline,
          ),
          label: Text(
            commentCount == 0 ? '评论' : formatCountToHumanReadable(commentCount),
            style: TextStyle(
              color: hasCommented ? colorScheme.primary : colorScheme.outline,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onTapLike,
          icon: Icon(
            hasLiked ? Icons.thumb_up_alt_rounded : Icons.thumb_up_outlined,
            color: hasLiked ? colorScheme.primary : colorScheme.outline,
          ),
          label: Text(
            likeCount == 0 ? '赞' : formatCountToHumanReadable(likeCount),
            style: TextStyle(
              color: hasLiked ? colorScheme.primary : colorScheme.outline,
            ),
          ),
        ),
      ],
    );
  }
}
