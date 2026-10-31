import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_login_qr_code_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_qr_code_status_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_self_info_response.dart';
import 'package:better_bilibili/domain/models/bilibili/account.dart';
import 'package:better_bilibili/utils/bilibili/bili_util.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

class AuthRepositoryMock extends ChangeNotifier implements AuthRepository {
  final _client = Dio();

  @override
  Future<void> createAccount(AccountBuilder builder) {
    return Future.value(null);
  }

  @override
  Future<Account> getAccount([String? userId]) {
    final device = randomPhoneInfo();
    return Future.value(
      Account(
        userId: 'user_mock',
        wbiImgKey: 'mock_wbi_img_key',
        wbiSubKey: 'mock_wbi_sub_key',
        buvid3: 'mock_buvid3',
        buvid4: 'mock_buvid4',
        biliTicket: 'mock_ticket',
        biliTicketExpiredAt: DateTime.now().millisecondsSinceEpoch + 24 * 60 * 3,
        uuid: 'mock_uuid',
        buvidFp: 'mock_buvid_fp',
        userAgent: 'mock_user_agent',
        windowWidth: 1920,
        windowHeight: 1080,
        brand: device.$1,
        model: device.$2,
      ),
    );
  }

  @override
  Future<List<Account>> getAccounts() async {
    return Future.value([await getAccount()]);
  }

  @override
  Future<Dio> getClient({required ClientTypeEnum type, String? userId}) {
    return Future.value(_client);
  }

  @override
  Future<String> getCurrentAccountId() {
    return Future.value('user_mock');
  }

  @override
  Future<Result<GetLoginQrCodeResponse>> getLoginQrCode() {
    return Future.value(
      Result.ok(
        GetLoginQrCodeResponse(
          url: 'https://i2.hdslb.com/bfs/face/0c9448726526297021ba4f3c69099388232d60b3.jpg',
          key: 'mock_key',
        ),
      ),
    );
  }

  int _qrCodeStatusCounter = 0;

  @override
  Future<Result<GetQrCodeStatusResponse>> getQrCodeStatus(String key) {
    ++_qrCodeStatusCounter;

    if (_qrCodeStatusCounter > 5) {
      _qrCodeStatusCounter = 0;
      return Future.value(
        Result.ok(
          ConfirmedQrCodeStatusResponse(
            status: .success,
            accessToken: 'mock_token',
            biliJct: 'mock_jct',
            dedeUserId: 'mock_dede_user_id',
            dedeUserIdCkMd5: 'moke_dede_user_id_ck_md5',
            refreshToken: 'mock_refresh_token',
            sid: 'mock_sid',
            tokenExpiredAt: DateTime.now().millisecondsSinceEpoch + 24 * 60 * 3,
          ),
        ),
      );
    }
    if (_qrCodeStatusCounter > 2) {
      return Future.value(Result.ok(GetQrCodeStatusResponse(status: .scanned)));
    }
    return Future.value(Result.ok(GetQrCodeStatusResponse(status: .waiting)));
  }

  @override
  Future<Result<GetSelfInfoResponse>> getWbiKeys() {
    return Future.value(
      Result.ok(
        GetSelfInfoResponse(
          wbiImgKey: 'mock_wbi_img_key',
          wbiSubKey: 'mock_wbi_sub_key',
        ),
      ),
    );
  }

  @override
  bool get hasLogin => true;

  @override
  Future<void> removeAccount(String accountId) {
    return Future.value(null);
  }

  @override
  Future<void> switchAccount(String nextAccountId) {
    return Future.value(null);
  }

  @override
  Future<void> updateAccount(Account account) {
    return Future.value(null);
  }

  @override
  // TODO: implement stream
  AuthRepositoryStream get stream => throw UnimplementedError();
}
