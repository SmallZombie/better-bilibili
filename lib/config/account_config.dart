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

    await box.put('account.$userId.wbiImgKey', account.wbiImgKey);
    await box.put('account.$userId.wbiSubKey', account.wbiSubKey);
    await box.put('account.$userId.buvid3', account.buvid3);
    await box.put('account.$userId.buvid4', account.buvid4);
    await box.put('account.$userId.biliTicket', account.biliTicket);
    await box.put('account.$userId.biliTicketExpiredAt', account.biliTicketExpiredAt);
    await box.put('account.$userId.uuid', account.uuid);
    await box.put('account.$userId.buvidFp', account.buvidFp);
    await box.put('account.$userId.userAgent', account.userAgent);
    await box.put('account.$userId.windowWidth', account.windowWidth);
    await box.put('account.$userId.windowHeight', account.windowHeight);
    await box.put('account.$userId.brand', account.brand);
    await box.put('account.$userId.model', account.model);

    if (account is LoginedAccount) {
      await secureBox.put('account.$userId.accessToken', account.accessToken);
      await secureBox.put('account.$userId.refreshToken', account.refreshToken);
      await box.put('account.$userId.tokenExpiredAt', account.tokenExpiredAt);
      await box.put('account.$userId.dedeUserID', account.dedeUserID);
      await box.put('account.$userId.dedeUserIdCkMd5', account.dedeUserIdCkMd5);
      await box.put('account.$userId.sid', account.sid);
      await box.put('account.$userId.biliJct', account.biliJct);
    }
  }

  Future<void> saveAccountWithBuilder(AccountBuilder builder) async {
    final userId = builder.userId;
    assert(userId != null);

    _log.i('saveAccountWithBuilder userId=$userId');

    await _addToAccountListIfNeeded(userId!);

    if (builder.wbiImgKey != null) await box.put('account.$userId.wbiImgKey', builder.wbiImgKey!);
    if (builder.wbiSubKey != null) await box.put('account.$userId.wbiSubKey', builder.wbiSubKey!);
    if (builder.buvid3 != null) await box.put('account.$userId.buvid3', builder.buvid3!);
    if (builder.buvid4 != null) await box.put('account.$userId.buvid4', builder.buvid4!);
    if (builder.biliTicket != null) await box.put('account.$userId.biliTicket', builder.biliTicket!);
    if (builder.biliTicketExpiredAt != null) await box.put('account.$userId.biliTicketExpiredAt', builder.biliTicketExpiredAt!);
    if (builder.uuid != null) await box.put('account.$userId.uuid', builder.uuid!);
    if (builder.buvidFp != null) await box.put('account.$userId.buvidFp', builder.buvidFp!);
    if (builder.userAgent != null) await box.put('account.$userId.userAgent', builder.userAgent!);
    if (builder.windowWidth != null) await box.put('account.$userId.windowWidth', builder.windowWidth!);
    if (builder.windowHeight != null) await box.put('account.$userId.windowHeight', builder.windowHeight!);
    if (builder.brand != null) await box.put('account.$userId.brand', builder.brand!);
    if (builder.model != null) await box.put('account.$userId.model', builder.model!);

    if (builder.accessToken != null) await secureBox.put('account.$userId.accessToken', builder.accessToken!);
    if (builder.refreshToken != null) await secureBox.put('account.$userId.refreshToken', builder.refreshToken!);
    if (builder.tokenExpiredAt != null) await box.put('account.$userId.tokenExpiredAt', builder.tokenExpiredAt!);
    if (builder.dedeUserID != null) await box.put('account.$userId.dedeUserID', builder.dedeUserID!);
    if (builder.dedeUserIdCkMd5 != null) await box.put('account.$userId.dedeUserIdCkMd5', builder.dedeUserIdCkMd5!);
    if (builder.sid != null) await box.put('account.$userId.sid', builder.sid!);
    if (builder.biliJct != null) await box.put('account.$userId.biliJct', builder.biliJct!);
  }

  Future<void> removeAccount(String userId) async {
    assert(userId != kGuestUserId);

    _log.i('removeAccount userId=$userId');

    final prefix = 'account.$userId.';
    await deleteWithPrefixAsync(box, prefix);
    await deleteWithPrefixAsync(secureBox, prefix);

    await _removeFromAccountList(userId);
  }

  Future<String> getCurrentAccountId() async {
    return (await box.get('account.current')) ?? kGuestUserId;
  }

  Future<AccountBuilder> getAccount(String userId) async {
    _log.i('getAccount userId=$userId');

    final builder = AccountBuilder();

    builder.userId = userId;
    builder.accessToken = await secureBox.get('account.$userId.accessToken');
    builder.refreshToken = await secureBox.get('account.$userId.refreshToken');
    builder.tokenExpiredAt = await box.get('account.$userId.tokenExpiredAt');
    builder.dedeUserID = await box.get('account.$userId.dedeUserID');
    builder.dedeUserIdCkMd5 = await box.get('account.$userId.dedeUserIdCkMd5');
    builder.sid = await box.get('account.$userId.sid');
    builder.biliJct = await box.get('account.$userId.biliJct');
    builder.wbiImgKey = await box.get('account.$userId.wbiImgKey');
    builder.wbiSubKey = await box.get('account.$userId.wbiSubKey');
    builder.buvid3 = await box.get('account.$userId.buvid3');
    builder.buvid4 = await box.get('account.$userId.buvid4');
    builder.biliTicket = await box.get('account.$userId.biliTicket');
    builder.biliTicketExpiredAt = await box.get('account.$userId.biliTicketExpiredAt');
    builder.uuid = await box.get('account.$userId.uuid');
    builder.buvidFp = await box.get('account.$userId.buvidFp');
    builder.userAgent = await box.get('account.$userId.userAgent');
    builder.windowWidth = await box.get('account.$userId.windowWidth');
    builder.windowHeight = await box.get('account.$userId.windowHeight');
    builder.brand = await box.get('account.$userId.brand');
    builder.model = await box.get('account.$userId.model');

    return builder;
  }

  Future<void> setCurrentAccount(String nextAccountId) {
    _log.i('setCurrentAccount nextAccountId=$nextAccountId');

    return box.put('account.current', nextAccountId);
  }

  Future<List<String>> getAccountList() async {
    final accountListStr = await box.get('account.list');
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
    unawaited(box.put('account.list', list.join(',')));
  }

  Future<void> _removeFromAccountList(String accountId) async {
    final list = await getAccountList();
    list.removeWhere((v) => v == accountId);
    unawaited(box.put('account.list', list.join(',')));
  }
}
