import 'package:better_bilibili/domain/models/bilibili/user.dart';

class GetPlaylistInfoResponse {
  final String id;
  final String name;
  final String cover;
  final int creationTime;
  final String description;
  final int total;
  final User owner;
  final int viewCount;

  GetPlaylistInfoResponse({
    required this.id,
    required this.name,
    required this.cover,
    required this.creationTime,
    required this.description,
    required this.total,
    required this.owner,
    required this.viewCount,
  });

  factory GetPlaylistInfoResponse.fromJson(Map<String, dynamic> json) {
    return GetPlaylistInfoResponse(
      id: json['id'].toString(),
      name: json['title'],
      cover: json['cover'],
      creationTime: json['ctime'],
      description: json['intro'],
      total: json['media_count'],
      owner: User(
        id: json['upper']['mid'].toString(),
        nickname: json['upper']['name'],
        avatar: json['upper']['face'],
      ),
      viewCount: json['cnt_info']['play'],
    );
  }
}
