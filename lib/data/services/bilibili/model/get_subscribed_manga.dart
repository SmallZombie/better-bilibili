enum GetSubscribedMangaOrderEnum {
  subscribeDesc,
  updateDesc,
  readDesc,
}

extension GetSubscribedMangaOrderEnumExtension on GetSubscribedMangaOrderEnum {
  int get value => switch (this) {
    GetSubscribedMangaOrderEnum.subscribeDesc => 1,
    GetSubscribedMangaOrderEnum.updateDesc => 2,
    GetSubscribedMangaOrderEnum.readDesc => 3,
  };
}

class GetSubscribedMangaResponse {
  final bool hasMore;
  final List<SubscribedManga> list;

  GetSubscribedMangaResponse({required this.hasMore, required this.list});
}

class SubscribedManga {
  final String id;
  final String title;
  final String cover;
  final int currentChapter;
  final int totalChapter;

  SubscribedManga({
    required this.id,
    required this.title,
    required this.cover,
    required this.currentChapter,
    required this.totalChapter,
  });

  factory SubscribedManga.fromJson(Map<String, dynamic> json) {
    return SubscribedManga(
      id: json['comic_id'].toString(),
      title: json['title'],
      cover: json['vcover'],
      currentChapter: json['last_ord'],
      totalChapter: json['ord_count'],
    );
  }
}
