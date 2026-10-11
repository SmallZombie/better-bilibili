import 'dart:ui';

import 'package:better_bilibili/data/services/bilibili/bili_background_service.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_post_list_response.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_user_avatar.dart';
import 'package:better_bilibili/ui/core/bilibili/post/post_feed_tile/post_feed_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/post/post_feed_tile/post_feed_tile_view_model.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/home/view_models/post_view_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class PostView extends StatefulWidget {
  final PostViewModel viewModel;

  const PostView({super.key, required this.viewModel});

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.maxScrollExtent - _scrollController.position.pixels <= 400 &&
        !widget.viewModel.getPosts.running &&
        widget.viewModel.hasMore) {
      widget.viewModel.getPosts.execute();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final vm = context.watch<PostViewModel>();

    if (vm.getPosts.error) {
      return CenterErrorMessage(
        errorMessage: vm.getPosts.result.toString(),
        onRetry: vm.getPosts.execute,
      );
    }
    if (vm.getUsers.error) {
      return CenterErrorMessage(
        errorMessage: vm.getUsers.result.toString(),
        onRetry: vm.getUsers.execute,
      );
    }

    final maxContentWidth = 640;

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
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
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: 3 + vm.users.length,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ChoiceChip(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 9.6),
                          label: Text('全部'),
                          showCheckmark: false,
                          selected: vm.selectedTypeIndex == 0,
                          onSelected: (selected) => vm.setSelectedTypeIndex(0),
                        );
                      } else if (index == 1) {
                        return ChoiceChip(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 9.6),
                          label: Text('新视频'),
                          showCheckmark: false,
                          selected: vm.selectedTypeIndex == 1,
                          onSelected: (selected) => vm.setSelectedTypeIndex(1),
                        );
                      } else if (index == 2) {
                        return ChoiceChip(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 9.6),
                          label: Text('新文章'),
                          showCheckmark: false,
                          selected: vm.selectedTypeIndex == 2,
                          onSelected: (selected) => vm.setSelectedTypeIndex(2),
                        );
                      } else {
                        final user = vm.users[index - 3];
                        return ChoiceChip(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 6.0),
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 4.0,
                            children: [
                              SizedBox(
                                width: 26.0,
                                height: 26.0,
                                child: BiliUserAvatar(url: user.avatar),
                              ),
                              Text(user.nickname),
                            ],
                          ),
                          showCheckmark: false,
                          selected: vm.selectedUserIndex == index - 3,
                          onSelected: (selected) => vm.setSelectedUserIndex(index - 3),
                        );
                      }
                    },
                    separatorBuilder: (context, index) => const SizedBox(width: 4.0),
                  ),
                ),
              ),
              Expanded(
                child: Selector<PostViewModel, List<Post>>(
                  selector: (context, vm) => vm.posts,
                  builder: (context, posts, child) {
                    if (posts.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) => ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: ((constraints.maxWidth - maxContentWidth) / 2).clamp(0, double.infinity),
                        ),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: colorScheme.outline),
                                right: BorderSide(color: colorScheme.outline),
                                bottom: BorderSide(color: colorScheme.outline),
                              ),
                            ),
                            child: ChangeNotifierProvider(
                              create: (context) => PostFeedTileViewModel(postRepository: context.read(), post: posts[index]),
                              builder: (context, child) => PostFeedTile(viewModel: context.read()),
                            ),
                          );
                        },
                      ),
                    );
                  },
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
                    onTap: widget.viewModel.reload,
                  ),
                ),
              );
            },
          ),
        ],
      ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
