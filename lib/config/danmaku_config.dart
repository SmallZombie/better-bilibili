import 'package:better_bilibili/config/adapter/config_prefs_storage.dart';
import 'package:better_bilibili/utils/config_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DanmakuConfig {
  late final prefs = ConfigPrefsStorage(prefs: SharedPreferencesAsync());

  late final ConfigItem<bool> enabled = ConfigItem(storage: prefs, key: 'danmaku.enabled', defaultValue: true);
  late final ConfigItem<bool> showScroll = ConfigItem(storage: prefs, key: 'danmaku.show_scroll', defaultValue: true);
  late final ConfigItem<bool> showTop = ConfigItem(storage: prefs, key: 'danmaku.show_top', defaultValue: true);
  late final ConfigItem<bool> showBottom = ConfigItem(storage: prefs, key: 'danmaku.show_bottom', defaultValue: true);
  late final ConfigItem<bool> showAdvanced = ConfigItem(storage: prefs, key: 'danmaku.show_advanced', defaultValue: true);

  late final ConfigItem<double> displayArea = ConfigItem(storage: prefs, key: 'danmaku.display_area', defaultValue: 0.3);
  late final ConfigItem<double> fixedDisplayArea = ConfigItem(storage: prefs, key: 'danmaku.fixed_display_area', defaultValue: 0.3);
  late final ConfigItem<double> opacity = ConfigItem(storage: prefs, key: 'danmaku.opacity', defaultValue: 0.8);
  late final ConfigItem<double> fontSize = ConfigItem(storage: prefs, key: 'danmaku.font_size', defaultValue: 1.0);
  late final ConfigItem<double> scrollSpeed = ConfigItem(storage: prefs, key: 'danmaku.scroll_speed', defaultValue: 1.0);
  late final ConfigItem<bool> syncPlaybackRate = ConfigItem(storage: prefs, key: 'danmaku.sync_playback_rate', defaultValue: true);
  late final ConfigItem<bool> antiOcclusion = ConfigItem(storage: prefs, key: 'danmaku.anti_occlusion', defaultValue: false);
  late final ConfigItem<bool> carnivalMode = ConfigItem(storage: prefs, key: 'danmaku.carnival_mode', defaultValue: false);
  late final ConfigItem<bool> duplicateMerge = ConfigItem(storage: prefs, key: 'danmaku.duplicate_merge', defaultValue: false);

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
