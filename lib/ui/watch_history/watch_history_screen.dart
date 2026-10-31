import 'package:better_bilibili/ui/core/bilibili/dynamic_card.dart';
import 'package:better_bilibili/ui/core/share/appbar_with_search.dart';
import 'package:better_bilibili/ui/core/share/card_layout_builder.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/multi_select_toolbar.dart';
import 'package:better_bilibili/ui/core/share/selectable_item_wrapper.dart';
import 'package:better_bilibili/ui/core/share/simple_dialog.dart';
import 'package:better_bilibili/ui/watch_history/watch_history_view_model.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

const _typeLabels = ['全部', '视频', '文章', '直播'];
const _durationLabels = ['全部', '小于10分钟', '10~30分钟', '30~60分钟', '一小时以上'];
const _recordTimeLabels = ['全部', '昨天', '一周内', '一个月内', '自定义'];
const _deviceLabels = ['全部', 'PC', '手机', '平板', 'TV'];

class WatchHistoryScreen extends StatefulWidget {
  final WatchHistoryViewModel viewModel;

  const WatchHistoryScreen({super.key, required this.viewModel});

  @override
  State<WatchHistoryScreen> createState() => _WatchHistoryScreenState();
}

class _WatchHistoryScreenState extends State<WatchHistoryScreen> {
  WatchHistoryViewModel get viewModel => widget.viewModel;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _multiSelectMode = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
    viewModel.loadHistoryConfig.addListener(_onResult);
    viewModel.setHistoryConfig.addListener(_onResult);
    viewModel.clearAllWatchHistory.addListener(_onResult);
    viewModel.deleteSelectedItems.addListener(_onResult);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();

