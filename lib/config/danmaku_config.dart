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

  late final ConfigItem<bool> enabled = ConfigItem(box: box, key: 'danmaku.enabled', defaultValue: true);
  late final ConfigItem<bool> showScroll = ConfigItem(box: box, key: 'danmaku.show_scroll', defaultValue: true);
  late final ConfigItem<bool> showTop = ConfigItem(box: box, key: 'danmaku.show_top', defaultValue: true);
  late final ConfigItem<bool> showBottom = ConfigItem(box: box, key: 'danmaku.show_bottom', defaultValue: true);
  late final ConfigItem<bool> showAdvanced = ConfigItem(box: box, key: 'danmaku.show_advanced', defaultValue: true);

  late final ConfigItem<double> displayArea = ConfigItem(box: box, key: 'danmaku.display_area', defaultValue: 0.3);
  late final ConfigItem<double> fixedDisplayArea = ConfigItem(box: box, key: 'danmaku.fixed_display_area', defaultValue: 0.3);
  late final ConfigItem<double> opacity = ConfigItem(box: box, key: 'danmaku.opacity', defaultValue: 0.8);
  late final ConfigItem<double> fontSize = ConfigItem(box: box, key: 'danmaku.font_size', defaultValue: 1.0);
  late final ConfigItem<double> scrollSpeed = ConfigItem(box: box, key: 'danmaku.scroll_speed', defaultValue: 1.0);
  late final ConfigItem<bool> syncPlaybackRate = ConfigItem(box: box, key: 'danmaku.sync_playback_rate', defaultValue: true);
  late final ConfigItem<bool> antiOcclusion = ConfigItem(box: box, key: 'danmaku.anti_occlusion', defaultValue: false);
  late final ConfigItem<bool> carnivalMode = ConfigItem(box: box, key: 'danmaku.carnival_mode', defaultValue: false);
  late final ConfigItem<bool> duplicateMerge = ConfigItem(box: box, key: 'danmaku.duplicate_merge', defaultValue: false);

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
}
