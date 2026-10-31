import 'package:better_bilibili/data/repositories/bilibili/comment_repository/comment_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/common_repository/common_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_comment_list.dart';
import 'package:better_bilibili/data/services/bilibili/model/uploaded_image.dart';
import 'package:better_bilibili/domain/models/bilibili/bilibili.dart';
import 'package:better_bilibili/domain/models/bilibili/comment.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class CommentPanelViewModel extends SafeChangeNotifier {
  final CommentRepository commentRepository;
  final CommonRepository commonRepository;

  final BiliContentTypeEnum type;
  final String id;

  CommentPanelViewModel({
    required this.commentRepository,
    required this.commonRepository,
    required this.type,
    required this.id,
  }) {
    loadData = Command0(
      _loadData,
      onSuccess: _loadDataSuccess,
      onCancel: () {},
    )..execute();
    post = Command1(_post);
    deleteComment = Command1(_deleteComment);
    loadMentionUserList = Command1(
      _loadMentionUserList,
      onSuccess: _loadMentionedUserListSuccess,
      onCancel: () {},
    );
    loadStickers = Command0(_loadStickers);
  }

  late final Command0<GetCommentListResponse> loadData;

  String? _nextCursor;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  final List<Comment> _comments = [];
  List<Comment> get comments => _comments;

  Future<Result<GetCommentListResponse>> _loadData() async {
    final result = await commentRepository.getList(
      id: id,
      type: type,
      cursor: _nextCursor,
    );
    return result;
  }

  void _loadDataSuccess(GetCommentListResponse result) {
    _comments.addAll(result.list);
    if (result.nextCursor == null) {
      _hasMore = false;
    } else {
      _nextCursor = result.nextCursor;
    }
    notifyListeners();
  }

  void reload() {
    _comments.clear();
    _nextCursor = null;
    _hasMore = true;
    loadData.cancel();
    notifyListeners();
    loadData.execute();
  }

  final List<UploadImage> _images = [];
  List<UploadImage> get images => List.unmodifiable(_images);

  Future<void> addAndUploadImage(UploadImage image) async {
    _images.add(image);
    notifyListeners();
    await uploadImage(image);
  }

  Future<void> uploadImage(UploadImage image) async {
    assert(image.status == .waiting || image.status == .failed);

    final index = _images.indexOf(image);
    image = image.copyWith(status: .uploading);
    _images[index] = image;
    notifyListeners();

    final result = await commonRepository.uploadImageForDynamic(image.localPath);
    switch (result) {
      case Ok(:final value):
        _images[_images.indexOf(image)] = image.copyWith(status: .success, result: value);
      case Err():
        _images[_images.indexOf(image)] = image.copyWith(status: .failed);
    }
    notifyListeners();
  }

  void removeImage(UploadImage image) {
    _images.remove(image);
    notifyListeners();
  }

  void clearImage() {
    _images.clear();
    notifyListeners();
  }

  late final Command1<void, PostRequest> post;

  Comment? _replyTarget;
  Comment? get replyTarget => _replyTarget;
  void setReplyTarget(Comment? comment) {
    _replyTarget = comment;
    notifyListeners();
  }

  Future<Result<Comment>> _post(PostRequest req) async {
    final result = await commentRepository.post(
      type: type,
      contextId: _replyTarget?.contextId ?? id,
      rootId: _replyTarget?.id,
      parentId: _replyTarget?.id,
      nicknameToUserId: req.nicknameToUserId,
      content: req.content,
      images: _images.map((image) => image.result!).toList(),
    );

    switch (result) {
      case Ok(:final value):
        if (_replyTarget != null) {
          final root = _replyTarget!.rootId == null ? _replyTarget! : _comments.firstWhere((comment) => comment.id == _replyTarget!.rootId);
          final updatedReplies = [value, ...root.replies];
          _comments[_comments.indexOf(root)] = root.copyWith(
            replies: updatedReplies,
            replyCount: root.replyCount + 1,
          );
        } else {
          _comments.insert(0, value);
        }
      case Err():
    }

    notifyListeners();
    return result;
  }

  late final Command1<void, Comment> deleteComment;

  Future<Result<void>> _deleteComment(Comment comment) async {
    final result = await commentRepository.delete(
      contextId: id,
      type: type,
      commentId: comment.id,
    );
    switch (result) {
      case Ok():
        try {
          final root = _comments.firstWhere((v) => v.id == comment.rootId);
          final updatedReplies = [...root.replies]..removeWhere((v) => v.id == comment.id);
          _comments[_comments.indexOf(root)] = root.copyWith(
            replies: updatedReplies,
            replyCount: updatedReplies.length,
          );
        } catch (_) {
          _comments.removeWhere((v) => v.id == comment.id);
        }
      case Err():
    }

    return result;
  }

  late final Command1<List<MentionUser>, String?> loadMentionUserList;

  final List<MentionUser> _mentionUserList = [];
  List<MentionUser> get mentionUserList => List.unmodifiable(_mentionUserList);

  Future<Result<List<MentionUser>>> _loadMentionUserList(String? keyword) async {
    final result = commentRepository.getMentionList(
      type: type,
      keyword: keyword,
    );
    return result;
  }

  void _loadMentionedUserListSuccess(List<MentionUser> result) {
    _mentionUserList.addAll(result);
    notifyListeners();
  }

  void reloadMentionUserList(String? keyword) {
    _mentionUserList.clear();
    loadMentionUserList.cancel();
    loadMentionUserList.execute(keyword);
  }

  late final Command0 loadStickers;

  final List<StickerPack> _stickers = [];
  List<StickerPack> get stickers => List.unmodifiable(_stickers);

  Future<Result<void>> _loadStickers() async {
    final result = await commentRepository.getStickerList();
    switch (result) {
      case Ok(:final value):
        _stickers.addAll(value);
      case Err():
    }

    notifyListeners();
    return result;
  }

  int _selectedStickerPackIndex = 0;
  int get selectedStickerPackIndex => _selectedStickerPackIndex;
  void setSelectedStickerPackIndex(int newIndex) {
    if (newIndex == _selectedStickerPackIndex) return;
    _selectedStickerPackIndex = newIndex;
    notifyListeners();
  }
}

enum CommentImageStatus {
  waiting,
  uploading,
  success,
  failed,
}

class UploadImage {
  final String localPath;
  final String localName;
  final CommentImageStatus status;
  final UploadedImage? result;
  final String? errorMessage;

  const UploadImage({
    required this.localPath,
    required this.localName,
    this.status = CommentImageStatus.waiting,
    this.result,
    this.errorMessage,
  });

  UploadImage copyWith({
    CommentImageStatus? status,
    UploadedImage? result,
    String? errorMessage,
  }) {
    return UploadImage(
      localPath: localPath,
      localName: localName,
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PostRequest {
  final String content;
  final Map<String, String> nicknameToUserId;

  PostRequest({
    required this.content,
    required this.nicknameToUserId,
  });
}
