import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_fans_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class UserFansViewModel extends SafeChangeNotifier {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  final String userId;

  UserFansViewModel({
    required UserRepository userRepository,
    required AuthRepository authRepository,
    required this.userId,
  }) : _userRepository = userRepository,
       _authRepository = authRepository {
    loadData = Command0(_loadData)..execute();
    deleteFan = Command1((userId) => _deleteFan(userId));
  }

  late final Command0 loadData;

  int _pn = 1;
  int get pn => _pn;
  void setPn(int pn) {
    _pn = pn;
    reload();
  }

  int _total = 0;
  int get total => _total;

  final List<FanUser> _fans = [];
  late final List<FanUser> fans = List.unmodifiable(_fans);

  int _fansVersion = 0;
  int get fansVersion => _fansVersion;

  bool _isCurrentUser = false;
  bool get isCurrentUser => _isCurrentUser;

  Future<Result<void>> _loadData() async {
    final result = await _userRepository.getFans(userId: userId, pn: _pn);
    switch (result) {
      case Ok(:final value):
        _fans.addAll(value.list);
        _fansVersion++;
        _total = value.total;
        _isCurrentUser = userId == (await _authRepository.getAccount()).userId;
      case Error():
    }
    return result;
  }

  void reload() {
    _fans.clear();
    _fansVersion++;
    loadData.execute();
  }

  late final Command1<void, String> deleteFan;

  Future<Result<void>> _deleteFan(String userId) async {
    final result = await _userRepository.deleteFans(userId: userId);
    switch (result) {
      case Ok():
        _fans.removeWhere((fan) => fan.id == userId);
        _fansVersion++;
        _total--;
      case Error():
    }

    notifyListeners();
    return result;
  }
}
