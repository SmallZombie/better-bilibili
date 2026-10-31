import 'package:better_bilibili/data/repositories/bilibili/post_repository/post_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_post_list_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class PostFeedTileViewModel extends SafeChangeNotifier {
  final PostRepository _postRepository;

  Post post;

  PostFeedTileViewModel({
    required this.post,
    required PostRepository postRepository,
  }) : _postRepository = postRepository {
    like = Command0(_like);
  }

  late final Command0 like;

  Future<Result<void>> _like() async {
    final action = !post.isLiked;
    final postBak = post;
    post = post.copyWith(
      isLiked: action,
      stats: post.stats?.copyWith(like: post.stats?.like ?? 0 + (action ? 1 : -1)),
    );
    notifyListeners();

    final result = await _postRepository.like(postId: post.id, like: action);
    switch (result) {
      case Ok():
        return result;
      case Err():
        post = postBak;
        notifyListeners();
        return result;
    }
  }
}
