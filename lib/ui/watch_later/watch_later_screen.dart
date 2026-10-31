import 'package:better_bilibili/ui/core/bilibili/dynamic_card.dart';
import 'package:better_bilibili/ui/core/bilibili/favorite_folder/edit_video_in_favorite_folder_sheet/edit_video_in_favorite_folder_sheet.dart';
import 'package:better_bilibili/ui/core/share/appbar_with_search.dart';
import 'package:better_bilibili/ui/core/share/bottom_sheet_wapper.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/card_layout_builder.dart';
import 'package:better_bilibili/ui/core/share/multi_select_toolbar.dart';
import 'package:better_bilibili/ui/core/share/selectable_item_wrapper.dart';
import 'package:better_bilibili/ui/core/share/simple_dialog.dart';
import 'package:better_bilibili/ui/watch_later/watch_later_view_model.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

const _orderLabels = ['添加时间降序', '添加时间升序'];
const _typeLabels = ['全部', '未看完'];
const _addTimeLabels = ['全部', '今天', '昨天', '一周内', '一个月内', '自定义'];
const _durationLabels = ['全部', '小于10分钟', '10~30分钟', '30~60分钟', '一小时以上'];

class WatchLaterScreen extends StatefulWidget {
  final WatchLaterViewModel viewModel;

  const WatchLaterScreen({super.key, required this.viewModel});

  @override
  State<WatchLaterScreen> createState() => _WatchLaterScreenState();
}

class _WatchLaterScreenState extends State<WatchLaterScreen> {
  WatchLaterViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();

