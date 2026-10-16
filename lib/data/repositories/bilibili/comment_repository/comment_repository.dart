import 'package:better_bilibili/data/services/bilibili/model/get_comment_list.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_comment_report_reasons_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/uploaded_image.dart';
import 'package:better_bilibili/domain/models/bilibili/bilibili.dart';
import 'package:better_bilibili/domain/models/bilibili/comment.dart';
import 'package:better_bilibili/utils/bili/bili_util.dart';
import 'package:better_bilibili/utils/result.dart';

abstract interface class CommentRepository {
  Future<Result<GetCommentListResponse>> getList({
    required String id,
    required BiliContentTypeEnum type,
    String? cursor,
    bool sort = false,
  });

  Future<Result<Comment>> post({
    required String contextId,
    required BiliContentTypeEnum type,
    required String content,
    String? rootId,
    String? parentId,
    Map<String, String>? nicknameToUserId,
    List<UploadedImage>? images,
  });

  Future<Result<List<MentionUser>>> getMentionList({
    String? keyword,
    required BiliContentTypeEnum type,
  });

  Future<Result<List<StickerPack>>> getStickerList({
    String webLocation = WebLocation.videoDetail,
  });

  Future<Result<void>> delete({
    required String contextId,
    required BiliContentTypeEnum type,
    required String commentId,
  });

  Future<Result<void>> like({
    required String contextId,
    required BiliContentTypeEnum type,
    required String commentId,
    required bool like,
  });

  Future<Result<void>> dislike({
    required String contextId,
    required BiliContentTypeEnum type,
    required String commentId,
    required bool dislike,
  });

  Future<Result<List<Comment>>> getReplies({
    required String contextId,
    required BiliContentTypeEnum type,
    required String rootId,
    int pn = 1,
    int ps = 10,
  });

  Future<Result<List<ReportReasonItem>>> getReportReasons({
    required BiliContentTypeEnum contentType,
    required String contentId,
  });

  Future<Result<void>> report({
    required BiliContentTypeEnum contentType,
    required String contentId,
    required String commentId,
    required int reasonId,
    String? description,
  });
}
