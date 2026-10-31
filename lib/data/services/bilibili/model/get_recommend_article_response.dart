import 'package:better_bilibili/domain/models/bilibili/article.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/utils/bilibili/bili_util.dart';

class RecommendArticle {
  final String id;
  final String title;
  final List<String> covers;
  final String? summary;
  final User owner;
  final ArticleStats stats;
  final int creationTime;
  final int releaseTime;
  final int modifyTime;
  final ArticleCategory category;

  RecommendArticle({
    required this.id,
    required this.title,
    required this.covers,
    this.summary,
    required this.owner,
    required this.stats,
    required this.creationTime,
    required this.releaseTime,
    required this.modifyTime,
    required this.category,
  });

  factory RecommendArticle.fromJson(Map<String, dynamic> json) {
    return RecommendArticle(
      id: json['id'].toString(),
      title: json['title'],
      covers: json['origin_image_urls'].cast<String>(),
      summary: handleArticleSummary(json['summary']),
      owner: User(
        id: json['author']['mid'].toString(),
        nickname: json['author']['name'],
        avatar: json['author']['face'],
      ),
      stats: ArticleStats.fromJson(json['stats']),
      creationTime: json['ctime'],
      releaseTime: json['publish_time'],
      modifyTime: json['mtime'],
      category: ArticleCategory.fromJson(json['categories'] as List),
    );
  }
}
