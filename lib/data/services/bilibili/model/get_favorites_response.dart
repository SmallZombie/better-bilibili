import 'package:better_bilibili/domain/models/bilibili/user.dart';

class GetFavoritesResponse {
  final List<Favorites> list;
  final int total;
  final bool hasMore;

  GetFavoritesResponse({required this.list, required this.total, required this.hasMore});
}

class Favorites {
  final String id;
  final String name;
  final String? cover;
  final int total;
  final User owner;
  final bool isPrivate;
  final bool isDefault;
  final int creationTime;
  final int modifyTime;

  Favorites({
    required this.id,
    required this.name,
    this.cover,
    required this.total,
    required this.owner,
    required this.isPrivate,
    required this.isDefault,
    required this.creationTime,
    required this.modifyTime,
  });

  factory Favorites.fromJson(Map<String, dynamic> item) {
    return Favorites(
      id: item['id'].toString(),
      name: item['title'],
      // 未设置封面且收藏夹内没有视频/首个视频失效时封面为空字符串
      cover: item['cover']?.isEmpty ? null : item['cover'],
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
