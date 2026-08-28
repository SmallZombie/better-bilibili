import 'dart:async';

import 'package:better_bilibili/domain/models/bilibili/play_info.dart';
import 'package:logger/logger.dart';
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

const _volumeKey = 'player.volume';
const _preferredCodecKey = 'player.preferred_codec';
const _fallbackCodecKey = 'player.fallback_codec';
const _audioQualityKey = 'player.audio_quality';
const _videoQualityKey = 'player.video_quality';
const _autoPlayKey = 'player.auto_play';
const _loopPlaybackKey = 'player.loop_playback';
const _autoPlayNextEpisodeKey = 'player.auto_play_next_episode';
const _autoPlayNextPlaylistKey = 'player.auto_play_next_playlist';
const _autoPlayNextCollectionKey = 'player.auto_play_next_collection';
const _autoPlayNextRecommendKey = 'player.auto_play_next_recommend';
const _ambientLightKey = 'player.ambient_light';
const _historyReporterDebugHudKey = 'player.history_reporter_debug_hud';
const _mediaControlKey = 'player.media_control';
const _loudnessNormalizationKey = 'player.loudness_normalization';

class PlayerConfigStreams {
  final _volumeController = StreamController<double>.broadcast();
  final _preferredCodecController = StreamController<CodecEnum>.broadcast();
  final _fallbackCodecController = StreamController<CodecEnum>.broadcast();
  final _audioQualityController = StreamController<int>.broadcast();
  final _videoQualityController = StreamController<int>.broadcast();
  final _autoPlayController = StreamController<bool>.broadcast();
  final _loopPlaybackController = StreamController<bool>.broadcast();
  final _autoPlayNextEpisodeController = StreamController<bool>.broadcast();
  final _autoPlayNextPlaylistController = StreamController<bool>.broadcast();
  final _autoPlayNextCollectionController = StreamController<bool>.broadcast();
  final _autoPlayNextRecommendController = StreamController<bool>.broadcast();
  final _ambientLightController = StreamController<bool>.broadcast();
  final _historyReporterDebugHudController = StreamController<bool>.broadcast();
  final _mediaControlController = StreamController<bool>.broadcast();
  final _loudnessNormalizationController = StreamController<LoudnessNormalizationModeEnum>.broadcast();

  Stream<double> get volume => _volumeController.stream;
  Stream<CodecEnum> get preferredCodec => _preferredCodecController.stream;
  Stream<CodecEnum> get fallbackCodec => _fallbackCodecController.stream;
  Stream<int> get audioQuality => _audioQualityController.stream;
  Stream<int> get videoQuality => _videoQualityController.stream;
  Stream<bool> get autoPlay => _autoPlayController.stream;
  Stream<bool> get loopPlayback => _loopPlaybackController.stream;
  Stream<bool> get autoPlayNextEpisode => _autoPlayNextEpisodeController.stream;
  Stream<bool> get autoPlayNextPlaylist => _autoPlayNextPlaylistController.stream;
  Stream<bool> get autoPlayNextCollection => _autoPlayNextCollectionController.stream;
  Stream<bool> get autoPlayNextRecommend => _autoPlayNextRecommendController.stream;
  Stream<bool> get ambientLight => _ambientLightController.stream;
  Stream<bool> get historyReporterDebugHud => _historyReporterDebugHudController.stream;
  Stream<bool> get mediaControl => _mediaControlController.stream;
  Stream<LoudnessNormalizationModeEnum> get loudnessNormalization => _loudnessNormalizationController.stream;

  void dispose() {
    _volumeController.close();
    _preferredCodecController.close();
    _fallbackCodecController.close();
    _audioQualityController.close();
    _videoQualityController.close();
    _autoPlayController.close();
    _loopPlaybackController.close();
    _autoPlayNextEpisodeController.close();
    _autoPlayNextPlaylistController.close();
    _autoPlayNextCollectionController.close();
    _autoPlayNextRecommendController.close();
    _ambientLightController.close();
    _historyReporterDebugHudController.close();
    _mediaControlController.close();
    _loudnessNormalizationController.close();
  }
}

class PlayerConfig {
  final Logger _log = Logger();
  final prefs = SharedPreferencesAsync();

  final stream = PlayerConfigStreams();

  Future<void>? _initialized;

