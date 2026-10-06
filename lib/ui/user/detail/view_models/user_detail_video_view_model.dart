import 'package:better_bilibili/data/repositories/bilibili/video_repository/video_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_videos_with_user_id_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

const ps = 25;
const _orderValues = [
  GetVideosWithUserOrderEnum.releaseTimeDesc,
  GetVideosWithUserOrderEnum.viewDesc,
  GetVideosWithUserOrderEnum.favoriteDesc,
];

class UserDetailVideoViewModel extends SafeChangeNotifier {
  final VideoRepository _videoRepository;

  final String userId;

  UserDetailVideoViewModel({
    required VideoRepository videoRepository,
    required this.userId,
  }) : _videoRepository = videoRepository {
    loadData = CancellableCommand0(
      _loadData,
      onSuccess: (resp) => loadDataSuccess(resp),
      onCancel: () {},
    )..execute();
  }

  int _selectedChipIndex = 0;
  int get selectedChipIndex => _selectedChipIndex;

  void setSelectedChipIndex(int index) {
    if (index == _selectedChipIndex) return;
    _selectedChipIndex = index;
    reload();
    notifyListeners();
  }

  late final CancellableCommand0 loadData;

  int _pn = 1;
  int get pn => _pn;
  void setPn(int pn) {
    _pn = pn;
    notifyListeners();
    reload();
  }

  int _total = 0;
  int get total => _total;

  int _sponsorOnlyTotal = 0;
  int get sponsorOnlyTotal => _sponsorOnlyTotal;

  final List<VideoItem> _videos = [];
  List<VideoItem> get videos => List.unmodifiable(_videos);

  Future<Result<void>> _loadData() async {
    final result = await _videoRepository.getVideosWithUser(
      userId: userId,
      pn: _pn,
      ps: ps,
      type: _selectedChipIndex == 3 ? .sponsorOnly : .all,
      order: _selectedChipIndex != 3 ? _orderValues[_selectedChipIndex] : .releaseTimeDesc,
    );
    return result;
  }

  void loadDataSuccess(GetVideosWithUserIdResponse resp) {
    _videos.addAll(resp.list);
    _total = resp.total;
    _sponsorOnlyTotal = resp.sponsorOnlyTotal;
    notifyListeners();
  }

  void reload() {
    _videos.clear();
    notifyListeners();

    loadData.cancel();
    loadData.execute();
  }
}
