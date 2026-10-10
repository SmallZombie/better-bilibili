import 'package:better_bilibili/data/services/storage_service.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/utils/platform_util.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

extension SaveImage on BuildContext {
  Future<void> saveImage(String url, String fileName, String fileExt) async {
    assert(!kIsWeb, 'Unsupported platform: Web');

    try {
      if (isDesktop) {
        final storageService = read<StorageService>();

        final dirPath = await storageService.pickDirectory();
        if (dirPath == null) return;

        final result = await storageService.saveNetworkImageForDesktop(url, dirPath, fileName, fileExt);

        if (!mounted) return;

        switch (result) {
          case Ok():
            showInfo('已保存');
          case Error():
            showError('保存失败: ${result.error.toString()}');
        }
      } else if (isMobile) {
        final storageService = read<StorageService>();
        final result = await storageService.saveNetworkImageForMobile(url, fileName, fileExt);

        if (!mounted) return;

        switch (result) {
          case Ok():
            showInfo('已保存');
          case Error():
            showError('保存失败: ${result.error.toString()}');
        }
      } else {
        showError('不受支持的平台');
      }
    } on Exception {
      return showError('服务不可用');
    }
  }

  Future<void> saveImages(List<String> urls, List<String> fileNames, List<String> fileExts) async {
    assert(!kIsWeb, 'Unsupported platform: Web');
    assert(urls.length == fileNames.length && fileNames.length == fileExts.length);

    try {
      if (isDesktop) {
        final storageService = read<StorageService>();
        final List<Future> futures = [];

        final dirPath = await storageService.pickDirectory();
        if (dirPath == null) return;

        for (int i = 0; i < urls.length; i++) {
          final url = urls[i];
          final name = fileNames[i];
          final ext = fileExts[i];

          futures.add(storageService.saveNetworkImageForDesktop(url, dirPath, name, ext));
        }

        final results = await Future.wait(futures);

        if (!mounted) return;

        for (final i in results) {
          if (i is Error) showError('保存时发生错误: ${i.error.toString()}');
        }

        if (results.every((v) => v is Ok)) {
          showInfo('已全部保存');
        }
      } else if (isMobile) {
        final storageService = read<StorageService>();
        final List<Future> futures = [];

        for (int i = 0; i < urls.length; i++) {
          final url = urls[i];
          final name = fileNames[i];
          final ext = fileExts[i];

          futures.add(storageService.saveNetworkImageForMobile(url, name, ext));
        }

        if (!mounted) return;

        final results = await Future.wait(futures);
        for (final i in results) {
          if (i is Error) showError('保存时发生错误: ${i.error.toString()}');
        }

        if (results.every((v) => v is Ok)) {
          showInfo('已全部保存');
        }
      } else {
        showError('不受支持的平台');
      }
    } on Exception {
      return showError('服务不可用');
    }
  }
}
