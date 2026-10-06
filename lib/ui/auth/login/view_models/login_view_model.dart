import 'dart:async';

import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_login_qr_code_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_qr_code_status_response.dart';
import 'package:better_bilibili/domain/models/bilibili/account.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class LoginViewModel extends SafeChangeNotifier {
  final AuthRepository _authRepository;

  LoginViewModel({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository {
    getLoginQrCode = Command0(_getLoginQrCode);
    getQrCodeStatus = Command1<GetQrCodeStatusResponse, String>((key) => _getQrCodeStatus(key));
  }

  @override
  void dispose() {
    stopPolling();
    getLoginQrCode.dispose();
    getQrCodeStatus.dispose();
    super.dispose();
  }

  static const int tabCount = 4;
  int _tabIndex = 0;
  int get tabIndex => _tabIndex;
  void onTabChanged(int index) {
    if (_tabIndex == index) return;
    _tabIndex = index;

    if (index == 2) {
      getLoginQrCode.execute();
    } else {
      stopPolling();
      _qrCodeStatus = null;
      _qrCodeUrl = null;
    }

    notifyListeners();
  }

  late final Command0<GetLoginQrCodeResponse> getLoginQrCode;
  late final Command1<GetQrCodeStatusResponse, String> getQrCodeStatus;
  QrCodeStatus? _qrCodeStatus;
  QrCodeStatus? get qrCodeStatus => _qrCodeStatus;
  String? _qrCodeUrl;
  String? get qrCodeUrl => _qrCodeUrl;
  Timer? _pollTimer;

  Future<Result<GetLoginQrCodeResponse>> _getLoginQrCode() async {
    _qrCodeUrl = null;
    _qrCodeStatus = null;
    notifyListeners();

    final result = await _authRepository.getLoginQrCode();
    switch (result) {
      case Ok(:final value):
        _qrCodeUrl = value.url;
        _qrCodeStatus = QrCodeStatus.waiting;
        _startPolling(value.key);
        return Result.ok(value);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<GetQrCodeStatusResponse>> _getQrCodeStatus(String key) async {
    final result = await _authRepository.getQrCodeStatus(key: key);
    switch (result) {
      case Ok(:final value):
        _qrCodeStatus = value.status;
        if (value.status == QrCodeStatus.expired) {
          stopPolling();
        }
        if (value.status == QrCodeStatus.success) {
          final resp = value as ConfirmedQrCodeStatusResponse;
          final userId = resp.dedeUserId;

          final builder = AccountBuilder();
          builder.userId = userId;
          builder.accessToken = resp.accessToken;
          builder.tokenExpiredAt = resp.tokenExpiredAt;
          builder.refreshToken = resp.refreshToken;
          builder.dedeUserID = resp.dedeUserId;
          builder.dedeUserIdCkMd5 = resp.dedeUserIdCkMd5;
          builder.sid = resp.sid;
          builder.biliJct = resp.biliJct;

          await _authRepository.createAccount(builder);
          await _authRepository.switchAccount(userId);
        }
        notifyListeners();
        return Result.ok(value);
      case Error(:final error):
        return Result.error(error);
    }
  }

  void refreshQrLogin() {
    stopPolling();
    getLoginQrCode.execute();
    notifyListeners();
  }

  void _startPolling(String qrCodeKey) {
    _pollTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => getQrCodeStatus.execute(qrCodeKey),
    );
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }
}
