import 'package:better_bilibili/ui/core/bilibili/article/article_card.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/sliver_grid_layout_builder.dart';
import 'package:better_bilibili/ui/home/view_models/article_home_view_model.dart';
import 'package:material_ui/material_ui.dart';

class ArticleHomeView extends StatefulWidget {
  final ArticleHomeViewModel viewModel;

  const ArticleHomeView({super.key, required this.viewModel});

  @override
  State<ArticleHomeView> createState() => _ArticleHomeViewState();
}

class _ArticleHomeViewState extends State<ArticleHomeView> {
  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification.metrics.maxScrollExtent - notification.metrics.pixels <= 400 && !widget.viewModel.loadData.running) {
      widget.viewModel.loadData.execute();
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: ListenableBuilder(
          listenable: widget.viewModel.loadData,
          builder: (context, child) {
            if (widget.viewModel.loadData.running && widget.viewModel.articles.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (widget.viewModel.loadData.error) {
              return CenterErrorMessage(
                errorMessage: widget.viewModel.loadData.result.toString(),
                onRetry: widget.viewModel.loadData.execute,
              );
            }
            if (widget.viewModel.articles.isEmpty) {
              return const Center(child: Text('暂无内容'));
            }

            return CustomScrollView(
              slivers: [
                SliverGridLayoutBuilder(
                  minColumns: 1,
                  maxColumns: 5,
                  minItemWidth: 300,
                  imageAspectRatio: 2 / 1,
                  extraHeight: 110,
                  horizontalPadding: 16.0,
                  builder: (context, constraints, gridDelegate) => SliverPadding(
                    padding: const .all(16.0),
                    sliver: SliverGrid.builder(
                      gridDelegate: gridDelegate,
                      itemCount: widget.viewModel.articles.length,
                      itemBuilder: (context, index) {
                        final article = widget.viewModel.articles[index];
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
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
