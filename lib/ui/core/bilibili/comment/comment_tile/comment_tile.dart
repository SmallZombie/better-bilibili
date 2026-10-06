import 'dart:ui';

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
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CommentTile extends StatefulWidget {
  final ValueChanged<Comment> onReply;
  final ValueChanged<Comment> onDelete;
  final bool compact;
  final Function(int episodeIndex, Duration time)? onTapTime;

  const CommentTile({
    super.key,
    required this.onReply,
    required this.onDelete,
    this.compact = false,
    this.onTapTime,
  });

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  late final CommentTileViewModel _viewModel;

  bool _isExpandedMoreReplies = false;

  @override
  void initState() {
    super.initState();

    _viewModel = context.read();
    _viewModel.like.addListener(_onResult);
    _viewModel.dislike.addListener(_onResult);
  }

  @override
  void dispose() {
    _viewModel.like.removeListener(_onResult);
    _viewModel.dislike.removeListener(_onResult);

    super.dispose();
  }

  void _onResult() {
    if (_viewModel.like.error) {
      context.showError('赞失败: ${(_viewModel.like.result as Error).toString()}');
      _viewModel.like.clearResult();
    }
    if (_viewModel.dislike.error) {
      context.showError('踩失败: ${(_viewModel.dislike.result as Error).toString()}');
      _viewModel.dislike.clearResult();
    }
  }

  Future<void> _onLike() async {
    _viewModel.like.execute();
  }

  Future<void> _onDislike() async {
    _viewModel.dislike.execute();
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

  void _onTapImage(int index) {
    context.openImageViewer(
      images: _viewModel.comment.content.images.map((v) {
        return ImageViewerItem(
          thumbUrl: '$v@478w_270h_1s',
          url: v,
          heroTag: ImageViewerItem.defaultHeroTag(v),
        );
      }).toList(),
      initialIndex: index,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final comment = _viewModel.comment;
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
                                      tag: ImageViewerItem.defaultHeroTag(image),
                                      createRectTween: (begin, end) => RectTween(begin: begin, end: end),
                                      child: BiliImageWapper(
                                        url: image,
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
                          listenable: Listenable.merge([_viewModel.like, _viewModel.dislike]),
                          builder: (context, child) {
                            final isLiked = _viewModel.comment.isLiked;
                            final likeCount = _viewModel.comment.likeCount;

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
                          listenable: Listenable.merge([_viewModel.like, _viewModel.dislike]),
                          builder: (context, child) {
                            final isDisliked = _viewModel.comment.isDisliked;
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
            listenable: _viewModel.getReplies,
            builder: (context, child) => _buildReplies(),
          ),
        ],
      ),
    );
  }

  Widget _buildReplies() {
    final colorScheme = Theme.of(context).colorScheme;
    final comment = _viewModel.comment;
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
                child: CommentTile(
                  onReply: widget.onReply,
                  onDelete: widget.onDelete,
                  compact: true,
                  onTapTime: widget.onTapTime,
                ),
              ),
            ),
          if (_viewModel.getReplies.running)
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
                      if (moreRepliesCount > 0) _viewModel.getReplies.execute();
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
          if (_viewModel.getReplies.error)
            CenterErrorMessage(
              errorMessage: _viewModel.getReplies.result.toString(),
              onRetry: _viewModel.getReplies.execute,
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
