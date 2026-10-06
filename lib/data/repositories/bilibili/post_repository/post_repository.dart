import 'package:better_bilibili/data/services/bilibili/model/get_post_list_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_posts_response.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/utils/result.dart';

abstract interface class PostRepository {
  Future<Result<dynamic>> getDetail({required String postId});

  Future<Result<void>> like({required String postId, required bool like});

  Future<Result<void>> favorite({required String postId, required bool favorite});

  Future<Result<GetPostListResponse>> getList({
    int pn = 1,
    String? offset,
    GetPostListTypeEnum type = GetPostListTypeEnum.all,
    String? userId,
  });

  Future<Result<List<User>>> getActiveUserList();

  Future<Result<GetUserPostsResponse>> getUserPosts({
    required String userId,
    String? offset,
    GetUserPostsTypeEnum type = .all,
  });

  Future<Result<void>> report({
    required String postId,
    required String userId,
    required int reasonId,
    String? reason,
  });
}
