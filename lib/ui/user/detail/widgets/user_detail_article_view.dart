import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/ui/core/bilibili/post/post_card.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/grid_layout_builder.dart';
import 'package:better_bilibili/ui/user/detail/view_models/user_detail_article_view_model.dart';
import 'package:material_ui/material_ui.dart';

class UserDetailArticleView extends StatefulWidget {
  final UserDetailArticleViewModel viewModel;

  const UserDetailArticleView({super.key, required this.viewModel});

  @override
  State<UserDetailArticleView> createState() => _UserDetailArticleViewState();
}

class _UserDetailArticleViewState extends State<UserDetailArticleView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  UserDetailArticleViewModel get viewModel => widget.viewModel;

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification.metrics.maxScrollExtent - notification.metrics.pixels <= 400 &&
        !widget.viewModel.loadData.running &&
        widget.viewModel.hasMore) {
      widget.viewModel.loadData.execute();
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: ListenableBuilder(
        listenable: viewModel.loadData,
        builder: (context, child) {
          if (viewModel.loadData.running && viewModel.articles.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (viewModel.loadData.error) {
            return CenterErrorMessage(
              errorMessage: viewModel.loadData.result.toString(),
              onRetry: viewModel.loadData.execute,
            );
          }

          if (viewModel.articles.isEmpty) {
            return Center(child: Text('暂无内容'));
          }

          return NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: GridLayoutBuilder(
              minColumns: 1,
              maxColumns: 5,
              minItemWidth: 280,
              imageAspectRatio: 16 / 9,
              extraHeight: 100,
              horizontalPadding: 16,
              builder: (context, constraints, gridDelegate) {
                return GridView.builder(
                  padding: const .symmetric(horizontal: 16.0, vertical: 4.0),
                  gridDelegate: gridDelegate,
                  itemCount: viewModel.articles.length,
                  itemBuilder: (context, index) {
                    final article = viewModel.articles[index];
                    return PostCard(
                      postId: article.postId,
                      cover: article.cover,
                      title: article.title,
                      likeCount: article.likeCount,
                      user: User(id: viewModel.userId, nickname: '', avatar: ''),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
