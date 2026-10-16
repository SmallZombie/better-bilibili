import 'package:better_bilibili/data/repositories/bilibili/post_repository/post_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_post_detail_response.dart';
import 'package:better_bilibili/domain/models/bilibili/bilibili.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';
import 'package:logger/logger.dart';

class PostDetailViewModel extends SafeChangeNotifier {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'PostDetailViewModel'));

  final PostRepository _postRepository;
  final UserRepository _userRepository;

  String postId;
  String? cover;

  PostDetailViewModel({
    required PostRepository postRepository,
    required UserRepository userRepository,
    required this.postId,
    String? initCover,
  }) : _postRepository = postRepository,
       _userRepository = userRepository,
       cover = initCover {
    loadData = CancellableCommand0(
      _loadData,
      onSuccess: (result) => _loadDataSuccess(result),
      onCancel: () {},
    )..execute();
    like = Command0(_like);
    favorite = Command0(_favorite);
  }

  late final CancellableCommand0 loadData;

  PostDetail? _postDetail;
  PostDetail? get postDetail => _postDetail;
  PostInteraction? get interaction => _postDetail?.interaction;

  String? _collectionId;
  String? get collectionId => _collectionId;

  Future<Result<void>> _loadData() async {
    final result = await _postRepository.getDetail( postId);
    return result;
  }

  void _loadDataSuccess(PostDetail result) {
    _postDetail = result;
    cover = result.cover;
    _collectionId = result.collectionId;
    _reportHistory();
    notifyListeners();
  }

  void switchPost(String newPostId, String newCover) {
    if (postId == newPostId) return;
    _log.i('switchPost newPostId: $newPostId, cover: $newCover');

    postId = newPostId;
    cover = newCover;
    _postDetail = null;
    notifyListeners();

    loadData.cancel();
    loadData.execute();
  }

  late final Command0 like;

  Future<Result<void>> _like() async {
    final action = !(interaction?.hasLiked ?? false);
    final postDetailbak = _postDetail;

    _postDetail = _postDetail?.copyWith(
      interaction: interaction?.copyWith(hasLiked: action),
      stats: _postDetail?.stats.copyWith(like: (_postDetail?.stats.like ?? 0) + (action ? 1 : -1)),
    );
    notifyListeners();

    final result = await _postRepository.like(postId: postId, like: action);
    switch (result) {
      case Ok():
        return result;
      case Error():
        _postDetail = postDetailbak;
        notifyListeners();
    }

    return result;
  }

  late final Command0 favorite;

  Future<Result<void>> _favorite() async {
    final action = !(interaction?.hasFavorited ?? false);
    final postDetailbak = _postDetail;

    _postDetail = _postDetail?.copyWith(
      interaction: interaction?.copyWith(hasFavorited: action),
      stats: _postDetail?.stats.copyWith(favorite: (_postDetail?.stats.favorite ?? 0) + (action ? 1 : -1)),
    );
    notifyListeners();

    final result = await _postRepository.favorite(postId: postId, favorite: action);
    switch (result) {
      case Ok():
        return result;
      case Error():
        _postDetail = postDetailbak;
        notifyListeners();
    }

    return result;
  }

  int _currentContentsIndex = 0;
  int get currentContentsIndex => _currentContentsIndex;
  void setCurrentContentsIndex(int index) {
    if (index == _currentContentsIndex) return;
    _currentContentsIndex = index;
    notifyListeners();
  }

  void _reportHistory() {
    if (_postDetail?.commentId == null) {
      _log.w('postDetail.commentId is null, skip report history');
      return;
    }
    if (_postDetail!.commentType != BiliContentTypeEnum.article) {
      return;
    }

    _userRepository.reportArticleHistory( _postDetail!.commentId);
  }
}
