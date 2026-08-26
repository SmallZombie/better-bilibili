import 'package:better_bilibili/domain/models/bilibili/bilibili.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';

/// 适用于下列接口返回的数据
/// - `https://api.bilibili.com/x/web-interface/wbi/index/top/feed/rcmd`
/// - `https://api.bilibili.com/x/web-interface/region/feed/rcmd`
/// - `https://api.bilibili.com/x/web-interface/wbi/view/detail`
class RecommendVideo {
  final String id;
  final String bvid;
  final String episodeId;
  final String title;
  final String cover;
  final double duration;
  final int releaseTime;
  final RecommendVideoState stats;
  final User owner;
  final TrackingInfo trackingInfo;

  RecommendVideo({
    required this.id,
    required this.bvid,
    required this.episodeId,
    required this.title,
    required this.cover,
    required this.duration,
    required this.releaseTime,
    required this.stats,
    required this.owner,
    required this.trackingInfo,
  });

  factory RecommendVideo.fromJson(Map<String, dynamic> json) {
    final userJson = json['owner'] ?? json['author'];
    return RecommendVideo(
      id: (json['id'] ?? json['aid']).toString(),
      bvid: json['bvid'],
      episodeId: json['cid'].toString(),
      title: json['title'],
      cover: json['pic'] ?? json['cover'],
      duration: json['duration'].toDouble(),
      releaseTime: json['pubdate'],
      stats: RecommendVideoState.fromJson(json['stat']),
      owner: User(
        id: userJson['mid'].toString(),
        nickname: userJson['name'],
        avatar: userJson['face'] ?? kDefaultUserAvatar,
      ),
      trackingInfo: TrackingInfo(
        id: json['track_id'] ?? '',
        goto: json['goto'] ?? '',
      ),
    );
  }
}

class RecommendVideoState {
  final int view;
  final int like;
  final int danmaku;

  RecommendVideoState({
    required this.view,
    required this.like,
    required this.danmaku,
  });

  factory RecommendVideoState.fromJson(Map<String, dynamic> json) {
    return RecommendVideoState(
      view: json['view'],
      like: json['like'],
      danmaku: json['danmaku'],
    );
  }
}