    viewModel.loadData.addListener(_onResult);
    viewModel.copySelectedItemsToFavorites.addListener(_onResult);
    viewModel.moveSelectedItemsToFavorites.addListener(_onResult);
    viewModel.deleteSelectedItems.addListener(_onResult);
    viewModel.clearWatched.addListener(_onResult);
  }

  @override
  void dispose() {
    viewModel.loadData.removeListener(_onResult);
    viewModel.copySelectedItemsToFavorites.removeListener(_onResult);
    viewModel.moveSelectedItemsToFavorites.removeListener(_onResult);
    viewModel.deleteSelectedItems.removeListener(_onResult);
    viewModel.clearWatched.removeListener(_onResult);

    super.dispose();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification.metrics.maxScrollExtent - notification.metrics.pixels <= 400 && !viewModel.loadData.running && viewModel.hasMore) {
      viewModel.loadData.execute();
    }

    return false;
  }

  void _onResult() {
    if (viewModel.copySelectedItemsToFavorites.success) {
      context.showInfo('复制成功');
      viewModel.copySelectedItemsToFavorites.clearResult();
      if (viewModel.multiSelectMode) {
        _onToggleMultiSelectMode();
      }
    }
    if (viewModel.copySelectedItemsToFavorites.error) {
      context.showError('复制失败: ${getErrorMessage(viewModel.copySelectedItemsToFavorites.result!)}');
      viewModel.copySelectedItemsToFavorites.clearResult();
    }

    if (viewModel.moveSelectedItemsToFavorites.success) {
      context.showInfo('移动成功');
      viewModel.moveSelectedItemsToFavorites.clearResult();
      if (viewModel.multiSelectMode) {
        _onToggleMultiSelectMode();
      }
    }
    if (viewModel.moveSelectedItemsToFavorites.error) {
      context.showError('移动失败: ${getErrorMessage(viewModel.moveSelectedItemsToFavorites.result!)}');
      viewModel.moveSelectedItemsToFavorites.clearResult();
    }

    if (viewModel.deleteSelectedItems.error) {
      context.showError('删除失败: ${getErrorMessage(viewModel.deleteSelectedItems.result!)}');
      viewModel.deleteSelectedItems.clearResult();
    }

    if (viewModel.clearWatched.error) {
      context.showError('清理失败: ${getErrorMessage(viewModel.clearWatched.result!)}');
      viewModel.clearWatched.clearResult();
    }
  }

  Future<void> _onCopy(dynamic item) async {
    viewModel.clearSelectedItems();
    viewModel.toggleItemSelection(item);
    await _onCopySelectedItems();
  }

  Future<void> _onMove(dynamic item) async {
    viewModel.clearSelectedItems();
    viewModel.toggleItemSelection(item);
    await _onMoveSelectedItems();
  }

  Future<void> _onDelete(dynamic item) async {
    viewModel.clearSelectedItems();
    viewModel.toggleItemSelection(item);
    await _onDeleteSelectedItems();
  }

  Future<void> _onCopySelectedItems() async {
    final favorites = await context.showFavoritesPicker(
      subtitle: '将 ${viewModel.selectedItems.length} 项复制到...',
    );
    final targetFavorites = favorites?.singleSelectedFavorite;
    if (targetFavorites == null) return;

    await viewModel.copySelectedItemsToFavorites.execute(targetFavorites.id);
  }

  Future<void> _onMoveSelectedItems() async {
    final favorites = await context.showFavoritesPicker(
      subtitle: '将 ${viewModel.selectedItems.length} 项移动到...',
    );
    final targetFavorites = favorites?.singleSelectedFavorite;
    if (targetFavorites == null) return;

    await viewModel.moveSelectedItemsToFavorites.execute(targetFavorites.id);
  }

  Future<void> _onCleanWatched() async {
    final confirm = await context.showConfirm(
      title: '清理已观看项',
      content: '确定清理已观看项吗？',
    );
    if (confirm && context.mounted) {
      await viewModel.clearWatched.execute();
    }
  }

  Future<void> _onToggleMultiSelectMode() async {
    viewModel.clearSelectedItems();
    viewModel.setMultiSelectMode(!viewModel.multiSelectMode);
  }

  Future<void> _onDeleteSelectedItems() async {
    final confirm = await context.showConfirm(
      title: '删除选中项',
      content: '确定删除选中的 ${viewModel.selectedItems.length} 项吗？',
    );
    if (confirm && context.mounted) {
      await viewModel.deleteSelectedItems.execute();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBarWithSearch(
        title: const Text('稍后观看'),
        searchHintText: '在稍后观看中搜索',
        onSearch: (value) {
          viewModel.setKeyword(value);
        },
        onToggleFilter: () {
          viewModel.rememberFiltersState();
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (context) => BottomSheetWapper(
              child: ListenableBuilder(
                listenable: viewModel,
                builder: (context, _) {
                  final List<Widget> typeChips = [];
                  for (var i = 0; i < _typeLabels.length; i++) {
                    final label = _typeLabels[i];
                    typeChips.add(
                      ChoiceChip(
                        label: Text(label),
                        selected: viewModel.selectedTypeIndex == i,
                        onSelected: (selected) {
                          viewModel.setSelectedTypeIndex(selected ? i : 0);
                        },
                      ),
                    );
                  }

                  final List<Widget> addTimeChips = [];
                  for (var i = 0; i < _addTimeLabels.length; i++) {
                    final label = _addTimeLabels[i];
                    addTimeChips.add(
                      ChoiceChip(
                        label: Text(label),
                        selected: viewModel.selectedAddTimeIndex == i,
                        onSelected: (selected) {
                          viewModel.setSelectedAddTimeIndex(selected ? i : 0);
                        },
                      ),
                    );
                  }
                  if (viewModel.selectedAddTimeIndex == 5) {
                    addTimeChips.add(
                      TextButton.icon(
                        onPressed: () async {
                          final now = DateTime.now();
                          final range = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(now.year - 1),
                            lastDate: now,
                            initialDateRange: viewModel.customAddTimeStart != null
                                ? DateTimeRange(
                                    start: DateTime.fromMillisecondsSinceEpoch(
                                      viewModel.customAddTimeStart! * 1000,
                                    ),
                                    end: DateTime.fromMillisecondsSinceEpoch(
                                      ((viewModel.customAddTimeEnd ?? viewModel.customAddTimeStart)! + 1) * 1000,
                                    ),
                                  )
                                : null,
                          );
                          if (range == null || !mounted) return;
                          final customEndSec =
                              range.end.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)).millisecondsSinceEpoch ~/ 1000;
                          viewModel.setCustomAddTimeRange(
                            startSec: range.start.millisecondsSinceEpoch ~/ 1000,
                            endSec: customEndSec,
                          );
                        },
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: const Text('选择日期'),
                      ),
                    );
                  }

                  final List<Widget> durationChips = [];
                  for (var i = 0; i < _durationLabels.length; i++) {
                    final label = _durationLabels[i];
                    durationChips.add(
                      ChoiceChip(
                        label: Text(label),
                        selected: viewModel.selectedDurationIndex == i,
                        onSelected: (selected) {
                          viewModel.setSelectedDurationIndex(selected ? i : 0);
                        },
                      ),
                    );
                  }

                  final List<Widget> orderChips = [];
                  for (var i = 0; i < _orderLabels.length; i++) {
                    final label = _orderLabels[i];
                    orderChips.add(
                      ChoiceChip(
                        label: Text(label),
                        selected: viewModel.selectedOrderIndex == i,
                        onSelected: (selected) {
                          viewModel.setSelectedOrderIndex(selected ? i : 0);
                        },
                      ),
                    );
                  }

                  final textTheme = Theme.of(context).textTheme;
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: .min,
                      crossAxisAlignment: .start,
                      children: [
                        Text('类型', style: textTheme.titleMedium),
                        const SizedBox(height: 4.0),
                        Wrap(spacing: 8.0, runSpacing: 4.0, children: typeChips),

                        const SizedBox(height: 24.0),
                        Text('添加时间', style: textTheme.titleMedium),
                        const SizedBox(height: 4.0),
                        Wrap(spacing: 8.0, runSpacing: 4.0, children: addTimeChips),

                        const SizedBox(height: 24.0),
                        Text('时长', style: textTheme.titleMedium),
                        const SizedBox(height: 4.0),
                        Wrap(spacing: 8.0, runSpacing: 4.0, children: durationChips),

                        const SizedBox(height: 24.0),
                        Text('排序方式', style: textTheme.titleMedium),
                        const SizedBox(height: 4.0),
                        Wrap(spacing: 8.0, runSpacing: 4.0, children: orderChips),
                      ],
                    ),
                  );
                },
              ),
            ),
          ).whenComplete(() {
            if (mounted) {
              viewModel.onFilterSheetDismissed();
            }
          });
        },
        actions: [
          Selector<WatchLaterViewModel, ({bool multiSelectMode, int count})>(
            selector: (context, vm) => (
              multiSelectMode: viewModel.multiSelectMode,
              count: viewModel.selectedItems.length,
            ),
            builder: (context, state, _) => MultiSelectToolbar(
              enabled: state.multiSelectMode,
              count: state.count,
              onToggleMultiSelectMode: _onToggleMultiSelectMode,
              onSelectAll: viewModel.selectAll,
              onDeselectAll: viewModel.deselectAll,
              onInvertSelection: viewModel.invertSelection,
              actions: [
                IconButton(
                  onPressed: () => _onCopySelectedItems(),
                  icon: const Icon(Icons.copy_all),
                  tooltip: '复制',
                ),
                IconButton(
                  onPressed: () => _onMoveSelectedItems(),
                  icon: const Icon(Icons.drive_file_move_outline),
                  tooltip: '移动',
                ),
                IconButton(
                  onPressed: () => _onDeleteSelectedItems(),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: '删除',
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: '更多',
            onSelected: (value) {
              if (value == 'clear') {
                _onCleanWatched();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear',
                child: Text('清理已观看项', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            ],
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: CardLayoutBuilder(
          builder: (context, constraints, gridDelegate, padding) => ListenableBuilder(
            listenable: viewModel.loadData,
            builder: (context, child) {
              if (viewModel.loadData.error) {
                return CenterErrorMessage(
                  errorMessage: getErrorMessage(viewModel.loadData.result!),
                  onRetry: viewModel.reload,
                );
              }
              if (viewModel.watchLater.isEmpty) {
                if (viewModel.loadData.running) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const Center(child: Text('暂无内容'));
              }

              return Selector<WatchLaterViewModel, ({List<dynamic> watchLater, Set<dynamic> selectedItems})>(
                selector: (context, vm) => (watchLater: vm.watchLater, selectedItems: vm.selectedItems),
                builder: (context, state, _) => GridView.builder(
                  gridDelegate: gridDelegate,
                  padding: padding,
                  itemCount: state.watchLater.length,
                  itemBuilder: (context, index) {
                    final item = state.watchLater[index];
                    final card = DynamicCard(
                      data: item,
                      contextActions: [
                        PopupMenuItem(
                          value: 'copy',
                          child: const Text('复制'),
                          onTap: () => _onCopy(item),
                        ),
                        PopupMenuItem(
                          value: 'move',
                          child: const Text('移动'),
                          onTap: () => _onMove(item),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('删除', style: TextStyle(color: colorScheme.error)),
                          onTap: () => _onDelete(item),
                        ),
                      ],
                    );

                    if (!viewModel.multiSelectMode) return card;

                    return SelectableItemWrapper(
                      borderRadius: .circular(12.0),
                      borderPadding: const .all(8.0),
                      selected: state.selectedItems.contains(item),
                      onTap: () {
                        viewModel.toggleItemSelection(item);
                      },
                      child: card,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
