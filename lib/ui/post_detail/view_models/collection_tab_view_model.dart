import 'package:better_bilibili/data/repositories/bilibili/article_repository/article_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_article_colllection_detail_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class CollectionTabViewModel extends SafeChangeNotifier {
  final ArticleRepository articleRepository;

  final String collectionId;

  CollectionTabViewModel({
    required this.articleRepository,
    required this.collectionId,
  }) {
    loadData = Command0(_getCollection)..execute();
  }

  late final Command0<void> loadData;

  ArticleCollection? _collection;
  ArticleCollection? get collection => _collection;

  Future<Result<void>> _getCollection() async {
    final result = await articleRepository.getCollectionDetail(collectionId);
    switch (result) {
      case Ok(:final value):
        _collection = value;
      case Err():
    }

    notifyListeners();
    return result;
  }
}
