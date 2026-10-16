import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_detail_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

const _orderOptions = <GetFavoritesDetailOrderEnum>[
  GetFavoritesDetailOrderEnum.favoriteTimeDesc,
  GetFavoritesDetailOrderEnum.viewDesc,
  GetFavoritesDetailOrderEnum.releaseTimeDesc,
];

class FavoritesDetailViewModel extends SafeChangeNotifier {
  final UserRepository _userRepository;

  FavoritesDetailViewModel({
    required UserRepository userRepository,
  }) : _userRepository = userRepository {
    loadFavoritesDetail = Command1<void, String>((favoritesId) => _loadFavoritesDetail(favoritesId));
    copySelectedItemsToFavorites = Command1<void, String>((targetId) => _copySelectedItemsToFavorites(targetId));
    moveSelectedItemsToFavorites = Command1<void, String>((targetId) => _moveSelectedItemsToFavorites(targetId));
    deleteSelectedItems = Command0(_deleteSelectedItems);
    clearInvalid = Command0(_clearInvalid);
    deleteFavorites = Command0(_deleteFavorites);
  }

  late final Command1<void, String> loadFavoritesDetail;

  GetFavoritesDetailResponse? _favorites;
  GetFavoritesDetailResponse? get favorites => _favorites;
  List<dynamic> get items => List.unmodifiable(_favorites?.list ?? []);

  int _pn = 1;
  int get pn => _pn;
  void setPn(int pn) {
    _pn = pn;
    reload();
  }

  String _keyword = '';
  String get keyword => _keyword;
  void setKeyword(String keyword) {
    _keyword = keyword;
    reload();
  }

  int _selectedOrderIndex = 0;
  int get selectedOrderIndex => _selectedOrderIndex;
  void setSelectedOrderIndex(int index) {
    _selectedOrderIndex = index;
    reload();
  }

  int _total = 0;
  int get total => _total;

  Future<Result<void>> _loadFavoritesDetail(String favoritesId) async {
    final result = await _userRepository.getFavoritesDetail(
      favoritesId: favoritesId,
      pn: _pn,
      keyword: _keyword,
      order: _orderOptions[selectedOrderIndex],
    );
    switch (result) {
      case Ok(:final value):
        _favorites = value;
        if (_pn == 1 && keyword.isEmpty) {
          _total = value.total;
        }
      case Error():
    }
    return result;
  }

  void reload() {
    loadFavoritesDetail.execute(_favorites!.favoritesId);
    notifyListeners();
  }

  final Set<String> _selectedItemIds = {};
  Set<String> get selectedItemIds => Set.unmodifiable(_selectedItemIds);

  String getItemId(dynamic item) {
    if (item is FavoritesVideo) {
      return '${item.id}:2';
    } else if (item is FavoritesMovie) {
      return '${item.id}:24';
    }
    throw Exception('Unknown item type: ${item.runtimeType}');
  }

  void toggleItemSelection(String id) {
    _selectedItemIds.contains(id) ? _selectedItemIds.remove(id) : _selectedItemIds.add(id);
    notifyListeners();
  }

  void selectAll() {
    if (_favorites == null) {
      return;
    }

    final list = _favorites!.list;
    _selectedItemIds.clear();
    _selectedItemIds.addAll(list.map((e) => getItemId(e)));
    notifyListeners();
  }

  void deselectAll() {
    _selectedItemIds.clear();
    notifyListeners();
  }

  void invertSelection() {
    if (_favorites == null) {
      return;
    }

    final list = _favorites!.list;
    for (final item in list) {
      final id = getItemId(item);
      if (_selectedItemIds.contains(id)) {
        _selectedItemIds.remove(id);
      } else {
        _selectedItemIds.add(id);
      }
    }
    notifyListeners();
  }

  void clearSelectedItems() {
    _selectedItemIds.clear();
    notifyListeners();
  }

  late final Command1<void, String> copySelectedItemsToFavorites;

  Future<Result<void>> _copySelectedItemsToFavorites(String targetId) async {
    final result = await _userRepository.copyFavoritesVideos(
      ids: _selectedItemIds.toList(),
      sourceFavoritesId: _favorites!.favoritesId,
      targetFavoritesId: targetId,
    );
    switch (result) {
      case Ok():
        reload();
      case Error():
    }
    return result;
  }

  late final Command1<void, String> moveSelectedItemsToFavorites;

  Future<Result<void>> _moveSelectedItemsToFavorites(String targetId) async {
    final result = await _userRepository.moveFavoritesVideos(
      ids: _selectedItemIds.toList(),
      sourceFavoritesId: _favorites!.favoritesId,
      targetFavoritesId: targetId,
    );
    switch (result) {
      case Ok():
        reload();
      case Error():
    }
    return result;
  }

  late final Command0<void> deleteSelectedItems;

  Future<Result<void>> _deleteSelectedItems() async {
    final result = await _userRepository.deleteFavoritesVideos(
      favoritesId: _favorites!.favoritesId,
      ids: _selectedItemIds.toList(),
    );
    switch (result) {
      case Ok():
        reload();
      case Error():
    }
    return result;
  }

  late final Command0<void> clearInvalid;

  Future<Result<void>> _clearInvalid() async {
    final result = await _userRepository.clearInvalidInFavorites( _favorites!.favoritesId);
    switch (result) {
      case Ok():
        reload();
      case Error():
    }
    return result;
  }

  late final Command0<void> deleteFavorites;

  Future<Result<void>> _deleteFavorites() async {
    return _userRepository.deleteFavorites( _favorites!.favoritesId);
  }
}
