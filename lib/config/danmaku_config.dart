import 'dart:async';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefixKey = 'danmaku';

const _enabledKey = '$_prefixKey.enabled';
const _showScrollKey = '$_prefixKey.show_scroll';
const _showTopKey = '$_prefixKey.show_top';
const _showBottomKey = '$_prefixKey.show_bottom';
const _showAdvancedKey = '$_prefixKey.show_advanced';

const _displayAreaKey = '$_prefixKey.display_area';
const _fixedDisplayAreaKey = '$_prefixKey.fixed_display_area';
const _opacityKey = '$_prefixKey.opacity';
const _fontSizeKey = '$_prefixKey.font_size';
const _scrollSpeedKey = '$_prefixKey.scroll_speed';
const _syncPlaybackRateKey = '$_prefixKey.sync_playback_rate';
const _antiOcclusionKey = '$_prefixKey.anti_occlusion';
const _carnivalModeKey = '$_prefixKey.carnival_mode';
const _duplicateMergeKey = '$_prefixKey.duplicate_merge';

class DanmakuConfigStreams {
  final _enabledController = StreamController<bool>.broadcast();
  final _showScrollController = StreamController<bool>.broadcast();
  final _showTopController = StreamController<bool>.broadcast();
  final _showBottomController = StreamController<bool>.broadcast();
  final _showAdvancedController = StreamController<bool>.broadcast();

  final _displayAreaController = StreamController<double>.broadcast();
  final _fixedDisplayAreaController = StreamController<double>.broadcast();
  final _opacityController = StreamController<double>.broadcast();
  final _fontSizeController = StreamController<double>.broadcast();
  final _scrollSpeedController = StreamController<double>.broadcast();
  final _syncPlaybackRateController = StreamController<bool>.broadcast();
  final _antiOcclusionController = StreamController<bool>.broadcast();
  final _carnivalModeController = StreamController<bool>.broadcast();
  final _duplicateMergeController = StreamController<bool>.broadcast();

  Stream<bool> get enabled => _enabledController.stream;
  Stream<bool> get showScroll => _showScrollController.stream;
  Stream<bool> get showTop => _showTopController.stream;
  Stream<bool> get showBottom => _showBottomController.stream;
  Stream<bool> get showAdvanced => _showAdvancedController.stream;

  Stream<double> get displayArea => _displayAreaController.stream;
  Stream<double> get fixedDisplayArea => _fixedDisplayAreaController.stream;
  Stream<double> get opacity => _opacityController.stream;
  Stream<double> get fontSize => _fontSizeController.stream;
  Stream<double> get scrollSpeed => _scrollSpeedController.stream;
  Stream<bool> get syncPlaybackRate => _syncPlaybackRateController.stream;
  Stream<bool> get antiOcclusion => _antiOcclusionController.stream;
  Stream<bool> get carnivalMode => _carnivalModeController.stream;
  Stream<bool> get duplicateMerge => _duplicateMergeController.stream;

  void dispose() {
    _enabledController.close();
    _showScrollController.close();
    _showTopController.close();
    _showBottomController.close();
    _showAdvancedController.close();
    _displayAreaController.close();
    _fixedDisplayAreaController.close();
    _opacityController.close();
    _fontSizeController.close();
    _scrollSpeedController.close();
    _syncPlaybackRateController.close();
    _antiOcclusionController.close();
    _carnivalModeController.close();
    _duplicateMergeController.close();
  }
}

