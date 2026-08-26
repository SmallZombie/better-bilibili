import 'dart:convert';
import 'dart:io';

import 'package:better_bilibili/config/account_config.dart';
import 'package:better_bilibili/data/services/bilibili/bili_auth_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_buvid_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_login_qr_code_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_qr_code_status_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_self_info_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_ticket_response.dart';
import 'package:better_bilibili/utils/bili_util.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// 只在切换账户的时候通知页面刷新
class AuthRepository extends ChangeNotifier {
  final Logger _log = Logger('AuthRepositoryImpl');
  final AccountConfig _accountConfig;
  late final BiliAuthApiService _biliAuthApiService = BiliAuthApiService(authRepository: this);

  bool _initialized = false;
  bool get hasInitialized => _initialized;
  Future? _initializeFuture;

  late AccountData _currentAccount;

  Dio? _biliClient;
  Dio? _biliClientByAccount;

  AuthRepository({
    required AccountConfig accountConfig,
  }) : _accountConfig = accountConfig;

  bool get hasLogin => _currentAccount.uid != '0';

  /// 负责确保 account_config 和当前账户都已完成初始化
  /// 初始化需要实现：
  /// - 确保 account_config 已初始化
  /// - 如果 UA 不存在，则分配新 UA
  /// - 如果 WindowSize 不存在或缺失，则分配新 WindowSize
  /// - 获取 Wbi 签名，如果与现存数据存在差异则更新，否则跳过
  /// 依照技术文档，如果获取失败，无论原本是否存在 Wbi 都正常继续后面的流程，遇到风控就正常提示风控错误
  /// - 如果 buvid 不存在，则获取新的 buvid
  /// 依照技术文档，如果获取失败，无论原本是否存在 buvid 都正常继续后面的流程，遇到风控就正常提示风控错误
  /// - 如果 bili_ticket 不存在或过期，则获取新的 bili_ticket
  /// 依照技术文档，如果获取失败，无论原本是否存在 bili_ticket 都正常继续后面的流程，遇到风控就正常提示风控错误
  /// - 如果 _uuid 不存在则创建新的
  /// - 如果 buvidFp 不存在则创建新的
  /// - 保存 account_config
  Future<void> ensureInitialized() async {
    Future<void> initialize() async {
      await _accountConfig.ensureInitialized();
      _currentAccount = _accountConfig.getCurrentAccount();

      // UA
      if (_currentAccount.userAgent == null) {
        _currentAccount.userAgent = getRandomUserAgent();
        _log.info('New UserAgent for ${_currentAccount.uid}: ${_currentAccount.userAgent}');
      }

      // WindowSize
      if (_currentAccount.windowWidth == null || _currentAccount.windowHeight == null) {
        final windowSize = getRandomWindowSize();
        _currentAccount.windowWidth = windowSize.$1;
        _currentAccount.windowHeight = windowSize.$2;
        _log.info(
          'New WindowSize for ${_currentAccount.uid}: ${_currentAccount.windowWidth}x${_currentAccount.windowHeight}',
        );
      }

      // wbi
      _log.info('Get wbi keys for ${_currentAccount.uid}...');
      final wbiResp = await _biliAuthApiService.getSelfInfo();

      switch (wbiResp) {
        case Ok<GetSelfInfoResponse>():
          if (_currentAccount.wbiImgKey != wbiResp.value.wbiImgKey ||
              _currentAccount.wbiSubKey != wbiResp.value.wbiSubKey) {
            _log.info('Update img_key: ${_currentAccount.wbiImgKey} -> ${wbiResp.value.wbiImgKey}');
            _log.info('Update sub_key: ${_currentAccount.wbiSubKey} -> ${wbiResp.value.wbiSubKey}');
            _currentAccount.wbiImgKey = wbiResp.value.wbiImgKey;
            _currentAccount.wbiSubKey = wbiResp.value.wbiSubKey;
          } else {
            _log.info('Wbi keys are up to date');
          }
        case Error<GetSelfInfoResponse>():
          _log.severe('Failed to get wbi keys: ${wbiResp.error}');
      }

      // buvid
      if (_currentAccount.buvid3 == null || _currentAccount.buvid4 == null) {
        _log.info('Buvid not exists, get buvid for ${_currentAccount.uid}...');
        final buvidResp = await _biliAuthApiService.getBuvid();

        switch (buvidResp) {
          case Ok<GetBuvidResponse>():
            _currentAccount.buvid3 = buvidResp.value.buvid3;
            _currentAccount.buvid4 = buvidResp.value.buvid4;
            _log.info('New buvid3: ${buvidResp.value.buvid3}, buvid4: ${buvidResp.value.buvid4}');
          case Error<GetBuvidResponse>():
            _log.severe('Failed to get buvid: ${buvidResp.error}');
        }
      }

      // bili_ticket
      if (_currentAccount.biliTicket == null ||
          _currentAccount.biliTicketExpiredAt == null ||
          _currentAccount.biliTicketExpiredAt! < DateTime.now().millisecondsSinceEpoch ~/ 1000) {
        _log.info('Get bili ticket for ${_currentAccount.uid}...');
        final ticketResp = await _biliAuthApiService.getTicket();

        switch (ticketResp) {
          case Ok<GetTicketResponse>():
            _currentAccount.biliTicket = ticketResp.value.ticket;
            _currentAccount.biliTicketExpiredAt = ticketResp.value.expiredAt;
            _log.info(
              'New bili ticket: ${_currentAccount.biliTicket}, expiredAt: ${_currentAccount.biliTicketExpiredAt}',
            );
          case Error<GetTicketResponse>():
            _log.severe('Failed to get bili ticket: ${ticketResp.error}');
        }
      }

      // _uuid 于 log-reporter.js 中生成的 uuid，猜测是用于日志上报的，仅生成一次即可
      if (_currentAccount.uuid == null) {
        _currentAccount.uuid = generateLogReporterUuid();
        _log.info('Uuid not exists, generate new uuid for ${_currentAccount.uid}: ${_currentAccount.uuid}');
      }

      // buvidFp 仅在不存在时生成，原本在网页端应该是浏览器指纹，在这里实在难以模拟，所以干脆就随机生成了
      if (_currentAccount.buvidFp == null) {
        _currentAccount.buvidFp = generateBuvidFp();
        _log.info('BuvidFp not exists, generate new buvidFp for ${_currentAccount.uid}: ${_currentAccount.buvidFp}');
      }

      await _accountConfig.save();
    }

    if (_initialized) return;

    _initializeFuture ??= initialize();
    await _initializeFuture;

    _initialized = true;
    _initializeFuture = null;
  }

