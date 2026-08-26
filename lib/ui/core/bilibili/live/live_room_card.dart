import 'package:better_bilibili/data/services/storage_service.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:provider/provider.dart';

class LiveRoomCard extends StatelessWidget {
  final String liveId;
  final String title;
  final String cover;
  final String? badge;
  final String nickname;
  final int? watchTime;

  const LiveRoomCard({
    super.key,
    required this.liveId,
    required this.title,
    required this.cover,
    required this.nickname,
    this.watchTime,
    this.badge,
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
    final result = await storageService.saveNetworkImage(cover, '${liveId}_cover', 'jpeg');
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
                    suffix: '@672w_378h_1c_!web-search-common-cover',
                    width: 900,
                    aspectRatio: 16 / 9,
                    borderRadius: BorderRadius.circular(12.0),
                    fit: BoxFit.cover,
                  ),
                  if (badge != null)
                    Positioned(
                      top: 8.0,
                      right: 8.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          badge!,
                          style: TextStyle(color: colorScheme.onPrimaryContainer, fontSize: 12.0),
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

                    // 作者和上传时间
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment.centerLeft,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3.0),
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext innerContext) => AlertDialog(
                                  title: Text('你点击了作者名'),
                                  content: Text(liveId.toString()),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(innerContext, 'Cancel'),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(innerContext, 'OK'),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Text(
                              nickname,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.outline,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        if (watchTime != null)
                          Text(
                            ' · 观看于${formatTimeToHumanReadable(watchTime!)}',
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

                SizedBox(height: 24.0),
                Text('作者', style: titleStyle),
                SelectableText(nickname, style: textStyle),

                if (watchTime != null) ...[
                  SizedBox(height: 24.0),
                  Text('观看于', style: titleStyle),
                  SelectableText(
                    '${formatTime(watchTime!)} (${formatTimeToHumanReadable(watchTime!)})',
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
