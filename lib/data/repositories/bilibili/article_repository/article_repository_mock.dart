import 'package:better_bilibili/data/repositories/bilibili/article_repository/article_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_article_colllection_detail_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_article_detail_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_articles_with_user_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_recommend_article_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_anthologys_response.dart';
import 'package:better_bilibili/utils/result.dart';

class ArticleRepositoryMock implements ArticleRepository {
  @override
  Future<Result<void>> favorite({required String articleId, required bool favorite}) {
    // TODO: implement favorite
    throw UnimplementedError();
  }

  @override
  Future<Result<GetArticlesWithUserResponse>> getArticlesWithUser({required String userId, int pn = 1, String? offset}) {
    // TODO: implement getArticlesWithUser
    throw UnimplementedError();
  }

  @override
  Future<Result<ArticleCollection>> getCollectionDetail({required String collectionId}) {
    // TODO: implement getCollectionDetail
    throw UnimplementedError();
  }

  @override
  Future<Result<ArticleDetail>> getDetail({required String articleId}) {
    // TODO: implement getDetail
    throw UnimplementedError();
  }

  @override
  Future<Result<List<RecommendArticle>>> getRecommendedList({int pn = 1, int ps = 20}) {
    // TODO: implement getRecommendedList
    throw UnimplementedError();
  }

  @override
  Future<Result<List<GetUserAnthologysItem>>> getUserAnthologys({
    required String userId,
    GetUserAnthologysOrderEnum order = .updateTimeDesc,
  }) {
    // TODO: implement getUserAnthologys
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> like({required String articleId, required bool like}) {
    // TODO: implement like
    throw UnimplementedError();
  }
}
