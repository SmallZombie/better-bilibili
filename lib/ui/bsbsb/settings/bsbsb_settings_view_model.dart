import 'package:better_bilibili/config/bsbsb_config.dart';
import 'package:better_bilibili/data/model/bsbsb/user_info.dart';
import 'package:better_bilibili/data/repositories/bsbsb/bsbsb_repository.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class BsbsbSettingsViewModel extends SafeChangeNotifier {
  final BsbsbConfig config;
  final BsbsbRepository bsbsbRepository;

  BsbsbSettingsViewModel({required this.config, required this.bsbsbRepository}) {
    loadData.execute();
  }

  late final Command0 loadData = Command0(_loadData);

  UserInfo? userInfo;

  Future<Result<void>> _loadData() async {
    final result = await bsbsbRepository.getUserInfo();
    switch (result) {
      case Ok(:final value):
        userInfo = value;
      case Error():
    }

    notifyListeners();
    return result;
  }

  late final Command1 modifyUsername = Command1((username) => _modifyUsername(username));

  Future<Result<void>> _modifyUsername(String username) async {
    final result = await bsbsbRepository.modifyUsername(username);
    switch (result) {
      case Ok _:
        userInfo = userInfo?.copyWith(userName: username);
      case Error _:
    }

    notifyListeners();
    return result;
  }

  late final Command0 getMyLeaderboardRank = Command0(_getMyLeaderboardRank);

  int _myRank = -1;
  int get myRank => _myRank;

  Future<Result<void>> _getMyLeaderboardRank() async {
    assert(userInfo != null);

    final result = await bsbsbRepository.getMyLeaderboardRank(userInfo!.userName, userInfo!.minutesSaved);
    switch (result) {
      case Ok(:final value):
        _myRank = value;
      case Error _:
    }

    notifyListeners();
    return result;
  }
}
