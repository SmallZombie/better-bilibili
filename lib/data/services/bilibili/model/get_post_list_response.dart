import 'package:better_bilibili/config/constants.dart';
import 'package:better_bilibili/data/services/bilibili/model/uploaded_image.dart';
import 'package:better_bilibili/domain/models/bilibili/bilibili.dart';
import 'package:better_bilibili/domain/models/bilibili/comment.dart';
import 'package:better_bilibili/domain/models/bilibili/post.dart';
import 'package:better_bilibili/utils/bili_util.dart';
import 'package:flutter/rendering.dart';

enum GetPostListTypeEnum {
  all,
  video,
  article,
}

extension GetPostListTypeEnumExtension on GetPostListTypeEnum {
  String get value => switch (this) {
    GetPostListTypeEnum.all => 'all',
    GetPostListTypeEnum.video => 'video',
    GetPostListTypeEnum.article => 'article',
  };
}

class GetPostListResponse {
  final List<Post> list;
  final bool hasMore;
  final String offset;

  GetPostListResponse({required this.list, required this.hasMore, required this.offset});
}

final _priceRegex = RegExp(r'(\d+\.?\d*)元');

class Post {
  final String id;
  // final String type;
  final PostPublisher owner;
  final PostStats? stats;
  final String? commentId;
  final BiliContentTypeEnum? commentType;
  final int creationTime;
  final String? title;
  final String? content;
  final List<UploadedImage> images;
  final HashTag? hashTag;
  final PostVideo? relatedVideo;
  final PostArticle? relatedArticle;
  final PostGame? relatedGame;
  final Post? quotedPost;
  final PostCollection? relatedCollection;
  final PostMovie? relatedMovie;
  final bool isLiked;
  final SubscriptionTier? requiredTier;

  Post({
    required this.id,
    // required this.type,
    required this.owner,
    this.stats,
    this.commentId,
    this.commentType,
    required this.creationTime,
    this.title,
    this.content,
    required this.images,
    required this.hashTag,
    required this.relatedVideo,
    required this.relatedArticle,
    required this.relatedGame,
    required this.quotedPost,
    required this.relatedCollection,
    required this.relatedMovie,
    required this.isLiked,
    this.requiredTier,
  });

  Post copyWith({
    String? id,
    PostPublisher? owner,
    PostStats? stats,
    String? commentId,
    BiliContentTypeEnum? commentType,
    int? creationTime,
    String? title,
    String? content,
    List<UploadedImage>? images,
    HashTag? hashTag,
    PostVideo? relatedVideo,
    PostArticle? relatedArticle,
    PostGame? relatedGame,
    Post? quotedPost,
    PostCollection? relatedCollection,
    PostMovie? relatedMovie,
    bool? isLiked,
    SubscriptionTier? requiredTier,
  }) {
    return Post(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      stats: stats ?? this.stats,
      commentId: commentId ?? this.commentId,
      commentType: commentType ?? this.commentType,
      creationTime: creationTime ?? this.creationTime,
      title: title ?? this.title,
      content: content ?? this.content,
      images: images ?? this.images,
      hashTag: hashTag ?? this.hashTag,
      relatedVideo: relatedVideo ?? this.relatedVideo,
      relatedArticle: relatedArticle ?? this.relatedArticle,
      relatedGame: relatedGame ?? this.relatedGame,
      quotedPost: quotedPost ?? this.quotedPost,
      relatedCollection: relatedCollection ?? this.relatedCollection,
      relatedMovie: relatedMovie ?? this.relatedMovie,
      isLiked: isLiked ?? this.isLiked,
      requiredTier: requiredTier ?? this.requiredTier,
    );
  }

