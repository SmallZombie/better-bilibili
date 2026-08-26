import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:better_bilibili/ui/core/bilibili/dynamic_card.dart';
import 'package:better_bilibili/ui/core/bilibili/favorite_folder/edit_video_in_favorite_folder_sheet/edit_video_in_favorite_folder_sheet.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/enhanced_appbar.dart';
import 'package:better_bilibili/ui/core/share/paginator.dart';
import 'package:better_bilibili/ui/core/share/selectable_item_wrapper.dart';
import 'package:better_bilibili/ui/favorites_detail/favorites_detail_view_model.dart';
import 'package:better_bilibili/utils/result.dart' as result;
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

const _orderLabels = ['收藏时间', '播放量', '发布时间'];

class FavoritesDetailScreen extends StatefulWidget {
  final String favoritesId;

  const FavoritesDetailScreen({super.key, required this.favoritesId});

  @override
  State<FavoritesDetailScreen> createState() => _FavoritesDetailScreenState();
}

class _FavoritesDetailScreenState extends State<FavoritesDetailScreen> {
  late FavoritesDetailViewModel _viewModel;

  bool _multiSelectMode = false;

  @override
  void initState() {
    super.initState();

    _viewModel = context.read();
    _viewModel.loadFavoritesDetail.execute(widget.favoritesId);

    _viewModel.loadFavoritesDetail.addListener(_onResult);
    _viewModel.copySelectedItemsToFavorites.addListener(_onResult);
    _viewModel.moveSelectedItemsToFavorites.addListener(_onResult);
    _viewModel.deleteSelectedItems.addListener(_onResult);
    _viewModel.clearInvalid.addListener(_onResult);
    _viewModel.deleteFavorites.addListener(_onResult);
  }

  @override
  void dispose() {
    _viewModel.loadFavoritesDetail.removeListener(_onResult);
    _viewModel.copySelectedItemsToFavorites.removeListener(_onResult);
    _viewModel.moveSelectedItemsToFavorites.removeListener(_onResult);
    _viewModel.deleteSelectedItems.removeListener(_onResult);
    _viewModel.clearInvalid.removeListener(_onResult);
    _viewModel.deleteFavorites.removeListener(_onResult);

    super.dispose();
  }

  void _onResult() {
    if (_viewModel.copySelectedItemsToFavorites.completed) {
      context.showInfo('复制成功');
      _viewModel.copySelectedItemsToFavorites.clearResult();
      if (_multiSelectMode) {
        _onToggleMultiSelectMode();
      }
    }
    if (_viewModel.copySelectedItemsToFavorites.error) {
      final message = (_viewModel.copySelectedItemsToFavorites.result as result.Error).toString();
      context.showError('复制失败: $message');
      _viewModel.copySelectedItemsToFavorites.clearResult();
    }

    if (_viewModel.moveSelectedItemsToFavorites.completed) {
      context.showInfo('移动成功');
      _viewModel.moveSelectedItemsToFavorites.clearResult();
      if (_multiSelectMode) {
        _onToggleMultiSelectMode();
      }
    }
    if (_viewModel.moveSelectedItemsToFavorites.error) {
      final message = (_viewModel.moveSelectedItemsToFavorites.result as result.Error).toString();
      context.showError('移动失败: $message');
      _viewModel.moveSelectedItemsToFavorites.clearResult();
    }

    if (_viewModel.deleteSelectedItems.completed) {
      _viewModel.deleteSelectedItems.clearResult();
      if (_multiSelectMode) {
        _onToggleMultiSelectMode();
      }
    }
    if (_viewModel.deleteSelectedItems.error) {
      final message = (_viewModel.deleteSelectedItems.result as result.Error).toString();
      context.showError('删除失败: $message');
      _viewModel.deleteSelectedItems.clearResult();
    }

    if (_viewModel.clearInvalid.error) {
      final message = (_viewModel.clearInvalid.result as result.Error).toString();
      context.showError('清理失败: $message');
      _viewModel.clearInvalid.clearResult();
    }

    if (_viewModel.deleteFavorites.completed) {
      context.showInfo('删除成功');
      context.pop();
    }
    if (_viewModel.deleteFavorites.error) {
      final message = (_viewModel.deleteFavorites.result as result.Error).toString();
      context.showError('删除失败: $message');
      _viewModel.deleteFavorites.clearResult();
    }
  }

