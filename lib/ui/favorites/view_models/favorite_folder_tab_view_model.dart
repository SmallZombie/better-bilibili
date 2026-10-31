import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class FavoritesViewModel extends SafeChangeNotifier {
  final UserRepository userRepository;
  final AuthRepository authRepository;

  FavoritesViewModel({
    required this.userRepository,
    required this.authRepository,
  }) {
    loadData = Command0(_loadData);
    delete = Command1(_delete);
    modify = Command1(_modify);
  }

  late final Command0<GetFavoritesResponse> loadData;

  final List<FavoriteFolder> _favoriteFolders = [];
  List<FavoriteFolder> get favoriteFolders => List.unmodifiable(_favoriteFolders);

  int _pn = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  void reload() {
    _favoriteFolders.clear();

    _pn = 1;
    _hasMore = true;

    loadData.execute();
  }

  Future<Result<GetFavoritesResponse>> _loadData() async {
    final account = await authRepository.getAccount();
    final result = await userRepository.getFavoritesList(userId: account.userId, pn: _pn);
    switch (result) {
      case Ok(:final value):
        _favoriteFolders.addAll(value.list);
        _pn++;
        _hasMore = value.hasMore;
      case Err():
    }

    notifyListeners();
    return result;
  }

  late final Command1<void, String> delete;

  Future<Result<void>> _delete(String favoritesId) async {
    final result = await userRepository.deleteFavorites(favoritesId);
    switch (result) {
      case Ok():
        reload();
      case Err():
    }
    return result;
  }

  late final Command1<void, ModifyFavoriteFolderOptions> modify;

  Future<Result<void>> _modify(ModifyFavoriteFolderOptions options) async {
    final result = await userRepository.modifyFavoriteFolder(
      favoritesId: options.id,
      name: options.name,
      cover: options.cover,
      description: options.description,
      isPrivate: options.isPrivate,
    );

    switch (result) {
      case Ok():
        final index = _favoriteFolders.indexWhere((v) => options.id == v.id);
        _favoriteFolders[index] = _favoriteFolders[index].copyWith(
          name: options.name,
          isPrivate: options.isPrivate,
        );
      case Err():
    }

    notifyListeners();
    return result;
  }
}

class ModifyFavoriteFolderOptions {
  final String id;
  final String name;
  final String? cover;
  final String? description;
  final bool isPrivate;

  const ModifyFavoriteFolderOptions({
    required this.id,
    required this.name,
    this.cover,
    this.description,
    required this.isPrivate,
  });
}
