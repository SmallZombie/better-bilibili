import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/video_repository/video_repository.dart';
import 'package:better_bilibili/domain/models/bilibili/bilibili.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/l10n/l10n_util.dart';
import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_user_avatar.dart';
import 'package:better_bilibili/ui/core/bilibili/not_interested/not_interested_card.dart';
import 'package:better_bilibili/ui/core/bilibili/video/not_interested_sheet.dart';
import 'package:better_bilibili/ui/core/share/base_card.dart';
import 'package:better_bilibili/ui/core/share/custom_icons.dart';
import 'package:better_bilibili/ui/core/share/save_image.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/utils/bili/bili_util.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:material_ui/material_ui.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class VideoCard extends StatefulWidget {
  final String videoId;
  final String? episodeId;
  final String title;
  final String cover;
  final User? user;
  final bool showAvatar;
  final int? viewCount;
  final int? danmakuCount;
  final double? duration;
  final int? uploadTime;
  final int? watchTime;
  final int? favoriteTime;
  final int? watchLaterTime;
  final String? playListId;
  final List<PopupMenuEntry<String>> contextActions;
  final VoidCallback? onTap;
  final bool canAddWatchLater;
  final bool canNotInterested;
  final TrackingInfo? trackingInfo;

  const VideoCard({
    super.key,
    required this.videoId,
    this.episodeId,
    required this.title,
    required this.cover,
    this.user,
    this.showAvatar = false,
    this.viewCount,
    this.danmakuCount,
    this.duration,
    this.uploadTime,
    this.watchTime,
    this.favoriteTime,
    this.watchLaterTime,
    this.playListId,
    this.contextActions = const [],
    this.onTap,
    this.canAddWatchLater = true,
    this.canNotInterested = false,
    this.trackingInfo,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  String? notInterestedReasonId;

  void _onTap() {
    context.push(
      Routes.buildVideoDetail(
        videoId: widget.videoId,
        episodeId: widget.episodeId,
        initCover: widget.cover,
        playlistId: widget.playListId,
      ),
    );
  }

  void _saveCover() {
    context.saveImage(widget.cover, 'bilibili_video_${widget.videoId}_cover', 'jpeg');
  }

  Future<void> _watchLater() async {
    try {
      final userRepository = context.read<UserRepository>();
      final result = await userRepository.addVideoToWatchLater(videoId: widget.videoId);

      if (!mounted) return;

      switch (result) {
        case Ok():
          context.showInfo('已添加');
        case Error(:final error):
          context.showError('添加失败: ${error.toString()}');
      }
    } on Exception {
      context.showError('服务不可用');
    }
  }

  Future<void> _notInterested() async {
    final result = await context.showVideoNotInterestedSheet(
      videoId: widget.videoId,
      userId: widget.user!.id,
      track: widget.trackingInfo!,
      videoTitle: widget.title,
    );

    if (result != null && mounted) {
      setState(() {
        notInterestedReasonId = result;
      });
    }
  }

  Future<void> _undoNotInterested() async {
    assert(notInterestedReasonId != null);

    late final VideoRepository videoRepository;
    try {
      videoRepository = context.read<VideoRepository>();
    } on Exception {
      context.showError('服务不可用');
    }

    final result = await videoRepository.cancelNotInterested(
      videoId: widget.videoId,
      userId: widget.user!.id,
      reasonId: notInterestedReasonId!,
      trackingInfo: widget.trackingInfo!,
    );

    if (!mounted) return;

    switch (result) {
      case Ok():
        setState(() {
          notInterestedReasonId = null;
        });
      case Error(:final error):
        context.showError('撤销失败: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (notInterestedReasonId != null) {
      return NotInterestedCard(onUndo: _undoNotInterested);
    }

    return BaseCard(
      title: Text(widget.title),
      cover: BiliImageWapper(
        url: widget.cover,
        suffix: '@672w_378h_1c',
        width: 900,
        aspectRatio: 16 / 9,
        borderRadius: .circular(12.0),
        fit: .cover,
      ),
      coverItems: [
        if (widget.viewCount != null)
          MetadataItem(
            key: '浏览量',
            value: context.formatCompactNumber(widget.viewCount!),
            icon: Icons.smart_display_outlined,
          ),
        if (widget.danmakuCount != null)
          MetadataItem(
            key: '弹幕量',
            value: formatCountToHumanReadable(widget.danmakuCount!),
            icon: Icons.subtitles_outlined,
          ),
        if (widget.duration != null)
          MetadataItem(
            key: '时长',
            value: formatSeconds(widget.duration!),
          ),
      ],
      leading: switch (widget.user) {
        final user when widget.showAvatar => BiliUserAvatar(
          url: user!.avatar,
          size: 40.0,
          suffix: '@80w_80h_1c_1s',
        ),
        _ => null,
      },
      contentItems: [
        MetadataItemGroup(
          items: [
            if (widget.user != null)
              MetadataItem(
                key: '上传者',
                value: widget.user!.nickname,
                onTap: () => context.push(Routes.buildUserDetail(widget.user!.id)),
              ),
            if (widget.uploadTime != null) MetadataItem(key: '上传时间', value: formatTimeToHumanReadable(widget.uploadTime!)),
            if (widget.watchTime != null) MetadataItem(key: '观看于', value: formatTimeToHumanReadable(widget.watchTime!)),
            if (widget.favoriteTime != null) MetadataItem(key: '收藏于', value: formatTimeToHumanReadable(widget.favoriteTime!)),
            if (widget.watchLaterTime != null) MetadataItem(key: '添加于', value: formatTimeToHumanReadable(widget.watchLaterTime!)),
          ],
          separator: const Text(' · '),
        ),
      ],
      onTap: widget.onTap ?? _onTap,
      sheetItems: [
        MetadataItem(
          icon: CustomIcons.incognito,
          value: '以无痕模式打开',
          onTap: () {},
        ),
        if (widget.canAddWatchLater)
          MetadataItem(
            icon: Icons.watch_later_outlined,
            value: '添加到稍后观看',
            onTap: _watchLater,
          ),
        MetadataItem(
          icon: Icons.file_download_outlined,
          value: '保存封面',
          onTap: _saveCover,
        ),
        if (widget.canNotInterested && widget.user != null && widget.trackingInfo != null)
          MetadataItem(
            icon: Icons.remove_circle_outline,
            value: '不感兴趣',
            description: '点按选择具体原因',
            onTap: _notInterested,
          ),
        MetadataItem(
          icon: Icons.report_problem_outlined,
          value: '举报内容',
          description: '点按选择具体原因',
          onTap: () {},
        ),

        MetadataItem(key: 'ID', value: '${av2bv(widget.videoId)} (${widget.videoId})'),
        MetadataItem(key: '标题', value: widget.title),
        if (widget.user != null)
          MetadataItem(
            key: '上传者',
            value: '${widget.user!.nickname} (${widget.user!.id})',
          ),
        if (widget.uploadTime != null)
          MetadataItem(
            key: '上传时间',
            value: '${formatTime(widget.uploadTime!)} (${formatTimeToHumanReadable(widget.uploadTime!)})',
          ),
        if (widget.watchTime != null)
          MetadataItem(
            key: '观看于',
            value: '${formatTime(widget.watchTime!)} (${formatTimeToHumanReadable(widget.watchTime!)})',
          ),
        if (widget.watchLaterTime != null)
          MetadataItem(
            key: '添加于',
            value: '${formatTime(widget.watchLaterTime!)} (${formatTimeToHumanReadable(widget.watchLaterTime!)})',
          ),
      ],
      contextActions: widget.contextActions,
    );
  }
}
