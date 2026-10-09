import 'package:better_bilibili/data/model/bilibili/movie_model.dart';
import 'package:better_bilibili/ui/core/share/base_card.dart';
import 'package:better_bilibili/ui/core/share/save_image.dart';
import 'package:flutter/material.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';

class SeriesPoster extends StatelessWidget {
  final String seriesId;
  final String title;
  final String cover;
  final String? badge;
  final String? category;
  final MovieCountry? countries;
  final int year;
  final String? watchProgressStr;
  final List<PopupMenuEntry<String>> contextActions;
  final VoidCallback? onTap;

  const SeriesPoster({
    super.key,
    required this.seriesId,
    required this.title,
    required this.cover,
    this.badge,
    this.category,
    this.countries,
    required this.year,
    this.watchProgressStr,
    this.contextActions = const [],
    this.onTap,
  });

  void _onTap(BuildContext context) {}

  void _saveCover(BuildContext context) {
    context.saveImage(cover, 'bilibili_series_${seriesId}_cover', 'jpeg');
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
      badge: badge,
      contentItems: [
        MetadataItemGroup(
          items: [
            if (category != null) MetadataItem(value: category!),
            if (countries != null) MetadataItem(value: countries!.name),
            MetadataItem(value: year.toString()),
          ],
          separator: const Text(' · '),
        ),
        if (watchProgressStr != null)
          MetadataItemGroup(
            items: [
              MetadataItem(key: '观看进度', value: watchProgressStr!),
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

        MetadataItem(key: 'ID', value: seriesId),
        MetadataItem(key: '标题', value: title),
        if (category != null) MetadataItem(key: '分类', value: category!),
        if (countries != null) MetadataItem(key: '国家', value: countries!.name),
        MetadataItem(key: '年份', value: year.toString()),
        if (watchProgressStr != null) MetadataItem(key: '观看进度', value: watchProgressStr!),
      ],
      contextActions: contextActions,
    );
  }
}
