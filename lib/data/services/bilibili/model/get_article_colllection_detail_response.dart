import 'package:better_bilibili/domain/models/bilibili/user.dart';

class ArticleCollection {
  final String id;
  final String name;
  final String description;
  final String cover;
  final User owner;
  final int wordCount;
  final int creationTime;
  final int releaseTime;
  final int modifyTime;
  final List<ArticleCollectionItem> items;

  ArticleCollection({
    required this.id,
    required this.name,
    required this.description,
    required this.cover,
    required this.owner,
    required this.wordCount,
    required this.creationTime,
    required this.releaseTime,
    required this.modifyTime,
    required this.items,
  });

  factory ArticleCollection.fromJson(Map<String, dynamic> json) {
    return ArticleCollection(
      id: json['list']['id'].toString(),
      name: json['list']['name'],
      description: json['list']['summary'],
      owner: User(
        id: json['author']['mid'].toString(),
        nickname: json['author']['name'],
        avatar: json['author']['face'],
      ),
      cover: json['list']['image_url'],
      wordCount: json['list']['words'],
      creationTime: json['list']['ctime'],
      releaseTime: json['list']['publish_time'],
      modifyTime: json['list']['update_time'],
      items: (json['articles'] as List).map((value) => ArticleCollectionItem.fromJson(value)).toList(),
    );
  }
}

class ArticleCollectionItem {
  final String id;
  final String title;
  final String cover;
  final String? summary;
  final int wordCount;
  final int releaseTime;

  ArticleCollectionItem({
    required this.id,
    required this.title,
    required this.cover,
    this.summary,
    required this.wordCount,
    required this.releaseTime,
  });

  factory ArticleCollectionItem.fromJson(Map<String, dynamic> json) {
    return ArticleCollectionItem(
      id: json['dyn_id_str'],
      title: json['title'],
      cover: json['image_urls'].first,
      summary: json['summary'].isEmpty ? null : json['summary'],
      wordCount: json['words'],
      releaseTime: json['publish_time'],
    );
  }
}
