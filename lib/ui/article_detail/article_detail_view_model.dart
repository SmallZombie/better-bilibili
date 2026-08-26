import 'package:better_bilibili/data/repositories/bilibili/article_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_article_detail_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class ArticleDetailViewModel extends SafeChangeNotifier {
  final ArticleRepository _articleRepository;

  String articleId;

  ArticleDetailViewModel({
    required ArticleRepository articleRepository,
    required this.articleId,
  }) : _articleRepository = articleRepository {
    loadData = Command0(_loadData)..execute();
  }

  late final Command0<ArticleDetail> loadData;

  ArticleDetail? _articleDetail;
  ArticleDetail? get articleDetail => _articleDetail;

  Future<Result<ArticleDetail>> _loadData() async {
    final result = await _articleRepository.getDetail(articleId: articleId);
    switch (result) {
      case Ok(:final value):
        _articleDetail = value;
      case Error():
    }

    notifyListeners();
    return result;
  }
}
