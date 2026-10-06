import 'package:better_bilibili/data/repositories/bilibili/article_repository/article_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_articles_with_user_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class UserDetailArticleViewModel extends SafeChangeNotifier {
  final ArticleRepository _articleRepository;

  final String userId;

  UserDetailArticleViewModel({
    required ArticleRepository videoRepository,
    required this.userId,
  }) : _articleRepository = videoRepository {
    loadData = Command0(_loadData)..execute();
  }

  int _selectedChipIndex = 0;
  int get selectedChipIndex => _selectedChipIndex;

  void setSelectedChipIndex(int index) {
    if (index == _selectedChipIndex) return;
    _selectedChipIndex = index;
    reload();
    notifyListeners();
  }

  late final Command0 loadData;

  int _pn = 1;
  String? _offset;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  final List<GetArticlesWithUserItem> _articles = [];
  List<GetArticlesWithUserItem> get articles => List.unmodifiable(_articles);

  Future<Result<void>> _loadData() async {
    final result = await _articleRepository.getArticlesWithUser(
      userId: userId,
      pn: _pn,
      offset: _offset,
    );
    switch (result) {
      case Ok(:final value):
        _articles.addAll(value.list);
        _pn++;
        _hasMore = value.hasMore;
        _offset = value.offset;
      case Error():
    }

    notifyListeners();
    return result;
  }

  void reload() {
    _articles.clear();
    notifyListeners();
    loadData.execute();
  }
}
