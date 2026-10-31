import 'package:better_bilibili/data/repositories/bilibili/article_repository/article_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_article_colllection_detail_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_article_detail_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_articles_with_user_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_recommend_article_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_anthologys_response.dart';
import 'package:better_bilibili/domain/models/bilibili/article.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:better_bilibili/utils/bilibili/mock_data_generator_util.dart';
import 'package:better_bilibili/utils/result.dart';

class ArticleRepositoryMock implements ArticleRepository {
  @override
  Future<Result<void>> favorite({required String articleId, required bool favorite}) {
    return Future.value(Result.ok(null));
  }

  @override
  Future<Result<GetArticlesWithUserResponse>> getArticlesWithUser({required String userId, int pn = 1, String? offset}) {
    return Future.value(
      Result.ok(
        GetArticlesWithUserResponse(
          hasMore: true,
          offset: '-',
          list: List.generate(20, (index) {
            return GetArticlesWithUserItem(
              postId: ArticleMock.getId(),
              title: ArticleMock.getTitle(),
              cover: ArticleMock.getCover(),
              likeCount: ArticleMock.getLikeCount(),
            );
          }),
        ),
      ),
    );
  }

  @override
  Future<Result<ArticleCollection>> getCollectionDetail(String collectionId) {
    return Future.value(
      Result.ok(
        ArticleCollection(
          id: ArticleMock.getId(),
          name: ArticleMock.getTitle(),
          description: ArticleMock.getDescription(),
          cover: ArticleMock.getCover(),
          owner: UserMock.getUser(),
          wordCount: ArticleMock.getWordCount(),
          creationTime: ArticleMock.getCreationTime(),
          releaseTime: ArticleMock.getReleaseTime(),
          modifyTime: ArticleMock.getModifyTime(),
          items: List.generate(20, (index) {
            return ArticleCollectionItem(
              id: ArticleMock.getId(),
              title: ArticleMock.getTitle(),
              cover: ArticleMock.getCover(),
              wordCount: ArticleMock.getWordCount(),
              releaseTime: ArticleMock.getReleaseTime(),
              summary: ArticleMock.getDescription(),
            );
          }),
        ),
      ),
    );
  }

  @override
  Future<Result<ArticleDetail>> getDetail(String articleId) {
    return Future.value(
      Result.ok(
        ArticleDetail(
          id: ArticleMock.getId(),
          postId: ArticleMock.getId(),
          covers: [ArticleMock.getCover()],
          title: ArticleMock.getTitle(),
          owner: UserMock.getUser(),
          creationTime: ArticleMock.getCreationTime(),
          releaseTime: ArticleMock.getReleaseTime(),
          modifyTime: ArticleMock.getModifyTime(),
          copyright: true,
          stats: ArticleStats(
            view: ArticleMock.getViewCount(),
            like: ArticleMock.getLikeCount(),
            favorite: ArticleMock.getFavoriteCount(),
          ),
          summary: ArticleMock.getDescription(),
          tags: List.generate(3, (index) => ArticleMock.getTag()),
          category: ArticleCategory(
            categoryId: ArticleMock.getCategoryId(),
            categoryName: ArticleMock.getCategoryName(),
            subcategoryId: getRandomInt(10000, 1000000),
            subcategoryName: ArticleMock.getCategoryName(),
          ),
          wordCount: ArticleMock.getWordCount(),
        ),
      ),
    );
  }

  @override
  Future<Result<List<RecommendArticle>>> getRecommendedList({int pn = 1, int ps = 20}) {
    return Future.value(
      Result.ok(
        List.generate(ps, (index) {
          return RecommendArticle(
            id: ArticleMock.getId(),
            title: ArticleMock.getTitle(),
            covers: [ArticleMock.getCover()],
            owner: UserMock.getUser(),
            stats: ArticleStats(
              view: ArticleMock.getViewCount(),
              like: ArticleMock.getLikeCount(),
              favorite: ArticleMock.getFavoriteCount(),
            ),
            creationTime: ArticleMock.getCreationTime(),
            releaseTime: ArticleMock.getReleaseTime(),
            modifyTime: ArticleMock.getModifyTime(),
            category: ArticleCategory(
              categoryId: ArticleMock.getCategoryId(),
              categoryName: ArticleMock.getCategoryName(),
              subcategoryId: ArticleMock.getCategoryId(),
              subcategoryName: ArticleMock.getCategoryName(),
            ),
          );
        }),
      ),
    );
  }

  @override
  Future<Result<List<GetUserAnthologysItem>>> getUserAnthologys({
    required String userId,
    GetUserAnthologysOrderEnum order = .updateTimeDesc,
  }) {
    return Future.value(
      Result.ok(
        List.generate(10, (index) {
          return GetUserAnthologysItem(
            id: ArticleMock.getId(),
            cover: ArticleMock.getCover(),
            name: ArticleMock.getTag(),
            viewCount: ArticleMock.getViewCount(),
            wordCount: ArticleMock.getWordCount(),
            total: getRandomInt(1, 100),
            creationTime: ArticleMock.getCreationTime(),
            modifyTime: ArticleMock.getModifyTime(),
          );
        }),
      ),
    );
  }

  @override
  Future<Result<void>> like({required String articleId, required bool like}) {
    return Future.value(Result.ok(null));
  }
}
