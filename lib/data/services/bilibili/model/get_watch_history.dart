import 'package:better_bilibili/domain/models/bilibili/user.dart';

enum GetWatchHistoryTypeEnum {
  all,
  video,
  live,
  article,
}

extension GetWatchHistoryTypeEnumExtension on GetWatchHistoryTypeEnum {
  String get value => switch (this) {
    GetWatchHistoryTypeEnum.all => 'all',
    GetWatchHistoryTypeEnum.video => 'archive',
    GetWatchHistoryTypeEnum.live => 'live',
    GetWatchHistoryTypeEnum.article => 'article',
  };
}

class GetWatchHistoryResponse {
  final List<dynamic> list;
  final int nextCursor;
  final int viewAt;

  GetWatchHistoryResponse({required this.list, required this.nextCursor, required this.viewAt});
}

class WatchHistoryVideo {
  final String id;
  final String bvid;
  final String episodeId;
  final String title;
  final String cover;
  final User owner;
  final int watchTime;
  final double watchProgress;
  final double duration;

  WatchHistoryVideo({
    required this.id,
    required this.bvid,
    required this.episodeId,
    required this.title,
    required this.cover,
    required this.owner,
    required this.watchTime,
    required this.watchProgress,
    required this.duration,
  });

  factory WatchHistoryVideo.fromJson(Map<String, dynamic> item) {
    return WatchHistoryVideo(
      id: item['history']['oid'].toString(),
      bvid: item['history']['bvid'] ?? '',
      episodeId: item['history']['cid']?.toString() ?? '',
      title: item['title'] ?? '',
      cover: item['cover'] ?? '',
      owner: User(
        id: item['author_mid'].toString(),
        nickname: item['author_name'] ?? '',
        avatar: item['author_face'] ?? '',
      ),
      watchTime: item['view_at'] ?? 0,
      watchProgress: (item['progress'] as num?)?.toDouble() ?? 0.0,
      duration: (item['duration'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class WatchHistoryLive {
  final String id;
  final String title;
  final String cover;
  final User owner;
  final bool isLive;
  final int watchTime;

  WatchHistoryLive({
    required this.id,
    required this.title,
    required this.cover,
    required this.owner,
    required this.isLive,
    required this.watchTime,
  });

  factory WatchHistoryLive.fromJson(Map<String, dynamic> item) {
    return WatchHistoryLive(
      id: item['history']['oid'].toString(),
      title: item['title'] ?? '',
      cover: item['cover'] ?? '',
      owner: User(
        id: item['author_mid'].toString(),
        nickname: item['author_name'] ?? '',
        avatar: item['author_face'] ?? '',
      ),
      isLive: item['live_status'] == 1,
      watchTime: item['view_at'] ?? 0,
    );
  }
}

class WatchHistoryArticle {
  final String id;
  final String title;
  final List<String> covers;
  final User owner;
  final int watchTime;

  WatchHistoryArticle({
    required this.id,
    required this.title,
    required this.covers,
    required this.owner,
    required this.watchTime,
  });

  factory WatchHistoryArticle.fromJson(Map<String, dynamic> item) {
    return WatchHistoryArticle(
      id: item['history']['oid'].toString(),
      title: item['title'] ?? '',
      covers: (item['covers'] as List<dynamic>?)?.cast<String>() ?? [],
      owner: User(
        id: item['author_mid'].toString(),
        nickname: item['author_name'] ?? '',
        avatar: item['author_face'] ?? '',
      ),
      watchTime: item['view_at'] ?? 0,
    );
  }
}

class WatchHistoryMovie {
  final String id;
  final int epid;
  final String title;
  final String cover;
  final int totalEpisodes;
  final double duration;
  final int watchTime;
  final double watchProgress;

  WatchHistoryMovie({
    required this.id,
    required this.epid,
    required this.title,
    required this.cover,
    required this.totalEpisodes,
    required this.duration,
    required this.watchTime,
    required this.watchProgress,
  });

  factory WatchHistoryMovie.fromJson(Map<String, dynamic> item) {
    return WatchHistoryMovie(
      id: item['history']['oid'].toString(),
      epid: item['history']['epid'],
      // b站也是神了，搞了三个 title 字段(title, long_title, show_title) 也不搞一个当前剧集，只有 total
      title: '《${item['title']}》${item['show_title']}',
      cover: item['cover'],
      totalEpisodes: item['total'],
      duration: (item['duration'] as num).toDouble(),
      watchTime: item['view_at'],
      watchProgress: (item['progress'] as num).toDouble(),
    );
  }
}

class WatchHistoryAnthology {
  final String id;
  final String title;
  final List<String> covers;
  final User owner;
  final int watchTime;

  WatchHistoryAnthology({
    required this.id,
    required this.title,
    required this.covers,
    required this.owner,
    required this.watchTime,
  });

  factory WatchHistoryAnthology.fromJson(Map<String, dynamic> item) {
    return WatchHistoryAnthology(
      id: item['history']['oid'].toString(),
      title: item['title'] ?? '',
      covers: (item['covers'] as List<dynamic>?)?.cast<String>() ?? [],
      owner: User(
        id: item['author_mid'].toString(),
        nickname: item['author_name'] ?? '',
        avatar: item['author_face'] ?? '',
      ),
      watchTime: item['view_at'] ?? 0,
    );
  }
}

class WatchHistoryCourse {
  final String id;
  final String episodeId;
  final String title;
  final String cover;
  final double duration;

  WatchHistoryCourse({
    required this.id,
    required this.episodeId,
    required this.title,
    required this.cover,
    required this.duration,
  });

  factory WatchHistoryCourse.fromJson(Map<String, dynamic> item) {
    return WatchHistoryCourse(
      id: item['kid'].toString(),
      episodeId: item['history']['cid'].toString(),
      title: item['show_title'],
      cover: item['cover'],
      duration: item['duration'].toDouble(),
    );
  }
}

class GetWatchHistoryWithFilterResult {
  final List<dynamic> list;
  final bool hasMore;

  GetWatchHistoryWithFilterResult({required this.list, required this.hasMore});
}

enum GetWatchHistoryWithFilterTypeEnum {
  all,
  video,
  article,
  live,
  movie,
  // TODO 我怎么不记得历史记录里有文集？
  anthology,
}

extension GetWatchHistoryWithFilterTypeEnumExtension on GetWatchHistoryWithFilterTypeEnum {
  String get value => switch (this) {
    GetWatchHistoryWithFilterTypeEnum.all => 'all',
    GetWatchHistoryWithFilterTypeEnum.video => 'archive',
    GetWatchHistoryWithFilterTypeEnum.article => 'article',
    GetWatchHistoryWithFilterTypeEnum.live => 'live',
    GetWatchHistoryWithFilterTypeEnum.movie => 'pgc',
    GetWatchHistoryWithFilterTypeEnum.anthology => 'article-list',
  };
}

enum GetWatchHistoryWithFilterDeviceTypeEnum {
  all,
  pc,
  mobile,
  tablet,
  tv,
}

extension GetWatchHistoryWithFilterDeviceTypeEnumExtension on GetWatchHistoryWithFilterDeviceTypeEnum {
  int get value => switch (this) {
    GetWatchHistoryWithFilterDeviceTypeEnum.all => 0,
    GetWatchHistoryWithFilterDeviceTypeEnum.pc => 1,
    GetWatchHistoryWithFilterDeviceTypeEnum.mobile => 2,
    GetWatchHistoryWithFilterDeviceTypeEnum.tablet => 3,
    GetWatchHistoryWithFilterDeviceTypeEnum.tv => 4,
  };
}
