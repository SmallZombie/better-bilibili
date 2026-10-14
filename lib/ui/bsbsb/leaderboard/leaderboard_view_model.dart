import 'package:better_bilibili/data/model/bsbsb/leaderboard_entry.dart';
import 'package:better_bilibili/data/repositories/bsbsb/bsbsb_repository.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:material_ui/material_ui.dart';

class LeaderboardViewModel extends ChangeNotifier {
  final BsbsbRepository bsbsbRepository;

  LeaderboardViewModel({required this.bsbsbRepository});

  late final Command0<List<LeaderboardEntry>> loadData = Command0(_loadData)..execute();

  List<LeaderboardEntry> data = [];

  Future<Result<List<LeaderboardEntry>>> _loadData() async {
    final result = await bsbsbRepository.getLeaderboard(ps: 100);
    switch (result) {
      case Ok(:final value):
        data = value;
      case Error():
    }

    notifyListeners();
    return result;
  }
}
