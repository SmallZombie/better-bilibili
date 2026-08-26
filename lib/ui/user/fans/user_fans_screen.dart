import 'package:better_bilibili/data/services/bilibili/model/get_fans_response.dart';
import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_user_avatar.dart';
import 'package:better_bilibili/ui/core/bilibili/user/follow_text_button/follow_text_button.dart';
import 'package:better_bilibili/ui/core/bilibili/user/follow_text_button/follow_text_button_view_model.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/image_wapper.dart';
import 'package:better_bilibili/ui/core/share/paginator.dart';
import 'package:better_bilibili/ui/user/fans/user_fans_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UserFansScreen extends StatefulWidget {
  final UserFansViewModel viewModel;

  const UserFansScreen({super.key, required this.viewModel});

  @override
  State<UserFansScreen> createState() => _UserFansScreenState();
}

class _UserFansScreenState extends State<UserFansScreen> {
  Future<void> _onDeleteFan(FanUser user) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除粉丝'),
        content: Text('确定要删除粉丝 "${user.nickname}" 吗？'),
        actions: [
          TextButton(onPressed: () => context.pop(false), child: const Text('取消')),
          TextButton(onPressed: () => context.pop(true), child: const Text('确定')),
        ],
      ),
    );
    if (result == true) {
      widget.viewModel.deleteFan.execute(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxContentWidth = 1000;

    return Scaffold(
      appBar: AppBar(title: const Text('粉丝列表')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = constraints.maxWidth > maxContentWidth ? maxContentWidth : constraints.maxWidth;
          final crossAxisCount = contentWidth > 800 ? 2 : 1;

          return ListenableBuilder(
            listenable: widget.viewModel.loadData,
            builder: (context, child) {
              if (widget.viewModel.loadData.running) {
                return const Center(child: CircularProgressIndicator());
              }

              if (widget.viewModel.loadData.error) {
                return Center(
                  child: CenterErrorMessage(
                    errorMessage: widget.viewModel.loadData.result.toString(),
                    onRetry: widget.viewModel.reload,
                  ),
                );
              }

              if (widget.viewModel.fans.isEmpty) {
                return const Center(child: Text('暂无记录'));
              }

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth > maxContentWidth ? (constraints.maxWidth - maxContentWidth) / 2 : 0,
                    ),
                    sliver: SliverPadding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      sliver: Selector<UserFansViewModel, ({List<FanUser> fans, int version})>(
                        selector: (context, viewModel) => (fans: viewModel.fans, version: viewModel.fansVersion),
                        builder: (context, state, _) => SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 5.5,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final user = state.fans[index];
                              return _UserTile(
                                key: ValueKey(user.id),
                                user: user,
                                onTap: () => context.push(Routes.buildUserDetail(user.id)),
                                onDelete: () => _onDeleteFan(user),
                              );
                            },
                            childCount: state.fans.length,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Selector<UserFansViewModel, ({int total, int pn})>(
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
}

class _UserTile extends StatelessWidget {
  final FanUser user;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _UserTile({
    super.key,
    required this.user,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8.0,
            children: [
              BiliUserAvatar(
                url: user.avatar,
                size: 72,
                isVerified: user.isVerified,
                isEnterpriseVerified: user.isEnterpriseVerified,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      spacing: 8.0,
                      children: [
                        Text(
                          user.nickname,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16.0),
                        ),
                        if (user.amEarlyFan)
                          ImageWapper(
                            image: AssetImage('assets/images/am_early_fan_icon.png'),
                            height: 14.0,
                          ),
                      ],
                    ),
                    if (user.description != null)
                      Text(
                        user.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colorScheme.outline),
                      ),
                  ],
                ),
              ),
              ChangeNotifierProvider(
                create: (context) => FollowTextButtonViewModel(
                  userRepository: context.read(),
                  userId: user.id,
                  initState: user.isFollowing,
                ),
                builder: (context, _) => FollowTextButton(viewModel: context.read()),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    onTap: onDelete,
                    child: Text('删除', style: TextStyle(color: colorScheme.error)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
