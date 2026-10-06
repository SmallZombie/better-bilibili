import 'dart:convert';
import 'dart:io';

import 'package:better_bilibili/data/services/bilibili/model/get_login_qr_code_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_qr_code_status_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_self_info_response.dart';
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

  /// 获取 Buvid3 和 Buvid4，只在没有的时候获取，不要反复获取
  /// 登录与否返回的内容是不一样的，有 session 时务必传入
  Future<Result<GetBuvidResponse>> getBuvid() async {
    final client = await getClient();
    final result = await client.get('https://api.bilibili.com/x/frontend/finger/spi_v2');

    if (result.data['code'] != 0) {
      return Result.error(Exception('${result.data['code']}: ${result.data['message']}'));
    }

    return Result.ok(
      GetBuvidResponse(
        buvid3: result.data['data']['b_3'],
        buvid4: result.data['data']['b_4'],
      ),
    );
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

    final result = await client.post(
      'https://api.bilibili.com/bapis/bilibili.api.ticket.v1.Ticket/GenWebTicket',
      queryParameters: {
        'key_id': 'ec02',
        'hexsign': hexsign,
        'context[ts]': timestamp,
        'csrf': account is LoginedAccount ? account.biliJct : '',
      },
    );

    if (result.data['code'] != 0) {
      return Result.error(Exception('${result.data['code']}: ${result.data['message']}'));
    }

    return Result.ok(
      GetTicketResponse(
        ticket: result.data['data']['ticket'],
        expiredAt: result.data['data']['created_at'] + result.data['data']['ttl'],
      ),
    );
  }

  /// 获取账户基本信息，等同于 nav
  /// 该接口不会因为未登录而报 -101
  /// 传入 session 返回登录后的信息，否则返回 wbi 签名
  Future<Result<GetSelfInfoResponse>> getSelfInfo() async {
    final client = await getClient();
    final result = await client.get('https://api.bilibili.com/x/web-interface/nav');

    if (![0, -101].contains(result.data['code'])) {
      return Result.error(Exception('${result.data['code']}: ${result.data['message']}'));
    }

    return Result.ok(
      GetSelfInfoResponse(
        wbiImgKey: result.data['data']['wbi_img']['img_url'].split('/').last.split('.').first,
        wbiSubKey: result.data['data']['wbi_img']['sub_url'].split('/').last.split('.').first,
      ),
    );
  }

  Future<Result<GetLoginQrCodeResponse>> getLoginQrCode() async {
    final client = await getClient();
    final result = await client.get('https://passport.bilibili.com/x/passport-login/web/qrcode/generate');

    if (result.data['code'] != 0) {
      return Result.error(Exception('${result.data['code']}: ${result.data['message']}'));
    }

    return Result.ok(
      GetLoginQrCodeResponse(
        url: result.data['data']['url'],
        key: result.data['data']['qrcode_key'],
      ),
    );
  }

  Future<Result<GetQrCodeStatusResponse>> getQrCodeStatus({required String key}) async {
    assert(key.isNotEmpty);

    try {
      final client = await getClient();
      final result = await client.get(
        'https://passport.bilibili.com/x/passport-login/web/qrcode/poll',
        queryParameters: {'qrcode_key': key},
      );

      if (result.data['code'] != 0) {
        return Result.error(Exception('${result.data['code']}: ${result.data['message']}'));
      }

      switch (result.data['data']['code']) {
        // 未扫描
        case 86101:
          return Result.ok(GetQrCodeStatusResponse(status: QrCodeStatus.waiting));
        // 已扫描未确认
        case 86090:
          return Result.ok(GetQrCodeStatusResponse(status: QrCodeStatus.scanned));
        // 过期
        case 86038:
          return Result.ok(GetQrCodeStatusResponse(status: QrCodeStatus.expired));
        case 0:
          late String sessdata;
          late String biliJct;
          late String dedeUserId;
          late String dedeUserIdCkMd5;
          late String sid;
          late int sessDataExpiredAt;

          final setCookies = result.headers['set-cookie'];
          for (final i in setCookies ?? <String>[]) {
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
              refreshToken: result.data['data']['refresh_token'],
              biliJct: biliJct,
              dedeUserId: dedeUserId,
              dedeUserIdCkMd5: dedeUserIdCkMd5,
              sid: sid,
            ),
          );
        default:
          return Result.error(Exception('${result.data['code']}: unknown code: ${result.data['data']['code']}'));
      }
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }
}
