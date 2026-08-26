import 'package:better_bilibili/data/repositories/bilibili/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorite_articles_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class FavoriteArticleViewModel extends SafeChangeNotifier {
  final UserRepository _userRepository;

  FavoriteArticleViewModel({
    required UserRepository userRepository,
  }) : _userRepository = userRepository {
    loadArticles = Command0(_loadArticles);
    deleteItem = Command1<void, String>((postId) => _deleteItem(postId));
  }

  late final Command0<void> loadArticles;

  int _pn = 1;
  int get pn => _pn;
  void setPn(int pn) {
    _pn = pn;
    reload();
  }

  final List<FavoriteArticle> _articles = [];
  List<FavoriteArticle> get articles => List.unmodifiable(_articles);

  int _total = 0;
  int get total => _total;

  void reload() {
    _articles.clear();
    _total = 0;
    loadArticles.execute();
  }

  Future<Result<void>> _loadArticles() async {
    final result = await _userRepository.getFavoriteArticles(pn: _pn);
    switch (result) {
      case Ok(:final value):
        _articles.addAll(value.list);
        _total = value.total;
      case Error():
    }

    notifyListeners();
    return result;
  }

  late final Command1<void, String> deleteItem;

  Future<Result<void>> _deleteItem(String postId) async {
    final result = await _userRepository.deleteFavoritePost(postId: postId);
    switch (result) {
      case Ok():
        reload();
      case Error():
    }
    return result;
  }
}
