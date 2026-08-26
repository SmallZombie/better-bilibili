import 'package:better_bilibili/config/constants.dart';

class GetUserCollectionsAndPlaylistsResponse {
  final List<GetUserCollectionsAndPlaylistsItem> list;
  final int total;

  GetUserCollectionsAndPlaylistsResponse({
    required this.list,
    required this.total,
  });
}

class GetUserCollectionsAndPlaylistsItem {
  final String id;
  final String cover;
  final String name;
  final String? description;
  final int total;
  final bool isPlaylist;
  final List<ListVideoItem> videos;

  GetUserCollectionsAndPlaylistsItem({
    required this.id,
    required this.cover,
    required this.name,
    this.description,
    required this.total,
    required this.isPlaylist,
    required this.videos,
  });

  factory GetUserCollectionsAndPlaylistsItem.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'];
    final archives = json['archives'] as List;

    String name = meta['name'];
    String? description = meta['description'];
    if (description!.isEmpty) {
      description = null;
    }
    if (name == '直播回放' && description == '直播回放') {
      description = null;
    }
    if (name.startsWith('合集·')) {
      name = name.substring(3);
    }

    return GetUserCollectionsAndPlaylistsItem(
      id: meta['season_id']?.toString() ?? meta['series_id'].toString(),
      cover: meta['cover'] ?? kEmptyImageUrl,
      name: name,
      description: description,
      total: meta['total'],
      isPlaylist: meta['series_id'] != null,
      videos: archives.map((v) => ListVideoItem.fromJson(v)).toList(),
    );
  }
}

class ListVideoItem {
  final String id;
  final String title;
  final String cover;
  final double duration;
  final int releaseTime;
  final int viewCount;
  final int danmakuCount;

  ListVideoItem({
    required this.id,
    required this.title,
    required this.cover,
    required this.duration,
    required this.releaseTime,
    required this.viewCount,
    required this.danmakuCount,
  });

  factory ListVideoItem.fromJson(Map<String, dynamic> json) {
    return ListVideoItem(
      id: json['aid'].toString(),
      title: json['title'],
      cover: json['pic'],
      duration: json['duration'].toDouble(),
      releaseTime: json['pubdate'],
      viewCount: json['stat']['view'],
      danmakuCount: json['stat']['danmaku'],
    );
  }
}
