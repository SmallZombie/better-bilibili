import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_watch_history.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

const _durationOptions = <(int, int)>[
  (0, 0),
  (0, 600),
  (600, 1800),
  (1800, 3600),
  (3600, 0),
];

const _typeOptions = <GetWatchHistoryTypeEnum>[
  GetWatchHistoryTypeEnum.all,
  GetWatchHistoryTypeEnum.video,
  GetWatchHistoryTypeEnum.article,
  GetWatchHistoryTypeEnum.live,
];

const _filterTypeOptions = <GetWatchHistoryWithFilterTypeEnum>[
  GetWatchHistoryWithFilterTypeEnum.all,
  GetWatchHistoryWithFilterTypeEnum.video,
  GetWatchHistoryWithFilterTypeEnum.article,
  GetWatchHistoryWithFilterTypeEnum.live,
];

const _deviceTypeOptions = <GetWatchHistoryWithFilterDeviceTypeEnum>[
  GetWatchHistoryWithFilterDeviceTypeEnum.all,
  GetWatchHistoryWithFilterDeviceTypeEnum.pc,
  GetWatchHistoryWithFilterDeviceTypeEnum.mobile,
  GetWatchHistoryWithFilterDeviceTypeEnum.tablet,
  GetWatchHistoryWithFilterDeviceTypeEnum.tv,
];

class WatchHistoryViewModel extends SafeChangeNotifier {
  WatchHistoryViewModel({
    required UserRepository userRepository,
  }) : _userRepository = userRepository {
    loadWatchHistory = Command0(_loadWatchHistory)..execute();
    loadHistoryConfig = Command0(_loadHistoryConfig)..execute();
    setHistoryConfig = Command1<void, bool>((enable) => _setHistoryConfig(enable));
    clearAllWatchHistory = Command0(_clearAllWatchHistory);
    deleteSelectedItems = Command0(_deleteSelectedItems);
  }

  final UserRepository _userRepository;

  late final Command0<void> loadWatchHistory;

  final List<dynamic> _watchHistory = [];
  final List<dynamic> _todayList = [];
  final List<dynamic> _yesterdayList = [];
  final List<dynamic> _beforeYesterdayList = [];
  final List<dynamic> _otherList = [];

  List<dynamic> get watchHistory => List.unmodifiable(_watchHistory);
  List<dynamic> get todayList => List.unmodifiable(_todayList);
  List<dynamic> get yesterdayList => List.unmodifiable(_yesterdayList);
  List<dynamic> get beforeYesterdayList => List.unmodifiable(_beforeYesterdayList);
  List<dynamic> get otherList => List.unmodifiable(_otherList);

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  Future<Result<void>> _loadWatchHistory() async {
    // 仅在只有类型改变时使用无筛选器api，否则使用withFilter版本
    final useCursorApi = selectedDurationIndex == 0 && selectedRecordTimeIndex == 0 && selectedDeviceIndex == 0 && keyword.isEmpty;
    if (useCursorApi) {
      return await _loadWatchHistoryWithNoFilter();
    } else {
      return await _loadWatchHistoryWithFilter();
    }
  }

