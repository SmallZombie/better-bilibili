import 'dart:async';

import 'package:better_bilibili/config/app_config.dart';
import 'package:better_bilibili/config/constants.dart';
import 'package:better_bilibili/config/eagle_config.dart';
import 'package:better_bilibili/data/repositories/eagle/eagle_repository.dart';
import 'package:better_bilibili/data/services/network_manager.dart';
import 'package:better_bilibili/domain/models/bilibili/comment.dart';
import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_user_avatar.dart';
import 'package:better_bilibili/ui/core/bilibili/comment/comment_report_sheet/comment_report_sheet.dart';
import 'package:better_bilibili/ui/core/bilibili/comment/comment_tile/comment_tile_view_model.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/bili_rich_text_wapper.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/jump_progress_parse_node.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/link_parse_node.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/sticker_parse_node.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/unknown_link_parse_node.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/user_parse_node.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/image_viewer.dart';
import 'package:better_bilibili/ui/core/share/mini_text_button.dart';
import 'package:better_bilibili/ui/core/share/open_url.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:better_bilibili/utils/bilibili/bili_util.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CommentTile extends StatefulWidget {
  final CommentTileViewModel viewModel;
  final AppConfig appConfig;
  final NetworkManager networkManager;
  final EagleConfig eagleConfig;
  final EagleRepository eagleRepository;
  final ValueChanged<Comment> onReply;
  final ValueChanged<Comment> onDelete;
  final bool compact;
  final Function(int episodeIndex, Duration time)? onTapTime;

  const CommentTile({
    super.key,
    required this.viewModel,
    required this.appConfig,
    required this.networkManager,
    required this.eagleConfig,
    required this.eagleRepository,
    required this.onReply,
    required this.onDelete,
    this.compact = false,
    this.onTapTime,
  });

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  CommentTileViewModel get viewModel => widget.viewModel;
  AppConfig get appConfig => widget.appConfig;
  NetworkManager get networkManager => widget.networkManager;
  EagleConfig get eagleConfig => widget.eagleConfig;
  EagleRepository get eagleRepository => widget.eagleRepository;
  Comment get comment => widget.viewModel.comment;

  bool _isExpandedMoreReplies = false;

  @override
  void initState() {
    super.initState();

    viewModel.like.addListener(_onResult);
    viewModel.dislike.addListener(_onResult);
  }

  @override
  void dispose() {
    viewModel.like.removeListener(_onResult);
    viewModel.dislike.removeListener(_onResult);

    super.dispose();
  }

  void _onResult() {
    if (viewModel.like.error) {
      context.showError('赞失败: ${(viewModel.like.result as Error).toString()}');
      viewModel.like.clearResult();
    }
    if (viewModel.dislike.error) {
      context.showError('踩失败: ${(viewModel.dislike.result as Error).toString()}');
      viewModel.dislike.clearResult();
    }
  }

  Future<void> _onLike() async {
    unawaited(viewModel.like.execute());
  }

  Future<void> _onDislike() async {
    unawaited(viewModel.dislike.execute());
  }

  void _onTapLink(String url) {
    debugPrint('tap: $url');
    context.openUrl(url);
  }

  void _onTapVideo(String avid) {
    context.push(Routes.buildVideoDetail(videoId: avid));
  }

  void _onTapUser(String userId) {
    context.push(Routes.buildUserDetail(userId));
  }

  String _getSourceUrl() {
    final useExternalLinks = eagleConfig.useExternalLinks.value;

    switch (comment.type) {
      case .video:
        // https://www.bilibili.com/video/BV1i36kBjESA#reply290270007472
        // https://www.bilibili.com/video/BV1i36kBjESA?comment_secondary_id=294166889552#reply294166889552
        if (useExternalLinks) {
          return 'https://www.bilibili.com/video/${av2bv(comment.contextId)}#reply${comment.id}';
        } else {
          return '$kAppDeepLinkScheme://video/${comment.contextId}?comment=${comment.id}';
        }
      case .article:
        // https://www.bilibili.com/read/cv25817263#reply315549751057
        // https://www.bilibili.com/read/cv25817263?comment_secondary_id=315753375793#reply315753375793
        if (useExternalLinks) {
          return 'https://www.bilibili.com/opus/${comment.contextId}#reply${comment.id}';
        } else {
          return '$kAppDeepLinkScheme://post/${comment.contextId}?comment=${comment.id}';
        }
      case _:
        return '';
    }
  }

  void _onTapImage(int index) {
    final images = viewModel.comment.content.images.map((v) {
      return ImageViewerItem(
        thumbUrl: _getThumbUrl(v.url),
        url: v.url,
        width: v.width,
        height: v.height,
      );
    }).toList();
    context.openImageViewer(
      images,
      initialIndex: index,
      shouldUseOriginalQuality: (ImageViewerItem image) {
        if (appConfig.viewOriginalImage.value == .always) {
          return true;
        }
        if (appConfig.viewOriginalImage.value == .never) {
          return false;
        }
        if (appConfig.viewOriginalImage.value == .auto) {
          if (image.width / 2 > _thumbWidth || image.height / 2 > _thumbHeight) {
            return true;
          }
          return false;
        }
        if (appConfig.viewOriginalImage.value == .wifiOnly) {
          return !networkManager.isMobileNetwork();
        }

        return false;
      },
      actionsBuilder: (context, image, index, images) {
        if (!eagleConfig.enable.value) return [];

        return eagleRepository.imageViewerActionsBuilder(
          context: context,
          image: image,
          index: index,
          images: images,
          sourceUrl: _getSourceUrl(),
        );
      },
    );
  }

  final _thumbWidth = 478;
  final _thumbHeight = 270;

  String _getThumbUrl(String url) {
    return '$url@${_thumbWidth}w_${_thumbHeight}h_1s';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final comment = viewModel.comment;
    final compact = widget.compact;

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 8 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头像
              BiliUserAvatar(
                url: comment.owner.avatar,
                frameImage: comment.owner.avatarFrame == null ? null : NetworkImage(comment.owner.avatarFrame!),
                size: compact ? 30.0 : 36.0,
                suffix: '@48w_48h_1s',
              ),
              SizedBox(width: compact ? 4 : 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 6.0,
                      children: [
                        // pin
                        if (comment.isPinned)
                          _Tag(
                            active: true,
                            tooltip: '此评论由上传者置顶',
                            child: const Text('PIN'),
                          ),

                        // uploader
                        if (comment.isSendByUploader)
                          _Tag(
                            active: true,
                            tooltip: '此评论由上传者发布',
                            child: const Text('UP'),
                          ),

                        // 用户名
                        MiniTextButton(
                          onTap: () => context.push(Routes.buildUserDetail(comment.owner.id)),
                          child: Text(
                            comment.owner.nickname,
                            style: TextStyle(fontSize: compact ? 12 : 14),
                          ),
                        ),

                        // 回复时间
                        Text(
                          formatTimeToHumanReadable(comment.creationTime),
                          style: TextStyle(fontSize: 12.0, color: colorScheme.outline),
                        ),

                        // ip属地
                        if (comment.region != null)
                          Text(
                            comment.region!,
                            style: TextStyle(fontSize: 12.0, color: colorScheme.outline),
                          ),
                      ],
                    ),

                    // 回复目标
                    if (comment.replyTarget != null)
                      InkWell(
                        onTap: () => context.push(Routes.buildUserDetail(comment.replyTarget!.id)),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                          child: Text(
                            '@${comment.replyTarget!.nickname}',
                            style: TextStyle(
                              fontSize: compact ? 12 : 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                    // 正文
                    SizedBox(height: compact ? 2 : 4),
                    Column(
                      crossAxisAlignment: .start,
                      children: [
                        if (comment.content.text != null)
                          BiliRichTextWapper(
                            rawText: comment.content.text!,
                            parserNodes: [
                              LinkParseNode(
                                primaryColor: colorScheme.primary,
                                links: comment.content.links,
                                onTap: _onTapLink,
                                onTapVideo: _onTapVideo,
                              ),
                              UserParseNode(
                                primaryColor: colorScheme.primary,
                                users: comment.content.users,
                                onTap: _onTapUser,
                              ),
                              UnknownLinkParseNode(
                                primaryColor: colorScheme.primary,
                                onTap: _onTapLink,
                                onTapVideo: _onTapVideo,
                                onTapUser: _onTapUser,
                              ),
                              if (widget.onTapTime != null)
                                JumpProgressParseNode(
                                  primaryColor: colorScheme.primary,
                                  onTap: widget.onTapTime!,
                                ),
                              StickerParseNode(stickers: comment.content.stickers),
                            ],
                            maxLines: 4,
                          ),
                        if (comment.content.images.isNotEmpty)
                          SizedBox(
                            height: 130,
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context).copyWith(
                                dragDevices: {.touch, .mouse},
                              ),
                              child: ListView.separated(
                                scrollDirection: .horizontal,
                                itemCount: comment.content.images.length,
                                itemBuilder: (context, index) {
                                  final image = comment.content.images[index];
                                  return GestureDetector(
                                    onTap: () => _onTapImage(index),
                                    child: Hero(
                                      tag: _getThumbUrl(image.url),
                                      createRectTween: (begin, end) => RectTween(begin: begin, end: end),
                                      child: BiliImageWapper(
                                        url: image.url,
                                        suffix: '@478w_270h_1s',
                                        borderRadius: .circular(4.0),
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) => const SizedBox(width: 4.0),
                              ),
                            ),
                          ),
                      ],
                    ),

                    // 功能区
                    SizedBox(height: compact ? 4 : 6),
                    Row(
                      spacing: 4.0,
                      children: [
                        // 赞
                        ListenableBuilder(
                          listenable: Listenable.merge([viewModel.like, viewModel.dislike]),
                          builder: (context, child) {
                            final isLiked = viewModel.comment.isLiked;
                            final likeCount = viewModel.comment.likeCount;

                            return MiniTextButton(
                              onTap: _onLike,
                              child: Row(
                                mainAxisSize: .min,
                                spacing: 2.0,
                                children: [
                                  Icon(
                                    isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                                    size: compact ? 13 : 15,
                                    color: isLiked ? colorScheme.primary : colorScheme.outline,
                                  ),
                                  if (likeCount > 0)
                                    Text(
                                      likeCount.toString(),
                                      style: TextStyle(
                                        fontSize: compact ? 12 : 13,
                                        color: isLiked ? colorScheme.primary : colorScheme.outline,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),

                        // 踩
                        ListenableBuilder(
                          listenable: Listenable.merge([viewModel.like, viewModel.dislike]),
                          builder: (context, child) {
                            final isDisliked = viewModel.comment.isDisliked;
                            return InkWell(
                              onTap: _onDislike,
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                child: Icon(
                                  isDisliked ? Icons.thumb_down : Icons.thumb_down_alt_outlined,
                                  size: compact ? 13 : 15,
                                  color: isDisliked ? colorScheme.primary : colorScheme.outline,
                                ),
                              ),
                            );
                          },
                        ),

                        // 回复
                        Padding(
                          padding: .only(left: compact ? 8 : 10),
                          child: MiniTextButton(
                            onTap: () => widget.onReply(comment),
                            child: Row(
                              mainAxisSize: .min,
                              spacing: 2.0,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: compact ? 13 : 15,
                                  color: colorScheme.outline,
                                ),
                                Text(
                                  '回复',
                                  style: TextStyle(
                                    fontSize: compact ? 12 : 13,
                                    color: colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 更多 - 删除、举报
                        const Spacer(),
                        SizedBox(
                          width: compact ? 24 : 28,
                          height: compact ? 24 : 28,
                          child: PopupMenuButton<String>(
                            itemBuilder: (context) => [
                              if (comment.isSendByMe)
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('删除'),
                                ),
                              const PopupMenuItem(
                                value: 'report',
                                child: Text('举报'),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'delete') {
                                widget.onDelete(comment);
                              } else if (value == 'report') {
                                context.showCommentReportSheet(
                                  contentType: comment.type,
                                  contentId: comment.contextId,
                                  commentId: comment.id,
                                );
                              }
                            },
                            icon: Icon(Icons.more_vert, size: compact ? 13 : 15, color: colorScheme.outline),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(
                              minWidth: 0,
                              minHeight: 0,
                            ),
                            splashRadius: compact ? 13 : 15,
                          ),
                        ),
                      ],
                    ),

                    // up赞过、早期粉丝、关注的人、互相关注
                    Row(
                      spacing: 8.0,
                      children: [
                        // up赞过
                        if (comment.islikedByUploader)
                          _Tag(
                            child: const Text(
                              'UP赞过',
                              style: TextStyle(fontSize: 12.0),
                            ),
                          ),

                        // up回复过
                        if (comment.isRepliedByUploader)
                          _Tag(
                            child: const Text(
                              'UP回复过',
                              style: TextStyle(fontSize: 12.0),
                            ),
                          ),

                        // 早期粉丝
                        if (comment.isEarlyFan)
                          _Tag(
                            child: const Text(
                              '早期粉丝',
                              style: TextStyle(fontSize: 12.0),
                            ),
                          ),

                        // 互相关注
                        if (comment.isMutualFollow)
                          _Tag(
                            child: const Text(
                              '互相关注',
                              style: TextStyle(fontSize: 12.0),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 回复
          ListenableBuilder(
            listenable: viewModel.getReplies,
            builder: (context, child) => _buildReplies(),
          ),
        ],
      ),
    );
  }

  Widget _buildReplies() {
    final colorScheme = Theme.of(context).colorScheme;
    final comment = viewModel.comment;
    final hasReplies = comment.replyCount > 0;
    final moreRepliesCount = comment.replyCount - comment.replies.length;

    return Padding(
      padding: const EdgeInsets.only(left: 42, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isExpandedMoreReplies)
            ...comment.replies.map(
              (reply) => ChangeNotifierProvider(
                key: ValueKey('reply-${comment.id}-${reply.id}'),
                create: (context) => CommentTileViewModel(commentRepository: context.read(), comment: reply),
                builder: (context, child) => CommentTile(
                  viewModel: context.read(),
                  appConfig: appConfig,
                  networkManager: networkManager,
                  eagleConfig: eagleConfig,
                  eagleRepository: eagleRepository,
                  onReply: widget.onReply,
                  onDelete: widget.onDelete,
                  compact: true,
                  onTapTime: widget.onTapTime,
                ),
              ),
            ),
          if (viewModel.getReplies.running)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (hasReplies)
            Row(
              children: [
                if (!_isExpandedMoreReplies || moreRepliesCount > 0)
                  InkWell(
                    onTap: () {
                      if (!_isExpandedMoreReplies) {
                        setState(() => _isExpandedMoreReplies = true);
                      }
                      if (moreRepliesCount > 0) viewModel.getReplies.execute();
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '展开${_isExpandedMoreReplies ? '更多' : ''} ${_isExpandedMoreReplies ? moreRepliesCount : comment.replyCount} 条回复',
                        style: TextStyle(fontSize: 12, color: colorScheme.primary),
                      ),
                    ),
                  ),

                if (_isExpandedMoreReplies) ...[
                  SizedBox(width: 8.0),
                  InkWell(
                    onTap: () => setState(() => _isExpandedMoreReplies = false),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '收起回复',
                        style: TextStyle(fontSize: 12, color: colorScheme.primary),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          if (viewModel.getReplies.error)
            CenterErrorMessage(
              errorMessage: viewModel.getReplies.result.toString(),
              onRetry: viewModel.getReplies.execute,
            ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final Widget child;
  final bool active;
  final String? tooltip;

  const _Tag({required this.child, this.active = false, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget widget = Container(
      decoration: BoxDecoration(
        borderRadius: .all(.circular(4.0)),
        color: active ? colorScheme.primaryContainer : colorScheme.surfaceContainer,
      ),
      padding: const .symmetric(horizontal: 6.0, vertical: 4.0),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: active ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
          fontSize: 10.0,
          height: 1.0,
        ),
        child: child,
      ),
    );

    if (tooltip != null) {
      widget = Tooltip(
        message: tooltip,
        child: widget,
      );
    }

    if (active) {}

    return widget;
  }
}