  /// 切换账户，账户不存在时抛出异常，切换完成后通知账户切换，随后保存 account_config
  Future<void> switchAccount(String nextAccountId) async {
    final account = _accountConfig.findAccountByUid(nextAccountId);

    _currentAccount = account;
    _accountConfig.data.currentAccountId = nextAccountId;
    await _accountConfig.save();

    _initialized = false;
    _biliClient = null;

    notifyListeners();
  }

  /// 根据当前账户初始化新的 BiliClient
  Dio _buildBiliClientByAccount() {
    assert(_initialized);

    final dio = Dio(
      BaseOptions(
        headers: {
          'User-Agent': _currentAccount.userAgent,
          'Referer': 'https://www.bilibili.com/',
        },
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 拦截没有 ua 的请求防止暴毙
          if (options.headers['User-Agent'] == null) {
            throw Exception('User-Agent is required');
          }

          final List<String> cookies = [];

          // b_nut: 固定为当前秒级 unix 时间戳
          cookies.add('b_nut=${DateTime.now().millisecondsSinceEpoch ~/ 1000}');
          // browser_resolution 固定即可
          cookies.add('browser_resolution=2560-1305');
          // home_feed_column 首页一行能展示几个视频卡片，根据观察最大为 5，这里固定即可
          cookies.add('home_feed_column=5');
          // b_lsid 一段客户端生成的随机字符串，格式: {8位十六进制随机字符}_{当前毫秒时间戳的十六进制}，每次请求都要生成一个新的
          cookies.add(
            'b_lsid=${generateRandomHex(8)}_${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase()}',
          );
          // theme_style 网页端的主题，可选值为 light / dark
          cookies.add('theme_style=light');
          // 这些不知道干嘛的，初步判断固定即可
          cookies.add('theme-avatar-tip-show=SHOWED');
          cookies.add('theme-switch-show=SHOWED');
          cookies.add('theme-tip-show=SHOWED');
          cookies.add('timeMachine=0');
          // historyviewmode 进一次历史记录页后生成
          cookies.add('historyviewmode=grid');

          // _uuid
          if (_currentAccount.uuid != null) {
            cookies.add('_uuid=${_currentAccount.uuid}');
          }

          // SESSDATA
          if (_currentAccount.accessToken != null) {
            cookies.add('SESSDATA=${_currentAccount.accessToken}');
          }

          // bili_jct
          if (_currentAccount.biliJct != null) {
            cookies.add('bili_jct=${_currentAccount.biliJct}');
          }

          // DedeUserID
          if (_currentAccount.dedeUserID != null) {
            cookies.add('DedeUserID=${_currentAccount.dedeUserID}');
          }

          // DedeUserID__ckMd5
          if (_currentAccount.dedeUserIdCkMd5 != null) {
            cookies.add('DedeUserID__ckMd5=${_currentAccount.dedeUserIdCkMd5}');
          }

          // sid
          if (_currentAccount.sid != null) {
            cookies.add('sid=${_currentAccount.sid}');
          }

          // buvid3
          if (_currentAccount.buvid3 != null) {
            cookies.add('buvid3=${_currentAccount.buvid3}');
          }

          // buvid4
          if (_currentAccount.buvid4 != null) {
            cookies.add('buvid4=${_currentAccount.buvid4}');
          }

          // buvidFp
          if (_currentAccount.buvidFp != null) {
            cookies.add('buvidFp=${_currentAccount.buvidFp}');
          }

          // bili_ticket & bili_ticket_expires
          if (_currentAccount.biliTicket != null && _currentAccount.biliTicketExpiredAt != null) {
            cookies.add('bili_ticket=${_currentAccount.biliTicket}');
            cookies.add('bili_ticket_expires=${_currentAccount.biliTicketExpiredAt}');
          }

          options.headers['Cookie'] = cookies.join('; ');

          // csrf
          if (_currentAccount.biliJct != null) {
            if (options.queryParameters['csrf'] == '') {
              options.queryParameters['csrf'] = _currentAccount.biliJct;
            }

            if (options.data is Map<String, dynamic> && options.data.containsKey('csrf')) {
              options.data['csrf'] = _currentAccount.biliJct;
            }
          }

          return handler.next(options);
        },
        // onError: (error, handler) {
        //   // 统一错误处理
        //   if (error.response != null) {
        //     // 服务器返回了错误响应
        //     final statusCode = error.response?.statusCode;
        //     final message =
        //         error.response?.data?['message'] ??
        //         error.response?.data?['msg'] ??
        //         '请求失败';

        //     return handler.reject(
        //       DioException(
        //         requestOptions: error.requestOptions,
        //         response: error.response,
        //         type: DioExceptionType.badResponse,
        //         error: 'HTTP $statusCode: $message',
        //       ),
        //     );
        //   } else {
        //     // 网络错误或其他错误
        //     return handler.reject(error);
        //   }
        // },
      ),
    );

