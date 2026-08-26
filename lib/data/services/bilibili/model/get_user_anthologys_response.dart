enum GetUserAnthologysOrderEnum {
  updateTimeDesc,
  viewCountDesc,
}

extension GetUserAnthologysOrderEnumExtension on GetUserAnthologysOrderEnum {
  int get value => switch (this) {
    .updateTimeDesc => 0,
    .viewCountDesc => 1,
  };
}

class GetUserAnthologysItem {
  final String id;
  final String cover;
  final String name;
  final String? description;
  final int viewCount;
  final int wordCount;
  final int total;
  final int creationTime;
  final int modifyTime;

  GetUserAnthologysItem({
    required this.id,
    required this.cover,
    required this.name,
    this.description,
    required this.viewCount,
    required this.wordCount,
    required this.total,
    required this.creationTime,
    required this.modifyTime,
  });

  factory GetUserAnthologysItem.fromJson(Map<String, dynamic> json) {
    return GetUserAnthologysItem(
      id: json['id'].toString(),
      cover: json['image_url'],
      name: json['name'],
      description: json['summary'].isEmpty ? null : json['summary'],
      viewCount: json['read'],
      wordCount: json['words'],
      total: json['articles_count'],
      creationTime: json['ctime'],
      modifyTime: json['update_time'],
    );
  }
}
