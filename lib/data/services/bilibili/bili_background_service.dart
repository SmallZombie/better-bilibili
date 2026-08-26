import 'dart:async';

import 'package:better_bilibili/data/repositories/bilibili/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/chat_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:flutter/material.dart';

class BiliBackgroundService extends ChangeNotifier {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final ChatRepository _chatRepository;

  BiliBackgroundService({
    required UserRepository userRepository,
    required AuthRepository authRepository,
    required ChatRepository chatRepository,
  }) : _userRepository = userRepository,
       _authRepository = authRepository,
       _chatRepository = chatRepository {
    _startUnreadNotificationTimer();
    getUnreadChatCount();
    _startUnreadPostTimer();
    _getUnreadNotificationCount();
    _getUnreadPostCount();

    _authRepository.addListener(_onAuthRepositoryChanged);
  }

  @override
  void dispose() {
    _stopUnreadNotificationTimer();
    _stopUnreadPostTimer();

    _authRepository.removeListener(_onAuthRepositoryChanged);

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
    final result = await _chatRepository.getUnreadCount();
    switch (result) {
      case Ok(:final value):
        _unreadChatCount = value.followed + value.notFollowed;
      case Error():
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
    final result = await _userRepository.getUnreadPostCount();
    switch (result) {
      case Ok(:final value):
        _unreadPostCount = value;
      case Error():
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

  void _onAuthRepositoryChanged() {
    _getUnreadNotificationCount();
    getUnreadChatCount();
    _getUnreadPostCount();
  }
}
