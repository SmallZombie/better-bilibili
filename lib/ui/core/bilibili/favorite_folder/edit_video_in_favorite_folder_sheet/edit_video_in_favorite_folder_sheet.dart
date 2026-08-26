import 'package:better_bilibili/data/services/bilibili/model/get_favorites_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_simple_list_response.dart';
import 'package:better_bilibili/ui/core/bilibili/favorite_folder/edit_video_in_favorite_folder_sheet/edit_video_in_favorite_folder_sheet_view_model.dart';
import 'package:better_bilibili/ui/core/share/bottom_sheet_wapper.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

extension EditVideoInFavoriteFolderSheet on BuildContext {
  Future<FavoritesPickerResult?> showFavoritesPicker({
    String? subtitle,
    String? videoId,
    bool multiSelect = false,
  }) async {
    final viewModel = read<EditVideoInFavoriteFolderSheetViewModel>();
    viewModel.getFavorites.execute(videoId);
    final selectedFavoritesIds = <String>{};
    bool initialized = false;

    FavoritesPickerResult buildResult(Set<String> selectedIds) {
      final initialSelectedIds = viewModel.initialSelectedFavoritesIds;
      final selectedSet = Set<String>.from(selectedIds);
      return FavoritesPickerResult(
        allFavorites: viewModel.favorites,
        initialSelectedIds: initialSelectedIds,
        selectedIds: selectedSet,
      );
    }

    final result = await showModalBottomSheet<FavoritesPickerResult>(
      context: this,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setState) {
          return BottomSheetWapper(
            title: Text('选择收藏夹'),
            subtitle: subtitle == null ? null : Text(subtitle),
            actions: multiSelect
                ? [
                    TextButton(
                      onPressed: () => ctx.pop(),
                      child: const Text('取消'),
                    ),
                    FilledButton(
                      onPressed: viewModel.getFavorites.running ? null : () => ctx.pop(buildResult(selectedFavoritesIds)),
                      child: const Text('确定'),
                    ),
                  ]
                : [],
            child: ListenableBuilder(
              listenable: viewModel.getFavorites,
              builder: (_, _) {
                if (!initialized && !viewModel.getFavorites.running) {
                  selectedFavoritesIds
                    ..clear()
                    ..addAll(viewModel.initialSelectedFavoritesIds);
                  initialized = true;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (viewModel.getFavorites.running) LinearProgressIndicator(),
                    SizedBox(height: 4.0),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: ListView.builder(
                          itemCount: viewModel.favorites.length,
                          itemBuilder: (context, index) {
                            final item = viewModel.favorites[index];
                            return ListTile(
                              leading: Icon(item.isPrivate ? Icons.lock : Icons.lock_open),
                              title: Text(item.name),
                              subtitle: Text('${item.total} 个 · ${item.isPrivate ? '私有' : '公开'}'),
                              trailing: multiSelect
                                  ? Checkbox(
                                      value: selectedFavoritesIds.contains(item.id),
                                      onChanged: (_) {
                                        setState(() {
                                          if (selectedFavoritesIds.contains(item.id)) {
                                            selectedFavoritesIds.remove(item.id);
                                          } else {
                                            selectedFavoritesIds.add(item.id);
                                          }
                                        });
                                      },
                                    )
                                  : Radio<bool>(
                                      groupValue: selectedFavoritesIds.contains(item.id),
                                      value: true,
                                      onChanged: (_) {
                                        final result = buildResult({item.id});
                                        Navigator.pop(ctx, result);
                                      },
                                    ),
                              onTap: () {
                                if (multiSelect) {
                                  setState(() {
                                    if (selectedFavoritesIds.contains(item.id)) {
                                      selectedFavoritesIds.remove(item.id);
                                    } else {
                                      selectedFavoritesIds.add(item.id);
                                    }
                                  });
                                  return;
                                }

                                final result = buildResult({item.id});
                                Navigator.pop(ctx, result);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );

    viewModel.clear();

    return result;
  }

  Future<Favorites?> showCreateFavoritesDialog() async {
    final EditVideoInFavoriteFolderSheetViewModel viewModel = read();

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isPublic = false;

    return showDialog<Favorites>(
      context: this,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('创建收藏夹'),
            content: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 8.0),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: '名称'),
                    validator: (value) => value?.isEmpty ?? true ? '名称不能为空' : null,
                    maxLength: 20,
                  ),
                  SizedBox(height: 8.0),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 300,
                      maxWidth: 300,
                    ),
                    child: TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: '描述'),
                      minLines: 2,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      maxLength: 200,
                    ),
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
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, null), child: Text('取消')),
              ListenableBuilder(
                listenable: viewModel.createFavorites,
                builder: (context, child) {
                  if (viewModel.createFavorites.running) {
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

                      await viewModel.createFavorites.execute(
                        CreateFavoritesRequest(
                          name: nameController.text,
                          description: descriptionController.text,
                          isPrivate: isPublic == false,
                          coverUrl: null,
                        ),
                      );

                      if (!context.mounted) return;

                      switch (viewModel.createFavorites.result) {
                        case Ok(:final value):
                          context.pop(value);
                        case Error(:final error):
                          showError(error.toString());
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
        },
      ),
    );
  }
}

class FavoritesPickerResult {
  final List<SimpleFavorites> allFavorites;
  final Set<String> initialSelectedIds;
  final Set<String> selectedIds;

  FavoritesPickerResult({
    required List<SimpleFavorites> allFavorites,
    required Set<String> initialSelectedIds,
    required Set<String> selectedIds,
  }) : allFavorites = List.unmodifiable(allFavorites),
       initialSelectedIds = Set.unmodifiable(initialSelectedIds),
       selectedIds = Set.unmodifiable(selectedIds);

  Set<String> get addedIds => selectedIds.difference(initialSelectedIds);
  Set<String> get removedIds => initialSelectedIds.difference(selectedIds);
  bool get hasChanges => addedIds.isNotEmpty || removedIds.isNotEmpty;

  List<SimpleFavorites> get selectedFavorites =>
      allFavorites.where((favorite) => selectedIds.contains(favorite.id)).toList(growable: false);

  SimpleFavorites? get singleSelectedFavorite {
    if (selectedFavorites.isEmpty) {
      return null;
    }
    return selectedFavorites.first;
  }
}
