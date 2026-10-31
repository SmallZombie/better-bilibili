import 'dart:async';
import 'dart:ui' as ui;

import 'package:better_bilibili/data/repositories/bilibili/video_repository/video_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_timeline_preview_response.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/timeline/preview/timeline_preview_controller.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';
import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class BiliTimelinePreviewController extends SafeChangeNotifier implements TimelinePreviewController {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'TimelinePreviewController'));

  final VideoRepository videoRepository;
  final String videoId;
  final String episodeId;
  final Dio _client = Dio();

  BiliTimelinePreviewController({
    required this.videoRepository,
    required this.videoId,
    required this.episodeId,
  }) {
    getData = Command0(_getData);
  }

  late final Command0 getData;

  GetTimelinePreviewResponse? data;
  final List<int> indexes = [];

  bool _disposed = false;

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;

    currentImage = null;
    currentRect = null;

    _client.close(force: true);

    final cachedImages = imageCache.values.toList();
    imageCache.clear();
    _disposeCachedImages(cachedImages);

    super.dispose();
  }

  Future<void> _disposeCachedImages(Iterable<Future<ui.Image>> images) async {
    await Future.wait(
      images.map((future) async {
        try {
          (await future).dispose();
        } catch (error, stackTrace) {
          if (!_disposed || error is! DioException) {
            _log.e('Failed to dispose timeline preview image', error: error, stackTrace: stackTrace);
          }
        }
      }),
    );
  }

  Future<Result<void>> _getData() async {
    _log.i('Fetching timeline preview for videoId: $videoId, episodeId: $episodeId');

    final previewResult = await videoRepository.getTimelinePreview(videoId: videoId, episodeId: episodeId);
    if (_disposed) return previewResult;

    switch (previewResult) {
      case Ok(:final value):
        data = value;
      case Err():
        return previewResult;
    }

    final indexesResult = await _client.get(
      data!.indexFile,
      options: Options(responseType: .bytes),
    );
    if (_disposed) return previewResult;

    indexes.clear();
    final bytes = indexesResult.data as Uint8List;

    for (var i = 0; i < bytes.length; i += 2) {
      final value = (bytes[i] << 8) | bytes[i + 1];
      indexes.add(value);
    }
    _log.i('indexes: $indexes');

    return previewResult;
  }

  int latestIndex = -1;
  Map<int, Future<ui.Image>> imageCache = {};

  @override
  ui.Image? currentImage;
  @override
  Rect? currentRect;

  @override
  Future<void> updatePreview(Duration position) async {
    if (_disposed) return;

    if (data == null) {
      try {
        await getData.execute();
      } on DioException {
        if (!_disposed) rethrow;
      }
    }

    if (_disposed || data == null || indexes.isEmpty) return;

    // 由于b站返回的索引列表前面会多一个0，所以这里即使时间是 0 直接 -1 索引也是对的
    int index = indexes.indexWhere((v) => v > position.inSeconds) - 1;
    if (index < 0) {
      index = indexes.length - 1;
    }

    if (index == latestIndex) {
      return;
    }

    latestIndex = index;

    final imageIndex = index ~/ (data!.rowCount * data!.columnCount);

    ui.Image image;
    try {
      if (imageCache.containsKey(imageIndex)) {
        image = await imageCache[imageIndex]!;
      } else {
        final future = _getImage(imageIndex);
        imageCache[imageIndex] = future;
        image = await future;
      }
    } on DioException {
      if (!_disposed) rethrow;
      return;
    } on StateError {
      if (!_disposed) rethrow;
      return;
    }

    if (_disposed) return;
    if (latestIndex != index) return;

    currentImage = image;

    final indexWithImage = index % (data!.rowCount * data!.columnCount);
    final column = indexWithImage % data!.columnCount;
    final row = indexWithImage ~/ data!.columnCount;

    currentRect = Rect.fromLTWH(
      column * data!.imageWidth.toDouble(),
      row * data!.imageHeight.toDouble(),
      data!.imageWidth.toDouble(),
      data!.imageHeight.toDouble(),
    );

    notifyListeners();
  }

  Future<ui.Image> _getImage(int index) async {
    _log.i('Fetching image for index: $index');

    final url = data!.images[index];

    final result = await _client.get(url, options: Options(responseType: .bytes));
    final bytes = result.data as Uint8List;

    if (_disposed) {
      throw StateError('Timeline preview controller disposed while loading an image');
    }
    return decodeImageFromList(bytes);
  }
}
