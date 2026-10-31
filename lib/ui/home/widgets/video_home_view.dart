import 'package:better_bilibili/ui/core/bilibili/video/video_card.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/card_layout_builder.dart';
import 'package:better_bilibili/ui/core/theme/theme.dart';
import 'package:better_bilibili/ui/home/view_models/video_home_view_model.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:silky_scroll/silky_scroll.dart';

class VideoHomeView extends StatelessWidget {
  final VideoHomeViewModel viewModel;

  const VideoHomeView({super.key, required this.viewModel});

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
        child: Column(
          children: [
            Selector<VideoHomeViewModel, int>(
              selector: (context, viewModel) => viewModel.selectedCategoryIndex,
              builder: (context, selectedCategoryIndex, child) => _buildCategoryChips(
                context,
                viewModel.categoryList,
                selectedCategoryIndex,
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: viewModel.loadData,
                builder: (context, child) {
                  if (viewModel.loadData.error) {
                    return CenterErrorMessage(
                      errorMessage: getErrorMessage(viewModel.loadData.result!),
                      onRetry: viewModel.loadData.execute,
                    );
                  }
                  if (viewModel.videos.isEmpty) {
                    if (viewModel.loadData.running) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return const Center(child: Text('暂无内容'));
                  }

                  return CardLayoutBuilder(
                    extraHeight: 95,
                    padding: const .symmetric(horizontal: 16.0),
                    builder: (context, constraints, gridDelegate, padding) => SilkyGridView.builder(
                      silkyConfig: kDefaultSilkyConfig,
                      gridDelegate: gridDelegate,
                      padding: padding,
                      itemCount: viewModel.videos.length,
                      itemBuilder: (context, index) {
                        final item = viewModel.videos[index];
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

  Widget _buildCategoryChips(BuildContext context, List<String> categoryList, int selectedCategoryIndex) {
    return SizedBox(
      height: kMinInteractiveDimension,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {.touch, .mouse}),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          itemCount: categoryList.length,
          itemBuilder: (_, index) {
            return ChoiceChip(
              label: Text(categoryList[index]),
              selected: selectedCategoryIndex == index,
              showCheckmark: false,
              onSelected: (selected) => viewModel.onCategorySelected(selected ? index : 0),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(width: 8.0),
        ),
      ),
    );
  }
}
