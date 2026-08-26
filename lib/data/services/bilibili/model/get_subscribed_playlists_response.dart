import 'package:better_bilibili/domain/models/bilibili/user.dart';

class GetSubscribedPlaylistsResponse {
  final int total;
  final bool hasMore;
  final List<dynamic> list;

  GetSubscribedPlaylistsResponse({required this.total, required this.hasMore, required this.list});
}

class SubscribedPlaylist {
  final String id;
  final String name;
  final String? description;
  final String cover;
  final int total;
  final User owner;
  final int modifyTime;

  SubscribedPlaylist({
    required this.id,
    required this.name,
    this.description,
    required this.cover,
    required this.total,
    required this.owner,
    required this.modifyTime,
  });

  factory SubscribedPlaylist.fromJson(Map<String, dynamic> json) {
    return SubscribedPlaylist(
      id: json['id'].toString(),
      name: json['title'],
      description: json['intro'],
      cover: json['cover'],
      total: json['media_count'],
      owner: User(
        id: json['upper']['mid'].toString(),
        nickname: json['upper']['name'],
        avatar: '',
      ),
      modifyTime: json['mtime'],
    );
  }
}

class SubscribedFavorites {
  final String id;
  final String name;
  final String? description;
  final String cover;
  final int total;
  final User owner;
  final int creationTime;
  final int modifyTime;

  SubscribedFavorites({
    required this.id,
    required this.name,
    this.description,
    required this.cover,
    required this.total,
    required this.owner,
    required this.creationTime,
    required this.modifyTime,
  });

  factory SubscribedFavorites.fromJson(Map<String, dynamic> json) {
    return SubscribedFavorites(
      id: json['id'].toString(),
      name: json['title'],
      description: json['intro'],
      cover: json['cover'],
      total: json['media_count'],
      owner: User(
        id: json['upper']['mid'].toString(),
        nickname: json['upper']['name'],
        avatar: '',
      ),
      creationTime: json['ctime'],
      modifyTime: json['mtime'],
    );
  }
}
