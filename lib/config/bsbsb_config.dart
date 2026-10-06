import 'package:better_bilibili/config/adapter/config_prefs_storage.dart';
import 'package:better_bilibili/config/adapter/config_secure_storage.dart';
import 'package:better_bilibili/utils/config_item.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BsbsbConfig {
  final ConfigPrefsStorage prefsStorage = ConfigPrefsStorage(prefs: SharedPreferencesAsync());
  final ConfigSecureStorage secure = ConfigSecureStorage(secure: FlutterSecureStorage());

  String getKey(String key) => 'bsbsb.$key';

  late final enable = ConfigItem(
    storage: prefsStorage,
    key: getKey('enable'),
    defaultValue: false,
  );

  // sponsor, selfpromo, exclusive_access, interaction, poi_highlight, intro, outro, preview, padding, filler, music_offtopic
  late final sponsor = ConfigItem(
    storage: prefsStorage,
    key: getKey('sponsor'),
    defaultValue: SkipOptionsEnum.skipToEnd,
    serialization: (data) => data.stringOf(),
    deserialization: SkipOptionsEnum.fromString,
  );
  late final selfpromo = ConfigItem(
    storage: prefsStorage,
    key: getKey('selfpromo'),
    defaultValue: SkipOptionsEnum.skipToEnd,
    serialization: (data) => data.stringOf(),
    deserialization: SkipOptionsEnum.fromString,
  );
  late final interaction = ConfigItem(
    storage: prefsStorage,
    key: getKey('interaction'),
    defaultValue: SkipOptionsEnum.disable,
    serialization: (data) => data.stringOf(),
    deserialization: SkipOptionsEnum.fromString,
  );
  late final pointsOfInterest = ConfigItem(
    storage: prefsStorage,
    key: getKey('points_of_interest'),
    defaultValue: SkipOptionsEnum.askOnlyStart,
    serialization: (data) => data.stringOf(),
    deserialization: SkipOptionsEnum.fromString,
  );
  late final intro = ConfigItem(
    storage: prefsStorage,
    key: getKey('intro'),
    defaultValue: SkipOptionsEnum.askOnlyEnd,
    serialization: (data) => data.stringOf(),
    deserialization: SkipOptionsEnum.fromString,
  );
  late final outro = ConfigItem(
    storage: prefsStorage,
    key: getKey('outro'),
    defaultValue: SkipOptionsEnum.askOnlyEnd,
    serialization: (data) => data.stringOf(),
    deserialization: SkipOptionsEnum.fromString,
  );
  late final preview = ConfigItem(
    storage: prefsStorage,
    key: getKey('preview'),
    defaultValue: SkipOptionsEnum.disable,
    serialization: (data) => data.stringOf(),
    deserialization: SkipOptionsEnum.fromString,
  );
  late final padding = ConfigItem(
    storage: prefsStorage,
    key: getKey('padding'),
    defaultValue: SkipOptionsEnum.skipToEnd,
    serialization: (data) => data.stringOf(),
    deserialization: SkipOptionsEnum.fromString,
  );
  late final filler = ConfigItem(
    storage: prefsStorage,
    key: getKey('filler'),
    defaultValue: SkipOptionsEnum.disable,
    serialization: (data) => data.stringOf(),
    deserialization: SkipOptionsEnum.fromString,
  );
  late final musicOfftopic = ConfigItem(
    storage: prefsStorage,
    key: getKey('music_offtopic'),
    defaultValue: SkipOptionsEnum.skipToEnd,
    serialization: (data) => data.stringOf(),
    deserialization: SkipOptionsEnum.fromString,
  );

  late final sponsorColor = ConfigItem(
    storage: prefsStorage,
    key: getKey('sponsor_color'),
    defaultValue: '#00d400',
  );
  late final selfpromoColor = ConfigItem(
    storage: prefsStorage,
    key: getKey('selfpromo_color'),
    defaultValue: '#ffff00',
  );
  late final interactionColor = ConfigItem(
    storage: prefsStorage,
    key: getKey('interaction_color'),
    defaultValue: '#cc00ff',
  );
  late final pointsOfInterestColor = ConfigItem(
    storage: prefsStorage,
    key: getKey('points_of_interest_color'),
    defaultValue: '#ff1684',
  );
  late final introColor = ConfigItem(
    storage: prefsStorage,
    key: getKey('intro_color'),
    defaultValue: '#00ffff',
  );
  late final outroColor = ConfigItem(
    storage: prefsStorage,
    key: getKey('outro_color'),
    defaultValue: '#0202ed',
  );
  late final previewColor = ConfigItem(
    storage: prefsStorage,
    key: getKey('preview_color'),
    defaultValue: '#008fd6',
  );
  late final paddingColor = ConfigItem(
    storage: prefsStorage,
    key: getKey('padding_color'),
    defaultValue: '#222222',
  );
  late final fillerColor = ConfigItem(
    storage: prefsStorage,
    key: getKey('filler_color'),
    defaultValue: '#7300ff',
  );
  late final musicOfftopicColor = ConfigItem(
    storage: prefsStorage,
    key: getKey('music_offtopic_color'),
    defaultValue: '#ff9900',
  );

  late final allowMutedSegment = ConfigItem(
    storage: prefsStorage,
    key: getKey('allow_muted_segment'),
    defaultValue: false,
  );
  late final showGlobalMark = ConfigItem(
    storage: prefsStorage,
    key: getKey('show_global_mark'),
    defaultValue: false,
  );
  late final minSegmentDuration = ConfigItem(
    storage: prefsStorage,
    key: getKey('min_segment_duration'),
    defaultValue: 0,
  );
  late final whitelist = ConfigItem(
    storage: prefsStorage,
    key: getKey('whitelist'),
    defaultValue: '',
  );

  late final shareMyData = ConfigItem(
    storage: prefsStorage,
    key: getKey('share_my_data'),
    defaultValue: true,
  );

  late final privateId = ConfigItem(
    storage: secure,
    key: getKey('privateId'),
    defaultValue: generateRandomString(32),
  );
  late final baseUrls = ConfigItem(
    storage: secure,
    key: getKey('baseUrl'),
    defaultValue: ['https://www.bsbsb.xyz/api', 'http://103.236.70.57:9876/api'].join(','),
  );
}

enum SkipOptionsEnum {
  disable,
  showOnly,
  askOnlyStart,
  askOnlyEnd,
  skipToEnd,
  skipToStart;

  String stringOf() => index.toString();

  static SkipOptionsEnum fromString(String value) => values[int.parse(value)];
}
