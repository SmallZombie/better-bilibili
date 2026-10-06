import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_watch_later.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

const _orderOptions = <GetWatchLaterOrderEnum>[
  GetWatchLaterOrderEnum.addTimeDesc,
  GetWatchLaterOrderEnum.addTimeAsc,
];

const _durationOptions = [
  (0, 0),
  (0, 600),
  (600, 1800),
  (1800, 3600),
  (3600, 0),
];

class WatchLaterViewModel extends SafeChangeNotifier {
  final UserRepository _userRepository;

  WatchLaterViewModel({
    required UserRepository userRepository,
  }) : _userRepository = userRepository {
    loadData = Command0(_loadWatchLater)..execute();
    copySelectedItemsToFavorites = Command1<void, String>((targetId) => _copySelectedItemsToFavorites(targetId));
    moveSelectedItemsToFavorites = Command1<void, String>((targetId) => _moveSelectedItemsToFavorites(targetId));
    deleteSelectedItems = Command0(_deleteSelectedItems);
    clearWatched = Command0(_clearWatched);
  }

  late final Command0<void> loadData;

  final List<dynamic> _watchLater = [];
  List<dynamic> get watchLater => List.unmodifiable(_watchLater);

  int _pn = 1;
  String _keyword = '';
  int _selectedOrderIndex = 0;
  int _selectedTypeIndex = 0;
  int _selectedDurationIndex = 0;
  int _selectedAddTimeIndex = 0;
  // 秒级时间戳
  int? _customAddTimeStart;
  int? _customAddTimeEnd;
  bool _hasMore = true;
  int get selectedOrderIndex => _selectedOrderIndex;
  int get selectedTypeIndex => _selectedTypeIndex;
  int get selectedDurationIndex => _selectedDurationIndex;
  int get selectedAddTimeIndex => _selectedAddTimeIndex;
  int? get customAddTimeStart => _customAddTimeStart;
  int? get customAddTimeEnd => _customAddTimeEnd;
  bool get hasMore => _hasMore;

  Future<Result<void>> _loadWatchLater() async {
    final result = await _userRepository.getWatchLater(
      pn: _pn,
      keyword: _keyword,
      minAddTime: _resolveAddTimeRangeSec().$1,
      maxAddTime: _resolveAddTimeRangeSec().$2,
      minDuration: _durationOptions[selectedDurationIndex].$1,
      maxDuration: _durationOptions[selectedDurationIndex].$2,
      order: _orderOptions[selectedOrderIndex],
      onlyUnwatched: _selectedTypeIndex == 1,
    );
    switch (result) {
      case Ok(:final value):
        _watchLater.addAll(value.list);
        _pn++;
        _hasMore = _watchLater.length != value.total;
      case Error():
    }
    return result;
  }

  void setKeyword(String keyword) {
    _keyword = keyword;
    reload();
  }

  void setSelectedOrderIndex(int index) {
    _selectedOrderIndex = index;
    notifyListeners();
  }

  void setSelectedTypeIndex(int index) {
    _selectedTypeIndex = index;
    notifyListeners();
  }

  void setSelectedDurationIndex(int index) {
    _selectedDurationIndex = index;
    notifyListeners();
  }

  void setSelectedAddTimeIndex(int index) {
    _selectedAddTimeIndex = index;
    notifyListeners();
  }

  void setCustomAddTimeRange({required int startSec, required int endSec}) {
    _customAddTimeStart = startSec;
    _customAddTimeEnd = endSec;
    notifyListeners();
  }

  int _snapshotFiltersState = Object.hash(0, 0, 0, 0, null, null);

  int _getFiltersState() => Object.hash(
    selectedOrderIndex,
    selectedTypeIndex,
    selectedDurationIndex,
    selectedAddTimeIndex,
    customAddTimeStart,
    customAddTimeEnd,
  );

  void rememberFiltersState() {
    _snapshotFiltersState = _getFiltersState();
  }

  void onFilterSheetDismissed() {
    if (_getFiltersState() != _snapshotFiltersState) {
      reload();
    }
  }

  void reload() {
    _watchLater.clear();

    _pn = 1;
    _hasMore = true;

    loadData.execute();
  }

