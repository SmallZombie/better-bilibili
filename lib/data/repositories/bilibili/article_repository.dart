import 'package:better_bilibili/data/services/bilibili/bili_article_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_article_colllection_detail_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_article_detail_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_articles_with_user_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_recommend_article_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_anthologys_response.dart';
import 'package:better_bilibili/utils/result.dart';

class ArticleRepository {
  final BiliArticleApiService _articleApiService;

  ArticleRepository({
    required BiliArticleApiService articleApiService,
  }) : _articleApiService = articleApiService;

  Future<Result<List<RecommendArticle>>> getRecommendedList({
    int pn = 1,
    int ps = 20,
  }) async {
    return _articleApiService.getRecommendedList(pn: pn, ps: ps);
  }

  Future<Result<ArticleDetail>> getDetail({required String articleId}) async {
    return _articleApiService.getDetail(articleId: articleId);
  }

  Future<Result<void>> like({required String articleId, required bool like}) async {
    return _articleApiService.like(articleId: articleId, like: like);
  }

  Future<Result<void>> favorite({required String articleId, required bool favorite}) async {
    return _articleApiService.favorite(articleId: articleId, favorite: favorite);
  }

  Future<Result<ArticleCollection>> getCollectionDetail({required String collectionId}) async {
    return _articleApiService.getCollectionDetail(collectionId: collectionId);
  }

  Future<Result<GetArticlesWithUserResponse>> getArticlesWithUser({
    required String userId,
    int pn = 1,
    String? offset,
  }) async {
    return _articleApiService.getArticlesWithUser(userId: userId, pn: pn, offset: offset);
  }

  Future<Result<List<GetUserAnthologysItem>>> getUserAnthologys({
    required String userId,
    GetUserAnthologysOrderEnum order = .updateTimeDesc,
  }) async {
    return _articleApiService.getUserAnthologys(userId: userId, order: order);
  }
}
