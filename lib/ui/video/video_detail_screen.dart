import 'dart:async';
import 'dart:ui';

import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_video_detail_response.dart';
import 'package:better_bilibili/domain/models/bilibili/play_info.dart';
import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_user_avatar.dart';
import 'package:better_bilibili/ui/core/bilibili/user/follow_text_button/follow_text_button.dart';
import 'package:better_bilibili/ui/core/bilibili/user/follow_text_button/follow_text_button_view_model.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/bili_rich_text_wapper.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/jump_progress_parse_node.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/link_parse_node.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/resource_id_parse_node.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/unknown_link_parse_node.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/user_parse_node.dart';
import 'package:better_bilibili/ui/core/bilibili/comment/comment_panel/comment_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/comment/comment_panel/comment_panel_view_model.dart';
import 'package:better_bilibili/ui/core/bilibili/favorite_folder/edit_video_in_favorite_folder_sheet/edit_video_in_favorite_folder_sheet.dart';
import 'package:better_bilibili/ui/core/bilibili/video/video_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/bili_video_player.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/notice/notice_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/playlist/collection/bili_collection_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/playlist/episode/bili_episode_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/playlist/recommend/bili_recommend_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/playlist/playlist/bili_playlist_controller.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/custom_icons.dart';
import 'package:better_bilibili/ui/core/share/image_wapper.dart';
import 'package:better_bilibili/ui/core/share/open_url.dart';
import 'package:better_bilibili/ui/core/share/route_depth_limiter.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/ui/video/video_detail_view_model.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:better_bilibili/utils/result.dart' as result;
import 'package:better_bilibili/utils/result.dart';

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

  const VideoDetailScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'VideoDetailScreen'));

  VideoDetailViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();

    widget.viewModel.like.addListener(_onResult);
    widget.viewModel.coin.addListener(_onResult);
    widget.viewModel.favorite.addListener(_onResult);
    widget.viewModel.reload();
  }

  @override
  void dispose() {
    widget.viewModel.like.removeListener(_onResult);
    widget.viewModel.coin.removeListener(_onResult);
    widget.viewModel.favorite.removeListener(_onResult);

    super.dispose();
  }

  void _onResult() {
    if (viewModel.like.error) {
      context.showError(
        '${viewModel.hasLiked ? '取消赞' : '赞'}失败: ${viewModel.like.result.toString()}',
      );
    }
    if (viewModel.coin.error) {
      context.showError('投币失败: ${viewModel.coin.result.toString()}');
    }
    if (viewModel.favorite.error) {
      context.showError('收藏失败: ${viewModel.favorite.result.toString()}');
    }
  }

  Future<void> _onCoin() async {
    if (viewModel.states == null || viewModel.states!.coinCount == 2) {
      return;
    }

    final selectedCount = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Text('投币(已投${viewModel.states?.coinCount ?? 0}个)'),
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
              onPressed: viewModel.states?.coinCount == 1 ? null : () => Navigator.pop(ctx, 2),
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

    viewModel.coin.execute(selectedCount);
  }

  Future<void> _onFavorite() async {
    final pickerResult = await context.showFavoritesPicker(
      videoId: viewModel.videoId,
      multiSelect: true,
    );
    if (pickerResult == null || !pickerResult.hasChanges) return;

    viewModel.favorite.execute(
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
    bool withShortUrl = false;

    final urlController = TextEditingController(text: rawUrl);
    void updateShareText(StateSetter setStateFn) {
      String shareUrl = withShortUrl ? 'https://b23.tv/${widget.viewModel.detail?.bvid}' : rawUrl;

      if (withTimestamp) {
        shareUrl = '$shareUrl?t=${widget.viewModel.videoController.state.position.inSeconds}';
      }

      if (withTitle) {
        shareUrl = '[${widget.viewModel.detail?.title}]($shareUrl)';
      }

      setStateFn(() {
        urlController.text = shareUrl;
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
                          context.pop();
                          context.showInfo('已复制到剪贴板');
                        },
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('复制', style: TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                  // 勾选框区域
                  Row(
                    mainAxisAlignment: .start,
                    spacing: 16.0,
                    children: [
                      Row(
                        mainAxisSize: .min,
                        children: [
                          Checkbox(
                            value: withTitle,
                            onChanged: (val) {
                              withTitle = val ?? false;
                              updateShareText(setState);
                            },
                          ),
                          const Text('带标题'),
                        ],
                      ),

                      if (!withShortUrl)
                        Row(
                          mainAxisSize: .min,
                          children: [
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

                      if (!withTimestamp)
                        Row(
                          mainAxisSize: .min,
                          children: [
                            Checkbox(
                              value: withShortUrl,
                              onChanged: (val) {
                                withShortUrl = val ?? false;
                                updateShareText(setState);
                              },
                            ),
                            const Text('短链接'),
                          ],
                        ),
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
                          context.pop();
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
                          context.pop();
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

  void _onTapTime(int episodeIndex, Duration time) {
    if (episodeIndex < 0 || episodeIndex > widget.viewModel.episodes.length - 1) {
      _log.i('[onTapTime] Invaild episodeIndex: $episodeIndex');
      return;
    }

    final episode = widget.viewModel.episodes[episodeIndex];

    final episodeBak = widget.viewModel.episodes.firstWhere((v) => v.id == widget.viewModel.episodeId);
    final timeBak = widget.viewModel.videoController.state.position;

    if (episode.id != widget.viewModel.episodeId) {
      widget.viewModel.switchEpisode(episode, time);
      widget.viewModel.noticeController.show(
        Notice(
          content: Text('已转到 ${formatDuration(time)}'),
          action: '撤销',
          onTap: (self) {
            widget.viewModel.switchEpisode(episodeBak, timeBak);
            widget.viewModel.noticeController.dismiss(self);
          },
        ),
      );
    } else {
      widget.viewModel.videoController.seek(time);
      widget.viewModel.noticeController.show(
        Notice(
          content: Text('已转到 ${formatDuration(time)}'),
          action: '撤销',
          onTap: (self) {
            widget.viewModel.videoController.seek(timeBak);
            widget.viewModel.noticeController.dismiss(self);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RouteDepthLimiter(
      child: ScrollConfiguration(
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
      ),
    );
  }

  Widget _buildPlayer() {
    return Selector<VideoDetailViewModel, PlayInfo?>(
      selector: (context, vm) => vm.playInfo,
      builder: (context, playInfo, _) {
        if (playInfo == null) {
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
            controller: viewModel.videoController,
            playInfo: playInfo,
            appController: viewModel.appController,
            playerConfig: viewModel.playerConfig,
            danmakuConfig: viewModel.danmakuConfig,
            videoRepository: viewModel.videoRepository,
            aspectRatio: 16 / 9,
            borderRadius: .circular(16.0),
            mediaSessionController: viewModel.mediaSessionController,
            mediaSessionData: viewModel.mediaSessionData,
            authRepository: viewModel.authRepository,
            playlistController: viewModel.playlistCoordinator,
            noticeController: viewModel.noticeController,
            onRefresh: () {
              viewModel.videoController.setInitPosition(viewModel.videoController.state.position);
              viewModel.reload();
            },
            bsbsbRepository: viewModel.bsbsbRepository,
            bsbsbConfig: viewModel.bsbsbConfig,
          );
        }
      },
    );
  }

  Widget _buildSidebar() {
    if ([
      viewModel.detail,
      viewModel.episodeController,
      viewModel.playlistController,
      viewModel.collectionController,
      viewModel.recommendController,
    ].every((v) => v == null)) {
      return const SizedBox.expand();
    }

    const tabHeight = 32.0;
    int length = 0;
    List<Tab> tabs = [];
    List<Widget> children = [];

    if (viewModel.playlistController != null) {
      length++;
      tabs.add(const Tab(text: '列表', height: tabHeight));
      children.add(_PlaylistTab(controller: viewModel.playlistController!));
    }

    if (viewModel.episodeController != null) {
      length++;
      tabs.add(const Tab(text: '选集', height: tabHeight));
      children.add(
        _EpisodesTab(controller: viewModel.episodeController!),
      );
    }

    if (viewModel.collectionController != null) {
      length++;
      tabs.add(const Tab(text: '合集', height: tabHeight));
      children.add(
        Selector<VideoDetailViewModel, StateModel?>(
          selector: (context, vm) => vm.states,
          builder: (context, states, _) => _CollectionTab(
            controller: viewModel.collectionController!,
            initSubscription: states?.isSubscribedCollection ?? false,
            onPlay: (video) {
              if (viewModel.playlistId != null) {
                context.push(
                  Routes.buildVideoDetail(
                    videoId: video.id,
                    episodeId: video.episodeId,
                    initCover: video.cover,
                  ),
                );
              } else {
                viewModel.collectionController!.play(video);
              }
            },
          ),
        ),
      );
    }

    if (viewModel.recommendController != null) {
      length++;
      tabs.add(const Tab(text: '推荐', height: tabHeight));
      children.add(_RecommendTab(controller: viewModel.recommendController!));
    }

    length++;
    tabs.add(const Tab(text: '评论', height: tabHeight));
    children.add(
      ChangeNotifierProvider(
        key: ValueKey('comment_panel.${viewModel.videoId}_${viewModel.episodeId}'),
        create: (context) => CommentPanelViewModel(
          commentRepository: context.read(),
          commonRepository: context.read(),
          type: .video,
          id: viewModel.videoId,
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

    return Selector<
      VideoDetailViewModel,
      ({
        String videoId,
        VideoDetail? detail,
        StateModel? states,
      })
    >(
      selector: (_, vm) => (
        videoId: vm.videoId,
        detail: vm.detail,
        states: vm.states,
      ),
      builder: (context, states, _) {
        if (states.detail == null || states.states == null) {
          return const SizedBox.shrink();
        }

        final detail = states.detail!;

        return Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            // 标题
            SizedBox(height: 8.0),
            SelectableText(
              states.detail!.title,
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
                      formatCountToHumanReadable(states.states!.view),
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
                      formatCountToHumanReadable(states.states!.danmaku),
                      style: TextStyle(fontSize: 15.0, color: colorScheme.outline),
                    ),
                  ],
                ),

                // 发布时间
                SelectableText(
                  formatTime(states.detail!.releaseTime),
                  style: TextStyle(fontSize: 15.0, color: colorScheme.outline),
                ),

                // id
                SelectableText(
                  '${states.detail!.bvid}(${states.detail!.id})',
                  style: TextStyle(fontSize: 15.0, color: colorScheme.outline),
                ),

                // 警告信息
                if (states.detail!.isDangerous)
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
                if (states.detail!.isSensitive)
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
              selector: (_, vm) => vm.hasFollowed,
              builder: (context, hasFollowed, child) => _buildProduction(
                context: context,
                owner: states.detail!.owner,
                followed: hasFollowed,
                production: states.detail!.production,
              ),
            ),

            // 功能区
            SizedBox(height: 4.0),
            Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: [
                Selector<VideoDetailViewModel, StateModel>(
                  selector: (_, vm) => vm.states!,
                  builder: (context, states, _) => TextButton.icon(
                    onPressed: viewModel.like.execute,
                    icon: Icon(states.hasLiked ? Icons.thumb_up_alt_rounded : Icons.thumb_up_outlined),
                    label: Text(
                      states.like == 0 ? '赞' : formatCountToHumanReadable(states.like),
                    ),
                    style: actionButtonStyle(states.hasLiked),
                  ),
                ),
                Selector<VideoDetailViewModel, StateModel>(
                  selector: (_, vm) => vm.states!,
                  builder: (context, states, child) {
                    final hasCoined = states.coinCount > 0;
                    return TextButton.icon(
                      onPressed: onCoin,
                      icon: Icon(hasCoined ? CustomIcons.coin : CustomIcons.coin_outlined),
                      label: Text(
                        states.coin == 0 ? '投币' : formatCountToHumanReadable(states.coin),
                      ),
                      style: actionButtonStyle(hasCoined),
                    );
                  },
                ),
                Selector<VideoDetailViewModel, StateModel>(
                  selector: (_, vm) => vm.states!,
                  builder: (context, states, child) => TextButton.icon(
                    onPressed: onFavorite,
                    icon: Icon(states.hasFavorited ? Icons.star_rounded : Icons.star_outline),
                    label: Text(
                      states.favorite == 0 ? '收藏' : formatCountToHumanReadable(states.favorite),
                    ),
                    style: actionButtonStyle(states.hasFavorited),
                  ),
                ),
                _WatchLaterButton(
                  style: actionButtonStyle(false),
                  activeStyle: actionButtonStyle(true),
                  userRepository: viewModel.userRepository,
                  title: detail.title,
                  videoId: detail.id,
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
            if (states.detail!.description != null)
              _VideoDescription(
                description: states.detail!.description!,
                onTapLink: (url) => context.openUrl(url),
                onTapVideo: (avid) => context.push(Routes.buildVideoDetail(videoId: avid)),
                onTapUser: (userId) => context.push(Routes.buildUserDetail(userId)),
                onTapTime: onTapTime,
              ),

            // 标签
            if (states.detail!.tags.isNotEmpty || states.detail!.musics.isNotEmpty || states.detail!.isAigc) ...[
              SizedBox(height: 8.0),
              Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                children: [
                  if (states.detail!.isAigc)
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
                  if (states.detail!.musics.isNotEmpty)
                    ...states.detail!.musics.map(
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
                  if (states.detail!.honors.isNotEmpty)
                    ...states.detail!.honors.map(
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
                  ...states.detail!.tags.map(
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
      },
    );
  }
}

class _EpisodesTab extends StatefulWidget {
  final BiliEpisodeController controller;

  const _EpisodesTab({required this.controller});

  @override
  State<_EpisodesTab> createState() => _EpisodesTabState();
}

class _EpisodesTabState extends State<_EpisodesTab> with AutomaticKeepAliveClientMixin {
  BiliEpisodeController get controller => widget.controller;

  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();
  late final ListObserverController _observerController;

  @override
  void initState() {
    super.initState();

    _observerController = ListObserverController(controller: _scrollController);
    _observerController.initialIndexModel = ObserverIndexPositionModel(
      index: controller.index,
      isFixedHeight: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => ListViewObserver(
        controller: _observerController,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: controller.length,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemBuilder: (context, index) {
            final video = controller.episodes[index];
            final isCurrent = controller.index == index;

            return VideoTile(
              videoId: video.id,
              title: video.title,
              cover: video.cover,
              duration: video.duration,
              onTap: isCurrent ? () {} : () => controller.playByIndex(index),
              compact: true,
              isActive: isCurrent,
            );
          },
        ),
      ),
    );
  }
}

class _PlaylistTab extends StatefulWidget {
  final BiliPlaylistController controller;

  const _PlaylistTab({required this.controller});

  @override
  State<_PlaylistTab> createState() => _PlaylistTabState();
}

class _PlaylistTabState extends State<_PlaylistTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  BiliPlaylistController get controller => widget.controller;

  final _padding = const EdgeInsets.symmetric(vertical: 8.0);
  final ScrollController _scrollController = ScrollController();
  // late final ListObserverController _observerController;

  @override
  void initState() {
    super.initState();

    // _observerController = ListObserverController(controller: _scrollController);

    // final initIndex = widget.episodes.indexWhere((episode) => episode.episodeId == widget.currentEpisodeId);
    // if (initIndex != -1) {
    //   _observerController.initialIndexModel = ObserverIndexPositionModel(
    //     index: initIndex,
    //     isFixedHeight: true,
    //   );
    // }

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // 向前加载更多
    if (_scrollController.position.pixels <= 0 && !controller.loadMoreBefore.running && controller.hasMoreBefore) {
      controller.loadMoreBefore.execute();
    }

    // 向后加载更多
    if (_scrollController.position.maxScrollExtent - _scrollController.position.pixels <= 400 &&
        !controller.loadMoreAfter.running &&
        controller.hasMoreAfter) {
      controller.loadMoreAfter.execute();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.initLoad.error) {
          return CenterErrorMessage(
            errorMessage: controller.initLoad.result.toString(),
            onRetry: controller.initLoad.execute,
          );
        }
        if (controller.loadMoreBefore.error) {
          return CenterErrorMessage(
            errorMessage: controller.loadMoreBefore.result.toString(),
            onRetry: controller.loadMoreBefore.execute,
          );
        }
        if (controller.loadMoreAfter.error) {
          return CenterErrorMessage(
            errorMessage: controller.loadMoreAfter.result.toString(),
            onRetry: controller.loadMoreAfter.execute,
          );
        }

        if (controller.initLoad.running ||
            controller.loadMoreBefore.running ||
            controller.loadMoreAfter.running && controller.videos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: _padding,
              child: Text(
                '${controller.playlistInfo!.name} · 共 ${controller.playlistInfo!.total} 个视频',
                style: TextStyle(fontSize: 16.0),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: _padding,
                itemCount: controller.videos.length,
                itemBuilder: (context, index) {
                  final video = controller.videos[index];
                  final isCurrent = controller.currentVideoId == video.id;

                  return VideoTile(
                    videoId: video.id,
                    title: video.title,
                    cover: video.cover,
                    duration: video.duration,
                    nickname: video.owner.nickname,
                    onTap: isCurrent ? () {} : () => controller.play(video),
                    compact: true,
                    isActive: isCurrent,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CollectionTab extends StatefulWidget {
  final BiliCollectionController controller;
  final bool initSubscription;
  final ValueChanged<VideoCollectionVideo> onPlay;

  const _CollectionTab({
    required this.controller,
    required this.initSubscription,
    required this.onPlay,
  });

  @override
  State<_CollectionTab> createState() => _CollectionTabState();
}

class _CollectionTabState extends State<_CollectionTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  BiliCollectionController get controller => widget.controller;

  final _padding = const EdgeInsets.only(bottom: 8.0);
  final ScrollController _scrollController = ScrollController();
  late final ListObserverController _observerController;

  int _groupIndex = 0;

  @override
  void initState() {
    super.initState();

    _groupIndex = controller.currentGroupIndex;
    _observerController = ListObserverController(controller: _scrollController);
    _observerController.initialIndexModel = ObserverIndexPositionModel(
      index: controller.getCurrentIndex(),
      isFixedHeight: true,
    );
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              Text(
                '${controller.collection.title} · 共 ${controller.collection.total} 个视频',
                style: TextStyle(fontSize: 16.0),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Row(
              //   children: [
              //     // 正序倒序
              //     IconButton(
              //       onPressed: () => setState(() => _reverseOrder = !_reverseOrder),
              //       icon: _reverseOrder ? Transform.flip(flipY: true, child: const Icon(Icons.sort)) : const Icon(Icons.sort),
              //       tooltip: _reverseOrder ? '倒序' : '正序',
              //     ),
              //     // 循环播放
              //     IconButton(
              //       onPressed: () {},
              //       icon: const Icon(Icons.repeat),
              //       tooltip: '循环播放',
              //     ),
              //     // 随机播放
              //     IconButton(
              //       onPressed: () {},
              //       icon: const Icon(Icons.shuffle),
              //       tooltip: '随机播放',
              //     ),
              //     const Spacer(),
              //     ChangeNotifierProvider(
              //       key: Key(widget.initSubscription.toString()),
              //       create: (context) => SubscriptionCollectionTextButtonViewModel(
              //         videoRepository: context.read(),
              //         collectionId: controller.collection.id,
              //         initState: widget.initSubscription,
              //       ),
              //       builder: (context, _) => SubscriptionCollectionTextButton(viewModel: context.read()),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
        if (controller.groups.length > 1) _buildGroupChips(),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => Expanded(
            child: ListViewObserver(
              controller: _observerController,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: controller.length,
                padding: _padding,
                itemBuilder: (context, index) {
                  final video = controller.groups[_groupIndex].videos[index];
                  final isCurrent = video.id == controller.currentVideoId;

                  return VideoTile(
                    videoId: video.id,
                    title: video.title,
                    cover: video.cover,
                    duration: video.duration,
                    viewCount: video.stats.view,
                    danmakuCount: video.stats.danmaku,
                    nickname: video.owner.nickname,
                    onTap: isCurrent ? () {} : () => widget.onPlay(video),
                    compact: true,
                    isActive: isCurrent,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupChips() {
    final groupLabels = controller.groups.map((group) => group.name).toList();

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
              selected: _groupIndex == index,
              onSelected: (selected) => setState(() => _groupIndex = index),
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
  final BiliRecommendController controller;

  const _RecommendTab({required this.controller});

  @override
  State<_RecommendTab> createState() => _RecommendTabState();
}

class _RecommendTabState extends State<_RecommendTab> with AutomaticKeepAliveClientMixin {
  BiliRecommendController get controller => widget.controller;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView.builder(
      itemCount: controller.length,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemBuilder: (context, index) {
        final video = controller.videos[index];
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

class _WatchLaterButton extends StatefulWidget {
  final ButtonStyle style;
  final ButtonStyle activeStyle;
  final UserRepository userRepository;
  final String videoId;
  final String title;

  const _WatchLaterButton({
    required this.style,
    required this.activeStyle,
    required this.userRepository,
    required this.videoId,
    required this.title,
  });

  @override
  State<_WatchLaterButton> createState() => _WatchLaterButtonState();
}

class _WatchLaterButtonState extends State<_WatchLaterButton> {
  @override
  void initState() {
    super.initState();

    _getData();
    op.addListener(_onResult);
  }

  @override
  void dispose() {
    op.removeListener(_onResult);

    super.dispose();
  }

  bool hasWatchLater = false;

  Future<void> _getData() async {
    final result = await widget.userRepository.isExistInWatchLater(id: widget.videoId, title: widget.title);
    switch (result) {
      case Ok(:final value):
        if (!mounted) return;
        setState(() => hasWatchLater = value);
      case Error():
    }
  }

  late Command0 op = Command0(_op);

  Future<Result<void>> _op() async {
    final action = !hasWatchLater;
    setState(() => hasWatchLater = action);

    if (action) {
      final result = await widget.userRepository.addVideoToWatchLater(videoId: widget.videoId);
      switch (result) {
        case Ok():
          return result;
        case Error():
          setState(() => hasWatchLater = !action);
      }
      return result;
    } else {
      final result = await widget.userRepository.deleteVideosFromWatchLater(ids: [widget.videoId]);
      switch (result) {
        case Ok():
          return result;
        case Error():
          setState(() => hasWatchLater = !action);
      }
      return result;
    }
  }

  void _onResult() {
    if (op.error) {
      context.showError('${hasWatchLater ? '取消' : '添加'}稍后观看失败: ${op.result.toString()}');
      op.clearResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: op.execute,
      icon: Icon(hasWatchLater ? Icons.watch_later : Icons.watch_later_outlined),
      label: const Text('稍后观看'),
      style: hasWatchLater ? widget.activeStyle : widget.style,
    );
  }
}
