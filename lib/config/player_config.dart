import 'package:better_bilibili/domain/models/bilibili/play_info.dart';
import 'package:better_bilibili/hive/hive_adapters.dart';
import 'package:better_bilibili/utils/config/config_item.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

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
  late final Box box;
  late final Future init;

  PlayerConfig() {
    init = () async {
      Hive.registerAdapter(CodecEnumAdapter());
      box = await Hive.openBox('player_config');
    }();
  }

  late final ConfigItem<double> volume = ConfigItem(
    box: box,
    key: 'player.volume',
    defaultValue: 50,
  );
  late final ConfigItem<bool> muted = ConfigItem(
    box: box,
    key: 'player.muted',
    defaultValue: false,
  );
  // 观感目前测试下来是 264(7) > 265(12) > av1(13)
  // 但因为264不给8k流，所以这里首选265
  late final ConfigItem<CodecEnum> preferredCodec = ConfigItem(
    box: box,
    key: 'player.preferred_codec',
    defaultValue: .h265,
  );
  late final ConfigItem<CodecEnum> fallbackCodec = ConfigItem(
    box: box,
    key: 'player.fallback_codec',
    defaultValue: .h264,
  );
  late final ConfigItem<int> audioQuality = ConfigItem(
    box: box,
    key: 'player.audio_quality',
    defaultValue: 40251,
  );
  late final ConfigItem<int> videoQuality = ConfigItem(
    box: box,
    key: 'player.video_quality',
    defaultValue: 129,
  );
  late final ConfigItem<bool> autoPlay = ConfigItem(
    box: box,
    key: 'player.auto_play',
    defaultValue: true,
  );
  late final ConfigItem<bool> loopPlayback = ConfigItem(
    box: box,
    key: 'player.loop_playback',
    defaultValue: false,
  );
  late final ConfigItem<bool> autoPlayNextEpisode = ConfigItem(
    box: box,
    key: 'player.auto_play_next_episode',
    defaultValue: true,
  );
  late final ConfigItem<bool> autoPlayNextPlaylist = ConfigItem(
    box: box,
    key: 'player.auto_play_next_playlist',
    defaultValue: true,
  );
  late final ConfigItem<bool> autoPlayNextCollection = ConfigItem(
    box: box,
    key: 'player.auto_play_next_collection',
    defaultValue: false,
  );
  late final ConfigItem<bool> autoPlayNextRecommend = ConfigItem(
    box: box,
    key: 'player.auto_play_next_recommend',
    defaultValue: false,
  );
  late final ConfigItem<bool> ambientLight = ConfigItem(
    box: box,
    key: 'player.ambient_light',
    defaultValue: true,
  );
  late final ConfigItem<bool> historyReporterDebugHud = ConfigItem(
    box: box,
    key: 'player.history_reporter_debug_hud',
    defaultValue: false,
  );
  late final ConfigItem<bool> mediaControl = ConfigItem(
    box: box,
    key: 'player.media_control',
    defaultValue: true,
  );
  late final ConfigItem<LoudnessNormalizationModeEnum> loudnessNormalization = ConfigItem(
    box: box,
    key: 'player.loudness_normalization',
    defaultValue: .off,
  );
  late final ConfigItem<bool> heatWaveforms = ConfigItem(
    box: box,
    key: 'player.heat_waveforms',
    defaultValue: true,
  );
  late final ConfigItem<bool> hideMediaControlInfo = ConfigItem(
    box: box,
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
