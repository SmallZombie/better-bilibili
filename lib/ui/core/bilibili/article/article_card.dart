import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:better_bilibili/ui/core/share/base_card.dart';
import 'package:better_bilibili/ui/core/share/save_image.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:better_bilibili/ui/core/share/custom_icons.dart';

class ArticleCard extends StatelessWidget {
  final String articleId;
  final String title;
  final String? summary;
  final String cover;
  final String? nickname;
  final String? avatar;
  final int? viewCount;
  final int? likeCount;
  final int? commentCount;
  final int? releaseTime;
  final int? watchTime;
  final int? favoriteTime;
  final String? badge;
  final double coverAspectRatio;
  final List<PopupMenuEntry<String>> contextActions;
  final VoidCallback? onTap;

  const ArticleCard({
    super.key,
    required this.articleId,
    required this.title,
    this.summary,
    required this.cover,
    this.nickname,
    this.avatar,
    this.viewCount,
    this.likeCount,
    this.commentCount,
    this.releaseTime,
    this.watchTime,
    this.favoriteTime,
    this.badge,
    this.coverAspectRatio = 16 / 9,
    this.contextActions = const [],
    this.onTap,
  });

  void _onTap(BuildContext context) {
    context.push(Routes.buildArticleDetail(articleId, initCover: cover));
  }

  void _saveCover(BuildContext context) {
    context.saveImage(cover, 'bilibili_article_${articleId}_cover', 'jpeg');
  }

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      title: Text(title),
      cover: BiliImageWapper(
        url: cover,
        suffix: '@354w_199h_1c',
        width: 900,
        aspectRatio: 16 / 9,
        borderRadius: .circular(12.0),
        fit: .cover,
      ),
      subtitle: summary != null ? Text(summary!) : null,
      badge: badge != null ? Badge(label: Text(badge!)) : null,
      coverItems: [
        if (viewCount != null)
          MetadataItem(
            icon: Icons.remove_red_eye_outlined,
            value: formatCountToHumanReadable(viewCount!),
          ),
        if (likeCount != null)
          MetadataItem(
            icon: Icons.thumb_up_alt_outlined,
            value: formatCountToHumanReadable(likeCount!),
          ),
      ],
      contextActions: contextActions,
      onTap: onTap ?? () => _onTap(context),
      sheetItems: [
        MetadataItem(
          icon: CustomIcons.incognito,
          value: '以无痕模式打开',
          onTap: () {},
        ),
        MetadataItem(
          icon: Icons.file_download_outlined,
          value: '保存封面',
          onTap: () => _saveCover(context),
        ),
        MetadataItem(
          icon: Icons.report_problem_outlined,
          value: '举报内容',
          description: '点按选择具体原因',
          onTap: () {},
        ),

        MetadataItem(
          key: 'ID',
          value: articleId,
        ),
        MetadataItem(
          key: '标题',
          value: title,
        ),
        if (nickname != null)
          MetadataItem(
            key: '作者',
            value: nickname!,
          ),
        if (releaseTime != null)
          MetadataItem(
            key: '上传时间',
            value: '${formatTime(releaseTime!)} (${formatTimeToHumanReadable(releaseTime!)})',
          ),
        if (watchTime != null)
          MetadataItem(
            key: '观看于',
            value: '${formatTime(watchTime!)} (${formatTimeToHumanReadable(watchTime!)})',
          ),
        if (favoriteTime != null)
          MetadataItem(
            key: '收藏于',
            value: '${formatTime(favoriteTime!)} (${formatTimeToHumanReadable(favoriteTime!)})',
          ),
      ],
    );
  }
}
