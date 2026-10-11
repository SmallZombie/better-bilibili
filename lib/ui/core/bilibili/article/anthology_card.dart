import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:better_bilibili/ui/core/theme/theme.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:better_bilibili/utils/list_util.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class AnthologyCard extends StatelessWidget {
  final String anthologyId;
  final String cover;
  final String name;
  final String? description;
  final String? userId;
  final String? nickname;
  final int? releaseTime;
  final int? updateTime;
  final int? total;
  final int? viewCount;
  final int? wordCount;

  /// 封面比例: 3 / 4.2
  /// 建议扩展空间: 80
  const AnthologyCard({
    super.key,
    required this.anthologyId,
    required this.cover,
    required this.name,
    this.description,
    this.userId,
    this.nickname,
    this.releaseTime,
    this.updateTime,
    this.total,
    this.viewCount,
    this.wordCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      type: MaterialType.card,
      child: InkWell(
        onTap: () {},
        borderRadius: const .all(Radius.circular(12.0)),
        child: Padding(
          padding: const .all(10.0),
          child: Column(
            crossAxisAlignment: .start,
            spacing: 4.0,
            children: [
              Stack(
                children: [
                  BiliImageWapper(
                    aspectRatio: 3 / 4.2,
                    borderRadius: .circular(12.0),
                    fit: BoxFit.cover,
                    url: cover,
                    suffix: '@470w_628h_1c',
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      padding: const .symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(150),
                        borderRadius: kInfiniteBorderRadius,
                      ),
                      child: Row(
                        spacing: 8.0,
                        children: [
                          if (viewCount != null)
                            Row(
                              mainAxisSize: .min,
                              spacing: 2.0,
                              children: [
                                const Icon(
                                  Icons.remove_red_eye_outlined,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                Text(
                                  formatCountToHumanReadable(viewCount!),
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),

                          if (wordCount != null)
                            Text(
                              '约${formatCountToHumanReadable(wordCount!)}字',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox.shrink(),
              Text(
                name,
                maxLines: 2,
                overflow: .ellipsis,
                style: const TextStyle(fontSize: 15),
              ),
              if (description != null)
                Text(
                  description!,
                  maxLines: 1,
                  overflow: .ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.outline,
                  ),
                ),
              Row(
                children: [
                  if (nickname != null)
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
                        onPressed: userId == null ? null : () => context.push(Routes.buildUserDetail(userId!)),
                        child: Text(
                          nickname!,
                          maxLines: 1,
                          overflow: .ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.outline,
                            fontWeight: .normal,
                          ),
                        ),
                      ),
                    ),
                  if (total != null)
                    Flexible(
                      child: Text(
                        '${total!}篇文章',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.outline,
                        ),
                      ),
                    ),
                  if (updateTime != null || releaseTime != null)
                    Flexible(
                      child: Text(
                        '${updateTime != null ? '更新于' : '创建于'}${formatTimeToHumanReadable(updateTime ?? releaseTime!)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.outline,
                        ),
                      ),
                    ),
                ].intersperse(const Text(' · ')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
