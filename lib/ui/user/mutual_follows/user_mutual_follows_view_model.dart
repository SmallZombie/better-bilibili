import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_following_users.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class UserMutualFollowsViewModel extends SafeChangeNotifier {
  final String userId;
  final UserRepository userRepository;
  final AuthRepository authRepository;

  UserMutualFollowsViewModel({
    required this.userId,
    required this.userRepository,
    required this.authRepository,
  }) {
    loadData = Command0(_loadData)..execute();
  }

  late final Command0 loadData;

  final List<FollowingUser> _users = [];
  List<FollowingUser> get users => List.unmodifiable(_users);

  int _pn = 1;
  int get pn => _pn;
  void setPn(int newValue) {
    if (newValue == _pn) return;
    _pn = newValue;
    reload();
  }

  final int ps = 20;

  int _total = 0;
  int get total => _total;

  bool get hasMore => _pn * ps < _total;

  Future<Result<void>> _loadData() async {
    final result = await userRepository.getMutualFollowingUsers(userId: userId, pn: _pn, ps: ps);
    switch (result) {
      case Ok(:final value):
        _users.addAll(value.list);
        _total = value.total;
      case Err():
    }

    notifyListeners();
    return result;
  }

  void reload() {
    _users.clear();
    loadData.execute();
  }
}
