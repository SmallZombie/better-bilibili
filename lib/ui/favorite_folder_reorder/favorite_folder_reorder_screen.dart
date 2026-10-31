import 'package:better_bilibili/data/services/bilibili/model/get_favorites_simple_list_response.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/responsive/max_width_viewport.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/ui/favorite_folder_reorder/favorite_folder_reorder_view_model.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class FavoriteFolderReorderScreen extends StatefulWidget {
  final FavoriteFolderReorderViewModel viewModel;

  const FavoriteFolderReorderScreen({super.key, required this.viewModel});

  @override
  State<FavoriteFolderReorderScreen> createState() => _FavoriteFolderReorderScreenState();
}

class _FavoriteFolderReorderScreenState extends State<FavoriteFolderReorderScreen> {
  FavoriteFolderReorderViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();

    viewModel.save.addListener(_onResult);
  }

  @override
  void dispose() {
    viewModel.save.removeListener(_onResult);

    super.dispose();
  }

  void _onResult() {
    if (viewModel.save.success) {
      context.showInfo('已保存');
      viewModel.save.clearResult();
    }
    if (viewModel.save.error) {
      context.showError('保存时发生错误: ${getErrorMessage(viewModel.save.result!)}');
      viewModel.save.clearResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final oddItemColor = colorScheme.secondary.withValues(alpha: 0.05);
    final evenItemColor = colorScheme.secondary.withValues(alpha: 0.15);

    return Scaffold(
      appBar: AppBar(
        title: Text('收藏夹排序'),
        actions: [
          IconButton(
            onPressed: viewModel.save.execute,
            icon: const Icon(Icons.save_outlined),
            tooltip: '保存',
          ),
        ],
      ),
      body: MaxWidthViewport(
        maxWidth: 900,
        child: ListenableBuilder(
          listenable: viewModel.loadData,
          builder: (context, child) {
            if (viewModel.loadData.error) {
              return CenterErrorMessage(
                errorMessage: getErrorMessage(viewModel.loadData.result!),
                onRetry: viewModel.loadData.execute,
              );
            }
            if (viewModel.favoriteFolders.isEmpty) {
              if (viewModel.loadData.running) {
                return const Center(child: CircularProgressIndicator());
              }
              return const Center(child: Text('暂无内容'));
            }

            return Selector<FavoriteFolderReorderViewModel, List<SimpleFavorites>>(
              selector: (context, vm) => vm.favoriteFolders,
              builder: (context, value, _) => ReorderableListView(
                padding: const .only(right: 16.0),
                onReorderItem: viewModel.onReorderItem,
                buildDefaultDragHandles: true,
                children: [
                  for (int i = 0; i < value.length; i++)
                    ListTile(
                      key: ObjectKey(value[i]),
                      tileColor: i.isOdd ? oddItemColor : evenItemColor,
                      leading: Icon(value[i].isPrivate ? Icons.lock_outline : Icons.lock_open_outlined),
                      title: Text(value[i].name),
                      subtitle: Text('共 ${value[i].total} 个视频'),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
