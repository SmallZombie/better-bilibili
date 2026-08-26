import 'package:better_bilibili/domain/models/bilibili/user.dart';

enum GetPlaylistVideosDirectionEnum {
  both,
  before,
  after,
}

class GetPlaylistVideosResponse {
  final bool hasMore;
  final List<PlaylistVideo> list;

  GetPlaylistVideosResponse({required this.hasMore, required this.list});
}

class PlaylistVideo {
  final String id;
  final String episodeId;
  final String bvid;
  final String title;
  final String cover;
  final double duration;
  final int creationTime;
  final int releaseTime;
  final User owner;
  final PlaylistVideoStats stats;

  PlaylistVideo({
    required this.id,
    required this.episodeId,
    required this.bvid,
    required this.title,
    required this.cover,
    required this.duration,
    required this.creationTime,
    required this.releaseTime,
    required this.owner,
    required this.stats,
  });

  factory PlaylistVideo.fromJson(Map<String, dynamic> value) {
    return PlaylistVideo(
      id: value['id'].toString(),
      episodeId: value['ogv_info']?['cid'].toString() ?? value['pages'].first['id'].toString(),
      bvid: value['bv_id'],
      title: value['title'],
      cover: value['cover'],
      duration: value['duration'].toDouble(),
      creationTime: 0,
      releaseTime: value['pubtime'],
      // 此接口返回的 index 并不准确
      // index: value['index'],
      owner: User(
        id: value['upper']['mid'].toString(),
        nickname: value['upper']['name'],
        avatar: value['upper']['face'],
      ),
      stats: PlaylistVideoStats.fromJson(value['cnt_info']),
    );
  }
}

class PlaylistVideoStats {
  final int view;
  final int danmaku;

  PlaylistVideoStats({required this.view, required this.danmaku});

  factory PlaylistVideoStats.fromJson(Map<String, dynamic> json) {
    return PlaylistVideoStats(
      view: json['play'],
      danmaku: json['danmaku'],
    );
  }
}
