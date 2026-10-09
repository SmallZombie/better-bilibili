import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/share/base_card.dart';
import 'package:better_bilibili/ui/core/share/save_image.dart';
import 'package:flutter/material.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:go_router/go_router.dart';

class LiveRoomCard extends StatelessWidget {
  final String liveId;
  final String title;
  final String cover;
  final String? badge;
  final User? user;
  final int? watchTime;
  final List<PopupMenuEntry<String>> contextActions;
  final VoidCallback? onTap;

  const LiveRoomCard({
    super.key,
    required this.liveId,
    required this.title,
    required this.cover,
    this.user,
    this.watchTime,
    this.badge,
    this.contextActions = const [],
    this.onTap,
  });

  void _onTap(BuildContext context) {}

  void _saveCover(BuildContext context) {
    context.saveImage(cover, 'bilibili_live_${liveId}_cover', 'jpeg');
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
            if (user != null)
              MetadataItem(
                key: '上传者',
                value: user!.nickname,
                onTap: () => context.push(Routes.buildUserDetail(user!.id)),
              ),
            if (watchTime != null) MetadataItem(key: '观看于', value: formatTimeToHumanReadable(watchTime!)),
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

        MetadataItem(key: 'ID', value: liveId),
        MetadataItem(key: '标题', value: title),
        if (user != null)
          MetadataItem(
            key: '主播',
            value: '${user!.nickname} (${user!.id})',
          ),
        if (watchTime != null)
          MetadataItem(
            key: '观看于',
            value: '${formatTime(watchTime!)} (${formatTimeToHumanReadable(watchTime!)})',
          ),
      ],
      contextActions: contextActions,
    );
  }
}
