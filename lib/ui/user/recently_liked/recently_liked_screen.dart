import 'package:better_bilibili/ui/core/bilibili/dynamic_card.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/grid_layout_builder.dart';
import 'package:better_bilibili/ui/user/recently_liked/recently_liked_view_model.dart';
import 'package:flutter/material.dart';

class RecentlyLikedScreen extends StatefulWidget {
  final RecentlyLikedViewModel viewModel;
  final String? nickname;

  const RecentlyLikedScreen({super.key, required this.viewModel, this.nickname});

  @override
  State<RecentlyLikedScreen> createState() => _RecentlyLikedScreenState();
}

class _RecentlyLikedScreenState extends State<RecentlyLikedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.nickname == null ? const Text('最近点赞') : Text('${widget.nickname}的最近点赞'),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel.loadData,
        builder: (context, child) {
          if (widget.viewModel.loadData.running) {
            return const Center(child: CircularProgressIndicator());
          }
          if (widget.viewModel.loadData.error) {
            return CenterErrorMessage(
              errorMessage: widget.viewModel.loadData.result.toString(),
              onRetry: widget.viewModel.loadData.execute,
            );
          }
          if (widget.viewModel.videos.isEmpty) {
            return const Center(child: Text('暂无记录'));
          }

          return GridLayoutBuilder(
            minColumns: 1,
            maxColumns: 5,
            minItemWidth: 280,
            imageAspectRatio: 16 / 9,
            extraHeight: 100,
            horizontalPadding: 16,
            builder: (context, constraints, gridDelegate) => GridView.builder(
              gridDelegate: gridDelegate,
              padding: const EdgeInsets.all(16.0),
              itemCount: widget.viewModel.videos.length,
              itemBuilder: (context, index) => DynamicCard(data: widget.viewModel.videos[index]),
            ),
          );
        },
      ),
    );
  }
}
