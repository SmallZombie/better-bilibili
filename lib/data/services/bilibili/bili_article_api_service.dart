import 'package:better_bilibili/data/repositories/bilibili/auth_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_article_colllection_detail_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_article_detail_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_articles_with_user_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_recommend_article_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_anthologys_response.dart';
import 'package:better_bilibili/utils/bili_util.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:dio/dio.dart';

class BiliArticleApiService {
  final AuthRepository _authRepository;

  BiliArticleApiService({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  /// 注意此接口并不总是遵循 ps
  Future<Result<List<RecommendArticle>>> getRecommendedList({
    int pn = 1,
    int ps = 20,
  }) async {
    assert(pn > 0 && ps > 0);

    final client = await _authRepository.getClient();
    final resp = await client.get(
      'https://api.bilibili.com/x/article/recommends',
      queryParameters: {
        'cid': 0,
        'pn': pn,
        'ps': ps,
        'aids': '',
        'sort': 0,
        'web_location': WebLocation.articleHome,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    final List<RecommendArticle> list = [];
    for (final item in resp.data['data']) {
      list.add(RecommendArticle.fromJson(item));
    }

    return Result.ok(list);
  }

  Future<Result<ArticleDetail>> getDetail({required String articleId}) async {
    assert(articleId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final params = {
      'id': articleId,
      'gaia_source': 'main_web',
      'web_location': WebLocation.articleDetail,
    };
    final (String wts, String wbiSign) = encWbi(params, account.wbiImgKey!, account.wbiSubKey!);
    final resp = await client.get(
      'https://api.bilibili.com/x/article/view',
      queryParameters: {
        ...params,
        'w_rid': wbiSign,
        'wts': wts,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(ArticleDetail.fromJson(resp.data['data']));
  }

  Future<Result<void>> like({
    required String articleId,
    required bool like,
  }) async {
    assert(articleId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/article/like',
      options: Options(headers: {'Content-Type': 'application/x-www-form-urlencoded'}),
      data: {
        'id': articleId,
        'type': like ? 1 : 2,
        'csrf': account.biliJct,
      },
    );

    // 当想要赞但本就已赞时返回 65006 已赞过
    if (resp.data['code'] == 65006 && like) {
      return Result.ok(null);
    }

    // 当想要取消赞但本就未赞时返回 65504 未点赞过
    if (resp.data['code'] == 65004 && !like) {
      return Result.ok(null);
    }

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  Future<Result<void>> favorite({
    required String articleId,
    required bool favorite,
  }) async {
    assert(articleId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      favorite ? 'https://api.bilibili.com/x/article/favorites/add' : 'https://api.bilibili.com/x/article/favorites/del',
      options: Options(headers: {'Content-Type': 'application/x-www-form-urlencoded'}),
      data: {
        'csrf': account.biliJct,
        'id': articleId,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 获取文集详细信息及文章列表，此接口可一次性返回全部文章
  Future<Result<ArticleCollection>> getCollectionDetail({required String collectionId}) async {
    assert(collectionId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final params = {
      'id': collectionId,
      'gaia_source': 'main_web',
      'web_location': WebLocation.articleDetail,
    };

    final (String wts, String wbiSign) = encWbi(params, account.wbiImgKey!, account.wbiSubKey!);
    final resp = await client.get(
      // 还有一个接口也能拿到文集详细信息，但相比这个接口少了作者和总字数信息
      // `https://api.bilibili.com/x/polymer/web-dynamic/v1/opus/detail/collection`
      'https://api.bilibili.com/x/article/list/articles',
      queryParameters: {
        ...params,
        'w_rid': wbiSign,
        'wts': wts,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(ArticleCollection.fromJson(resp.data['data']));
  }

  /// 获取指定用户的文章列表
  ///
  /// 使用 pn+offset+hasMore 分页，ps 固定 20
  ///
  /// 注意此接口返回的是 postId
  Future<Result<GetArticlesWithUserResponse>> getArticlesWithUser({
    required String userId,
    int pn = 1,
    String? offset,
  }) async {
    assert(userId.isNotEmpty);
    assert(pn > 0);
    assert(pn == 1 || offset != null);
    assert(offset == null || offset.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final params = {
      'host_mid': userId,
      'page': pn,
      'offset': offset ?? '',
      'type': 'article',
      'web_location': WebLocation.userSpace,
    };
    final (String wts, String wbiSign) = encWbi(params, account.wbiImgKey!, account.wbiSubKey!);

    final resp = await client.get(
      // 新接口每个 item 不算 jumpurl 就只给 4 个字段
      // 有些还没封面 cover
      // 要是充电视频还会没有 stat
      // 我真没招了
      'https://api.bilibili.com/x/polymer/web-dynamic/v1/opus/feed/space',
      // 旧接口，此接口无法返回充电专栏，只能用新接口
      // 'https://api.bilibili.com/x/space/wbi/article',
      queryParameters: {
        ...params,
        'w_rid': wbiSign,
        'wts': wts,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(
      GetArticlesWithUserResponse(
        list: (resp.data['data']['items'] as List).map((v) => GetArticlesWithUserItem.fromJson(v)).toList(),
        hasMore: resp.data['data']['has_more'] as bool,
        offset: resp.data['data']['offset'].isEmpty ? null : resp.data['data']['offset'] as String,
      ),
    );
  }

  /// 获取用户创建的全部文集
  Future<Result<List<GetUserAnthologysItem>>> getUserAnthologys({
    required String userId,
    GetUserAnthologysOrderEnum order = .updateTimeDesc,
  }) async {
    assert(userId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final params = {
      'mid': userId,
      'sort': order.value,
      'web_location': WebLocation.userSpace,
    };
    final (String wts, String wbiSign) = encWbi(params, account.wbiImgKey!, account.wbiSubKey!);
    final resp = await client.get(
      'https://api.bilibili.com/x/article/up/lists',
      queryParameters: {
        ...params,
        'w_rid': wbiSign,
        'wts': wts,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok((resp.data['data']['lists'] as List).map((v) => GetUserAnthologysItem.fromJson(v)).toList());
  }
}
