import 'package:better_bilibili/config/account_config.dart';
import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/domain/models/bilibili/account.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';
import 'package:better_bilibili/utils/command.dart';

class AccountManagerViewModel extends SafeChangeNotifier {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AccountManagerViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository {
    getData = Command0(_getData)..execute();
    _authRepository.addListener(_onAuthRepositoryChanged);
  }

  @override
  void dispose() {
    _authRepository.removeListener(_onAuthRepositoryChanged);

    super.dispose();
  }

  void _onAuthRepositoryChanged() {
    getData.execute();
  }

  final List<Account> _accounts = [];
  List<Account> get accounts => List.unmodifiable(_accounts);

  final Map<String, String> _nicknames = {};
  final Map<String, String> _avatars = {};
  Map<String, String> get nicknames => Map.unmodifiable(_nicknames);
  Map<String, String> get avatars => Map.unmodifiable(_avatars);

  Account? _currentAccount;
  Account? get currentAccount => _currentAccount;

  late final Command0<List<Account>> getData;
  Future<Result<List<Account>>> _getData() async {
    final result = await _authRepository.getAccounts();
    result.removeAt(0);

    _accounts.clear();
    _accounts.addAll(result);

    _currentAccount = await _authRepository.getAccount();

    for (final i in _accounts) {
      String userId = i.userId;

      if (userId == kGuestUserId) {
        continue;
      }

      final nickname = await _userRepository.getLocalUserData(userId, 'nickname');
      final avatar = await _userRepository.getLocalUserData(userId, 'avatar');

      if (nickname != null) {
        _nicknames[userId] = nickname;
      }
      if (avatar != null) {
        _avatars[userId] = avatar;
      }
    }

    return Result.ok(result);
  }

  Future<void> switchAccount(String accountId) async {
    await _authRepository.switchAccount(accountId);
    getData.execute();
  }

  Future<void> removeAccount(String accountId) async {
    await _authRepository.removeAccount(accountId);
    getData.execute();
  }
}
