import 'dart:async';
import 'dart:ui';

import 'package:better_bilibili/config/player_config.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_recommend_videos_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_video_detail_response.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/routing/app_route_observer.dart';
import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_user_avatar.dart';
import 'package:better_bilibili/ui/core/bilibili/collection/subscription_text_button.dart/subscription_collection_text_button.dart';
import 'package:better_bilibili/ui/core/bilibili/collection/subscription_text_button.dart/subscription_collection_text_button_view_model.dart';
import 'package:better_bilibili/ui/core/bilibili/user/follow_text_button/follow_text_button.dart';
import 'package:better_bilibili/ui/core/bilibili/user/follow_text_button/follow_text_button_view_model.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/bili_rich_text_wapper.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/jump_progress_parse_node.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/link_parse_node.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/resource_id_parse_node.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/unknown_link_parse_node.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/user_parse_node.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/bili_video_player.dart';
import 'package:better_bilibili/ui/core/bilibili/comment/comment_panel/comment_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/comment/comment_panel/comment_panel_view_model.dart';
import 'package:better_bilibili/ui/core/bilibili/favorite_folder/edit_video_in_favorite_folder_sheet/edit_video_in_favorite_folder_sheet.dart';
import 'package:better_bilibili/ui/core/bilibili/video/video_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/bili_video_player_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/danmaku_layer/danmaku_layer.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/history_reporter/bili_history_reporter_debug_layer.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/notice_layer/notice_controller.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/custom_icons.dart';
import 'package:better_bilibili/ui/core/share/image_wapper.dart';
import 'package:better_bilibili/ui/core/share/open_url.dart';
import 'package:better_bilibili/ui/core/share/router_helper.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/ui/video/view_models/playlist_tab_view_model.dart';
import 'package:better_bilibili/ui/video/view_models/video_detail_view_model.dart';
import 'package:better_bilibili/ui/video/widgets/playlist_tab.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:better_bilibili/utils/result.dart' as result;
import 'package:window_manager/window_manager.dart';

const double _kMinReserveBelow = 100.0;
const double _kMaxContentWidth = 2300.0;
const double _kMinCoverHeight = 350.0;
const EdgeInsets _kPagePadding = .fromLTRB(12.0, 12.0, 12.0, 0.0);
const double _kSidebarSpacing = 12.0;

/*
跳转逻辑:
- 点击推荐视频 -> 跳转到新页面
- 点击选集 -> 切换选集
- 点击列表内视频 -> 切换视频但不更新列表
- 点击合集内视频 -> 切换视频但不更新合集
- 当存在列表时点击合集视频 -> 跳转到新页面
- 当存在合集时点击列表视频 -> 切换视频但不更新列表
*/

class VideoDetailScreen extends StatefulWidget {
  final VideoDetailViewModel viewModel;

