import 'package:better_bilibili/data/services/bilibili/model/get_article_colllection_detail_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_article_detail_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_articles_with_user_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_recommend_article_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_anthologys_response.dart';
import 'package:better_bilibili/utils/result.dart';

abstract interface class ArticleRepository {
  Future<Result<List<RecommendArticle>>> getRecommendedList({
    int pn = 1,
    int ps = 20,
  });

  Future<Result<ArticleDetail>> getDetail(String articleId);

  Future<Result<void>> like({required String articleId, required bool like});

  Future<Result<void>> favorite({required String articleId, required bool favorite});

  Future<Result<ArticleCollection>> getCollectionDetail(String collectionId);

  Future<Result<GetArticlesWithUserResponse>> getArticlesWithUser({
    required String userId,
    int pn = 1,
    String? offset,
  });

  Future<Result<List<GetUserAnthologysItem>>> getUserAnthologys({
    required String userId,
    GetUserAnthologysOrderEnum order = .updateTimeDesc,
  });
}
