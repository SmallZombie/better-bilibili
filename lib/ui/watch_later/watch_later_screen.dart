import 'package:better_bilibili/ui/core/bilibili/dynamic_card.dart';
import 'package:better_bilibili/ui/core/bilibili/favorite_folder/edit_video_in_favorite_folder_sheet/edit_video_in_favorite_folder_sheet.dart';
import 'package:better_bilibili/ui/core/share/appbar_with_search.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/grid_layout_builder.dart';
import 'package:better_bilibili/ui/core/share/multi_select_toolbar.dart';
import 'package:better_bilibili/ui/core/share/selectable_item_wrapper.dart';
import 'package:better_bilibili/ui/watch_later/watch_later_view_model.dart';
import 'package:better_bilibili/utils/result.dart' as result;
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();

    widget.viewModel.loadData.addListener(_onResult);
    widget.viewModel.copySelectedItemsToFavorites.addListener(_onResult);
    widget.viewModel.moveSelectedItemsToFavorites.addListener(_onResult);
    widget.viewModel.deleteSelectedItems.addListener(_onResult);
    widget.viewModel.clearWatched.addListener(_onResult);
  }

  @override
  void dispose() {
    widget.viewModel.loadData.removeListener(_onResult);
    widget.viewModel.copySelectedItemsToFavorites.removeListener(_onResult);
    widget.viewModel.moveSelectedItemsToFavorites.removeListener(_onResult);
    widget.viewModel.deleteSelectedItems.removeListener(_onResult);
    widget.viewModel.clearWatched.removeListener(_onResult);

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
    if (widget.viewModel.copySelectedItemsToFavorites.completed) {
      context.showInfo('复制成功');
      widget.viewModel.copySelectedItemsToFavorites.clearResult();
      if (widget.viewModel.multiSelectMode) {
        _onToggleMultiSelectMode();
      }
    }
    if (widget.viewModel.copySelectedItemsToFavorites.error) {
      final message = (widget.viewModel.copySelectedItemsToFavorites.result as result.Error).toString();
      context.showError('复制失败: $message');
      widget.viewModel.copySelectedItemsToFavorites.clearResult();
    }

    if (widget.viewModel.moveSelectedItemsToFavorites.completed) {
      context.showInfo('移动成功');
      widget.viewModel.moveSelectedItemsToFavorites.clearResult();
      if (widget.viewModel.multiSelectMode) {
        _onToggleMultiSelectMode();
      }
    }
    if (widget.viewModel.moveSelectedItemsToFavorites.error) {
      final message = (widget.viewModel.moveSelectedItemsToFavorites.result as result.Error).toString();
      context.showError('移动失败: $message');
      widget.viewModel.moveSelectedItemsToFavorites.clearResult();
    }

    if (widget.viewModel.deleteSelectedItems.error) {
      final message = (widget.viewModel.deleteSelectedItems.result as result.Error).toString();
      context.showError('删除失败: $message');
      widget.viewModel.deleteSelectedItems.clearResult();
    }

    if (widget.viewModel.clearWatched.error) {
      final message = (widget.viewModel.clearWatched.result as result.Error).toString();
      context.showError('清理失败: $message');
      widget.viewModel.clearWatched.clearResult();
    }
  }

  Future<void> _onCopy(dynamic item) async {
    widget.viewModel.clearSelectedItems();
    widget.viewModel.toggleItemSelection(item);
    _onCopySelectedItems();
  }

  Future<void> _onMove(dynamic item) async {
    widget.viewModel.clearSelectedItems();
    widget.viewModel.toggleItemSelection(item);
    _onMoveSelectedItems();
  }

  Future<void> _onDelete(dynamic item) async {
    widget.viewModel.clearSelectedItems();
    widget.viewModel.toggleItemSelection(item);
    _onDeleteSelectedItems();
  }

  Future<void> _onCopySelectedItems() async {
    final favorites = await context.showFavoritesPicker(subtitle: '将 ${widget.viewModel.selectedItems.length} 项复制到...');
    final targetFavorites = favorites?.singleSelectedFavorite;
    if (targetFavorites == null) return;

    widget.viewModel.copySelectedItemsToFavorites.execute(targetFavorites.id);
  }

  Future<void> _onMoveSelectedItems() async {
    final favorites = await context.showFavoritesPicker(subtitle: '将 ${widget.viewModel.selectedItems.length} 项移动到...');
    final targetFavorites = favorites?.singleSelectedFavorite;
    if (targetFavorites == null) return;

    widget.viewModel.moveSelectedItemsToFavorites.execute(targetFavorites.id);
  }

  Future<void> _onCleanWatched() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清理已观看项'),
        content: const Text('确定清理已观看项吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('确定')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      widget.viewModel.clearWatched.execute();
    }
  }

  Future<void> _onToggleMultiSelectMode() async {
    widget.viewModel.clearSelectedItems();
    widget.viewModel.setMultiSelectMode(!widget.viewModel.multiSelectMode);
  }

  Future<void> _onDeleteSelectedItems() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除选中项'),
        content: Text('确定删除选中的 ${widget.viewModel.selectedItems.length} 项吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('确定')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      widget.viewModel.deleteSelectedItems.execute();
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
          widget.viewModel.setKeyword(value);
        },
        onToggleFilter: () {
          widget.viewModel.rememberFiltersState();
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (sheetContext) {
              return ListenableBuilder(
                listenable: widget.viewModel,
                builder: (context, _) {
                  final double screenHeight = MediaQuery.of(context).size.height;
                  final double maxHeight = screenHeight / 2 < 500 ? screenHeight / 2 : 500;

                  final List<Widget> typeChips = [];
                  for (var i = 0; i < _typeLabels.length; i++) {
                    final label = _typeLabels[i];
                    typeChips.add(
                      ChoiceChip(
                        label: Text(label),
                        selected: widget.viewModel.selectedTypeIndex == i,
                        onSelected: (selected) {
                          widget.viewModel.setSelectedTypeIndex(selected ? i : 0);
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
                        selected: widget.viewModel.selectedAddTimeIndex == i,
                        onSelected: (selected) {
                          widget.viewModel.setSelectedAddTimeIndex(selected ? i : 0);
                        },
                      ),
                    );
                  }
                  if (widget.viewModel.selectedAddTimeIndex == 5) {
                    addTimeChips.add(
                      TextButton.icon(
                        onPressed: () async {
                          final now = DateTime.now();
                          final range = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(now.year - 1),
                            lastDate: now,
                            initialDateRange: widget.viewModel.customAddTimeStart != null
                                ? DateTimeRange(
                                    start: DateTime.fromMillisecondsSinceEpoch(
                                      widget.viewModel.customAddTimeStart! * 1000,
                                    ),
                                    end: DateTime.fromMillisecondsSinceEpoch(
                                      ((widget.viewModel.customAddTimeEnd ?? widget.viewModel.customAddTimeStart)! + 1) * 1000,
                                    ),
                                  )
                                : null,
                          );
                          if (range == null || !mounted) return;
                          final customEndSec =
                              range.end.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)).millisecondsSinceEpoch ~/ 1000;
                          widget.viewModel.setCustomAddTimeRange(
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
                        selected: widget.viewModel.selectedDurationIndex == i,
                        onSelected: (selected) {
                          widget.viewModel.setSelectedDurationIndex(selected ? i : 0);
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
                        selected: widget.viewModel.selectedOrderIndex == i,
                        onSelected: (selected) {
                          widget.viewModel.setSelectedOrderIndex(selected ? i : 0);
                        },
                      ),
                    );
                  }

                  return ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxHeight, minWidth: 640, maxWidth: 640),
                    child: SingleChildScrollView(
                      padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(24)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('类型', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4.0),
                          Wrap(spacing: 8.0, runSpacing: 4.0, children: typeChips),

                          const SizedBox(height: 24.0),
                          Text('添加时间', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4.0),
                          Wrap(spacing: 8.0, runSpacing: 4.0, children: addTimeChips),

                          const SizedBox(height: 24.0),
                          Text('时长', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4.0),
                          Wrap(spacing: 8.0, runSpacing: 4.0, children: durationChips),

                          const SizedBox(height: 24.0),
                          Text('排序方式', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4.0),
                          Wrap(spacing: 8.0, runSpacing: 4.0, children: orderChips),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ).whenComplete(() {
            if (mounted) {
              widget.viewModel.onFilterSheetDismissed();
            }
          });
        },
        actions: [
          Selector<WatchLaterViewModel, ({bool multiSelectMode, int count})>(
            selector: (context, vm) => (
              multiSelectMode: widget.viewModel.multiSelectMode,
              count: widget.viewModel.selectedItems.length,
            ),
            builder: (context, state, _) => MultiSelectToolbar(
              enabled: state.multiSelectMode,
              count: state.count,
              onToggleMultiSelectMode: _onToggleMultiSelectMode,
              onSelectAll: widget.viewModel.selectAll,
              onDeselectAll: widget.viewModel.deselectAll,
              onInvertSelection: widget.viewModel.invertSelection,
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
        child: GridLayoutBuilder(
          minColumns: 1,
          maxColumns: 5,
          minItemWidth: 280,
          imageAspectRatio: 16 / 9,
          extraHeight: 95,
          horizontalPadding: 16.0,
          builder: (context, constraints, gridDelegate) => ListenableBuilder(
            listenable: widget.viewModel.loadData,
            builder: (context, child) {
              if (widget.viewModel.loadData.running && widget.viewModel.watchLater.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (widget.viewModel.loadData.error) {
                return CenterErrorMessage(
                  errorMessage: switch (widget.viewModel.loadData.result) {
                    result.Error(:final error) => error.toString(),
                    _ => '加载失败',
                  },
                  onRetry: widget.viewModel.reload,
                );
              }

              if (widget.viewModel.watchLater.isEmpty) {
                return const Center(child: Text('暂无内容'));
              }

              return Selector<
                WatchLaterViewModel,
                ({
                  List<dynamic> watchLater,
                  Set<dynamic> selectedItems,
                })
              >(
                selector: (context, vm) => (
                  watchLater: vm.watchLater,
                  selectedItems: vm.selectedItems,
                ),
                builder: (context, state, _) => GridView.builder(
                  gridDelegate: gridDelegate,
                  itemCount: state.watchLater.length,
                  padding: const .all(16.0),
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

                    if (!widget.viewModel.multiSelectMode) return card;

                    return SelectableItemWrapper(
                      borderRadius: BorderRadius.circular(12.0),
                      borderPadding: const EdgeInsets.all(8.0),
                      selected: state.selectedItems.contains(item),
                      onTap: () {
                        widget.viewModel.toggleItemSelection(item);
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
