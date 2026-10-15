import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/article_detail/article_detail_view_model.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class ArticleDetailScreen extends StatefulWidget {
  final ArticleDetailViewModel viewModel;
  final String? cover;

  const ArticleDetailScreen({super.key, required this.viewModel, this.cover});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  ArticleDetailViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();

    viewModel.loadData.addListener(_onResult);
  }

  @override
  void dispose() {
    viewModel.loadData.removeListener(_onResult);

    super.dispose();
  }

  void _onResult() {
    if (viewModel.loadData.completed) {
      context.replace(
        Routes.buildPostDetail(
          viewModel.articleDetail!.postId,
          initCover: widget.cover,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (widget.cover == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = Padding(
        padding: const .all(16.0),
        child: BiliImageWapper(
          height: 400.0,
          url: widget.cover!,
          aspectRatio: 16 / 9,
          borderRadius: .circular(16.0),
        ),
      );
    }

    return Scaffold(appBar: AppBar(), body: body);
  }
}
