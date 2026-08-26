import 'package:better_bilibili/domain/models/bilibili/user.dart';

class PinnedVideo {
  final String id;
  final String episodeId;
  final String title;
  final String cover;
  final double duration;
  final int viewCount;
  final int danmakuCount;
  final int releaseTime;
  final User owner;

  PinnedVideo({
    required this.id,
    required this.episodeId,
    required this.title,
    required this.cover,
    required this.duration,
    required this.viewCount,
    required this.danmakuCount,
    required this.releaseTime,
    required this.owner,
  });

  factory PinnedVideo.fromJson(Map<String, dynamic> json) {
    return PinnedVideo(
      id: json['aid'].toString(),
      episodeId: json['cid'].toString(),
      title: json['title'],
      cover: json['pic'],
      duration: json['duration'].toDouble(),
      viewCount: json['stat']['view'],
      danmakuCount: json['stat']['danmaku'],
      releaseTime: json['pubdate'],
      owner: User(
        id: json['owner']['mid'].toString(),
        nickname: json['owner']['name'],
        avatar: json['owner']['face'],
      ),
    );
  }
}
