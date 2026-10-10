import 'package:better_bilibili/domain/models/bilibili/play_info.dart';
import 'package:better_bilibili/hive/hive_adapters.dart';
import 'package:better_bilibili/utils/config/config_item.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class PlayerConfig {
  late final Box box;
  late final Future init;

  PlayerConfig() {
    init = () async {
      Hive.registerAdapter(CodecEnumAdapter());
      Hive.registerAdapter(LoudnessNormalizationEnumAdapter());
      box = await Hive.openBox('player_config');
    }();
  }

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
    historyReporterDebugOverlay.dispose();
    mediaControl.dispose();
    loudnessNormalization.dispose();
    heatWaveforms.dispose();
    hideMediaControlInfo.dispose();
  }

  late final volume = ConfigItem(box: box, key: 'volume', defaultValue: 50.0);
  late final muted = ConfigItem(box: box, key: 'muted', defaultValue: false);
  // 观感目前测试下来是 264(7) > 265(12) > av1(13)
  // 但因为264不给8k流，所以这里首选265
  late final preferredCodec = ConfigItem(box: box, key: 'preferred_codec', defaultValue: CodecEnum.h265);
  late final fallbackCodec = ConfigItem(box: box, key: 'fallback_codec', defaultValue: CodecEnum.h264);
  late final audioQuality = ConfigItem(box: box, key: 'audio_quality', defaultValue: 40251);
  late final videoQuality = ConfigItem(box: box, key: 'video_quality', defaultValue: 129);
  late final autoPlay = ConfigItem(box: box, key: 'auto_play', defaultValue: true);
  late final loopPlayback = ConfigItem(box: box, key: 'loop_playback', defaultValue: false);
  late final autoPlayNextEpisode = ConfigItem(box: box, key: 'auto_play_next_episode', defaultValue: true);
  late final autoPlayNextPlaylist = ConfigItem(box: box, key: 'auto_play_next_playlist', defaultValue: true);
  late final autoPlayNextCollection = ConfigItem(box: box, key: 'auto_play_next_collection', defaultValue: false);
  late final autoPlayNextRecommend = ConfigItem(box: box, key: 'auto_play_next_recommend', defaultValue: false);
  late final ambientLight = ConfigItem(box: box, key: 'ambient_light', defaultValue: true);
  late final historyReporterDebugOverlay = ConfigItem(box: box, key: 'history_reporter_debug_overlay', defaultValue: false);
  late final mediaControl = ConfigItem(box: box, key: 'media_control', defaultValue: true);
  late final loudnessNormalization = ConfigItem(
    box: box,
    key: 'loudness_normalization',
    defaultValue: LoudnessNormalizationEnum.off,
  );
  late final heatWaveforms = ConfigItem(box: box, key: 'heat_waveforms', defaultValue: true);
  late final hideMediaControlInfo = ConfigItem(box: box, key: 'hide_media_control_info', defaultValue: false);
}

enum LoudnessNormalizationEnum {
  off,
  normal,
  highDynamic,
}
