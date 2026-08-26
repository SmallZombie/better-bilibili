enum GetUserAudiosOrderEnum {
  releaseTimeDesc,
  playCountDesc,
  favoritesCountDesc,
}

extension GetUserAudiosOrderEnumExtension on GetUserAudiosOrderEnum {
  int get value => switch (this) {
    .releaseTimeDesc => 1,
    .playCountDesc => 2,
    .favoritesCountDesc => 3,
  };
}

class GetUserAudiosResponse {
  final List<GetUserAudiosItem> list;
  final int total;

  GetUserAudiosResponse({required this.list, required this.total});
}

class GetUserAudiosItem {
  final String id;
  final String cover;
  final String name;
  final double duration;
  final int releaseTime;
  final int playCount;

  GetUserAudiosItem({
    required this.id,
    required this.cover,
    required this.name,
    required this.duration,
    required this.releaseTime,
    required this.playCount,
  });

  factory GetUserAudiosItem.fromJson(Map<String, dynamic> json) {
    return GetUserAudiosItem(
      id: json['id'].toString(),
      cover: json['cover'],
      name: json['title'],
      duration: json['duration'].toDouble(),
      releaseTime: json['passtime'],
      playCount: json['statistic']['play'],
    );
  }
}
