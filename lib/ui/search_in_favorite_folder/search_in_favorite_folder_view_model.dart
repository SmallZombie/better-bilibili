import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_detail_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

const _orderOptions = <GetFavoritesDetailOrderEnum>[
  .favoriteTimeDesc,
  .viewDesc,
  .releaseTimeDesc,
];

class SearchInFavoriteFolderViewModel extends SafeChangeNotifier {
  final UserRepository userRepository;
  final AuthRepository authRepository;

  SearchInFavoriteFolderViewModel({
    required this.userRepository,
    required this.authRepository,
  }) {
    search = Command0(_search);
  }

  late final Command0<void> search;

  String _keyword = '';
  String get keyword => _keyword;
  void setKeyword(String keyword) {
    _keyword = keyword;
    if (_keyword.isNotEmpty) reset();
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
    if (pn == _pn) return;
    _pn = pn;
    reSearch();
  }

  int _total = 0;
  int get total => _total;

  final ps = 20;
  String? _anyFolderId;

  final List<dynamic> _searchResult = [];
  List<dynamic> get searchResult => List.unmodifiable(_searchResult);

  Future<Result<void>> _search() async {
    if (_anyFolderId == null) {
      final account = await authRepository.getAccount();
      final result = await userRepository.getFavoritesSimpleList(userId: account.userId);
      switch (result) {
        case Ok(:final value):
          _anyFolderId = value.list.first.id;
        case Err():
          notifyListeners();
          return result;
      }
    }

    assert(_anyFolderId != null);

    final result = await userRepository.getFavoritesDetail(
      favoritesId: _anyFolderId!,
      pn: _pn,
      ps: ps,
      keyword: _keyword,
      order: _orderOptions[_selectedOrderIndex],
      scope: .global,
    );
    switch (result) {
      case Ok(:final value):
        _searchResult.addAll(value.list);
        _total = value.total;
      case Err():
    }

    notifyListeners();
    return result;
  }

  int _snapshotFiltersState = Object.hash(null, 0);

  bool get showEmpty => !search.running && !search.error && _searchResult.isEmpty;

  int _getFiltersState() => _selectedOrderIndex;

  void rememberFiltersState() {
    _snapshotFiltersState = _getFiltersState();
  }

  void onFilterSheetDismissed() {
    if (_getFiltersState() != _snapshotFiltersState) {
      reset();
    }
  }

  void reset() {
    _pn = 1;
    reSearch();
  }

  void reSearch() {
    _searchResult.clear();
    search.execute();
  }
}
