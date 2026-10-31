import 'dart:async';

import 'package:better_bilibili/config/account_config.dart';
import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/domain/models/bilibili/account.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';
import 'package:better_bilibili/utils/command.dart';

class AccountManagerViewModel extends SafeChangeNotifier {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  final List<StreamSubscription> _subscriptions = [];

  AccountManagerViewModel({
    required this.authRepository,
    required this.userRepository,
  }) {
    getData = Command0(_getData)..execute();
    _subscriptions.addAll([
      authRepository.stream.create.listen((_) => _onAuthRepositoryChanged()),
      authRepository.stream.remove.listen((_) => _onAuthRepositoryChanged()),
      authRepository.stream.update.listen((_) => _onAuthRepositoryChanged()),
      authRepository.stream.current.listen(_onCurrentChanged),
    ]);
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    super.dispose();
  }

  final List<Account> _accounts = [];
  List<Account> get accounts => List.unmodifiable(_accounts);

  final Map<String, String> _nicknames = {};
  final Map<String, String> _avatars = {};
  Map<String, String> get nicknames => Map.unmodifiable(_nicknames);
  Map<String, String> get avatars => Map.unmodifiable(_avatars);

  String? _currentAccount;
  String? get currentAccount => _currentAccount;

  late final Command0<List<Account>> getData;

  Future<Result<List<Account>>> _getData() async {
    final result = await authRepository.getAccounts();
    result.removeAt(0);

    _accounts.clear();
    _accounts.addAll(result);

    _currentAccount = (await authRepository.getAccount()).userId;

    for (final i in _accounts) {
      String userId = i.userId;

      if (userId == kGuestUserId) {
        continue;
      }

      final nickname = await userRepository.getLocalUserData(userId, 'nickname');
      final avatar = await userRepository.getLocalUserData(userId, 'avatar');

      if (nickname != null) {
        _nicknames[userId] = nickname;
      }
      if (avatar != null) {
        _avatars[userId] = avatar;
      }
    }

    return Result.ok(result);
  }

  void _onAuthRepositoryChanged() {
    getData.execute();
  }

  void _onCurrentChanged(String event) {
    _currentAccount = event;
    notifyListeners();
  }

  Future<void> switchAccount(String accountId) async {
    await authRepository.switchAccount(accountId);
    await getData.execute();
  }

  Future<void> removeAccount(String accountId) async {
    await authRepository.removeAccount(accountId);
    await getData.execute();
  }
}
