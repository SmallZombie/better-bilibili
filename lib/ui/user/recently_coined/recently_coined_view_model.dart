import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class RecentlyCoinedViewModel extends SafeChangeNotifier {
  final UserRepository _userRepository;

  final String userId;

  RecentlyCoinedViewModel({
    required UserRepository userRepository,
    required this.userId,
  }) : _userRepository = userRepository {
    loadData = Command0(_loadData)..execute();
  }

  late final Command0 loadData;

  final List<dynamic> _videos = [];
  List<dynamic> get videos => List.unmodifiable(_videos);

  Future<Result<void>> _loadData() async {
    final result = await _userRepository.getCoinedVideos(userId);
    switch (result) {
      case Ok(:final value):
        _videos.addAll(value);
      case Error():
    }

    notifyListeners();
    return result;
  }
}
