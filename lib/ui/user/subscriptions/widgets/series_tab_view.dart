import 'package:better_bilibili/data/model/bilibili/movie_model.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_subscribed_series_response.dart';
import 'package:better_bilibili/ui/core/bilibili/series/series_poster.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/paginator.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/ui/core/share/sliver_card_layout_builder.dart';
import 'package:better_bilibili/ui/user/subscriptions/view_models/series_tab_view_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:better_bilibili/utils/result.dart' as result;
import 'package:provider/provider.dart';

const List<String> _watchStatusLabels = ['全部', '想看', '在看', '已看'];

class SeriesTabView extends StatefulWidget {
  final SeriesTabViewModel viewModel;

  const SeriesTabView({super.key, required this.viewModel});

  @override
  State<SeriesTabView> createState() => _SeriesTabState();
}

class _SeriesTabState extends State<SeriesTabView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    widget.viewModel.modifySeriesWatchStatus.addListener(_onResult);
    widget.viewModel.unsubscribe.addListener(_onResult);
  }

  @override
  void dispose() {
    widget.viewModel.modifySeriesWatchStatus.removeListener(_onResult);
    widget.viewModel.unsubscribe.removeListener(_onResult);

    super.dispose();
  }

  void _onResult() {
    if (widget.viewModel.modifySeriesWatchStatus.error) {
      final message = (widget.viewModel.modifySeriesWatchStatus.result as result.Err).toString();
      context.showError('修改观看状态失败: $message');
      widget.viewModel.modifySeriesWatchStatus.clearResult();
    }

    if (widget.viewModel.unsubscribe.error) {
      final message = (widget.viewModel.unsubscribe.result as result.Err).toString();
      context.showError('取消订阅失败: $message');
      widget.viewModel.unsubscribe.clearResult();
    }
  }

  Future<void> _onMarkAsUnwatched(SubscribedSeries item) async {
    widget.viewModel.modifySeriesWatchStatus.execute(
      ModifySeriesWatchStatusRequest(seriesId: item.id, watchStatus: MovieWatchStatus.unwatched),
    );
  }

  Future<void> _onMarkAsWatching(SubscribedSeries item) async {
    widget.viewModel.modifySeriesWatchStatus.execute(
      ModifySeriesWatchStatusRequest(seriesId: item.id, watchStatus: MovieWatchStatus.watching),
    );
  }

  Future<void> _onMarkAsWatched(SubscribedSeries item) async {
    widget.viewModel.modifySeriesWatchStatus.execute(
      ModifySeriesWatchStatusRequest(seriesId: item.id, watchStatus: MovieWatchStatus.watched),
    );
  }

  Future<void> _onUnsubscribe(SubscribedSeries item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('取消订阅'),
        content: Text('确定要取消订阅 "${item.title}" 吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确定')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      widget.viewModel.unsubscribe.execute(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
          sliver: SliverToBoxAdapter(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                for (int i = 0; i < _watchStatusLabels.length; i++)
                  Selector<SeriesTabViewModel, int>(
                    selector: (context, vm) => vm.selectedWatchStatusIndex,
                    builder: (context, selectedWatchStatusIndex, _) => ChoiceChip(
                      label: Text(_watchStatusLabels[i]),
                      onSelected: (_) => widget.viewModel.setSelectedWatchStatusIndex(i),
                      selected: selectedWatchStatusIndex == i,
                      showCheckmark: false,
                    ),
                  ),
              ],
            ),
          ),
        ),
        SliverCardLayoutBuilder(
          minColumns: 1,
          maxColumns: 6,
          minItemWidth: 240,
          imageAspectRatio: 1 / 1.4,
          extraHeight: 90,
          horizontalPadding: 16,
          builder: (context, constraints, gridDelegate) => ListenableBuilder(
            listenable: widget.viewModel.loadData,
            builder: (context, child) {
              if (widget.viewModel.loadData.running && widget.viewModel.series.isEmpty) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }

              if (widget.viewModel.loadData.error) {
                return SliverFillRemaining(
                  child: CenterErrorMessage(
                    errorMessage: widget.viewModel.loadData.result.toString(),
                    onRetry: widget.viewModel.reload,
                  ),
                );
              }

              if (widget.viewModel.series.isEmpty) {
                return const SliverFillRemaining(child: Center(child: Text('暂无内容')));
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: Selector<SeriesTabViewModel, List<SubscribedSeries>>(
                  selector: (context, vm) => vm.series,
                  builder: (context, series, _) => SliverGrid.builder(
                    gridDelegate: gridDelegate,
                    itemCount: series.length,
                    itemBuilder: (context, index) {
                      final item = series[index];
                      return SeriesPoster(
                        seriesId: item.id,
                        cover: item.cover,
                        title: item.title,
                        category: item.category,
                        countries: item.countries.firstOrNull,
                        year: item.year,
                        watchProgressStr: item.watchProgressStr,
                        badge: item.badge,
                        contextActions: widget.viewModel.isCurrentUser
                            ? [
                                PopupMenuItem(
                                  value: 'mark_as_unwatched',
                                  enabled: item.watchStatus != MovieWatchStatus.unwatched,
                                  child: const Text('标记为想看'),
                                  onTap: () => _onMarkAsUnwatched(item),
                                ),
                                PopupMenuItem(
                                  value: 'mark_as_watching',
                                  enabled: item.watchStatus != MovieWatchStatus.watching,
                                  child: const Text('标记为在看'),
                                  onTap: () => _onMarkAsWatching(item),
                                ),
                                PopupMenuItem(
                                  value: 'mark_as_watched',
                                  enabled: item.watchStatus != MovieWatchStatus.watched,
                                  child: const Text('标记为已看'),
                                  onTap: () => _onMarkAsWatched(item),
                                ),
                                PopupMenuItem(
                                  value: 'unsubscribe',
                                  child: Text('取消订阅', style: TextStyle(color: colorScheme.error)),
                                  onTap: () => _onUnsubscribe(item),
                                ),
                              ]
                            : [],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        SliverPadding(
          padding: const .all(16.0),
          sliver: SliverToBoxAdapter(
            child: Selector<SeriesTabViewModel, ({int total, int pn})>(
              selector: (context, vm) => (total: vm.total, pn: vm.pn),
              builder: (context, state, _) => Paginator(
                maxPageCount: (state.total + (ps - 1)) ~/ ps,
                currentPage: state.pn,
                onPageChanged: (page) => widget.viewModel.setPn(page),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
