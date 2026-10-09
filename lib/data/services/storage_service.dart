import 'dart:io';

import 'package:better_bilibili/utils/platform_util.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gal/gal.dart';

class StorageService {
  Future<String?> pickDirectory() {
    assert(isDesktop, 'You should not call pickDirectory on non-desktop platforms');
    return FilePicker.getDirectoryPath();
  }

  /// 保存一个网络图片到本地
  Future<Result<void>> saveNetworkImageForDesktop(String url, String dirPath, String fileName, String fileExt) async {
    assert(isDesktop, 'You should not call saveNetworkImageForDesktop on non-desktop platforms');

    try {
      await Dio().download(url, '$dirPath/$fileName.$fileExt');

      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  /// 保存一个网络图片到本地
  Future<Result<void>> saveNetworkImageForMobile(String url, String fileName, String fileExt) async {
    assert(isMobile, 'You should not call saveNetworkImageForMobile on non-mobile platforms');

    try {
      final imagePath = '${Directory.systemTemp.path}/$fileName.$fileExt';

      await Dio().download(url, imagePath);
      await Gal.putImage(imagePath);

      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e));
    }
  }
}
