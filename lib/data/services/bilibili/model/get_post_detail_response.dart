import 'package:better_bilibili/domain/models/bilibili/bilibili.dart';
import 'package:better_bilibili/domain/models/bilibili/comment.dart';
import 'package:better_bilibili/domain/models/bilibili/post.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/utils/bili/bili_util.dart';
import 'package:flutter_quill/quill_delta.dart';

class PostDetail {
  final String id;
  final String? cover;
  final String? title;
  final User owner;
  final int? releaseTime;
  final int? modifyTime;
  final String? collectionId;
  final Topic? topic;
  final Delta? content;
  final List<String> tags;
  final bool copyright;
  final PostStats stats;
  final PostDetailForum? forum;
  final PostInteraction interaction;
  final BiliContentTypeEnum commentType;
  final String commentId;
  final SubscriptionTier? requiredTier;

  PostDetail({
    required this.id,
    this.cover,
    this.title,
    required this.owner,
    this.releaseTime,
    this.modifyTime,
    this.collectionId,
    this.topic,
    this.content,
    required this.tags,
    required this.copyright,
    required this.stats,
    this.forum,
    required this.interaction,
    required this.commentType,
    required this.commentId,
    this.requiredTier,
  });

  PostDetail copyWith({
    String? id,
    String? cover,
    String? title,
    User? owner,
    int? releaseTime,
    int? modifyTime,
    String? collectionId,
    Topic? topic,
    Delta? content,
    List<String>? tags,
    bool? copyright,
    PostStats? stats,
    PostDetailForum? forum,
    PostInteraction? interaction,
    BiliContentTypeEnum? commentType,
    String? commentId,
    SubscriptionTier? requiredTier,
  }) {
    return PostDetail(
      id: id ?? this.id,
      cover: cover ?? this.cover,
      title: title ?? this.title,
      owner: owner ?? this.owner,
      releaseTime: releaseTime ?? this.releaseTime,
      modifyTime: modifyTime ?? this.modifyTime,
      collectionId: collectionId ?? this.collectionId,
      topic: topic ?? this.topic,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      copyright: copyright ?? this.copyright,
      stats: stats ?? this.stats,
      forum: forum ?? this.forum,
      interaction: interaction ?? this.interaction,
      commentType: commentType ?? this.commentType,
      commentId: commentId ?? this.commentId,
      requiredTier: requiredTier ?? this.requiredTier,
    );
  }

