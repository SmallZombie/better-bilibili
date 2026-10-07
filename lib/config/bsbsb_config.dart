import 'dart:convert';

import 'package:better_bilibili/utils/config/async_config_item.dart';
import 'package:better_bilibili/utils/config/config_item.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive_ce.dart';

class BsbsbConfig {
  late final Box box;
  late final LazyBox secureBox;
  late final Future init;

  BsbsbConfig() {
    init = () async {
      box = await Hive.openBox('bsbsb_config');

      const secure = FlutterSecureStorage();
      String? keyString = await secure.read(key: 'bsbsb_config_key');
      if (keyString == null) {
        final key = Hive.generateSecureKey();
        keyString = base64UrlEncode(key);
        await secure.write(key: 'bsbsb_config_key', value: keyString);
      }
      final key = base64Url.decode(keyString);
      secureBox = await Hive.openLazyBox('bsbsb_config_secure', encryptionCipher: HiveAesCipher(key));
    }();
  }

  String getKey(String key) => 'bsbsb.$key';

  late final enable = ConfigItem(
    box: box,
    key: getKey('enable'),
    defaultValue: false,
  );

  // sponsor, selfpromo, exclusive_access, interaction, poi_highlight, intro, outro, preview, padding, filler, music_offtopic
  late final sponsor = ConfigItem(
    box: box,
    key: getKey('sponsor'),
    defaultValue: SkipOptionsEnum.skipToEnd,
  );
  late final selfpromo = ConfigItem(
    box: box,
    key: getKey('selfpromo'),
    defaultValue: SkipOptionsEnum.skipToEnd,
  );
  late final interaction = ConfigItem(
    box: box,
    key: getKey('interaction'),
    defaultValue: SkipOptionsEnum.disable,
  );
  late final pointsOfInterest = ConfigItem(
    box: box,
    key: getKey('points_of_interest'),
    defaultValue: SkipOptionsEnum.askOnlyStart,
  );
  late final intro = ConfigItem(
    box: box,
    key: getKey('intro'),
    defaultValue: SkipOptionsEnum.askOnlyEnd,
  );
  late final outro = ConfigItem(
    box: box,
    key: getKey('outro'),
    defaultValue: SkipOptionsEnum.askOnlyEnd,
  );
  late final preview = ConfigItem(
    box: box,
    key: getKey('preview'),
    defaultValue: SkipOptionsEnum.disable,
  );
  late final padding = ConfigItem(
    box: box,
    key: getKey('padding'),
    defaultValue: SkipOptionsEnum.skipToEnd,
  );
  late final filler = ConfigItem(
    box: box,
    key: getKey('filler'),
    defaultValue: SkipOptionsEnum.disable,
  );
  late final musicOfftopic = ConfigItem(
    box: box,
    key: getKey('music_offtopic'),
    defaultValue: SkipOptionsEnum.skipToEnd,
  );

  late final sponsorColor = ConfigItem(
    box: box,
    key: getKey('sponsor_color'),
    defaultValue: '#00d400',
  );
  late final selfpromoColor = ConfigItem(
    box: box,
    key: getKey('selfpromo_color'),
    defaultValue: '#ffff00',
  );
  late final interactionColor = ConfigItem(
    box: box,
    key: getKey('interaction_color'),
    defaultValue: '#cc00ff',
  );
  late final pointsOfInterestColor = ConfigItem(
    box: box,
    key: getKey('points_of_interest_color'),
    defaultValue: '#ff1684',
  );
  late final introColor = ConfigItem(
    box: box,
    key: getKey('intro_color'),
    defaultValue: '#00ffff',
  );
  late final outroColor = ConfigItem(
    box: box,
    key: getKey('outro_color'),
    defaultValue: '#0202ed',
  );
  late final previewColor = ConfigItem(
    box: box,
    key: getKey('preview_color'),
    defaultValue: '#008fd6',
  );
  late final paddingColor = ConfigItem(
    box: box,
    key: getKey('padding_color'),
    defaultValue: '#222222',
  );
  late final fillerColor = ConfigItem(
    box: box,
    key: getKey('filler_color'),
    defaultValue: '#7300ff',
  );
  late final musicOfftopicColor = ConfigItem(
    box: box,
    key: getKey('music_offtopic_color'),
    defaultValue: '#ff9900',
  );

  late final allowMutedSegment = ConfigItem(
    box: box,
    key: getKey('allow_muted_segment'),
    defaultValue: false,
  );
  late final showGlobalMark = ConfigItem(
    box: box,
    key: getKey('show_global_mark'),
    defaultValue: false,
  );
  late final minSegmentDuration = ConfigItem(
    box: box,
    key: getKey('min_segment_duration'),
    defaultValue: 0,
  );
  late final whitelist = ConfigItem(
    box: box,
    key: getKey('whitelist'),
    defaultValue: '',
  );

  late final shareMyData = ConfigItem(
    box: box,
    key: getKey('share_my_data'),
    defaultValue: true,
  );

  late final privateId = AsyncConfigItem(
    box: secureBox,
    key: getKey('privateId'),
    defaultValue: generateRandomString(32),
  );
  late final baseUrls = ConfigItem(
    box: box,
    key: getKey('baseUrl'),
    defaultValue: ['https://www.bsbsb.xyz/api', 'http://103.236.70.57:9876/api'].join(','),
  );

  void dispose() {
    enable.dispose();
    sponsor.dispose();
    selfpromo.dispose();
    interaction.dispose();
    pointsOfInterest.dispose();
    intro.dispose();
    outro.dispose();
    preview.dispose();
    padding.dispose();
    filler.dispose();
    musicOfftopic.dispose();
    sponsorColor.dispose();
    selfpromoColor.dispose();
    interactionColor.dispose();
    pointsOfInterestColor.dispose();
    introColor.dispose();
    outroColor.dispose();
    previewColor.dispose();
    paddingColor.dispose();
    fillerColor.dispose();
    musicOfftopicColor.dispose();
    allowMutedSegment.dispose();
    showGlobalMark.dispose();
    minSegmentDuration.dispose();
    whitelist.dispose();
    shareMyData.dispose();
    privateId.dispose();
    baseUrls.dispose();
  }
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
