import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

const kDefaultVideoTileStyle = PostTileStyle(backgroundColor: Colors.transparent);

class PostTile extends StatelessWidget {
  final String postId;
  final String cover;
  final String title;
  final String? summary;
  final String? nickname;
  final int? viewCount;
  final VoidCallback? onTap;
  final bool compact;
  final int? index;
  final bool isActive;
  final PostTileStyle style;

  const PostTile({
    super.key,
    required this.postId,
    required this.cover,
    required this.title,
    this.summary,
    this.nickname,
    this.viewCount,
    this.onTap,
    this.compact = false,
    this.index,
    this.isActive = false,
    this.style = kDefaultVideoTileStyle,
  });

  void _onTap(BuildContext context) {
    context.push(
      Routes.buildPostDetail(postId, initCover: cover),
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
          decoration:
              isActive
                  ? BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8.0),
                  )
                  : null,
          child: IntrinsicHeight(
            child: Row(
              children: [
                // 序号和选中状态
                if (index != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      width: 25,
                      child: Text(
                        index.toString(),
                        style: TextStyle(color: isActive ? colorScheme.primary : colorScheme.outline, fontSize: 14.0),
                      ),
                    ),
                  ),

                // 封面
                BiliImageWapper(
                  width: compact ? 120 : 170,
                  aspectRatio: 16 / 9,
                  borderRadius: BorderRadius.circular(12.0),
                  fit: BoxFit.cover,
                  url: cover,
                  suffix: BiliImageSuffix.small,
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
                        maxLines: summary == null ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.0,
                          color: isActive ? colorScheme.primary : null,
                        ),
                      ),
                      if (summary != null) ...[
                        SizedBox(height: 4.0),
                        Text(
                          summary!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: colorScheme.outline),
                        ),
                      ],
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
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (BuildContext innerContext) => AlertDialog(
                                        title: Text('你点击了作者名'),
                                        content: Text(postId.toString()),
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

class PostTileStyle {
  final Color backgroundColor;

  const PostTileStyle({
    required this.backgroundColor,
  });
}
