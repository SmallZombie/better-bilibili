import 'package:better_bilibili/config/account_config.dart';
import 'package:better_bilibili/data/repositories/bilibili/article_repository/article_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/services/bilibili/bili_article_web_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_article_colllection_detail_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_article_detail_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_articles_with_user_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_recommend_article_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_anthologys_response.dart';
import 'package:better_bilibili/utils/result.dart';

class ArticleRepositoryLogin implements ArticleRepository {
  final AuthRepository authRepository;
  late final BiliArticleWebApiService articleApiService = BiliArticleWebApiService(
    getClient: () => authRepository.getClient(type: .web, userId: kGuestUserId),
    getAccount: () => authRepository.getAccount('0'),
  );

  ArticleRepositoryLogin({required this.authRepository});

  @override
  Future<Result<List<RecommendArticle>>> getRecommendedList({
    int pn = 1,
    int ps = 20,
  }) {
    return articleApiService.getRecommendedList(pn: pn, ps: ps);
  }

  @override
  Future<Result<ArticleDetail>> getDetail( String articleId) {
    return articleApiService.getDetail(articleId);
  }

  @override
  Future<Result<void>> like({required String articleId, required bool like}) {
    return articleApiService.like(articleId: articleId, like: like);
  }

  @override
  Future<Result<void>> favorite({required String articleId, required bool favorite}) {
    return articleApiService.favorite(articleId: articleId, favorite: favorite);
  }

  @override
  Future<Result<ArticleCollection>> getCollectionDetail( String collectionId) {
    return articleApiService.getCollectionDetail(collectionId);
  }

  @override
  Future<Result<GetArticlesWithUserResponse>> getArticlesWithUser({
    required String userId,
    int pn = 1,
    String? offset,
  }) {
    return articleApiService.getArticlesWithUser(userId: userId, pn: pn, offset: offset);
  }

  @override
  Future<Result<List<GetUserAnthologysItem>>> getUserAnthologys({
    required String userId,
    GetUserAnthologysOrderEnum order = .updateTimeDesc,
  }) {
    return articleApiService.getUserAnthologys(userId: userId, order: order);
  }
}
