import 'dart:convert';
import 'dart:io';

import 'package:better_bilibili/data/services/bilibili/model/get_login_qr_code_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_qr_code_status_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_self_info_response.dart';
import 'package:better_bilibili/domain/exceptions/bili_http_exception.dart';
import 'package:better_bilibili/domain/models/bilibili/account.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_buvid_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_ticket_response.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

class BiliAuthWebApiService {
  Future<Dio> Function() getClient;
  Future<Account> Function() getAccount;

  BiliAuthWebApiService({required this.getClient, required this.getAccount});

  void _checkResponse(Response resp) {
    if (resp.data['code'] != 0) {
      throw BiliHttpException(resp.data['code'], resp.data['message']);
    }
  }

  Result<T> _handleError<T>(Object error) {
    if (error is DioException) {
      final resp = error.response;
      if (resp == null) {
        return Result.error(Exception('Unknown error: ${error.message}'));
      }
      return Result.error(Exception('${resp.statusCode}: ${resp.data}'));
    } else if (error is Exception) {
      return Result.error(error);
    } else if (error is Error) {
      assert(false, 'Something went wrong');
      return Result.error(Exception(error.toString()));
    } else {
      assert(false, 'What did you throw?');
      return Result.error(Exception('Unknown error'));
    }
  }

  /// 获取 Buvid3 和 Buvid4，只在没有的时候获取，不要反复获取
  /// 登录与否返回的内容是不一样的，有 session 时务必传入
  Future<Result<GetBuvidResponse>> getBuvid() async {
    final client = await getClient();

    try {
      final resp = await client.get('https://api.bilibili.com/x/frontend/finger/spi_v2');

      _checkResponse(resp);

      return Result.ok(
        GetBuvidResponse(
          buvid3: resp.data['data']['b_3'],
          buvid4: resp.data['data']['b_4'],
        ),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 获取 Bili Ticket
  /// 登录与否返回的内容是不一样的，有 session 时务必传入
  Future<Result<GetTicketResponse>> getTicket() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final message = 'ts$timestamp';
    final key = 'XgwSnGZ1p';

    // 使用 HMAC-SHA256 加密
    final hmacSha256 = Hmac(sha256, utf8.encode(key));
    final digest = hmacSha256.convert(utf8.encode(message));
    final hexsign = digest.toString();

    final client = await getClient();
    final account = await getAccount();

    try {
      final resp = await client.post(
        'https://api.bilibili.com/bapis/bilibili.api.ticket.v1.Ticket/GenWebTicket',
        queryParameters: {
          'key_id': 'ec02',
          'hexsign': hexsign,
          'context[ts]': timestamp,
          'csrf': account is LoginedAccount ? account.biliJct : '',
        },
      );

      _checkResponse(resp);

      return Result.ok(
        GetTicketResponse(
          ticket: resp.data['data']['ticket'],
          expiredAt: resp.data['data']['created_at'] + resp.data['data']['ttl'],
        ),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 获取 wbi 签名相关的两个 key，等同于 nav，
  /// 该接口不会因为未登录而报 -101
  ///
  /// 获取用户信息请使用 [BiliUserWebApiService.getSelfInfo]
  Future<Result<GetSelfInfoResponse>> getWbiKeys() async {
    final client = await getClient();

    try {
      final resp = await client.get('https://api.bilibili.com/x/web-interface/nav');

      if (resp.data['code'] != -101) {
        _checkResponse(resp);
      }

      return Result.ok(
        GetSelfInfoResponse(
          wbiImgKey: resp.data['data']['wbi_img']['img_url'].split('/').last.split('.').first,
          wbiSubKey: resp.data['data']['wbi_img']['sub_url'].split('/').last.split('.').first,
        ),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Result<GetLoginQrCodeResponse>> getLoginQrCode() async {
    final client = await getClient();

    try {
      final resp = await client.get('https://passport.bilibili.com/x/passport-login/web/qrcode/generate');

      _checkResponse(resp);

      return Result.ok(
        GetLoginQrCodeResponse(
          url: resp.data['data']['url'],
          key: resp.data['data']['qrcode_key'],
        ),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Result<GetQrCodeStatusResponse>> getQrCodeStatus(String key) async {
    assert(key.isNotEmpty);

    final client = await getClient();

    try {
      final resp = await client.get(
        'https://passport.bilibili.com/x/passport-login/web/qrcode/poll',
        queryParameters: {'qrcode_key': key},
      );

      _checkResponse(resp);

      switch (resp.data['data']['code']) {
        // 未扫描
        case 86101:
          return Result.ok(GetQrCodeStatusResponse(status: .waiting));
        // 已扫描未确认
        case 86090:
          return Result.ok(GetQrCodeStatusResponse(status: .scanned));
        // 过期
        case 86038:
          return Result.ok(GetQrCodeStatusResponse(status: .expired));
        case 0:
          late String sessdata;
          late String biliJct;
          late String dedeUserId;
          late String dedeUserIdCkMd5;
          late String sid;
          late int sessDataExpiredAt;

          final setCookies = resp.headers['set-cookie'];
          for (final i in setCookies ?? []) {
            if (i.startsWith('SESSDATA=')) {
              // (?<=SESSDATA=).*?(?=;)
              final sessdataMatch = RegExp(r'(?<=SESSDATA=).*?(?=;)').firstMatch(i);
              if (sessdataMatch != null) {
                sessdata = sessdataMatch.group(0)!;
              } else {
                throw Exception('SESSDATA not found in SESSDATA cookie');
              }

              // (?<=Expires=).*?(?=;)
              // 匹配出来是 "Fri, 14 Aug 2026 10:22:08 GMT"
              final expiresMatch = RegExp(r'(?<=Expires=).*?(?=;)').firstMatch(i);
              if (expiresMatch != null) {
                final expiresString = expiresMatch.group(0)!;
                sessDataExpiredAt = HttpDate.parse(expiresString).millisecondsSinceEpoch;
              } else {
                throw Exception('Expires not found in SESSDATA cookie');
              }
            } else if (i.startsWith('bili_jct=')) {
              biliJct = i.split('=')[1].split(';').first;
            } else if (i.startsWith('DedeUserID=')) {
              dedeUserId = i.split('=')[1].split(';').first;
            } else if (i.startsWith('DedeUserID__ckMd5=')) {
              dedeUserIdCkMd5 = i.split('=')[1].split(';').first;
            } else if (i.startsWith('sid=')) {
              sid = i.split('=')[1].split(';').first;
            }
          }

          return Result.ok(
            ConfirmedQrCodeStatusResponse(
              status: QrCodeStatus.success,
              accessToken: sessdata,
              tokenExpiredAt: sessDataExpiredAt,
              refreshToken: resp.data['data']['refresh_token'],
              biliJct: biliJct,
              dedeUserId: dedeUserId,
              dedeUserIdCkMd5: dedeUserIdCkMd5,
              sid: sid,
            ),
          );
        default:
          throw Exception('Unknown code: ${resp.data['data']['code']}');
      }
    } catch (e) {
      return _handleError(e);
    }
  }
}
