import 'package:better_bilibili/config/constants.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_response.dart';
import 'package:better_bilibili/ui/core/bilibili/favorite_folder/favorites_card.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/ui/favorites/view_models/favorites_tab_view_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:better_bilibili/utils/result.dart' as result;

class FavoritesTabView extends StatefulWidget {
  const FavoritesTabView({super.key});

  @override
  State<FavoritesTabView> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTabView> with AutomaticKeepAliveClientMixin {
  late final FavoritesTabViewModel _viewModel;

  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _viewModel = context.read();
    _viewModel.loadFavorites.execute();

    _scrollController.addListener(_onScroll);
    _viewModel.loadFavorites.addListener(_onResult);
    _viewModel.deleteFavorites.addListener(_onResult);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _viewModel.loadFavorites.removeListener(_onResult);
    _viewModel.deleteFavorites.removeListener(_onResult);

    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.maxScrollExtent - _scrollController.position.pixels <= 400 &&
        !_viewModel.loadFavorites.running &&
        _viewModel.hasMore) {
      _viewModel.loadFavorites.execute();
    }
  }

  void _onResult() {
    if (_viewModel.deleteFavorites.error) {
      final message = (_viewModel.deleteFavorites.result as result.Error).toString();
      context.showError('删除失败: $message');
      _viewModel.deleteFavorites.clearResult();
    }
  }

  Future<void> _onEditFavorites(Favorites favorites) async {}

  Future<void> _onDeleteFavorites(Favorites favorites) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除收藏夹'),
        content: Text('确定要删除 "${favorites.name}" 吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确定')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      _viewModel.deleteFavorites.execute(favorites.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final colorScheme = Theme.of(context).colorScheme;

    return Center(
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
              listenable: Listenable.merge([_viewModel, _viewModel.loadFavorites]),
              builder: (context, child) {
                if (_viewModel.favorites.isEmpty && _viewModel.loadFavorites.running) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_viewModel.loadFavorites.error) {
                  final message = switch (_viewModel.loadFavorites.result) {
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
                  controller: _scrollController,
                  gridDelegate: gridDelegate,
                  itemCount: _viewModel.favorites.length,
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, kBottomNavigationBarHeight),
                  itemBuilder: (context, index) {
                    final item = _viewModel.favorites[index];
                    return FavoritesCard(
                      favoritesId: item.id,
                      cover: item.cover ?? kEmptyImageUrl,
                      title: item.name,
                      user: item.owner,
                      total: item.total,
                      contextActions: [
                        PopupMenuItem(
                          value: 'edit',
                          child: const Text('编辑'),
                          onTap: () => _onEditFavorites(item),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          enabled: item.isDefault == false,
                          child: Text('删除', style: TextStyle(color: colorScheme.error)),
                          onTap: () => _onDeleteFavorites(item),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
