import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorite_articles_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class FavoriteArticleViewModel extends SafeChangeNotifier {
  final UserRepository userRepository;

  FavoriteArticleViewModel({required this.userRepository}) {
    loadArticles = Command0(_loadArticles);
    deleteArticle = Command1<void, String>((postId) => _deleteArticle(postId));
  }

  late final Command0<GetFavoriteArticlesResponse> loadArticles;

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

  Future<Result<GetFavoriteArticlesResponse>> _loadArticles() async {
    final result = await userRepository.getFavoriteArticles(pn: _pn);
    switch (result) {
      case Ok(:final value):
        _articles.addAll(value.list);
        _total = value.total;
      case Err():
    }

    notifyListeners();
    return result;
  }

  late final Command1<void, String> deleteArticle;

  Future<Result<void>> _deleteArticle(String postId) async {
    final result = await userRepository.deleteFavoritePost(postId);
    switch (result) {
      case Ok():
        reload();
      case Err():
    }
    return result;
  }
}
