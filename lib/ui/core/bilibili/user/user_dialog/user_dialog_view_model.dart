import 'package:better_bilibili/data/repositories/bilibili/user_repository.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class UserDialogViewModel extends SafeChangeNotifier {
  final UserRepository _userRepository;

  UserDialogViewModel({
    required UserRepository userRepository,
  }) : _userRepository = userRepository {
    createGroup = Command1((name) => _createGroup(name));
    modifyGroup = Command1((group) => _modifyGroup(group));
    loadGroups = Command0(_loadGroups);
  }

  late final Command1<UserGroup, String> createGroup;

  Future<Result<UserGroup>> _createGroup(String name) async {
    final result = await _userRepository.createUserGroup(name: name);
    return result;
  }

  late final Command0 loadGroups;

  final List<UserGroup> _groups = [];
  List<UserGroup> get groups => List.unmodifiable(List.from(_groups));

  Future<Result<void>> _loadGroups() async {
    final result = await _userRepository.getGroupList();
    switch (result) {
      case Ok(:final value):
        _groups.clear();
        _groups.addAll(value);
      case Error():
        return result;
    }

    notifyListeners();
    return result;
  }

  final Set<UserGroup> _selectedGroups = {};
  Set<UserGroup> get selectedGroups => Set.unmodifiable(_selectedGroups);

  void selectGroup(UserGroup group) {
    _selectedGroups.add(group);
    notifyListeners();
  }

  void unselectGroup(UserGroup group) {
    _selectedGroups.remove(group);
    notifyListeners();
  }

  void clearSelectedGroups() {
    _selectedGroups.clear();
    notifyListeners();
  }

  late final Command1<UserGroup, UserGroup> modifyGroup;

  Future<Result<UserGroup>> _modifyGroup(UserGroup group) async {
    final result = await _userRepository.modifyUserGroup(groupId: group.id, name: group.name);
    switch (result) {
      case Ok():
        return Result.ok(group);
      case Error():
        return Result.error(result.error);
    }
  }
}
