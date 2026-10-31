import 'package:better_bilibili/data/repositories/bilibili/article_repository/article_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_recommend_article_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class ArticleHomeViewModel extends SafeChangeNotifier {
  final ArticleRepository articleRepository;

  ArticleHomeViewModel({required this.articleRepository}) {
    loadData = Command0(_getArticles)..execute();
  }

  late final Command0<List<RecommendArticle>> loadData;

  int _pn = 1;

  final List<RecommendArticle> _articles = [];
  List<RecommendArticle> get articles => List.unmodifiable(_articles);

  Future<Result<List<RecommendArticle>>> _getArticles() async {
    final result = await articleRepository.getRecommendedList(pn: _pn);
    switch (result) {
      case Ok(:final value):
        _articles.addAll(value);
        _pn++;
      case Err():
    }

    notifyListeners();
    return result;
  }
}
