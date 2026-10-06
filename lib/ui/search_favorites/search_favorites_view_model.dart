import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_detail_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_simple_list_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

const _orderOptions = <GetFavoritesDetailOrderEnum>[
  GetFavoritesDetailOrderEnum.favoriteTimeDesc,
  GetFavoritesDetailOrderEnum.viewDesc,
  GetFavoritesDetailOrderEnum.releaseTimeDesc,
];

class SearchFavoritesViewModel extends SafeChangeNotifier {
  final UserRepository _userRepository;

  SearchFavoritesViewModel({
    required UserRepository userRepository,
  }) : _userRepository = userRepository {
    loadAddFavorites = Command0(_loadAddFavorites)..execute();
    search = Command0(_searchFavorites);
  }

  late final Command0<void> loadAddFavorites;

  final List<SimpleFavorites> _favorites = [];
  List<SimpleFavorites> get favorites => List.unmodifiable(_favorites);

  Future<Result<void>> _loadAddFavorites() async {
    final result = await _userRepository.getFavoritesSimpleList();
    switch (result) {
      case Ok(:final value):
        _favorites.addAll(value.list);
      case Error():
    }
    return result;
  }

  late final Command0<void> search;

  String _keyword = '';
  String get keyword => _keyword;
  void setKeyword(String keyword) {
    _keyword = keyword;
    if (_keyword.isNotEmpty) reload();
  }

  String? _selectedFavoritesId;
  String? get selectedFavoritesId => _selectedFavoritesId;
  void setSelectedFavoritesId(String? favoritesId) {
    _selectedFavoritesId = favoritesId;
    notifyListeners();
  }

  int _selectedOrderIndex = 0;
  int get selectedOrderIndex => _selectedOrderIndex;
  void setSelectedOrderIndex(int index) {
    _selectedOrderIndex = index;
    notifyListeners();
  }

  int _pn = 1;
  int get pn => _pn;
  void setPn(int pn) {
    _pn = pn;
    notifyListeners();
  }

  final List<dynamic> _searchResult = [];
  List<dynamic> get searchResult => List.unmodifiable(_searchResult);

  Future<Result<void>> _searchFavorites() async {
    final result = await _userRepository.getFavoritesDetail(
      favoritesId: _selectedFavoritesId ?? _favorites.first.id,
      pn: _pn,
      keyword: _keyword,
      order: _orderOptions[_selectedOrderIndex],
      scope: _selectedFavoritesId == null ? GetFavoritesDetailScopeEnum.global : GetFavoritesDetailScopeEnum.local,
    );
    switch (result) {
      case Ok(:final value):
        _searchResult.addAll(value.list);
      case Error():
    }
    return result;
  }

  int _snapshotFiltersState = Object.hash(null, 0);

  bool get showEmpty => !search.running && !search.error && _searchResult.isEmpty;

  int _getFiltersState() => Object.hash(_selectedFavoritesId, _selectedOrderIndex);

  void rememberFiltersState() {
    _snapshotFiltersState = _getFiltersState();
  }

  void onFilterSheetDismissed() {
    if (_getFiltersState() != _snapshotFiltersState) {
      reload();
    }
  }

  void reload() {
    _searchResult.clear();
    _pn = 1;
    search.execute();
  }
}