  late double volume;
  late CodecEnum preferredCodec;
  late CodecEnum fallbackCodec;
  late int audioQuality;
  late int videoQuality;
  late bool autoPlay;
  late bool loopPlayback;
  late bool autoPlayNextEpisode;
  late bool autoPlayNextPlaylist;
  late bool autoPlayNextCollection;
  late bool autoPlayNextRecommend;
  late bool ambientLight;
  late bool historyReporterDebugHud;
  late bool mediaControl;
  late LoudnessNormalizationModeEnum loudnessNormalization;

  Future<void> ensureInitialized() async {
    _initialized ??= _init();
    await _initialized;
  }

  Future<void> _init() async {
    volume = await prefs.getDouble(_volumeKey) ?? 50;

    // 观感目前测试下来是 264(7) > 265(12) > av1(13)
    // 但因为264不给8k流，所以这里首选265
    String? preferredCodecStr = await prefs.getString(_preferredCodecKey);
    preferredCodec = preferredCodecStr != null ? CodecEnum.fromString(preferredCodecStr) : CodecEnum.h265;

    String? fallbackCodecStr = await prefs.getString(_fallbackCodecKey);
    fallbackCodec = fallbackCodecStr != null ? CodecEnum.fromString(fallbackCodecStr) : CodecEnum.h264;

    audioQuality = await prefs.getInt(_audioQualityKey) ?? 40251;
    videoQuality = await prefs.getInt(_videoQualityKey) ?? 129;

    loopPlayback = await prefs.getBool(_loopPlaybackKey) ?? false;
    autoPlay = await prefs.getBool(_autoPlayKey) ?? true;
    autoPlayNextEpisode = await prefs.getBool(_autoPlayNextEpisodeKey) ?? true;
    autoPlayNextPlaylist = await prefs.getBool(_autoPlayNextPlaylistKey) ?? true;
    autoPlayNextCollection = await prefs.getBool(_autoPlayNextCollectionKey) ?? false;
    autoPlayNextRecommend = await prefs.getBool(_autoPlayNextRecommendKey) ?? false;
    ambientLight = await prefs.getBool(_ambientLightKey) ?? true;

    historyReporterDebugHud = await prefs.getBool(_historyReporterDebugHudKey) ?? false;

    mediaControl = await prefs.getBool(_mediaControlKey) ?? true;

    int? loudnessNormalizationInt = await prefs.getInt(_loudnessNormalizationKey);
    loudnessNormalization = loudnessNormalizationInt != null ? LoudnessNormalizationModeEnum.fromInt(loudnessNormalizationInt) : .normal;

    stream._volumeController.add(volume);
    stream._preferredCodecController.add(preferredCodec);
    stream._fallbackCodecController.add(fallbackCodec);
    stream._audioQualityController.add(audioQuality);
    stream._videoQualityController.add(videoQuality);
    stream._autoPlayController.add(autoPlay);
    stream._loopPlaybackController.add(loopPlayback);
    stream._autoPlayNextEpisodeController.add(autoPlayNextEpisode);
    stream._autoPlayNextPlaylistController.add(autoPlayNextPlaylist);
    stream._autoPlayNextCollectionController.add(autoPlayNextCollection);
    stream._autoPlayNextRecommendController.add(autoPlayNextRecommend);
    stream._ambientLightController.add(ambientLight);
    stream._historyReporterDebugHudController.add(historyReporterDebugHud);
    stream._mediaControlController.add(mediaControl);
    stream._loudnessNormalizationController.add(loudnessNormalization);
  }

  void dispose() {
    stream.dispose();
  }

