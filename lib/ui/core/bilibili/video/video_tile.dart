import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const kDefaultVideoTileStyle = VideoTileStyle(backgroundColor: Colors.transparent);

class VideoTile extends StatelessWidget {
  final String videoId;
  final String? episodeId;
  final String title;
  final String cover;
  final String? userId;
  final String? nickname;
  final int? viewCount;
  final int? danmakuCount;
  final double? duration;
  final VoidCallback? onTap;
  final bool compact;
  final int? index;
  final bool isActive;
  final VideoTileStyle style;

  const VideoTile({
    super.key,
    required this.videoId,
    this.episodeId,
    required this.title,
    required this.cover,
    this.userId,
    this.nickname,
    this.viewCount,
    this.danmakuCount,
    this.duration,
    this.onTap,
    this.compact = false,
    this.index,
    this.isActive = false,
    this.style = kDefaultVideoTileStyle,
  });

  void _onTap(BuildContext context) {
    context.push(
      Routes.buildVideoDetail(
        videoId: videoId,
        episodeId: episodeId,
        initCover: cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: style.backgroundColor,
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: onTap ?? () => _onTap(context),
        borderRadius: BorderRadius.circular(8.0),
        child: Ink(
          padding: const EdgeInsets.all(8.0),
          decoration: isActive
              ? BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8.0),
                )
              : null,
          child: IntrinsicHeight(
            child: Row(
              children: [
                // 序号和正在播放
                if (index != null) ...[
                  const SizedBox(width: 8.0),
                  isActive
                      ? Icon(Icons.play_arrow_rounded, size: 18, color: colorScheme.primary)
                      : Text(
                          index.toString(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
                        ),
                  const SizedBox(width: 8.0),
                ],

                // 封面
                Stack(
                  children: [
                    BiliImageWapper(
                      width: compact ? 120 : 170,
                      aspectRatio: 16 / 9,
                      borderRadius: BorderRadius.circular(12.0),
                      fit: BoxFit.cover,
                      url: cover,
                      suffix: '@336w_190h_1c_!web-video-rcmd-cover',
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

                // 信息
                SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题
                      SizedBox(height: 4.0),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.0,
                          color: isActive ? colorScheme.primary : null,
                        ),
                      ),
                      if (!compact) ...[
                        SizedBox(height: 4.0),
                        Wrap(
                          spacing: 10.0,
                          children: [
                            if (viewCount != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.smart_display_outlined,
                                    size: 14,
                                    color: colorScheme.outline,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    formatCountToHumanReadable(viewCount!),
                                    style: TextStyle(
                                      color: colorScheme.outline,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            if (danmakuCount != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.subtitles_outlined,
                                    size: 14,
                                    color: colorScheme.outline,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    formatCountToHumanReadable(danmakuCount!),
                                    style: TextStyle(
                                      color: colorScheme.outline,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                      if (nickname != null)
                        Row(
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                alignment: Alignment.centerLeft,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                              ),
                              onPressed: userId != null ? () => context.push(Routes.buildUserDetail(userId!)) : null,
                              child: Text(
                                nickname!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.outline,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VideoTileStyle {
  final Color backgroundColor;

  const VideoTileStyle({
    required this.backgroundColor,
  });
}
