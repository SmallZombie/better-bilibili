import 'package:better_bilibili/data/repositories/bilibili/post_repository/post_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_post_list_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_posts_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

const _typeValues = [GetUserPostsTypeEnum.all, GetUserPostsTypeEnum.video];

class UserDetailPostViewModel extends SafeChangeNotifier {
  final PostRepository _postRepository;

  final String userId;

  UserDetailPostViewModel({
    required PostRepository postRepository,
    required this.userId,
  }) : _postRepository = postRepository {
    loadData = CancellableCommand0(
      _loadData,
      onSuccess: (resp) => loadDataSuccess(resp),
      onCancel: () {},
    )..execute();
  }

  int _selectedTypeIndex = 0;
  int get selectedTypeIndex => _selectedTypeIndex;
  void setSelectedTypeIndex(int newIndex) {
    if (newIndex == _selectedTypeIndex) return;

    _selectedTypeIndex = newIndex;
    notifyListeners();

    reload();
  }

  late final CancellableCommand0 loadData;

  String? _offset;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  final List<Post> _posts = [];
  List<Post> get posts => List.unmodifiable(_posts);

  Future<Result<void>> _loadData() async {
    final result = await _postRepository.getUserPosts(
      userId: userId,
      type: _typeValues[_selectedTypeIndex],
      offset: _offset,
    );
    return result;
  }

  void loadDataSuccess(GetUserPostsResponse resp) {
    _posts.addAll(resp.list);
    _offset = resp.nextOffset;
    _hasMore = resp.hasMore;
    notifyListeners();
  }

  void reload() {
    _posts.clear();
    _offset = null;
    notifyListeners();

    loadData.cancel();
    loadData.execute();
  }
}
