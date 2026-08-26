import 'package:better_bilibili/ui/core/bilibili/video/video_card.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/paginator.dart';
import 'package:better_bilibili/ui/core/share/sliver_grid_layout_builder.dart';
import 'package:better_bilibili/ui/user/detail/view_models/user_detail_video_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const _chipLabels = ['最新发布', '最多播放', '最多收藏', '充电专属'];

class UserDetailVideoView extends StatefulWidget {
  final UserDetailVideoViewModel viewModel;

  const UserDetailVideoView({super.key, required this.viewModel});

  @override
  State<UserDetailVideoView> createState() => _UserDetailVideoViewState();
}

class _UserDetailVideoViewState extends State<UserDetailVideoView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const .symmetric(horizontal: 16.0, vertical: 8.0),
          sliver: SliverToBoxAdapter(
            child: Selector<UserDetailVideoViewModel, ({int selectedChipIndex, int sponsorOnlyTotal})>(
              selector: (context, vm) => (
                selectedChipIndex: vm.selectedChipIndex,
                sponsorOnlyTotal: vm.sponsorOnlyTotal,
              ),
              builder: (context, state, _) {
                final List<Widget> chips = [];
                for (var i = 0; i < _chipLabels.length; i++) {
                  if (i == _chipLabels.length - 1) {
                    if (state.sponsorOnlyTotal != 0) {
                      chips.add(
                        ChoiceChip(
                          label: Text('${_chipLabels[i]} (${state.sponsorOnlyTotal})'),
                          selected: state.selectedChipIndex == i,
                          onSelected: (value) => widget.viewModel.setSelectedChipIndex(i),
                        ),
                      );
                    }
                  } else {
                    chips.add(
                      ChoiceChip(
                        label: Text(_chipLabels[i]),
                        selected: state.selectedChipIndex == i,
                        onSelected: (value) => widget.viewModel.setSelectedChipIndex(i),
                      ),
                    );
                  }
                }

                return Row(
                  spacing: 8.0,
                  children: chips,
                );
              },
            ),
          ),
        ),
        _VideoGridSliver(viewModel: widget.viewModel),
        SliverToBoxAdapter(
          child: Selector<UserDetailVideoViewModel, ({int pn, int total})>(
            selector: (context, vm) => (pn: vm.pn, total: vm.total),
            builder: (context, state, _) => Paginator(
              maxPageCount: (state.total + (ps - 1)) ~/ ps,
              currentPage: state.pn,
              onPageChanged: (page) => widget.viewModel.setPn(page),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }
}

class _VideoGridSliver extends StatelessWidget {
  final UserDetailVideoViewModel viewModel;

  const _VideoGridSliver({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel.loadData,
      builder: (context, child) {
        if (viewModel.loadData.running) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.loadData.error) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: CenterErrorMessage(
              errorMessage: viewModel.loadData.result.toString(),
              onRetry: viewModel.reload,
            ),
          );
        }

        if (viewModel.videos.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('暂无内容')),
          );
        }

        return SliverGridLayoutBuilder(
          minColumns: 1,
          maxColumns: 5,
          minItemWidth: 280,
          imageAspectRatio: 16 / 9,
          extraHeight: 100,
          horizontalPadding: 16,
          builder: (context, constraints, gridDelegate) {
            return SliverPadding(
              padding: const .symmetric(horizontal: 16.0, vertical: 4.0),
              sliver: SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemCount: viewModel.videos.length,
                itemBuilder: (context, index) {
                  final video = viewModel.videos[index];
                  return VideoCard(
                    videoId: video.id,
                    cover: video.cover,
                    title: video.title,
                    duration: video.duration,
                    viewCount: video.stats.view,
                    danmakuCount: video.stats.danmaku,
                    uploadTime: video.releaseTime,
                    user: video.owner,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
