import 'package:better_bilibili/ui/core/bilibili/article/anthology_card.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/sliver_grid_layout_builder.dart';
import 'package:better_bilibili/ui/user/detail/view_models/user_detail_anthology_view_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

const _orderLabels = ['最近更新', '最多浏览'];

class UserDetailAnthologyView extends StatefulWidget {
  final UserDetailAnthologyViewModel viewModel;

  const UserDetailAnthologyView({super.key, required this.viewModel});

  @override
  State<UserDetailAnthologyView> createState() => _UserDetailAnthologyViewState();
}

class _UserDetailAnthologyViewState extends State<UserDetailAnthologyView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final List<Widget> chips = [];
    for (int i = 0; i < _orderLabels.length; i++) {
      chips.add(
        Selector<UserDetailAnthologyViewModel, int>(
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
        _AnthologyGridSliver(viewModel: widget.viewModel),
      ],
    );
  }
}

class _AnthologyGridSliver extends StatelessWidget {
  final UserDetailAnthologyViewModel viewModel;

  const _AnthologyGridSliver({required this.viewModel});

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

        if (viewModel.anthologys.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('暂无内容')),
          );
        }

        return SliverGridLayoutBuilder(
          minColumns: 1,
          maxColumns: 6,
          minItemWidth: 240,
          imageAspectRatio: 3 / 4.2,
          extraHeight: 80,
          horizontalPadding: 16,
          builder: (context, constraints, gridDelegate) {
            return SliverPadding(
              padding: const .symmetric(horizontal: 16.0, vertical: 4.0),
              sliver: SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemCount: viewModel.anthologys.length,
                itemBuilder: (context, index) {
                  final anthology = viewModel.anthologys[index];
                  return AnthologyCard(
                    anthologyId: anthology.id,
                    cover: anthology.cover,
                    name: anthology.name,
                    description: anthology.description,
                    total: anthology.total,
                    updateTime: anthology.modifyTime,
                    viewCount: anthology.viewCount,
                    wordCount: anthology.wordCount,
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
