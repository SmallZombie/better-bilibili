import 'package:better_bilibili/data/services/bilibili/bili_comment_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_comment_list.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_comment_report_reasons_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/uploaded_image.dart';
import 'package:better_bilibili/domain/models/bilibili/bilibili.dart';
import 'package:better_bilibili/domain/models/bilibili/comment.dart';
import 'package:better_bilibili/utils/bili_util.dart';
import 'package:better_bilibili/utils/result.dart';

class CommentRepository {
  final BiliCommentApiService _commentApiService;

  CommentRepository({
    required BiliCommentApiService commentApiService,
  }) : _commentApiService = commentApiService;

  Future<Result<GetCommentListResponse>> getList({
    required String id,
    required BiliContentTypeEnum type,
    String? cursor,
    bool sort = false,
  }) async {
    return _commentApiService.getList(id: id, type: type, cursor: cursor, sort: sort);
  }

  Future<Result<Comment>> post({
    required String contextId,
    required BiliContentTypeEnum type,
    required String content,
    String? rootId,
    String? parentId,
    Map<String, String>? nicknameToUserId,
    List<UploadedImage>? images,
  }) async {
    return _commentApiService.post(
      id: contextId,
      type: type,
      content: content,
      rootId: rootId,
      parentId: parentId,
      nicknameToUserId: nicknameToUserId,
      images: images,
    );
  }

  Future<Result<List<MentionUser>>> getMentionList({
    String? keyword,
    required BiliContentTypeEnum type,
  }) {
    return _commentApiService.getMentionList(keyword: keyword, type: type);
  }

  Future<Result<List<StickerPack>>> getStickerList({String webLocation = WebLocation.videoDetail}) {
    return _commentApiService.getStickerList(webLocation: webLocation);
  }

  Future<Result<void>> delete({
    required String contextId,
    required BiliContentTypeEnum type,
    required String commentId,
  }) {
    return _commentApiService.delete(contextId: contextId, type: type, commentId: commentId);
  }

  Future<Result<void>> like({
    required String contextId,
    required BiliContentTypeEnum type,
    required String commentId,
    required bool like,
  }) {
    return _commentApiService.like(contextId: contextId, type: type, commentId: commentId, like: like);
  }

  Future<Result<void>> dislike({
    required String contextId,
    required BiliContentTypeEnum type,
    required String commentId,
    required bool dislike,
  }) {
    return _commentApiService.dislike(contextId: contextId, type: type, commentId: commentId, dislike: dislike);
  }

  Future<Result<List<Comment>>> getReplies({
    required String contextId,
    required BiliContentTypeEnum type,
    required String rootId,
    int pn = 1,
    int ps = 10,
  }) {
    return _commentApiService.getReplies(contextId: contextId, type: type, rootId: rootId, pn: pn, ps: ps);
  }

  Future<Result<List<ReportReasonItem>>> getReportReasons(BiliContentTypeEnum contentType, String contentId) {
    return _commentApiService.getReportReasons(contentType, contentId);
  }

  Future<Result<void>> report({
    required BiliContentTypeEnum contentType,
    required String contentId,
    required String commentId,
    required int reasonId,
    String? description,
  }) {
    return _commentApiService.report(
      contentType: contentType,
      contentId: contentId,
      commentId: commentId,
      reasonId: reasonId,
      description: description,
    );
  }
}
