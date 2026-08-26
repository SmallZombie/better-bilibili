import 'package:better_bilibili/data/services/storage_service.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:provider/provider.dart';

class CourseCard extends StatelessWidget {
  final String courseId;
  final String title;
  final String cover;
  final String? badge;
  final double? duration;
  final int? watchTime;
  final int? watchLaterTime;
  final int? favoriteTime;

  const CourseCard({
    super.key,
    required this.courseId,
    required this.title,
    required this.cover,
    this.badge,
    this.duration,
    this.watchTime,
    this.watchLaterTime,
    this.favoriteTime,
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
    final result = await storageService.saveNetworkImage(cover, '${courseId}_cover', 'jpeg');
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
        onSecondaryTap: () => _showInfoSheet(context),
        onLongPress: () => _showInfoSheet(context),
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          margin: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              // 上半部分
              Stack(
                children: [
                  BiliImageWapper(
                    url: cover,
                    suffix: BiliImageSuffix.homeVideoCard,
                    width: 900,
                    aspectRatio: 16 / 9,
                    borderRadius: BorderRadius.circular(12.0),
                    fit: BoxFit.cover,
                  ),
                  if (duration != null)
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          formatDuration(duration!),
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),

              // 下半部分
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
                    Row(
                      children: [
                        if (watchTime != null)
                          Text(
                            '观看于${formatTimeToHumanReadable(watchTime!)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.outline,
                            ),
                            maxLines: 1,
                          ),

                        if (watchLaterTime != null)
                          Text(
                            '${watchTime != null ? ' · ' : ''}添加于${formatTimeToHumanReadable(watchLaterTime!)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.outline,
                            ),
                            maxLines: 1,
                          ),
                        if (watchLaterTime != null)
                          Text(
                            '${watchTime != null || watchLaterTime != null ? ' · ' : ''}收藏于${formatTimeToHumanReadable(watchLaterTime!)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.outline,
                            ),
                            maxLines: 1,
                          ),
                      ],
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

                if (watchTime != null) ...[
                  SizedBox(height: 24.0),
                  Text('观看于', style: titleStyle),
                  SelectableText(
                    '${formatTime(watchTime!)} (${formatTimeToHumanReadable(watchTime!)})',
                    style: textStyle,
                  ),
                ],

                if (watchLaterTime != null) ...[
                  SizedBox(height: 24.0),
                  Text('添加于', style: titleStyle),
                  SelectableText(
                    '${formatTime(watchLaterTime!)} (${formatTimeToHumanReadable(watchLaterTime!)})',
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
}
