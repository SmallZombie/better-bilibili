import 'package:better_bilibili/data/model/bilibili/movie_model.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/utils/bili_util.dart';

/// 去除字符串中的 HTML 标签
String _handleTitle(String title) {
  return title
      .replaceAll('<em class="keyword">', '')
      .replaceAll('</em>', '')
      .replaceAll('&amp;', '&')
      .replaceAll('&#x27;', '\'')
      .replaceAll('&quot;', '"');
}

class SearchResponse {
  int total;
  List<dynamic> list;
  List<SearchResultSeries> series;
  List<SearchResultMovie> movies;
  List<SearchResultGame> games;
  List<SearchResultUser> users;
  List<SearchResultEvent> events;
  List<SearchResultBanner> banners;

  SearchResponse({
    required this.total,
    this.list = const [],
    this.series = const [],
    this.movies = const [],
    this.games = const [],
    this.users = const [],
    this.events = const [],
    this.banners = const [],
  });
}

class SearchResultVideo {
  String id;
  String bvid;
  String title;
  String cover;
  double duration;
  int creationTime;
  int releaseTime;
  User owner;
  SearchResultVideoStats stats;

  SearchResultVideo({
    required this.id,
    required this.bvid,
    required this.title,
    required this.cover,
    required this.duration,
    required this.creationTime,
    required this.releaseTime,
    required this.owner,
    required this.stats,
  });

  factory SearchResultVideo.fromJson(Map<String, dynamic> json) {
    final pic = json['pic'];
    return SearchResultVideo(
      id: json['aid'].toString(),
      bvid: json['bvid'],
      title: _handleTitle(json['title']),
      cover: pic.startsWith('http') ? pic : 'https:$pic',
      duration: json['duration'].isEmpty ? 0.0 : durationStrToSec(json['duration']),
      creationTime: json['senddate'],
      releaseTime: json['pubdate'],
      owner: User(
        id: json['mid'].toString(),
        nickname: json['author'],
        avatar: json['upic'],
      ),
      stats: SearchResultVideoStats.fromJson(json),
    );
  }
}

class SearchResultVideoStats {
  int view;
  int danmaku;
  int like;
  int favorite;
  int comment;

  SearchResultVideoStats({
    required this.view,
    required this.danmaku,
    required this.like,
    required this.favorite,
    required this.comment,
  });

  factory SearchResultVideoStats.fromJson(Map<String, dynamic> json) {
    return SearchResultVideoStats(
      view: json['play'],
      // ['video_review'] 也是弹幕
      danmaku: json['danmaku'],
      like: json['like'],
      favorite: json['favorites'],
      comment: json['review'],
    );
  }
}

class SearchResultUser {
  final String id;
  final String nickname;
  final String avatar;
  final UserLevel level;
  final bool isLive;
  final int videoCount;
  final int fansCount;
  final bool isVerified;
  final bool isEnterpriseVerified;
  final List<SearchResultUserVideos> videos;

  SearchResultUser({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.level,
    required this.isLive,
    required this.videoCount,
    required this.fansCount,
    required this.isVerified,
    required this.isEnterpriseVerified,
    required this.videos,
  });

  factory SearchResultUser.fromJson(Map<String, dynamic> json) {
    return SearchResultUser(
      id: json['mid'].toString(),
      nickname: json['uname'],
      avatar: 'https:${json['upic']}',
      level: json['is_senior_member'] == 1
          ? UserLevel.lv6p
          : switch (json['level']) {
              0 => UserLevel.lv0,
              1 => UserLevel.lv1,
              2 => UserLevel.lv2,
              3 => UserLevel.lv3,
              4 => UserLevel.lv4,
              5 => UserLevel.lv5,
              6 => UserLevel.lv6,
              _ => throw Exception('Invalid user level: ${json['level']}'),
            },
      isLive: json['is_live'] == 1,
      videoCount: json['videos'],
      fansCount: json['fans'],
      // 0: 个人认证, 1: 机构认证
      isVerified: json['official_verify']?['type'] == 0,
      isEnterpriseVerified: json['official_verify']?['type'] == 1,
      videos: (json['res'] as List).map((v) => SearchResultUserVideos.fromJson(v)).toList(),
    );
  }
}

class SearchResultUserVideos {
  final String id;
  final String bvid;
  final String cover;
  final String title;
  final int releaseTime;
  final int viewCount;
  final int danmakuCount;
  final double duration;

  SearchResultUserVideos({
    required this.id,
    required this.bvid,
    required this.cover,
    required this.title,
    required this.releaseTime,
    required this.viewCount,
    required this.danmakuCount,
    required this.duration,
  });

