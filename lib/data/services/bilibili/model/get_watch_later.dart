import 'package:better_bilibili/domain/models/bilibili/user.dart';

enum GetWatchLaterOrderEnum {
  addTimeDesc,
  addTimeAsc,
}

extension GetWatchLaterOrderEnumExtension on GetWatchLaterOrderEnum {
  String get value => switch (this) {
    GetWatchLaterOrderEnum.addTimeDesc => 'add_time_desc',
    GetWatchLaterOrderEnum.addTimeAsc => 'add_time_asc',
  };
}

class GetWatchLaterResponse {
  final List<dynamic> list;
  final int total;

  GetWatchLaterResponse({required this.list, required this.total});
}

class WatchLaterVideo {
  final String id;
  final String bvid;
  final dynamic epid;
  final String title;
  final String cover;
  final double duration;
  final User owner;
  final WatchLaterVideoStats stats;
  final int creationTime;
  // 版权所有，1 = 原创，2 = 转载，3 = 上传时未填写或违规投自制被处理
  final bool copyright;
  // 经过测试 viewed 字段就等同于 progress == -1 || progress == duration
  // 而且已经看完的视频重新观看后会使已看完状态重新变为 false(一键清理也不会清掉)
  // 故只保留 watchProgress 字段
  final double watchProgress;
  final int watchLaterTime;

  WatchLaterVideo({
    required this.id,
    required this.bvid,
    required this.epid,
    required this.title,
    required this.cover,
    required this.duration,
    required this.owner,
    required this.stats,
    required this.creationTime,
    required this.copyright,
    required this.watchProgress,
    required this.watchLaterTime,
  });

  factory WatchLaterVideo.fromJson(Map<String, dynamic> item) {
    return WatchLaterVideo(
      id: item['aid'].toString(),
      bvid: item['bvid'],
      epid: item['cid'],
      title: item['title'],
      cover: item['pic'],
      duration: item['duration'].toDouble(),
      owner: User(
        id: item['owner']['mid'].toString(),
        nickname: item['owner']['name'],
        avatar: item['owner']['face'],
      ),
      stats: WatchLaterVideoStats.fromJson(item['stat']),
      creationTime: item['ctime'],
      copyright: item['copyright'] == 1,
      watchProgress: item['progress'] == -1 ? item['duration'].toDouble() : item['progress'].toDouble(),
      watchLaterTime: item['add_at'],
    );
  }
}

class WatchLaterVideoStats {
  final int view;
  final int danmaku;
  final int like;
  final int coin;
  final int favorite;
  final int comment;
  final int share;

  WatchLaterVideoStats({
    required this.view,
    required this.danmaku,
    required this.like,
    required this.coin,
    required this.favorite,
    required this.comment,
    required this.share,
  });

  factory WatchLaterVideoStats.fromJson(Map<String, dynamic> stat) {
    return WatchLaterVideoStats(
      view: stat['view'],
      danmaku: stat['danmaku'],
      like: stat['like'],
      coin: stat['coin'],
      favorite: stat['favorite'],
      comment: stat['reply'],
      share: stat['share'],
    );
  }
}

class WatchLaterMovie {
  final String id;
  final int epid;
  final String title;
  final String cover;
  final int totalEpisodes;
  final double duration;
  final int watchLaterTime;
  final double watchProgress;

  WatchLaterMovie({
    required this.id,
    required this.epid,
    required this.title,
    required this.cover,
    required this.totalEpisodes,
    required this.duration,
    required this.watchLaterTime,
    required this.watchProgress,
  });

  factory WatchLaterMovie.fromJson(Map<String, dynamic> item) {
    return WatchLaterMovie(
      id: item['aid'].toString(),
      epid: item['cid'],
      title: item['title'],
      cover: item['pic'],
      totalEpisodes: item['bangumi']?['season']?['total_count'] ?? 0,
      duration: item['duration'].toDouble(),
      watchLaterTime: item['add_at'],
      watchProgress: item['progress'] == -1 ? item['duration'].toDouble() : item['progress'].toDouble(),
    );
  }
}
