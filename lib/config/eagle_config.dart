import 'dart:convert';

import 'package:better_bilibili/utils/config/async_config_item.dart';
import 'package:better_bilibili/utils/config/config_item.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

class EagleConfig {
  late final Box box;
  late final LazyBox secureBox;
  late final Future init;

  EagleConfig() {
    init = () async {
      box = await Hive.openBox('player_config');

      const secure = FlutterSecureStorage();
      String? keyString = await secure.read(key: 'eagle_config_key');
      if (keyString == null) {
        final key = Hive.generateSecureKey();
        keyString = base64UrlEncode(key);
        await secure.write(key: 'eagle_config_key', value: keyString);
      }
      final key = base64Url.decode(keyString);
      secureBox = await Hive.openLazyBox('eagle_config_secure', encryptionCipher: HiveAesCipher(key));
    }();
  }

  void dispose() {
    enable.dispose();
    useExternalLinks.dispose();
    baseUrl.dispose();
    apiToken.dispose();
  }

  late final enable = ConfigItem(box: box, key: 'enable', defaultValue: false);
  late final useExternalLinks = ConfigItem(box: box, key: 'use_external_links', defaultValue: false);

  late final baseUrl = ConfigItem(box: box, key: 'base_url', defaultValue: 'http://localhost:41595');
  late final apiToken = AsyncConfigItem(box: secureBox, key: 'api_token', defaultValue: '');
}
