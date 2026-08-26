import 'package:better_bilibili/data/services/storage_service.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

extension SaveImage on BuildContext {
  Future<void> saveImage(String url, String fileName, String fileExt) async {
    if (kIsWeb) {
      return showInfo('不支持的平台: Web');
    }

    try {
      final storageService = read<StorageService>();
      final result = await storageService.saveNetworkImage(url, fileName, fileExt);

      if (!mounted) {
        return;
      }

      switch (result) {
        case Ok():
          showInfo('已保存');
        case Error():
          showError('保存失败: ${result.error.toString()}');
      }
    } on Exception {
      return showError('服务不可用');
    }
  }
}
