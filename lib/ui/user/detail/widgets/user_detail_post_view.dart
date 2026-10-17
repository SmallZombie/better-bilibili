import 'package:better_bilibili/config/app_config.dart';
import 'package:better_bilibili/config/eagle_config.dart';
import 'package:better_bilibili/data/repositories/eagle/eagle_repository.dart';
import 'package:better_bilibili/data/services/network_manager.dart';
import 'package:better_bilibili/ui/core/bilibili/post/post_feed_tile/post_feed_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/post/post_feed_tile/post_feed_tile_view_model.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/sliver_max_width_box.dart';
import 'package:better_bilibili/ui/user/detail/view_models/user_detail_post_view_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

const _orderLabels = ['全部', '视频'];

class UserDetailPostView extends StatefulWidget {
  final UserDetailPostViewModel viewModel;
  final AppConfig appConfig;
  final EagleConfig eagleConfig;
  final EagleRepository eagleRepository;
  final NetworkManager networkManager;

  const UserDetailPostView({
    super.key,
    required this.viewModel,
    required this.appConfig,
    required this.eagleConfig,
    required this.eagleRepository,
    required this.networkManager,
  });

  @override
  State<UserDetailPostView> createState() => _UserDetailPostViewState();
}

class _UserDetailPostViewState extends State<UserDetailPostView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification.metrics.maxScrollExtent - notification.metrics.pixels <= 400 &&
        !widget.viewModel.loadData.running &&
        widget.viewModel.hasMore) {
      widget.viewModel.loadData.execute();
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final List<Widget> chips = [];
    for (int i = 0; i < _orderLabels.length; i++) {
      chips.add(
        Selector<UserDetailPostViewModel, int>(
          selector: (context, vm) => vm.selectedTypeIndex,
          builder: (context, selectedOrderIndex, _) => ChoiceChip(
            label: Text(_orderLabels[i]),
            selected: selectedOrderIndex == i,
            onSelected: (value) => widget.viewModel.setSelectedTypeIndex(i),
          ),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const .symmetric(horizontal: 16.0, vertical: 8.0),
            sliver: SliverToBoxAdapter(
              child: Row(spacing: 8.0, children: chips),
            ),
          ),
          _PostListSliver(
            viewModel: widget.viewModel,
            appConfig: widget.appConfig,
            eagleConfig: widget.eagleConfig,
            eagleRepository: widget.eagleRepository,
            networkManager: widget.networkManager,
          ),
        ],
      ),
    );
  }
}

class _PostListSliver extends StatelessWidget {
  final UserDetailPostViewModel viewModel;
  final AppConfig appConfig;
  final EagleConfig eagleConfig;
  final EagleRepository eagleRepository;
  final NetworkManager networkManager;

  const _PostListSliver({
    required this.viewModel,
    required this.appConfig,
    required this.eagleConfig,
    required this.eagleRepository,
    required this.networkManager,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: viewModel.loadData,
      builder: (context, child) {
        if (viewModel.loadData.running && viewModel.posts.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.loadData.error) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: CenterErrorMessage(
              errorMessage: viewModel.loadData.result.toString(),
              onRetry: viewModel.reload,
            ),
          );
        }

        if (viewModel.posts.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('暂无内容')),
          );
        }

        return SliverMaxWidthBox(
          maxWidth: 800,
          sliver: SliverList.builder(
            itemCount: viewModel.posts.length,
            itemBuilder: (context, index) {
              final post = viewModel.posts[index];
              return DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: colorScheme.outline),
                    left: BorderSide(color: colorScheme.outline),
                    right: BorderSide(color: colorScheme.outline),
                  ),
                ),
                child: ChangeNotifierProvider(
                  create: (context) => PostFeedTileViewModel(post: post, postRepository: context.read()),
                  builder: (context, _) => PostFeedTile(
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
    );
  }
}
