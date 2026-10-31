import 'package:better_bilibili/hive/hive_adapters.dart';
import 'package:better_bilibili/utils/config/config_item.dart';
import 'package:hive_ce/hive.dart';

class AppConfig {
  final String appName;
  final String appPackageName;
  final String appVersion;
  final String appBuildNumber;

  late final Box box;
  late final Future init;

  AppConfig({
    required this.appName,
    required this.appPackageName,
    required this.appVersion,
    required this.appBuildNumber,
  }) {
    init = () async {
      Hive.registerAdapter(ViewOriginalImageEnumAdapter());
      box = await Hive.openBox('app_config');
    }();
  }

  void dispose() {
    viewOriginalImage.dispose();
  }

  late final viewOriginalImage = ConfigItem(box: box, key: 'view_original_image', defaultValue: ViewOriginalImageEnum.auto);
}

enum ViewOriginalImageEnum {
  auto,
  always,
  wifiOnly,
  never,
}
