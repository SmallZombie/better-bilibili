import 'package:better_bilibili/data/services/bilibili/model/get_recommend_videos_response.dart';
import 'package:better_bilibili/domain/models/bilibili/comment.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';

class GetVideoDetailResponse {
  final VideoDetail video;
  final List<RecommendVideo> recommendVideos;

  GetVideoDetailResponse({
    required this.video,
    required this.recommendVideos,
  });
}

class VideoDetail {
  final String id;
  final String bvid;
  final String episodeId;
  final bool copyright;
  final String title;
  final String cover;
  final int creationTime;
  final int releaseTime;
  final VideoDetailDescription? description;
  final double duration;
  final String? eventId;
  final VideoDetailOwner owner;
  final VideoDetailStats stats;
  final List<VideoDetailHonor> honors;
  final List<VideoDetailTag> tags;
  final List<VideoDetailMusic> musics;
  final List<VideoProduction> production;
  final bool isAigc;
  final bool isDangerous;
  final bool isSensitive;
  final List<VideoDetailEpisode> episodes;
  final VideoCollection? collection;

  VideoDetail({
    required this.id,
    required this.bvid,
    required this.episodeId,
    required this.copyright,
    required this.title,
    required this.cover,
    required this.creationTime,
    required this.releaseTime,
    this.description,
    required this.duration,
    this.eventId,
    required this.owner,
    required this.stats,
    this.honors = const [],
    this.tags = const [],
    this.musics = const [],
    this.production = const [],
    required this.isAigc,
    required this.isDangerous,
    required this.isSensitive,
    this.episodes = const [],
    this.collection,
  });

  VideoDetail copyWith({
    String? id,
    String? bvid,
    String? episodeId,
    bool? copyright,
    String? title,
    String? cover,
    int? creationTime,
    int? releaseTime,
    VideoDetailDescription? description,
    double? duration,
    String? eventId,
    VideoDetailOwner? owner,
    VideoDetailStats? stats,
    List<VideoDetailHonor>? honors,
    List<VideoDetailTag>? tags,
    List<VideoDetailMusic>? musics,
    List<VideoProduction>? production,
    bool? isAigc,
    bool? isDangerous,
    bool? isSensitive,
    List<VideoDetailEpisode>? episodes,
    VideoCollection? collection,
  }) {
    return VideoDetail(
      id: id ?? this.id,
      bvid: bvid ?? this.bvid,
      episodeId: episodeId ?? this.episodeId,
      copyright: copyright ?? this.copyright,
      title: title ?? this.title,
      cover: cover ?? this.cover,
      creationTime: creationTime ?? this.creationTime,
      releaseTime: releaseTime ?? this.releaseTime,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      eventId: eventId ?? this.eventId,
      owner: owner ?? this.owner,
      stats: stats ?? this.stats,
      honors: honors ?? this.honors,
      tags: tags ?? this.tags,
      musics: musics ?? this.musics,
      production: production ?? this.production,
      isAigc: isAigc ?? this.isAigc,
      isDangerous: isDangerous ?? this.isDangerous,
      isSensitive: isSensitive ?? this.isSensitive,
      episodes: episodes ?? this.episodes,
      collection: collection ?? this.collection,
    );
  }

