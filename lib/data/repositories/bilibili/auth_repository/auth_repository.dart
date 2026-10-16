import 'package:better_bilibili/data/services/bilibili/model/get_login_qr_code_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_qr_code_status_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_self_info_response.dart';
import 'package:better_bilibili/domain/models/bilibili/account.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

abstract interface class AuthRepository implements Listenable {
  bool get hasLogin;
  Future<Dio> getClient({required ClientTypeEnum type, String? userId});
  Future<String> getCurrentAccountId();
  Future<Account> getAccount([String? userId]);
  Future<void> createAccount(AccountBuilder builder);
  Future<void> removeAccount(String accountId);
  Future<void> updateAccount(Account account);
  Future<void> switchAccount(String nextAccountId);
  Future<List<Account>> getAccounts();

  Future<Result<GetLoginQrCodeResponse>> getLoginQrCode();
  Future<Result<GetQrCodeStatusResponse>> getQrCodeStatus(String key);
  Future<Result<GetSelfInfoResponse>> getSelfInfo();
}

enum ClientTypeEnum { web, app }