    if (kDebugMode) {
      _addDebugHttpInterceptor(dio);
    }
    return dio;
  }

  /// 允许在未初始化下使用的仅包含必要请求头的 BiliClient
  Dio _buildBiliClient() {
    final dio = Dio(
      BaseOptions(
        headers: {
          'User-Agent': _currentAccount.userAgent,
          'Referer': 'https://www.bilibili.com/',
        },
      ),
    );

    if (kDebugMode) {
      _addDebugHttpInterceptor(dio);
    }

    return dio;
  }

  void _addDebugHttpInterceptor(Dio dio) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) async {
          await _persistHttpTraffic(requestOptions: response.requestOptions, response: response);
          return handler.next(response);
        },
        onError: (error, handler) async {
          await _persistHttpTraffic(
            requestOptions: error.requestOptions,
            response: error.response,
            error: error,
          );
          return handler.next(error);
        },
      ),
    );
  }

  Future<void> _persistHttpTraffic({
    required RequestOptions requestOptions,
    Response<dynamic>? response,
    DioException? error,
  }) async {
    try {
      final logsDir = Directory('${Directory.systemTemp.path}\\better_bilibili_http_logs');
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      final urlPath = requestOptions.uri.path.isEmpty ? 'root' : requestOptions.uri.path;
      final safeName = urlPath
          .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
          .replaceAll(RegExp(r'_+'), '_')
          .replaceAll(RegExp(r'^_+|_+$'), '');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${safeName.isEmpty ? 'request' : safeName}_$timestamp.txt';
      final logFile = File('${logsDir.path}\\$fileName');

      final requestInfo =
          StringBuffer()
            ..writeln('==== REQUEST ====')
            ..writeln('time: ${DateTime.now().toIso8601String()}')
            ..writeln('method: ${requestOptions.method}')
            ..writeln('uri: ${requestOptions.uri}')
            ..writeln('baseUrl: ${requestOptions.baseUrl}')
            ..writeln('path: ${requestOptions.path}')
            ..writeln('queryParameters: ${_encodePretty(requestOptions.queryParameters)}')
            ..writeln('headers: ${_encodePretty(requestOptions.headers)}')
            ..writeln('extra: ${_encodePretty(requestOptions.extra)}')
            ..writeln('contentType: ${requestOptions.contentType}')
            ..writeln('responseType: ${requestOptions.responseType}')
            ..writeln('followRedirects: ${requestOptions.followRedirects}')
            ..writeln('connectTimeout: ${requestOptions.connectTimeout}')
            ..writeln('sendTimeout: ${requestOptions.sendTimeout}')
            ..writeln('receiveTimeout: ${requestOptions.receiveTimeout}')
            ..writeln('requestBody: ${_encodePretty(requestOptions.data)}');

      final responseInfo = StringBuffer()..writeln('==== RESPONSE ====');
      if (response != null) {
        responseInfo
          ..writeln('statusCode: ${response.statusCode}')
          ..writeln('statusMessage: ${response.statusMessage}')
          ..writeln('isRedirect: ${response.isRedirect}')
          ..writeln('realUri: ${response.realUri}')
          ..writeln('extra: ${_encodePretty(response.extra)}')
          ..writeln('headers: ${_encodePretty(response.headers.map)}')
          ..writeln('responseBody: ${_encodePretty(response.data)}');
      } else {
        responseInfo.writeln('status: no response');
      }

      if (error != null) {
        responseInfo
          ..writeln('errorType: ${error.type}')
          ..writeln('errorMessage: ${error.message}')
          ..writeln('error: ${_encodePretty(error.error)}')
          ..writeln('stackTrace: ${error.stackTrace}');
      }

      await logFile.writeAsString('${requestInfo.toString()}\n\n${responseInfo.toString()}');
    } catch (e, stackTrace) {
      debugPrint('[HTTP_LOG_ERROR] $e\n$stackTrace');
    }
  }

  String _encodePretty(dynamic value) {
    if (value == null) {
      return 'null';
    }
    try {
      if (value is String) {
        final maybeJson = jsonDecode(value);
        return const JsonEncoder.withIndent('  ').convert(maybeJson);
      }
      if (value is List<int>) {
        return value.toString();
      }
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  /// 获取 BiliClient，如果 allowDowngrade 为 true，则允许降级为未初始化的客户端
  Future<Dio> getClient({bool allowDowngrade = false}) async {
    if (!_initialized && allowDowngrade) {
      return _biliClient ??= _buildBiliClient();
    }

    await ensureInitialized();
    return _biliClientByAccount ??= _buildBiliClientByAccount();
  }

  Future<AccountData> getAccount() async {
    await ensureInitialized();
    return _currentAccount;
  }

  Future<Result<GetLoginQrCodeResponse>> getLoginQrCode() async {
    return _biliAuthApiService.getLoginQrCode();
  }

  Future<Result<GetQrCodeStatusResponse>> getQrCodeStatus({required String key}) async {
    return _biliAuthApiService.getQrCodeStatus(key: key);
  }

  /// 更新现有账户，如果不存在则创建新的
  Future<void> updateAccount(AccountData newAccount) async {
    await _accountConfig.ensureInitialized();

    try {
      final account = _accountConfig.findAccountByUid(newAccount.uid);
      account.mergeWith(newAccount);
      _accountConfig.updateAccount(account);
    } catch (_) {
      _accountConfig.addAccount(newAccount);
    }

    await _accountConfig.save();
  }

  Future<List<AccountData>> getAccounts() async {
    return [..._accountConfig.data.accounts];
  }

  Future<void> removeAccount(String accountId) async {
    _accountConfig.removeAccount(accountId);
    if (_currentAccount.uid == accountId) {
      await switchAccount('0');
    }
    notifyListeners();
  }

  Future<Result<GetSelfInfoResponse>> getSelfInfo() async {
    return _biliAuthApiService.getSelfInfo();
  }
}
