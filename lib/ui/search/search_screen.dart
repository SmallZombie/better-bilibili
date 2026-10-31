import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_user_avatar.dart';
import 'package:better_bilibili/ui/core/bilibili/dynamic_card.dart';
import 'package:better_bilibili/ui/core/bilibili/dynamic_poster.dart';
import 'package:better_bilibili/ui/core/bilibili/event/event_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/game/game_tile.dart';
import 'package:better_bilibili/ui/core/share/appbar_with_search.dart';
import 'package:better_bilibili/ui/core/share/bottom_sheet_wapper.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/custom_icons.dart';
import 'package:better_bilibili/ui/core/share/card_layout_builder.dart';
import 'package:better_bilibili/ui/core/share/open_url.dart';
import 'package:better_bilibili/ui/core/share/paginator.dart';
import 'package:better_bilibili/ui/core/share/simple_dialog.dart';
import 'package:better_bilibili/ui/search/search_view_model.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:better_bilibili/utils/result.dart' as result;
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  final SearchViewModel viewModel;
  final String? initialKeyword;

  const SearchScreen({
    super.key,
    required this.viewModel,
    this.initialKeyword,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  SearchViewModel get viewModel => widget.viewModel;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scheduleInitialSearch(widget.initialKeyword);
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  void _scheduleInitialSearch(String? keyword) {
    if (keyword == null || keyword.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _searchController.text = keyword;
      viewModel.setKeyword(keyword);
      viewModel.reSearch();
    });
  }

  void _onSuggestTap(String keyword) {
    if (viewModel.deleteSearchHistoryMode) {
      viewModel.deleteSearchHistory(keyword);
    } else {
      _searchController.text = keyword;
      viewModel.setKeyword(keyword);
      viewModel.reSearch();
    }
  }

  Future<void> _pickCustomReleaseTimeRange() async {
    final now = DateUtils.dateOnly(DateTime.now());
    final start = widget.viewModel.customReleaseTimeStart;
    final end = widget.viewModel.customReleaseTimeEnd ?? start;

    final range = await showDateRangePicker(
      context: context,
      // 2009年6月26日，B站的前身 Mikufans 成立
      // 2010年1月24日，Mikufans 更名为 Bilibili
      firstDate: DateTime(2009, 6, 26),
      lastDate: now,
      initialDateRange: start != null
          ? DateTimeRange(
              start: DateUtils.dateOnly(
                DateTime.fromMillisecondsSinceEpoch(start * 1000),
              ),
              end: DateUtils.dateOnly(
                DateTime.fromMillisecondsSinceEpoch(end! * 1000),
              ),
            )
          : null,
    );
    if (range == null || !mounted) return;
    final customEndSec = range.end.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)).millisecondsSinceEpoch ~/ 1000;
    widget.viewModel.setCustomReleaseTimeRange(range.start.millisecondsSinceEpoch ~/ 1000, customEndSec);
  }

  Future<void> _onTapClearSearchHistory() async {
    final choice = await context.showConfirm(
      title: '清空搜索历史',
      content: '此操作不可逆，确定要清空搜索历史吗？',
      confirmColor: Theme.of(context).colorScheme.error,
    );
    if (choice) {
      viewModel.clearSearchHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithSearch(
        searchMode: true,
        searchHintText: '搜索视频、用户、直播等',
        autoFocus: true,
        searchController: _searchController,
        onSearch: (value) {
          viewModel.setKeyword(value);
          viewModel.reSearch();
        },
        onSearchChanged: (value) {
          viewModel.setKeyword(value);
          if (value.isNotEmpty) {
            viewModel.getSuggestions();
          }
        },
        onToggleSearchMode: () => context.pop(),
        onToggleFilter: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => ChangeNotifierProvider.value(
              value: viewModel,
              child: Selector<SearchViewModel, Map<Filter, int>>(
                selector: (context, vm) => vm.selectedIndexs,
                builder: (context, selectedIndexs, _) => _FilterSheet<SearchTypeEnum>(
                  typeFilter: typeFilter,
                  filters: {
                    .all: [],
                    .video: [videoOrderFilter, releaseTimeFilter, durationFilter],
                    .series: [],
                    .movie: [],
                    .live: [liveRoomOrderFilter],
                    .article: [articleOrderFilter],
                    .user: [userOrderFilter, userTypeFilter],
                  },
                  selectedIndexs: selectedIndexs,
                  onTap: viewModel.setFilterIndex,
                  onSelectTimeRange: _pickCustomReleaseTimeRange,
                ),
              ),
            ),
          );

          if (mounted) {
            viewModel.onFilterSheetDismissed();
          }
        },
        actions: [
          Selector<SearchViewModel, bool>(
            selector: (context, vm) => vm.incognitoMode,
            builder: (context, incognitoMode, _) => IconButton(
              onPressed: () => viewModel.setIncognitoMode(!viewModel.incognitoMode),
              icon: incognitoMode ? const Icon(CustomIcons.incognito) : const Icon(CustomIcons.incognito_off),
              tooltip: incognitoMode ? '正在以无痕模式搜索' : '进入无痕模式',
            ),
          ),
        ],
      ),
      body: Selector<SearchViewModel, ({String keyword, String? latestKeyword})>(
        selector: (context, vm) => (
          keyword: vm.keyword,
          latestKeyword: vm.latestKeyword,
        ),
        builder: (context, state, _) {
          if (state.keyword == state.latestKeyword) {
            return ListenableBuilder(
              listenable: viewModel.search,
              builder: (context, child) {
                if (widget.viewModel.search.running) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (widget.viewModel.search.error) {
                  final message = switch (widget.viewModel.search.result) {
                    result.Err(:final error) => error.toString(),
                    _ => '加载失败',
                  };
                  return CenterErrorMessage(
                    errorMessage: message,
                    onRetry: () => widget.viewModel.reSearch(),
                  );
                }
                return _buildSearchResult();
              },
            );
          } else if (state.keyword.isNotEmpty) {
            return _buildSearchSuggest();
          } else {
            return _buildWithNoSearch();
          }
        },
      ),
    );
  }

  Widget _buildSearchSuggest() {
    final colorScheme = Theme.of(context).colorScheme;

    return Selector<SearchViewModel, List<String>>(
      selector: (context, vm) => vm.suggestionList,
      builder: (context, suggestionList, _) {
        return ListView.builder(
          itemCount: suggestionList.length,
          itemBuilder: (context, index) {
            final keyword = suggestionList[index];
            return ListTile(
              onTap: () => _onSuggestTap(keyword),
              leading: Icon(
                Icons.search,
                size: 22.0,
                color: colorScheme.outline,
              ),
              title: Text(keyword),
            );
          },
        );
      },
    );
  }

  Widget _buildWithNoSearch() {
    return Row(
      crossAxisAlignment: .start,
      spacing: 8.0,
      children: [
        Expanded(
          child:
              Selector<
                SearchViewModel,
                ({
                  List<String> keywords,
                  bool deleteMode,
                  bool searchHistoryExpanded,
                })
              >(
                selector: (context, vm) => (
                  keywords: vm.searchHistory,
                  deleteMode: vm.deleteSearchHistoryMode,
                  searchHistoryExpanded: vm.isSearchHistoryExpanded,
                ),
                builder: (context, state, _) {
                  final keywords = switch (state.searchHistoryExpanded) {
                    true => state.keywords,
                    _ => state.keywords.sublist(0, min(state.keywords.length, 20)),
                  };

                  return Column(
                    crossAxisAlignment: .start,
                    children: [
                      Padding(
                        padding: const .symmetric(horizontal: 12.0, vertical: 4.0),
                        child: Row(
                          children: [
                            Text('搜索历史', style: Theme.of(context).textTheme.titleMedium),
                            const Spacer(),
                            IconButton(
                              onPressed: _onTapClearSearchHistory,
                              icon: const Icon(Icons.clear_all),
                              tooltip: '清空搜索历史',
                            ),
                            IconButton(
                              onPressed: () {
                                viewModel.setDeleteSearchHistoryMode(!state.deleteMode);
                              },
                              icon: state.deleteMode ? const Icon(Icons.delete) : const Icon(Icons.delete_outline),
                              tooltip: state.deleteMode ? '点按退出删除模式' : '点按进入删除模式',
                              isSelected: state.deleteMode,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const .symmetric(horizontal: 12.0),
                          child: ListView(
                            // 这里的 wrap 存在严重的性能问题，而且不是简单的使用类似 LazyWrap 就可以解决的
                            // 实测只要到达大约100条历史时就会有明显的卡顿，此时元素只占据了屏幕的一半，所以根本不是懒加载的问题，
                            // 由于解决起来较为麻烦，但我又想要保留所有历史记录，这里就用一种比较折中的方案
                            // 绝大部分人不会天天想要回看搜索历史，所以这里改为默认只展示前20条，超出的部分默认折叠
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: keywords.map(
                                  (v) {
                                    return ActionChip(
                                      onPressed: () => _onSuggestTap(v),
                                      label: Text(v),
                                    );
                                  },
                                ).toList(),
                              ),
                              if (state.keywords.length > 20)
                                Padding(
                                  padding: const .symmetric(vertical: 8.0),
                                  child: InkWell(
                                    onTap: () => viewModel.setSearchHistoryExpanded(!state.searchHistoryExpanded),
                                    child: Padding(
                                      padding: const .all(6.0),
                                      child: Row(
                                        mainAxisAlignment: .center,
                                        children: [
                                          Text(state.searchHistoryExpanded ? '折叠' : '展开'),
                                          state.searchHistoryExpanded
                                              ? const Icon(
                                                  Icons.arrow_drop_up,
                                                  size: 20,
                                                )
                                              : const Icon(
                                                  Icons.arrow_drop_down,
                                                  size: 20,
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
        ),
        Expanded(
          child: ListenableBuilder(
            listenable: widget.viewModel.getTrendingList,
            builder: (context, child) => ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Text('热搜', style: Theme.of(context).textTheme.titleMedium),
                ),
                for (int i = 0; i < widget.viewModel.trendingList.length; i++)
                  ListTile(
                    onTap: () => _onSuggestTap(widget.viewModel.trendingList[i].name),
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    leading: widget.viewModel.trendingList[i].isPinned
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: const Text(
                              'PIN',
                              style: TextStyle(color: Colors.white, fontWeight: .bold),
                            ),
                          )
                        : CircleAvatar(
                            radius: 16.0,
                            child: Text('${i + 1}', style: const TextStyle(fontSize: 12)),
                          ),
                    title: Text(widget.viewModel.trendingList[i].name),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResult() {
    return CardLayoutBuilder(
      builder: (context, constraints, gridDelegate, padding) {
        return CustomScrollView(
          slivers: [
            if (viewModel.pn == 1) ...[
              // banner
              if (viewModel.resultBanners.isNotEmpty)
                SliverPadding(
                  padding: padding,
                  sliver: SliverList.separated(
                    itemCount: viewModel.resultBanners.length,
                    itemBuilder: (context, index) {
                      final banner = viewModel.resultBanners[index];
                      return GestureDetector(
                        onTap: () => context.openUrl(banner.url),
                        child: Stack(
                          children: [
                            BiliImageWapper(
                              url: banner.cover,
                              height: 200,
                              width: double.infinity,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            Positioned(
                              bottom: 16.0,
                              left: 16.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    banner.name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26.0,
                                      fontWeight: .bold,
                                      shadows: [Shadow(color: Colors.black.withAlpha(100), blurRadius: 20.0)],
                                    ),
                                  ),
                                  Text(
                                    banner.description,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      shadows: [Shadow(color: Colors.black.withAlpha(100), blurRadius: 20.0)],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 12.0,
                              right: 12.0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(50),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: const Text(
                                  'AD',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(height: 8.0),
                  ),
                ),
              // events and games
              if (viewModel.resultEvents.isNotEmpty || viewModel.resultGames.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverToBoxAdapter(
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        for (final event in viewModel.resultEvents)
                          EventTile(
                            eventId: event.id,
                            name: event.name,
                            description: event.description,
                            cover: event.cover,
                            url: event.url,
                          ),
                        for (final game in viewModel.resultGames)
                          GameTile(
                            gameId: game.id,
                            name: game.name,
                            description: game.description,
                            cover: game.icon,
                          ),
                      ],
                    ),
                  ),
                ),
              // series and movies
              if (viewModel.resultSeries.isNotEmpty || viewModel.resultMovies.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: 350,
                      child: ListView.builder(
                        itemCount: viewModel.resultSeries.length + viewModel.resultMovies.length,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemBuilder: (context, index) {
                          final item = index < viewModel.resultSeries.length
                              ? viewModel.resultSeries[index]
                              : viewModel.resultMovies[index - viewModel.resultSeries.length];
                          return SizedBox(width: 200, child: DynamicPoster(data: item));
                        },
                      ),
                    ),
                  ),
                ),
              // users
              if (viewModel.resultUsers.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final item in viewModel.resultUsers) ...[
                          ListTile(
                            onTap: () => context.push(Routes.buildUserDetail(item.id)),
                            leading: BiliUserAvatar(
                              url: item.avatar,
                              isVerified: item.isVerified,
                              isEnterpriseVerified: item.isEnterpriseVerified,
                              size: 48,
                            ),
                            title: Text(item.nickname),
                            subtitle: Text(
                              '${formatCountToHumanReadable(item.fansCount)}粉丝 · ${formatCountToHumanReadable(item.videoCount)}条视频',
                            ),
                          ),
                          SizedBox(
                            height: 240,
                            child: ScrollConfiguration(
                              behavior: ScrollBehavior().copyWith(
                                dragDevices: {
                                  PointerDeviceKind.touch,
                                  PointerDeviceKind.mouse,
                                },
                                scrollbars: false,
                              ),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: item.videos.length,
                                itemBuilder: (context, index) {
                                  final card = item.videos[index];
                                  return SizedBox(width: 270, child: DynamicCard(data: card));
                                },
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ], // videos and lives
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverToBoxAdapter(
                child: Text(
                  '共 ${viewModel.total == 1000 ? '1000+' : viewModel.total} 条相关结果',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverGrid.builder(
                itemCount: viewModel.resultList!.length,
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) => DynamicCard(data: widget.viewModel.resultList![index]),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12.0)),
            SliverToBoxAdapter(
              child: Paginator(
                maxPageCount: (widget.viewModel.total + 19) ~/ 20,
                currentPage: widget.viewModel.pn,
                onPageChanged: (page) => widget.viewModel.setPn(page),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: kBottomNavigationBarHeight)),
          ],
        );
      },
    );
  }
}

class _FilterSheet<T> extends StatelessWidget {
  final Filter<T> typeFilter;
  final Map<T, List<Filter>> filters;
  final Map<Filter, int> selectedIndexs;
  final Function(Filter filter, int index) onTap;
  final VoidCallback onSelectTimeRange;

  const _FilterSheet({
    required this.typeFilter,
    required this.filters,
    required this.selectedIndexs,
    required this.onTap,
    required this.onSelectTimeRange,
  });

  @override
  Widget build(BuildContext context) {
    final subFilters = filters[typeFilter.values[selectedIndexs[typeFilter] ?? 0].value] ?? [];

    return BottomSheetWapper(
      child: ListView(
        children: [
          _buildSection(typeFilter.name, _buildChips(typeFilter)),
          ...subFilters.map((v) => _buildSection(v.name, _buildChips(v))),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Padding(
      padding: const .fromLTRB(24.0, 0, 24.0, 16.0),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(title, style: TextStyle(fontSize: 18.0)),
          const SizedBox(height: 4.0),
          child,
        ],
      ),
    );
  }

  Widget _buildChips(Filter filter) {
    final selectedIndex = selectedIndexs[filter] ?? 0;

    final List<Widget> chips = [
      for (var i = 0; i < filter.values.length; i++)
        ChoiceChip(
          label: Text(filter.values[i].name),
          selected: selectedIndex == i,
          onSelected: (_) => onTap(filter, i),
        ),
    ];

    if (filter == releaseTimeFilter && selectedIndex == 5) {
      chips.add(
        TextButton.icon(
          onPressed: onSelectTimeRange,
          icon: const Icon(Icons.calendar_today, size: 18),
          label: const Text('选择日期'),
        ),
      );
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: chips,
    );
  }
}
