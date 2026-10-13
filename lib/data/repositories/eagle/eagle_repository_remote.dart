import 'dart:async';

import 'package:better_bilibili/config/eagle_config.dart';
import 'package:better_bilibili/data/interceptors/debug_logger_interceptor.dart';
import 'package:better_bilibili/data/model/eagle/folder.dart';
import 'package:better_bilibili/data/repositories/eagle/eagle_repository.dart';
import 'package:better_bilibili/data/services/eagle/eagle_api_service.dart';
import 'package:better_bilibili/ui/core/share/image_viewer.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

class EagleRepositoryRemote implements EagleRepository {
  final EagleConfig config;
  late final EagleApiService eagleApiService = EagleApiService(getClient: getClient);

  final List<StreamSubscription> _subscriptions = [];

  EagleRepositoryRemote({required this.config}) {
    _subscriptions.addAll([
      config.baseUrl.stream.listen((_) => _disposeClient()),
      config.apiToken.stream.listen((_) => _disposeClient()),
    ]);
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    _disposeClient();
  }

  void _disposeClient() {
    _client?.close();
    _client = null;
  }

  Dio? _client;

  @override
  Future<Dio> getClient() async {
    if (_client != null) {
      return _client!;
    }

    final apiToken = await config.apiToken.get();
    final params = {
      if (apiToken.isNotEmpty) 'token': apiToken,
    };

    final client = Dio(
      BaseOptions(
        baseUrl: config.baseUrl.value,
        queryParameters: params.isNotEmpty ? params : null,
      ),
    );
    if (kDebugMode) {
      client.interceptors.add(debugLoggerInterceptor);
    }

    _client = client;

    return client;
  }

  @override
  Future<Result<List<Folder>>> getRecentFolderList() {
    return eagleApiService.getRecentFolderList();
  }

  @override
  Future<Result<void>> saveImage({required String imageUrl, required String sourceUrl, required String name}) {
    return eagleApiService.saveImage(imageUrl: imageUrl, sourceUrl: sourceUrl, name: name);
  }

  @override
  List<ImageViewerAction> imageViewerActionsBuilder({
    required BuildContext context,
    required ImageViewerItem image,
    required int index,
    required List<ImageViewerItem> images,
    required String sourceUrl,
  }) {
    String getName(int? index) => 'bilibili_${ImageViewer.getSaveDateString(context)}${index != null ? '_${index + 1}' : ''}';

    return [
      ImageViewerAction(
        name: '保存到 Eagle',
        icon: Icons.download,
        onTap: () async {
          final result = await saveImage(
            imageUrl: image.url,
            sourceUrl: sourceUrl,
            name: getName(index),
          );
          if (!context.mounted) return;

          switch (result) {
            case Ok():
              context.showInfo('已保存');
            case Error(:final error):
              context.showError('保存失败: ${error.toString()}');
          }
        },
      ),
      if (images.length > 1)
        ImageViewerAction(
          name: '保存全部${images.length}张到 Eagle',
          icon: Icons.download,
          onTap: () async {
            final List<Future> futures = [];
            for (int i = 0; i < images.length; i++) {
              futures.add(
                saveImage(
                  imageUrl: images[i].url,
                  sourceUrl: sourceUrl,
                  name: getName(i),
                ),
              );
            }
            final results = await Future.wait(futures);
            if (!context.mounted) return;

            for (final i in results) {
              if (i is Error) context.showError('保存时发生错误: ${i.error.toString()}');
            }

            if (results.every((v) => v is Ok)) {
              context.showInfo('已全部保存');
            }
          },
        ),
    ];
  }
}
