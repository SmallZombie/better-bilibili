import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_detail_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

const _orderOptions = [
  GetFavoritesDetailOrderEnum.favoriteTimeDesc,
  GetFavoritesDetailOrderEnum.viewDesc,
  GetFavoritesDetailOrderEnum.releaseTimeDesc,
];

class FavoriteFolderDetailViewModel extends SafeChangeNotifier {
  final String favoriteFolderId;
  final UserRepository userRepository;

  FavoriteFolderDetailViewModel({
    required this.favoriteFolderId,
    required this.userRepository,
  }) {
    loadData = Command1<void, String>((favoritesId) => _loadData(favoritesId))..execute(favoriteFolderId);
    copySelectedItemsToFavorites = Command1<void, String>((targetId) => _copySelectedItemsToFavorites(targetId));
    moveSelectedItemsToFavorites = Command1<void, String>((targetId) => _moveSelectedItemsToFavorites(targetId));
    deleteSelectedItems = Command0(_deleteSelectedItems);
    clearInvalid = Command0(_clearInvalid);
    deleteFavorites = Command0(_deleteFavorites);
  }

  late final Command1<void, String> loadData;

  GetFavoritesDetailResponse? _data;
  GetFavoritesDetailResponse? get data => _data;
  List<dynamic> get items => List.unmodifiable(_data?.list ?? []);

  int _pn = 1;
  int get pn => _pn;
  void setPn(int pn) {
    if (pn == _pn) return;
    _pn = pn;
    reSearch();
  }

  String _keyword = '';
  String get keyword => _keyword;
  void setKeyword(String keyword) {
    if (keyword == _keyword) return;
    _keyword = keyword;
    reset();
  }

  int _selectedOrderIndex = 0;
  int get selectedOrderIndex => _selectedOrderIndex;
  void setSelectedOrderIndex(int index) {
    _selectedOrderIndex = index;
    reset();
  }

  int _total = 0;
  int get total => _total;

  Future<Result<void>> _loadData(String favoritesId) async {
    final result = await userRepository.getFavoritesDetail(
      favoritesId: favoritesId,
      pn: _pn,
      keyword: _keyword,
      order: _orderOptions[selectedOrderIndex],
    );
    switch (result) {
      case Ok(:final value):
        _data = value;
        if (_pn == 1 && keyword.isEmpty) {
          _total = value.total;
        }
      case Err():
    }
    return result;
  }

  void reset() {
    _data = null;
    _pn = 1;
    reSearch();
  }

  void reSearch() {
    loadData.execute(favoriteFolderId);
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
    if (_data == null) {
      return;
    }

    final list = _data!.list;
    _selectedItemIds.clear();
    _selectedItemIds.addAll(list.map((e) => getItemId(e)));
    notifyListeners();
  }

  void deselectAll() {
    _selectedItemIds.clear();
    notifyListeners();
  }

  void invertSelection() {
    if (_data == null) {
      return;
    }

    final list = _data!.list;
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
    final result = await userRepository.copyFavoritesVideos(
      ids: _selectedItemIds.toList(),
      sourceFavoritesId: _data!.favoritesId,
      targetFavoritesId: targetId,
    );
    switch (result) {
      case Ok():
        reset();
      case Err():
    }
    return result;
  }

  late final Command1<void, String> moveSelectedItemsToFavorites;

  Future<Result<void>> _moveSelectedItemsToFavorites(String targetId) async {
    final result = await userRepository.moveFavoritesVideos(
      ids: _selectedItemIds.toList(),
      sourceFavoritesId: _data!.favoritesId,
      targetFavoritesId: targetId,
    );
    switch (result) {
      case Ok():
        reset();
      case Err():
    }
    return result;
  }

  late final Command0<void> deleteSelectedItems;

  Future<Result<void>> _deleteSelectedItems() async {
    final result = await userRepository.deleteFavoritesVideos(
      favoritesId: _data!.favoritesId,
      ids: _selectedItemIds.toList(),
    );
    switch (result) {
      case Ok():
        reset();
      case Err():
    }
    return result;
  }

  late final Command0<void> clearInvalid;

  Future<Result<void>> _clearInvalid() async {
    final result = await userRepository.clearInvalidInFavorites(_data!.favoritesId);
    switch (result) {
      case Ok():
        reset();
      case Err():
    }
    return result;
  }

  late final Command0<void> deleteFavorites;

  Future<Result<void>> _deleteFavorites() async {
    return userRepository.deleteFavorites(_data!.favoritesId);
  }
}
