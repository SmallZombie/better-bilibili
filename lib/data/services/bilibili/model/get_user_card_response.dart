import 'package:better_bilibili/data/services/bilibili/model/get_user_info_response.dart';

class GetUserCardResponse {
  final String id;
  final String nickname;
  final String avatar;
  final AvatarFrame avatarFrame;
  final int level;
  final int videoCount;
  final int followCount;
  final int fansCount;
  final int likeCount;
  final String banner;
  final String description;

  const GetUserCardResponse({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.avatarFrame,
    required this.level,
    required this.videoCount,
    required this.followCount,
    required this.fansCount,
    required this.likeCount,
    required this.banner,
    required this.description,
  });
}
