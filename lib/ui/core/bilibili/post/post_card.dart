import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:better_bilibili/ui/core/bilibili/post/post_report_sheet.dart';
import 'package:better_bilibili/ui/core/share/base_card.dart';
import 'package:better_bilibili/ui/core/share/save_image.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:better_bilibili/ui/core/share/custom_icons.dart';

class PostCard extends StatelessWidget {
  final String postId;
  final String title;
  final String? summary;
  final String cover;
  final User? user;
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

  const PostCard({
    super.key,
    required this.postId,
    required this.title,
    this.summary,
    required this.cover,
    this.user,
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
    context.push(Routes.buildPostDetail(postId, initCover: cover));
  }

  void _saveCover(BuildContext context) {
    context.saveImage(cover, 'bilibili_post_${postId}_cover', 'jpeg');
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
        if (user != null)
          MetadataItem(
            icon: Icons.report_problem_outlined,
            value: '举报内容',
            description: '点按选择具体原因',
            onTap: () => context.showPostReportSheet(postId, user!.id),
          ),

        MetadataItem(
          key: 'ID',
          value: postId,
        ),
        MetadataItem(
          key: '标题',
          value: title,
        ),
        if (user != null)
          MetadataItem(
            key: '作者',
            value: user!.nickname,
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
