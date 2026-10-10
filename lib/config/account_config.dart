import 'dart:async';
import 'dart:convert';

import 'package:better_bilibili/domain/models/bilibili/account.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:better_bilibili/utils/hive_util.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive.dart';
import 'package:logger/logger.dart';

const kGuestUserId = '#guest';

class AccountConfig {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'AccountConfig'));

  late final LazyBox box;
  late final LazyBox secureBox;
  late final Future init;

  AccountConfig() {
    init = () async {
      box = await Hive.openLazyBox('account_config');

      const secure = FlutterSecureStorage();
      String? keyString = await secure.read(key: 'account_config_key');
      if (keyString == null) {
        final key = Hive.generateSecureKey();
        keyString = base64UrlEncode(key);
        await secure.write(key: 'account_config_key', value: keyString);
      }
      final key = base64Url.decode(keyString);
      secureBox = await Hive.openLazyBox('account_config_secure', encryptionCipher: HiveAesCipher(key));
    }();
  }

  Future<void> saveAccount(Account account) async {
    final userId = account.userId;

    _log.i('saveAccount userId=$userId');

    await _addToAccountListIfNeeded(userId);

    await box.put('$userId.wbiImgKey', account.wbiImgKey);
    await box.put('$userId.wbiSubKey', account.wbiSubKey);
    await box.put('$userId.buvid3', account.buvid3);
    await box.put('$userId.buvid4', account.buvid4);
    await box.put('$userId.biliTicket', account.biliTicket);
    await box.put('$userId.biliTicketExpiredAt', account.biliTicketExpiredAt);
    await box.put('$userId.uuid', account.uuid);
    await box.put('$userId.buvidFp', account.buvidFp);
    await box.put('$userId.userAgent', account.userAgent);
    await box.put('$userId.windowWidth', account.windowWidth);
    await box.put('$userId.windowHeight', account.windowHeight);
    await box.put('$userId.brand', account.brand);
    await box.put('$userId.model', account.model);

    if (account is LoginedAccount) {
      await secureBox.put('$userId.accessToken', account.accessToken);
      await secureBox.put('$userId.refreshToken', account.refreshToken);
      await box.put('$userId.tokenExpiredAt', account.tokenExpiredAt);
      await box.put('$userId.dedeUserID', account.dedeUserID);
      await box.put('$userId.dedeUserIdCkMd5', account.dedeUserIdCkMd5);
      await box.put('$userId.sid', account.sid);
      await box.put('$userId.biliJct', account.biliJct);
    }
  }

  Future<void> saveAccountWithBuilder(AccountBuilder builder) async {
    final userId = builder.userId;
    assert(userId != null);

    _log.i('saveAccountWithBuilder userId=$userId');

    await _addToAccountListIfNeeded(userId!);

    if (builder.wbiImgKey != null) await box.put('$userId.wbiImgKey', builder.wbiImgKey!);
    if (builder.wbiSubKey != null) await box.put('$userId.wbiSubKey', builder.wbiSubKey!);
    if (builder.buvid3 != null) await box.put('$userId.buvid3', builder.buvid3!);
    if (builder.buvid4 != null) await box.put('$userId.buvid4', builder.buvid4!);
    if (builder.biliTicket != null) await box.put('$userId.biliTicket', builder.biliTicket!);
    if (builder.biliTicketExpiredAt != null) await box.put('$userId.biliTicketExpiredAt', builder.biliTicketExpiredAt!);
    if (builder.uuid != null) await box.put('$userId.uuid', builder.uuid!);
    if (builder.buvidFp != null) await box.put('$userId.buvidFp', builder.buvidFp!);
    if (builder.userAgent != null) await box.put('$userId.userAgent', builder.userAgent!);
    if (builder.windowWidth != null) await box.put('$userId.windowWidth', builder.windowWidth!);
    if (builder.windowHeight != null) await box.put('$userId.windowHeight', builder.windowHeight!);
    if (builder.brand != null) await box.put('$userId.brand', builder.brand!);
    if (builder.model != null) await box.put('$userId.model', builder.model!);

    if (builder.accessToken != null) await secureBox.put('$userId.accessToken', builder.accessToken!);
    if (builder.refreshToken != null) await secureBox.put('$userId.refreshToken', builder.refreshToken!);
    if (builder.tokenExpiredAt != null) await box.put('$userId.tokenExpiredAt', builder.tokenExpiredAt!);
    if (builder.dedeUserID != null) await box.put('$userId.dedeUserID', builder.dedeUserID!);
    if (builder.dedeUserIdCkMd5 != null) await box.put('$userId.dedeUserIdCkMd5', builder.dedeUserIdCkMd5!);
    if (builder.sid != null) await box.put('$userId.sid', builder.sid!);
    if (builder.biliJct != null) await box.put('$userId.biliJct', builder.biliJct!);
  }

  Future<void> removeAccount(String userId) async {
    assert(userId != kGuestUserId);

    _log.i('removeAccount userId=$userId');

    final prefix = '$userId.';
    await deleteWithPrefixAsync(box, prefix);
    await deleteWithPrefixAsync(secureBox, prefix);

    await _removeFromAccountList(userId);
  }

  Future<String> getCurrentAccountId() async {
    return (await box.get('current')) ?? kGuestUserId;
  }

  Future<AccountBuilder> getAccount(String userId) async {
    _log.i('getAccount userId=$userId');

    final builder = AccountBuilder();

    builder.userId = userId;
    builder.accessToken = await secureBox.get('$userId.accessToken');
    builder.refreshToken = await secureBox.get('$userId.refreshToken');
    builder.tokenExpiredAt = await box.get('$userId.tokenExpiredAt');
    builder.dedeUserID = await box.get('$userId.dedeUserID');
    builder.dedeUserIdCkMd5 = await box.get('$userId.dedeUserIdCkMd5');
    builder.sid = await box.get('$userId.sid');
    builder.biliJct = await box.get('$userId.biliJct');
    builder.wbiImgKey = await box.get('$userId.wbiImgKey');
    builder.wbiSubKey = await box.get('$userId.wbiSubKey');
    builder.buvid3 = await box.get('$userId.buvid3');
    builder.buvid4 = await box.get('$userId.buvid4');
    builder.biliTicket = await box.get('$userId.biliTicket');
    builder.biliTicketExpiredAt = await box.get('$userId.biliTicketExpiredAt');
    builder.uuid = await box.get('$userId.uuid');
    builder.buvidFp = await box.get('$userId.buvidFp');
    builder.userAgent = await box.get('$userId.userAgent');
    builder.windowWidth = await box.get('$userId.windowWidth');
    builder.windowHeight = await box.get('$userId.windowHeight');
    builder.brand = await box.get('$userId.brand');
    builder.model = await box.get('$userId.model');

    return builder;
  }

  Future<void> setCurrentAccount(String nextAccountId) {
    _log.i('setCurrentAccount nextAccountId=$nextAccountId');

    return box.put('current', nextAccountId);
  }

  Future<List<String>> getAccountList() async {
    final accountListStr = await box.get('list');
    if (accountListStr == null) return [kGuestUserId];

    final list = accountListStr.split(',');
    if (!list.contains(kGuestUserId)) {
      list.add(kGuestUserId);
    }
    return list;
  }

  Future<void> _addToAccountListIfNeeded(String accountId) async {
    final list = await getAccountList();
    if (!list.contains(accountId)) {
      list.add(accountId);
    }
    unawaited(box.put('list', list.join(',')));
  }

  Future<void> _removeFromAccountList(String accountId) async {
    final list = await getAccountList();
    list.removeWhere((v) => v == accountId);
    unawaited(box.put('list', list.join(',')));
  }
}
