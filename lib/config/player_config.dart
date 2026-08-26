import 'package:better_bilibili/domain/models/bilibili/play_info.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _volumeKey = 'player.volume';
const _preferredCodecKey = 'player.preferred_codec';
const _fallbackCodecKey = 'player.preferred_codec';
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

class PlayerConfig extends ChangeNotifier {
  final Logger _log = Logger();
  final prefs = SharedPreferencesAsync();

  Future? _initialized;

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

  Future<void> ensureInitialized() async {
    _initialized ??= _init();
    await _init();
  }

  Future<void> _init() async {
    volume = await prefs.getDouble(_volumeKey) ?? 50;

    // 观感目前测试下来是 264(7) > 265(12) > av1(13)
    // 但因为264不给8k流，所以这里首选265
    String? preferredCodecStr = await prefs.getString(_preferredCodecKey);
    preferredCodec = preferredCodecStr == null ? CodecEnum.h265 : CodecEnum.fromString(preferredCodecStr);

    String? fallbackCodecStr = await prefs.getString(_fallbackCodecKey);
    preferredCodec = fallbackCodecStr == null ? CodecEnum.h264 : CodecEnum.fromString(fallbackCodecStr);

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
  }

  Future<void> setVolume(double newValue) async {
    assert(newValue >= 0 && newValue <= 100);
    volume = newValue;
    notifyListeners();

    try {
      await prefs.setDouble(_volumeKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_volumeKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setPreferredCodec(CodecEnum newValue) async {
    preferredCodec = newValue;
    notifyListeners();

    try {
      await prefs.setString(_preferredCodecKey, newValue.value);
    } catch (e, s) {
      _log.e('Config save failed: key=$_preferredCodecKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setFallbackCodec(CodecEnum newValue) async {
    fallbackCodec = newValue;
    notifyListeners();

    try {
      await prefs.setString(_fallbackCodecKey, newValue.value);
    } catch (e, s) {
      _log.e('Config save failed: key=$_fallbackCodecKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setAudioQuality(int newValue) async {
    assert(newValue > 0);
    audioQuality = newValue;
    notifyListeners();

    try {
      await prefs.setInt(_audioQualityKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_audioQualityKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setVideoQuality(int newValue) async {
    assert(newValue > 0);
    videoQuality = newValue;
    notifyListeners();

    try {
      await prefs.setInt(_videoQualityKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_videoQualityKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setLoopPlayback(bool newValue) async {
    loopPlayback = newValue;
    notifyListeners();

    try {
      await prefs.setBool(_loopPlaybackKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_loopPlaybackKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setAutoPlayNextEpisode(bool newValue) async {
    autoPlayNextEpisode = newValue;
    notifyListeners();

    try {
      await prefs.setBool(_autoPlayNextEpisodeKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_autoPlayNextEpisodeKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setAutoPlayNextPlaylist(bool newValue) async {
    autoPlayNextPlaylist = newValue;
    notifyListeners();

    try {
      await prefs.setBool(_autoPlayNextPlaylistKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_autoPlayNextPlaylistKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setAutoPlayNextCollection(bool newValue) async {
    autoPlayNextCollection = newValue;
    notifyListeners();

    try {
      await prefs.setBool(_autoPlayNextCollectionKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_autoPlayNextCollectionKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setAutoPlayNextRecommend(bool newValue) async {
    autoPlayNextRecommend = newValue;
    notifyListeners();

    try {
      await prefs.setBool(_autoPlayNextRecommendKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_autoPlayNextRecommendKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setAutoPlay(bool newValue) async {
    autoPlay = newValue;
    notifyListeners();

    try {
      await prefs.setBool(_autoPlayKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_autoPlayKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setAmbientLight(bool newValue) async {
    ambientLight = newValue;
    notifyListeners();

    try {
      await prefs.setBool(_ambientLightKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_ambientLightKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setHistoryReporterDebugHud(bool newValue) async {
    historyReporterDebugHud = newValue;
    notifyListeners();

    try {
      await prefs.setBool(_historyReporterDebugHudKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_historyReporterDebugHudKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }
}