    _scrollController.removeListener(_onScroll);
    viewModel.loadHistoryConfig.removeListener(_onResult);
    viewModel.setHistoryConfig.removeListener(_onResult);
    viewModel.clearAllWatchHistory.removeListener(_onResult);
    viewModel.deleteSelectedItems.removeListener(_onResult);

    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.maxScrollExtent - _scrollController.position.pixels <= 400 &&
        !viewModel.loadWatchHistory.running &&
        viewModel.hasMore) {
      viewModel.loadWatchHistory.execute();
    }
  }

  void _onResult() {
    if (viewModel.loadHistoryConfig.error) {
      context.showError('获取历史记录配置失败: ${getErrorMessage(viewModel.loadHistoryConfig.result!)}');
      viewModel.loadHistoryConfig.clearResult();
    }

    if (viewModel.setHistoryConfig.success) {
      context.showInfo('已${viewModel.isHistoryEnabled! ? '启用' : '禁用'}历史记录');
      viewModel.setHistoryConfig.clearResult();
    }
    if (viewModel.setHistoryConfig.error) {
      context.showError('修改失败: ${getErrorMessage(viewModel.setHistoryConfig.result!)}');
      viewModel.setHistoryConfig.clearResult();
    }

    if (viewModel.clearAllWatchHistory.error) {
      context.showError('清空失败: ${getErrorMessage(viewModel.clearAllWatchHistory.result!)}');
      viewModel.clearAllWatchHistory.clearResult();
    }

    if (viewModel.deleteSelectedItems.success) {
      if (_multiSelectMode) {
        _onToggleMultiSelectMode();
      }
    }
    if (viewModel.deleteSelectedItems.error) {
      context.showError('删除失败: ${getErrorMessage(viewModel.deleteSelectedItems.result!)}');
      viewModel.deleteSelectedItems.clearResult();
    }
  }

  void _onToggleConfig() {
    viewModel.setHistoryConfig.execute(!viewModel.isHistoryEnabled!);
  }

  Future<void> _onClearHistory() async {
    final confirm = await context.showConfirm(
      title: '清空观看历史',
      content: '确定清空全部观看历史吗？',
    );
    if (confirm && context.mounted) {
      await viewModel.clearAllWatchHistory.execute();
    }
  }

  Future<void> _onToggleMultiSelectMode() async {
    viewModel.clearSelectedItems();
    setState(() {
      _multiSelectMode = !_multiSelectMode;
    });
  }

  void _onDelete(dynamic item) {
    viewModel.clearSelectedItems();
    viewModel.toggleItemSelection(item);
    _onDeleteSelectedItems();
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

  bool _searchMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, child) => AppBarWithSearch(
            title: const Text('观看历史'),
            searchHintText: '在观看历史中搜索',
            searchMode: _searchMode,
            onToggleSearchMode: () {
              if (_searchMode) {
                viewModel.setKeyword('');
              }
              setState(() => _searchMode = !_searchMode);
            },
            onSearch: (value) {
              viewModel.setKeyword(value);
            },
            onToggleFilter: () {
              viewModel.rememberFiltersState();
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (sheetContext) {
                  return ListenableBuilder(
                    listenable: viewModel,
                    builder: (context, _) {
                      final double screenHeight = MediaQuery.sizeOf(context).height;
                      final double maxHeight = screenHeight / 2 < 500 ? screenHeight / 2 : 500;

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

                      final List<Widget> recordTimeChips = [];
                      for (var i = 0; i < _recordTimeLabels.length; i++) {
                        final label = _recordTimeLabels[i];
                        recordTimeChips.add(
                          ChoiceChip(
                            label: Text(label),
                            selected: viewModel.selectedRecordTimeIndex == i,
                            onSelected: (selected) {
                              viewModel.setSelectedRecordTimeIndex(selected ? i : 0);
                            },
                          ),
                        );
                      }
                      if (viewModel.selectedRecordTimeIndex == 4) {
                        recordTimeChips.add(
                          TextButton.icon(
                            onPressed: () async {
                              final now = DateTime.now();
                              final range = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(now.year - 1),
                                lastDate: now,
                                initialDateRange: viewModel.customRecordTimeStartSec != null
                                    ? DateTimeRange(
                                        start: DateTime.fromMillisecondsSinceEpoch(
                                          viewModel.customRecordTimeStartSec! * 1000,
                                        ),
                                        end: DateTime.fromMillisecondsSinceEpoch(
                                          (viewModel.customRecordTimeEndSec ?? viewModel.customRecordTimeStartSec)! * 1000,
                                        ),
                                      )
                                    : null,
                              );
                              if (range == null || !mounted) return;
                              viewModel.setCustomRecordTimeRange(
                                startSec: range.start.millisecondsSinceEpoch ~/ 1000,
                                endSec: range.end.millisecondsSinceEpoch ~/ 1000,
                              );
                            },
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: const Text('选择日期'),
                          ),
                        );
                      }

                      final List<Widget> deviceChips = [];
                      for (var i = 0; i < _deviceLabels.length; i++) {
                        final label = _deviceLabels[i];
                        deviceChips.add(
                          ChoiceChip(
                            label: Text(label),
                            selected: viewModel.selectedDeviceIndex == i,
                            onSelected: (selected) {
                              viewModel.setSelectedDeviceIndex(selected ? i : 0);
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
                              Wrap(spacing: 8.0, children: typeChips),

                              const SizedBox(height: 24.0),
                              Text('时长', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4.0),
                              Wrap(spacing: 8.0, children: durationChips),

                              const SizedBox(height: 24.0),
                              Text('记录时间', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4.0),
                              Wrap(spacing: 8.0, children: recordTimeChips),

                              const SizedBox(height: 24.0),
                              Text('设备', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4.0),
                              Wrap(spacing: 8.0, children: deviceChips),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ).whenComplete(() {
                if (mounted) {
                  viewModel.onFilterSheetDismissed();
                }
              });
            },
            actions: [
              MultiSelectToolbar(
                onToggleMultiSelectMode: _onToggleMultiSelectMode,
                enabled: _multiSelectMode,
                count: viewModel.selectedItems.length,
                onSelectAll: viewModel.selectAll,
                onDeselectAll: viewModel.deselectAll,
                onInvertSelection: viewModel.invertSelection,
                actions: [
                  IconButton(
                    onPressed: _onDeleteSelectedItems,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: '删除',
                  ),
                ],
              ),
              ListenableBuilder(
                listenable: Listenable.merge([viewModel.loadHistoryConfig, viewModel.setHistoryConfig]),
                builder: (context, child) => PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  tooltip: '更多',
                  onSelected: viewModel.isHistoryEnabled != null
                      ? (value) {
                          if (value == 'toggle_config') {
                            _onToggleConfig();
                          } else if (value == 'clear') {
                            _onClearHistory();
                          }
                        }
                      : null,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'toggle_config',
                      enabled: viewModel.isHistoryEnabled != null,
                      child: Text(
                        viewModel.isHistoryEnabled == null ? '...' : (viewModel.isHistoryEnabled! ? '关闭历史记录' : '开启历史记录'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'clear',
                      child: Text('清空历史', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: CardLayoutBuilder(
        padding: .symmetric(horizontal: 16.0),
        builder: (context, constraints, gridDelegate, padding) => ListenableBuilder(
          listenable: viewModel.loadWatchHistory,
          builder: (context, child) {
            if (viewModel.loadWatchHistory.error) {
              return CenterErrorMessage(
                errorMessage: getErrorMessage(viewModel.loadWatchHistory.result!),
                onRetry: viewModel.reload,
              );
            }
            if (viewModel.watchHistory.isEmpty) {
              if (viewModel.loadWatchHistory.running) {
                return const Center(child: CircularProgressIndicator());
              }
              return const Center(child: Text('暂无内容'));
            }

            return Selector<WatchHistoryViewModel, Set<dynamic>>(
              selector: (context, vm) => vm.selectedItems,
              builder: (context, value, _) => CustomScrollView(
                controller: _scrollController,
                slivers: [
                  if (viewModel.todayList.isNotEmpty)
                    ..._buildDateList(
                      context,
                      '今天',
                      viewModel.todayList,
                      gridDelegate,
                      padding,
                    ),
                  if (viewModel.yesterdayList.isNotEmpty)
                    ..._buildDateList(
                      context,
                      '昨天',
                      viewModel.yesterdayList,
                      gridDelegate,
                      padding,
                    ),
                  if (viewModel.beforeYesterdayList.isNotEmpty)
                    ..._buildDateList(
                      context,
                      '前天',
                      viewModel.beforeYesterdayList,
                      gridDelegate,
                      padding,
                    ),
                  if (viewModel.otherList.isNotEmpty)
                    ..._buildDateList(
                      context,
                      '更早',
                      viewModel.otherList,
                      gridDelegate,
                      padding,
                    ),
                  SliverToBoxAdapter(child: SizedBox(height: kBottomNavigationBarHeight)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildDateList(
    BuildContext context,
    String title,
    List<dynamic> list,
    SliverGridDelegate gridDelegate,
    EdgeInsets padding,
  ) {
    return [
      SliverPadding(
        padding: padding,
        sliver: SliverToBoxAdapter(
          child: Text(title, style: TextStyle(fontSize: 24.0)),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 4.0)),
      SliverPadding(
        padding: padding,
        sliver: SliverGrid.builder(
          gridDelegate: gridDelegate,
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            final card = DynamicCard(
              data: item,
              contextActions: [
                PopupMenuItem(
                  value: 'delete',
                  child: Text('删除', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  onTap: () => _onDelete(item),
                ),
              ],
            );

            if (!_multiSelectMode) return card;

            return SelectableItemWrapper(
              borderRadius: BorderRadius.circular(12.0),
              borderPadding: const EdgeInsets.all(8.0),
              selected: viewModel.selectedItems.contains(item),
              onTap: () {
                viewModel.toggleItemSelection(item);
              },
              child: card,
            );
          },
        ),
      ),
    ];
  }
}
