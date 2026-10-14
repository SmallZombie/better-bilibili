import 'dart:async';

import 'package:better_bilibili/config/account_config.dart';
import 'package:better_bilibili/data/interceptors/base_rate_limiter_intercrptor.dart';
import 'package:better_bilibili/data/interceptors/bilibili/bili_app_auth_interceptor.dart';
import 'package:better_bilibili/data/interceptors/bilibili/bili_web_auth_interceptor.dart';
import 'package:better_bilibili/data/interceptors/debug_logger_interceptor.dart';
import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/services/bilibili/bili_auth_web_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_buvid_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_login_qr_code_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_qr_code_status_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_self_info_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_ticket_response.dart';
import 'package:better_bilibili/domain/models/bilibili/account.dart';
import 'package:better_bilibili/utils/bili/bili_util.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// 只在切换账户的时候通知页面刷新
class AuthRepositoryRemote extends ChangeNotifier implements AuthRepository {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'AuthRepository'));

  late final BiliAuthWebApiService authApiService = BiliAuthWebApiService(
    getClient: () => getClient(type: .web),
    getAccount: getAccount,
  );
  final AccountConfig config;

  AuthRepositoryRemote({required this.config}) {
    unawaited(_refreshLoginState());
  }

  @override
  void dispose() async {
    for (final client in _clientCache.values) {
      (await client).close();
    }

    _clientCache.clear();
    _accountInitializationCache.clear();

    super.dispose();
  }

  @override
  bool get hasLogin => _hasLogin;

  bool _hasLogin = false;

  Future<void> _refreshLoginState() async {
    final userId = await config.getCurrentAccountId();
    final builder = await config.getAccount(userId);
    final hasLogin = builder.isLogin;

    if (_hasLogin == hasLogin) return;

    _hasLogin = hasLogin;
  }

  final Map<String, Future<Dio>> _clientCache = {};

  @override
  Future<Dio> getClient({required ClientTypeEnum type, String? userId}) async {
    final uid = userId ?? (await config.getCurrentAccountId());
    final cacheKey = '$uid-$type';

    Future<Dio> doGetClient() async {
      _log.i('doGetClient userId=$userId');
      final account = await _ensureAccountInitialized(uid);
      final client = _buildClient(type, account);
      return client;
    }

    if (_clientCache.containsKey(cacheKey)) {
      return _clientCache[cacheKey]!;
    }

    final future = doGetClient();
    _clientCache[cacheKey] = future;
    return future;
  }

  @override
  Future<Account> getAccount([String? userId]) async {
    final uid = userId ?? (await config.getCurrentAccountId());
    return _ensureAccountInitialized(uid);
  }

  final Map<String, Future<Account>> _accountInitializationCache = {};

  /// 确保账户在使用前已经初始化过
  Future<Account> _ensureAccountInitialized(String userId) {
    Future<Account> doEnsureAccountInitialized() async {
      final builder = await config.getAccount(userId);
      return _initializeAccount(builder);
    }

    if (_accountInitializationCache.containsKey(userId)) {
      return _accountInitializationCache[userId]!;
    }

    final future = doEnsureAccountInitialized();
    _accountInitializationCache[userId] = future;
    return future;
  }

  Future<Account> _initializeAccount(AccountBuilder builder) async {
    final userId = builder.userId;

    // UA
    if (builder.userAgent?.isEmpty ?? true) {
      builder.userAgent = randomUserAgent();
      _log.i('New UserAgent for $userId: ${builder.userAgent}');
    }

    // WindowSize
    if (((builder.windowWidth ?? 0) <= 0) || ((builder.windowHeight ?? 0) <= 0)) {
      final windowSize = randomWindowSize();
      builder.windowWidth = windowSize.$1;
      builder.windowHeight = windowSize.$2;
      _log.i('New WindowSize for $userId: ${windowSize.$1}x${windowSize.$2}');
    }

    // _uuid 于 log-reporter.js 中生成的 uuid，猜测是用于日志上报的，仅生成一次即可
    if (builder.uuid?.isEmpty ?? true) {
      builder.uuid = generateLogReporterUuid();
      _log.i('Generate new uuid for $userId: ${builder.uuid}');
    }

    // buvidFp 仅在不存在时生成，原本在网页端应该是浏览器指纹，在这里实在难以模拟，所以干脆就随机生成了
    if (builder.buvidFp?.isEmpty ?? true) {
      builder.buvidFp = generateBuvidFp();
      _log.i('Generate new buvidFp for $userId: ${builder.buvidFp}');
    }

    if ((builder.brand?.isEmpty ?? true) || (builder.model?.isEmpty ?? true)) {
      final phoneInfo = randomPhoneInfo();
      builder.brand = phoneInfo.$1;
      builder.model = phoneInfo.$2;
      _log.i('Generate new phoneInfo for $userId: brand=${builder.brand}, model=${builder.model}');
    }

    // buvid
    if ((builder.buvid3?.isEmpty ?? true) || (builder.buvid4?.isEmpty ?? true)) {
      _log.i('Buvid not exists, get buvid for $userId...');

      final account = builder.buildTemporary();
      final service = BiliAuthWebApiService(
        getClient: () async {
          return _buildClient(.web, account);
        },
        getAccount: () async {
          return account;
        },
      );

      final result = await service.getBuvid();
      switch (result) {
        case Ok<GetBuvidResponse>():
          builder.buvid3 = result.value.buvid3;
          builder.buvid4 = result.value.buvid4;
          _log.i('New buvid3: ${builder.buvid3}, buvid4: ${builder.buvid4}');
        case Error<GetBuvidResponse>(:final error):
          _log.e('Failed to get buvid', error: error);
          throw error;
      }
    }

    // wbi
    {
      _log.i('Get wbi keys for $userId...');

      final account = builder.buildTemporary();
      final service = BiliAuthWebApiService(
        getClient: () async {
          return _buildClient(.web, account);
        },
        getAccount: () async {
          return account;
        },
      );

      final result = await service.getSelfInfo();
      switch (result) {
        case Ok<GetSelfInfoResponse>():
          if (builder.wbiImgKey != result.value.wbiImgKey || builder.wbiSubKey != result.value.wbiSubKey) {
            builder.wbiImgKey = result.value.wbiImgKey;
            builder.wbiSubKey = result.value.wbiSubKey;
            _log.i('Update img_key: "${builder.wbiImgKey}" -> "${result.value.wbiImgKey}"');
            _log.i('Update sub_key: "${builder.wbiSubKey}" -> "${result.value.wbiSubKey}"');
          } else {
            _log.i('Wbi keys are up to date');
          }
        case Error<GetSelfInfoResponse>(:final error):
          _log.e('Failed to get wbi keys', error: error);
      }
    }

    // bili_ticket
    if ((builder.biliTicket?.isEmpty ?? true) ||
        (builder.biliTicketExpiredAt ?? 0) <= 0 ||
        builder.biliTicketExpiredAt! < DateTime.now().millisecondsSinceEpoch ~/ 1000) {
      _log.i('Get bili ticket for $userId...');

      final account = builder.buildTemporary();
      final service = BiliAuthWebApiService(
        getClient: () async {
          return _buildClient(.web, account);
        },
        getAccount: () async {
          return account;
        },
      );

      final result = await service.getTicket();
      switch (result) {
        case Ok<GetTicketResponse>():
          _log.i('New bili ticket: "${result.value.ticket}", expiredAt: ${result.value.expiredAt}');
          builder.biliTicket = result.value.ticket;
          builder.biliTicketExpiredAt = result.value.expiredAt;
        case Error<GetTicketResponse>(:final error):
          _log.e('Failed to get bili ticket', error: error);
      }
    }

    final account = builder.build();
    config.saveAccount(account);
    return account;
  }

  void _cleanAccountContext(String userId) async {
    _accountInitializationCache.remove(userId);

    final client = _clientCache.remove(userId);
    (await client)?.close();
  }

  Dio _buildClient(ClientTypeEnum type, Account account) {
    switch (type) {
      case .web:
        final dio = Dio();
        dio.interceptors.add(buildBiliWebAuthIntercrptor(account));
        dio.interceptors.add(
          BaseRateLimiterInterceptor(
            // dropExcess: kDebugMode,
            whiteList: ['api.bilibili.com/x/web-interface/suggest'],
          ),
        );

        if (kDebugMode) {
          dio.interceptors.add(debugLoggerInterceptor);
        }
        return dio;
      case .app:
        final dio = Dio();
        dio.interceptors.add(buildBiliAppAuthIntercrptor(account));
        dio.interceptors.add(
          BaseRateLimiterInterceptor(dropExcess: kDebugMode),
        );

        if (kDebugMode) {
          dio.interceptors.add(debugLoggerInterceptor);
        }
        return dio;
    }
  }

  @override
  Future<void> createAccount(AccountBuilder builder) async {
    assert(builder.userId != null);

    await config.saveAccountWithBuilder(builder);
    await _refreshLoginState();
    notifyListeners();
  }

  @override
  Future<void> removeAccount(String accountId) async {
    await config.removeAccount(accountId);

    if (accountId == await getCurrentAccountId()) {
      await switchAccount(kGuestUserId);
    } else {
      await _refreshLoginState();
      notifyListeners();
    }
  }

  /// 切换账户
  @override
  Future<void> switchAccount(String nextAccountId) async {
    final currentId = await config.getCurrentAccountId();
    assert(nextAccountId != currentId);

    await config.setCurrentAccount(nextAccountId);

    await _refreshLoginState();
    notifyListeners();
  }

  @override
  Future<void> updateAccount(Account account) async {
    final stillInitializing = _accountInitializationCache[account.userId];
    if (stillInitializing != null) await stillInitializing;

    _cleanAccountContext(account.userId);
    await config.saveAccount(account);
    await _refreshLoginState();
    notifyListeners();
  }

  @override
  Future<List<Account>> getAccounts() async {
    final list = await config.getAccountList();

    final List<Account> result = [];
    for (final i in list) {
      result.add(await _ensureAccountInitialized(i));
    }

    return result;
  }

  @override
  Future<String> getCurrentAccountId() {
    return config.getCurrentAccountId();
  }

  @override
  Future<Result<GetLoginQrCodeResponse>> getLoginQrCode() {
    return authApiService.getLoginQrCode();
  }

  @override
  Future<Result<GetQrCodeStatusResponse>> getQrCodeStatus({required String key}) {
    return authApiService.getQrCodeStatus(key: key);
  }

  @override
  Future<Result<GetSelfInfoResponse>> getSelfInfo() {
    return authApiService.getSelfInfo();
  }
}
