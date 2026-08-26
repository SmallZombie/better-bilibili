import 'package:better_bilibili/data/repositories/bilibili/user_repository.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class FollowTextButtonViewModel extends SafeChangeNotifier {
  final UserRepository _userRepository;

  String userId;
  bool followed;

  FollowTextButtonViewModel({
    required UserRepository userRepository,
    required this.userId,
    required bool initState,
  }) : _userRepository = userRepository,
       followed = initState {
    follow = Command0(_follow);
  }

  late final Command0<void> follow;

  Future<Result<void>> _follow() async {
    final action = !followed;
    followed = action;
    notifyListeners();

    final result = await _userRepository.followUser(userId: userId, follow: action);
    switch (result) {
      case Ok():
        return result;
      case Error():
        followed = !action;
    }

    notifyListeners();
    return result;
  }
}
