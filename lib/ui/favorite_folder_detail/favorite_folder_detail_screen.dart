import 'dart:async';

import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:better_bilibili/ui/core/bilibili/dynamic_card.dart';
import 'package:better_bilibili/ui/core/bilibili/favorite_folder/edit_video_in_favorite_folder_sheet/edit_video_in_favorite_folder_sheet.dart';
import 'package:better_bilibili/ui/core/share/appbar_with_search.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/multi_select_toolbar.dart';
import 'package:better_bilibili/ui/core/share/paginator.dart';
import 'package:better_bilibili/ui/core/share/selectable_item_wrapper.dart';
import 'package:better_bilibili/ui/core/share/simple_dialog.dart';
import 'package:better_bilibili/ui/core/share/sliver_card_layout_builder.dart';
import 'package:better_bilibili/ui/favorite_folder_detail/favorite_folder_detail_view_model.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

const _orderLabels = ['收藏时间', '播放量', '发布时间'];

class FavoriteFolderDetailScreen extends StatefulWidget {
  final FavoriteFolderDetailViewModel viewModel;

  const FavoriteFolderDetailScreen({super.key, required this.viewModel});

  @override
  State<FavoriteFolderDetailScreen> createState() => _FavoriteFolderDetailScreenState();
}

class _FavoriteFolderDetailScreenState extends State<FavoriteFolderDetailScreen> {
  FavoriteFolderDetailViewModel get viewModel => widget.viewModel;

  bool _multiSelectMode = false;

  @override
  void initState() {
    super.initState();

    viewModel.loadData.addListener(_onResult);
    viewModel.copySelectedItemsToFavorites.addListener(_onResult);
    viewModel.moveSelectedItemsToFavorites.addListener(_onResult);
    viewModel.deleteSelectedItems.addListener(_onResult);
    viewModel.clearInvalid.addListener(_onResult);
    viewModel.deleteFavorites.addListener(_onResult);
  }

  @override
  void dispose() {
    viewModel.loadData.removeListener(_onResult);
    viewModel.copySelectedItemsToFavorites.removeListener(_onResult);
    viewModel.moveSelectedItemsToFavorites.removeListener(_onResult);
    viewModel.deleteSelectedItems.removeListener(_onResult);
    viewModel.clearInvalid.removeListener(_onResult);
    viewModel.deleteFavorites.removeListener(_onResult);

    super.dispose();
  }

  void _onResult() {
    if (viewModel.copySelectedItemsToFavorites.success) {
      context.showInfo('复制成功');
      viewModel.copySelectedItemsToFavorites.clearResult();
      if (_multiSelectMode) {
        _onToggleMultiSelectMode();
      }
    }
    if (viewModel.copySelectedItemsToFavorites.error) {
      final message = getErrorMessage(viewModel.copySelectedItemsToFavorites.result!);
      context.showError('复制失败: $message');
      viewModel.copySelectedItemsToFavorites.clearResult();
    }

    if (viewModel.moveSelectedItemsToFavorites.success) {
      context.showInfo('移动成功');
      viewModel.moveSelectedItemsToFavorites.clearResult();
      if (_multiSelectMode) {
        _onToggleMultiSelectMode();
      }
    }
    if (viewModel.moveSelectedItemsToFavorites.error) {
      final message = getErrorMessage(viewModel.moveSelectedItemsToFavorites.result!);
      context.showError('移动失败: $message');
      viewModel.moveSelectedItemsToFavorites.clearResult();
    }

    if (viewModel.deleteSelectedItems.success) {
      viewModel.deleteSelectedItems.clearResult();
      if (_multiSelectMode) {
        _onToggleMultiSelectMode();
      }
    }
    if (viewModel.deleteSelectedItems.error) {
      final message = getErrorMessage(viewModel.deleteSelectedItems.result!);
      context.showError('删除失败: $message');
      viewModel.deleteSelectedItems.clearResult();
    }

    if (viewModel.clearInvalid.error) {
      final message = getErrorMessage(viewModel.clearInvalid.result!);
      context.showError('清理失败: $message');
      viewModel.clearInvalid.clearResult();
    }

    if (viewModel.deleteFavorites.success) {
      context.showInfo('删除成功');
      context.pop();
    }
    if (viewModel.deleteFavorites.error) {
      final message = getErrorMessage(viewModel.deleteFavorites.result!);
      context.showError('删除失败: $message');
      viewModel.deleteFavorites.clearResult();
    }
  }

