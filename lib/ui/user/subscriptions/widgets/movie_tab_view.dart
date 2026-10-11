import 'package:better_bilibili/data/model/bilibili/movie_model.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_subscribed_movie_response.dart';
import 'package:better_bilibili/ui/core/bilibili/movie/movie_poster.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/paginator.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/ui/core/share/sliver_grid_layout_builder.dart';
import 'package:better_bilibili/ui/user/subscriptions/view_models/movie_tab_view_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:better_bilibili/utils/result.dart' as result;
import 'package:provider/provider.dart';

const List<String> _watchStatusLabels = ['全部', '想看', '在看', '已看'];

class MovieTabView extends StatefulWidget {
  final MovieTabViewModel viewModel;

  const MovieTabView({super.key, required this.viewModel});

  @override
  State<MovieTabView> createState() => _MovieTabViewState();
}

class _MovieTabViewState extends State<MovieTabView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    widget.viewModel.modifyMovieWatchStatus.addListener(_onResult);
    widget.viewModel.unsubscribe.addListener(_onResult);
  }

  @override
  void dispose() {
    widget.viewModel.modifyMovieWatchStatus.removeListener(_onResult);
    widget.viewModel.unsubscribe.removeListener(_onResult);

    super.dispose();
  }

  void _onResult() {
    if (widget.viewModel.modifyMovieWatchStatus.error) {
      final message = (widget.viewModel.modifyMovieWatchStatus.result as result.Error).toString();
      context.showError('修改观看状态失败: $message');
      widget.viewModel.modifyMovieWatchStatus.clearResult();
    }

    if (widget.viewModel.unsubscribe.error) {
      final message = (widget.viewModel.unsubscribe.result as result.Error).toString();
      context.showError('取消订阅失败: $message');
      widget.viewModel.unsubscribe.clearResult();
    }
  }

  Future<void> _onMarkAsUnwatched(SubscribedMovie item) async {
    widget.viewModel.modifyMovieWatchStatus.execute(
      ModifyMovieWatchStatusRequest(movieId: item.id, watchStatus: MovieWatchStatus.unwatched),
    );
  }

  Future<void> _onMarkAsWatching(SubscribedMovie item) async {
    widget.viewModel.modifyMovieWatchStatus.execute(
      ModifyMovieWatchStatusRequest(movieId: item.id, watchStatus: MovieWatchStatus.watching),
    );
  }

  Future<void> _onMarkAsWatched(SubscribedMovie item) async {
    widget.viewModel.modifyMovieWatchStatus.execute(
      ModifyMovieWatchStatusRequest(movieId: item.id, watchStatus: MovieWatchStatus.watched),
    );
  }

  Future<void> _onUnsubscribe(SubscribedMovie item) async {
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
                  Selector<MovieTabViewModel, int>(
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
        SliverGridLayoutBuilder(
          minColumns: 1,
          maxColumns: 6,
          minItemWidth: 240,
          imageAspectRatio: 1 / 1.4,
          extraHeight: 90,
          horizontalPadding: 16,
          builder: (context, constraints, gridDelegate) => ListenableBuilder(
            listenable: widget.viewModel.loadData,
            builder: (context, child) {
              if (widget.viewModel.loadData.running && widget.viewModel.movies.isEmpty) {
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

              if (widget.viewModel.movies.isEmpty) {
                return const SliverFillRemaining(child: Center(child: Text('暂无内容')));
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: Selector<MovieTabViewModel, List<SubscribedMovie>>(
                  selector: (context, vm) => vm.movies,
                  builder: (context, movies, _) => SliverGrid.builder(
                    gridDelegate: gridDelegate,
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final item = movies[index];
                      return MoviePoster(
                        movieId: item.id,
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
            child: Selector<MovieTabViewModel, ({int total, int pn})>(
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
