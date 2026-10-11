import 'package:better_bilibili/ui/core/share/base_card.dart';
import 'package:better_bilibili/ui/core/share/save_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';

class SeriesCard extends StatelessWidget {
  final String seriesId;
  final String title;
  final String cover;
  final String? badge;
  final double? duration;
  final int? watchTime;
  final int? watchLaterTime;
  final List<PopupMenuEntry<String>> contextActions;
  final VoidCallback? onTap;

  const SeriesCard({
    super.key,
    required this.seriesId,
    required this.title,
    required this.cover,
    this.badge,
    this.duration,
    this.watchTime,
    this.watchLaterTime,
    this.contextActions = const [],
    this.onTap,
  });

  void _onTap(BuildContext context) {}

  void _saveCover(BuildContext context) {
    context.saveImage(cover, 'bilibili_series_${seriesId}_cover', 'jpeg');
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
      contentItems: [
        MetadataItemGroup(
          items: [
            if (watchTime != null) MetadataItem(key: '观看于', value: formatTimeToHumanReadable(watchTime!)),
            if (watchLaterTime != null) MetadataItem(key: '添加于', value: formatTimeToHumanReadable(watchLaterTime!)),
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

        MetadataItem(key: 'ID', value: seriesId),
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
