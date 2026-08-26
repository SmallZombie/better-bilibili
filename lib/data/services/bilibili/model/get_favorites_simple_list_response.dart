class GetFavoritesSimpleListResponse {
  final List<SimpleFavorites> list;
  final List<String> ids;

  GetFavoritesSimpleListResponse({required this.list, required this.ids});
}

class SimpleFavorites {
  final String id;
  final String userId;
  final String name;
  final int total;
  final bool isPrivate;
  final bool isDefault;
  final bool isSelected;

  SimpleFavorites({
    required this.id,
    required this.userId,
    required this.name,
    required this.total,
    required this.isPrivate,
    required this.isDefault,
    required this.isSelected,
  });

  factory SimpleFavorites.fromJson(Map<String, dynamic> item) {
    return SimpleFavorites(
      id: item['id'].toString(),
      userId: item['mid'].toString(),
      name: item['title'],
      total: item['media_count'],
      // 属性位 0 为 1 时为私有
      isPrivate: (item['attr'] & 1) == 1,
      // 属性位 1 为 0 时为默认收藏夹
      isDefault: (item['attr'] & 2) == 0,
      isSelected: item['fav_state'] == 1,
    );
  }
}
