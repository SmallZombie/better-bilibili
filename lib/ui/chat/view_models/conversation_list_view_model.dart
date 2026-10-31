import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/chat_repository/chat_repository.dart';
import 'package:better_bilibili/domain/models/bilibili/chat.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:material_ui/material_ui.dart';

class ConversationListViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  final ChatRepository chatRepository;

  ConversationListViewModel({
    required this.authRepository,
    required this.chatRepository,
  }) {
    init = Command0(_init)..execute();
    loadMore = Command0(_loadMore);
  }

  late Command0 init;

  String currentUserId = '';

  Future<Result<void>> _init() async {
    final account = await authRepository.getAccount();
    currentUserId = account.userId;

    await loadMore.execute();
    return Result.ok(null);
  }

  late Command0 loadMore;

  final List<Conversation> _data = [];
  List<Conversation> get data => List.unmodifiable(_data);
  String? _nextCursur;

  Future<Result<void>> _loadMore() async {
    final result = await chatRepository.getConversationList(
      type: .userAndSystem,
      foldGroup: true,
      foldNotFollowed: true,
      nextCursor: _nextCursur,
    );

    switch (result) {
      case Ok(:final value):
        _data.addAll(value.data.where((v) => v.type == .user));
        _nextCursur = value.nextCursor;
      case Err():
    }

    notifyListeners();
    return result;
  }

  void reload() {
    _data.clear();
    _nextCursur = null;

    loadMore.execute();

    notifyListeners();
  }
}
