import 'dart:convert';
import 'dart:io';

import 'package:better_bilibili/config/constants.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

/// 配置基类
abstract class BaseConfig<T> {
  final Logger _log = Logger('BaseConfig<$T>');

  final String fileName;
  T data;

  BaseConfig({required this.fileName, required this.data});

  T fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson(T data);

  /// 根据平台获取配置文件路径，如果不支持则返回 null
  Future<String?> _getConfigPath() async {
    if (Platform.isAndroid) {
      return join((await getExternalStorageDirectory())!.path, fileName);
    } else if (Platform.isWindows) {
      final appdata = Platform.environment['APPDATA'];
      if (appdata == null) return null;
      return join(appdata, kAppId, fileName);
    }
    return null;
  }

  Future<void> load() async {
    try {
      final path = await _getConfigPath();
      if (path == null) {
        _log.info('Load by default in memory: $path');
        return;
      }

      final file = File(path);
      if (await file.exists()) {
        _log.info('Load by exists: $path');
        final content = await file.readAsString();
        data = fromJson(jsonDecode(content) as Map<String, dynamic>);
      } else {
        _log.info('Load by default: $path');
        await save();
      }
    } catch (e) {
      _log.severe('Load failed: $fileName', e);
      await save();
    }
  }

  Future<void> save() async {
    final path = await _getConfigPath();
    if (path == null) {
      _log.info('Skip save: $path');
      return;
    }

    _log.info('Save: $path');
    final file = File(path);

    // 确保父目录存在
    await file.parent.create(recursive: true);

    // 序列化并保存
    final json = toJson(data);
    final jsonString = const JsonEncoder.withIndent('  ').convert(json);
    await file.writeAsString(jsonString);
  }
}
