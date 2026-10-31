import 'dart:ui';

import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/share/base_card.dart';
import 'package:better_bilibili/ui/core/share/save_image.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:material_ui/material_ui.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:go_router/go_router.dart';

class FavoriteFolderCard extends StatelessWidget {
  final String favoritesId;
  final String title;
  final String cover;
  final User? user;
  final int total;
  final int? createdAt;
  final List<PopupMenuEntry<String>> contextActions;
  final VoidCallback? onTap;

  const FavoriteFolderCard({
    super.key,
    required this.favoritesId,
    required this.title,
    required this.cover,
    this.user,
    required this.total,
    this.createdAt,
    this.contextActions = const [],
    this.onTap,
  });

  void _onTap(BuildContext context) {
    context.push(Routes.buildFavoritesDetail(favoritesId));
  }

  void _saveCover(BuildContext context) {
    context.saveImage(cover, 'bilibili_favorites_${favoritesId}_cover', 'jpeg');
  }

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      title: Text(title),
      cover: Stack(
        alignment: .bottomCenter,
        children: [
          Transform.translate(
            offset: const Offset(0, -11),
            child: Transform.scale(
              scale: .93,
              child: ClipRRect(
                borderRadius: .circular(12.0),
                child: Opacity(
                  opacity: 0.8,
                  child: ImageFiltered(
                    imageFilter: .blur(sigmaX: 10, sigmaY: 10),
                    child: _buildCover(),
                  ),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -7),
            child: Transform.scale(
              scale: .95,
              child: ClipRRect(
                borderRadius: .circular(12.0),
                child: ImageFiltered(
                  imageFilter: .blur(sigmaX: 10, sigmaY: 10),
                  child: _buildCover(),
                ),
              ),
            ),
          ),
          _buildCover(),
        ],
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
          ],
        ),
      ],
      onTap: onTap ?? () => _onTap(context),
      sheetItems: [
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

        MetadataItem(key: 'ID', value: favoritesId),
        MetadataItem(key: '名称', value: title),
        if (user != null)
          MetadataItem(
            key: '创建者',
            value: '${user!.nickname} (${user!.id})',
          ),
        if (createdAt != null)
          MetadataItem(
            key: '创建时间',
            value: '${formatTime(createdAt!)} (${formatTimeToHumanReadable(createdAt!)})',
          ),
      ],
      contextActions: contextActions,
    );
  }

  Widget _buildCover() {
    return BiliImageWapper(
      url: cover,
      suffix: '@672w_378h_1c',
      width: 900,
      aspectRatio: 16 / 9,
      borderRadius: .circular(12.0),
      fit: .cover,
    );
  }
}
