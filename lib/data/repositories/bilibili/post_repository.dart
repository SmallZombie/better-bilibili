import 'package:better_bilibili/data/services/bilibili/bili_post_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_post_list_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_posts_response.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/utils/result.dart';

class PostRepository {
  final BiliPostApiService _postApiService;

  PostRepository({
    required BiliPostApiService postApiService,
  }) : _postApiService = postApiService;

  Future<Result<dynamic>> getDetail({required String postId}) async {
    return _postApiService.getDetail(postId: postId);
  }

  Future<Result<void>> like({required String postId, required bool like}) async {
    return _postApiService.like(postId: postId, like: like);
  }

  Future<Result<void>> favorite({required String postId, required bool favorite}) async {
    return _postApiService.favorite(postId: postId, favorite: favorite);
  }

  Future<Result<GetPostListResponse>> getList({
    int pn = 1,
    String? offset,
    GetPostListTypeEnum type = GetPostListTypeEnum.all,
    String? userId,
  }) async {
    return _postApiService.getList(pn: pn, offset: offset, type: type, userId: userId);
  }

  Future<Result<List<User>>> getActiveUserList() async {
    return _postApiService.getActiveUserList();
  }

  Future<Result<GetUserPostsResponse>> getUserPosts({
    required String userId,
    String? offset,
    GetUserPostsTypeEnum type = .all,
  }) async {
    return _postApiService.getUserPosts(userId: userId, offset: offset, type: type);
  }

  Future<Result<void>> report({
    required String postId,
    required String userId,
    required int reasonId,
    String? reason,
  }) async {
    return _postApiService.report(
      postId: postId,
      userId: userId,
      reasonId: reasonId,
      reason: reason,
    );
  }
}
