import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:better_bilibili/ui/settings/account_manager/account_manager_view_model.dart';

class AccountManagerScreen extends StatefulWidget {
  final AccountManagerViewModel viewModel;

  const AccountManagerScreen({super.key, required this.viewModel});

  @override
  State<AccountManagerScreen> createState() => _AccountManagerScreenState();
}

class _AccountManagerScreenState extends State<AccountManagerScreen> {
  AccountManagerViewModel get viewModel => widget.viewModel;

  Future<void> _removeAccount(String accountId, String? nickname) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('移除账户'),
        content: Text('确定要移除账户 "${nickname ?? accountId}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('移除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    viewModel.removeAccount(accountId);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('账号管理'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 1,
      ),
      body: ListenableBuilder(
        listenable: viewModel.getData,
        builder: (context, child) {
          if (viewModel.getData.running) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.getData.error) {
            return CenterErrorMessage(errorMessage: (viewModel.getData.result as Error).toString());
          }

          if (viewModel.accounts.isEmpty) {
            return _buildEmptyState();
          }

          return ListView(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            children: [
              ...viewModel.accounts.map((account) {
                final isSelected = viewModel.currentAccount!.userId == account.userId;
                final userId = account.userId;

                return Card(
                  margin: const .symmetric(horizontal: 16, vertical: 4),
                  color: isSelected ? colorScheme.secondaryContainer : null,
                  child: ListTile(
                    leading: CircleAvatar(backgroundImage: NetworkImage(viewModel.avatars[userId] ?? '')),
                    title: Text(viewModel.nicknames[userId] ?? ''),
                    subtitle: Text('UID: ${account.userId}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              '当前',
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (!isSelected)
                          IconButton(
                            icon: const Icon(Icons.switch_account),
                            tooltip: '切换到此账号',
                            onPressed: () => viewModel.switchAccount(account.userId),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: '移除此账号',
                          onPressed: () => _removeAccount(account.userId, viewModel.nicknames[userId]),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              Center(
                child: FilledButton.icon(
                  onPressed: () => context.push(Routes.login),
                  icon: const Icon(Icons.add),
                  label: const Text('添加新账号'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              '暂无账号',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '添加一个账号以开始使用',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.push(Routes.login),
              icon: const Icon(Icons.add),
              label: const Text('添加账号'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