  factory SearchResultUserVideos.fromJson(Map<String, dynamic> json) {
    return SearchResultUserVideos(
      id: json['aid'].toString(),
      bvid: json['bvid'],
      cover: 'https:${json['pic']}',
      title: json['title'],
      releaseTime: json['pubdate'],
      viewCount: int.parse(json['play']),
      danmakuCount: json['dm'],
      duration: durationStrToSec(json['duration']),
    );
  }
}

class SearchResultSeries {
  final String id;
  final String title;
  final String cover;
  final String description;
  final List<String> tags;
  final List<MovieCountry> countries;
  final int year;

  SearchResultSeries({
    required this.id,
    required this.title,
    required this.cover,
    required this.description,
    required this.tags,
    required this.countries,
    required this.year,
  });

  factory SearchResultSeries.fromJson(Map<String, dynamic> json) {
    return SearchResultSeries(
      id: json['season_id'].toString(),
      title: _handleTitle(json['title']),
      cover: json['cover'],
      description: json['desc'],
      tags: json['styles'].split('/'),
      countries: [MovieCountry(id: '0', name: json['areas'])],
      year: DateTime.fromMillisecondsSinceEpoch(json['pubtime'] * 1000).year,
    );
  }
}

class SearchResultMovie {
  final String id;
  final String title;
  final String cover;
  final String description;
  final List<String> tags;
  final List<MovieCountry> countries;
  final int year;

  SearchResultMovie({
    required this.id,
    required this.title,
    required this.cover,
    required this.description,
    required this.tags,
    required this.countries,
    required this.year,
  });

  factory SearchResultMovie.fromJson(Map<String, dynamic> json) {
    return SearchResultMovie(
      id: json['season_id'].toString(),
      title: _handleTitle(json['title']),
      cover: json['cover'],
      description: json['desc'],
      tags: json['styles'].split('/'),
      countries: [MovieCountry(id: '0', name: json['areas'])],
      year: DateTime.fromMillisecondsSinceEpoch(json['pubtime'] * 1000).year,
    );
  }
}

class SearchResultGame {
  final String id;
  final String icon;
  final String name;
  final List<String> tags;
  final String description;
  final String latestUpdateMessage;
  // cm = Community Manager，指游戏运营方与互动的负责人
  final String cmUserId;

  SearchResultGame({
    required this.id,
    required this.icon,
    required this.name,
    required this.tags,
    required this.description,
    required this.latestUpdateMessage,
    required this.cmUserId,
  });

  factory SearchResultGame.fromJson(Map<String, dynamic> json) {
    return SearchResultGame(
      id: json['game_base_id'].toString(),
      icon: json['game_icon'],
      name: json['game_name_v2'],
      tags: json['game_tags'].split('/'),
      description: json['summary'],
      latestUpdateMessage: json['notice'],
      cmUserId: json['official_account'].toString(),
    );
  }
}

class SearchResultEvent {
  final String id;
  final String name;
  final String description;
  final String cover;
  final String url;

  SearchResultEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.cover,
    required this.url,
  });

  factory SearchResultEvent.fromJson(Map<String, dynamic> json) {
    return SearchResultEvent(
      id: json['id'].toString(),
      name: json['title'],
      description: json['desc'],
      cover: json['cover'],
      url: json['url'],
    );
  }
}

class SearchResultBanner {
  final String id;
  final String name;
  final String description;
  final String cover;
  final String url;

  SearchResultBanner({
    required this.id,
    required this.name,
    required this.description,
    required this.cover,
    required this.url,
  });

  factory SearchResultBanner.fromJson(Map<String, dynamic> json) {
    final card = json['value']['biz_data']['ad_content']['extra']['card'];
    return SearchResultBanner(
      id: json['id'].toString(),
      name: card['dynamic_text'],
      description: card['desc'],
      cover: (card['covers'] as List).first['url'],
      url: card['jump_url'],
    );
  }
}

enum GetSearchResultWithFilterTypeEnum {
  video,
  series,
  movie,
  live,
  article,
  user,
}

extension GetSearchResultWithFilterTypeEnumExtension on GetSearchResultWithFilterTypeEnum {
  String get value => switch (this) {
    GetSearchResultWithFilterTypeEnum.video => 'video',
    GetSearchResultWithFilterTypeEnum.series => 'media_bangumi',
    GetSearchResultWithFilterTypeEnum.movie => 'media_ft',
    GetSearchResultWithFilterTypeEnum.live => 'live',
    GetSearchResultWithFilterTypeEnum.article => 'article',
    GetSearchResultWithFilterTypeEnum.user => 'bili_user',
  };
}

