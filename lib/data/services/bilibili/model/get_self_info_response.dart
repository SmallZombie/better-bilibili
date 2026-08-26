import 'package:better_bilibili/domain/models/bilibili/user.dart';

class GetSelfInfoResponse {
  final String wbiImgKey;
  final String wbiSubKey;

  GetSelfInfoResponse({required this.wbiImgKey, required this.wbiSubKey});
}

class GetSelfInfoLogginResponse extends GetSelfInfoResponse {
  final String nickname;
  final String avatar;
  final String uid;
  final String? avatarFrame;
  final SelfLevel level;
  final UserVip vip;
  final UserWallet wallet;
  final int creditScore;
  final bool isDCM;

  GetSelfInfoLogginResponse({
    required super.wbiImgKey,
    required super.wbiSubKey,
    required this.nickname,
    required this.avatar,
    required this.uid,
    this.avatarFrame,
    required this.level,
    required this.vip,
    required this.wallet,
    required this.creditScore,
    required this.isDCM,
  });
}