  /// 不支持 type=DYNAMIC_TYPE_PGC_UNION 的动态
  factory Post.fromJson(Map<String, dynamic> json) {
    List<UploadedImage> parseImages(List<dynamic> images) {
      return images
          .map(
            (value) => UploadedImage(
              src: value['url'],
              width: value['width'],
              height: value['height'],
              size: 0,
            ),
          )
          .toList();
    }

    /// 用于将 '[xxxx年]xx月xx日' 转换为时间戳
    int parsePubTimeToTimestamp(String pubtime) {
      final now = DateTime.now();

      final regexWithYear = RegExp(r'(\d{4})年(\d{1,2})月(\d{1,2})日');
      final regexWithoutYear = RegExp(r'(\d{1,2})月(\d{1,2})日');

      if (regexWithYear.hasMatch(pubtime)) {
        final match = regexWithYear.firstMatch(pubtime)!;
        final year = int.parse(match.group(1)!);
        final month = int.parse(match.group(2)!);
        final day = int.parse(match.group(3)!);
        return DateTime(year, month, day).millisecondsSinceEpoch ~/ 1000;
      } else if (regexWithoutYear.hasMatch(pubtime)) {
        final match = regexWithoutYear.firstMatch(pubtime)!;
        final month = int.parse(match.group(1)!);
        final day = int.parse(match.group(2)!);
        return DateTime(now.year, month, day).millisecondsSinceEpoch ~/ 1000;
      } else {
        throw Exception('Invalid pubtime format: $pubtime');
      }
    }

    final authorModule = json['modules']['module_author'];
    final dynamicModule = json['modules']['module_dynamic'];
    final statModule = json['modules']['module_stat'];

    final PostPublisher owner = switch (authorModule['type']) {
      'AUTHOR_TYPE_UGC_SEASON' => PostPublisher(
        // xxx更新了合集
        nickname: authorModule['pub_action'].replaceFirst('更新了合集', ''),
        avatar: authorModule['face'],
      ),
      'AUTHOR_TYPE_NORMAL' => PostPublisher(
        id: authorModule['mid'].toString(),
        nickname: authorModule['name'],
        avatar: authorModule['face'],
      ),
      _ => throw Exception('Unknown author type: ${authorModule['type']}'),
    };
    String? title;
    String? content;
    List<UploadedImage>? images;
    HashTag? hashTag;
    PostVideo? relatedVideo;
    PostArticle? relatedArticle;
    PostGame? relatedGame;
    Post? quotedPost;
    PostCollection? relatedCollection;
    PostMovie? relatedMovie;
    int creationTime = int.parse(authorModule['pub_ts']);
    SubscriptionTier? requiredTier;

    switch (json['type']) {
      // 图文，发动态默认就是图文，或者说 动态=图文
      case 'DYNAMIC_TYPE_DRAW':
        {
          final major = dynamicModule['major'];

          if (major['type'] == 'MAJOR_TYPE_BLOCKED') {
            final blocked = major['blocked'];
            final name = blocked['hint_message'].split('\n').first.replaceAll('专属专栏', '');

            requiredTier = SubscriptionTier(
              id: '0',
              name: name,
              // "加入当前UP主的「30元档包月充电」即可解锁观看"
              price: double.parse(_priceRegex.firstMatch(blocked['hint_message'])!.group(1)!),
            );

            break;
          }

          final pics = major['opus']['pics'] as List?;
          final topic = dynamicModule['topic'];

          title = major['opus']['title'] as String;
          if (title.isEmpty) title = null;

          content = major['opus']['summary']['text'] as String;
          while (content!.endsWith('\n')) {
            content = content.substring(0, content.length - 2);
          }

          if (pics != null && pics.isNotEmpty) images = parseImages(pics);
          if (topic != null) {
            hashTag = HashTag(
              id: topic['id'].toString(),
              name: topic['name'],
            );
          }

          break;
        }
      // 投稿视频
      case 'DYNAMIC_TYPE_AV':
        {
          content = dynamicModule['desc']?['text'];

          final archive = dynamicModule['major']['archive'];
          relatedVideo = PostVideo(
            id: archive['aid'],
            bvid: archive['bvid'],
            title: archive['title'],
            summary: archive['desc'],
            cover: archive['cover'],
            duration: durationStrToSec(archive['duration_text']),
            owner: owner,
            stats: PostVideoStats(
              view: countStrToInt(archive['stat']['play']),
              danmaku: countStrToInt(archive['stat']['danmaku']),
            ),
          );

          break;
        }
      // 投稿文章
      case 'DYNAMIC_TYPE_ARTICLE':
        {
          final major = dynamicModule['major'];

          if (major['type'] == 'MAJOR_TYPE_BLOCKED') {
            final blocked = major['blocked'];
            final name = blocked['hint_message'].split('\n').first.replaceAll('专属专栏', '');

            requiredTier = SubscriptionTier(
              id: '0',
              name: name,
              // "加入当前UP主的「30元档包月充电」即可解锁观看"
              price: double.parse(_priceRegex.firstMatch(blocked['hint_message'])!.group(1)!),
            );

            break;
          }

          final opus = major['opus'];
          final pics = opus['pics'];
          late final String pic;

          if (pics is String) {
            pic = pics;
          } else if (pics is List) {
            if (pics.isEmpty) {
              pic = kEmptyImageUrl;
            } else if (pics.first is String) {
              pic = pics.first;
            } else {
              pic = pics.first['url'];
            }
          } else {
            pic = pics['url'];
          }

          relatedArticle = PostArticle(
            id: opus['jump_url'].split('/').last,
            title: opus['title'],
            cover: pic,
            summary: handleArticleSummary(opus['summary']['text']),
            owner: owner,
            releaseTime: int.parse(authorModule['pub_ts']),
          );

          break;
        }
      // 转发
      case 'DYNAMIC_TYPE_FORWARD':
        {
          quotedPost = Post.fromJson(json['orig']);

          break;
        }
      // 合集更新
      case 'DYNAMIC_TYPE_UGC_SEASON':
        {
          final ugcSeason = dynamicModule['major']['ugc_season'];
          relatedCollection = PostCollection(
            name: authorModule['name'],
            videoId: ugcSeason['aid'].toString(),
            videoBvid: ugcSeason['bvid'],
            videoTitle: ugcSeason['title'],
            videoCover: ugcSeason['cover'],
            videoDuration: durationStrToSec(ugcSeason['duration_text']),
            videoOwner: owner,
            videoViewCount: countStrToInt(ugcSeason['stat']['play']),
            videoDanmakuCount: countStrToInt(ugcSeason['stat']['danmaku']),
          );

          break;
        }
      // 番剧更新
      case 'DYNAMIC_TYPE_PGC_UNION':
        {
          final pgc = dynamicModule['major']['pgc'];
          relatedMovie = PostMovie(
            id: pgc['season_id'].toString(),
            episodeId: pgc['epid'].toString(),
            title: pgc['title'],
            cover: pgc['cover'],
            stats: PostMovieStats(
              view: countStrToInt(pgc['stat']['play']),
              danmaku: countStrToInt(pgc['stat']['danmaku']),
            ),
          );
          // 此类型下的 `authorModule['pub_ts']` == 0
          // 只能用 `pub_time` 的 '[xxxx年]xx月xx日'
          creationTime = parsePubTimeToTimestamp(dynamicModule['pub_time']);

          break;
        }
      case _:
        {
          print('未解析的动态类型: ${json['type']}');
          content = '未解析的动态类型: [${json['id_str']}] ${json['type']}';
        }
    }

    final additional = dynamicModule['additional']?['common'];
    if (additional != null) {
      if (additional['sub_type'] == 'game') {
        relatedGame = PostGame(
          id: additional['id_str'],
          cover: additional['cover'],
          name: additional['title'],
          description: additional['desc2'],
          tags: additional['desc1'].split('/'),
        );
      } else {
        debugPrint('未解析的 additional 类型: ${additional['sub_type']}');
      }
    }

    return Post(
      id: json['id_str'],
      // type: json['type'],
      owner: owner,
      stats: statModule == null ? null : PostStats.fromJson(statModule),
      commentId: json['basic']['comment_id_str'],
      commentType: BiliContentTypeEnumExtension.fromNumber(json['basic']['comment_type']),
      creationTime: creationTime,
      title: title,
      content: content,
      images: images ?? const [],
      hashTag: hashTag,
      relatedVideo: relatedVideo,
      relatedArticle: relatedArticle,
      relatedGame: relatedGame,
      quotedPost: quotedPost,
      relatedCollection: relatedCollection,
      relatedMovie: relatedMovie,
      // 被转发的动态没有 statModule
      isLiked: statModule?['like']?['status'] == true,
      requiredTier: requiredTier,
    );
  }
}

