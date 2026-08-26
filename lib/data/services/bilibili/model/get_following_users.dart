enum GetFollowingUsersOrderEnum {
  followTimeAsc,
  followTimeDesc,
  viewTimeAsc,
  viewTimeDesc,
}

class GetFollowingUsersResponse {
  final List<FollowingUser> list;
  final int total;

  GetFollowingUsersResponse({
    required this.list,
    required this.total,
  });
}

class FollowingUser {
  final String id;
  final String avatar;
  final String nickname;
  final String? description;
  final bool isVip;
  final bool isVerified;
  final bool isEnterpriseVerified;
  final bool isEarlyFan;
  final bool amEarlyFan;
  final bool isFollowing;
  final bool isFan;

  FollowingUser({
    required this.id,
    required this.avatar,
    required this.nickname,
    required this.description,
    required this.isVip,
    required this.isVerified,
    required this.isEnterpriseVerified,
    required this.isEarlyFan,
    required this.amEarlyFan,
    required this.isFollowing,
    required this.isFan,
  });

  factory FollowingUser.fromJson(Map<String, dynamic> json) {
    return FollowingUser(
      id: json['mid'].toString(),
      avatar: json['face'],
      nickname: json['uname'],
      description: json['sign'].isEmpty ? null : json['sign'],
      isVip: json['vip']['vipStatus'] == 1,
      isVerified: json['official_verify']['type'] == 0,
      isEnterpriseVerified: json['official_verify']['type'] == 1,
      isEarlyFan: json['contract_info']?['is_contractor'] == true,
      amEarlyFan: json['contract_info']?['is_contract'] == true,
      isFollowing: json['attribute'] == 2,
      isFan: false,
    );
  }
}
