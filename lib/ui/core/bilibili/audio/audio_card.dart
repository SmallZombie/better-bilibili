import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:better_bilibili/ui/core/share/base_card.dart';
import 'package:better_bilibili/ui/core/share/custom_icons.dart';
import 'package:better_bilibili/ui/core/share/save_image.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:flutter/material.dart';

class AudioCard extends StatelessWidget {
  final String audioId;
  final String cover;
  final String name;
  final User? user;
  final int? releaseTime;
  final int? playCount;
  final double? duration;
  final List<PopupMenuEntry<String>> contextActions;
  final VoidCallback? onTap;

  const AudioCard({
    super.key,
    required this.audioId,
    required this.cover,
    required this.name,
    this.user,
    this.releaseTime,
    this.playCount,
    this.duration,
    this.contextActions = const [],
    this.onTap,
  });

  void _onTap(BuildContext context, {bool incognito = false}) {
    // context.push(Routes.buildAudioDetail(audioId, initCover: cover));
  }

  void _saveCover(BuildContext context) {
    context.saveImage(cover, 'bilibili_audio_${audioId}_cover', 'jpeg');
  }

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      title: Text(name),
      cover: BiliImageWapper(
        url: cover,
        suffix: '@310w_310h_1c',
        aspectRatio: 1,
        borderRadius: .circular(12.0),
        fit: BoxFit.cover,
      ),
      coverItems: [
        if (playCount != null)
          MetadataItem(
            icon: Icons.play_circle_outline,
            value: formatCountToHumanReadable(playCount!),
          ),
        if (duration != null) MetadataItem(value: formatSeconds(duration!)),
      ],
      contextActions: contextActions,
      onTap: onTap ?? () => _onTap(context),
      sheetItems: [
        MetadataItem(
          icon: CustomIcons.incognito,
          value: '以无痕模式打开',
          onTap: () => _onTap(context, incognito: true),
        ),
        MetadataItem(
          icon: Icons.file_download_outlined,
          value: '保存封面',
          onTap: () => _saveCover(context),
        ),
        // TODO 跟视频共用一个举报通道
        MetadataItem(
          icon: Icons.report_problem_outlined,
          value: '举报内容',
          description: '点按选择具体原因',
          onTap: () {},
        ),

        MetadataItem(
          key: 'ID',
          value: audioId,
        ),
        MetadataItem(
          key: '歌曲名',
          value: name,
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
      ],
    );
  }
}
