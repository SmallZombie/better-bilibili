import 'package:better_bilibili/config/app_config.dart';
import 'package:better_bilibili/config/eagle_config.dart';
import 'package:better_bilibili/data/repositories/eagle/eagle_repository.dart';
import 'package:better_bilibili/data/services/bilibili/bili_background_service.dart';
import 'package:better_bilibili/data/services/network_manager.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_user_avatar.dart';
import 'package:better_bilibili/ui/core/bilibili/post/post_feed_tile/post_feed_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/post/post_feed_tile/post_feed_tile_view_model.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/responsive/max_width_viewport.dart';
import 'package:better_bilibili/ui/home/view_models/post_view_model.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class PostView extends StatelessWidget {
  final PostViewModel viewModel;
  final AppConfig appConfig;
  final EagleConfig eagleConfig;
  final EagleRepository eagleRepository;
  final NetworkManager networkManager;

  const PostView({
    super.key,
    required this.viewModel,
    required this.appConfig,
    required this.eagleConfig,
    required this.eagleRepository,
    required this.networkManager,
  });

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification.metrics.maxScrollExtent - notification.metrics.pixels <= 400 && !viewModel.getPosts.running && viewModel.hasMore) {
      viewModel.getPosts.execute();
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      alignment: .topCenter,
      children: [
        Row(
          children: [
            SizedBox(
              width: 280,
              child: ListenableBuilder(
                listenable: viewModel.getUsers,
                builder: (context, child) {
                  if (viewModel.getUsers.error) {
                    return CenterErrorMessage(
                      errorMessage: getErrorMessage(viewModel.getUsers.result!),
                      onRetry: viewModel.getUsers.execute,
                    );
                  }
                  if (viewModel.users.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final avatarSize = 36.0;
                  final titleStyle = const TextStyle(fontSize: 15.0);

                  return Selector<PostViewModel, ({int user, int type})>(
                    selector: (context, vm) => (type: vm.selectedTypeIndex, user: vm.selectedUserIndex),
                    builder: (context, state, child) => ListView.builder(
                      padding: const .symmetric(horizontal: 16.0, vertical: 8.0),
                      itemCount: 3 + viewModel.users.length,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return ListTile(
                            leading: SizedBox(width: avatarSize, height: avatarSize),
                            title: Text('全部', style: titleStyle),
                            selected: state.type == 0,
                            onTap: () => viewModel.setSelectedTypeIndex(0),
                            shape: RoundedRectangleBorder(borderRadius: .circular(8)),
                          );
                        }
                        if (index == 1) {
                          return ListTile(
                            leading: SizedBox(width: avatarSize, height: avatarSize),
                            title: Text('新视频', style: titleStyle),
                            selected: state.type == 1,
                            onTap: () => viewModel.setSelectedTypeIndex(1),
                            shape: RoundedRectangleBorder(borderRadius: .circular(8)),
                          );
                        }
                        if (index == 2) {
                          return ListTile(
                            leading: SizedBox(width: avatarSize, height: avatarSize),
                            title: Text('新文章', style: titleStyle),
                            selected: state.type == 2,
                            onTap: () => viewModel.setSelectedTypeIndex(2),
                            shape: RoundedRectangleBorder(borderRadius: .circular(8)),
                          );
                        }

                        final user = viewModel.users[index - 3];
                        return ListTile(
                          leading: SizedBox(
                            width: avatarSize,
                            height: avatarSize,
                            child: BiliUserAvatar(url: user.avatar),
                          ),
                          title: Text(user.nickname, style: titleStyle),
                          selected: state.user == index - 3,
                          onTap: () => viewModel.setSelectedUserIndex(index - 3),
                          shape: RoundedRectangleBorder(borderRadius: .circular(8)),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: NotificationListener<ScrollNotification>(
                  onNotification: _onScroll,
                  child: ListenableBuilder(
                    listenable: viewModel.getPosts,
                    builder: (context, child) {
                      if (viewModel.getPosts.error) {
                        return CenterErrorMessage(
                          errorMessage: getErrorMessage(viewModel.getPosts.result!),
                          onRetry: viewModel.getPosts.execute,
                        );
                      }
                      if (viewModel.posts.isEmpty) {
                        if (viewModel.getPosts.running) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return const Center(child: Text('暂无内容'));
                      }

                      return MaxWidthViewport.builder(
                        maxWidth: 640,
                        builder: (context, padding) => ListView.builder(
                          padding: padding,
                          itemCount: viewModel.posts.length,
                          itemBuilder: (context, index) {
                            final borderColor = colorScheme.outline.withAlpha(50);
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(color: borderColor),
                                  right: BorderSide(color: borderColor),
                                  bottom: BorderSide(color: borderColor),
                                ),
                              ),
                              child: ChangeNotifierProvider(
                                create: (context) => PostFeedTileViewModel(
                                  postRepository: context.read(),
                                  post: viewModel.posts[index],
                                ),
                                builder: (context, child) => PostFeedTile(
                                  viewModel: context.read(),
                                  appConfig: appConfig,
                                  eagleConfig: eagleConfig,
                                  eagleRepository: eagleRepository,
                                  networkManager: networkManager,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        Selector<BiliBackgroundService, int>(
          selector: (context, service) => service.unreadPostCount,
          builder: (context, count, _) {
            final visible = count > 0;
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              top: visible ? kMinInteractiveDimension + 24 : -56,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: visible ? 1 : 0,
                child: _NewPostPill(
                  count: count,
                  onTap: viewModel.reload,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _NewPostPill extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _NewPostPill({
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.primary,
      elevation: 6,
      shadowColor: Colors.black.withAlpha(60),
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const .symmetric(horizontal: 16, vertical: 9),
          child: Row(
            mainAxisSize: .min,
            children: [
              Icon(
                Icons.keyboard_arrow_up,
                size: 18,
                color: colorScheme.onPrimary,
              ),
              const SizedBox(width: 4),
              Text(
                '$count 条新动态',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: .w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
