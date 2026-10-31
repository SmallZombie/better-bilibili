import 'dart:async';

import 'package:better_bilibili/data/repositories/bilibili/search_repository/search_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_trending_list_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/search_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';
import 'package:logger/logger.dart';

class Filter<T> {
  final String name;
  final List<FilterItem<T>> values;

  const Filter({required this.name, required this.values});
}

class FilterItem<T> {
  final String name;
  final T value;

  const FilterItem({required this.name, required this.value});
}

const typeFilter = Filter<SearchTypeEnum>(
  name: '类型',
  values: [
    FilterItem(name: '全部', value: .all),
    FilterItem(name: '视频', value: .video),
    FilterItem(name: '剧集', value: .series),
    FilterItem(name: '电影', value: .movie),
    FilterItem(name: '直播', value: .live),
    FilterItem(name: '文章', value: .article),
    FilterItem(name: '用户', value: .user),
  ],
);

const videoOrderFilter = Filter<GetSearchResultWithFilterOrderEnum>(
  name: '排序',
  values: [
    FilterItem(name: '综合', value: .auto),
    FilterItem(name: '最新发布', value: .releaseTimeDesc),
    FilterItem(name: '最多浏览', value: .viewDesc),
    FilterItem(name: '最多弹幕', value: .danmakuDesc),
  ],
);

const releaseTimeFilter = Filter<int>(
  name: '发布时间',
  values: [
    FilterItem(name: '全部', value: 0),
    FilterItem(name: '今天', value: 1),
    FilterItem(name: '昨天', value: 2),
    FilterItem(name: '一周内', value: 3),
    FilterItem(name: '一个月内', value: 4),
    FilterItem(name: '自定义', value: 5),
  ],
);

const durationFilter = Filter<GetSearchResultWithFilterDurationEnum?>(
  name: '时长',
  values: [
    FilterItem(name: '全部', value: null),
    FilterItem(name: '小于10分钟', value: GetSearchResultWithFilterDurationEnum.under10Minutes),
    FilterItem(name: '10~30分钟', value: GetSearchResultWithFilterDurationEnum.under30Minutes),
    FilterItem(name: '30~60分钟', value: GetSearchResultWithFilterDurationEnum.under60Minutes),
    FilterItem(name: '一小时以上', value: GetSearchResultWithFilterDurationEnum.over60Minutes),
  ],
);

const liveRoomOrderFilter = Filter<GetSearchResultWithFilterOrderEnum>(
  name: '排序',
  values: [
    FilterItem(name: '综合', value: GetSearchResultWithFilterOrderEnum.auto),
    FilterItem(name: '最新开播', value: GetSearchResultWithFilterOrderEnum.airtimeDesc),
  ],
);

const articleOrderFilter = Filter<GetSearchResultWithFilterOrderEnum>(
  name: '排序',
  values: [
    FilterItem(name: '综合', value: GetSearchResultWithFilterOrderEnum.auto),
    FilterItem(name: '最新发布', value: GetSearchResultWithFilterOrderEnum.releaseTimeDesc),
    FilterItem(name: '最多阅览', value: GetSearchResultWithFilterOrderEnum.viewDesc),
    FilterItem(name: '最多赞', value: GetSearchResultWithFilterOrderEnum.likeDesc),
    FilterItem(name: '最多评论', value: GetSearchResultWithFilterOrderEnum.commentDesc),
  ],
);

const userOrderFilter = Filter<GetSearchResultWithFilterOrderEnum>(
  name: '排序',
  values: [
    FilterItem(name: '综合', value: GetSearchResultWithFilterOrderEnum.auto),
    FilterItem(name: '粉丝量降序', value: GetSearchResultWithFilterOrderEnum.fansDesc),
    FilterItem(name: '粉丝量升序', value: GetSearchResultWithFilterOrderEnum.fansAsc),
    FilterItem(name: '等级降序', value: GetSearchResultWithFilterOrderEnum.levelDesc),
    FilterItem(name: '等级升序', value: GetSearchResultWithFilterOrderEnum.levelAsc),
  ],
);

const userTypeFilter = Filter<GetSearchResultWithFilterUserTypeEnum>(
  name: '类型',
  values: [
    FilterItem(name: '全部', value: GetSearchResultWithFilterUserTypeEnum.all),
    FilterItem(name: '发过视频', value: GetSearchResultWithFilterUserTypeEnum.uploader),
    FilterItem(name: '没发过视频', value: GetSearchResultWithFilterUserTypeEnum.notUploader),
    FilterItem(name: '拥有认证', value: GetSearchResultWithFilterUserTypeEnum.verified),
  ],
);

