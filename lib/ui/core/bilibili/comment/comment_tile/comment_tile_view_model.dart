import 'package:better_bilibili/data/services/bilibili/bili_comment_api_service.dart';
import 'package:better_bilibili/domain/models/bilibili/comment.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class CommentTileViewModel extends SafeChangeNotifier {
  final BiliCommentApiService _commentApiService;

  Comment comment;

  CommentTileViewModel({
    required BiliCommentApiService commentApiService,
    required this.comment,
  }) : _commentApiService = commentApiService {
    getReplies = Command0(_getReplies);
    like = Command0(_like);
    dislike = Command0(_dislike);
  }

  late final Command0<List<Comment>> getReplies;

  int _pn = 1;
  int get pn => _pn;

  Future<Result<List<Comment>>> _getReplies() async {
    final result = await _commentApiService.getReplies(
      pn: _pn,
      contextId: comment.contextId,
      type: comment.type,
      rootId: comment.id,
    );

    switch (result) {
      case Ok(:final value):
        comment.replies.addAll(value);
        _pn++;
      case Error():
    }

    return result;
  }

  late final Command0<void> like;

  Future<Result<void>> _like() async {
    final action = !comment.isLiked;
    final result = await _commentApiService.like(
      contextId: comment.contextId,
      type: comment.type,
      commentId: comment.id,
      like: action,
    );

    switch (result) {
      case Ok():
        comment = comment.copyWith(
          isLiked: action,
          likeCount: comment.likeCount + (action ? 1 : -1),
          isDisliked: action ? false : comment.isDisliked,
        );
      case Error():
    }

    return result;
  }

  late final Command0<void> dislike;

  Future<Result<void>> _dislike() async {
    final action = !comment.isDisliked;
    final result = await _commentApiService.dislike(
      contextId: comment.contextId,
      type: comment.type,
      commentId: comment.id,
      dislike: action,
    );

    switch (result) {
      case Ok():
        comment = comment.copyWith(
          isDisliked: action,
          isLiked: action ? false : comment.isLiked,
          likeCount: action && comment.isLiked ? comment.likeCount - 1 : comment.likeCount,
        );
      case Error():
    }

    return result;
  }
}
