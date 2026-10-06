import 'package:better_bilibili/data/repositories/bilibili/post_repository/post_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_post_list_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_posts_response.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/utils/result.dart';

class PostRepositoryMock implements PostRepository {
  @override
  Future<Result<void>> favorite({required String postId, required bool favorite}) {
    // TODO: implement favorite
    throw UnimplementedError();
  }

  @override
  Future<Result<List<User>>> getActiveUserList() {
    // TODO: implement getActiveUserList
    throw UnimplementedError();
  }

  @override
  Future<Result<dynamic>> getDetail({required String postId}) {
    // TODO: implement getDetail
    throw UnimplementedError();
  }

  @override
  Future<Result<GetPostListResponse>> getList({
    int pn = 1,
    String? offset,
    GetPostListTypeEnum type = GetPostListTypeEnum.all,
    String? userId,
  }) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future<Result<GetUserPostsResponse>> getUserPosts({required String userId, String? offset, GetUserPostsTypeEnum type = .all}) {
    // TODO: implement getUserPosts
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> like({required String postId, required bool like}) {
    // TODO: implement like
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> report({required String postId, required String userId, required int reasonId, String? reason}) {
    // TODO: implement report
    throw UnimplementedError();
  }
}
