class GetQrCodeStatusResponse {
  final QrCodeStatus status;

  GetQrCodeStatusResponse({required this.status});
}

enum QrCodeStatus {
  waiting,
  scanned,
  expired,
  success,
}

class ConfirmedQrCodeStatusResponse extends GetQrCodeStatusResponse {
  final String accessToken;
  final int tokenExpiredAt;
  final String refreshToken;
  final String biliJct;
  final String dedeUserId;
  final String dedeUserIdCkMd5;
  final String sid;

  ConfirmedQrCodeStatusResponse({
    required super.status,
    required this.accessToken,
    required this.tokenExpiredAt,
    required this.refreshToken,
    required this.biliJct,
    required this.dedeUserId,
    required this.dedeUserIdCkMd5,
    required this.sid,
  });
}
