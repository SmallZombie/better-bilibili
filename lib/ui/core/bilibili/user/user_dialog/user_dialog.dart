import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/ui/core/bilibili/user/user_dialog/user_dialog_view_model.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

extension SimpleSnackBar on BuildContext {
  Future<UserGroup?> showUserGroupCreateDialog() async {
    final result = await showDialog<UserGroup?>(
      context: this,
      barrierDismissible: false,
      builder: (context) => _UserGroupCreateDialog(viewModel: context.read()),
    );

    return result;
  }

  Future<UserGroup?> showUserGroupModifyDialog({required UserGroup group}) async {
    final result = await showDialog<UserGroup?>(
      context: this,
      barrierDismissible: false,
      builder: (context) => _UserGroupModifyDialog(viewModel: context.read(), group: group),
    );

    return result;
  }

  Future<List<UserGroup>> showUserGroupPicker({String? subtitle}) async {
    final result = await showModalBottomSheet<List<UserGroup>>(
      context: this,
      isScrollControlled: true,
      builder: (context) => _UserGroupPickerDialog(
        viewModel: context.read(),
        subtitle: subtitle,
      ),
    );

    return result ?? [];
  }
}

class _UserGroupCreateDialog extends StatefulWidget {
  final UserDialogViewModel viewModel;

  const _UserGroupCreateDialog({required this.viewModel});

  @override
  State<_UserGroupCreateDialog> createState() => _UserGroupCreateDialogState();
}

class _UserGroupCreateDialogState extends State<_UserGroupCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    widget.viewModel.createGroup.addListener(_onResult);
  }

  @override
  void dispose() {
    _nameController.dispose();
    widget.viewModel.createGroup.removeListener(_onResult);

    super.dispose();
  }

  void _onResult() {
    if (widget.viewModel.createGroup.completed || widget.viewModel.createGroup.error) {
      switch (widget.viewModel.createGroup.result!) {
        case Ok(:final value):
          context.pop(value);
        case Error(:final error):
          context.showError('创建失败: ${error.toString()}');
          widget.viewModel.createGroup.clearResult();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Padding(
          padding: const .all(18.0),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: <Widget>[
              const Text('创建用户组', style: TextStyle(fontSize: 20.0)),
              Text('创建一个用户组来管理关注中的用户', style: TextStyle(fontSize: 14.0, color: colorScheme.outline)),
              const SizedBox(height: 16.0),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: '名称',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '组名不能为空';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: .end,
                children: [
                  TextButton(
                    onPressed: context.pop,
                    child: const Text('取消'),
                  ),
                  ListenableBuilder(
                    listenable: widget.viewModel.createGroup,
                    builder: (context, _) {
                      if (widget.viewModel.createGroup.running) {
                        return const TextButton(
                          onPressed: null,
                          child: SizedBox(
                            width: 18.0,
                            height: 18.0,
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          ),
                        );
                      }

                      return TextButton(
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          widget.viewModel.createGroup.execute(_nameController.text);
                        },
                        child: const Text('确定'),
                      );
                    },
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

class _UserGroupModifyDialog extends StatefulWidget {
  final UserDialogViewModel viewModel;
  final UserGroup group;

  const _UserGroupModifyDialog({required this.viewModel, required this.group});

  @override
  State<_UserGroupModifyDialog> createState() => _UserGroupModifyDialogState();
}

class _UserGroupModifyDialogState extends State<_UserGroupModifyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.group.name;
    widget.viewModel.modifyGroup.addListener(_onResult);
  }

  @override
  void dispose() {
    _nameController.dispose();
    widget.viewModel.modifyGroup.removeListener(_onResult);

    super.dispose();
  }

  void _onResult() {
    if (widget.viewModel.modifyGroup.completed || widget.viewModel.modifyGroup.error) {
      switch (widget.viewModel.modifyGroup.result!) {
        case Ok(:final value):
          context.pop(value);
        case Error(:final error):
          context.showError('修改失败: ${error.toString()}');
          widget.viewModel.modifyGroup.clearResult();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Padding(
          padding: const .all(18.0),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: <Widget>[
              const Text('编辑用户组', style: TextStyle(fontSize: 20.0)),
              const SizedBox(height: 16.0),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: '名称',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '组名不能为空';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: .end,
                children: [
                  TextButton(
                    onPressed: context.pop,
                    child: const Text('取消'),
                  ),
                  ListenableBuilder(
                    listenable: widget.viewModel.modifyGroup,
                    builder: (context, _) {
                      if (widget.viewModel.modifyGroup.running) {
                        return const TextButton(
                          onPressed: null,
                          child: SizedBox(
                            width: 18.0,
                            height: 18.0,
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          ),
                        );
                      }

                      return TextButton(
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          widget.viewModel.modifyGroup.execute(widget.group.copyWith(name: _nameController.text));
                        },
                        child: const Text('确定'),
                      );
                    },
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

class _UserGroupPickerDialog extends StatefulWidget {
  final UserDialogViewModel viewModel;
  final String? subtitle;

  const _UserGroupPickerDialog({required this.viewModel, this.subtitle});

  @override
  State<_UserGroupPickerDialog> createState() => _UserGroupPickerDialogState();
}

class _UserGroupPickerDialogState extends State<_UserGroupPickerDialog> {
  @override
  void initState() {
    super.initState();

    widget.viewModel.loadGroups.execute();
  }

  void _onSelectGroup(UserGroup group) {
    if (widget.viewModel.selectedGroups.contains(group)) {
      widget.viewModel.unselectGroup(group);
    } else {
      widget.viewModel.selectGroup(group);
    }
  }

  void _onConfirm() {
    context.pop(widget.viewModel.selectedGroups.toList());
    widget.viewModel.clearSelectedGroups();
  }

  void _onCancel() {
    widget.viewModel.clearSelectedGroups();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 600,
      height: 350,
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: widget.subtitle == null ? .center : .start,
        children: [
          Padding(
            padding: const .all(16.0),
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: [
                const Text('选择用户组', style: TextStyle(fontSize: 20.0)),
                if (widget.subtitle != null) Text(widget.subtitle!, style: TextStyle(fontSize: 14.0, color: colorScheme.outline)),
              ],
            ),
          ),
          Expanded(
            child: Selector<UserDialogViewModel, List<UserGroup>>(
              selector: (context, viewModel) => viewModel.groups,
              builder: (context, groups, _) => ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return Selector<UserDialogViewModel, Set<UserGroup>>(
                    selector: (context, viewModel) => viewModel.selectedGroups,
                    builder: (context, selectedGroups, _) => ListTile(
                      title: Text(group.name),
                      onTap: () => _onSelectGroup(group),
                      trailing: Checkbox(
                        value: selectedGroups.contains(group),
                        onChanged: (_) => _onSelectGroup(group),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const .all(12.0),
            child: Row(
              spacing: 4.0,
              children: [
                const Spacer(),
                TextButton(onPressed: _onCancel, child: const Text('取消')),
                TextButton(onPressed: _onConfirm, child: const Text('确定')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
