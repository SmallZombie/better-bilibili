import 'package:better_bilibili/ui/core/bilibili/audio/audio_card.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/paginator.dart';
import 'package:better_bilibili/ui/core/share/sliver_grid_layout_builder.dart';
import 'package:better_bilibili/ui/user/detail/view_models/user_detail_audio_view_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

const _orderLabels = ['最新发布', '最多播放', '最多收藏'];

class UserDetailAudioView extends StatefulWidget {
  final UserDetailAudioViewModel viewModel;

  const UserDetailAudioView({super.key, required this.viewModel});

  @override
  State<UserDetailAudioView> createState() => _UserDetailAudioViewState();
}

class _UserDetailAudioViewState extends State<UserDetailAudioView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final List<Widget> chips = [];
    for (int i = 0; i < _orderLabels.length; i++) {
      chips.add(
        Selector<UserDetailAudioViewModel, int>(
          selector: (context, vm) => vm.selectedOrderIndex,
          builder: (context, selectedOrderIndex, _) => ChoiceChip(
            label: Text(_orderLabels[i]),
            selected: selectedOrderIndex == i,
            onSelected: (value) => widget.viewModel.setSelectedOrderIndex(i),
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const .symmetric(horizontal: 16.0, vertical: 8.0),
          sliver: SliverToBoxAdapter(
            child: Row(spacing: 8.0, children: chips),
          ),
        ),
        _AudioGridSliver(viewModel: widget.viewModel),
        SliverPadding(
          padding: const .all(16.0),
          sliver: SliverToBoxAdapter(
            child: Selector<UserDetailAudioViewModel, ({int pn, int total})>(
              selector: (context, vm) => (pn: vm.pn, total: vm.total),
              builder: (context, state, _) => Paginator(
                maxPageCount: (state.total + (ps - 1)) ~/ ps,
                currentPage: state.pn,
                onPageChanged: (page) => widget.viewModel.setPn(page),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AudioGridSliver extends StatelessWidget {
  final UserDetailAudioViewModel viewModel;

  const _AudioGridSliver({required this.viewModel});

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

        if (viewModel.audios.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('暂无内容')),
          );
        }

        return SliverGridLayoutBuilder(
          minColumns: 1,
          maxColumns: 7,
          minItemWidth: 200,
          imageAspectRatio: 1,
          extraHeight: 80,
          horizontalPadding: 16,
          builder: (context, constraints, gridDelegate) {
            return SliverPadding(
              padding: const .symmetric(horizontal: 16.0, vertical: 4.0),
              sliver: SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemCount: viewModel.audios.length,
                itemBuilder: (context, index) {
                  final audio = viewModel.audios[index];
                  return AudioCard(
                    audioId: audio.id,
                    cover: audio.cover,
                    name: audio.name,
                    releaseTime: audio.releaseTime,
                    playCount: audio.playCount,
                    duration: audio.duration,
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