enum SearchTypeEnum {
  all(null),
  video(.video),
  series(.series),
  movie(.movie),
  live(.live),
  article(.article),
  user(.user);

  final GetSearchResultWithFilterTypeEnum? apiType;

  const SearchTypeEnum(this.apiType);
}

class SearchViewModel extends SafeChangeNotifier {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'SearchViewModel'));

  final SearchRepository searchRepository;
  final UserRepository userRepository;

  SearchViewModel({
    required this.searchRepository,
    required this.userRepository,
  }) {
    getSearchHistory = Command0(_getSearchHistory)..execute();
    getTrendingList = Command0(_getTrendingList)..execute();
    search = Command0(_search);
  }

  late final Command0 getSearchHistory;

  final List<String> _searchHistory = [];
  List<String> get searchHistory => List.unmodifiable(_searchHistory);

  Future<Result<void>> _getSearchHistory() async {
    final result = await userRepository.getSearchHistory();
    switch (result) {
      case Ok(:final value):
        _searchHistory.addAll(value);
      case Err():
    }

    notifyListeners();
    return result;
  }

  late final Command0 getTrendingList;

  final List<Trending> _trendingList = [];
  List<Trending> get trendingList => List.unmodifiable(_trendingList);

  Future<Result<void>> _getTrendingList() async {
    final result = await searchRepository.getTrendingList();
    switch (result) {
      case Ok(:final value):
        _trendingList.addAll(value);
      case Err():
    }

    notifyListeners();
    return result;
  }

  int latestSuggestionsId = 0;
  List<String> _suggestionList = [];
  List<String> get suggestionList => List.unmodifiable(_suggestionList);

  Future<void> getSuggestions() async {
    final id = ++latestSuggestionsId;
    final result = await searchRepository.getSuggestList(keyword);

    if (id != latestSuggestionsId) return;

    switch (result) {
      case Ok(:final value):
        _suggestionList = value;
      case Err():
    }

    notifyListeners();
  }

  late final Command0<void> search;

  String _keyword = '';
  String get keyword => _keyword;
  void setKeyword(String newValue) {
    if (newValue == _keyword) return;
    _keyword = newValue;
    notifyListeners();
  }

  int _pn = 1;
  int get pn => _pn;
  void setPn(int page) {
    _pn = page;
    reload();
  }

  int get total => _searchResponse?.total ?? _searchResponseWithFilter?.total ?? 0;

  Map<Filter, int> _selectedIndexs = {};
  Map<Filter, int> get selectedIndexs => _selectedIndexs;
  void setFilterIndex(Filter filter, int newValue) {
    if (_selectedIndexs[filter] == newValue) return;

    _selectedIndexs = {
      ..._selectedIndexs,
      filter: newValue,
    };
    notifyListeners();
  }

  int filterIndex(Filter filter) => _selectedIndexs[filter] ?? 0;

  int _customReleaseTimeStart = 0;
  int _customReleaseTimeEnd = 0;
  int? get customReleaseTimeStart => _customReleaseTimeStart;
  int? get customReleaseTimeEnd => _customReleaseTimeEnd;

  void setCustomReleaseTimeRange(int start, int end) {
    _customReleaseTimeStart = start;
    _customReleaseTimeEnd = end;
    notifyListeners();
  }

  void reload() {
    _searchResponse = null;
    _searchResponseWithFilter = null;
    search.execute();
  }

  void reSearch() {
    _pn = 1;
    reload();
  }

  int _latestFilterKey = 0;

  int _getFilterKey() => Object.hashAll([
    ..._selectedIndexs.values,
    _customReleaseTimeStart,
    _customReleaseTimeEnd,
  ]);

  void onFilterSheetDismissed() {
    final key = _getFilterKey();
    if (key != _latestFilterKey) {
      _log.i('filterKeyChanged: $_latestFilterKey => $key');
      _latestFilterKey = key;
      if (_keyword.isNotEmpty) reSearch();
    }
  }

  SearchResponse? _searchResponse;
  SearchResponseWithFilter? _searchResponseWithFilter;
  List<dynamic>? get resultList => _searchResponse?.list ?? _searchResponseWithFilter?.list;
  List<SearchResultSeries> get resultSeries => _searchResponse?.series ?? const [];
  List<SearchResultMovie> get resultMovies => _searchResponse?.movies ?? const [];
  List<SearchResultGame> get resultGames => _searchResponse?.games ?? const [];
  List<SearchResultUser> get resultUsers => _searchResponse?.users ?? const [];
  List<SearchResultEvent> get resultEvents => _searchResponse?.events ?? const [];
  List<SearchResultBanner> get resultBanners => _searchResponse?.banners ?? const [];

  String? _latestSearchKeyword;
  String? get latestKeyword => _latestSearchKeyword;

  Future<Result<void>> _search() async {
    _searchHistory.add(_keyword);
    unawaited(userRepository.addSearchHistory(_keyword));
    _latestSearchKeyword = _keyword;
    notifyListeners();

    final type = typeFilter.values[_selectedIndexs[typeFilter] ?? 0].value;
    if (type == .all) {
      final result = await searchRepository.getSearchResult(pn: _pn, keyword: _keyword);
      switch (result) {
        case Ok(:final value):
          _searchResponse = value;
        case Err(:final error):
          return Result.error(error);
      }
    } else {
      final releaseTime = _resolveReleaseTimeRange();
      final result = await searchRepository.getSearchResultWithFilter(
        pn: _pn,
        keyword: _keyword,
        type: type.apiType!,
        order: _resolveOrder(),
        duration: type == .video ? durationFilter.values[filterIndex(durationFilter)].value : null,
        userType: type == .user ? userTypeFilter.values[filterIndex(userTypeFilter)].value : .all,
        releaseTimeStart: releaseTime.start,
        releaseTimeEnd: releaseTime.end,
      );
      switch (result) {
        case Ok(:final value):
          _searchResponseWithFilter = value;
        case Err(:final error):
          return Result.error(error);
      }
    }

    return Result.ok(null);
  }

  GetSearchResultWithFilterOrderEnum _resolveOrder() => switch (typeFilter.values[filterIndex(typeFilter)].value) {
    .video => videoOrderFilter.values[filterIndex(videoOrderFilter)].value,
    .live => liveRoomOrderFilter.values[filterIndex(liveRoomOrderFilter)].value,
    .article => articleOrderFilter.values[filterIndex(articleOrderFilter)].value,
    .user => userOrderFilter.values[filterIndex(userOrderFilter)].value,
    _ => .auto,
  };

  ({int start, int end}) _resolveReleaseTimeRange() {
    final type = typeFilter.values[_selectedIndexs[typeFilter] ?? 0].value;
    if (type != .video) return (start: 0, end: 0);

    int sec(DateTime d) => d.millisecondsSinceEpoch ~/ 1000;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endOfToday = today.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
    final startOfYesterday = today.subtract(const Duration(days: 1));
    final endOfYesterday = today.subtract(const Duration(seconds: 1));

    return switch (filterIndex(releaseTimeFilter)) {
      1 => (start: sec(today), end: sec(endOfToday)),
      2 => (start: sec(startOfYesterday), end: sec(endOfYesterday)),
      3 => (start: sec(now.subtract(const Duration(days: 7))), end: sec(now)),
      4 => (start: sec(now.subtract(const Duration(days: 30))), end: sec(now)),
      5 => (start: _customReleaseTimeStart, end: _customReleaseTimeEnd),
      _ => (start: 0, end: 0),
    };
  }

  bool _incognitoMode = false;
  bool get incognitoMode => _incognitoMode;
  void setIncognitoMode(bool newValue) {
    if (newValue == _incognitoMode) return;
    _incognitoMode = newValue;
    notifyListeners();
  }

  void clearSearchHistory() {
    _searchHistory.clear();
    userRepository.clearSearchHistory();
    notifyListeners();
  }

  bool _deleteSearchHistoryMode = false;
  bool get deleteSearchHistoryMode => _deleteSearchHistoryMode;
  void setDeleteSearchHistoryMode(bool newValue) {
    if (newValue == _deleteSearchHistoryMode) {
      return;
    }

    _deleteSearchHistoryMode = newValue;
    notifyListeners();
  }

  void deleteSearchHistory(String keyword) {
    _searchHistory.removeWhere((v) => v == keyword);
    userRepository.deleteSearchHistory(keyword);
    notifyListeners();
  }

  bool _isSearchHistoryExpanded = false;
  bool get isSearchHistoryExpanded => _isSearchHistoryExpanded;
  void setSearchHistoryExpanded(bool newValue) {
    if (newValue == _isSearchHistoryExpanded) {
      return;
    }

    _isSearchHistoryExpanded = newValue;
    notifyListeners();
  }
}
