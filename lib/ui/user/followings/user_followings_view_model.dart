import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_following_users.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_stats_response.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/ui/core/bilibili/user/user_dialog/user_dialog_view_model.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

const _orderValues = <GetFollowingUsersOrderEnum>[
  GetFollowingUsersOrderEnum.followTimeAsc,
  GetFollowingUsersOrderEnum.followTimeDesc,
  GetFollowingUsersOrderEnum.viewTimeAsc,
  GetFollowingUsersOrderEnum.viewTimeDesc,
];

class UserFollowingsViewModel extends SafeChangeNotifier {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final UserDialogViewModel _userDialogViewModel;

  final String userId;

  UserFollowingsViewModel({
    required UserRepository userRepository,
    required AuthRepository authRepository,
    required UserDialogViewModel userDialogViewModel,
    required this.userId,
  }) : _userRepository = userRepository,
       _authRepository = authRepository,
       _userDialogViewModel = userDialogViewModel {
    loadData = Command0(_loadData)..execute();
    loadGroups = Command0(_loadGroups)..execute();
    loadStats = Command0(_loadStats)..execute();
    deleteGroup = Command1((index) => _deleteGroup(index));
    addSelectedItemsToGroup = Command1((groups) => _addSelectedItemsToGroup(groups));

    _userDialogViewModel.createGroup.addListener(_onCreateGroupResult);
    _userDialogViewModel.modifyGroup.addListener(_onModifyGroupResult);
  }

  @override
  void dispose() {
    _userDialogViewModel.createGroup.removeListener(_onCreateGroupResult);
    _userDialogViewModel.modifyGroup.removeListener(_onModifyGroupResult);

    super.dispose();
  }

  late final Command0<void> loadData;

  int _pn = 1;
  int get pn => _pn;
  void setPn(int pn) {
    _pn = pn;
    reload();
  }

  String? _keyword;
  String? get keyword => _keyword;
  void setKeyword(String? keyword) {
    if (keyword == _keyword) return;
    _keyword = keyword;
    _pn = 1;
    reload();
  }

  bool _isCurrentUser = false;
  bool get isCurrentUser => _isCurrentUser;

  final List<FollowingUser> _users = [];
  List<FollowingUser> get users => List.unmodifiable(_users);

  int _total = 0;
  int get total => _total;

  Future<Result<void>> _loadData() async {
    if (_selectedGroupIndex != 0) {
      final result = await _userRepository.getUsersInGroup(
        groupId: _groups[_selectedGroupIndex].id,
        pn: _pn,
      );
      switch (result) {
        case Ok(:final value):
          _users.addAll(value);
          _total = _groups[_selectedGroupIndex].count;
        case Error():
          return result;
      }
    } else if (_keyword == null) {
      final result = await _userRepository.getFollowingUsers(
        userId: userId,
        pn: _pn,
        order: _orderValues[_selectedOrderIndex],
      );
      switch (result) {
        case Ok(:final value):
          _users.addAll(value.list);
          _total = value.total;
        case Error():
          return result;
      }
    } else {
      final result = await _userRepository.getFollowingUsersWithKeyword(
        keyword: _keyword!,
        pn: _pn,
      );
      switch (result) {
        case Ok(:final value):
          _users.addAll(value.list);
          _total = value.total;
          _isCurrentUser = userId == (await _authRepository.getAccount()).userId;
        case Error():
          return result;
      }
    }

    notifyListeners();
    return Result.ok(null);
  }

  late final Command0<void> loadGroups;

  int _selectedGroupIndex = 0;
  int get selectedGroupIndex => _selectedGroupIndex;
  void setSelectedGroupIndex(int index) {
    if (index == _selectedGroupIndex) return;
    _selectedGroupIndex = index;
    _pn = 1;
    notifyListeners();
    reload();
  }

  final List<UserGroup> _groups = [];
  List<UserGroup> get groups => List.unmodifiable(List.from(_groups));

