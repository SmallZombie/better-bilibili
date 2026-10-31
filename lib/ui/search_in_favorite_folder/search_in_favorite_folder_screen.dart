import 'package:better_bilibili/ui/core/bilibili/dynamic_card.dart';
import 'package:better_bilibili/ui/core/share/appbar_with_search.dart';
import 'package:better_bilibili/ui/core/share/bottom_sheet_wapper.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/paginator.dart';
import 'package:better_bilibili/ui/core/share/sliver_card_layout_builder.dart';
import 'package:better_bilibili/ui/search_in_favorite_folder/search_in_favorite_folder_view_model.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

const _orderLabels = ['收藏时间', '播放量', '发布时间'];

class SearchInFavoriteFolderScreen extends StatefulWidget {
  final SearchInFavoriteFolderViewModel viewModel;
  final String? initialFavoriteFolderId;

  const SearchInFavoriteFolderScreen({
    super.key,
    required this.viewModel,
    this.initialFavoriteFolderId,
  });

  @override
  State<SearchInFavoriteFolderScreen> createState() => _SearchInFavoriteFolderScreenState();
}

class _SearchInFavoriteFolderScreenState extends State<SearchInFavoriteFolderScreen> {
  SearchInFavoriteFolderViewModel get viewModel => widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithSearch(
        searchHintText: '在全部收藏夹中搜索',
        searchMode: true,
        autoFocus: true,
        onToggleSearchMode: () => context.pop(),
        onSearch: (value) {
          viewModel.setKeyword(value);
        },
        onToggleFilter: () {
          viewModel.rememberFiltersState();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => BottomSheetWapper(
              child: Padding(
                padding: const .all(16.0),
                child: ListenableBuilder(
                  listenable: viewModel,
                  builder: (context, _) {
                    final List<Widget> orderChips = [];
                    for (var i = 0; i < _orderLabels.length; i++) {
                      orderChips.add(
                        ChoiceChip(
                          label: Text(_orderLabels[i]),
                          selected: viewModel.selectedOrderIndex == i,
                          onSelected: (selected) {
                            viewModel.setSelectedOrderIndex(selected ? i : 0);
                          },
                        ),
                      );
                    }

                    return Column(
                      mainAxisSize: .min,
                      crossAxisAlignment: .start,
                      children: [
                        Text('排序方式', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4.0),
                        Wrap(spacing: 8.0, runSpacing: 8.0, children: orderChips),
                      ],
                    );
                  },
                ),
              ),
            ),
          ).whenComplete(() {
            if (mounted) {
              viewModel.onFilterSheetDismissed();
            }
          });
        },
      ),
      body: ListenableBuilder(
        listenable: viewModel.search,
        builder: (context, child) {
          if (viewModel.search.error) {
            return CenterErrorMessage(
              errorMessage: getErrorMessage(viewModel.search.result!),
              onRetry: viewModel.reset,
            );
          }
          if (viewModel.searchResult.isEmpty) {
            if (viewModel.search.running) {
              return const Center(child: CircularProgressIndicator());
            }
            return const Center(child: Text('暂无内容'));
          }

          return CustomScrollView(
            slivers: [
              SliverCardLayoutBuilder(
                builder: (context, constraints, gridDelegate) => SliverGrid.builder(
                  gridDelegate: gridDelegate,
                  itemCount: viewModel.searchResult.length,
                  itemBuilder: (context, index) {
                    final item = viewModel.searchResult[index];
                    return DynamicCard(data: item);
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Paginator(
                  maxPageCount: (viewModel.total + (viewModel.ps - 1)) ~/ viewModel.ps,
                  currentPage: viewModel.pn,
                  onPageChanged: viewModel.setPn,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: kBottomNavigationBarHeight)),
            ],
          );
        },
      ),
    );
  }
}
