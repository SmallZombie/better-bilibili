import 'dart:ui';

import 'package:better_bilibili/data/services/bilibili/model/get_following_users.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_user_avatar.dart';
import 'package:better_bilibili/ui/core/bilibili/user/follow_text_button/follow_text_button.dart';
import 'package:better_bilibili/ui/core/bilibili/user/follow_text_button/follow_text_button_view_model.dart';
import 'package:better_bilibili/ui/core/bilibili/user/user_dialog/user_dialog.dart';
import 'package:better_bilibili/ui/core/share/appbar_with_search.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/image_wapper.dart';
import 'package:better_bilibili/ui/core/share/multi_select_toolbar.dart';
import 'package:better_bilibili/ui/core/share/paginator.dart';
import 'package:better_bilibili/ui/core/share/selectable_item_wrapper.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/ui/user/followings/user_followings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

const _orderLabels = ['关注时间正序', '关注时间倒序', '访问时间正序', '访问时间倒序'];

class UserFollowingsScreen extends StatefulWidget {
  final UserFollowingsViewModel viewModel;

  const UserFollowingsScreen({super.key, required this.viewModel});

  @override
  State<UserFollowingsScreen> createState() => _UserFollowingsScreenState();
}

class _UserFollowingsScreenState extends State<UserFollowingsScreen> {
  void _onToggleMultiSelectMode() {
    widget.viewModel.setMultiSelectMode(!widget.viewModel.multiSelectMode);
  }

  Future<void> _onAddSelectedItemsToGroup() async {
    if (widget.viewModel.selectedUsers.isEmpty) {
      return;
    }

    final result = await context.showUserGroupPicker(
      subtitle: switch (widget.viewModel.selectedUsers.length) {
        1 => '将 "${widget.viewModel.selectedUsers.first.nickname}" 添加到...',
        _ => '将 ${widget.viewModel.selectedUsers.length} 个用户添加到...',
      },
    );

    if (result.isNotEmpty) {
      widget.viewModel.addSelectedItemsToGroup.execute(result);
      _onToggleMultiSelectMode();
    }
  }

  Future<void> _onDeleteUserGroup(int index) async {
    final group = widget.viewModel.groups[index];

    if (const ['-1', '-10', '-20', '0'].contains(group.id)) {
      context.showError('用户组 "${group.name}" 无法被删除');
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('删除用户组'),
        content: Text('确定删除用户组 "${group.name}" 吗？'),
        actions: [
          TextButton(onPressed: () => context.pop(false), child: const Text('取消')),
          TextButton(onPressed: () => context.pop(true), child: const Text('确定')),
        ],
      ),
    );

