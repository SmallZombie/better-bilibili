import 'package:better_bilibili/domain/models/bilibili/article.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/utils/bili/bili_util.dart';
import 'package:flutter_quill/quill_delta.dart';

class ArticleDetail {
  final String id;
  final String postId;
  final List<String> covers;
  final String title;
  final User owner;
  final Delta? content;
  final int creationTime;
  final int releaseTime;
  final int modifyTime;
  final bool copyright;
  final ArticleStats stats;
  final String? summary;
  final List<String> tags;
  final ArticleCategory category;
  final int wordCount;
  final String? collectionId;

  ArticleDetail({
    required this.id,
    required this.postId,
    required this.covers,
    required this.title,
    required this.owner,
    this.content,
    required this.creationTime,
    required this.releaseTime,
    required this.modifyTime,
    required this.copyright,
    required this.stats,
    required this.summary,
    required this.tags,
    required this.category,
    required this.wordCount,
    this.collectionId,
  });

  factory ArticleDetail.fromJson(Map<String, dynamic> json) {
    final paragraphs = json['opus']['content']['paragraphs'] as List?;

    return ArticleDetail(
      id: json['id'].toString(),
      postId: json['dyn_id_str'],
      covers: json['origin_image_urls'].cast<String>(),
      title: json['title'],
      owner: User(
        id: json['author']['mid'].toString(),
        nickname: json['author']['name'],
        avatar: json['author']['face'],
      ),
      // 这个 content 里的内容参差不齐
      // 比如 25817263 的 content 里是没有格式只有换行的纯文本
      // 27705422 则是一种与 opus 里不同的富文本 json (`{"ops": [{"insert": "..."}]}`)
      // 没有权限访问时 content 为 null，比如充电文章(专栏)
      content: paragraphs != null ? parseArticleContentToDelta(paragraphs) : null,
      creationTime: json['ctime'],
      releaseTime: json['publish_time'],
      modifyTime: json['mtime'],
      copyright: json['original'] == 1,
      stats: ArticleStats.fromJson(json['stats']),
      summary: handleArticleSummary(json['summary']),
      tags: (json['tags'] as List? ?? const []).map<String>((value) => value['name']).toList(),
      category: ArticleCategory.fromJson(json['categories'] as List),
      wordCount: json['words'],
      collectionId: json['list'] != null ? json['list']['id'].toString() : null,
    );
  }
}