  Future<Result<void>> _loadGroups() async {
    if (userId != (await _authRepository.getAccount()).userId) {
      return Result.ok(null);
    }

    final result = await _userRepository.getGroupList();
    switch (result) {
      case Ok(:final value):
        _groups.addAll(value);
        _groups.insert(
          0,
          UserGroup(
            id: '-1',
            name: '全部',
            count: _stats?.following ?? 0,
          ),
        );
        _groups.insert(
          2,
          UserGroup(
            id: '-20',
            name: '悄悄关注',
            count: _stats?.secretFollowing ?? 0,
          ),
        );
      case Error():
    }

    notifyListeners();
    return result;
  }

  late final Command0 loadStats;

  GetUserStatsResponse? _stats;
  GetUserStatsResponse? get stats => _stats;

  Future<Result<void>> _loadStats() async {
    final result = await _userRepository.getUserStats(userId: userId);
    switch (result) {
      case Ok(:final value):
        _stats = value;
        if (_groups.isNotEmpty) {
          _groups[0] = _groups[0].copyWith(count: value.following);
          _groups[2] = _groups[2].copyWith(count: value.secretFollowing);
        }
      case Error():
    }

    notifyListeners();
    return result;
  }

  void reload() {
    _users.clear();
    notifyListeners();
    loadData.execute();
    loadStats.execute();
  }

  final Set<FollowingUser> _selectedUsers = {};
  Set<FollowingUser> get selectedUsers => Set.unmodifiable(_selectedUsers);

  void toggleItemSelection(FollowingUser user) {
    _selectedUsers.contains(user) ? _selectedUsers.remove(user) : _selectedUsers.add(user);
    notifyListeners();
  }

  void selectAll() {
    _selectedUsers.clear();
    _selectedUsers.addAll(_users);
    notifyListeners();
  }

  void deselectAll() {
    _selectedUsers.clear();
    notifyListeners();
  }

  void invertSelection() {
    for (final user in _users) {
      if (_selectedUsers.contains(user)) {
        _selectedUsers.remove(user);
      } else {
        _selectedUsers.add(user);
      }
    }
    notifyListeners();
  }

  void clearSelectedItems() {
    _selectedUsers.clear();
    notifyListeners();
  }

  int _selectedOrderIndex = 1;
  int get selectedOrderIndex => _selectedOrderIndex;
  void setSelectedOrderIndex(int index) {
    _selectedOrderIndex = index;
    notifyListeners();
  }

  int _snapshotFiltersState = 1;

  int _getFiltersState() => _selectedOrderIndex;

  void rememberFiltersState() {
    _snapshotFiltersState = _getFiltersState();
  }

  void onFilterSheetDismissed() {
    if (_getFiltersState() != _snapshotFiltersState) {
      _pn = 1;
      reload();
    }
  }

  void _onCreateGroupResult() {
    if (_userDialogViewModel.createGroup.completed) {
      switch (_userDialogViewModel.createGroup.result!) {
        case Ok(:final value):
          _groups.add(value);
          notifyListeners();
        case Error():
      }
    }
  }

  void _onModifyGroupResult() {
    if (_userDialogViewModel.modifyGroup.completed) {
      switch (_userDialogViewModel.modifyGroup.result!) {
        case Ok(:final value):
          final index = _groups.indexWhere((element) => element.id == value.id);
          if (index != -1) {
            _groups[index] = value;
            notifyListeners();
          }
        case Error():
      }
    }
  }

  late final Command1<void, int> deleteGroup;

  Future<Result<void>> _deleteGroup(int index) async {
    final group = _groups[index];
    final result = await _userRepository.deleteUserGroup(groupId: group.id);
    switch (result) {
      case Ok():
        _groups.removeAt(index);
        setSelectedGroupIndex(0);
      case Error():
    }

    notifyListeners();
    return result;
  }

  late final Command1<void, List<UserGroup>> addSelectedItemsToGroup;

  Future<Result<void>> _addSelectedItemsToGroup(List<UserGroup> groups) async {
    final result = await _userRepository.setUsersToGroups(
      userIds: _selectedUsers.map((e) => e.id).toList(),
      groupIds: groups.map((e) => e.id).toList(),
    );
    switch (result) {
      case Ok():
        reload();
      case Error():
    }

    notifyListeners();
    return result;
  }

  bool _multiSelectMode = false;
  bool get multiSelectMode => _multiSelectMode;
  void setMultiSelectMode(bool value) {
    if (value == _multiSelectMode) return;
    _multiSelectMode = value;
    notifyListeners();
  }
}
