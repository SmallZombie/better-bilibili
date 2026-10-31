import 'dart:math';

import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/paginator.dart';
import 'package:better_bilibili/ui/core/share/responsive/max_width_viewport.dart';
import 'package:better_bilibili/ui/followings/user_tile.dart';
import 'package:better_bilibili/ui/user/followings/user_followings_view_model.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UserFollowingsScreen extends StatefulWidget {
  final UserFollowingsViewModel viewModel;

  const UserFollowingsScreen({super.key, required this.viewModel});

  @override
  State<UserFollowingsScreen> createState() => _UserFollowingsScreenState();
}

class _UserFollowingsScreenState extends State<UserFollowingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关注列表')),
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
              if (widget.viewModel.followings.isEmpty) {
                if (widget.viewModel.loadData.running) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const Center(child: Text('暂无内容'));
              }

              return CustomScrollView(
                slivers: [
                  if (widget.viewModel.pn == 1) ..._buildMutualFollowSection(padding),
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
                              final user = widget.viewModel.followings[index];
                              return UserTile(
                                key: ValueKey(user.id),
                                user: user,
                                onTap: () => context.push(Routes.buildUserDetail(user.id)),
                              );
                            },
                            childCount: widget.viewModel.followings.length,
                          ),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Selector<UserFollowingsViewModel, ({int total, int pn})>(
                      selector: (context, viewModel) => (total: viewModel.total, pn: viewModel.pn),
                      builder: (context, value, child) => Paginator(
                        maxPageCount: (value.total + 23) ~/ 24,
                        currentPage: value.pn,
                        onPageChanged: widget.viewModel.setPn,
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

  List<Widget> _buildMutualFollowSection(EdgeInsets padding) {
    final maxCount = 6;

    return [
      SliverPadding(
        padding: padding,
        sliver: SliverToBoxAdapter(child: Text('您与 TA 共同关注了', style: Theme.of(context).textTheme.titleMedium)),
      ),
      SliverPadding(
        padding: padding,
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
                  final user = widget.viewModel.mutualFollows[index];
                  return UserTile(
                    key: ValueKey(user.id),
                    user: user,
                    onTap: () => context.push(Routes.buildUserDetail(user.id)),
                  );
                },
                childCount: min(widget.viewModel.mutualFollows.length, maxCount),
              ),
            );
          },
        ),
      ),
      if (widget.viewModel.mutualFollows.length > maxCount)
        SliverPadding(
          padding: padding,
          sliver: SliverToBoxAdapter(
            child: InkWell(
              onTap: () => context.push(Routes.buildUserMutualFollowings(widget.viewModel.userId)),
              child: Padding(
                padding: const .all(6.0),
                child: Row(
                  mainAxisAlignment: .center,
                  children: [
                    Text('查看更多'),
                    const Icon(Icons.arrow_right, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
    ];
  }
}
