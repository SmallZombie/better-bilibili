import 'package:better_bilibili/ui/core/share/base_card.dart';
import 'package:better_bilibili/ui/core/share/save_image.dart';
import 'package:flutter/material.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';

class MangaPoster extends StatelessWidget {
  final String mangaId;
  final String title;
  final String cover;
  final List<String>? tags;
  final int? currentChapter;
  final int? totalChapter;
  final String? badge;
  final List<PopupMenuEntry<String>> contextActions;
  final VoidCallback? onTap;

  const MangaPoster({
    super.key,
    required this.mangaId,
    required this.title,
    required this.cover,
    this.tags,
    this.currentChapter,
    this.totalChapter,
    this.badge,
    this.contextActions = const [],
    this.onTap,
  });

  void _onTap(BuildContext context) {}

  void _saveCover(BuildContext context) {
    context.saveImage(cover, 'bilibili_manga_${mangaId}_cover', 'jpeg');
  }

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      title: Text(title),
      cover: BiliImageWapper(
        url: cover,
        suffix: '@616w_820h_1c',
        width: 400,
        aspectRatio: 1 / 1.4,
        borderRadius: .circular(12.0),
        fit: .cover,
      ),
      contentItems: [
        MetadataItemGroup(
          items: [
            if (currentChapter != null && totalChapter != null)
              MetadataItem(key: '观看进度', value: '看到第 ${currentChapter!}/${totalChapter!} 话')
            else if (currentChapter != null)
              MetadataItem(key: '观看进度', value: '看到第 ${currentChapter!} 话')
            else
              MetadataItem(key: '总话数', value: '共 ${totalChapter!} 话'),
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

        MetadataItem(key: 'ID', value: mangaId),
        MetadataItem(key: '标题', value: title),
      ],
      contextActions: contextActions,
    );
  }
}
