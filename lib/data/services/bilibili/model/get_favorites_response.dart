import 'package:better_bilibili/domain/models/bilibili/user.dart';

class GetFavoritesResponse {
  final List<FavoriteFolder> list;
  final int total;
  final bool hasMore;

  GetFavoritesResponse({required this.list, required this.total, required this.hasMore});
}

class FavoriteFolder {
  final String id;
  final String? cover;
  final String name;
  final String? description;
  final int total;
  final User owner;
  final bool isPrivate;
  final bool isDefault;
  final int creationTime;
  final int modifyTime;

  FavoriteFolder({
    required this.id,
    this.cover,
    required this.name,
    this.description,
    required this.total,
    required this.owner,
    required this.isPrivate,
    required this.isDefault,
    required this.creationTime,
    required this.modifyTime,
  });

  FavoriteFolder copyWith({
    String? id,
    String? cover,
    String? name,
    String? description,
    int? total,
    User? owner,
    bool? isPrivate,
    bool? isDefault,
    int? creationTime,
    int? modifyTime,
  }) {
    return FavoriteFolder(
      id: id ?? this.id,
      cover: cover ?? this.cover,
      name: name ?? this.name,
      description: description ?? this.description,
      total: total ?? this.total,
      owner: owner ?? this.owner,
      isPrivate: isPrivate ?? this.isPrivate,
      isDefault: isDefault ?? this.isDefault,
      creationTime: creationTime ?? this.creationTime,
      modifyTime: modifyTime ?? this.modifyTime,
    );
  }

  factory FavoriteFolder.fromJson(Map<String, dynamic> item) {
    return FavoriteFolder(
      id: item['id'].toString(),
      // 未设置封面且收藏夹内没有视频/首个视频失效时封面为空字符串
      cover: item['cover']?.isEmpty ? null : item['cover'],
      name: item['title'],
      description: item['intro'].isEmpty ? null : item['intro'],
      total: item['media_count'],
      owner: User(
        id: item['upper']['mid'].toString(),
        nickname: item['upper']['name'],
        avatar: item['upper']['face'],
      ),
      // 属性位 0 为 1 时为私有
      isPrivate: (item['attr'] & 1) == 1,
      // 属性位 1 为 0 时为默认收藏夹
      isDefault: (item['attr'] & 2) == 0,
      creationTime: item['ctime'],
      modifyTime: item['mtime'],
    );
  }
}
