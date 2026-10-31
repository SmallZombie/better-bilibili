import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class UserDialogViewModel extends SafeChangeNotifier {
  final UserRepository userRepository;

  UserDialogViewModel({required this.userRepository}) {
    createGroup = Command1(_createGroup);
    modifyGroup = Command1(_modifyGroup);
    loadGroups = Command0(_loadGroups);
  }

  late final Command1<UserGroup, String> createGroup;

  Future<Result<UserGroup>> _createGroup(String name) async {
    final result = await userRepository.createUserGroup(name);
    return result;
  }

  late final Command0 loadGroups;

  final List<UserGroup> _groups = [];
  List<UserGroup> get groups => List.unmodifiable(List.from(_groups));

  Future<Result<void>> _loadGroups() async {
    final result = await userRepository.getGroupList();
    switch (result) {
      case Ok(:final value):
        _groups.clear();
        _groups.addAll(value);
      case Err():
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
    final result = await userRepository.modifyUserGroup(groupId: group.id, name: group.name);
    switch (result) {
      case Ok():
        return Result.ok(group);
      case Err():
        return Result.error(result.error);
    }
  }
}
