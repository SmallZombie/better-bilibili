import 'package:better_bilibili/data/repositories/bilibili/video_repository/video_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_collections_and_playlists_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

const ps = 20;

class UserDetailPlaylistViewModel extends SafeChangeNotifier {
  final VideoRepository _videoRepository;

  final String userId;

  UserDetailPlaylistViewModel({
    required VideoRepository videoRepository,
    required this.userId,
  }) : _videoRepository = videoRepository {
    loadData = Command0(_loadData)..execute();
  }

  late final Command0 loadData;

  int _pn = 1;
  int get pn => _pn;
  void setPn(int newPn) {
    if (newPn == _pn) return;
    _pn = newPn;
    notifyListeners();
    reload();
  }

  final List<GetUserCollectionsAndPlaylistsItem> _playlists = [];
  List<GetUserCollectionsAndPlaylistsItem> get playlists => List.unmodifiable(_playlists);

  int _total = 0;
  int get total => _total;

  Future<Result<void>> _loadData() async {
    final result = await _videoRepository.getUserCollectionsAndPlaylists(
      userId: userId,
      pn: _pn,
      ps: ps,
    );
    switch (result) {
      case Ok(:final value):
        _playlists.addAll(value.list);
        _total = value.total;
      case Err():
    }

    notifyListeners();
    return result;
  }

  void reload() {
    _playlists.clear();
    notifyListeners();
    loadData.execute();
  }
}
