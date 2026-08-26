class GetUserVideosWithKeywordResponse {
  final List<GetUserVideosWithKeywordItem> list;
  final int total;

  GetUserVideosWithKeywordResponse({required this.list, required this.total});
}

class GetUserVideosWithKeywordItem {
  final String id;
  final String title;
  final String cover;
  final double duration;
  final int releaseTime;
  final int viewCount;
  final String description;

  GetUserVideosWithKeywordItem({
    required this.id,
    required this.title,
    required this.cover,
    required this.duration,
    required this.releaseTime,
    required this.viewCount,
    required this.description,
  });

  factory GetUserVideosWithKeywordItem.fromJson(Map<String, dynamic> json) {
    return GetUserVideosWithKeywordItem(
      id: json['id'].toString(),
      title: json['title'],
      cover: json['pic'],
      duration: json['duration'].toDouble(),
      releaseTime: json['pubdate'],
      viewCount: json['stat']['view'],
      description: json['desc'],
    );
  }
}
