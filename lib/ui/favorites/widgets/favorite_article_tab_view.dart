import 'dart:async';

import 'package:better_bilibili/config/constants.dart';
import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/bilibili/article/article_card.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/paginator.dart';
import 'package:better_bilibili/ui/core/share/simple_dialog.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/ui/core/share/sliver_card_layout_builder.dart';
import 'package:better_bilibili/ui/favorites/view_models/favorite_article_view_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:better_bilibili/utils/result.dart';

class FavoriteArticleTabView extends StatefulWidget {
  final FavoriteArticleViewModel viewModel;

  const FavoriteArticleTabView({super.key, required this.viewModel});

  @override
  State<FavoriteArticleTabView> createState() => _FavoriteArticleTabViewState();
}

class _FavoriteArticleTabViewState extends State<FavoriteArticleTabView> with AutomaticKeepAliveClientMixin {
  FavoriteArticleViewModel get viewModel => widget.viewModel;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    viewModel.loadArticles.execute();
    viewModel.deleteArticle.addListener(_onResult);
  }

  void _onResult() {
    if (viewModel.deleteArticle.error) {
      context.showError('删除失败: ${getErrorMessage(viewModel.deleteArticle.result!)}');
      viewModel.deleteArticle.clearResult();
    }
  }

  void _onDelete(String postId) async {
    final confirm = await context.showConfirm(title: '删除文章', content: '确定要删除吗？');
    if (confirm && context.mounted) {
      unawaited(viewModel.deleteArticle.execute(postId));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: viewModel.loadArticles,
      builder: (context, child) {
        if (viewModel.loadArticles.error) {
          return CenterErrorMessage(
            errorMessage: getErrorMessage(viewModel.loadArticles.result!),
            onRetry: viewModel.loadArticles.execute,
          );
        }
        if (viewModel.articles.isEmpty) {
          if (viewModel.loadArticles.running) {
            return const Center(child: CircularProgressIndicator());
          }
          return const Center(child: Text('暂无内容'));
        }

        return CustomScrollView(
          slivers: [
            SliverCardLayoutBuilder(
              builder: (context, constraints, gridDelegate) => SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemCount: viewModel.articles.length,
                itemBuilder: (context, index) {
                  final item = viewModel.articles[index];
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
                maxPageCount: (viewModel.total + 19) ~/ 20, // 向上取整
                currentPage: viewModel.pn,
                onPageChanged: (page) => viewModel.setPn(page),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: kBottomNavigationBarHeight)),
          ],
        );
      },
    );
  }
}
