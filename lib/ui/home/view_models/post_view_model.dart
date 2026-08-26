import 'package:better_bilibili/data/repositories/bilibili/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/post_repository.dart';
import 'package:better_bilibili/data/services/bilibili/bili_background_service.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_post_list_response.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class PostViewModel extends SafeChangeNotifier {
  final PostRepository _postRepository;
  final BiliBackgroundService _biliBackgroundService;
  final AuthRepository _authRepository;

  PostViewModel({
    required PostRepository postRepository,
    required BiliBackgroundService biliBackgroundService,
    required AuthRepository authRepository,
  }) : _postRepository = postRepository,
       _authRepository = authRepository,
       _biliBackgroundService = biliBackgroundService {
    getPosts = CancellableCommand0(
      _getPosts,
      onSuccess: (result) => _getPostsSuccess(result),
      onCancel: () {},
    )..execute();
    getUsers = Command0(_getUsers)..execute();

    _authRepository.addListener(_onAuthRepositoryChanged);
  }

  @override
  void dispose() {
    _authRepository.removeListener(_onAuthRepositoryChanged);

    super.dispose();
  }

  late final CancellableCommand0 getPosts;

  int _pn = 1;
  String? _offset;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  final List<Post> _posts = [];
  List<Post> get posts => List.unmodifiable(_posts);

  int _selectedTypeIndex = 0;
  int get selectedTypeIndex => _selectedTypeIndex;
  void setSelectedTypeIndex(int index) {
    if (_selectedTypeIndex == index) return;
    _selectedTypeIndex = index;
    _selectedUserIndex = -1;

    reload();
  }

  Future<Result<void>> _getPosts() async {
    final result = await _postRepository.getList(
      pn: _pn,
      offset: _offset,
      type: switch (_selectedTypeIndex) {
        1 => GetPostListTypeEnum.video,
        2 => GetPostListTypeEnum.article,
        _ => GetPostListTypeEnum.all,
      },
      userId: _selectedUserIndex == -1 ? null : _users[_selectedUserIndex].id,
    );

    return result;
  }

  void _getPostsSuccess(GetPostListResponse result) {
    _posts.addAll(result.list);
    _pn++;
    _offset = result.offset;
    _hasMore = result.hasMore;

    _biliBackgroundService.clearUnreadPostCount();
    notifyListeners();
  }

  late final Command0 getUsers;

  int _selectedUserIndex = -1;
  int get selectedUserIndex => _selectedUserIndex;
  void setSelectedUserIndex(int index) {
    if (_selectedUserIndex == index) return;
    _selectedUserIndex = index;
    _selectedTypeIndex = -1;

    reload();
  }

  final List<User> _users = [];
  List<User> get users => List.unmodifiable(_users);

  Future<Result<void>> _getUsers() async {
    final result = await _postRepository.getActiveUserList();
    switch (result) {
      case Ok(:final value):
        _users.addAll(value);
      case Error():
    }

    notifyListeners();
    return result;
  }

  void reload() {
    _posts.clear();
    _pn = 1;
    _offset = null;
    _hasMore = true;
    notifyListeners();

    getPosts.cancel();
    getPosts.execute();
  }

  void _onAuthRepositoryChanged() {
    _posts.clear();
    _pn = 1;
    _offset = null;
    _hasMore = true;
    _biliBackgroundService.clearUnreadPostCount();
    _selectedTypeIndex = 0;

    _users.clear();
    _selectedUserIndex = -1;
    notifyListeners();

    getPosts.cancel();
    getPosts.execute();
    getUsers.execute();
    notifyListeners();
  }
}
