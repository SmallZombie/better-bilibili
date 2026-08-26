import 'package:better_bilibili/domain/models/bilibili/comment.dart';

class GetCommentListResponse {
  final String? nextCursor;
  final List<Comment> list;

  GetCommentListResponse({
    this.nextCursor,
    required this.list,
  });
}
