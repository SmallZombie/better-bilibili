import 'package:better_bilibili/config/constants.dart';
import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/bilibili/article/article_card.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/grid_layout_builder.dart';
import 'package:better_bilibili/ui/core/share/paginator.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/ui/favorites/view_models/favorite_article_view_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:better_bilibili/utils/result.dart' as result;

class FavoriteArticleView extends StatefulWidget {
  const FavoriteArticleView({super.key});

  @override
  State<FavoriteArticleView> createState() => _FavoriteArticleViewState();
}

class _FavoriteArticleViewState extends State<FavoriteArticleView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final FavoriteArticleViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = context.read();
    _viewModel.loadArticles.execute();
    _viewModel.deleteItem.addListener(_onResult);
  }

  void _onResult() {
    if (_viewModel.deleteItem.error) {
      final message = (_viewModel.deleteItem.result as result.Error).toString();
      context.showError('删除失败: $message');
      _viewModel.deleteItem.clearResult();
    }
  }

  void _onDelete(String postId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('删除动态'),
            content: Text('确定要删除吗？'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确定')),
            ],
          ),
    );
    if (ok == true && context.mounted) {
      _viewModel.deleteItem.execute(postId);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final viewModel = context.watch<FavoriteArticleViewModel>();
    final articles = viewModel.articles;

    if (viewModel.loadArticles.error) {
      final message = (viewModel.loadArticles.result as result.Error).toString();
      return CenterErrorMessage(errorMessage: message, onRetry: viewModel.loadArticles.execute);
    }
    if (articles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 2100),
        child: GridLayoutBuilder(
          minColumns: 1,
          maxColumns: 5,
          minItemWidth: 300,
          imageAspectRatio: 2 / 1,
          extraHeight: 120,
          builder:
              (context, constraints, gridDelegate) => CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverGrid.builder(
                      gridDelegate: gridDelegate,
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        final item = articles[index];
                        return ArticleCard(
                          articleId: item.postId,
                          cover: item.cover ?? kEmptyImageUrl,
                          title: item.title,
                          summary: item.summary,
                          favoriteTime: item.favoriteTime,
                          coverAspectRatio: 2 / 1,
                          contextActions: [
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('删除', style: TextStyle(color: colorScheme.error)),
                              onTap: () => _onDelete(item.postId),
                            ),
                          ],
                          onTap: () => context.push(Routes.buildPostDetail(item.postId, initCover: item.cover)),
                        );
                      },
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
                  SliverToBoxAdapter(
                    child: Paginator(
                      maxPageCount: (_viewModel.total + 19) ~/ 20, // 向上取整
                      currentPage: _viewModel.pn,
                      onPageChanged: (page) => _viewModel.setPn(page),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: kBottomNavigationBarHeight)),
                ],
              ),
        ),

        // LayoutBuilder(
        //   builder: (context, constraints) {
        //     final crossAxisCount = (constraints.maxWidth / 280).floor().clamp(1, 5);
        //     final childAspectRatio = 1.14 - (crossAxisCount - 1) * 0.01;
        //     final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
        //       crossAxisCount: crossAxisCount,
        //       childAspectRatio: constraints.maxWidth > 1750 ? 1.25 : childAspectRatio,
        //     );

        //     return ListenableBuilder(
        //       listenable: _viewModel.loadArticles,
        //       builder: (context, child) {
        //         if (_viewModel.loadArticles.running) {
        //           return const Center(child: CircularProgressIndicator());
        //         }

        //         if (_viewModel.loadArticles.error) {
        //           final message = (_viewModel.loadArticles.result as result.Error).toString();
        //           return CenterErrorMessage(
        //             errorMessage: message,
        //             onRetry: () => _viewModel.reload(),
        //           );
        //         }

        //         if (_viewModel.articles.isEmpty) {
        //           return const Center(child: Text('暂无记录'));
        //         }

        //         return CustomScrollView(
        //           slivers: [
        //             SliverPadding(
        //               padding: const EdgeInsets.symmetric(horizontal: 16.0),
        //               sliver: SliverGrid.builder(
        //                 gridDelegate: gridDelegate,
        //                 itemCount: _viewModel.articles.length,
        //                 itemBuilder: (context, index) {
        //                   final item = _viewModel.articles[index];
        //                   return ArticleCard(
        //                     articleId: item.postId,
        //                     cover: item.cover ?? kEmptyImageUrl,
        //                     title: item.title,
        //                     summary: item.summary,
        //                     favoriteTime: item.favoriteTime,
        //                     contextActions: [
        //                       PopupMenuItem(
        //                         value: 'delete',
        //                         child: Text('删除', style: TextStyle(color: colorScheme.error)),
        //                         onTap: () => _onDelete(item.postId),
        //                       ),
        //                     ],
        //                   );
        //                 },
        //               ),
        //             ),
        //             const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
        //             SliverToBoxAdapter(
        //               child: Paginator(
        //                 maxPageCount: (_viewModel.total + 19) ~/ 20, // 向上取整
        //                 currentPage: _viewModel.pn,
        //                 onPageChanged: (page) => _viewModel.setPn(page),
        //               ),
        //             ),
        //             const SliverToBoxAdapter(child: SizedBox(height: kBottomNavigationBarHeight)),
        //           ],
        //         );
        //       },
        //     );
        //   },
        // ),
      ),
    );
  }
}
