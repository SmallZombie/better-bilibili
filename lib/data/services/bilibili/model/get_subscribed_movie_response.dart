import 'package:better_bilibili/data/model/bilibili/movie_model.dart';

class GetSubscribedMovieResponse {
  final int total;
  final List<SubscribedMovie> list;

  GetSubscribedMovieResponse({required this.total, required this.list});
}

class SubscribedMovie {
  final String id;
  final String title;
  final String cover;
  final String? category;
  final List<MovieCountry> countries;
  final int year;
  // 由于b站不给当前集数，给的 progress 还是字符串，而且字符串里的集数还是标题(不是索引)，
  // 没办法只能用他的给的字符串了，要不然总不能不显示看到哪了吧...
  final String? watchProgressStr;
  final String? badge;
  final MovieWatchStatus watchStatus;

  SubscribedMovie({
    required this.id,
    required this.title,
    required this.cover,
    this.category,
    required this.countries,
    required this.year,
    this.watchProgressStr,
    this.badge,
    required this.watchStatus,
  });

  factory SubscribedMovie.fromJson(Map<String, dynamic> json) {
    final areas = json['areas'] as List?;
    return SubscribedMovie(
      id: json['season_id'].toString(),
      title: json['title'],
      cover: json['cover'],
      category: json['styles'] == null ? null : (json['styles'] as List).first,
      countries: areas == null ? [] : areas.map((v) => MovieCountry(id: v['id'].toString(), name: v['name'])).toList(),
      // `2020-04-03`
      year: int.parse(json['publish']['release_date'].split('-').first),
      // 此处可能为空字符串(没看)、`看到 57:16`(电影)、`看到 1:32:38`(超过1h的电影)、`看到2025B站跨年晚会第二波阵容官 0:31`(综艺) 和 `已看完`
      watchProgressStr: json['progress'].isEmpty ? null : json['progress'],
      badge: json['badge'].isEmpty ? null : json['badge'],
      watchStatus: switch (json['follow_status']) {
        // 只在官测号(14135892)主页见过的 0
        0 => .unwatched,
        1 => .unwatched,
        2 => .watching,
        3 => .watched,
        _ => throw Exception('Invalid watch status: ${json['follow_status']}'),
      },
    );
  }

  SubscribedMovie copyWith({
    MovieWatchStatus? watchStatus,
  }) {
    return SubscribedMovie(
      id: id,
      title: title,
      cover: cover,
      category: category,
      countries: countries,
      year: year,
      watchProgressStr: watchProgressStr,
      badge: badge,
      watchStatus: watchStatus ?? this.watchStatus,
    );
  }
}
