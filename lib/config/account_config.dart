import 'package:better_bilibili/config/adapter/config_prefs_storage.dart';
import 'package:better_bilibili/config/adapter/config_secure_storage.dart';
import 'package:better_bilibili/domain/models/bilibili/account.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kGuestUserId = '#guest';

class AccountConfig {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'AccountConfig'));

  final ConfigPrefsStorage prefs = ConfigPrefsStorage(prefs: SharedPreferencesAsync());
  final ConfigSecureStorage secure = ConfigSecureStorage(secure: FlutterSecureStorage());

  Future<void> saveAccount(Account account) async {
    final userId = account.userId;

    _log.i('saveAccount userId=$userId');

    await _addToAccountListIfNeeded(userId);

    await prefs.setString('account.$userId.wbiImgKey', account.wbiImgKey);
    await prefs.setString('account.$userId.wbiSubKey', account.wbiSubKey);
    await prefs.setString('account.$userId.buvid3', account.buvid3);
    await prefs.setString('account.$userId.buvid4', account.buvid4);
    await prefs.setString('account.$userId.biliTicket', account.biliTicket);
    await prefs.setInt('account.$userId.biliTicketExpiredAt', account.biliTicketExpiredAt);
    await prefs.setString('account.$userId.uuid', account.uuid);
    await prefs.setString('account.$userId.buvidFp', account.buvidFp);
    await prefs.setString('account.$userId.userAgent', account.userAgent);
    await prefs.setInt('account.$userId.windowWidth', account.windowWidth);
    await prefs.setInt('account.$userId.windowHeight', account.windowHeight);
    await prefs.setString('account.$userId.brand', account.brand);
    await prefs.setString('account.$userId.model', account.model);

    if (account is LoginedAccount) {
      await secure.setString('account.$userId.accessToken', account.accessToken);
      await secure.setString('account.$userId.refreshToken', account.refreshToken);
      await prefs.setInt('account.$userId.tokenExpiredAt', account.tokenExpiredAt);
      await prefs.setString('account.$userId.dedeUserID', account.dedeUserID);
      await prefs.setString('account.$userId.dedeUserIdCkMd5', account.dedeUserIdCkMd5);
      await prefs.setString('account.$userId.sid', account.sid);
      await prefs.setString('account.$userId.biliJct', account.biliJct);
    }
  }

  Future<void> saveAccountWithBuilder(AccountBuilder builder) async {
    final userId = builder.userId;
    assert(userId != null);

    _log.i('saveAccountWithBuilder userId=$userId');

    await _addToAccountListIfNeeded(userId!);

    if (builder.wbiImgKey != null) await prefs.setString('account.$userId.wbiImgKey', builder.wbiImgKey!);
    if (builder.wbiSubKey != null) await prefs.setString('account.$userId.wbiSubKey', builder.wbiSubKey!);
    if (builder.buvid3 != null) await prefs.setString('account.$userId.buvid3', builder.buvid3!);
    if (builder.buvid4 != null) await prefs.setString('account.$userId.buvid4', builder.buvid4!);
    if (builder.biliTicket != null) await prefs.setString('account.$userId.biliTicket', builder.biliTicket!);
    if (builder.biliTicketExpiredAt != null) await prefs.setInt('account.$userId.biliTicketExpiredAt', builder.biliTicketExpiredAt!);
    if (builder.uuid != null) await prefs.setString('account.$userId.uuid', builder.uuid!);
    if (builder.buvidFp != null) await prefs.setString('account.$userId.buvidFp', builder.buvidFp!);
    if (builder.userAgent != null) await prefs.setString('account.$userId.userAgent', builder.userAgent!);
    if (builder.windowWidth != null) await prefs.setInt('account.$userId.windowWidth', builder.windowWidth!);
    if (builder.windowHeight != null) await prefs.setInt('account.$userId.windowHeight', builder.windowHeight!);
    if (builder.brand != null) await prefs.setString('account.$userId.brand', builder.brand!);
    if (builder.model != null) await prefs.setString('account.$userId.model', builder.model!);

    if (builder.accessToken != null) await secure.setString('account.$userId.accessToken', builder.accessToken!);
    if (builder.refreshToken != null) await secure.setString('account.$userId.refreshToken', builder.refreshToken!);
    if (builder.tokenExpiredAt != null) await prefs.setInt('account.$userId.tokenExpiredAt', builder.tokenExpiredAt!);
    if (builder.dedeUserID != null) await prefs.setString('account.$userId.dedeUserID', builder.dedeUserID!);
    if (builder.dedeUserIdCkMd5 != null) await prefs.setString('account.$userId.dedeUserIdCkMd5', builder.dedeUserIdCkMd5!);
    if (builder.sid != null) await prefs.setString('account.$userId.sid', builder.sid!);
    if (builder.biliJct != null) await prefs.setString('account.$userId.biliJct', builder.biliJct!);
  }

  Future<void> removeAccount(String userId) async {
    assert(userId != kGuestUserId);

    _log.i('removeAccount userId=$userId');

    final prefix = 'account.$userId.';
    await prefs.clearWithPrefix(prefix);
    await secure.clearWithPrefix(prefix);

    await _removeFromAccountList(userId);
  }

  Future<String> getCurrentAccountId() async {
    return (await prefs.getString('account.current')) ?? kGuestUserId;
  }

  Future<AccountBuilder> getAccount(String userId) async {
    _log.i('getAccount userId=$userId');

    final builder = AccountBuilder();

    builder.userId = userId;
    builder.accessToken = await secure.getString('account.$userId.accessToken');
    builder.refreshToken = await secure.getString('account.$userId.refreshToken');
    builder.tokenExpiredAt = await prefs.getInt('account.$userId.tokenExpiredAt');
    builder.dedeUserID = await prefs.getString('account.$userId.dedeUserID');
    builder.dedeUserIdCkMd5 = await prefs.getString('account.$userId.dedeUserIdCkMd5');
    builder.sid = await prefs.getString('account.$userId.sid');
    builder.biliJct = await prefs.getString('account.$userId.biliJct');
    builder.wbiImgKey = await prefs.getString('account.$userId.wbiImgKey');
    builder.wbiSubKey = await prefs.getString('account.$userId.wbiSubKey');
    builder.buvid3 = await prefs.getString('account.$userId.buvid3');
    builder.buvid4 = await prefs.getString('account.$userId.buvid4');
    builder.biliTicket = await prefs.getString('account.$userId.biliTicket');
    builder.biliTicketExpiredAt = await prefs.getInt('account.$userId.biliTicketExpiredAt');
    builder.uuid = await prefs.getString('account.$userId.uuid');
    builder.buvidFp = await prefs.getString('account.$userId.buvidFp');
    builder.userAgent = await prefs.getString('account.$userId.userAgent');
    builder.windowWidth = await prefs.getInt('account.$userId.windowWidth');
    builder.windowHeight = await prefs.getInt('account.$userId.windowHeight');
    builder.brand = await prefs.getString('account.$userId.brand');
    builder.model = await prefs.getString('account.$userId.model');

    return builder;
  }

  Future<void> setCurrentAccount(String nextAccountId) {
    _log.i('setCurrentAccount nextAccountId=$nextAccountId');

    return prefs.setString('account.current', nextAccountId);
  }

  Future<List<String>> getAccountList() async {
    final accountListStr = await prefs.getString('account.list');
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
    prefs.setString('account.list', list.join(','));
  }

  Future<void> _removeFromAccountList(String accountId) async {
    final list = await getAccountList();
    list.removeWhere((v) => v == accountId);
    prefs.setString('account.list', list.join(','));
  }
}
