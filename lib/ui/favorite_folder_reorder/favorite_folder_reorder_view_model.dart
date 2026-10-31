import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_simple_list_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class FavoriteFolderReorderViewModel extends SafeChangeNotifier {
  final UserRepository userRepository;
  final AuthRepository authRepository;

  FavoriteFolderReorderViewModel({
    required this.userRepository,
    required this.authRepository,
  }) {
    loadData = Command0(_loadData)..execute();
    save = Command0(_save);
  }

  late final Command0 loadData;

  List<SimpleFavorites> _favoriteFolders = [];
  List<SimpleFavorites> get favoriteFolders => List.unmodifiable(_favoriteFolders);

  Future<Result<void>> _loadData() async {
    final account = await authRepository.getAccount();
    final result = await userRepository.getFavoritesSimpleList(userId: account.userId);

    switch (result) {
      case Ok(:final value):
        _favoriteFolders = value.list;
      case Err():
    }

    notifyListeners();
    return result;
  }

  void onReorderItem(int oldIndex, int newIndex) {
    final item = _favoriteFolders.removeAt(oldIndex);
    _favoriteFolders.insert(newIndex, item);
    notifyListeners();
  }

  late final Command0 save;

  Future<Result<void>> _save() async {
    final result = await userRepository.reorderFavoriteFolder(
      ids: _favoriteFolders.map((v) => v.id).toList(),
    );
    notifyListeners();
    return result;
  }
}
