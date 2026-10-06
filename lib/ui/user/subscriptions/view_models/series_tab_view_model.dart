import 'package:better_bilibili/data/model/bilibili/movie_model.dart';
import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_subscribed_series_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

const ps = 20;
const _watchStatusValues = [
  GetSubscribedSeriesWatchStatusEnum.all,
  GetSubscribedSeriesWatchStatusEnum.unwatched,
  GetSubscribedSeriesWatchStatusEnum.watching,
  GetSubscribedSeriesWatchStatusEnum.watched,
];

class SeriesTabViewModel extends SafeChangeNotifier {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  final String userId;

  SeriesTabViewModel({
    required UserRepository userRepository,
    required AuthRepository authRepository,
    required this.userId,
  }) : _userRepository = userRepository,
       _authRepository = authRepository {
    loadData = CancellableCommand0(
      _loadData,
      onSuccess: (resp) => loadDataSuccess(resp),
      onCancel: () {},
    )..execute();
    modifySeriesWatchStatus = Command1<void, ModifySeriesWatchStatusRequest>((req) => _modifySeriesWatchStatus(req));
    unsubscribe = Command1<void, String>((seriesId) => _unsubscribe(seriesId));
  }

  late final CancellableCommand0 loadData;

  final List<SubscribedSeries> _series = [];
  List<SubscribedSeries> get series => List.unmodifiable(_series);

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

  bool? _isCurrentUser;
  bool get isCurrentUser => _isCurrentUser ?? false;

  int _selectedWatchStatusIndex = 0;
  int get selectedWatchStatusIndex => _selectedWatchStatusIndex;
  void setSelectedWatchStatusIndex(int index) {
    if (_selectedWatchStatusIndex == index) return;
    _selectedWatchStatusIndex = index;
    _pn = 1;
    notifyListeners();
    reload();
  }

  Future<Result<GetSubscribedSeriesResponse>> _loadData() async {
    final result = await _userRepository.getSubscribedSeries(
      userId: userId,
      pn: _pn,
      ps: ps,
      watchStatus: _watchStatusValues[_selectedWatchStatusIndex],
    );
    _isCurrentUser ??= userId == (await _authRepository.getAccount()).userId;
    return result;
  }

  void loadDataSuccess(GetSubscribedSeriesResponse result) {
    _series.addAll(result.list);
    _total = result.total;
    notifyListeners();
  }

  void reload() {
    _series.clear();
    notifyListeners();
    loadData.cancel();
    loadData.execute();
  }

  late final Command1<void, ModifySeriesWatchStatusRequest> modifySeriesWatchStatus;

  Future<Result<void>> _modifySeriesWatchStatus(ModifySeriesWatchStatusRequest req) async {
    final result = await _userRepository.modifySeriesWatchStatus(
      seriesId: req.seriesId,
      watchStatus: req.watchStatus,
    );
    switch (result) {
      case Ok():
        final index = _series.indexWhere((element) => element.id == req.seriesId);
        _series[index] = _series[index].copyWith(watchStatus: req.watchStatus);
        notifyListeners();
      case Error():
    }
    return result;
  }

  late final Command1<void, String> unsubscribe;

  Future<Result<void>> _unsubscribe(String seriesId) async {
    final result = await _userRepository.unsubscribeSeries(seriesId: seriesId);
    switch (result) {
      case Ok():
        _series.removeWhere((v) => v.id == seriesId);
        notifyListeners();
      case Error():
    }
    return result;
  }
}

class ModifySeriesWatchStatusRequest {
  final String seriesId;
  final MovieWatchStatus watchStatus;

  ModifySeriesWatchStatusRequest({
    required this.seriesId,
    required this.watchStatus,
  });
}
