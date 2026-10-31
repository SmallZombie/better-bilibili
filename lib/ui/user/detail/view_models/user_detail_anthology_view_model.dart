import 'package:better_bilibili/data/repositories/bilibili/article_repository/article_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_anthologys_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

const _orderValues = [
  GetUserAnthologysOrderEnum.updateTimeDesc,
  GetUserAnthologysOrderEnum.viewCountDesc,
];

class UserDetailAnthologyViewModel extends SafeChangeNotifier {
  final ArticleRepository articleRepository;

  final String userId;

  UserDetailAnthologyViewModel({required this.articleRepository, required this.userId}) {
    loadData = Command0(
      _loadData,
      onSuccess: loadDataSuccess,
      onCancel: () {},
    )..execute();
  }

  int _selectedOrderIndex = 0;
  int get selectedOrderIndex => _selectedOrderIndex;
  void setSelectedOrderIndex(int newIndex) {
    if (newIndex == _selectedOrderIndex) return;

    _selectedOrderIndex = newIndex;
    notifyListeners();

    reload();
  }

  late final Command0<List<GetUserAnthologysItem>> loadData;

  final List<GetUserAnthologysItem> _anthologys = [];
  List<GetUserAnthologysItem> get anthologys => List.unmodifiable(_anthologys);

  Future<Result<List<GetUserAnthologysItem>>> _loadData() async {
    final result = await articleRepository.getUserAnthologys(
      userId: userId,
      order: _orderValues[_selectedOrderIndex],
    );
    return result;
  }

  void loadDataSuccess(List<GetUserAnthologysItem> resp) {
    _anthologys.addAll(resp);
    notifyListeners();
  }

  void reload() {
    _anthologys.clear();
    notifyListeners();

    loadData.cancel();
    loadData.execute();
  }
}
