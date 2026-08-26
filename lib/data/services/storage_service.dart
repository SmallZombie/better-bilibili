import 'dart:io';

import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:better_bilibili/utils/platform_util.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gal/gal.dart';
import 'package:logger/logger.dart';

class StorageService {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'StorageService'));

  /// 保存一个网络图片到本地
  /// 对于移动端，他会尝试保存到相册
  /// 对于桌面端，他会尝试唤起路径选择器选择保存位置
  Future<Result<void>> saveNetworkImage(String url, String fileName, String fileExt) async {
    if (isMobile) {
      try {
        final imagePath = '${Directory.systemTemp.path}/$fileName.$fileExt';

        await Dio().download(url, imagePath);
        await Gal.putImage(imagePath);

        return Result.ok(null);
      } catch (e) {
        return Result.error(Exception(e));
      }
    } else if (isDesktop) {
      try {
        final dirPath = await FilePicker.getDirectoryPath();
        _log.i('User selected directory: $dirPath');

        await Dio().download(url, '$dirPath/$fileName.$fileExt');

        return Result.ok(null);
      } on Exception catch (e) {
        return Result.error(e);
      }
    } else {
      return Result.error(Exception('Unsupported platform'));
    }
  }
}
