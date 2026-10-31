import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/comment_repository/comment_repository.dart';
import 'package:better_bilibili/data/services/bilibili/bili_comment_web_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_comment_list.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_comment_report_reasons_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/uploaded_image.dart';
import 'package:better_bilibili/domain/models/bilibili/bilibili.dart';
import 'package:better_bilibili/domain/models/bilibili/comment.dart';
import 'package:better_bilibili/utils/bilibili/bili_util.dart';
import 'package:better_bilibili/utils/result.dart';

class CommentRepositoryLogin implements CommentRepository {
  final AuthRepository authRepository;
  late final BiliCommentWebApiService commentApiService = BiliCommentWebApiService(
    getClient: () => authRepository.getClient(type: .web),
    getAccount: authRepository.getAccount,
  );

  CommentRepositoryLogin({required this.authRepository});

  @override
  Future<Result<GetCommentListResponse>> getList({
    required String id,
    required BiliContentTypeEnum type,
    String? cursor,
    bool sort = false,
  }) {
    return commentApiService.getList(id: id, type: type, cursor: cursor, sort: sort);
  }

  @override
  Future<Result<Comment>> post({
    required String contextId,
    required BiliContentTypeEnum type,
    required String content,
    String? rootId,
    String? parentId,
    Map<String, String>? nicknameToUserId,
    List<UploadedImage>? images,
  }) {
    return commentApiService.post(
      id: contextId,
      type: type,
      content: content,
      rootId: rootId,
      parentId: parentId,
      nicknameToUserId: nicknameToUserId,
      images: images,
    );
  }

  @override
  Future<Result<List<MentionUser>>> getMentionList({
    String? keyword,
    required BiliContentTypeEnum type,
  }) {
    return commentApiService.getMentionList(keyword: keyword, type: type);
  }

  @override
  Future<Result<List<StickerPack>>> getStickerList({String webLocation = WebLocation.videoDetail}) {
    return commentApiService.getStickerList(webLocation: webLocation);
  }

  @override
  Future<Result<void>> delete({
    required String contextId,
    required BiliContentTypeEnum type,
    required String commentId,
  }) {
    return commentApiService.delete(contextId: contextId, type: type, commentId: commentId);
  }

  @override
  Future<Result<void>> like({
    required String contextId,
    required BiliContentTypeEnum type,
    required String commentId,
    required bool like,
  }) {
    return commentApiService.like(contextId: contextId, type: type, commentId: commentId, like: like);
  }

  @override
  Future<Result<void>> dislike({
    required String contextId,
    required BiliContentTypeEnum type,
    required String commentId,
    required bool dislike,
  }) {
    return commentApiService.dislike(contextId: contextId, type: type, commentId: commentId, dislike: dislike);
  }

  @override
  Future<Result<List<Comment>>> getReplies({
    required String contextId,
    required BiliContentTypeEnum type,
    required String rootId,
    int pn = 1,
    int ps = 10,
  }) {
    return commentApiService.getReplies(contextId: contextId, type: type, rootId: rootId, pn: pn, ps: ps);
  }

  @override
  Future<Result<List<ReportReasonItem>>> getReportReasons({required BiliContentTypeEnum contentType, required String contentId}) {
    return commentApiService.getReportReasons(contentType: contentType, contentId: contentId);
  }

  @override
  Future<Result<void>> report({
    required BiliContentTypeEnum contentType,
    required String contentId,
    required String commentId,
    required int reasonId,
    String? description,
  }) {
    return commentApiService.report(
      contentType: contentType,
      contentId: contentId,
      commentId: commentId,
      reasonId: reasonId,
      description: description,
    );
  }
}
