import 'package:better_bilibili/ui/core/share/base_card.dart';
import 'package:better_bilibili/ui/core/share/save_image.dart';
import 'package:better_bilibili/utils/bilibili/bili_util.dart';
import 'package:material_ui/material_ui.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';

class CourseCard extends StatelessWidget {
  final String courseId;
  final String title;
  final String cover;
  final String? badge;
  final double? duration;
  final int? watchTime;
  final int? watchLaterTime;
  final int? favoriteTime;
  final List<PopupMenuEntry<String>> contextActions;
  final VoidCallback? onTap;

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
    this.contextActions = const [],
    this.onTap,
  });

  void _onTap(BuildContext context) {}

  void _saveCover(BuildContext context) {
    context.saveImage(cover, 'bilibili_course_${courseId}_cover', 'jpeg');
  }

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      title: Text(title),
      cover: BiliImageWapper(
        url: cover,
        suffix: '@672w_378h_1c',
        width: 900,
        aspectRatio: 16 / 9,
        borderRadius: .circular(12.0),
        fit: .cover,
      ),
      coverItems: [
        if (duration != null)
          MetadataItem(
            key: '时长',
            value: formatSeconds(duration!),
          ),
      ],
      contentItems: [
        MetadataItemGroup(
          items: [
            if (watchTime != null) MetadataItem(key: '观看于', value: '观看于${formatTimeToHumanReadable(watchTime!)}'),
            if (favoriteTime != null) MetadataItem(key: '收藏于', value: '收藏于${formatTimeToHumanReadable(favoriteTime!)}'),
            if (watchLaterTime != null) MetadataItem(key: '添加于', value: '添加于${formatTimeToHumanReadable(watchLaterTime!)}'),
          ],
          separator: const Text(' · '),
        ),
      ],
      onTap: onTap ?? () => _onTap(context),
      sheetItems: [
        MetadataItem(
          icon: Icons.file_download_outlined,
          value: '保存封面',
          onTap: () => _saveCover(context),
        ),

        MetadataItem(key: 'ID', value: '${av2bv(courseId)} ($courseId)'),
        MetadataItem(key: '标题', value: title),
        if (watchTime != null)
          MetadataItem(
            key: '观看于',
            value: '${formatTime(watchTime!)} (${formatTimeToHumanReadable(watchTime!)})',
          ),
        if (watchLaterTime != null)
          MetadataItem(
            key: '添加于',
            value: '${formatTime(watchLaterTime!)} (${formatTimeToHumanReadable(watchLaterTime!)})',
          ),
      ],
      contextActions: contextActions,
    );
  }
}
