import 'package:better_bilibili/config/constants.dart';
import 'package:better_bilibili/utils/bili_util.dart';

class GetArticlesWithUserResponse {
  final List<GetArticlesWithUserItem> list;
  final bool hasMore;
  final String? offset;

  GetArticlesWithUserResponse({required this.list, required this.hasMore, this.offset});
}

class GetArticlesWithUserItem {
  final String postId;
  final String title;
  final String cover;
  final int likeCount;

  GetArticlesWithUserItem({
    required this.postId,
    required this.title,
    required this.cover,
    required this.likeCount,
  });

  factory GetArticlesWithUserItem.fromJson(Map<String, dynamic> json) {
    return GetArticlesWithUserItem(
      postId: json['opus_id'].toString(),
      title: json['content'],
      cover: json['cover']?['url'] ?? kEmptyImageUrl,
      likeCount: json['stat'] == null ? 0 : countStrToInt(json['stat']['like']),
    );
  }
}
