import 'package:better_bilibili/data/repositories/bilibili/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_subscribed_playlists_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

const ps = 50;

class PlaylistTabViewModel extends SafeChangeNotifier {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  final String userId;

  PlaylistTabViewModel({
    required UserRepository userRepository,
    required AuthRepository authRepository,
    required this.userId,
  }) : _userRepository = userRepository,
       _authRepository = authRepository {
    loadData = Command0(_loadData)..execute();
    unsubscribe = Command1<void, dynamic>((item) => _unsubscribe(item));
  }

  late final Command0<void> loadData;

  final List<dynamic> _playlists = [];
  List<dynamic> get playlists => List.unmodifiable(_playlists);

  int _pn = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  bool? _isCurrentUser;
  bool get isCurrentUser => _isCurrentUser ?? false;

  Future<Result<void>> _loadData() async {
    final result = await _userRepository.getSubscribedPlaylists(
      userId: userId,
      pn: _pn,
      ps: ps,
    );
    switch (result) {
      case Ok(:final value):
        _playlists.addAll(value.list);
        _pn++;
        _hasMore = value.hasMore;
      case Error():
    }
    _isCurrentUser ??= userId == (await _authRepository.getAccount()).uid;
    return result;
  }

  void reload() {
    _playlists.clear();

    _pn = 1;
    _hasMore = true;

    loadData.execute();
  }

  late final Command1<void, dynamic> unsubscribe;

  Future<Result<void>> _unsubscribe(dynamic item) async {
    final result = switch (item) {
      SubscribedFavorites() => _userRepository.unsubscribeFavorites(favoritesId: item.id),
      SubscribedPlaylist() => _userRepository.unsubscribePlaylist(playlistId: item.id),
      _ => throw Exception('Unknown item: $item'),
    };

    switch (await result) {
      case Ok():
        reload();
      case Error():
    }

    return result;
  }
}
