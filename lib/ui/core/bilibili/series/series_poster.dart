import 'package:better_bilibili/data/model/bilibili/movie_model.dart';
import 'package:better_bilibili/data/services/storage_service.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:provider/provider.dart';

class SeriesPoster extends StatelessWidget {
  final String seriesId;
  final String title;
  final String cover;
  final String? badge;
  final String? category;
  final MovieCountry? countries;
  final int year;
  final String? watchProgressStr;
  final List<PopupMenuEntry<String>>? contextActions;

  const SeriesPoster({
    super.key,
    required this.seriesId,
    required this.title,
    required this.cover,
    this.badge,
    this.category,
    this.countries,
    required this.year,
    this.watchProgressStr,
    this.contextActions,
  });

  void _showInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildBottomSheet(
        context,
        Theme.of(context).colorScheme,
        Theme.of(context).textTheme,
      ),
    );
  }

  Future<void> _saveCoverImage(BuildContext context) async {
    assert(!kIsWeb);

    final storageService = context.read<StorageService>();
    final result = await storageService.saveNetworkImage(cover, '${seriesId}_cover', 'jpeg');
    if (context.mounted) {
      switch (result) {
        case Ok():
          context.showInfo('保存成功');
        case Error():
          context.showError('保存失败: ${result.error.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final hasCustomContextMenu = contextActions != null && contextActions!.isNotEmpty;

    return Material(
      type: MaterialType.card,
      child: InkWell(
        // onTap:
        //     () => AppService().toVideoDetail(
        //       context,
        //       videoId,
        //       episodeId: episodeId,
        //       preloadTitle: title,
        //       preloadCover: cover,
        //       preloadViewCount: viewCount,
        //       preloadDanmuCount: danmakuCount,
        //       playListId: playListId,
        //     ),
        onSecondaryTap: hasCustomContextMenu ? null : () => _showInfoSheet(context),
        onLongPress: hasCustomContextMenu ? null : () => _showInfoSheet(context),
        onSecondaryTapDown: hasCustomContextMenu ? (details) => _showContextMenu(context, details.globalPosition) : null,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          margin: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  BiliImageWapper(
                    url: cover,
                    // suffix: '@308w_410h_1c',
                    suffix: '@616w_820h_1c',
                    width: 400,
                    aspectRatio: 1 / 1.4,
                    borderRadius: BorderRadius.circular(12.0),
                    fit: BoxFit.cover,
                  ),
                  if (badge != null)
                    Positioned(
                      top: 8.0,
                      right: 8.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge!,
                          style: TextStyle(color: colorScheme.primary, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),

                    SizedBox(height: 4),
                    Text(
                      '${category == null ? '' : '$category · '}${countries == null ? '' : '${countries!.name} · '}$year',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.outline,
                      ),
                      maxLines: 1,
                    ),

                    if (watchProgressStr != null)
                      Text(
                        watchProgressStr!,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.outline,
                        ),
                        maxLines: 1,
                      ),
                  ],
                ),
              ),
              SizedBox(width: 4.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    final titleStyle = textTheme.titleMedium!.copyWith(fontSize: 18.0, fontWeight: FontWeight.w500);
    final textStyle = TextStyle(fontSize: 14.0, color: colorScheme.onSurfaceVariant);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenHeight = MediaQuery.of(context).size.height;
        final double maxHeight = screenHeight / 2 < 500 ? screenHeight / 2 : 500;
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight, minWidth: 640, maxWidth: 640),
          child: SingleChildScrollView(
            padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('封面', style: titleStyle),
                SizedBox(height: 4.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    BiliImageWapper(
                      url: cover,
                      suffix: BiliImageSuffix.recommendVideoCard,
                      width: 380,
                      aspectRatio: 16 / 9,
                      borderRadius: BorderRadius.circular(12.0),
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 8.0),
                    IconButton(
                      onPressed: () => _saveCoverImage(context),
                      icon: Icon(Icons.download_outlined),
                      tooltip: '下载原图',
                    ),
                  ],
                ),

                SizedBox(height: 24.0),
                Text('标题', style: titleStyle),
                SelectableText(title, style: textStyle),

                if (watchProgressStr != null) ...[
                  SizedBox(height: 24.0),
                  Text('观看进度', style: titleStyle),
                  SelectableText(
                    watchProgressStr!,
                    style: textStyle,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showContextMenu(BuildContext context, Offset pos) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(pos.dx, pos.dy, pos.dx, pos.dy),
      items: [
        ...contextActions!,
        PopupMenuItem(value: '_info', child: Text('详细信息'), onTap: () => _showInfoSheet(context)),
      ],
    );
  }
}
