import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_simple_list_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class EditVideoInFavoriteFolderSheetViewModel extends SafeChangeNotifier {
  final UserRepository userRepository;
  final AuthRepository authRepository;

  EditVideoInFavoriteFolderSheetViewModel({required this.userRepository, required this.authRepository}) {
    getFavorites = Command1(_getFavorites);
    createFavorites = Command1(_createFavorites);
  }

  final List<SimpleFavorites> _favorites = [];
  List<SimpleFavorites> get favorites => List.unmodifiable(_favorites);

  final Set<String> _initialSelectedFavoritesIds = {};
  Set<String> get initialSelectedFavoritesIds => Set.unmodifiable(_initialSelectedFavoritesIds);

  late final Command1<GetFavoritesSimpleListResponse, String?> getFavorites;

  Future<Result<GetFavoritesSimpleListResponse>> _getFavorites(String? videoId) async {
    final account = await authRepository.getAccount();
    final result = await userRepository.getFavoritesSimpleList(userId: account.userId, videoId: videoId);
    switch (result) {
      case Ok(:final value):
        _favorites.clear();
        _favorites.addAll(value.list);
        _initialSelectedFavoritesIds
          ..clear()
          ..addAll(value.ids);
      case Err():
    }
    return result;
  }

  late final Command1<FavoriteFolder, CreateFavoritesRequest> createFavorites;

  Future<Result<FavoriteFolder>> _createFavorites(CreateFavoritesRequest favorites) async {
    return userRepository.createFavorites(
      name: favorites.name,
      description: favorites.description,
      isPrivate: favorites.isPrivate,
      cover: favorites.cover,
    );
  }

  void clear() {
    _favorites.clear();
    _initialSelectedFavoritesIds.clear();
  }
}

class CreateFavoritesRequest {
  final String name;
  final String description;
  final bool isPrivate;
  final String? cover;

  CreateFavoritesRequest({
    required this.name,
    required this.description,
    required this.isPrivate,
    required this.cover,
  });
}