class DanmakuConfig {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'DanmakuConfig'));
  final prefs = SharedPreferencesAsync();

  final stream = DanmakuConfigStreams();

  Future<void>? _initialized;

  late bool enabled;
  late bool showScroll;
  late bool showTop;
  late bool showBottom;
  late bool showAdvanced;

  late double displayArea;
  late double fixedDisplayArea;
  late double opacity;
  late double fontSize;
  late double scrollSpeed;
  late bool syncPlaybackRate;
  late bool antiOcclusion;
  late bool carnivalMode;
  late bool duplicateMerge;

  Future<void> ensureInitialized() async {
    _initialized ??= _init();
    await _initialized;
  }

  Future<void> _init() async {
    enabled = await prefs.getBool(_enabledKey) ?? true;
    showScroll = await prefs.getBool(_showScrollKey) ?? true;
    showTop = await prefs.getBool(_showTopKey) ?? true;
    showBottom = await prefs.getBool(_showBottomKey) ?? true;
    showAdvanced = await prefs.getBool(_showAdvancedKey) ?? true;

    displayArea = await prefs.getDouble(_displayAreaKey) ?? 0.3;
    fixedDisplayArea = await prefs.getDouble(_fixedDisplayAreaKey) ?? 0.3;
    opacity = await prefs.getDouble(_opacityKey) ?? 0.8;
    fontSize = await prefs.getDouble(_fontSizeKey) ?? 1.0;
    scrollSpeed = await prefs.getDouble(_scrollSpeedKey) ?? 1.0;
    syncPlaybackRate = await prefs.getBool(_syncPlaybackRateKey) ?? true;
    antiOcclusion = await prefs.getBool(_antiOcclusionKey) ?? false;
    carnivalMode = await prefs.getBool(_carnivalModeKey) ?? false;
    duplicateMerge = await prefs.getBool(_duplicateMergeKey) ?? false;

    stream._enabledController.add(enabled);
    stream._showScrollController.add(showScroll);
    stream._showTopController.add(showTop);
    stream._showBottomController.add(showBottom);
    stream._showAdvancedController.add(showAdvanced);
    stream._displayAreaController.add(displayArea);
    stream._fixedDisplayAreaController.add(fixedDisplayArea);
    stream._opacityController.add(opacity);
    stream._fontSizeController.add(fontSize);
    stream._scrollSpeedController.add(scrollSpeed);
    stream._syncPlaybackRateController.add(syncPlaybackRate);
    stream._antiOcclusionController.add(antiOcclusion);
    stream._carnivalModeController.add(carnivalMode);
    stream._duplicateMergeController.add(duplicateMerge);
  }

  void dispose() {
    stream.dispose();
  }

  Future<void> setEnabled(bool newValue) async {
    enabled = newValue;
    stream._enabledController.add(newValue);

    try {
      await prefs.setBool(_enabledKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_enabledKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setDisplayArea(double newValue) async {
    assert(newValue > 0 && newValue <= 1);
    displayArea = newValue;
    stream._displayAreaController.add(newValue);

    try {
      await prefs.setDouble(_displayAreaKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_displayAreaKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setFixedDisplayArea(double newValue) async {
    assert(newValue > 0 && newValue <= 1);
    fixedDisplayArea = newValue;
    stream._fixedDisplayAreaController.add(newValue);

    try {
      await prefs.setDouble(_fixedDisplayAreaKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_fixedDisplayAreaKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setOpacity(double newValue) async {
    assert(newValue > 0 && newValue <= 1);
    opacity = newValue;
    stream._opacityController.add(newValue);

    try {
      await prefs.setDouble(_opacityKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_opacityKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setFontSize(double newValue) async {
    assert(newValue > 0 && newValue <= 1);
    fontSize = newValue;
    stream._fontSizeController.add(newValue);

    try {
      await prefs.setDouble(_fontSizeKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_fontSizeKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setScrollSpeed(double newValue) async {
    assert(newValue > 0 && newValue <= 2);
    scrollSpeed = newValue;
    stream._scrollSpeedController.add(newValue);

    try {
      await prefs.setDouble(_scrollSpeedKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_scrollSpeedKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setSyncPlaybackRate(bool newValue) async {
    syncPlaybackRate = newValue;
    stream._syncPlaybackRateController.add(newValue);

    try {
      await prefs.setBool(_syncPlaybackRateKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_syncPlaybackRateKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setShowScroll(bool newValue) async {
    showScroll = newValue;
    stream._showScrollController.add(newValue);

    try {
      await prefs.setBool(_showScrollKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_showScrollKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setShowTop(bool newValue) async {
    showTop = newValue;
    stream._showTopController.add(newValue);

    try {
      await prefs.setBool(_showTopKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_showTopKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setShowBottom(bool newValue) async {
    showBottom = newValue;
    stream._showBottomController.add(newValue);

    try {
      await prefs.setBool(_showBottomKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_showBottomKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setShowAdvanced(bool newValue) async {
    showAdvanced = newValue;
    stream._showAdvancedController.add(newValue);

    try {
      await prefs.setBool(_showAdvancedKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_showAdvancedKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setAntiOcclusion(bool newValue) async {
    antiOcclusion = newValue;
    stream._antiOcclusionController.add(newValue);

    try {
      await prefs.setBool(_antiOcclusionKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_antiOcclusionKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setCarnivalMode(bool newValue) async {
    carnivalMode = newValue;
    stream._carnivalModeController.add(newValue);

    try {
      await prefs.setBool(_carnivalModeKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_carnivalModeKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }

  Future<void> setDuplicateMerge(bool newValue) async {
    duplicateMerge = newValue;
    stream._duplicateMergeController.add(newValue);

    try {
      await prefs.setBool(_duplicateMergeKey, newValue);
    } catch (e, s) {
      _log.e('Config save failed: key=$_duplicateMergeKey, newValue=$newValue', error: e, stackTrace: s);
    }
  }
}
