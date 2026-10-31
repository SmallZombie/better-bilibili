import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_following_users.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class UserFollowingsViewModel extends SafeChangeNotifier {
  final UserRepository userRepository;
  final AuthRepository authRepository;

  final String userId;

  UserFollowingsViewModel({
    required this.userRepository,
    required this.authRepository,
    required this.userId,
  }) {
    loadData = Command0(_loadData)..execute();
  }

  late final Command0<void> loadData;

  int _pn = 1;
  int get pn => _pn;
  void setPn(int pn) {
    _pn = pn;
    reload();
  }

  final List<FollowingUser> _followings = [];
  List<FollowingUser> get followings => List.unmodifiable(_followings);

  final List<FollowingUser> _mutualFollows = [];
  List<FollowingUser> get mutualFollows => List.unmodifiable(_mutualFollows);

  int _total = 0;
  int get total => _total;

  Future<Result<void>> _loadData() async {
    final followingResult = await userRepository.getFollowingUsers(userId: userId, pn: _pn);
    switch (followingResult) {
      case Ok(:final value):
        _followings.addAll(value.list);
        _total = value.total;
      case Err():
    }

    if (_pn == 1) {
      final mutualFollowResult = await userRepository.getMutualFollowingUsers(userId: userId, pn: _pn);
      switch (mutualFollowResult) {
        case Ok(:final value):
          _mutualFollows.addAll(value.list);
        case Err():
      }
    }

    notifyListeners();
    return followingResult;
  }

  late final Command0<void> loadGroups;

  int _selectedGroupIndex = 0;
  int get selectedGroupIndex => _selectedGroupIndex;
  void setSelectedGroupIndex(int index) {
    if (index == _selectedGroupIndex) return;
    _selectedGroupIndex = index;
    _pn = 1;
    notifyListeners();
    reload();
  }

  void reload() {
    _followings.clear();
    _mutualFollows.clear();

    notifyListeners();
    loadData.execute();
  }
}
