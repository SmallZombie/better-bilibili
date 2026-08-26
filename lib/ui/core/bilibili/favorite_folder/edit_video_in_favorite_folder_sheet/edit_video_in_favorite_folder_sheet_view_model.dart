import 'package:better_bilibili/data/repositories/bilibili/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_simple_list_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class EditVideoInFavoriteFolderSheetViewModel extends SafeChangeNotifier {
  final UserRepository _userRepository;

  EditVideoInFavoriteFolderSheetViewModel({
    required UserRepository userRepository,
  }) : _userRepository = userRepository {
    getFavorites = Command1<void, String?>((videoId) => _getFavorites(videoId));
    createFavorites = Command1<void, CreateFavoritesRequest>((favorites) => _createFavorites(favorites));
  }

  final List<SimpleFavorites> _favorites = [];
  List<SimpleFavorites> get favorites => List.unmodifiable(_favorites);
  final Set<String> _initialSelectedFavoritesIds = {};
  Set<String> get initialSelectedFavoritesIds => Set.unmodifiable(_initialSelectedFavoritesIds);

  late final Command1<void, String?> getFavorites;

  Future<Result<void>> _getFavorites(String? videoId) async {
    final result = await _userRepository.getFavoritesSimpleList(videoId: videoId);
    switch (result) {
      case Ok(:final value):
        _favorites.clear();
        _favorites.addAll(value.list);
        _initialSelectedFavoritesIds
          ..clear()
          ..addAll(value.ids);
      case Error():
    }
    return result;
  }

  late final Command1<void, CreateFavoritesRequest> createFavorites;

  Future<Result<Favorites>> _createFavorites(CreateFavoritesRequest favorites) async {
    return _userRepository.createFavorites(
      name: favorites.name,
      description: favorites.description,
      isPrivate: favorites.isPrivate,
      coverUrl: favorites.coverUrl,
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
  final String? coverUrl;

  CreateFavoritesRequest({
    required this.name,
    required this.description,
    required this.isPrivate,
    required this.coverUrl,
  });
}