  Future<void> setVolume(double newValue) async {
    assert(newValue >= 0 && newValue <= 100);
    volume = newValue;
    stream._volumeController.add(newValue);

    try {
      await prefs.setDouble(_volumeKey, newValue);
    } catch (e, s) {
      _log.e(
        'Config save failed: key=$_volumeKey, newValue=$newValue',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> setPreferredCodec(CodecEnum newValue) async {
    preferredCodec = newValue;
    stream._preferredCodecController.add(newValue);

    try {
      await prefs.setString(_preferredCodecKey, newValue.value);
    } catch (e, s) {
      _log.e(
        'Config save failed: key=$_preferredCodecKey, newValue=$newValue',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> setFallbackCodec(CodecEnum newValue) async {
    fallbackCodec = newValue;
    stream._fallbackCodecController.add(newValue);

    try {
      await prefs.setString(_fallbackCodecKey, newValue.value);
    } catch (e, s) {
      _log.e(
        'Config save failed: key=$_fallbackCodecKey, newValue=$newValue',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> setAudioQuality(int newValue) async {
    assert(newValue > 0);
    audioQuality = newValue;
    stream._audioQualityController.add(newValue);

    try {
      await prefs.setInt(_audioQualityKey, newValue);
    } catch (e, s) {
      _log.e(
        'Config save failed: key=$_audioQualityKey, newValue=$newValue',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> setVideoQuality(int newValue) async {
    assert(newValue > 0);
    videoQuality = newValue;
    stream._videoQualityController.add(newValue);

    try {
      await prefs.setInt(_videoQualityKey, newValue);
    } catch (e, s) {
      _log.e(
        'Config save failed: key=$_videoQualityKey, newValue=$newValue',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> setLoopPlayback(bool newValue) async {
    loopPlayback = newValue;
    stream._loopPlaybackController.add(newValue);

    try {
      await prefs.setBool(_loopPlaybackKey, newValue);
    } catch (e, s) {
      _log.e(
        'Config save failed: key=$_loopPlaybackKey, newValue=$newValue',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> setAutoPlayNextEpisode(bool newValue) async {
    autoPlayNextEpisode = newValue;
    stream._autoPlayNextEpisodeController.add(newValue);

    try {
      await prefs.setBool(_autoPlayNextEpisodeKey, newValue);
    } catch (e, s) {
      _log.e(
        'Config save failed: key=$_autoPlayNextEpisodeKey, newValue=$newValue',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> setAutoPlayNextPlaylist(bool newValue) async {
    autoPlayNextPlaylist = newValue;
    stream._autoPlayNextPlaylistController.add(newValue);

    try {
      await prefs.setBool(_autoPlayNextPlaylistKey, newValue);
    } catch (e, s) {
      _log.e(
        'Config save failed: key=$_autoPlayNextPlaylistKey, newValue=$newValue',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> setAutoPlayNextCollection(bool newValue) async {
    autoPlayNextCollection = newValue;
    stream._autoPlayNextCollectionController.add(newValue);

    try {
      await prefs.setBool(_autoPlayNextCollectionKey, newValue);
    } catch (e, s) {
      _log.e(
        'Config save failed: key=$_autoPlayNextCollectionKey, newValue=$newValue',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> setAutoPlayNextRecommend(bool newValue) async {
    autoPlayNextRecommend = newValue;
    stream._autoPlayNextRecommendController.add(newValue);

    try {
      await prefs.setBool(_autoPlayNextRecommendKey, newValue);
    } catch (e, s) {
      _log.e(
        'Config save failed: key=$_autoPlayNextRecommendKey, newValue=$newValue',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> setAutoPlay(bool newValue) async {
    autoPlay = newValue;
    stream._autoPlayController.add(newValue);

    try {
      await prefs.setBool(_autoPlayKey, newValue);
    } catch (e, s) {
      _log.e(
        'Config save failed: key=$_autoPlayKey, newValue=$newValue',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> setAmbientLight(bool newValue) async {
    ambientLight = newValue;
    stream._ambientLightController.add(newValue);

    try {
      await prefs.setBool(_ambientLightKey, newValue);
    } catch (e, s) {
      _log.e(
        'Config save failed: key=$_ambientLightKey, newValue=$newValue',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> setHistoryReporterDebugHud(bool newValue) async {
    historyReporterDebugHud = newValue;
    stream._historyReporterDebugHudController.add(newValue);

    try {
      await prefs.setBool(_historyReporterDebugHudKey, newValue);
    } catch (e, s) {
      _log.e(
        'Config save failed: key=$_historyReporterDebugHudKey, newValue=$newValue',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> setMediaControl(bool newValue) async {
    mediaControl = newValue;
    stream._mediaControlController.add(newValue);

    try {
      await prefs.setBool(_mediaControlKey, newValue);
    } catch (e, s) {
      _log.e(
        'Config save failed: key=$_mediaControlKey, newValue=$newValue',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> setLoudnessNormalization(LoudnessNormalizationModeEnum newValue) async {
    loudnessNormalization = newValue;
    stream._loudnessNormalizationController.add(newValue);

    try {
      await prefs.setInt(_loudnessNormalizationKey, newValue.value);
    } catch (e, s) {
      _log.e(
        'Config save failed: key=$_loudnessNormalizationKey, newValue=$newValue',
        error: e,
        stackTrace: s,
      );
    }
  }
}