  Future<void> _onCopy(String id) async {
    _viewModel.clearSelectedItems();
    _viewModel.toggleItemSelection(id);
    _onCopySelectedItems();
  }

  Future<void> _onMove(String id) async {
    _viewModel.clearSelectedItems();
    _viewModel.toggleItemSelection(id);
    _onMoveSelectedItems();
  }

  Future<void> _onDelete(String id) async {
    _viewModel.clearSelectedItems();
    _viewModel.toggleItemSelection(id);
    _onDeleteSelectedItems();
  }

  Future<void> _onToggleMultiSelectMode() async {
    _viewModel.clearSelectedItems();
    setState(() {
      _multiSelectMode = !_multiSelectMode;
    });
  }

  Future<void> _onCopySelectedItems() async {
    final favorites = await context.showFavoritesPicker(subtitle: '将 ${_viewModel.selectedItemIds.length} 项复制到...');
    final targetFavorites = favorites?.singleSelectedFavorite;
    if (targetFavorites == null) return;

    _viewModel.copySelectedItemsToFavorites.execute(targetFavorites.id);
  }

  Future<void> _onMoveSelectedItems() async {
    final favorites = await context.showFavoritesPicker(subtitle: '将 ${_viewModel.selectedItemIds.length} 项移动到...');
    final targetFavorites = favorites?.singleSelectedFavorite;
    if (targetFavorites == null) return;

    _viewModel.moveSelectedItemsToFavorites.execute(targetFavorites.id);
  }

  Future<void> _onEdit() async {}

