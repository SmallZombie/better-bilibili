import 'package:better_bilibili/ui/core/bilibili/dynamic_card.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/enhanced_appbar.dart';
import 'package:better_bilibili/ui/search_favorites/search_favorites_view_model.dart';
import 'package:better_bilibili/utils/result.dart' as result;
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

const _orderLabels = ['收藏时间', '播放量', '发布时间'];

class SearchFavoritesScreen extends StatefulWidget {
  final String? initFavoritesId;

  const SearchFavoritesScreen({super.key, this.initFavoritesId});

  @override
  State<SearchFavoritesScreen> createState() => _SearchFavoritesScreenState();
}

class _SearchFavoritesScreenState extends State<SearchFavoritesScreen> {
  late SearchFavoritesViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = context.read();
    _viewModel.loadAddFavorites.addListener(_onResult);
  }

  @override
  void dispose() {
    _viewModel.loadAddFavorites.removeListener(_onResult);

    super.dispose();
  }

  void _onResult() {
    if (_viewModel.loadAddFavorites.error) {
      final message = (_viewModel.loadAddFavorites.result as result.Error).toString();
      context.showError('加载收藏夹失败: $message');
      _viewModel.loadAddFavorites.clearResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ListenableBuilder(
          listenable: _viewModel,
          builder:
              (context, child) => EnhancedAppBar(
                title: const Text('收藏夹搜索'),
                searchHintText: '在全部收藏夹中搜索',
                onSearch: (value) {
                  if (_viewModel.favorites.isEmpty) {
                    return;
                  }
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

                          final List<Widget> favoritesChips = [];
                          favoritesChips.add(
                            ChoiceChip(
                              label: Text('全部'),
                              selected: _viewModel.selectedFavoritesId == null,
                              onSelected: (selected) {
                                _viewModel.setSelectedFavoritesId(null);
                              },
                            ),
                          );
                          for (var i = 0; i < _viewModel.favorites.length; i++) {
                            final item = _viewModel.favorites[i];
                            favoritesChips.add(
                              ChoiceChip(
                                label: Text(item.name),
                                selected: _viewModel.selectedFavoritesId == item.id,
                                onSelected: (selected) {
                                  _viewModel.setSelectedFavoritesId(item.id);
                                },
                              ),
                            );
                          }

                          final List<Widget> orderChips = [];
                          for (var i = 0; i < _orderLabels.length; i++) {
                            orderChips.add(
                              ChoiceChip(
                                label: Text(_orderLabels[i]),
                                selected: _viewModel.selectedOrderIndex == i,
                                onSelected: (selected) {
                                  _viewModel.setSelectedOrderIndex(selected ? i : 0);
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
                                  Text('收藏夹', style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 4.0),
                                  Wrap(spacing: 8.0, runSpacing: 8.0, children: favoritesChips),

                                  const SizedBox(height: 24.0),
                                  Text('排序方式', style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 4.0),
                                  Wrap(spacing: 8.0, runSpacing: 8.0, children: orderChips),
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
                listenable: Listenable.merge([_viewModel, _viewModel.search]),
                builder: (context, child) {
                  if (_viewModel.searchResult.isEmpty && _viewModel.search.running) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_viewModel.search.error) {
                    final message = switch (_viewModel.search.result) {
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

                  return GridView.builder(
                    gridDelegate: gridDelegate,
                    itemCount: _viewModel.searchResult.length,
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, kBottomNavigationBarHeight),
                    itemBuilder: (context, index) {
                      final item = _viewModel.searchResult[index];
                      return DynamicCard(data: item);
                    },
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
