import 'dart:async';

import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/chat_repository/chat_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:material_ui/material_ui.dart';

class BiliBackgroundService extends ChangeNotifier {
  final UserRepository userRepository;
  final AuthRepository authRepository;
  final ChatRepository chatRepository;

  late final StreamSubscription _accountChangeSubscription;

  BiliBackgroundService({
    required this.userRepository,
    required this.authRepository,
    required this.chatRepository,
  }) {
    _startUnreadNotificationTimer();
    getUnreadChatCount();
    _startUnreadPostTimer();
    _getUnreadNotificationCount();
    _getUnreadPostCount();

    _accountChangeSubscription = authRepository.stream.current.listen(_onAccountChanged);
  }

  @override
  void dispose() {
    _stopUnreadNotificationTimer();
    _stopUnreadPostTimer();

    _accountChangeSubscription.cancel();

    super.dispose();
  }

  Timer? _unreadNotificationTimer;
  int _unreadNotificationCount = 0;
  int get unreadNotificationCount => _unreadNotificationCount;

  void _getUnreadNotificationCount() {
    _unreadNotificationCount = 0;
    notifyListeners();
  }

  void _startUnreadNotificationTimer() {
    _unreadNotificationTimer = Timer.periodic(const Duration(seconds: 30), (timer) => _getUnreadNotificationCount());
  }

  void _stopUnreadNotificationTimer() {
    _unreadNotificationTimer?.cancel();
    _unreadNotificationTimer = null;
  }

  void clearUnreadNotificationCount() {
    _unreadNotificationCount = 0;
    notifyListeners();
  }

  int _unreadChatCount = 0;
  int get unreadChatCount => _unreadChatCount;

  Future<void> getUnreadChatCount() async {
    final result = await chatRepository.getUnreadCount();
    switch (result) {
      case Ok(:final value):
        _unreadChatCount = value.followed + value.notFollowed;
      case Err():
    }

    notifyListeners();
  }

  void clearUnreadChatCount() {
    _unreadChatCount = 0;
    notifyListeners();
  }

  Timer? _unreadPostTimer;
  int _unreadPostCount = 0;
  int get unreadPostCount => _unreadPostCount;

  Future<void> _getUnreadPostCount() async {
    final result = await userRepository.getUnreadPostCount();
    switch (result) {
      case Ok(:final value):
        _unreadPostCount = value;
      case Err():
    }

    notifyListeners();
  }

  void _startUnreadPostTimer() {
    _unreadPostTimer = Timer.periodic(const Duration(seconds: 30), (timer) => _getUnreadPostCount());
  }

  void _stopUnreadPostTimer() {
    _unreadPostTimer?.cancel();
    _unreadPostTimer = null;
  }

  void clearUnreadPostCount() {
    _unreadPostCount = 0;
    notifyListeners();
  }

  void _onAccountChanged(String event) {
    _getUnreadNotificationCount();
    getUnreadChatCount();
    _getUnreadPostCount();
  }
}