  Future<void> _onCleanInvalid() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清理失效项'),
        content: const Text('确定要清理全部失效项吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确定')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      _viewModel.clearInvalid.execute();
    }
  }

  Future<void> _onDeleteFavorites() async {
    if (_viewModel.favorites == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除收藏夹'),
        content: Text('确定要删除收藏夹 "${_viewModel.favorites!.name}" ？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确定')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      _viewModel.deleteFavorites.execute();
    }
  }

  Future<void> _onDeleteSelectedItems() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除选中项'),
        content: Text('确定删除选中的 ${_viewModel.selectedItemIds.length} 项吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确定')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      _viewModel.deleteSelectedItems.execute();
    }
  }

  void _onPlayAll() {
    final video = _viewModel.items.firstOrNull;
    if (video == null) return;

    context.push(
      Routes.buildVideoDetail(
        videoId: video.id,
        episodeId: video.episodeId,
        initCover: video.cover,
        playlistId: _viewModel.favorites!.favoritesId,
      ),
    );
  }

  void _onTap(int index) {
    final item = _viewModel.items[index];
    context.push(
      Routes.buildVideoDetail(
        videoId: item.id,
        episodeId: item.episodeId,
        initCover: item.cover,
        playlistId: _viewModel.favorites!.favoritesId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ListenableBuilder(
          listenable: Listenable.merge([_viewModel, _viewModel.loadFavoritesDetail]),
          builder: (context, child) => EnhancedAppBar(
            title: Text(_viewModel.favorites?.name ?? '收藏夹详情'),
            searchHintText: '在收藏夹中搜索',
            onSearch: (value) {
              _viewModel.setKeyword(value ?? '');
            },
            onToggleMultiSelectMode: _onToggleMultiSelectMode,
            multiSelectMode: _multiSelectMode,
            multiSelectCount: _viewModel.selectedItemIds.length,
            onSelectAll: _viewModel.selectAll,
            onDeselectAll: _viewModel.deselectAll,
            onInvertSelection: _viewModel.invertSelection,
            multiSelectActions: [
              IconButton(
                onPressed: _onCopySelectedItems,
                icon: const Icon(Icons.copy_all),
                tooltip: '复制',
              ),
              IconButton(
                onPressed: _onMoveSelectedItems,
                icon: const Icon(Icons.drive_file_move_outline),
                tooltip: '移动',
              ),
              IconButton(
                onPressed: _onDeleteSelectedItems,
                icon: const Icon(Icons.delete_outline),
                tooltip: '删除',
              ),
            ],
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                tooltip: '更多',
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'modify',
                    onTap: _onEdit,
                    child: const Text('编辑'),
                  ),
                  PopupMenuItem(
                    value: 'clear',
                    onTap: _onCleanInvalid,
                    child: Text('清理失效项', style: TextStyle(color: colorScheme.error)),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    enabled: _viewModel.favorites?.isDefault == false,
                    onTap: _onDeleteFavorites,
                    child: Text('删除', style: TextStyle(color: colorScheme.error)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _viewModel.reload,
        child: const Icon(Icons.refresh),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 2100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = (constraints.maxWidth / 280).floor().clamp(1, 5);
              final childAspectRatio = 1.14 - (crossAxisCount - 1) * 0.01;
              final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: constraints.maxWidth > 1750 ? 1.25 : childAspectRatio,
              );

              return ListenableBuilder(
                listenable: Listenable.merge([_viewModel, _viewModel.loadFavoritesDetail]),
                builder: (context, child) {
                  if (_viewModel.loadFavoritesDetail.running) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_viewModel.loadFavoritesDetail.error) {
                    final message = switch (_viewModel.loadFavoritesDetail.result) {
                      result.Error(:final error) => error.toString(),
                      _ => '加载失败',
                    };
                    return CenterErrorMessage(
                      errorMessage: message,
                      onRetry: () => _viewModel.reload(),
                    );
                  }

                  if (_viewModel.items.isEmpty) {
                    return const Center(child: Text('暂无记录'));
                  }

                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BiliImageWapper(
                                height: 100,
                                aspectRatio: 16 / 9,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(12.0),
                                url: _viewModel.favorites!.cover,
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SelectableText(_viewModel.favorites!.name, style: textTheme.titleMedium),
                                  Text('共${_viewModel.total}个视频 · ${_viewModel.favorites!.isPrivate ? '私有' : '公开'}'),
                                  SizedBox(height: 8.0),
                                  FilledButton(
                                    onPressed: _onPlayAll,
                                    child: const Text('播放全部'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: Divider()),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            children: [
                              Text('排序：', style: textTheme.bodyMedium),
                              const SizedBox(width: 8),
                              Wrap(
                                spacing: 8,
                                children: List.generate(_orderLabels.length, (i) {
                                  return FilterChip(
                                    label: Text(_orderLabels[i]),
                                    selected: _viewModel.selectedOrderIndex == i,
                                    onSelected: (selected) {
                                      if (selected) {
                                        _viewModel.setSelectedOrderIndex(i);
                                      }
                                    },
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        sliver: SliverGrid.builder(
                          gridDelegate: gridDelegate,
                          itemCount: _viewModel.items.length,
                          itemBuilder: (context, index) {
                            final item = _viewModel.items[index];
                            final id = _viewModel.getItemId(item);
                            final card = DynamicCard(
                              data: item,
                              contextActions: [
                                PopupMenuItem(
                                  value: 'copy',
                                  child: Text('复制'),
                                  onTap: () => _onCopy(id),
                                ),
                                PopupMenuItem(
                                  value: 'move',
                                  child: Text('移动'),
                                  onTap: () => _onMove(id),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('删除', style: TextStyle(color: colorScheme.error)),
                                  onTap: () => _onDelete(id),
                                ),
                              ],
                              onTap: () => _onTap(index),
                            );

                            if (!_multiSelectMode) return card;

                            return SelectableItemWrapper(
                              borderRadius: BorderRadius.circular(12.0),
                              borderPadding: const EdgeInsets.all(8.0),
                              selected: _viewModel.selectedItemIds.contains(id),
                              onTap: () {
                                _viewModel.toggleItemSelection(id);
                              },
                              child: card,
                            );
                          },
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
                      SliverToBoxAdapter(
                        child: Paginator(
                          maxPageCount: (_viewModel.total + 19) ~/ 20, // 向上取整
                          currentPage: _viewModel.pn,
                          onPageChanged: (page) => _viewModel.setPn(page),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: kBottomNavigationBarHeight)),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
