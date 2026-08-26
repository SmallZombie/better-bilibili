import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';
import 'package:better_bilibili/config/account_config.dart';
import 'package:better_bilibili/data/repositories/bilibili/auth_repository.dart';
import 'package:better_bilibili/utils/command.dart';

class AccountManagerViewModel extends SafeChangeNotifier {
  final AuthRepository _authRepository;

  AccountManagerViewModel({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository {
    loadAccounts = Command0(_loadAccounts)..execute();
    _authRepository.addListener(_onAuthRepositoryChanged);
  }

  @override
  void dispose() {
    _authRepository.removeListener(_onAuthRepositoryChanged);

    super.dispose();
  }

  void _onAuthRepositoryChanged() {
    loadAccounts.execute();
  }

  final List<AccountData> _accounts = [];
  AccountData? _currentAccount;
  AccountData? get currentAccount => _currentAccount;
  List<AccountData> get accounts => List.unmodifiable(_accounts);

  late final Command0<List<AccountData>> loadAccounts;
  Future<Result<List<AccountData>>> _loadAccounts() async {
    final result = await _authRepository.getAccounts();
    result.removeAt(0);

    _accounts.clear();
    _accounts.addAll(result);

    _currentAccount = await _authRepository.getAccount();

    return Result.ok(result);
  }

  Future<void> switchAccount(String accountId) async {
    await _authRepository.switchAccount(accountId);
    loadAccounts.execute();
  }

  Future<void> removeAccount(String accountId) async {
    await _authRepository.removeAccount(accountId);
    loadAccounts.execute();
  }
}
