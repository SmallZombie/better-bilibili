import 'dart:core' hide Error;
import 'dart:ui';

import 'package:better_bilibili/ui/core/bilibili/video/video_card.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/grid_layout_builder.dart';
import 'package:better_bilibili/ui/home/view_models/video_home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:silky_scroll/silky_scroll.dart';

class VideoHomeView extends StatefulWidget {
  final VideoHomeViewModel viewModel;

  const VideoHomeView({super.key, required this.viewModel});

  @override
  State<VideoHomeView> createState() => _VideoHomeViewState();
}

class _VideoHomeViewState extends State<VideoHomeView> {
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
        child: Column(
          children: [
            Selector<VideoHomeViewModel, int>(
              selector: (context, viewModel) => viewModel.selectedCategoryIndex,
              builder: (context, selectedCategoryIndex, child) => _buildCategoryChips(
                widget.viewModel.categoryList,
                selectedCategoryIndex,
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.viewModel.loadData,
                builder: (context, child) {
                  if (widget.viewModel.loadData.running && widget.viewModel.videos.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (widget.viewModel.loadData.error) {
                    return CenterErrorMessage(
                      errorMessage: widget.viewModel.loadData.result.toString(),
                      onRetry: widget.viewModel.loadData.execute,
                    );
                  }

                  if (widget.viewModel.videos.isEmpty) {
                    return const Center(child: Text('暂无内容'));
                  }

                  return GridLayoutBuilder(
                    minColumns: 1,
                    maxColumns: 5,
                    minItemWidth: 280,
                    imageAspectRatio: 16 / 9,
                    extraHeight: 95,
                    horizontalPadding: 16.0,
                    builder: (context, constraints, gridDelegate) => SilkyGridView.builder(
                      silkyConfig: const SilkyScrollConfig(
                        silkyScrollDuration: Duration(milliseconds: 400),
                        animationCurve: Curves.bounceOut,
                      ),
                      gridDelegate: gridDelegate,
                      padding: const .all(16.0),
                      itemCount: widget.viewModel.videos.length,
                      itemBuilder: (context, index) {
                        final item = widget.viewModel.videos[index];
                        return VideoCard(
                          videoId: item.id,
                          episodeId: item.episodeId,
                          title: item.title,
                          cover: item.cover,
                          viewCount: item.stats.view,
                          danmakuCount: item.stats.danmaku,
                          duration: item.duration,
                          user: item.owner,
                          uploadTime: item.releaseTime,
                          showAvatar: true,
                          canNotInterested: true,
                          trackingInfo: item.trackingInfo,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips(List<String> categoryList, int selectedCategoryIndex) {
    return SizedBox(
      height: kMinInteractiveDimension,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          itemCount: categoryList.length,
          itemBuilder: (_, index) {
            return ChoiceChip(
              label: Text(categoryList[index]),
              selected: selectedCategoryIndex == index,
              showCheckmark: false,
              onSelected: (selected) => widget.viewModel.onCategorySelected(selected ? index : 0),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(width: 8.0),
        ),
      ),
    );
  }
}
