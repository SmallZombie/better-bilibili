class Account {
  final String userId;
  final String wbiImgKey;
  final String wbiSubKey;
  final String buvid3;
  final String buvid4;
  final String biliTicket;
  final int biliTicketExpiredAt;
  final String uuid;
  final String buvidFp;
  final String userAgent;
  final int windowWidth;
  final int windowHeight;
  final String brand;
  final String model;

  const Account({
    required this.userId,
    required this.wbiImgKey,
    required this.wbiSubKey,
    required this.buvid3,
    required this.buvid4,
    required this.biliTicket,
    required this.biliTicketExpiredAt,
    required this.uuid,
    required this.buvidFp,
    required this.userAgent,
    required this.windowWidth,
    required this.windowHeight,
    required this.brand,
    required this.model,
  });
}

class LoginedAccount extends Account {
  final String accessToken;
  final String refreshToken;
  final int tokenExpiredAt;
  final String dedeUserID;
  final String dedeUserIdCkMd5;
  final String sid;
  final String biliJct;

  LoginedAccount({
    required super.userId,
    required super.wbiImgKey,
    required super.wbiSubKey,
    required super.buvid3,
    required super.buvid4,
    required super.biliTicket,
    required super.biliTicketExpiredAt,
    required super.uuid,
    required super.buvidFp,
    required super.userAgent,
    required super.windowWidth,
    required super.windowHeight,
    required super.brand,
    required super.model,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenExpiredAt,
    required this.dedeUserID,
    required this.dedeUserIdCkMd5,
    required this.sid,
    required this.biliJct,
  });
}

class AccountBuilder {
  String? userId;
  String? accessToken;
  String? wbiImgKey;
  String? wbiSubKey;
  String? buvid3;
  String? buvid4;
  String? biliTicket;
  int? biliTicketExpiredAt;
  String? uuid;
  String? buvidFp;
  String? userAgent;
  int? windowWidth;
  int? windowHeight;
  String? brand;
  String? model;
  String? refreshToken;
  int? tokenExpiredAt;
  String? dedeUserID;
  String? dedeUserIdCkMd5;
  String? sid;
  String? biliJct;

  bool get isLogin => [
    accessToken,
    refreshToken,
    tokenExpiredAt,
    dedeUserID,
    dedeUserIdCkMd5,
    sid,
    biliJct,
  ].every((v) => !const [null, 0, ''].contains(v));

  Account build() {
    assert(userId?.isNotEmpty == true);
    assert(wbiImgKey?.isNotEmpty == true);
    assert(wbiSubKey?.isNotEmpty == true);
    assert(buvid3?.isNotEmpty == true);
    assert(buvid4?.isNotEmpty == true);
    assert(biliTicket?.isNotEmpty == true);
    assert(biliTicketExpiredAt != null && biliTicketExpiredAt! > 0);
    assert(uuid?.isNotEmpty == true);
    assert(buvidFp?.isNotEmpty == true);
    assert(userAgent?.isNotEmpty == true);
    assert(windowWidth != null && windowWidth! > 0);
    assert(windowHeight != null && windowHeight! > 0);
    assert(brand?.isNotEmpty == true);
    assert(model?.isNotEmpty == true);

    assert(accessToken == null || accessToken!.isNotEmpty);
    assert(refreshToken == null || refreshToken!.isNotEmpty);
    assert(tokenExpiredAt == null || tokenExpiredAt! > 0);
    assert(dedeUserID == null || dedeUserID!.isNotEmpty);
    assert(dedeUserIdCkMd5 == null || dedeUserIdCkMd5!.isNotEmpty);
    assert(sid == null || sid!.isNotEmpty);
    assert(biliJct == null || biliJct!.isNotEmpty);

    return _build();
  }

  Account buildTemporary() {
    assert(userId?.isNotEmpty == true);

    return _build();
  }

  Account _build() {
    if (isLogin) {
      return LoginedAccount(
        userId: userId!,
        wbiImgKey: wbiImgKey ?? '',
        wbiSubKey: wbiSubKey ?? '',
        buvid3: buvid3 ?? '',
        buvid4: buvid4 ?? '',
        biliTicket: biliTicket ?? '',
        biliTicketExpiredAt: biliTicketExpiredAt ?? 0,
        uuid: uuid ?? '',
        buvidFp: buvidFp ?? '',
        userAgent: userAgent ?? '',
        windowWidth: windowWidth ?? 0,
        windowHeight: windowHeight ?? 0,
        brand: brand ?? '',
        model: model ?? '',
        accessToken: accessToken!,
        refreshToken: refreshToken!,
        tokenExpiredAt: tokenExpiredAt!,
        dedeUserID: dedeUserID!,
        dedeUserIdCkMd5: dedeUserIdCkMd5!,
        sid: sid!,
        biliJct: biliJct!,
      );
    } else {
      return Account(
        userId: userId!,
        wbiImgKey: wbiImgKey ?? '',
        wbiSubKey: wbiSubKey ?? '',
        buvid3: buvid3 ?? '',
        buvid4: buvid4 ?? '',
        biliTicket: biliTicket ?? '',
        biliTicketExpiredAt: biliTicketExpiredAt ?? 0,
        uuid: uuid ?? '',
        buvidFp: buvidFp ?? '',
        userAgent: userAgent ?? '',
        windowWidth: windowWidth ?? 0,
        windowHeight: windowHeight ?? 0,
        brand: brand ?? '',
        model: model ?? '',
      );
    }
  }
}
