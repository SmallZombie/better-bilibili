import 'package:better_bilibili/ui/core/bilibili/dynamic_card.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/enhanced_appbar.dart';
import 'package:better_bilibili/ui/core/share/selectable_item_wrapper.dart';
import 'package:better_bilibili/ui/core/theme/theme.dart';
import 'package:better_bilibili/ui/watch_history/watch_history_view_model.dart';
import 'package:better_bilibili/utils/result.dart' as result;
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const _typeLabels = ['全部', '视频', '文章', '直播'];
const _durationLabels = ['全部', '小于10分钟', '10~30分钟', '30~60分钟', '一小时以上'];
const _recordTimeLabels = ['全部', '昨天', '一周内', '一个月内', '自定义'];
const _deviceLabels = ['全部', 'PC', '手机', '平板', 'TV'];

class WatchHistoryScreen extends StatefulWidget {
  const WatchHistoryScreen({super.key});

  @override
  State<WatchHistoryScreen> createState() => _WatchHistoryScreenState();
}

class _WatchHistoryScreenState extends State<WatchHistoryScreen> {
  late WatchHistoryViewModel _viewModel;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _multiSelectMode = false;

  @override
  void initState() {
    super.initState();

    _viewModel = context.read();
    _scrollController.addListener(_onScroll);
    _viewModel.loadHistoryConfig.addListener(_onResult);
    _viewModel.setHistoryConfig.addListener(_onResult);
    _viewModel.clearAllWatchHistory.addListener(_onResult);
    _viewModel.deleteSelectedItems.addListener(_onResult);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();

    _scrollController.removeListener(_onScroll);
    _viewModel.loadHistoryConfig.removeListener(_onResult);
    _viewModel.setHistoryConfig.removeListener(_onResult);
    _viewModel.clearAllWatchHistory.removeListener(_onResult);
    _viewModel.deleteSelectedItems.removeListener(_onResult);

    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.maxScrollExtent - _scrollController.position.pixels <= 400 &&
        !_viewModel.loadWatchHistory.running &&
        _viewModel.hasMore) {
      _viewModel.loadWatchHistory.execute();
    }
  }

  void _onResult() {
    if (_viewModel.loadHistoryConfig.error) {
      final message = (_viewModel.loadHistoryConfig.result as result.Error).toString();
      context.showError('获取历史记录配置失败: $message');
      _viewModel.loadHistoryConfig.clearResult();
    }

    if (_viewModel.setHistoryConfig.completed) {
      context.showInfo('已${_viewModel.isHistoryEnabled! ? '启用' : '禁用'}历史记录');
      _viewModel.setHistoryConfig.clearResult();
    }
    if (_viewModel.setHistoryConfig.error) {
      final message = (_viewModel.setHistoryConfig.result as result.Error).toString();
      context.showError('修改失败: $message');
      _viewModel.setHistoryConfig.clearResult();
    }

    if (_viewModel.clearAllWatchHistory.error) {
      final message = (_viewModel.clearAllWatchHistory.result as result.Error).toString();
      context.showError('清空失败: $message');
      _viewModel.clearAllWatchHistory.clearResult();
    }

    if (_viewModel.deleteSelectedItems.completed) {
      if (_multiSelectMode) {
        _onToggleMultiSelectMode();
      }
    }
    if (_viewModel.deleteSelectedItems.error) {
      final message = (_viewModel.deleteSelectedItems.result as result.Error).toString();
      context.showError('删除失败: $message');
      _viewModel.deleteSelectedItems.clearResult();
    }
  }

  Future<void> _onToggleConfig() async {
    _viewModel.setHistoryConfig.execute(!_viewModel.isHistoryEnabled!);
  }

  Future<void> _onClearHistory() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空观看历史'),
        content: const Text('确定清空全部观看历史吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确定')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      _viewModel.clearAllWatchHistory.execute();
    }
  }

  Future<void> _onToggleMultiSelectMode() async {
    _viewModel.clearSelectedItems();
    setState(() {
      _multiSelectMode = !_multiSelectMode;
    });
  }

  Future<void> _onDelete(dynamic item) async {
    _viewModel.clearSelectedItems();
    _viewModel.toggleItemSelection(item);
    _onDeleteSelectedItems();
  }

  Future<void> _onDeleteSelectedItems() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除选中项'),
        content: Text('确定删除选中的 ${_viewModel.selectedItems.length} 项吗？'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) => EnhancedAppBar(
            title: const Text('观看历史'),
            searchHintText: '在观看历史中搜索',
            onSearch: (value) {
              _viewModel.setKeyword(value ?? '');
            },
            onToggleFilter: () {
              _viewModel.rememberFiltersState();
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (sheetContext) {
                  return ListenableBuilder(
                    listenable: _viewModel,
                    builder: (context, _) {
                      final double screenHeight = MediaQuery.of(context).size.height;
                      final double maxHeight = screenHeight / 2 < 500 ? screenHeight / 2 : 500;

                      final List<Widget> typeChips = [];
                      for (var i = 0; i < _typeLabels.length; i++) {
                        final label = _typeLabels[i];
                        typeChips.add(
                          ChoiceChip(
                            label: Text(label),
                            selected: _viewModel.selectedTypeIndex == i,
                            onSelected: (selected) {
                              _viewModel.setSelectedTypeIndex(selected ? i : 0);
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
                            selected: _viewModel.selectedDurationIndex == i,
                            onSelected: (selected) {
                              _viewModel.setSelectedDurationIndex(selected ? i : 0);
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
                            selected: _viewModel.selectedRecordTimeIndex == i,
                            onSelected: (selected) {
                              _viewModel.setSelectedRecordTimeIndex(selected ? i : 0);
                            },
                          ),
                        );
                      }
                      if (_viewModel.selectedRecordTimeIndex == 4) {
                        recordTimeChips.add(
                          TextButton.icon(
                            onPressed: () async {
                              final now = DateTime.now();
                              final range = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(now.year - 1),
                                lastDate: now,
                                initialDateRange: _viewModel.customRecordTimeStartSec != null
                                    ? DateTimeRange(
                                        start: DateTime.fromMillisecondsSinceEpoch(
                                          _viewModel.customRecordTimeStartSec! * 1000,
                                        ),
                                        end: DateTime.fromMillisecondsSinceEpoch(
                                          (_viewModel.customRecordTimeEndSec ?? _viewModel.customRecordTimeStartSec)! * 1000,
                                        ),
                                      )
                                    : null,
                              );
                              if (range == null || !mounted) return;
                              _viewModel.setCustomRecordTimeRange(
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
                            selected: _viewModel.selectedDeviceIndex == i,
                            onSelected: (selected) {
                              _viewModel.setSelectedDeviceIndex(selected ? i : 0);
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
                  _viewModel.onFilterSheetDismissed();
                }
              });
            },
            onToggleMultiSelectMode: _onToggleMultiSelectMode,
            multiSelectMode: _multiSelectMode,
            multiSelectCount: _viewModel.selectedItems.length,
            onSelectAll: _viewModel.selectAll,
            onDeselectAll: _viewModel.deselectAll,
            onInvertSelection: _viewModel.invertSelection,
            multiSelectActions: [
              IconButton(
                onPressed: _onDeleteSelectedItems,
                icon: const Icon(Icons.delete_outline),
                tooltip: '删除',
              ),
            ],
            actions: [
              ListenableBuilder(
                listenable: Listenable.merge([_viewModel.loadHistoryConfig, _viewModel.setHistoryConfig]),
                builder: (context, child) => PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  tooltip: '更多',
                  onSelected: _viewModel.isHistoryEnabled != null
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
                      enabled: _viewModel.isHistoryEnabled != null,
                      child: Text(
                        _viewModel.isHistoryEnabled == null ? '...' : (_viewModel.isHistoryEnabled! ? '关闭历史记录' : '开启历史记录'),
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
                listenable: Listenable.merge([_viewModel, _viewModel.loadWatchHistory]),
                builder: (context, child) {
                  if (_viewModel.watchHistory.isEmpty && _viewModel.loadWatchHistory.running) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_viewModel.loadWatchHistory.error) {
                    final message = switch (_viewModel.loadWatchHistory.result) {
                      result.Error(:final error) => error.toString(),
                      _ => '加载失败',
                    };
                    return CenterErrorMessage(
                      errorMessage: message,
                      onRetry: () => _viewModel.reload(),
                    );
                  }

                  if (_viewModel.showEmpty) {
                    return const Center(child: Text('暂无记录'));
                  }

                  return CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      if (_viewModel.todayList.isNotEmpty) ..._buildDateList(context, '今天', _viewModel.todayList, gridDelegate),
                      if (_viewModel.yesterdayList.isNotEmpty) ..._buildDateList(context, '昨天', _viewModel.yesterdayList, gridDelegate),
                      if (_viewModel.beforeYesterdayList.isNotEmpty)
                        ..._buildDateList(context, '前天', _viewModel.beforeYesterdayList, gridDelegate),
                      if (_viewModel.otherList.isNotEmpty) ..._buildDateList(context, '更早', _viewModel.otherList, gridDelegate),
                      SliverToBoxAdapter(child: SizedBox(height: kScreenBottomPadding)),
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

  List<Widget> _buildDateList(BuildContext context, String title, List<dynamic> list, SliverGridDelegate gridDelegate) {
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        sliver: SliverToBoxAdapter(
          child: Text(title, style: TextStyle(fontSize: 24.0)),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 4.0)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
              selected: _viewModel.selectedItems.contains(item),
              onTap: () {
                _viewModel.toggleItemSelection(item);
              },
              child: card,
            );
          },
        ),
      ),
    ];
  }
}
