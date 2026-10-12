import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/utils/bili/bili_util.dart';

enum GetVideosWithUserTypeEnum {
  all,
  sponsorOnly,
}

enum GetVideosWithUserOrderEnum {
  releaseTimeDesc,
  viewDesc,
  favoriteDesc,
}

extension GetVideosWithUserOrderEnumExtension on GetVideosWithUserOrderEnum {
  String get value => switch (this) {
    GetVideosWithUserOrderEnum.releaseTimeDesc => 'pubdate',
    GetVideosWithUserOrderEnum.viewDesc => 'click',
    GetVideosWithUserOrderEnum.favoriteDesc => 'stow',
  };
}

class GetVideosWithUserIdResponse {
  final List<VideoItem> list;
  final int total;
  final int sponsorOnlyTotal;

  GetVideosWithUserIdResponse({
    required this.list,
    required this.total,
    required this.sponsorOnlyTotal,
  });
}

class VideoItem {
  final String id;
  final String episodeId;
  final String title;
  final String cover;
  final double duration;
  final int releaseTime;
  final User owner;
  final VideoItemStats stats;

  VideoItem({
    required this.id,
    required this.episodeId,
    required this.title,
    required this.cover,
    required this.duration,
    required this.releaseTime,
    required this.owner,
    required this.stats,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['aid'].toString(),
      episodeId: json['cid'].toString(),
      title: json['title'],
      cover: json['pic'],
      duration: durationStrToSec(json['length']),
      releaseTime: json['created'],
      owner: User(
        id: json['mid'].toString(),
        nickname: json['author'],
        avatar: '',
      ),
      stats: VideoItemStats.fromJson(json),
    );
  }
}

class VideoItemStats {
  final int view;
  final int danmaku;

  VideoItemStats({required this.view, required this.danmaku});

  factory VideoItemStats.fromJson(Map<String, dynamic> json) {
    return VideoItemStats(
      view: json['play'],
      danmaku: json['video_review'],
    );
  }
}
