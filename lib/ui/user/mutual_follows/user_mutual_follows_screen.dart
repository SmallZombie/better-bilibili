import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/paginator.dart';
import 'package:better_bilibili/ui/core/share/responsive/max_width_viewport.dart';
import 'package:better_bilibili/ui/followings/user_tile.dart';
import 'package:better_bilibili/ui/user/mutual_follows/user_mutual_follows_view_model.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class UserMutualFollowsScreen extends StatefulWidget {
  final UserMutualFollowsViewModel viewModel;

  const UserMutualFollowsScreen({super.key, required this.viewModel});

  @override
  State<UserMutualFollowsScreen> createState() => _UserMutualFollowsScreenState();
}

class _UserMutualFollowsScreenState extends State<UserMutualFollowsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('共同关注列表')),
      body: MaxWidthViewport.builder(
        maxWidth: 1000,
        padding: .symmetric(horizontal: 16.0),
        builder: (context, padding) {
          return ListenableBuilder(
            listenable: widget.viewModel.loadData,
            builder: (context, asyncSnapshot) {
              if (widget.viewModel.loadData.error) {
                return CenterErrorMessage(
                  errorMessage: getErrorMessage(widget.viewModel.loadData.result!),
                  onRetry: widget.viewModel.reload,
                );
              }
              if (widget.viewModel.users.isEmpty) {
                if (widget.viewModel.loadData.running) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const Center(child: Text('暂无内容'));
              }

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: padding.add(const .symmetric(vertical: 16.0)),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.crossAxisExtent > 800 ? 2 : 1;
                        return SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 5.5,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final user = widget.viewModel.users[index];
                              return UserTile(
                                key: ValueKey(user.id),
                                user: user,
                                onTap: () => context.push(Routes.buildUserDetail(user.id)),
                              );
                            },
                            childCount: widget.viewModel.users.length,
                          ),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Selector<UserMutualFollowsViewModel, ({int total, int pn})>(
                      selector: (context, viewModel) => (total: viewModel.total, pn: viewModel.pn),
                      builder: (context, value, child) => Paginator(
                        maxPageCount: (widget.viewModel.total + (widget.viewModel.ps - 1)) ~/ widget.viewModel.ps, // 向上取整
                        currentPage: widget.viewModel.pn,
                        onPageChanged: (page) => widget.viewModel.setPn(page),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: const SizedBox(height: kBottomNavigationBarHeight)),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