enum GetSearchResultWithFilterOrderEnum {
  auto,
  viewDesc,
  releaseTimeDesc,
  danmakuDesc,
  favoriteDesc,
  likeDesc,
  commentDesc,
  fansDesc,
  fansAsc,
  levelDesc,
  levelAsc,
  airtimeDesc,
}

extension GetSearchResultWithFilterOrderEnumExtension on GetSearchResultWithFilterOrderEnum {
  String get value => switch (this) {
    GetSearchResultWithFilterOrderEnum.auto => '',
    GetSearchResultWithFilterOrderEnum.viewDesc => 'click',
    GetSearchResultWithFilterOrderEnum.releaseTimeDesc => 'pubdate',
    GetSearchResultWithFilterOrderEnum.danmakuDesc => 'dm',
    GetSearchResultWithFilterOrderEnum.favoriteDesc => 'stow',
    GetSearchResultWithFilterOrderEnum.likeDesc => 'attention',
    GetSearchResultWithFilterOrderEnum.commentDesc => 'scores',
    GetSearchResultWithFilterOrderEnum.fansDesc => 'fans',
    GetSearchResultWithFilterOrderEnum.fansAsc => 'fans',
    GetSearchResultWithFilterOrderEnum.levelDesc => 'level',
    GetSearchResultWithFilterOrderEnum.levelAsc => 'level',
    GetSearchResultWithFilterOrderEnum.airtimeDesc => 'live_time',
  };
}

enum GetSearchResultWithFilterDurationEnum {
  under10Minutes,
  under30Minutes,
  under60Minutes,
  over60Minutes,
}

extension GetSearchResultWithFilterDurationEnumExtension on GetSearchResultWithFilterDurationEnum {
  int get value => switch (this) {
    GetSearchResultWithFilterDurationEnum.under10Minutes => 1,
    GetSearchResultWithFilterDurationEnum.under30Minutes => 2,
    GetSearchResultWithFilterDurationEnum.under60Minutes => 3,
    GetSearchResultWithFilterDurationEnum.over60Minutes => 4,
  };
}

enum GetSearchResultWithFilterUserTypeEnum {
  all,
  uploader,
  notUploader,
  verified,
}

extension GetSearchResultWithFilterUserTypeEnumExtension on GetSearchResultWithFilterUserTypeEnum {
  int get value => switch (this) {
    GetSearchResultWithFilterUserTypeEnum.all => 0,
    GetSearchResultWithFilterUserTypeEnum.uploader => 1,
    GetSearchResultWithFilterUserTypeEnum.notUploader => 2,
    GetSearchResultWithFilterUserTypeEnum.verified => 3,
  };
}

class SearchResponseWithFilter {
  final List<dynamic> list;
  final int total;

  SearchResponseWithFilter({
    this.list = const [],
    required this.total,
  });
}

class SearchResultLive {
  final String id;
  final String title;
  final String cover;
  final bool isLive;
  final User owner;
  // 用于代替真实观看人数的 "热度"
  final int popularity;

  SearchResultLive({
    required this.id,
    required this.title,
    required this.cover,
    required this.isLive,
    required this.owner,
    required this.popularity,
  });

  factory SearchResultLive.fromJson(Map<String, dynamic> json) {
    return SearchResultLive(
      id: json['roomid'].toString(),
      title: _handleTitle(json['title']),
      // 从综合接口返回的 cover 不带 https，从分类筛选接口返回的就会带
      // ...
      cover: json['cover'].startsWith('https:') ? json['cover'] : 'https:${json['cover']}',
      isLive: json['live_status'] == 1,
      owner: User(
        id: json['uid'].toString(),
        nickname: json['uname'],
        avatar: json['uface'],
      ),
      popularity: json['online'],
    );
  }
}

class SearchResultArticle {
  final String id;
  final String title;
  final List<String> covers;
  final User owner;
  final int viewCount;
  final int likeCount;
  final int releaseTime;

  SearchResultArticle({
    required this.id,
    required this.title,
    required this.covers,
    required this.owner,
    required this.viewCount,
    required this.likeCount,
    required this.releaseTime,
  });

  factory SearchResultArticle.fromJson(Map<String, dynamic> json) {
    return SearchResultArticle(
      id: json['id'].toString(),
      title: _handleTitle(json['title']),
      covers: (json['image_urls'] as List).map((v) => 'https:$v').toList(),
      owner: User(id: json['mid'].toString(), nickname: json['author'], avatar: ''),
      viewCount: json['view'],
      likeCount: json['like'],
      releaseTime: json['pubdate'],
    );
  }
}
