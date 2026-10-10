import 'package:better_bilibili/utils/config/config_item.dart';
import 'package:hive_ce/hive_ce.dart';

class DanmakuConfig {
  late final Box box;
  late final Future init;

  DanmakuConfig() {
    init = () async {
      box = await Hive.openBox('danmaku_config');
    }();
  }

  void dispose() {
    enabled.dispose();
    showScroll.dispose();
    showTop.dispose();
    showBottom.dispose();
    showAdvanced.dispose();
    displayArea.dispose();
    fixedDisplayArea.dispose();
    opacity.dispose();
    fontSize.dispose();
    scrollSpeed.dispose();
    syncPlaybackRate.dispose();
    antiOcclusion.dispose();
    carnivalMode.dispose();
    duplicateMerge.dispose();
  }

  late final enabled = ConfigItem(box: box, key: 'enabled', defaultValue: true);
  late final showScroll = ConfigItem(box: box, key: 'show_scroll', defaultValue: true);
  late final showTop = ConfigItem(box: box, key: 'show_top', defaultValue: true);
  late final showBottom = ConfigItem(box: box, key: 'show_bottom', defaultValue: true);
  late final showAdvanced = ConfigItem(box: box, key: 'show_advanced', defaultValue: true);

  late final displayArea = ConfigItem(box: box, key: 'display_area', defaultValue: 0.3);
  late final fixedDisplayArea = ConfigItem(box: box, key: 'fixed_display_area', defaultValue: 0.3);
  late final opacity = ConfigItem(box: box, key: 'opacity', defaultValue: 0.8);
  late final fontSize = ConfigItem(box: box, key: 'font_size', defaultValue: 1.0);
  late final scrollSpeed = ConfigItem(box: box, key: 'scroll_speed', defaultValue: 1.0);
  late final syncPlaybackRate = ConfigItem(box: box, key: 'sync_playback_rate', defaultValue: true);
  late final antiOcclusion = ConfigItem(box: box, key: 'anti_occlusion', defaultValue: false);
  late final carnivalMode = ConfigItem(box: box, key: 'carnival_mode', defaultValue: false);
  late final duplicateMerge = ConfigItem(box: box, key: 'duplicate_merge', defaultValue: false);
}