  factory PostDetail.fromJson(Map<String, dynamic> json) {
    // dart format off
    final topModule = (json['modules'] as List).firstWhere(
      (v) => v['module_type'] == 'MODULE_TYPE_TOP',
      orElse: () => null,
    )?['module_top'];
    final titleModule = (json['modules'] as List).firstWhere(
      (v) => v['module_type'] == 'MODULE_TYPE_TITLE',
      orElse: () => null,
    )?['module_title'];
    final authorModule = (json['modules'] as List).firstWhere((v) => v['module_type'] == 'MODULE_TYPE_AUTHOR')['module_author'];
    final topicModule = (json['modules'] as List).firstWhere(
      (v) => v['module_type'] == 'MODULE_TYPE_TOPIC',
      orElse: () => null,
    )?['module_topic'];
    final contentModule = (json['modules'] as List).firstWhere(
      (v) => v['module_type'] == 'MODULE_TYPE_CONTENT',
      orElse: () => null,
    )?['module_content'];
    final extendModule = (json['modules'] as List).firstWhere(
      (v) => v['module_type'] == 'MODULE_TYPE_EXTEND',
      orElse: () => null,
    )?['module_extend'];
    final copyrightModule = (json['modules'] as List).firstWhere(
      (v) => v['module_type'] == 'MODULE_TYPE_COPYRIGHT',
      orElse: () => null,
    )?['module_copyright'];
    final statModule = (json['modules'] as List).firstWhere((v) => v['module_type'] == 'MODULE_TYPE_STAT')['module_stat'];
    final blockedModule = (json['modules'] as List).firstWhere(
      (v) => v['module_type'] == 'MODULE_TYPE_BLOCKED',
      orElse: () => null,
    )?['module_blocked'];
    // dart format on

    final List<String> tags = [];
    PostDetailForum? forum;
    if (extendModule != null) {
      for (final item in extendModule['items']) {
        if (item['jump_url'].contains('tribee')) {
          final reg = RegExp(r'/tribee/home/(\d+)(?:\?[^#]*category_id=(\d+))?');
          // `//www.bilibili.com/tribee/home/39?category_id=350`
          final match = reg.firstMatch(item['jump_url']);

          forum = PostDetailForum(
            categoryId: match!.group(1)!,
            // `柚子社小站`
            categoryName: item['text'].substring(0, item['text'].length - 2),
            forumId: match.group(2)!,
          );
        } else {
          tags.add(item['text']);
        }
      }
    }

    String? cover;
    if (topModule != null) {
      final type = topModule['display']['type'];
      if (type == 1) {
        cover = topModule['display']['album']['pics'].first['url'];
      } else if (type == 2) {
        cover = topModule['display']['video']['cover'];
      }
    }

    bool isModified = authorModule['pub_time'].contains('编辑');

    SubscriptionTier? requiredTier;
    if (blockedModule != null) {
      final name = blockedModule['hint_message'].split('\n').first.replaceAll('专属专栏', '');
      requiredTier = SubscriptionTier(
        id: '0',
        name: name,
        // description: blockedModule['hint_message'].split('\n').last,
        price: double.parse(blockedModule['hint_message'].split('元').first),
      );
    }

    final String collectionId = json['basic']['collection_id'];

    return PostDetail(
      id: json['id_str'],
      cover: cover,
      title: titleModule?['text'],
      owner: User(
        id: authorModule['mid'].toString(),
        nickname: authorModule['name'],
        avatar: authorModule['face'],
      ),
      // b站只返回一个时间戳，只能这样了
      releaseTime: isModified ? null : int.parse(authorModule['pub_ts']),
      modifyTime: isModified ? int.parse(authorModule['pub_ts']) : null,
      collectionId: collectionId != '0' ? collectionId : null,
      topic: topicModule == null ? null : Topic(id: topicModule['id'].toString(), name: topicModule['name']),
      content: contentModule == null ? null : parsePostContentToDelta(contentModule['paragraphs'] as List),
      tags: tags,
      copyright: copyrightModule == null ? false : copyrightModule['left_text'] == '本文为我原创，未经授权禁止转载',
      stats: PostStats(
        like: statModule['like']['count'],
        favorite: statModule['favorite']['count'],
        coin: statModule['coin']['count'],
        comment: statModule['comment']['count'],
        share: statModule['forward']['count'],
      ),
      forum: forum,
      interaction: PostInteraction(
        hasLiked: statModule['like']?['status'] ?? false,
        hasFavorited: statModule['favorite']?['status'] ?? false,
        hasCoind: statModule['coin']?['status'] ?? false,
      ),
      commentType: BiliContentTypeEnumExtension.fromNumber(json['basic']['comment_type']),
      commentId: json['basic']['comment_id_str'],
      requiredTier: requiredTier,
    );
  }
}

// 小站
class PostDetailForum {
  final String categoryId;
  final String categoryName;
  final String? forumId;

  PostDetailForum({
    required this.categoryId,
    required this.categoryName,
    this.forumId,
  });
}

class PostInteraction {
  final bool hasLiked;
  final bool hasFavorited;
  final bool hasCoind;

  PostInteraction({
    required this.hasLiked,
    required this.hasFavorited,
    required this.hasCoind,
  });

  PostInteraction copyWith({
    bool? hasLiked,
    bool? hasFavorited,
    bool? hasCoind,
  }) {
    return PostInteraction(
      hasLiked: hasLiked ?? this.hasLiked,
      hasFavorited: hasFavorited ?? this.hasFavorited,
      hasCoind: hasCoind ?? this.hasCoind,
    );
  }
}