  (int, int) _resolveAddTimeRangeSec() {
    (int, int) todayRangeSec() {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final tomorrowStart = todayStart.add(const Duration(days: 1));
      final end = tomorrowStart.subtract(const Duration(seconds: 1));
      return (
        todayStart.millisecondsSinceEpoch ~/ 1000,
        end.millisecondsSinceEpoch ~/ 1000,
      );
    }

    (int, int) yesterdayRangeSec() {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final yesterdayStart = todayStart.subtract(const Duration(days: 1));
      final end = todayStart.subtract(const Duration(seconds: 1));
      return (
        yesterdayStart.millisecondsSinceEpoch ~/ 1000,
        end.millisecondsSinceEpoch ~/ 1000,
      );
    }

    (int, int) lastDaysRangeSec(int days) {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final start = todayStart.subtract(Duration(days: days));
      final endSec = now.millisecondsSinceEpoch ~/ 1000;
      return (start.millisecondsSinceEpoch ~/ 1000, endSec);
    }

    switch (selectedAddTimeIndex) {
      case 1:
        return todayRangeSec();
      case 2:
        return yesterdayRangeSec();
      case 3:
        return lastDaysRangeSec(7);
      case 4:
        return lastDaysRangeSec(30);
      case 5:
        assert(customAddTimeStart != null && customAddTimeEnd != null);
        return (customAddTimeStart!, customAddTimeEnd!);
      default:
        return (0, 0);
    }
  }

  final Set<dynamic> _selectedItems = {};
  Set<dynamic> get selectedItems => Set.unmodifiable(_selectedItems);

  String _getItemId(dynamic item) {
    if (item is WatchLaterVideo) {
      return item.id;
    } else if (item is WatchLaterMovie) {
      return item.id;
    }
    throw Exception('Unknown item type: ${item.runtimeType}');
  }

  void toggleItemSelection(dynamic item) {
    _selectedItems.contains(item) ? _selectedItems.remove(item) : _selectedItems.add(item);
    notifyListeners();
  }

  void selectAll() {
    _selectedItems.clear();
    _selectedItems.addAll(_watchLater.map((e) => _watchLater.indexOf(e)));
    notifyListeners();
  }

  void deselectAll() {
    _selectedItems.clear();
    notifyListeners();
  }

  void invertSelection() {
    for (final item in _watchLater) {
      if (_selectedItems.contains(_watchLater.indexOf(item))) {
        _selectedItems.remove(_watchLater.indexOf(item));
      } else {
        _selectedItems.add(_watchLater.indexOf(item));
      }
    }
    notifyListeners();
  }

  void clearSelectedItems() {
    _selectedItems.clear();
    notifyListeners();
  }

  bool _multiSelectMode = false;
  bool get multiSelectMode => _multiSelectMode;
  void setMultiSelectMode(bool newState) {
    if (newState == _multiSelectMode) return;
    _multiSelectMode = newState;
    notifyListeners();
  }

  late final Command1<void, String> copySelectedItemsToFavorites;

  Future<Result<void>> _copySelectedItemsToFavorites(String targetId) async {
    final List<String> ids = _selectedItems.map((item) => _getItemId(item)).toList();
    final result = await _userRepository.copyFromWatchLaterToFavorites(ids: ids, targetFavoritesId: targetId);
    return result;
  }

  late final Command1<void, String> moveSelectedItemsToFavorites;

  Future<Result<void>> _moveSelectedItemsToFavorites(String targetId) async {
    final List<String> ids = _selectedItems.map((item) => _getItemId(item)).toList();
    final result = await _userRepository.moveFromWatchLaterToFavorites(ids: ids, targetFavoritesId: targetId);
    switch (result) {
      case Ok():
        _watchLater.removeWhere((item) => _selectedItems.contains(item));
        _selectedItems.clear();
        _multiSelectMode = false;
      case Error():
    }

    notifyListeners();
    return result;
  }

  late final Command0<void> deleteSelectedItems;

  Future<Result<void>> _deleteSelectedItems() async {
    final List<String> ids = _selectedItems.map((item) => _getItemId(item)).toList();
    final result = await _userRepository.deleteVideosFromWatchLater(ids: ids);
    switch (result) {
      case Ok():
        _watchLater.removeWhere((item) => _selectedItems.contains(item));
        _selectedItems.clear();
        _multiSelectMode = false;
      case Error():
    }

    notifyListeners();
    return result;
  }

  late final Command0<void> clearWatched;

  Future<Result<void>> _clearWatched() async {
    final result = await _userRepository.clearWatchedInWatchLater();
    switch (result) {
      case Ok():
        reload();
      case Error():
    }
    return result;
  }
}
