import 'package:better_bilibili/config/adapter/config_prefs_storage.dart';
import 'package:better_bilibili/domain/models/bilibili/play_info.dart';
import 'package:better_bilibili/utils/config_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LoudnessNormalizationModeEnum {
  off(0),
  normal(1),
  highDynamic(2);

  final int value;

  const LoudnessNormalizationModeEnum(this.value);

  factory LoudnessNormalizationModeEnum.fromInt(int num) {
    return switch (num) {
      2 => .highDynamic,
      _ => .normal,
    };
  }
}

class PlayerConfig {
  final ConfigPrefsStorage prefs = ConfigPrefsStorage(prefs: SharedPreferencesAsync());

  late final ConfigItem<double> volume = ConfigItem(
    storage: prefs,
    key: 'player.volume',
    defaultValue: 50,
  );
  late final ConfigItem<bool> muted = ConfigItem(
    storage: prefs,
    key: 'player.muted',
    defaultValue: false,
  );
  // 观感目前测试下来是 264(7) > 265(12) > av1(13)
  // 但因为264不给8k流，所以这里首选265
  late final ConfigItem<CodecEnum> preferredCodec = ConfigItem(
    storage: prefs,
    key: 'player.preferred_codec',
    defaultValue: .h265,
    deserialization: (data) => CodecEnum.fromString(data),
  );
  late final ConfigItem<CodecEnum> fallbackCodec = ConfigItem(
    storage: prefs,
    key: 'player.fallback_codec',
    defaultValue: .h264,
    deserialization: (data) => CodecEnum.fromString(data),
  );
  late final ConfigItem<int> audioQuality = ConfigItem(
    storage: prefs,
    key: 'player.audio_quality',
    defaultValue: 40251,
  );
  late final ConfigItem<int> videoQuality = ConfigItem(
    storage: prefs,
    key: 'player.video_quality',
    defaultValue: 129,
  );
  late final ConfigItem<bool> autoPlay = ConfigItem(
    storage: prefs,
    key: 'player.auto_play',
    defaultValue: true,
  );
  late final ConfigItem<bool> loopPlayback = ConfigItem(
    storage: prefs,
    key: 'player.loop_playback',
    defaultValue: false,
  );
  late final ConfigItem<bool> autoPlayNextEpisode = ConfigItem(
    storage: prefs,
    key: 'player.auto_play_next_episode',
    defaultValue: true,
  );
  late final ConfigItem<bool> autoPlayNextPlaylist = ConfigItem(
    storage: prefs,
    key: 'player.auto_play_next_playlist',
    defaultValue: true,
  );
  late final ConfigItem<bool> autoPlayNextCollection = ConfigItem(
    storage: prefs,
    key: 'player.auto_play_next_collection',
    defaultValue: false,
  );
  late final ConfigItem<bool> autoPlayNextRecommend = ConfigItem(
    storage: prefs,
    key: 'player.auto_play_next_recommend',
    defaultValue: false,
  );
  late final ConfigItem<bool> ambientLight = ConfigItem(
    storage: prefs,
    key: 'player.ambient_light',
    defaultValue: true,
  );
  late final ConfigItem<bool> historyReporterDebugHud = ConfigItem(
    storage: prefs,
    key: 'player.history_reporter_debug_hud',
    defaultValue: false,
  );
  late final ConfigItem<bool> mediaControl = ConfigItem(
    storage: prefs,
    key: 'player.media_control',
    defaultValue: true,
  );
  late final ConfigItem<LoudnessNormalizationModeEnum> loudnessNormalization = ConfigItem(
    storage: prefs,
    key: 'player.loudness_normalization',
    defaultValue: .off,
  );
  late final ConfigItem<bool> heatWaveforms = ConfigItem(
    storage: prefs,
    key: 'player.heat_waveforms',
    defaultValue: true,
  );
  late final ConfigItem<bool> hideMediaControlInfo = ConfigItem(
    storage: prefs,
    key: 'player.hide_media_control_info',
    defaultValue: false,
  );

  void dispose() {
    volume.dispose();
    muted.dispose();
    preferredCodec.dispose();
    fallbackCodec.dispose();
    audioQuality.dispose();
    videoQuality.dispose();
    autoPlay.dispose();
    loopPlayback.dispose();
    autoPlayNextEpisode.dispose();
    autoPlayNextPlaylist.dispose();
    autoPlayNextCollection.dispose();
    autoPlayNextRecommend.dispose();
    ambientLight.dispose();
    historyReporterDebugHud.dispose();
    mediaControl.dispose();
    loudnessNormalization.dispose();
    heatWaveforms.dispose();
    hideMediaControlInfo.dispose();
  }
}
