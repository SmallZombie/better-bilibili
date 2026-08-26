import 'package:better_bilibili/domain/models/bilibili/user.dart';

class GetUserInfoResponse {
  final String id;
  final String nickname;
  final String avatar;
  final AvatarFrame? avatarFrame;
  final String banner;
  final String? description;
  final UserLevel level;
  final UserVip? vip;
  final LiveRoom? liveRoom;
  final Achievement? achievement;
  final int sponsorCount;
  final String? birthDate;
  final List<String> tags;
  final FanBadge? fanBadge;
  final String? verified;
  final String? organizationVerified;
  final GenderEnum gender;

  GetUserInfoResponse({
    required this.id,
    required this.nickname,
    required this.avatar,
    this.avatarFrame,
    required this.banner,
    this.description,
    required this.level,
    this.vip,
    this.liveRoom,
    this.achievement,
    required this.sponsorCount,
    this.birthDate,
    required this.tags,
    this.fanBadge,
    this.verified,
    this.organizationVerified,
    required this.gender,
  });

  factory GetUserInfoResponse.fromJson(Map<String, dynamic> json) {
    String? descriptionHandler(String str) {
      if (str.isEmpty) return null;
      if (str.contains('请允许我们在此献上最后的告别')) {
        return null;
      }

      return str;
    }

    return GetUserInfoResponse(
      id: json['mid'].toString(),
      nickname: json['name'],
      avatar: json['face'],
      avatarFrame: json['pendant']['n_pid'] == 0 ? null : .fromJson(json['pendant']),
      banner: json['top_photo_v2']['l_200h_img'],
      description: descriptionHandler(json['sign']),
      level: json['is_senior_member'] == 1
          ? .lv6p
          : switch (json['level']) {
              0 => .lv0,
              1 => .lv1,
              2 => .lv2,
              3 => .lv3,
              4 => .lv4,
              5 => .lv5,
              6 => .lv6,
              _ => throw Exception('Invalid user level: ${json['level']}'),
            },
      vip: json['vip']['status'] == 0
          ? null
          : UserVip(
              type: switch (json['vip']['type']) {
                1 => .normal,
                2 => .year,
                _ => throw Exception('Invalid user vip type: ${json['vip']['type']}'),
              },
              expiredAt: json['vip']['due_date'],
              labelImage: json['vip']['label']['img_label_uri_hans_static'],
            ),
      liveRoom: json['live_room'] == null ? null : .fromJson(json['live_room']),
      achievement: json['nameplate']['nid'] == 0 ? null : .fromJson(json['nameplate']),
      sponsorCount: json['elec']['show_info']['total'],
      birthDate: json['birthday'].isEmpty ? null : json['birthday'],
      tags: json['tags'] == null ? [] : json['tags'].cast<String>(),
      fanBadge: json['fans_medal']['detail'] == null ? null : .fromJson(json['fans_medal']),
      verified: json['attestation']['type'] == 2 ? json['attestation']['common_info']['title'] : null,
      organizationVerified: json['attestation']['type'] == 3 ? json['attestation']['common_info']['title'] : null,
      gender: switch (json['sex']) {
        '男' => .male,
        '女' => .female,
        _ => .unknown,
      },
    );
  }
}

class AvatarFrame {
  final String id;
  final String url;

  AvatarFrame({
    required this.id,
    required this.url,
  });

  factory AvatarFrame.fromJson(Map<String, dynamic> json) {
    return AvatarFrame(
      id: json['n_pid'].toString(),
      url: json['image_enhance'],
    );
  }
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['nid'].toString(),
      name: json['name'],
      description: json['condition'],
      icon: json['image'],
    );
  }
}

class FanBadge {
  final String id;
  final String name;
  final int level;
  final String levelColor;
  final String nameColor;
  final String backgroundColorStart;
  final String backgroundColorEnd;
  final String borderColor;

  FanBadge({
    required this.id,
    required this.name,
    required this.level,
    required this.levelColor,
    required this.nameColor,
    required this.backgroundColorStart,
    required this.backgroundColorEnd,
    required this.borderColor,
  });

  factory FanBadge.fromJson(Map<String, dynamic> json) {
    return FanBadge(
      id: json['detail']['medal_id'].toString(),
      name: json['detail']['medal_name'],
      level: json['detail']['level'],
      levelColor: json['detail']['medal_color_level'],
      nameColor: json['detail']['medal_color_name'],
      backgroundColorStart: json['detail']['medal_color'],
      backgroundColorEnd: json['detail']['medal_color_end'],
      borderColor: json['detail']['medal_color_border'],
    );
  }
}

class LiveRoom {
  final String id;
  final String cover;
  final String title;
  final bool isLive;

  LiveRoom({
    required this.id,
    required this.cover,
    required this.title,
    required this.isLive,
  });

  factory LiveRoom.fromJson(Map<String, dynamic> json) {
    return LiveRoom(
      id: json['roomid'].toString(),
      cover: json['cover'],
      title: json['title'],
      isLive: json['liveStatus'] == 1,
    );
  }
}

enum GenderEnum { unknown, male, female, other }
