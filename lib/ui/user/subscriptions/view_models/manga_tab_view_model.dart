import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_subscribed_manga.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class MangaTabViewModel extends SafeChangeNotifier {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  final String userId;

  MangaTabViewModel({
    required UserRepository userRepository,
    required AuthRepository authRepository,
    required this.userId,
  }) : _userRepository = userRepository,
       _authRepository = authRepository {
    loadData = Command0(_loadData)..execute();
    unsubscribe = Command1<void, String>((mangaId) => _unsubscribe(mangaId));
  }

  late final Command0 loadData;

  final List<SubscribedManga> _mangas = [];
  List<SubscribedManga> get mangas => List.unmodifiable(_mangas);

  int _pn = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  void reload() {
    _mangas.clear();

    _pn = 1;
    _hasMore = true;

    loadData.execute();
  }

  Future<Result<void>> _loadData() async {
    if (userId != (await _authRepository.getAccount()).userId) {
      return Result.ok(null);
    }

    final result = await _userRepository.getSubscribedManga(pn: _pn);
    switch (result) {
      case Ok(:final value):
        _mangas.addAll(value.list);
        _pn++;
        _hasMore = value.hasMore;
      case Error():
    }
    return result;
  }

  late final Command1<void, String> unsubscribe;

  Future<Result<void>> _unsubscribe(String mangaId) async {
    final result = await _userRepository.unsubscribeManga(mangaIds: [mangaId]);
    switch (result) {
      case Ok():
        _mangas.removeWhere((v) => v.id == mangaId);
        notifyListeners();
      case Error():
    }
    return result;
  }
}
