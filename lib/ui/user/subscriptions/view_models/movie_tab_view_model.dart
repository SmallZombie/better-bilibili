import 'package:better_bilibili/data/model/bilibili/movie_model.dart';
import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_subscribed_movie_response.dart';
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

class MovieTabViewModel extends SafeChangeNotifier {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  final String userId;

  MovieTabViewModel({
    required UserRepository userRepository,
    required AuthRepository authRepository,
    required this.userId,
  }) : _userRepository = userRepository,
       _authRepository = authRepository {
    loadData = CancellableCommand0(
      _loadData,
      onSuccess: (result) => _loadDataSuccess(result),
      onCancel: () {},
    )..execute();
    modifyMovieWatchStatus = Command1<void, ModifyMovieWatchStatusRequest>((req) => _modifyMovieWatchStatus(req));
    unsubscribe = Command1<void, String>((movieId) => _unsubscribe(movieId));
  }

  late final CancellableCommand0 loadData;

  final List<SubscribedMovie> _movies = [];
  List<SubscribedMovie> get movies => List.unmodifiable(_movies);

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
  void setSelectedWatchStatusIndex(int newIndex) {
    if (_selectedWatchStatusIndex == newIndex) return;
    _selectedWatchStatusIndex = newIndex;
    _pn = 1;
    notifyListeners();
    reload();
  }

  Future<Result<void>> _loadData() async {
    final result = await _userRepository.getSubscribedMovie(
      userId: userId,
      pn: _pn,
      ps: ps,
      watchStatus: _watchStatusValues[_selectedWatchStatusIndex],
    );
    _isCurrentUser ??= userId == (await _authRepository.getAccount()).userId;
    return result;
  }

  void _loadDataSuccess(GetSubscribedMovieResponse result) {
    _movies.addAll(result.list);
    _total = result.total;
    notifyListeners();
  }

  void reload() {
    _movies.clear();
    notifyListeners();
    loadData.cancel();
    loadData.execute();
  }

  late final Command1<void, ModifyMovieWatchStatusRequest> modifyMovieWatchStatus;

  Future<Result<void>> _modifyMovieWatchStatus(ModifyMovieWatchStatusRequest req) async {
    final result = await _userRepository.modifyMovieWatchStatus(
      movieId: req.movieId,
      watchStatus: req.watchStatus,
    );
    switch (result) {
      case Ok():
        final index = _movies.indexWhere((element) => element.id == req.movieId);
        _movies[index] = _movies[index].copyWith(watchStatus: req.watchStatus);
        notifyListeners();
      case Error():
    }
    return result;
  }

  late final Command1<void, String> unsubscribe;

  Future<Result<void>> _unsubscribe(String movieId) async {
    final result = await _userRepository.unsubscribeMovie(movieId);
    switch (result) {
      case Ok():
        _movies.removeWhere((v) => v.id == movieId);
        notifyListeners();
      case Error():
    }
    return result;
  }
}

class ModifyMovieWatchStatusRequest {
  final String movieId;
  final MovieWatchStatus watchStatus;

  ModifyMovieWatchStatusRequest({
    required this.movieId,
    required this.watchStatus,
  });
}
