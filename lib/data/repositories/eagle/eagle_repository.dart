import 'package:better_bilibili/data/model/eagle/folder.dart';
import 'package:better_bilibili/ui/core/share/image_viewer.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';

abstract interface class EagleRepository {
  Future<Dio> getClient();

  Future<Result<List<Folder>>> getRecentFolderList();
  Future<Result<void>> saveImage({required String imageUrl, required String sourceUrl, required String name});
  List<ImageViewerAction> imageViewerActionsBuilder({
    required BuildContext context,
    required ImageViewerItem image,
    required int index,
    required List<ImageViewerItem> images,
    required String sourceUrl,
  });
}
