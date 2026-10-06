import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_login_qr_code_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_qr_code_status_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_self_info_response.dart';
import 'package:better_bilibili/domain/models/bilibili/account.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

class AuthRepositoryMock extends ChangeNotifier implements AuthRepository {
  @override
  Future<Result<GetLoginQrCodeResponse>> getLoginQrCode() {
    // TODO: implement getLoginQrCode
    throw UnimplementedError();
  }

  @override
  Future<Result<GetQrCodeStatusResponse>> getQrCodeStatus({required String key}) {
    // TODO: implement getQrCodeStatus
    throw UnimplementedError();
  }

  @override
  Future<Result<GetSelfInfoResponse>> getSelfInfo() {
    // TODO: implement getSelfInfo
    throw UnimplementedError();
  }

  @override
  Future<Account> getAccount([String? userId]) {
    // TODO: implement getAccount
    throw UnimplementedError();
  }

  @override
  Future<Dio> getClient({required ClientTypeEnum type, String? userId}) {
    // TODO: implement getClient
    throw UnimplementedError();
  }

  @override
  Future<void> removeAccount(String accountId) {
    // TODO: implement removeAccount
    throw UnimplementedError();
  }

  @override
  Future<void> switchAccount(String nextAccountId) {
    // TODO: implement switchAccount
    throw UnimplementedError();
  }

  @override
  Future<void> createAccount(AccountBuilder builder) {
    // TODO: implement updateAndSaveAccount
    throw UnimplementedError();
  }

  @override
  Future<List<Account>> getAccounts() {
    // TODO: implement getAccounts
    throw UnimplementedError();
  }

  @override
  // TODO: implement hasLogin
  bool get hasLogin => throw UnimplementedError();

  @override
  Future<void> updateAccount(Account account) {
    // TODO: implement updateAccount
    throw UnimplementedError();
  }

  @override
  Future<String> getCurrentAccountId() {
    // TODO: implement getCurrentAccountId
    throw UnimplementedError();
  }
}
