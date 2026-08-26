import 'package:better_bilibili/domain/models/bilibili/user.dart';

class LikedVideo {
  final String id;
  final String episodeId;
  final String bvid;
  final String title;
  final String cover;
  final double duration;
  final User owner;
  final int creationTime;
  final int releaseTime;
  final LikedVideoStats stats;

  LikedVideo({
    required this.id,
    required this.episodeId,
    required this.bvid,
    required this.title,
    required this.cover,
    required this.duration,
    required this.owner,
    required this.creationTime,
    required this.releaseTime,
    required this.stats,
  });

  factory LikedVideo.fromJson(Map<String, dynamic> json) {
    return LikedVideo(
      id: json['aid'].toString(),
      bvid: json['bvid'],
      episodeId: json['cid'].toString(),
      title: json['title'],
      cover: json['pic'],
      duration: json['duration'].toDouble(),
      owner: User(
        id: json['owner']['mid'].toString(),
        nickname: json['owner']['name'],
        avatar: json['owner']['face'],
      ),
      creationTime: json['ctime'],
      releaseTime: json['pubdate'],
      stats: LikedVideoStats(
        view: json['stat']['view'],
        danmaku: json['stat']['danmaku'],
      ),
    );
  }
}

class LikedVideoStats {
  final int view;
  final int danmaku;

  LikedVideoStats({
    required this.view,
    required this.danmaku,
  });
}

class LikedMovie {
  final String episodeId;
  final String cover;
  final String title;

  LikedMovie({
    required this.episodeId,
    required this.cover,
    required this.title,
  });

  factory LikedMovie.fromJson(Map<String, dynamic> json) {
    final episodeId = RegExp(r'/([^/?]+)\?').firstMatch(json['redirect_url'])!.group(1)!;
    return LikedMovie(
      episodeId: episodeId,
      cover: json['pic'],
      title: json['title'] + json['subtitle'],
    );
  }
}

class LikedSeries {
  final String episodeId;
  final String cover;
  final String title;

  LikedSeries({
    required this.episodeId,
    required this.cover,
    required this.title,
  });

  factory LikedSeries.fromJson(Map<String, dynamic> json) {
    final episodeId = RegExp(r'/([^/]+)$').firstMatch(json['redirect_url'])!.group(1)!;
    return LikedSeries(
      episodeId: episodeId,
      cover: json['pic'],
      title: json['title'] + json['subtitle'],
    );
  }
}
