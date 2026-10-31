import 'dart:async';

import 'package:better_bilibili/data/services/bilibili/model/get_login_qr_code_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_qr_code_status_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_self_info_response.dart';
import 'package:better_bilibili/domain/models/bilibili/account.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:dio/dio.dart';

abstract interface class AuthRepository {
  bool get hasLogin;
  Future<Dio> getClient({required ClientTypeEnum type, String? userId});
  Future<String> getCurrentAccountId();
  Future<Account> getAccount([String? userId]);
  Future<void> createAccount(AccountBuilder builder);
  Future<void> removeAccount(String accountId);
  Future<void> updateAccount(Account account);
  Future<void> switchAccount(String nextAccountId);
  Future<List<Account>> getAccounts();

  AuthRepositoryStream get stream;

  Future<Result<GetLoginQrCodeResponse>> getLoginQrCode();
  Future<Result<GetQrCodeStatusResponse>> getQrCodeStatus(String key);
  Future<Result<GetSelfInfoResponse>> getWbiKeys();
}

enum ClientTypeEnum { web, app }

class AuthRepositoryStream {
  final Stream<AccountBuilder> create;
  final Stream<String> remove;
  final Stream<Account> update;
  final Stream<String> current;

  const AuthRepositoryStream({
    required this.create,
    required this.remove,
    required this.update,
    required this.current,
  });
}
