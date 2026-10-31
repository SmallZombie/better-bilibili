import 'package:better_bilibili/config/account_config.dart';
import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/post_repository/post_repository.dart';
import 'package:better_bilibili/data/services/bilibili/bili_post_web_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_post_detail_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_post_list_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_posts_response.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/utils/result.dart';

class PostRepositoryGuest implements PostRepository {
  final AuthRepository authRepository;
  late final BiliPostWebApiService postApiService = BiliPostWebApiService(
    getClient: () => authRepository.getClient(type: .web, userId: kGuestUserId),
    getAccount: () => authRepository.getAccount('0'),
  );

  PostRepositoryGuest({required this.authRepository});

  @override
  Future<Result<PostDetail>> getDetail(String postId) {
    return postApiService.getDetail(postId);
  }

  @override
  Future<Result<void>> like({required String postId, required bool like}) {
    return postApiService.like(postId: postId, like: like);
  }

  @override
  Future<Result<void>> favorite({required String postId, required bool favorite}) {
    return postApiService.favorite(postId: postId, favorite: favorite);
  }

  @override
  Future<Result<GetPostListResponse>> getList({
    int pn = 1,
    String? offset,
    GetPostListTypeEnum type = GetPostListTypeEnum.all,
    String? userId,
  }) {
    return postApiService.getList(pn: pn, offset: offset, type: type, userId: userId);
  }

  @override
  Future<Result<List<User>>> getActiveUserList() {
    return postApiService.getActiveUserList();
  }

  @override
  Future<Result<GetUserPostsResponse>> getUserPosts({
    required String userId,
    String? offset,
    GetUserPostsTypeEnum type = .all,
  }) {
    return postApiService.getUserPosts(userId: userId, offset: offset, type: type);
  }

  @override
  Future<Result<void>> report({
    required String postId,
    required String userId,
    required int reasonId,
    String? reason,
  }) {
    return postApiService.report(
      postId: postId,
      userId: userId,
      reasonId: reasonId,
      reason: reason,
    );
  }
}
