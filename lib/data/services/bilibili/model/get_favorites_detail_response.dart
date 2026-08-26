import 'package:better_bilibili/domain/models/bilibili/user.dart';

enum GetFavoritesDetailOrderEnum {
  favoriteTimeDesc,
  viewDesc,
  releaseTimeDesc,
}

extension GetFavoritesDetailOrderEnumExtension on GetFavoritesDetailOrderEnum {
  String get value => switch (this) {
    GetFavoritesDetailOrderEnum.favoriteTimeDesc => 'mtime',
    GetFavoritesDetailOrderEnum.viewDesc => 'view',
    GetFavoritesDetailOrderEnum.releaseTimeDesc => 'pubtime',
  };
}

enum GetFavoritesDetailScopeEnum {
  local,
  global,
}

extension GetFavoritesDetailScopeEnumExtension on GetFavoritesDetailScopeEnum {
  int get value => switch (this) {
    GetFavoritesDetailScopeEnum.local => 0,
    GetFavoritesDetailScopeEnum.global => 1,
  };
}

class GetFavoritesDetailResponse {
  final String favoritesId;
  final String cover;
  final String name;
  final String description;
  final User owner;
  final bool isPrivate;
  final bool isDefault;
  final int subscriberCount;
  final bool isSubscribed;
  final int creationTime;
  final int modifyTime;

  final int total;
  final bool hasMore;
  final List<dynamic> list;

  GetFavoritesDetailResponse({
    required this.favoritesId,
    required this.cover,
    required this.name,
    required this.description,
    required this.owner,
    required this.isPrivate,
    required this.isDefault,
    required this.subscriberCount,
    required this.isSubscribed,
    required this.creationTime,
    required this.modifyTime,
    required this.total,
    required this.hasMore,
    required this.list,
  });

  factory GetFavoritesDetailResponse.fromJson(Map<String, dynamic> json, List<dynamic> list) {
    final info = json['info'];

    return GetFavoritesDetailResponse(
      favoritesId: info['id'].toString(),
      cover: info['cover'] ?? '',
      name: info['title'] ?? '',
      description: info['intro'] ?? '',
      owner: User(
        id: info['upper']['mid'].toString(),
        nickname: info['upper']['name'] ?? '',
        avatar: info['upper']['face'] ?? '',
      ),
      isPrivate: (info['attr'] ?? 0) & 1 == 1,
      isDefault: (info['attr'] ?? 0) & 2 == 0,
      subscriberCount: info['cnt_info']?['collect'] ?? 0,
      isSubscribed: info['fav_state'] == 1,
      creationTime: info['ctime'] ?? 0,
      modifyTime: info['mtime'] ?? 0,
      total: info['media_count'] ?? 0,
      hasMore: json['has_more'] ?? false,
      list: list,
    );
  }
}

class FavoritesVideo {
  final String id;
  final String bvid;
  final String episodeId;
  final String title;
  final String cover;
  final double duration;
  final User owner;
  final FavoritesVideoStats stats;
  final int creationTime;
  final int releaseTime;
  final int favoriteTime;

  FavoritesVideo({
    required this.id,
    required this.bvid,
    required this.episodeId,
    required this.title,
    required this.cover,
    required this.duration,
    required this.owner,
    required this.stats,
    required this.creationTime,
    required this.releaseTime,
    required this.favoriteTime,
  });

  factory FavoritesVideo.fromJson(Map<String, dynamic> item) {
    return FavoritesVideo(
      id: item['id'].toString(),
      bvid: item['bvid'] ?? '',
      episodeId: item['ugc']['first_cid'].toString(),
      title: item['title'] ?? '',
      cover: item['cover'] ?? '',
      duration: (item['duration'] ?? 0).toDouble(),
      creationTime: item['ctime'] ?? 0,
      releaseTime: item['pubtime'] ?? 0,
      favoriteTime: item['fav_time'] ?? 0,
      owner: User(
        id: item['upper']?['mid']?.toString() ?? '',
        nickname: item['upper']?['name'] ?? '',
        avatar: item['upper']?['face'] ?? '',
      ),
      stats: FavoritesVideoStats(
        view: item['cnt_info']['play'],
        danmaku: item['cnt_info']['danmaku'],
        collect: item['cnt_info']['collect'],
      ),
    );
  }
}

class FavoritesVideoStats {
  final int view;
  final int danmaku;
  final int collect;

  FavoritesVideoStats({
    required this.view,
    required this.danmaku,
    required this.collect,
  });
}

class FavoritesMovie {
  final String id;
  final String episodeId;
  final String title;
  final String cover;
  final double duration;
  final int favoriteTime;

  FavoritesMovie({
    required this.id,
    required this.episodeId,
    required this.title,
    required this.cover,
    required this.duration,
    required this.favoriteTime,
  });

  factory FavoritesMovie.fromJson(Map<String, dynamic> item) {
    return FavoritesMovie(
      id: item['id'].toString(),
      // 番剧的 epid 在 ogv
      episodeId: item['ogv']?['season_id']?.toString() ?? '',
      title: item['title'] ?? '',
      cover: item['cover'] ?? '',
      duration: (item['duration'] ?? 0).toDouble(),
      favoriteTime: item['fav_time'] ?? 0,
    );
  }
}
