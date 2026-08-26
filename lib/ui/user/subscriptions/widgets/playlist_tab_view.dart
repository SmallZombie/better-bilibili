import 'package:better_bilibili/data/services/bilibili/model/get_subscribed_playlists_response.dart';
import 'package:better_bilibili/ui/core/bilibili/favorite_folder/favorites_card.dart';
import 'package:better_bilibili/ui/core/bilibili/playlist/playlist_card.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/grid_layout_builder.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/ui/user/subscriptions/view_models/playlist_tab_view_model.dart';
import 'package:flutter/material.dart';
import 'package:better_bilibili/utils/result.dart' as result;

class PlaylistTabView extends StatefulWidget {
  final PlaylistTabViewModel viewModel;

  const PlaylistTabView({super.key, required this.viewModel});

  @override
  State<PlaylistTabView> createState() => _PlaylistTabState();
}

class _PlaylistTabState extends State<PlaylistTabView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    widget.viewModel.loadData.addListener(_onResult);
    widget.viewModel.unsubscribe.addListener(_onResult);
  }

  @override
  void dispose() {
    widget.viewModel.loadData.removeListener(_onResult);
    widget.viewModel.unsubscribe.removeListener(_onResult);

    super.dispose();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification.metrics.maxScrollExtent - notification.metrics.pixels <= 400 &&
        !widget.viewModel.loadData.running &&
        widget.viewModel.hasMore) {
      widget.viewModel.loadData.execute();
    }

    return false;
  }

  void _onResult() {
    if (widget.viewModel.unsubscribe.error) {
      final message = (widget.viewModel.unsubscribe.result as result.Error).toString();
      context.showError('退订失败: $message');
      widget.viewModel.unsubscribe.clearResult();
    }
  }

  Future<void> _onUnsubscribe(dynamic item) async {
    String getName() {
      if (item is SubscribedFavorites) {
        return item.name;
      } else if (item is SubscribedPlaylist) {
        return item.name;
      }
      return '';
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除收藏夹'),
        content: Text('确定要删除 "${getName()}" 吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确定')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      widget.viewModel.unsubscribe.execute(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final colorScheme = Theme.of(context).colorScheme;

    return GridLayoutBuilder(
      minColumns: 1,
      maxColumns: 5,
      minItemWidth: 280,
      imageAspectRatio: 16 / 9,
      extraHeight: 100,
      horizontalPadding: 16,
      builder: (context, constraints, gridDelegate) => ListenableBuilder(
        listenable: widget.viewModel.loadData,
        builder: (context, child) {
          if (widget.viewModel.loadData.running && widget.viewModel.playlists.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.loadData.error) {
            final message = switch (widget.viewModel.loadData.result) {
              result.Error(:final error) => error.toString(),
              _ => '加载失败',
            };
            return CenterErrorMessage(
              errorMessage: message,
              onRetry: () => widget.viewModel.reload(),
            );
          }

          if (widget.viewModel.playlists.isEmpty) {
            return const Center(child: Text('暂无内容'));
          }

          return NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: GridView.builder(
              gridDelegate: gridDelegate,
              itemCount: widget.viewModel.playlists.length,
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, kBottomNavigationBarHeight),
              itemBuilder: (context, index) {
                final item = widget.viewModel.playlists[index];

                final List<PopupMenuItem<String>> contextActions = [];
                if (widget.viewModel.isCurrentUser) {
                  contextActions.add(
                    PopupMenuItem(
                      value: 'unsubscribe',
                      child: Text('退订', style: TextStyle(color: colorScheme.error)),
                      onTap: () => _onUnsubscribe(item),
                    ),
                  );
                }

                if (item is SubscribedFavorites) {
                  return FavoritesCard(
                    favoritesId: item.id,
                    cover: item.cover,
                    title: item.name,
                    user: item.owner,
                    total: item.total,
                    contextActions: contextActions,
                  );
                } else if (item is SubscribedPlaylist) {
                  return PlaylistCard(
                    playlistId: item.id,
                    cover: item.cover,
                    title: item.name,
                    user: item.owner,
                    total: item.total,
                    contextActions: contextActions,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }
}
