import 'dart:async';

import 'package:better_bilibili/config/constants.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_response.dart';
import 'package:better_bilibili/ui/core/bilibili/favorite_folder/favorite_folder_card.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/card_layout_builder.dart';
import 'package:better_bilibili/ui/core/share/simple_dialog.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/ui/favorites/view_models/favorite_folder_tab_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:provider/provider.dart';

class FavoriteFolderTabView extends StatefulWidget {
  final FavoritesViewModel viewModel;

  const FavoriteFolderTabView({super.key, required this.viewModel});

  @override
  State<FavoriteFolderTabView> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoriteFolderTabView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  FavoritesViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();

    viewModel.loadData.execute();

    viewModel.loadData.addListener(_onResult);
    viewModel.delete.addListener(_onResult);
  }

  @override
  void dispose() {
    viewModel.loadData.removeListener(_onResult);
    viewModel.delete.removeListener(_onResult);

    super.dispose();
  }

  void _onResult() {
    if (viewModel.delete.error) {
      final message = getErrorMessage(viewModel.delete.result!);
      context.showError('删除失败: $message');
      viewModel.delete.clearResult();
    }
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification.metrics.maxScrollExtent - notification.metrics.pixels <= 400 &&
        !widget.viewModel.loadData.running &&
        widget.viewModel.hasMore) {
      widget.viewModel.loadData.execute();
    }

    return false;
  }

  Future<void> _onEditFavorites(FavoriteFolder favoriteFolder) async {
    showDialog(
      context: context,
      builder: (context) => _EditFavoriteFolderDialog(
        viewModel: viewModel,
        favoriteFolder: favoriteFolder,
      ),
    );
  }

  Future<void> _onDeleteFavorites(FavoriteFolder favorites) async {
    final confirm = await context.showConfirm(
      title: '删除收藏夹',
      content: '确定要删除 "${favorites.name}" 吗？',
    );

    if (confirm && context.mounted) {
      unawaited(viewModel.delete.execute(favorites.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final colorScheme = Theme.of(context).colorScheme;

    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: CardLayoutBuilder(
        padding: const .fromLTRB(16.0, 0, 16.0, kBottomNavigationBarHeight),
        builder: (context, constraints, gridDelegate, padding) => ListenableBuilder(
          listenable: viewModel.loadData,
          builder: (context, child) {
            if (viewModel.loadData.error) {
              return CenterErrorMessage(
                errorMessage: getErrorMessage(viewModel.loadData.result!),
                onRetry: viewModel.reload,
              );
            }
            if (viewModel.favoriteFolders.isEmpty) {
              if (viewModel.loadData.running) {
                return const Center(child: CircularProgressIndicator());
              }
              return const Center(child: Text('暂无内容'));
            }

            return Selector<FavoritesViewModel, List<FavoriteFolder>>(
              selector: (context, vm) => vm.favoriteFolders,
              builder: (context, value, _) => GridView.builder(
                gridDelegate: gridDelegate,
                padding: padding,
                itemCount: value.length,
                itemBuilder: (context, index) {
                  final item = value[index];
                  return FavoriteFolderCard(
                    favoritesId: item.id,
                    cover: item.cover ?? kEmptyImageUrl,
                    title: item.name,
                    user: item.owner,
                    total: item.total,
                    contextActions: [
                      PopupMenuItem(
                        value: 'edit',
                        child: const Text('编辑'),
                        onTap: () => _onEditFavorites(item),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        enabled: item.isDefault == false,
                        child: Text('删除', style: TextStyle(color: colorScheme.error)),
                        onTap: () => _onDeleteFavorites(item),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EditFavoriteFolderDialog extends StatefulWidget {
  final FavoriteFolder favoriteFolder;
  final FavoritesViewModel viewModel;

  const _EditFavoriteFolderDialog({required this.favoriteFolder, required this.viewModel});

  @override
  State<_EditFavoriteFolderDialog> createState() => _EditFavoriteFolderDialogState();
}

class _EditFavoriteFolderDialogState extends State<_EditFavoriteFolderDialog> {
  FavoritesViewModel get viewModel => widget.viewModel;

  late final nameController = TextEditingController(text: widget.favoriteFolder.name);
  late final descriptionController = TextEditingController(text: widget.favoriteFolder.description);
  late bool isPublic = !widget.favoriteFolder.isPrivate;

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑收藏夹'),
      content: Form(
        key: formKey,
        child: SizedBox(
          width: 260,
          child: Column(
            crossAxisAlignment: .start,
            mainAxisSize: .min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: '*名称'),
                validator: (value) {
                  final name = value ?? '';
                  return name.trim().isEmpty ? '名称不能为空' : null;
                },
                maxLength: 20,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: '描述'),
                minLines: 2,
                maxLines: 5,
                keyboardType: .multiline,
                maxLength: 200,
              ),
              Row(
                children: [
                  const Text('公开'),
                  Checkbox(
                    value: isPublic,
                    onChanged: (v) => setState(() => isPublic = v ?? false),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, null), child: Text('取消')),
        ListenableBuilder(
          listenable: viewModel.modify,
          builder: (context, child) {
            if (viewModel.modify.running) {
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
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                await viewModel.modify.execute(
                  ModifyFavoriteFolderOptions(
                    id: widget.favoriteFolder.id,
                    cover: widget.favoriteFolder.cover,
                    name: nameController.text.trim(),
                    description: descriptionController.text,
                    isPrivate: isPublic == false,
                  ),
                );

                if (!context.mounted) return;

                switch (viewModel.modify.result) {
                  case Ok():
                    context.pop();
                  case Err(:final error):
                    context.showError(error.toString());
                  default:
                    break;
                }
              },
              child: Text('确定'),
            );
          },
        ),
      ],
    );
  }
}
