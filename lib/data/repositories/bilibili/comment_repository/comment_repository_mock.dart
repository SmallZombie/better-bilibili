import 'package:better_bilibili/data/repositories/bilibili/comment_repository/comment_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_comment_list.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_comment_report_reasons_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/uploaded_image.dart';
import 'package:better_bilibili/domain/models/bilibili/bilibili.dart';
import 'package:better_bilibili/domain/models/bilibili/comment.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/bili/bili_util.dart';

class CommentRepositoryMock implements CommentRepository {
  @override
  Future<Result<void>> delete({required String contextId, required BiliContentTypeEnum type, required String commentId}) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> dislike({required String contextId, required BiliContentTypeEnum type, required String commentId, required bool dislike}) {
    // TODO: implement dislike
    throw UnimplementedError();
  }

  @override
  Future<Result<GetCommentListResponse>> getList({required String id, required BiliContentTypeEnum type, String? cursor, bool sort = false}) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future<Result<List<MentionUser>>> getMentionList({String? keyword, required BiliContentTypeEnum type}) {
    // TODO: implement getMentionList
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Comment>>> getReplies({required String contextId, required BiliContentTypeEnum type, required String rootId, int pn = 1, int ps = 10}) {
    // TODO: implement getReplies
    throw UnimplementedError();
  }

  @override
  Future<Result<List<ReportReasonItem>>> getReportReasons({required BiliContentTypeEnum contentType, required String contentId}) {
    // TODO: implement getReportReasons
    throw UnimplementedError();
  }

  @override
  Future<Result<List<StickerPack>>> getStickerList({String webLocation = WebLocation.videoDetail}) {
    // TODO: implement getStickerList
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> like({required String contextId, required BiliContentTypeEnum type, required String commentId, required bool like}) {
    // TODO: implement like
    throw UnimplementedError();
  }

  @override
  Future<Result<Comment>> post({required String contextId, required BiliContentTypeEnum type, required String content, String? rootId, String? parentId, Map<String, String>? nicknameToUserId, List<UploadedImage>? images}) {
    // TODO: implement post
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> report({required BiliContentTypeEnum contentType, required String contentId, required String commentId, required int reasonId, String? description}) {
    // TODO: implement report
    throw UnimplementedError();
  }
}