  factory VideoDetail.fromJson(Map<String, dynamic> json) {
    final view = json['View'];

    final List<VideoDetailTag> tags = [];
    // web 端接口最多只会返回一首歌的 tag
    VideoDetailMusic? music;
    for (final item in json['Tags']) {
      if (item['tag_type'] == 'bgm') {
        music = VideoDetailMusic.fromJson(item);
      } else {
        tags.add(VideoDetailTag.fromJson(item));
      }
    }

    return VideoDetail(
      id: view['aid'].toString(),
      bvid: view['bvid'],
      episodeId: view['cid'].toString(),
      // 1 = 原创, 2 = 转载, 3 = 上传时未填写或违规投自制被处理
      copyright: view['copyright'] == 1,
      title: view['title'],
      cover: view['pic'],
      // 秒
      creationTime: view['ctime'],
      // 秒
      releaseTime: view['pubdate'],
      description: const ['', '-'].contains(view['desc']) ? null : VideoDetailDescription.fromJson(view['desc_v2'] as List),
      duration: view['duration'].toDouble(),
      eventId: view['mission_id']?.toString(),
      owner: VideoDetailOwner.fromJson(json['Card']),
      stats: VideoDetailStats.fromJson(view['stat']),
      honors: view['honor_reply']['honor'] == null
          ? const []
          : (view['honor_reply']['honor'] as List).map((v) => VideoDetailHonor.fromJson(v)).toList(),
      tags: tags,
      musics: music == null ? const [] : [music],
      // 创作团队
      production: view['staff'] == null ? const [] : (view['staff'] as List).map((v) => VideoProduction.fromJson(v)).toList(),
      // 狗屎b站的狗屎接口，argue_type 始终为 0，argue_link 始终为空，只能通过 msg 判断类型
      // 旧创作声明
      // - "该内容疑似使用AI技术合成，请谨慎甄别": BV1oZo4B2EJD
      // - "作者声明：该视频使用人工智能合成技术": BV1fpQ3BoEbx
      // - "作者声明：视频内含有危险行为，请勿轻易模仿": BV1GHE4zZEwp
      // - "作者声明：该内容仅供娱乐，请勿过分解读": BV1P9QwB1EX4
      // - "此内容可能引起不适，请谨慎观看": BV19tpfeMEFf
      // - "作者声明：请理性适度消费": BV19twTzPEYp
      // - "个人观点，仅供参考": BV1jDLP6UEnT
      // 新创作声明
      // - "含AI生成内容": BV1mdLz6wEmC (此视频在动态中显示为 "含虚构演绎内容", 详情页显示为新ai提示, 以后再具体研究)
      // - "含虚构演绎内容": BV1nX5i6CEbR
      // - "内容含营销信息": BV1sdL26jEA6
      // - 内容为转载: 就是 copyright = 2, 选择此项时会有一个必填的来源, 但这个来源里填写的内容会被直接放到简介里, 并不是单独的字段保存的
      // - 内容为自制: 就是 copyright = 1
      // 未知
      // - "温馨提示:过量饮酒，有害健康": BV16ML76REvg
      isAigc: const [
        '该内容疑似使用AI技术合成，请谨慎甄别',
        '作者声明：该视频使用人工智能合成技术',
        '含AI生成内容',
      ].contains(view['argue_info']['argue_msg']),
      // 包含危险行为
      isDangerous: view['argue_info']['argue_msg'] == '作者声明：视频内含有危险行为，请勿轻易模仿',
      // 可能引起不适
      isSensitive: view['argue_info']['argue_msg'] == '此内容可能引起不适，请谨慎观看',
      episodes: (view['pages'] as List).map((v) => VideoDetailEpisode.fromJson(v, view['pic'])).toList(),
      collection: view['ugc_season'] != null ? VideoCollection.fromJson(view['ugc_season']) : null,
    );
  }
}

class VideoDetailDescription {
  final String rawText;
  final List<CommentContentUser> users;

  const VideoDetailDescription({required this.rawText, required this.users});

  factory VideoDetailDescription.fromJson(List json) {
    String rawText = '';
    final List<CommentContentUser> users = [];
    for (final item in json) {
      if (item['type'] == 2) {
        users.add(CommentContentUser(id: item['biz_id'].toString(), nickname: item['raw_text']));
        rawText += '@${item['raw_text']}';
      } else {
        rawText += item['raw_text'];
      }
    }

    return VideoDetailDescription(rawText: rawText, users: users);
  }
}

class VideoDetailStats {
  final int view;
  final int danmaku;
  final int comment;
  final int like;
  final int coin;
  final int favorite;
  final int share;

  VideoDetailStats({
    required this.view,
    required this.danmaku,
    required this.comment,
    required this.like,
    required this.coin,
    required this.favorite,
    required this.share,
  });

  factory VideoDetailStats.fromJson(Map<String, dynamic> json) {
    return VideoDetailStats(
      view: json['view'],
      danmaku: json['danmaku'],
      comment: json['reply'],
      like: json['like'],
      coin: json['coin'],
      favorite: json['favorite'],
      share: json['share'],
    );
  }

  VideoDetailStats copyWith({
    int? view,
    int? danmaku,
    int? comment,
    int? like,
    int? coin,
    int? favorite,
    int? share,
  }) {
    return VideoDetailStats(
      view: view ?? this.view,
      danmaku: danmaku ?? this.danmaku,
      comment: comment ?? this.comment,
      like: like ?? this.like,
      coin: coin ?? this.coin,
      favorite: favorite ?? this.favorite,
      share: share ?? this.share,
    );
  }
}

class VideoDetailHonor {
  final int type;
  final String name;

  VideoDetailHonor({
    required this.type,
    required this.name,
  });

  factory VideoDetailHonor.fromJson(Map<String, dynamic> json) {
    return VideoDetailHonor(
      type: json['type'],
      name: json['desc'],
    );
  }
}

class VideoDetailTag {
  final String id;
  final String name;
  final bool isTopic;

  VideoDetailTag({
    required this.id,
    required this.name,
    required this.isTopic,
  });

  factory VideoDetailTag.fromJson(Map<String, dynamic> json) {
    return VideoDetailTag(
      id: json['tag_id'].toString(),
      name: json['tag_name'],
      isTopic: json['tag_type'] == 'topic',
    );
  }
}

class VideoDetailMusic {
  final String id;
  final String name;

  VideoDetailMusic({
    required this.id,
    required this.name,
  });

  factory VideoDetailMusic.fromJson(Map<String, dynamic> json) {
    return VideoDetailMusic(
      id: json['music_id'].toString(),
      name: json['tag_name'].substring(3, json['tag_name'].length - 1),
    );
  }
}

