import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class FavoritesTabViewModel extends SafeChangeNotifier {
  final UserRepository userRepository;
  final AuthRepository authRepository;

  FavoritesTabViewModel({required this.userRepository, required this.authRepository}) {
    loadFavorites = Command0(_loadFavorites);
    deleteFavorites = Command1<void, String>((favoritesId) => _deleteFavorites(favoritesId));
  }

  bool get showEmpty => !loadFavorites.running && !loadFavorites.error && _favorites.isEmpty;

  late final Command0<void> loadFavorites;

  final List<Favorites> _favorites = [];
  List<Favorites> get favorites => List.unmodifiable(_favorites);

  int _pn = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  void reload() {
    _favorites.clear();

    _pn = 1;
    _hasMore = true;

    loadFavorites.execute();
  }

  Future<Result<void>> _loadFavorites() async {
    final account = await authRepository.getAccount();
    final result = await userRepository.getFavoritesList(userId:account.userId, pn: _pn);
    switch (result) {
      case Ok(:final value):
        _favorites.addAll(value.list);
        _pn++;
        _hasMore = value.hasMore;
      case Error():
    }
    return result;
  }

  late final Command1<void, String> deleteFavorites;

  Future<Result<void>> _deleteFavorites(String favoritesId) async {
    final result = await userRepository.deleteFavorites( favoritesId);
    switch (result) {
      case Ok():
        reload();
      case Error():
    }
    return result;
  }
}
