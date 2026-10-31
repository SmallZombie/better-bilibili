import 'package:better_bilibili/data/services/bilibili/model/get_subscribed_manga.dart';
import 'package:better_bilibili/ui/core/bilibili/manga/manga_poster.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/card_layout_builder.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/ui/user/subscriptions/view_models/manga_tab_view_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:better_bilibili/utils/result.dart' as result;
import 'package:provider/provider.dart';

class MangaTabView extends StatefulWidget {
  final MangaTabViewModel viewModel;

  const MangaTabView({super.key, required this.viewModel});

  @override
  State<MangaTabView> createState() => _MangaTabState();
}

class _MangaTabState extends State<MangaTabView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    widget.viewModel.unsubscribe.addListener(_onResult);
  }

  @override
  void dispose() {
    widget.viewModel.unsubscribe.removeListener(_onResult);

    super.dispose();
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

  void _onResult() {
    if (widget.viewModel.unsubscribe.error) {
      final message = (widget.viewModel.unsubscribe.result as result.Err).toString();
      context.showError('取消订阅失败: $message');
      widget.viewModel.unsubscribe.clearResult();
    }
  }

  Future<void> _onUnsubscribe(SubscribedManga item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('取消订阅'),
        content: Text('确定要取消订阅 "${item.title}" 吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确定')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      widget.viewModel.unsubscribe.execute(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final colorScheme = Theme.of(context).colorScheme;

    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: CardLayoutBuilder(
        minColumns: 1,
        maxColumns: 6,
        minItemWidth: 240,
        imageAspectRatio: 1 / 1.4,
        extraHeight: 80,
        padding: const .fromLTRB(16.0, 0, 16.0, kBottomNavigationBarHeight),
        builder: (context, constraints, gridDelegate, padding) {
          return ListenableBuilder(
            listenable: widget.viewModel.loadData,
            builder: (context, child) {
              if (widget.viewModel.mangas.isEmpty && widget.viewModel.loadData.running) {
                return const Center(child: CircularProgressIndicator());
              }

              if (widget.viewModel.loadData.error) {
                return CenterErrorMessage(
                  errorMessage: widget.viewModel.loadData.result.toString(),
                  onRetry: widget.viewModel.reload,
                );
              }

              if (widget.viewModel.mangas.isEmpty) {
                return const Center(child: Text('暂无内容'));
              }

              return Selector<MangaTabViewModel, List<SubscribedManga>>(
                selector: (context, vm) => vm.mangas,
                builder: (context, mangas, _) => GridView.builder(
                  gridDelegate: gridDelegate,
                  padding: padding,
                  itemCount: mangas.length,
                  itemBuilder: (context, index) {
                    final item = mangas[index];
                    return MangaPoster(
                      mangaId: item.id,
                      cover: item.cover,
                      title: item.title,
                      currentChapter: item.currentChapter,
                      totalChapter: item.totalChapter,
                      contextActions: [
                        PopupMenuItem(
                          value: 'unsubscribe',
                          child: Text('取消订阅', style: TextStyle(color: colorScheme.error)),
                          onTap: () => _onUnsubscribe(item),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