class VideoDetailEpisode {
  final String id;
  final String title;
  final String cover;
  final double duration;
  final int creationTime;

  VideoDetailEpisode({
    required this.id,
    required this.title,
    required this.cover,
    required this.duration,
    required this.creationTime,
  });

  factory VideoDetailEpisode.fromJson(Map<String, dynamic> json, String coverFallback) {
    return VideoDetailEpisode(
      id: json['cid'].toString(),
      title: json['part'],
      cover: json['first_frame'] ?? coverFallback,
      duration: json['duration'].toDouble(),
      creationTime: json['ctime'],
    );
  }
}

class VideoCollection {
  final String id;
  final String title;
  final String cover;
  final String description;
  final int total;
  final List<VideoCollectionGroup> groups;

  VideoCollection({
    required this.id,
    required this.title,
    required this.cover,
    required this.description,
    required this.total,
    required this.groups,
  });

  factory VideoCollection.fromJson(Map<String, dynamic> json) {
    return VideoCollection(
      id: json['id'].toString(),
      title: json['title'],
      cover: json['cover'],
      description: json['intro'],
      total: json['ep_count'],
      groups: (json['sections'] as List).map((v) => VideoCollectionGroup.fromJson(v)).toList(),
    );
  }
}

class VideoCollectionGroup {
  final String name;
  final List<VideoCollectionVideo> videos;

  VideoCollectionGroup({
    required this.name,
    required this.videos,
  });

  factory VideoCollectionGroup.fromJson(Map<String, dynamic> json) {
    return VideoCollectionGroup(
      name: json['title'],
      videos: (json['episodes'] as List).map((v) => VideoCollectionVideo.fromJson(v)).toList(),
    );
  }
}

class VideoCollectionVideo {
  final String id;
  final String bvid;
  final String episodeId;
  final String title;
  final String cover;
  final double duration;
  final int creationTime;
  final int releaseTime;
  final User owner;
  final VideoCollectionVideoStats stats;

  VideoCollectionVideo({
    required this.id,
    required this.bvid,
    required this.episodeId,
    required this.title,
    required this.cover,
    required this.duration,
    required this.creationTime,
    required this.releaseTime,
    required this.owner,
    required this.stats,
  });

  factory VideoCollectionVideo.fromJson(Map<String, dynamic> json) {
    return VideoCollectionVideo(
      id: json['aid'].toString(),
      bvid: json['bvid'],
      episodeId: json['cid'].toString(),
      title: json['arc']['title'],
      cover: json['arc']['pic'],
      duration: json['arc']['duration'].toDouble(),
      creationTime: json['arc']['ctime'],
      releaseTime: json['arc']['pubdate'],
      owner: User(
        id: json['arc']['author']['mid'].toString(),
        nickname: json['arc']['author']['name'],
        avatar: json['arc']['author']['face'],
      ),
      stats: VideoCollectionVideoStats.fromJson(json['arc']['stat']),
    );
  }
}

class VideoCollectionVideoStats {
  final int view;
  final int danmaku;

  VideoCollectionVideoStats({
    required this.view,
    required this.danmaku,
  });

  factory VideoCollectionVideoStats.fromJson(Map<String, dynamic> json) {
    return VideoCollectionVideoStats(
      view: json['view'],
      danmaku: json['danmaku'],
    );
  }
}

class VideoProduction {
  final String id;
  final String nickname;
  final String avatar;
  final String role;
  final int fansCount;

  VideoProduction({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.role,
    required this.fansCount,
  });

  factory VideoProduction.fromJson(Map<String, dynamic> json) {
    return VideoProduction(
      id: json['mid'].toString(),
      nickname: json['name'],
      avatar: json['face'],
      role: json['title'],
      fansCount: json['follower'],
    );
  }
}

class VideoDetailOwner {
  final String id;
  final String nickname;
  final String avatar;
  final String? avatarFrame;
  final UserStats stats;

  VideoDetailOwner({
    required this.id,
    required this.nickname,
    required this.avatar,
    this.avatarFrame,
    required this.stats,
  });

  factory VideoDetailOwner.fromJson(Map<String, dynamic> json) {
    return VideoDetailOwner(
      id: json['card']['mid'].toString(),
      nickname: json['card']['name'],
      avatar: json['card']['face'],
      avatarFrame: json['card']['pendant']['image'].isEmpty ? null : json['card']['pendant']['image'],
      stats: UserStats(
        following: json['card']['friend'],
        fans: json['card']['fans'],
      ),
    );
  }

  VideoDetailOwner copyWith({
    String? id,
    String? nickname,
    String? avatar,
    String? avatarFrame,
    UserStats? stats,
  }) {
    return VideoDetailOwner(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      avatarFrame: avatarFrame ?? this.avatarFrame,
      stats: stats ?? this.stats,
    );
  }
}
