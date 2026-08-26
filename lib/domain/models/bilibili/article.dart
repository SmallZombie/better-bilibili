class ArticleStats {
  final int view;
  final int like;
  final int favorite;

  ArticleStats({
    required this.view,
    required this.like,
    required this.favorite,
  });

  factory ArticleStats.fromJson(Map<String, dynamic> json) {
    return ArticleStats(
      view: json['view'],
      like: json['like'],
      favorite: json['favorite'],
    );
  }

  ArticleStats copyWith({
    int? view,
    int? like,
    int? favorite,
  }) {
    return ArticleStats(
      view: view ?? this.view,
      like: like ?? this.like,
      favorite: favorite ?? this.favorite,
    );
  }
}

class ArticleCategory {
  final int categoryId;
  final String categoryName;
  final int subcategoryId;
  final String subcategoryName;

  ArticleCategory({
    required this.categoryId,
    required this.categoryName,
    required this.subcategoryId,
    required this.subcategoryName,
  });

  factory ArticleCategory.fromJson(List<dynamic> json) {
    final category = json.firstWhere((v) => v['parent_id'] == 0);
    final subcategory = json.firstWhere((v) => v['parent_id'] != 0);
    return ArticleCategory(
      categoryId: category['id'],
      categoryName: category['name'],
      subcategoryId: subcategory['id'],
      subcategoryName: subcategory['name'],
    );
  }
}
