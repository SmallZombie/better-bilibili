import 'package:better_bilibili/data/services/bilibili/model/get_article_colllection_detail_response.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/post_detail/view_models/collection_tab_view_model.dart';
import 'package:better_bilibili/ui/core/bilibili/post/post_tile.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

class CollectionTab extends StatefulWidget {
  final CollectionTabViewModel viewModel;
  final String selectedItemId;
  final ValueChanged<ArticleCollectionItem>? onItemTap;

  const CollectionTab({super.key, required this.viewModel, required this.selectedItemId, this.onItemTap});

  @override
  State<CollectionTab> createState() => _CollectionTabState();
}

class _CollectionTabState extends State<CollectionTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  CollectionTabViewModel get viewModel => widget.viewModel;

  final _padding = const EdgeInsets.symmetric(vertical: 8.0);
  final ScrollController _scrollController = ScrollController();
  late final ListObserverController _observerController;

  @override
  void initState() {
    super.initState();

    viewModel.loadData.addListener(_onResult);
    _observerController = ListObserverController(controller: _scrollController);
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  void _onResult() {
    if (viewModel.loadData.success) {
      final index = viewModel.collection!.items.indexWhere(
        (item) => item.id == widget.selectedItemId || item.id == widget.selectedItemId,
      );
      if (index != -1) {
        _observerController.initialIndexModel = ObserverIndexPositionModel(
          index: index,
          isFixedHeight: true,
          padding: _padding,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListenableBuilder(
      listenable: viewModel.loadData,
      builder: (context, child) {
        if (viewModel.loadData.error) {
          return CenterErrorMessage(
            errorMessage: getErrorMessage(viewModel.loadData.result!),
            onRetry: viewModel.loadData.execute,
          );
        }
        if (viewModel.collection == null) {
          if (viewModel.loadData.running) {
            return const Center(child: CircularProgressIndicator());
          }
          return const Center(child: Text('暂无内容'));
        }

        final collection = viewModel.collection!;

        return ListViewObserver(
          controller: _observerController,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: collection.items.length,
            padding: _padding,
            itemBuilder: (context, index) {
              final item = collection.items[index];
              return PostTile(
                postId: item.id,
                title: item.title,
                cover: item.cover,
                compact: true,
                index: index + 1,
                isActive: item.id == widget.selectedItemId || item.id == widget.selectedItemId,
                onTap: () => widget.onItemTap?.call(item),
              );
            },
          ),
        );
      },
    );
  }
}
