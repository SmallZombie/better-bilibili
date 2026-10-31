import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_fans_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class UserFansViewModel extends SafeChangeNotifier {
  final UserRepository userRepository;
  final AuthRepository authRepository;

  final String userId;

  UserFansViewModel({
    required this.userRepository,
    required this.authRepository,
    required this.userId,
  }) {
    loadData = Command0(_loadData)..execute();
    deleteFan = Command1(_deleteFan);
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
  List<FanUser> get fans => List.unmodifiable(_fans);

  int _fansVersion = 0;
  int get fansVersion => _fansVersion;

  bool _isCurrentUser = false;
  bool get isCurrentUser => _isCurrentUser;

  Future<Result<void>> _loadData() async {
    final result = await userRepository.getFans(userId: userId, pn: _pn);
    switch (result) {
      case Ok(:final value):
        _fans.addAll(value.list);
        _fansVersion++;
        _total = value.total;
        _isCurrentUser = userId == (await authRepository.getAccount()).userId;
      case Err():
    }

    notifyListeners();
    return result;
  }

  void reload() {
    _fans.clear();
    _fansVersion++;
    loadData.execute();
  }

  late final Command1<void, String> deleteFan;

  Future<Result<void>> _deleteFan(String userId) async {
    final result = await userRepository.deleteFans(userId);
    switch (result) {
      case Ok():
        _fans.removeWhere((fan) => fan.id == userId);
        _fansVersion++;
        _total--;
      case Err():
    }

    notifyListeners();
    return result;
  }
}