    if (context.mounted && result == true) {
      widget.viewModel.deleteGroup.execute(index);
    }
  }

  Future<void> _onModifyUserGroup() async {
    final group = widget.viewModel.groups[widget.viewModel.selectedGroupIndex];

    if (const ['-1', '-10', '-20', '0'].contains(group.id)) {
      context.showError('用户组 "${group.name}" 无法被编辑');
      return;
    }

    await context.showUserGroupModifyDialog(group: group);
  }

  @override
  Widget build(BuildContext context) {
    final maxContentWidth = 1000;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBarWithSearch(
        title: const Text('关注列表'),
        onSearch: widget.viewModel.setKeyword,
        onToggleFilter: () {
          widget.viewModel.rememberFiltersState();
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (sheetContext) {
              return ListenableBuilder(
                listenable: widget.viewModel,
                builder: (context, _) {
                  final double screenHeight = MediaQuery.of(context).size.height;
                  final double maxHeight = screenHeight / 2 < 500 ? screenHeight / 2 : 500;

                  final selectedOrderIndex = widget.viewModel.selectedOrderIndex;

                  return ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxHeight, minWidth: 640, maxWidth: 640),
                    child: SingleChildScrollView(
                      padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(24)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSection(
                            context,
                            title: '排序方式',
                            child: Wrap(
                              spacing: 8.0,
                              children: [
                                for (final order in GetFollowingUsersOrderEnum.values)
                                  ChoiceChip(
                                    label: Text(_orderLabels[order.index]),
                                    selected: selectedOrderIndex == order.index,
                                    onSelected: (_) {
                                      widget.viewModel.setSelectedOrderIndex(order.index);
                                    },
                                  ),
                              ],
                            ),
                            isFirst: true,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ).whenComplete(() {
            if (mounted) {
              widget.viewModel.onFilterSheetDismissed();
            }
          });
        },
        actions: [
          Selector<UserFollowingsViewModel, ({bool multiSelectMode, int selectedUsersCount})>(
            selector: (context, viewModel) => (
              multiSelectMode: viewModel.multiSelectMode,
              selectedUsersCount: viewModel.selectedUsers.length,
            ),
            builder: (context, state, _) => MultiSelectToolbar(
              enabled: state.multiSelectMode,
              count: state.selectedUsersCount,
              onToggleMultiSelectMode: _onToggleMultiSelectMode,
              onSelectAll: widget.viewModel.selectAll,
              onDeselectAll: widget.viewModel.deselectAll,
              onInvertSelection: widget.viewModel.invertSelection,
              actions: [
                IconButton(
                  onPressed: () => _onAddSelectedItemsToGroup(),
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: '添加到分组',
                ),
              ],
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'modify_group',
                child: const Text('编辑用户组'),
              ),
              PopupMenuItem(
                value: 'create_group',
                child: const Text('创建用户组'),
              ),
              PopupMenuItem(
                value: 'delete_group',
                child: Text('删除用户组', style: TextStyle(color: colorScheme.error)),
              ),
            ],
            onSelected: (value) {
              if (value == 'modify_group') {
                _onModifyUserGroup();
              } else if (value == 'create_group') {
                context.showUserGroupCreateDialog();
              } else if (value == 'delete_group') {
                _onDeleteUserGroup(widget.viewModel.selectedGroupIndex);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Selector<UserFollowingsViewModel, ({List<UserGroup> groups, int selectedGroupIndex})>(
            selector: (_, vm) => (groups: vm.groups, selectedGroupIndex: vm.selectedGroupIndex),
            builder: (context, state, _) {
              if (state.groups.isEmpty) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  height: kMinInteractiveDimension,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      },
                    ),
                    child: ListView.separated(
                      scrollDirection: .horizontal,
                      itemCount: state.groups.length,
                      itemBuilder: (context, index) {
                        final group = state.groups[index];
                        return ChoiceChip(
                          label: Text('${group.name} (${group.count})'),
                          selected: state.selectedGroupIndex == index,
                          onSelected: (_) => widget.viewModel.setSelectedGroupIndex(index),
                          showCheckmark: false,
                        );
                      },
                      separatorBuilder: (context, index) => const SizedBox(width: 4.0),
                    ),
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
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

                    if (widget.viewModel.users.isEmpty) {
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
                                      final tile = _UserTile(
                                        key: ValueKey(user.id),
                                        user: user,
                                        onTap: () => context.push(Routes.buildUserDetail(user.id)),
                                      );

                                      return Selector<UserFollowingsViewModel, ({bool multiSelectMode, bool selected})>(
                                        selector: (context, vm) =>
                                            (multiSelectMode: vm.multiSelectMode, selected: vm.selectedUsers.contains(user)),
                                        builder: (context, state, _) {
                                          if (state.multiSelectMode) {
                                            return SelectableItemWrapper(
                                              selected: state.selected,
                                              onTap: () => widget.viewModel.toggleItemSelection(user),
                                              child: tile,
                                            );
                                          } else {
                                            return tile;
                                          }
                                        },
                                      );
                                    },
                                    childCount: widget.viewModel.users.length,
                                  ),
                                );
                              },
                            ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required Widget child, bool isFirst = false}) {
    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4.0),
          child,
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final FollowingUser user;
  final VoidCallback onTap;

  const _UserTile({
    super.key,
    required this.user,
    required this.onTap,
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
            ],
          ),
        ),
      ),
    );
  }
}