  Future<void> _onCopy(String id) async {
    viewModel.clearSelectedItems();
    viewModel.toggleItemSelection(id);
    unawaited(_copySelectedItems());
  }

  Future<void> _onMove(String id) async {
    viewModel.clearSelectedItems();
    viewModel.toggleItemSelection(id);
    unawaited(_moveSelectedItems());
  }

  Future<void> _onDelete(String id) async {
    viewModel.clearSelectedItems();
    viewModel.toggleItemSelection(id);
    unawaited(_deleteSelectedItems());
  }

  Future<void> _onToggleMultiSelectMode() async {
    viewModel.clearSelectedItems();
    setState(() {
      _multiSelectMode = !_multiSelectMode;
    });
  }

  Future<void> _copySelectedItems() async {
    final favorites = await context.showFavoritesPicker(
      subtitle: '将 ${viewModel.selectedItemIds.length} 项复制到...',
    );
    final targetFavorites = favorites?.singleSelectedFavorite;
    if (targetFavorites == null) return;

    unawaited(viewModel.copySelectedItemsToFavorites.execute(targetFavorites.id));
  }

  Future<void> _moveSelectedItems() async {
    final favorites = await context.showFavoritesPicker(
      subtitle: '将 ${viewModel.selectedItemIds.length} 项移动到...',
    );
    final targetFavorites = favorites?.singleSelectedFavorite;
    if (targetFavorites == null) return;

    unawaited(viewModel.moveSelectedItemsToFavorites.execute(targetFavorites.id));
  }

  Future<void> _onEdit() async {}

  Future<void> _onCleanInvalid() async {
    final confirm = await context.showConfirm(
      title: '清理失效项',
      content: '确定要清理全部失效项吗？',
    );
    if (confirm && context.mounted) {
      unawaited(viewModel.clearInvalid.execute());
    }
  }

  Future<void> _onDeleteFavorites() async {
    if (viewModel.data == null) return;
    final confirm = await context.showConfirm(
      title: '删除收藏夹',
      content: '确定要删除收藏夹 "${viewModel.data!.name}" 吗？',
    );
    if (confirm && context.mounted) {
      unawaited(viewModel.deleteFavorites.execute());
    }
  }

  Future<void> _deleteSelectedItems() async {
    final confirm = await context.showConfirm(
      title: '删除选中项',
      content: '确定删除选中的 ${viewModel.selectedItemIds.length} 项吗？',
    );
    if (confirm && context.mounted) {
      unawaited(viewModel.deleteSelectedItems.execute());
    }
  }

  void _onPlayAll() {
    final video = viewModel.items.firstOrNull;
    if (video == null) return;

    context.push(
      Routes.buildVideoDetail(
        videoId: video.id,
        episodeId: video.episodeId,
        initCover: video.cover,
        playlistId: viewModel.data!.favoritesId,
      ),
    );
  }

  void _onTap(int index) {
    final item = viewModel.items[index];
    context.push(
      Routes.buildVideoDetail(
        videoId: item.id,
        episodeId: item.episodeId,
        initCover: item.cover,
        playlistId: viewModel.data!.favoritesId,
      ),
    );
  }