class PostPublisher {
  final String? id;
  final String nickname;
  final String avatar;

  const PostPublisher({this.id, required this.nickname, required this.avatar});
}

class PostStats {
  final int comment;
  final int share;
  final int like;

  PostStats({required this.comment, required this.share, required this.like});

  PostStats copyWith({
    int? comment,
    int? share,
    int? like,
  }) {
    return PostStats(
      comment: comment ?? this.comment,
      share: share ?? this.share,
      like: like ?? this.like,
    );
  }

  factory PostStats.fromJson(Map<String, dynamic> json) {
    return PostStats(
      comment: json['comment']['count'],
      share: json['forward']['count'],
      like: json['like']['count'],
    );
  }
}

class PostVideo {
  final String id;
  final String bvid;
  final String title;
  final String summary;
  final String cover;
  final double duration;
  final PostPublisher owner;
  final PostVideoStats stats;

  PostVideo({
    required this.id,
    required this.bvid,
    required this.title,
    required this.summary,
    required this.cover,
    required this.duration,
    required this.owner,
    required this.stats,
  });
}

class PostVideoStats {
  final int view;
  final int danmaku;

  PostVideoStats({required this.view, required this.danmaku});
}

class PostArticle {
  final String id;
  final String title;
  final String cover;
  final String? summary;
  final PostPublisher owner;
  final int releaseTime;

  PostArticle({
    required this.id,
    required this.title,
    required this.cover,
    this.summary,
    required this.owner,
    required this.releaseTime,
  });
}

class PostGame {
  final String id;
  final String cover;
  final String name;
  final String description;
  final List<String> tags;

  PostGame({required this.id, required this.cover, required this.name, required this.description, required this.tags});
}

class PostCollection {
  final String name;
  final String videoId;
  final String videoBvid;
  final String videoTitle;
  final String videoCover;
  final double videoDuration;
  final PostPublisher videoOwner;
  final int videoViewCount;
  final int videoDanmakuCount;

  PostCollection({
    required this.name,
    required this.videoId,
    required this.videoBvid,
    required this.videoTitle,
    required this.videoCover,
    required this.videoDuration,
    required this.videoOwner,
    required this.videoViewCount,
    required this.videoDanmakuCount,
  });
}

class PostMovie {
  final String id;
  final String episodeId;
  final String title;
  final String cover;
  final PostMovieStats stats;

  PostMovie({
    required this.id,
    required this.episodeId,
    required this.title,
    required this.cover,
    required this.stats,
  });
}

class PostMovieStats {
  final int view;
  final int danmaku;

  PostMovieStats({required this.view, required this.danmaku});
}
