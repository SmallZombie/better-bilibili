import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/article_detail/article_detail_view_model.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ArticleDetailScreen extends StatefulWidget {
  final ArticleDetailViewModel viewModel;
  final String? cover;

  const ArticleDetailScreen({super.key, required this.viewModel, this.cover});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  @override
  void initState() {
    super.initState();

    widget.viewModel.loadData.addListener(_onResult);
  }

  void _onResult() {
    if (widget.viewModel.loadData.completed) {
      context.replace(
        Routes.buildPostDetail(
          widget.viewModel.articleDetail!.postId,
          initCover: widget.cover,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cover == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    } else {
      return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BiliImageWapper(
            height: 400.0,
            url: widget.cover!,
            aspectRatio: 16 / 9,
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
      );
    }
  }
}