  bool _searchMode = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ListenableBuilder(
          listenable: Listenable.merge([viewModel, viewModel.loadData]),
          builder: (context, child) => AppBarWithSearch(
            title: Text(viewModel.data?.name ?? '收藏夹详情'),
            searchHintText: '在收藏夹中搜索',
            onSearch: (value) {
              viewModel.setKeyword(value);
            },
            searchMode: _searchMode,
            onToggleSearchMode: () {
              if (_searchMode) {
                viewModel.setKeyword('');
              }
              setState(() => _searchMode = !_searchMode);
            },
            actions: [
              MultiSelectToolbar(
                enabled: _multiSelectMode,
                count: viewModel.selectedItemIds.length,
                onToggleMultiSelectMode: _onToggleMultiSelectMode,
                onSelectAll: viewModel.selectAll,
                onDeselectAll: viewModel.deselectAll,
                onInvertSelection: viewModel.invertSelection,
                actions: [
                  IconButton(
                    onPressed: _copySelectedItems,
                    icon: const Icon(Icons.copy_all),
                    tooltip: '复制',
                  ),
                  IconButton(
                    onPressed: _moveSelectedItems,
                    icon: const Icon(Icons.drive_file_move_outline),
                    tooltip: '移动',
                  ),
                  IconButton(
                    onPressed: _deleteSelectedItems,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: '删除',
                  ),
                ],
              ),
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
                    enabled: viewModel.data?.isDefault == false,
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
        onPressed: viewModel.reset,
        child: const Icon(Icons.refresh),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([viewModel, viewModel.loadData]),
        builder: (context, child) {
          if (viewModel.loadData.error) {
            return CenterErrorMessage(
              errorMessage: getErrorMessage(viewModel.loadData.result!),
              onRetry: viewModel.reset,
            );
          }
          if (viewModel.items.isEmpty) {
            if (viewModel.loadData.running) {
              return const Center(child: CircularProgressIndicator());
            }
            return const Center(child: Text('暂无内容'));
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const .symmetric(horizontal: 16.0, vertical: 12.0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    crossAxisAlignment: .start,
                    spacing: 16.0,
                    children: [
                      BiliImageWapper(
                        height: 100,
                        aspectRatio: 16 / 9,
                        fit: .cover,
                        borderRadius: .circular(12.0),
                        url: viewModel.data!.cover,
                      ),
                      Column(
                        crossAxisAlignment: .start,
                        children: [
                          SelectableText(viewModel.data!.name, style: textTheme.titleMedium),
                          Text('共${viewModel.total}个视频 · ${viewModel.data!.isPrivate ? '私有' : '公开'}'),
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
                  padding: const .symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Text('排序：', style: textTheme.bodyMedium),
                      const SizedBox(width: 8),
                      Wrap(
                        spacing: 8,
                        children: List.generate(_orderLabels.length, (i) {
                          return FilterChip(
                            label: Text(_orderLabels[i]),
                            selected: viewModel.selectedOrderIndex == i,
                            onSelected: (selected) {
                              if (selected) {
                                viewModel.setSelectedOrderIndex(i);
                              }
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              SliverCardLayoutBuilder(
                builder: (context, constraints, gridDelegate) => SliverGrid.builder(
                  gridDelegate: gridDelegate,
                  itemCount: viewModel.items.length,
                  itemBuilder: (context, index) {
                    final item = viewModel.items[index];
                    final id = viewModel.getItemId(item);
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
                      borderRadius: .circular(12.0),
                      borderPadding: const .all(8.0),
                      selected: viewModel.selectedItemIds.contains(id),
                      onTap: () {
                        viewModel.toggleItemSelection(id);
                      },
                      child: card,
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
              SliverToBoxAdapter(
                child: Paginator(
                  maxPageCount: (viewModel.total + 19) ~/ 20,
                  currentPage: viewModel.pn,
                  onPageChanged: viewModel.setPn,
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: kBottomNavigationBarHeight)),
            ],
          );
        },
      ),
    );
  }
}