  const VideoDetailScreen({super.key, required this.viewModel});

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'VideoDetailScreen'));

  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();

    widget.viewModel.like.addListener(_onResult);
    widget.viewModel.coin.addListener(_onResult);
    widget.viewModel.favorite.addListener(_onResult);
    widget.viewModel.watchLater.addListener(_onResult);
    widget.viewModel.reload();

    _subscriptions.addAll([
      appRouteObserver.events.listen(_onRouteChanged),
    ]);
  }

  @override
  void dispose() {
    widget.viewModel.like.removeListener(_onResult);
    widget.viewModel.coin.removeListener(_onResult);
    widget.viewModel.favorite.removeListener(_onResult);
    widget.viewModel.watchLater.removeListener(_onResult);

    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    super.dispose();
  }

  void _onResult() {
    if (widget.viewModel.like.error) {
      context.showError(
        '${(widget.viewModel.interaction?.hasLiked ?? false) ? '取消赞' : '赞'}失败: ${widget.viewModel.like.result.toString()}',
      );
    }
    if (widget.viewModel.coin.error) {
      context.showError('投币失败: ${widget.viewModel.coin.result.toString()}');
    }
    if (widget.viewModel.favorite.error) {
      context.showError('收藏失败: ${widget.viewModel.favorite.result.toString()}');
    }
    if (widget.viewModel.watchLater.error) {
      context.showError('${widget.viewModel.isInWatchLater ? '取消' : '添加'}稍后观看失败: ${widget.viewModel.watchLater.result.toString()}');
    }
  }

  Future<void> _onCoin() async {
    if (widget.viewModel.interaction == null || widget.viewModel.interaction!.coinCount == 2) {
      return;
    }

    final selectedCount = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Text('投币(已投${widget.viewModel.interaction?.coinCount ?? 0}个)'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, 1),
              child: Row(
                children: [
                  ImageWapper(
                    image: AssetImage('assets/images/coin_1.png'),
                    width: 48.0,
                    aspectRatio: 1 / 1,
                  ),
                  const SizedBox(width: 8.0),
                  const Text('投 1 个币'),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: widget.viewModel.interaction?.coinCount == 1 ? null : () => Navigator.pop(ctx, 2),
              child: Row(
                children: [
                  ImageWapper(
                    image: AssetImage('assets/images/coin_2.png'),
                    width: 48.0,
                    aspectRatio: 1 / 1,
                  ),
                  const SizedBox(width: 8.0),
                  const Text('投 2 个币'),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (selectedCount == null) {
      return;
    }

    widget.viewModel.coin.execute(selectedCount);
  }

  Future<void> _onFavorite() async {
    final pickerResult = await context.showFavoritesPicker(
      videoId: widget.viewModel.videoId,
      multiSelect: true,
    );
    if (pickerResult == null || !pickerResult.hasChanges) return;

    widget.viewModel.favorite.execute(
      UpdateVideoFavoritesRequest(
        addFavoritesIds: pickerResult.addedIds.toList(growable: false),
        deleteFavoritesIds: pickerResult.removedIds.toList(growable: false),
        hasFavoritedAfter: pickerResult.selectedIds.isNotEmpty,
      ),
    );
  }

  Future<void> _onShare() async {
    final colorScheme = Theme.of(context).colorScheme;

    final rawUrl = 'https://www.bilibili.com/video/${widget.viewModel.detail?.bvid}';

    bool withTitle = false;
    bool withTimestamp = false;
    int fakeTimestamp = 123;

    final urlController = TextEditingController(text: rawUrl);
    void updateShareText(StateSetter setStateFn) {
      String shareUrl = rawUrl;
      if (withTimestamp) {
        shareUrl = '$shareUrl?t=$fakeTimestamp';
      }
      String result;
      if (withTitle) {
        result = '[${widget.viewModel.detail?.title}]($shareUrl)';
      } else {
        result = shareUrl;
      }
      setStateFn(() {
        urlController.text = result;
      });
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: MediaQuery.of(ctx).viewInsets.add(const EdgeInsets.fromLTRB(24, 24, 24, 28)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('分享', style: Theme.of(ctx).textTheme.titleMedium),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: urlController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: urlController.text));
                          context.showInfo('已复制到剪贴板');
                        },
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('复制', style: TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                  // 勾选框区域
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: withTitle,
                        onChanged: (val) {
                          withTitle = val ?? false;
                          updateShareText(setState);
                        },
                      ),
                      const Text('带标题'),
                      const SizedBox(width: 16),
                      Checkbox(
                        value: withTimestamp,
                        onChanged: (val) {
                          withTimestamp = val ?? false;
                          updateShareText(setState);
                        },
                      ),
                      const Text('带当前时间点'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 32,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              backgroundColor: colorScheme.primaryContainer,
                              child: Icon(Icons.forum_outlined, color: colorScheme.primary),
                            ),
                            const SizedBox(height: 4.0),
                            const Text('发帖', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              backgroundColor: colorScheme.primaryContainer,
                              child: Icon(Icons.send_outlined, color: colorScheme.primary),
                            ),
                            const SizedBox(height: 4.0),
                            const Text('私信', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          launchUrlString(
                            'mailto:?subject=${Uri.encodeComponent("来自 Bilibili 的分享")}&body=${Uri.encodeComponent(urlController.text)}',
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              backgroundColor: colorScheme.primaryContainer,
                              child: Icon(Icons.email_outlined, color: colorScheme.primary),
                            ),
                            const SizedBox(height: 4.0),
                            const Text('邮件', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(
                              text:
                                  '<iframe src="//player.bilibili.com/player.html?isOutside=true&aid=${widget.viewModel.videoId}&bvid=${widget.viewModel.detail?.bvid}&cid=${widget.viewModel.detail?.episodeId}&p=1" scrolling="no" border="0" frameborder="no" framespacing="0" allowfullscreen="true"></iframe>',
                            ),
                          );
                          context.showInfo('已复制到剪贴板');
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              backgroundColor: colorScheme.primaryContainer,
                              child: Icon(Icons.code_outlined, color: colorScheme.primary),
                            ),
                            const SizedBox(height: 4.0),
                            const Text('嵌入', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    urlController.dispose();
  }

  Future<void> _onDownload() async {}
  Future<void> _onReport() async {}

  int _depth = 0;

  void _onRouteChanged(AppRouteEvent event) {
    if (event is AppRoutePushEvent) {
      final name = event.route.settings.name;
      if (name == null) return;

      _depth++;

      if (_depth == 3) {
        widget.viewModel.disposePlayer();
      }
    } else if (event is AppRoutePopEvent) {
      final name = event.route.settings.name;
      if (name == null) return;

      _depth--;
    }
  }

  void _onTapTime(int episodeIndex, Duration time) {
    if (episodeIndex < 0 || episodeIndex > widget.viewModel.episodes.length - 1) {
      _log.i('[onTapTime] Invaild episodeIndex: $episodeIndex');
      return;
    }

    final episode = widget.viewModel.episodes[episodeIndex];

    final episodeBak = widget.viewModel.episodes.firstWhere((v) => v.episodeId == widget.viewModel.episodeId);
    final timeBak = widget.viewModel.videoController?.state.position ?? .zero;

    if (episode.episodeId != widget.viewModel.episodeId) {
      widget.viewModel.switchEpisode(episode, initPosition: time);
      widget.viewModel.videoController?.noticeController.show(
        Notice(
          content: Text('已转到 ${formatDuration(time)}'),
          action: '撤销',
          onTap: (self) {
            widget.viewModel.switchEpisode(episodeBak, initPosition: timeBak);
            widget.viewModel.videoController?.noticeController.dismiss(self);
          },
        ),
      );
    } else {
      widget.viewModel.videoController?.seek(time);
      widget.viewModel.videoController?.noticeController.show(
        Notice(
          content: Text('已转到 ${formatDuration(time)}'),
          action: '撤销',
          onTap: (self) {
            widget.viewModel.videoController?.seek(timeBak);
            widget.viewModel.videoController?.noticeController.dismiss(self);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListenableBuilder(
        listenable: widget.viewModel.getDetail,
        builder: (context, child) {
          if (widget.viewModel.getDetail.running &&
              widget.viewModel.cover == null &&
              widget.viewModel.collection == null &&
              widget.viewModel.playlistId == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (widget.viewModel.getDetail.error) {
            final msg = (widget.viewModel.getDetail.result as result.Error).toString();

            late final String errorMessage;
            if (msg.contains('62002')) {
              errorMessage = '视频不存在';
            } else if (msg.contains('62012')) {
              errorMessage = '此视频仅发布者可见';
            } else {
              errorMessage = msg;
            }

            return Scaffold(
              appBar: AppBar(),
              body: CenterErrorMessage(
                errorMessage: errorMessage,
                onRetry: widget.viewModel.reload,
              ),
            );
          }

          return Scaffold(
            body: _VideoDetailLayout(
              player: _buildPlayer(),
              content: _ContentTab(
                viewModel: widget.viewModel,
                onCoin: _onCoin,
                onFavorite: _onFavorite,
                onShare: _onShare,
                onDownload: _onDownload,
                onReport: _onReport,
                onTapTime: _onTapTime,
              ),
              sidebar: _buildSidebar(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayer() {
    return Selector<VideoDetailViewModel, BiliVideoPlayerController?>(
      selector: (context, vm) => vm.videoController,
      builder: (context, controller, _) {
        if (controller == null) {
          return Stack(
            children: [
              BiliImageWapper(
                url: widget.viewModel.cover!,
                aspectRatio: 16 / 9,
                borderRadius: BorderRadius.circular(16.0),
              ),
              Positioned(
                top: 10.0,
                left: 16.0,
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                ),
              ),
            ],
          );
        } else {
          return BiliVideoPlayer(
            key: ObjectKey(controller),
            controller: controller,
            playerConfig: context.read(),
            danmakuConfig: context.read(),
            videoService: context.read(),
            aspectRatio: 16 / 9,
            borderRadius: BorderRadius.circular(16.0),
            title: Row(
              mainAxisAlignment: .start,
              crossAxisAlignment: .center,
              spacing: 8.0,
              children: [
                StreamBuilder(
                  stream: controller.stream.fullscreen,
                  builder: (context, asyncSnapshot) {
                    final isFullscreen = asyncSnapshot.data ?? controller.state.fullscreen;
                    return StreamBuilder(
                      stream: controller.stream.windowFullscreen,
                      builder: (context, asyncSnapshot) {
                        final isWindowFullscreen = asyncSnapshot.data ?? controller.state.windowFullscreen;
                        if (isFullscreen || isWindowFullscreen) {
                          return const SizedBox.shrink();
                        }

                        return Row(
                          mainAxisSize: .min,
                          spacing: 4.0,
                          children: [
                            IconButton(
                              onPressed: () => context.pop(),
                              icon: Icon(Icons.arrow_back_outlined, color: Colors.white),
                              hoverColor: Colors.white24,
                              tooltip: '返回',
                            ),
                            IconButton(
                              onPressed: () => context.popToRoot(),
                              icon: Icon(Icons.home_outlined, color: Colors.white),
                              hoverColor: Colors.white24,
                              tooltip: '返回主页',
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                Flexible(
                  child: Stack(
                    alignment: .centerLeft,
                    children: [
                      Text(widget.viewModel.detail?.title ?? ''),
                      StreamBuilder(
                        stream: controller.stream.windowFullscreen,
                        builder: (context, asyncSnapshot) {
                          final isWindowFullscreen = asyncSnapshot.data ?? controller.state.windowFullscreen;
                          if (!isWindowFullscreen) {
                            return SizedBox.shrink();
                          }

                          return GestureDetector(
                            behavior: .translucent,
                            onPanStart: (_) => windowManager.startDragging(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            layers: [
              StreamBuilder(
                stream: widget.viewModel.danmakuConfig.stream.enabled,
                builder: (context, asyncSnapshot) {
                  final enabled = asyncSnapshot.data ?? widget.viewModel.danmakuConfig.enabled;
                  if (!enabled) {
                    return SizedBox.shrink();
                  }

                  return DanmakuLayer(
                    key: ObjectKey(controller),
                    controller: widget.viewModel.danmakuController!,
                    positionStream: controller.stream.position,
                    playingStream: controller.stream.playing,
                    playing: controller.state.playing,
                  );
                },
              ),
              Selector<PlayerConfig, bool>(
                selector: (context, config) => config.historyReporterDebugHud,
                builder: (context, state, _) {
                  if (!state) {
                    return SizedBox.shrink();
                  }

                  return BiliHistoryReporterDebugLayer(
                    controller: widget.viewModel.biliHistoryReporter!,
                  );
                },
              ),
            ],
            onToggleWindowFullscreen: widget.viewModel.onToggleWindowFullscreen,
            onToggleFullscreen: widget.viewModel.onToggleFullscreen,
          );
        }
      },
    );
  }

  Widget _buildSidebar() {
    // 仅在存在合集时提前展示
    if (widget.viewModel.detail == null && widget.viewModel.collection == null && widget.viewModel.playlistId == null) {
      return const SizedBox.expand();
    }

    const tabHeight = 32.0;
    int length = 0;
    List<Tab> tabs = [];
    List<Widget> children = [];

    if (widget.viewModel.playlistId != null) {
      length++;
      tabs.add(const Tab(text: '列表', height: tabHeight));
      children.add(
        Selector<VideoDetailViewModel, String>(
          selector: (context, vm) => vm.videoId,
          builder: (context, videoId, _) => ChangeNotifierProvider(
            create: (context) => PlaylistTabViewModel(
              videoRepository: context.read(),
              playlistId: widget.viewModel.playlistId!,
              videoId: videoId,
            ),
            builder: (context, child) => PlaylistTab(
              viewModel: context.read(),
              currentVideoId: videoId,
              onSwitchVideo: (video) => widget.viewModel.switchVideo(video.id, video.episodeId, video.cover),
            ),
          ),
        ),
      );
    }

    if (widget.viewModel.episodes.length > 1) {
      length++;
      tabs.add(const Tab(text: '选集', height: tabHeight));
      children.add(
        Selector<VideoDetailViewModel, String>(
          selector: (_, vm) => vm.episodeId!,
          builder: (context, episodeId, _) => _EpisodesTab(
            episodes: widget.viewModel.episodes,
            currentEpisodeId: episodeId,
            onSwitchEpisode: widget.viewModel.switchEpisode,
          ),
        ),
      );
    }

    if (widget.viewModel.collection != null) {
      length++;
      tabs.add(const Tab(text: '合集', height: tabHeight));
      children.add(
        Selector<VideoDetailViewModel, VideoInteraction?>(
          selector: (context, vm) => vm.interaction,
          builder: (context, value, _) => _CollectionTab(
            collection: widget.viewModel.collection!,
            currentVideoId: widget.viewModel.videoId,
            initSubscription: value?.isSubscribedCollection ?? false,
            onSwitchVideo: (video) {
              // 遵循顶部提到的跳转逻辑
              if (widget.viewModel.playlistId != null) {
                context.push(
                  Routes.buildVideoDetail(
                    videoId: video.id,
                    episodeId: video.episodeId,
                    initCover: video.cover,
                  ),
                );
              } else {
                widget.viewModel.switchVideo(video.id, video.episodeId, video.cover);
              }
            },
          ),
        ),
      );
    }

    if (widget.viewModel.recommandVideos.isNotEmpty) {
      length++;
      tabs.add(const Tab(text: '推荐', height: tabHeight));
      children.add(_RecommendTab(videos: widget.viewModel.recommandVideos));
    }

    length++;
    tabs.add(const Tab(text: '评论', height: tabHeight));
    children.add(
      ChangeNotifierProvider(
        key: ValueKey('comment_panel.${widget.viewModel.videoId}_${widget.viewModel.episodeId}'),
        create: (context) => CommentPanelViewModel(
          commentRepository: context.read(),
          commonRepository: context.read(),
          type: .video,
          id: widget.viewModel.videoId,
        ),
        builder: (context, _) => CommentPanel(
          viewModel: context.read(),
          onTapTime: _onTapTime,
        ),
      ),
    );

    return DefaultTabController(
      length: length,
      child: Column(
        children: [
          TabBar(
            splashBorderRadius: .circular(8.0),
            dividerColor: Colors.transparent,
            isScrollable: true,
            tabAlignment: .center,
            tabs: tabs,
          ),
          Expanded(child: TabBarView(children: children)),
        ],
      ),
    );
  }
}

class _ContentTab extends StatelessWidget {
  final VideoDetailViewModel viewModel;
  final VoidCallback? onCoin;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;
  final VoidCallback? onDownload;
  final VoidCallback? onReport;
  final Function(int episodeIndex, Duration time)? onTapTime;

  const _ContentTab({
    required this.viewModel,
    this.onCoin,
    this.onFavorite,
    this.onShare,
    this.onDownload,
    this.onReport,
    this.onTapTime,
  });

  Widget _buildProduction({
    required BuildContext context,
    required VideoDetailOwner owner,
    required bool followed,
    required List<VideoProduction> production,
  }) {
    if (production.isEmpty) {
      return ListTile(
        leading: BiliUserAvatar(
          url: owner.avatar,
          frameImage: owner.avatarFrame != null ? NetworkImage(owner.avatarFrame!) : null,
          size: 48.0,
        ),
        title: Text(owner.nickname),
        subtitle: Text('${formatCountToHumanReadable(owner.stats.fans)}粉丝'),
        trailing: ChangeNotifierProvider(
          key: ValueKey('follow-button.${owner.id}.$followed'),
          create: (context) => FollowTextButtonViewModel(
            userRepository: context.read(),
            userId: owner.id,
            initState: followed,
          ),
          builder: (context, _) => FollowTextButton(viewModel: context.read(), onChange: viewModel.updateFollowStatus),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        onTap: () => context.push(Routes.buildUserDetail(owner.id)),
      );
    }

    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: 100.0,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: production.length,
            itemBuilder: (_, index) {
              final item = production[index];
              return InkWell(
                onTap: () => context.push(Routes.buildUserDetail(item.id)),
                borderRadius: BorderRadius.circular(8.0),
                child: Ink(
                  padding: EdgeInsets.all(4.0),
                  child: SizedBox(
                    width: 70.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BiliUserAvatar(url: item.avatar),
                        Text(
                          item.nickname,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item.role,
                          style: TextStyle(
                            color: colorScheme.outline,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    ButtonStyle actionButtonStyle(bool active) => TextButton.styleFrom(
      foregroundColor: active ? colorScheme.primary : colorScheme.onSurface,
      backgroundColor: active ? colorScheme.primaryContainer : colorScheme.surfaceContainer,
    );

    return Selector<VideoDetailViewModel, ({String videoId, VideoDetail? detail, VideoDetailStats? stats})>(
      selector: (_, vm) => (
        videoId: vm.videoId,
        detail: vm.detail,
        stats: vm.detailStats,
      ),
      builder: (context, state, _) {
        {
          if (state.detail == null || state.stats == null) {
            return const SizedBox.shrink();
          }

          return Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              // 标题
              SizedBox(height: 8.0),
              SelectableText(
                state.detail!.title,
                style: TextStyle(fontSize: 20.0),
              ),

              // 各种信息
              SizedBox(height: 2.0),
              Wrap(
                direction: Axis.horizontal,
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 播放量
                      Icon(
                        Icons.smart_display_outlined,
                        size: 16.0,
                        color: colorScheme.outline,
                      ),
                      SizedBox(width: 2.0),
                      SelectableText(
                        formatCountToHumanReadable(state.stats!.view),
                        style: TextStyle(fontSize: 15.0, color: colorScheme.outline),
                      ),
                    ],
                  ),

                  // 弹幕量
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.subtitles_outlined,
                        size: 16.0,
                        color: colorScheme.outline,
                      ),
                      SizedBox(width: 2.0),
                      SelectableText(
                        formatCountToHumanReadable(state.stats!.danmaku),
                        style: TextStyle(fontSize: 15.0, color: colorScheme.outline),
                      ),
                    ],
                  ),

                  // 发布时间
                  SelectableText(
                    formatTime(state.detail!.releaseTime),
                    style: TextStyle(fontSize: 15.0, color: colorScheme.outline),
                  ),

                  // id
                  SelectableText(
                    '${state.detail!.bvid}(${state.detail!.id})',
                    style: TextStyle(fontSize: 15.0, color: colorScheme.outline),
                  ),

                  // 警告信息
                  if (state.detail!.isDangerous)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_outlined,
                          size: 16.0,
                          color: colorScheme.error,
                        ),
                        SizedBox(width: 2.0),
                        SelectableText(
                          '视频含有危险行为，请勿模仿',
                          style: TextStyle(fontSize: 15.0, color: colorScheme.error),
                        ),
                      ],
                    ),
                  if (state.detail!.isSensitive)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_outlined,
                          size: 16.0,
                          color: colorScheme.error,
                        ),
                        SizedBox(width: 2.0),
                        SelectableText(
                          '内容可能引起不适',
                          style: TextStyle(fontSize: 15.0, color: colorScheme.error),
                        ),
                      ],
                    ),
                ],
              ),

              // 创作者
              Selector<VideoDetailViewModel, bool>(
                selector: (_, vm) => vm.interaction?.hasFollowed ?? false,
                builder: (context, hasFollowed, child) => _buildProduction(
                  context: context,
                  owner: state.detail!.owner,
                  followed: hasFollowed,
                  production: state.detail!.production,
                ),
              ),

              // 功能区
              SizedBox(height: 4.0),
              Wrap(
                spacing: 4.0,
                runSpacing: 4.0,
                children: [
                  Selector<VideoDetailViewModel, ({bool hasLiked, int likeCount})>(
                    selector: (_, vm) => (
                      hasLiked: vm.hasLiked,
                      likeCount: vm.detailStats?.like ?? 0,
                    ),
                    builder: (context, state, child) => TextButton.icon(
                      onPressed: viewModel.like.execute,
                      icon: Icon(state.hasLiked ? Icons.thumb_up_alt_rounded : Icons.thumb_up_outlined),
                      label: Text(
                        state.likeCount == 0 ? '点赞' : formatCountToHumanReadable(state.likeCount),
                      ),
                      style: actionButtonStyle(state.hasLiked),
                    ),
                  ),
                  Selector<VideoDetailViewModel, ({bool hasCoined, int coinCount})>(
                    selector: (_, vm) => (
                      hasCoined: vm.hasCoined,
                      coinCount: vm.detailStats?.coin ?? 0,
                    ),
                    builder: (context, state, child) => TextButton.icon(
                      onPressed: onCoin,
                      icon: Icon(state.hasCoined ? CustomIcons.coin : CustomIcons.coin_outlined),
                      label: Text(
                        state.coinCount == 0 ? '投币' : formatCountToHumanReadable(state.coinCount),
                      ),
                      style: actionButtonStyle(state.hasCoined),
                    ),
                  ),
                  Selector<VideoDetailViewModel, ({bool hasFavorited, int favoriteCount})>(
                    selector: (_, vm) => (
                      hasFavorited: vm.hasFavorited,
                      favoriteCount: vm.detailStats?.favorite ?? 0,
                    ),
                    builder: (context, state, child) => TextButton.icon(
                      onPressed: onFavorite,
                      icon: Icon(state.hasFavorited ? Icons.star_rounded : Icons.star_outline),
                      label: Text(
                        state.favoriteCount == 0 ? '收藏' : formatCountToHumanReadable(state.favoriteCount),
                      ),
                      style: actionButtonStyle(state.hasFavorited),
                    ),
                  ),
                  Selector<VideoDetailViewModel, bool>(
                    selector: (_, vm) => vm.isInWatchLater,
                    builder: (context, state, child) => TextButton.icon(
                      onPressed: viewModel.watchLater.execute,
                      icon: Icon(state ? Icons.watch_later : Icons.watch_later_outlined),
                      label: const Text('稍后观看'),
                      style: actionButtonStyle(state),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onShare,
                    icon: Icon(Icons.share_outlined),
                    label: const Text('分享'),
                    style: actionButtonStyle(false),
                  ),
                  TextButton.icon(
                    onPressed: onDownload,
                    icon: Icon(Icons.download_outlined),
                    label: const Text('下载'),
                    style: actionButtonStyle(false),
                  ),
                  TextButton.icon(
                    onPressed: onReport,
                    icon: Icon(Icons.flag_outlined),
                    label: const Text('举报'),
                    style: actionButtonStyle(false),
                  ),
                ],
              ),

              // 简介
              if (state.detail!.description != null)
                _VideoDescription(
                  description: state.detail!.description!,
                  onTapLink: (url) => context.openUrl(url),
                  onTapVideo: (avid) => context.push(Routes.buildVideoDetail(videoId: avid)),
                  onTapUser: (userId) => context.push(Routes.buildUserDetail(userId)),
                  onTapTime: onTapTime,
                ),

              // 标签
              if (state.detail!.tags.isNotEmpty || state.detail!.musics.isNotEmpty || state.detail!.isAigc) ...[
                SizedBox(height: 8.0),
                Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: [
                    if (state.detail!.isAigc)
                      ActionChip(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        label: Text(
                          'AIGC',
                          style: TextStyle(fontSize: 12.0, color: colorScheme.onPrimary),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                        backgroundColor: colorScheme.primary,
                        onPressed: () {},
                      ),
                    if (state.detail!.musics.isNotEmpty)
                      ...state.detail!.musics.map(
                        (music) => ActionChip(
                          avatar: Icon(Icons.music_note_outlined, color: colorScheme.onPrimary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          label: Text(
                            music.name,
                            style: TextStyle(fontSize: 12.0, color: colorScheme.onPrimary),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                          backgroundColor: colorScheme.primary,
                          onPressed: () {},
                        ),
                      ),
                    if (state.detail!.honors.isNotEmpty)
                      ...state.detail!.honors.map(
                        (honor) => Chip(
                          avatar: Icon(Icons.emoji_events_outlined, color: colorScheme.onPrimary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          label: Text(
                            honor.name,
                            style: TextStyle(fontSize: 12.0, color: colorScheme.onPrimary),
                          ),
                          backgroundColor: colorScheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                        ),
                      ),
                    ...state.detail!.tags.map(
                      (tag) => ActionChip(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        label: Text(
                          tag.name,
                          style: const TextStyle(fontSize: 12.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                        onPressed: () => context.push(Routes.buildSearch(tag.name)),
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 24.0),
            ],
          );
        }
      },
    );
  }
}

class _EpisodesTab extends StatefulWidget {
  final List<VideoDetailEpisode> episodes;
  final String? currentEpisodeId;
  final ValueChanged<VideoDetailEpisode> onSwitchEpisode;

  const _EpisodesTab({
    required this.episodes,
    required this.currentEpisodeId,
    required this.onSwitchEpisode,
  });

  @override
  State<_EpisodesTab> createState() => _EpisodesTabState();
}

class _EpisodesTabState extends State<_EpisodesTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();
  late final ListObserverController _observerController;

  @override
  void initState() {
    super.initState();

    _observerController = ListObserverController(controller: _scrollController);

    final initIndex = widget.episodes.indexWhere((episode) => episode.episodeId == widget.currentEpisodeId);
    if (initIndex != -1) {
      _observerController.initialIndexModel = ObserverIndexPositionModel(
        index: initIndex,
        isFixedHeight: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListViewObserver(
      controller: _observerController,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.episodes.length,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemBuilder: (context, index) {
          final video = widget.episodes[index];
          final isCurrent = widget.currentEpisodeId == video.episodeId;
          return VideoTile(
            videoId: video.episodeId,
            title: video.title,
            cover: video.cover,
            duration: video.duration,
            onTap: isCurrent ? () {} : () => widget.onSwitchEpisode(video),
            compact: true,
            isActive: isCurrent,
          );
        },
      ),
    );
  }
}

class _CollectionTab extends StatefulWidget {
  final VideoCollection collection;
  final String currentVideoId;
  final ValueChanged<VideoCollectionVideo> onSwitchVideo;
  final bool initSubscription;

  const _CollectionTab({
    required this.collection,
    required this.currentVideoId,
    required this.onSwitchVideo,
    required this.initSubscription,
  });

  @override
  State<_CollectionTab> createState() => _CollectionTabState();
}

class _CollectionTabState extends State<_CollectionTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _padding = const EdgeInsets.only(bottom: 8.0);
  final ScrollController _scrollController = ScrollController();
  late final ListObserverController _observerController;

  int _selectedGroupIndex = 0;

  bool _reverseOrder = false;

  @override
  void initState() {
    super.initState();

    _selectedGroupIndex = widget.collection.groups.indexWhere(
      (group) => group.videos.any((video) => video.id == widget.currentVideoId),
    );

    _observerController = ListObserverController(controller: _scrollController);

    final index = widget.collection.groups[_selectedGroupIndex].videos.indexWhere((video) => video.id == widget.currentVideoId);
    if (index != -1) {
      _observerController.initialIndexModel = ObserverIndexPositionModel(
        index: index,
        isFixedHeight: true,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.collection.groups.length > 1) _buildGroupChips(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              Text(
                '${widget.collection.title} · 共 ${widget.collection.total} 个视频',
                style: TextStyle(fontSize: 16.0),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  // 正序倒序
                  IconButton(
                    onPressed: () => setState(() => _reverseOrder = !_reverseOrder),
                    icon: _reverseOrder ? Transform.flip(flipY: true, child: const Icon(Icons.sort)) : const Icon(Icons.sort),
                    tooltip: _reverseOrder ? '倒序' : '正序',
                  ),
                  // 循环播放
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.repeat),
                    tooltip: '循环播放',
                  ),
                  // 随机播放
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.shuffle),
                    tooltip: '随机播放',
                  ),
                  const Spacer(),
                  ChangeNotifierProvider(
                    key: Key(widget.initSubscription.toString()),
                    create: (context) => SubscriptionCollectionTextButtonViewModel(
                      videoRepository: context.read(),
                      collectionId: widget.collection.id,
                      initState: widget.initSubscription,
                    ),
                    builder: (context, _) => SubscriptionCollectionTextButton(viewModel: context.read()),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListViewObserver(
            controller: _observerController,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: widget.collection.groups[_selectedGroupIndex].videos.length,
              padding: _padding,
              itemBuilder: (context, index) {
                final video = widget.collection.groups[_selectedGroupIndex].videos[index];
                final isCurrent = widget.currentVideoId == video.id;
                return VideoTile(
                  videoId: video.id,
                  title: video.title,
                  cover: video.cover,
                  duration: video.duration,
                  viewCount: video.stats.view,
                  danmakuCount: video.stats.danmaku,
                  nickname: video.owner.nickname,
                  onTap: isCurrent ? () {} : () => widget.onSwitchVideo(video),
                  compact: true,
                  isActive: isCurrent,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupChips() {
    final groupLabels = widget.collection.groups.map((group) => group.name).toList();

    return SizedBox(
      height: kMinInteractiveDimension,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: groupLabels.length,
          itemBuilder: (_, index) {
            return ChoiceChip(
              label: Text(groupLabels[index]),
              selected: _selectedGroupIndex == index,
              onSelected: (selected) => setState(() => _selectedGroupIndex = index),
              showCheckmark: false,
            );
          },
          separatorBuilder: (context, index) => const SizedBox(width: 8.0),
        ),
      ),
    );
  }
}

class _RecommendTab extends StatefulWidget {
  final List<RecommendVideo> videos;

  const _RecommendTab({required this.videos});

  @override
  State<_RecommendTab> createState() => _RecommendTabState();
}

class _RecommendTabState extends State<_RecommendTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView.builder(
      itemCount: widget.videos.length,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemBuilder: (context, index) {
        final video = widget.videos[index];
        return VideoTile(
          videoId: video.id,
          title: video.title,
          cover: video.cover,
          duration: video.duration,
          viewCount: video.stats.view,
          danmakuCount: video.stats.danmaku,
          nickname: video.owner.nickname,
        );
      },
    );
  }
}

class _VideoDetailLayout extends StatelessWidget {
  final Widget player;
  final Widget content;
  final Widget sidebar;

  const _VideoDetailLayout({required this.player, required this.content, required this.sidebar});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // 0.35 -> 0.32
    final sidebarWidth = (size.width * 0.32).clamp(350.0, 440.0);
    final innerMaxWidth = size.width.clamp(0.0, _kMaxContentWidth) - _kPagePadding.horizontal - _kSidebarSpacing;
    final maxByHeight = (size.height - _kPagePadding.vertical - _kMinReserveBelow) * 16 / 9;
    final maxByWidth = innerMaxWidth - sidebarWidth;
    const minMainWidth = _kMinCoverHeight * 16 / 9;
    final fitted = maxByHeight.clamp(0.0, maxByWidth);
    final mainWidth = fitted < minMainWidth ? minMainWidth : fitted;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _kMaxContentWidth),
        child: Padding(
          padding: _kPagePadding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: _kSidebarSpacing,
            children: [
              SingleChildScrollView(
                clipBehavior: .none,
                child: Column(
                  children: [
                    SizedBox(width: mainWidth, child: player),
                    SizedBox(width: mainWidth, child: content),
                  ],
                ),
              ),
              SizedBox(width: sidebarWidth, child: sidebar),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoDescription extends StatelessWidget {
  final VideoDetailDescription description;
  final ValueChanged<String>? onTapLink;
  final ValueChanged<String>? onTapVideo;
  final ValueChanged<String>? onTapUser;
  final Function(int episodeCount, Duration time)? onTapTime;

  const _VideoDescription({
    required this.description,
    this.onTapLink,
    this.onTapVideo,
    this.onTapUser,
    this.onTapTime,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text('简介', style: TextStyle(fontSize: 18.0)),
          BiliRichTextWapper(
            rawText: description.rawText,
            parserNodes: [
              LinkParseNode(
                primaryColor: colorScheme.primary,
                links: const [],
                onTapVideo: onTapVideo,
              ),
              UserParseNode(
                primaryColor: colorScheme.primary,
                users: description.users,
                onTap: onTapUser,
              ),
              UnknownLinkParseNode(
                primaryColor: colorScheme.primary,
                onTap: onTapLink,
                onTapVideo: onTapVideo,
                onTapUser: onTapUser,
              ),
              JumpProgressParseNode(
                primaryColor: colorScheme.primary,
                onTap: onTapTime,
              ),
              ResourceIdParseNode(onTapVideo: onTapVideo),
            ],
            maxLines: 4,
          ),
        ],
      ),
    );
  }
}
