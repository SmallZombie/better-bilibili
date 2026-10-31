import 'package:better_bilibili/ui/core/bilibili/article/article_card.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/card_layout_builder.dart';
import 'package:better_bilibili/ui/home/view_models/article_home_view_model.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:material_ui/material_ui.dart';

class ArticleHomeView extends StatelessWidget {
  final ArticleHomeViewModel viewModel;

  const ArticleHomeView({super.key, required this.viewModel});

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification.metrics.maxScrollExtent - notification.metrics.pixels <= 400 && !viewModel.loadData.running) {
      viewModel.loadData.execute();
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: CardLayoutBuilder(
          padding: const .symmetric(horizontal: 16.0),
          builder: (context, constraints, gridDelegate, padding) => ListenableBuilder(
            listenable: viewModel.loadData,
            builder: (context, child) {
              if (viewModel.loadData.error) {
                return CenterErrorMessage(
                  errorMessage: getErrorMessage(viewModel.loadData.result!),
                  onRetry: viewModel.loadData.execute,
                );
              }
              if (viewModel.articles.isEmpty) {
                if (viewModel.loadData.running) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const Center(child: Text('暂无内容'));
              }

              return GridView.builder(
                gridDelegate: gridDelegate,
                padding: padding,
                itemCount: viewModel.articles.length,
                itemBuilder: (context, index) {
                  final article = viewModel.articles[index];
                  return ArticleCard(
                    articleId: article.id,
                    cover: article.covers.first,
                    title: article.title,
                    summary: article.summary,
                    avatar: article.owner.avatar,
                    nickname: article.owner.nickname,
                    releaseTime: article.releaseTime,
                    viewCount: article.stats.view,
                    likeCount: article.stats.like,
                    coverAspectRatio: 2 / 1,
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
