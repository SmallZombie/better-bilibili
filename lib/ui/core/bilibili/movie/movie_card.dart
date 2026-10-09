import 'package:better_bilibili/ui/core/share/base_card.dart';
import 'package:better_bilibili/ui/core/share/custom_icons.dart';
import 'package:better_bilibili/ui/core/share/save_image.dart';
import 'package:flutter/material.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';

class MovieCard extends StatelessWidget {
  final String movieId;
  final String title;
  final String cover;
  final String? badge;
  final double? duration;
  final int? watchTime;
  final int? watchLaterTime;
  final int? favoriteTime;
  final List<PopupMenuEntry<String>> contextActions;
  final VoidCallback? onTap;

  const MovieCard({
    super.key,
    required this.movieId,
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
    context.saveImage(cover, 'bilibili_movie_${movieId}_cover', 'jpeg');
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
        if (duration != null) MetadataItem(value: formatSeconds(duration!)),
      ],
      contentItems: [
        MetadataItemGroup(
          items: [
            if (watchTime != null) MetadataItem(key: '观看于', value: formatTimeToHumanReadable(watchTime!)),
            if (favoriteTime != null) MetadataItem(key: '收藏于', value: formatTimeToHumanReadable(favoriteTime!)),
            if (watchLaterTime != null) MetadataItem(key: '添加于', value: formatTimeToHumanReadable(watchLaterTime!)),
          ],
          separator: const Text(' · '),
        ),
      ],
      onTap: onTap ?? () => _onTap(context),
      sheetItems: [
        MetadataItem(
          icon: CustomIcons.incognito,
          value: '以无痕模式打开',
          onTap: () {},
        ),
        // MetadataItem(
        //   icon: Icons.watch_later_outlined,
        //   value: '添加到稍后观看',
        //   onTap: _watchLater,
        // ),
        MetadataItem(
          icon: Icons.file_download_outlined,
          value: '保存封面',
          onTap: () => _saveCover(context),
        ),

        MetadataItem(key: 'ID', value: movieId),
        MetadataItem(key: '名称', value: title),
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
