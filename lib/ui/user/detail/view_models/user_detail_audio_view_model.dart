import 'package:better_bilibili/data/repositories/bilibili/audio_repository/audio_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_audios_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

const ps = 42;
const _orderValues = [
  GetUserAudiosOrderEnum.releaseTimeDesc,
  GetUserAudiosOrderEnum.playCountDesc,
  GetUserAudiosOrderEnum.favoritesCountDesc,
];

class UserDetailAudioViewModel extends SafeChangeNotifier {
  final AudioRepository _audioRepository;

  final String userId;

  UserDetailAudioViewModel({
    required AudioRepository audioRepository,
    required this.userId,
  }) : _audioRepository = audioRepository {
    loadData = CancellableCommand0(
      _loadData,
      onSuccess: (resp) => loadDataSuccess(resp),
      onCancel: () {},
    )..execute();
  }

  int _selectedOrderIndex = 0;
  int get selectedOrderIndex => _selectedOrderIndex;
  void setSelectedOrderIndex(int newIndex) {
    if (newIndex == _selectedOrderIndex) return;

    _selectedOrderIndex = newIndex;
    notifyListeners();

    reload();
  }

  late final CancellableCommand0 loadData;

  int _pn = 1;
  int get pn => _pn;
  void setPn(int newPn) {
    if (newPn == _pn) return;
    _pn = newPn;
    notifyListeners();
    reload();
  }

  int _total = 0;
  int get total => _total;

  final List<GetUserAudiosItem> _audios = [];
  List<GetUserAudiosItem> get audios => List.unmodifiable(_audios);

  Future<Result<void>> _loadData() async {
    final result = await _audioRepository.getUserAudios(
      userId: userId,
      order: _orderValues[_selectedOrderIndex],
      pn: _pn,
      ps: ps,
    );
    return result;
  }

  void loadDataSuccess(GetUserAudiosResponse resp) {
    _audios.addAll(resp.list);
    _total = resp.total;
    notifyListeners();
  }

  void reload() {
    _audios.clear();
    notifyListeners();

    loadData.cancel();
    loadData.execute();
  }
}
