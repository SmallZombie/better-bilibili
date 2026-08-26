class GetUserProfileSettingsResponse {
  /// 1 = 我的稿件
  /// 2 = 我的收藏夹
  /// 3 = 订阅番剧
  /// 4 = 订阅标签
  /// 5 = 最近投币的视频
  /// 6 = 我的圈子
  /// 7 = 我的视频列表
  /// 8 = 我的专栏
  /// 9 = 我的相簿
  /// 10 = 最近点赞的视频
  /// 21 = 公告
  /// 22 = 直播间
  /// 23 = 个人资料
  /// 25 = 最近玩过的游戏
  /// 26 = 预约
  final List<int> moduleSorting;
  final UserPrivacySettings privacySetting;

  GetUserProfileSettingsResponse({required this.privacySetting, required this.moduleSorting});

  factory GetUserProfileSettingsResponse.fromJson(Map<String, dynamic> json) {
    return GetUserProfileSettingsResponse(
      moduleSorting: (json['index_order'] as List).map((v) => v['id'] as int).toList(),
      privacySetting: UserPrivacySettings.fromJson(json['privacy']),
    );
  }
}

class UserPrivacySettings {
  final bool favorites;
  final bool subscribedMovie;
  final bool likedVideo;
  final bool coinedVideo;
  final bool followedUsers;
  final bool fans;
  final bool birthday;
  final bool tags;
  final bool school;
  final bool playedGame;
  final bool fanBadgeList;
  final bool activeFanBadge;
  final bool subscribedManga;
  final bool dressedUp;
  final bool liveStreamReplay;
  final bool course;
  final bool sponsorVideo;

  UserPrivacySettings({
    required this.favorites,
    required this.subscribedMovie,
    required this.likedVideo,
    required this.coinedVideo,
    required this.followedUsers,
    required this.fans,
    required this.birthday,
    required this.tags,
    required this.school,
    required this.playedGame,
    required this.fanBadgeList,
    required this.activeFanBadge,
    required this.subscribedManga,
    required this.dressedUp,
    required this.liveStreamReplay,
    required this.course,
    required this.sponsorVideo,
  });

  factory UserPrivacySettings.fromJson(Map<String, dynamic> json) {
    // // 此处展示全开时状态
    // {
    //   // 公开我的追番追剧
    //   "bangumi": 1,
    //   "bbq": 1,
    //   "channel": 1,
    //   // 投稿视频列表中展现包月充电专属视频
    //   "charge_video": 1,
    //   // 公开佩戴的粉丝勋章
    //   "close_space_medal": 0,
    //   // 公开最近投币的视频
    //   "coins_video": 1,
    //   // 公开我的追漫(仅APP)
    //   "comic": 1,
    //   // 公开我的关注列表
    //   "disable_following": 0,
    //   // 公开我的粉丝列表
    //   "disable_show_fans": 0,
    //   // 公开学校信息
    //   "disable_show_school": 0,
    //   // 公开拥有的粉丝装扮(仅APP)
    //   "dress_up": 1,
    //   // 公开我的收藏
    //   "fav_video": 1,
    //   "groups": 1,
    //   // 投稿视频列表中展现课堂视频
    //   "lesson_video": 1,
    //   // 公开最近点赞的视频
    //   "likes_video": 1,
    //   // 投稿视频列表中展现直播回放
    //   "live_playback": 1,
    //   // 勋章墙公开显示所有粉丝勋章(仅当 close_space_medal == 1 时展示)
    //   "only_show_wearing": 0,
    //   // 公开最近玩过的游戏
    //   "played_game": 1,
    //   "tags": 1,
    //   // 公开我的生日、个人标签
    //   "user_info": 1
    // }
    return UserPrivacySettings(
      favorites: json[UserPrivacySettingsEnum.favorites.value] == 1,
      subscribedMovie: json[UserPrivacySettingsEnum.subscribedMovie.value] == 1,
      likedVideo: json[UserPrivacySettingsEnum.likedVideo.value] == 1,
      coinedVideo: json[UserPrivacySettingsEnum.coinedVideo.value] == 1,
      followedUsers: json[UserPrivacySettingsEnum.followedUsers.value] == 0,
      fans: json[UserPrivacySettingsEnum.fans.value] == 0,
      birthday: json[UserPrivacySettingsEnum.birthday.value] == 1,
      tags: json[UserPrivacySettingsEnum.tags.value] == 1,
      school: json[UserPrivacySettingsEnum.school.value] == 0,
      playedGame: json[UserPrivacySettingsEnum.playedGame.value] == 1,
      fanBadgeList: json[UserPrivacySettingsEnum.fanBadgeList.value] == 0,
      activeFanBadge: json[UserPrivacySettingsEnum.activeFanBadge.value] == 0,
      subscribedManga: json[UserPrivacySettingsEnum.subscribedManga.value] == 1,
      dressedUp: json[UserPrivacySettingsEnum.dressedUp.value] == 1,
      liveStreamReplay: json[UserPrivacySettingsEnum.liveStreamReplay.value] == 1,
      course: json[UserPrivacySettingsEnum.course.value] == 1,
      sponsorVideo: json[UserPrivacySettingsEnum.sponsorVideo.value] == 1,
    );
  }
}

enum UserPrivacySettingsEnum {
  favorites,
  subscribedMovie,
  likedVideo,
  coinedVideo,
  followedUsers,
  fans,
  birthday,
  tags,
  school,
  playedGame,
  fanBadgeList,
  activeFanBadge,
  subscribedManga,
  dressedUp,
  liveStreamReplay,
  course,
  sponsorVideo,
}

extension UserPrivacySettingsEnumExtension on UserPrivacySettingsEnum {
  String get value => switch (this) {
    UserPrivacySettingsEnum.favorites => 'fav_video',
    UserPrivacySettingsEnum.subscribedMovie => 'bangumi',
    UserPrivacySettingsEnum.likedVideo => 'likes_video',
    UserPrivacySettingsEnum.coinedVideo => 'coins_video',
    UserPrivacySettingsEnum.followedUsers => 'disable_following',
    UserPrivacySettingsEnum.fans => 'disable_show_fans',
    UserPrivacySettingsEnum.birthday => 'user_info',
    UserPrivacySettingsEnum.tags => 'tags',
    UserPrivacySettingsEnum.school => 'disable_show_school',
    UserPrivacySettingsEnum.playedGame => 'played_game',
    UserPrivacySettingsEnum.fanBadgeList => 'only_show_wearing',
    UserPrivacySettingsEnum.activeFanBadge => 'close_space_medal',
    UserPrivacySettingsEnum.subscribedManga => 'comic',
    UserPrivacySettingsEnum.dressedUp => 'dress_up',
    UserPrivacySettingsEnum.liveStreamReplay => 'live_playback',
    UserPrivacySettingsEnum.course => 'lesson_video',
    UserPrivacySettingsEnum.sponsorVideo => 'charge_video',
  };
}