  void _addToDateList(dynamic item) {
    final watchTime = _getWatchTime(item);
    final date = DateTime.fromMillisecondsSinceEpoch(watchTime * 1000);
    final dateOnly = DateTime(date.year, date.month, date.day);

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));
    final beforeYesterdayStart = todayStart.subtract(const Duration(days: 2));

    if (dateOnly == todayStart) {
      _todayList.add(item);
    } else if (dateOnly == yesterdayStart) {
      _yesterdayList.add(item);
    } else if (dateOnly == beforeYesterdayStart) {
      _beforeYesterdayList.add(item);
    } else {
      _otherList.add(item);
    }
  }

  int _nextCursor = 0;
  int _viewAt = 0;

  Future<Result<void>> _loadWatchHistoryWithNoFilter() async {
    final result = await _userRepository.getWatchHistory(
      nextCursor: _nextCursor,
      viewAt: _viewAt,
      type: _typeOptions[selectedTypeIndex],
    );

    switch (result) {
      case Ok(:final value):
        _watchHistory.addAll(value.list);
        for (final item in value.list) {
          _addToDateList(item);
        }
        _nextCursor = value.nextCursor;
        _viewAt = value.viewAt;

        if (value.list.isEmpty) {
          _hasMore = false;
        }
      case Error():
    }
    notifyListeners();
    return result;
  }

  int _pn = 1;
  String keyword = '';
  int selectedTypeIndex = 0;
  int selectedDurationIndex = 0;
  int selectedRecordTimeIndex = 0;
  int selectedDeviceIndex = 0;
  int? customRecordTimeStartSec;
  int? customRecordTimeEndSec;

  Future<Result<void>> _loadWatchHistoryWithFilter() async {
    final result = await _userRepository.getWatchHistoryWithFilter(
      pn: _pn,
      keyword: keyword,
      type: _filterTypeOptions[selectedTypeIndex],
      minDuration: _durationOptions[selectedDurationIndex].$1,
      maxDuration: _durationOptions[selectedDurationIndex].$2,
      minUploadTime: _resolveRecordTimeRangeSec().$1,
      maxUploadTime: _resolveRecordTimeRangeSec().$2,
      deviceType: _deviceTypeOptions[selectedDeviceIndex],
    );

    switch (result) {
      case Ok(:final value):
        _watchHistory.addAll(value.list);
        value.list.forEach(_addToDateList);
        _pn++;
        _hasMore = value.hasMore;
      case Error():
    }

    notifyListeners();
    return result;
  }

  void setKeyword(String keyword) {
    this.keyword = keyword;
    reload();
  }

  void setSelectedTypeIndex(int index) {
    selectedTypeIndex = index;
    notifyListeners();
  }

  void setSelectedDurationIndex(int index) {
    selectedDurationIndex = index;
    notifyListeners();
  }

  void setSelectedRecordTimeIndex(int index) {
    selectedRecordTimeIndex = index;
    notifyListeners();
  }

  void setSelectedDeviceIndex(int index) {
    selectedDeviceIndex = index;
    notifyListeners();
  }

  void setCustomRecordTimeRange({required int startSec, required int endSec}) {
    customRecordTimeStartSec = startSec;
    customRecordTimeEndSec = endSec;
    notifyListeners();
  }

  int _snapshotFiltersState = Object.hash(0, 0, 0, 0, null, null);

  bool? _isHistoryEnabled;
  bool? get isHistoryEnabled => _isHistoryEnabled;

  bool get showEmpty => !loadWatchHistory.running && !loadWatchHistory.error && _watchHistory.isEmpty;

  int _getFiltersState() => Object.hash(
    selectedTypeIndex,
    selectedDurationIndex,
    selectedRecordTimeIndex,
    selectedDeviceIndex,
    customRecordTimeStartSec,
    customRecordTimeEndSec,
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
    _todayList.clear();
    _yesterdayList.clear();
    _beforeYesterdayList.clear();
    _otherList.clear();
    _watchHistory.clear();

    _nextCursor = 0;
    _viewAt = 0;
    _pn = 1;
    _hasMore = true;

    loadWatchHistory.execute();
  }

  late final Command0<void> loadHistoryConfig;

  Future<Result<void>> _loadHistoryConfig() async {
    final result = await _userRepository.getWatchHistoryConfig();
    switch (result) {
      case Ok(:final value):
        _isHistoryEnabled = value;
      case Error():
        _isHistoryEnabled = null;
    }
    return result;
  }

  late final Command1<void, bool> setHistoryConfig;

  Future<Result<void>> _setHistoryConfig(bool enable) async {
    final result = await _userRepository.setWatchHistoryConfig(enable: enable);
    switch (result) {
      case Ok():
        _isHistoryEnabled = enable;
      case Error():
    }
    return result;
  }

  late final Command0<void> clearAllWatchHistory;

  Future<Result<void>> _clearAllWatchHistory() async {
    final result = await _userRepository.clearWatchHistory();
    switch (result) {
      case Ok():
        reload();
      case Error():
        notifyListeners();
    }
    return result;
  }

  (int, int) _resolveRecordTimeRangeSec() {
    switch (selectedRecordTimeIndex) {
      case 1:
        return _yesterdayRangeSec();
      case 2:
        return _lastDaysRangeSec(7);
      case 3:
        return _lastDaysRangeSec(30);
      case 4:
        final start = customRecordTimeStartSec;
        final end = customRecordTimeEndSec;
        if (start != null && end != null) {
          return (start, end);
        }
        return (0, 0);
      default:
        return (0, 0);
    }
  }

  (int, int) _yesterdayRangeSec() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));
    final end = todayStart.subtract(const Duration(seconds: 1));
    return (
      yesterdayStart.millisecondsSinceEpoch ~/ 1000,
      end.millisecondsSinceEpoch ~/ 1000,
    );
  }

  (int, int) _lastDaysRangeSec(int days) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final start = todayStart.subtract(Duration(days: days));
    final endSec = now.millisecondsSinceEpoch ~/ 1000;
    return (start.millisecondsSinceEpoch ~/ 1000, endSec);
  }

  int _getWatchTime(dynamic item) {
    if (item is WatchHistoryVideo) {
      return item.watchTime;
    } else if (item is WatchHistoryLive) {
      return item.watchTime;
    } else if (item is WatchHistoryArticle) {
      return item.watchTime;
    } else if (item is WatchHistoryMovie) {
      return item.watchTime;
    } else if (item is WatchHistoryAnthology) {
      return item.watchTime;
    }
    throw Exception('Unknown item type: ${item.runtimeType}');
  }

  late final Command0 deleteSelectedItems;

  Future<Result<void>> _deleteSelectedItems() async {
    final ids = _selectedItems.map((v) => getItemId(v)).toList();
    final result = await _userRepository.deleteWatchHistory(ids);
    switch (result) {
      case Ok():
        _watchHistory.removeWhere(selectedItems.contains);
        _todayList.removeWhere(selectedItems.contains);
        _yesterdayList.removeWhere(selectedItems.contains);
        _beforeYesterdayList.removeWhere(selectedItems.contains);
        _otherList.removeWhere(selectedItems.contains);
      case Error():
    }

    notifyListeners();
    return result;
  }

  String getItemId(dynamic item) {
    if (item is WatchHistoryVideo) {
      return '${GetWatchHistoryWithFilterTypeEnum.video.value}_${item.id}';
    } else if (item is WatchHistoryLive) {
      return '${GetWatchHistoryWithFilterTypeEnum.live.value}_${item.id}';
    } else if (item is WatchHistoryArticle) {
      return '${GetWatchHistoryWithFilterTypeEnum.article.value}_${item.id}';
    } else if (item is WatchHistoryMovie) {
      return '${GetWatchHistoryWithFilterTypeEnum.movie.value}_${item.id}';
    } else if (item is WatchHistoryAnthology) {
      return '${GetWatchHistoryWithFilterTypeEnum.anthology.value}_${item.id}';
    }
    throw Exception('Unknown item type: ${item.runtimeType}');
  }

  final Set<dynamic> _selectedItems = {};
  Set<dynamic> get selectedItems => Set.unmodifiable(_selectedItems);

  void toggleItemSelection(dynamic item) {
    if (_selectedItems.contains(item)) {
      _selectedItems.remove(item);
    } else {
      _selectedItems.add(item);
    }
    notifyListeners();
  }

  void selectAll() {
    _selectedItems.clear();
    _selectedItems.addAll(_watchHistory);
    notifyListeners();
  }

  void deselectAll() {
    _selectedItems.clear();
    notifyListeners();
  }

  void invertSelection() {
    for (final item in _watchHistory) {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    }
    notifyListeners();
  }

  void clearSelectedItems() {
    _selectedItems.clear();
    notifyListeners();
  }
}
