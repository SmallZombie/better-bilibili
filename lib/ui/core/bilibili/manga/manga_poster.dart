import 'package:better_bilibili/data/services/storage_service.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:provider/provider.dart';

class MangaPoster extends StatelessWidget {
  final String mangaId;
  final String title;
  final String cover;
  final List<String>? tags;
  final int? currentChapter;
  final int? totalChapter;
  final String? badge;

  final List<PopupMenuEntry<String>>? contextActions;

  const MangaPoster({
    super.key,
    required this.mangaId,
    required this.title,
    required this.cover,
    this.tags,
    this.currentChapter,
    this.totalChapter,
    this.badge,
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
    final result = await storageService.saveNetworkImage(cover, '${mangaId}_cover', 'jpeg');
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
              BiliImageWapper(
                url: cover,
                // suffix: '@308w_410h_1c',
                suffix: '@616w_820h_1c',
                width: 400,
                aspectRatio: 1 / 1.4,
                borderRadius: BorderRadius.circular(12.0),
                fit: BoxFit.cover,
              ),

              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),

                    if (tags != null) ...[
                      SizedBox(height: 4),
                      Text(
                        tags!.join(' / '),
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.outline,
                        ),
                        maxLines: 1,
                      ),
                    ],

                    if (currentChapter != null || totalChapter != null) ...[
                      SizedBox(height: 4),
                      if (currentChapter == 0)
                        Text(
                          '尚未观看',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.outline,
                          ),
                          maxLines: 1,
                        )
                      else if (currentChapter != null && totalChapter != null)
                        Text(
                          '看到第 ${currentChapter!}/${totalChapter!} 话',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.outline,
                          ),
                          maxLines: 1,
                        )
                      else if (currentChapter != null)
                        Text(
                          '看到第 ${currentChapter!} 话',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.outline,
                          ),
                          maxLines: 1,
                        )
                      else
                        Text(
                          '共 ${totalChapter!} 话',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.outline,
                          ),
                          maxLines: 1,
                        ),
                    ],
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

                if (currentChapter != null) ...[
                  SizedBox(height: 24.0),
                  Text('观看进度', style: titleStyle),
                  if (currentChapter != null && totalChapter != null)
                    SelectableText(
                      '看到第 ${currentChapter!}/${totalChapter!} 话',
                      style: textStyle,
                    )
                  else if (currentChapter != null)
                    SelectableText(
                      '看到第 ${currentChapter!} 话',

                      style: textStyle,
                    )
                  else
                    SelectableText(
                      '共 ${totalChapter!} 话',
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
