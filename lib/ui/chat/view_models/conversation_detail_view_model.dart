import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/chat_repository/chat_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/video_repository/video_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_video_cards.dart';
import 'package:better_bilibili/domain/models/bilibili/chat.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:flutter/material.dart';

class ConversationDetailViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ChatRepository _chatRepository;
  final UserRepository _userRepository;
  final VideoRepository _videoRepository;

  final String conversationId;

  ConversationDetailViewModel({
    required AuthRepository authRepository,
    required ChatRepository chatRepository,
    required this.conversationId,
    required UserRepository userRepository,
    required VideoRepository videoRepository,
  }) : _videoRepository = videoRepository,
       _userRepository = userRepository,
       _chatRepository = chatRepository,
       _authRepository = authRepository,
       _headerInfo = HeaderInfo(
         userId: conversationId,
         nickname: '...',
         avatar: kDefaultUserAvatar,
         description: '',
       ) {
    init = Command0(_init)..execute();
    loadMore = Command0(_loadMore);
  }

  late Command0 init;

  late final User _currentUser;
  User get currentUser => _currentUser;

  HeaderInfo _headerInfo;
  HeaderInfo get headerInfo => _headerInfo;

  Future<Result<void>> _init() async {
    final account = await _authRepository.getAccount();
    _currentUser = User(
      id: account.userId,
      nickname: '',
      avatar: '',
    );

    final result = await _userRepository.getUserCard(conversationId);
    switch (result) {
      case Ok(:final value):
        _headerInfo = HeaderInfo(
          userId: value.id,
          nickname: value.nickname,
          avatar: value.avatar,
          description: value.description,
        );
      case Error(:final error):
        return Result.error(error);
    }

    await loadMore.execute();
    return Result.ok(null);
  }

  late final Command0 loadMore;

  final List<BaseMessage> _data = [];
  List<BaseMessage> get data => List.unmodifiable(_data);

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  Future<Result<void>> _loadMore() async {
    final result = await _chatRepository.getMessages(conversationId: conversationId, messageId: _data.lastOrNull?.id);

    switch (result) {
      case Ok(:final value):
        _hasMore = value.hasMore;
        _data.addAll(value.list);
      case Error():
    }

    notifyListeners();

    getAllCardInfoIfNeeded();
    return result;
  }

  void reload() {
    _hasMore = true;
    _data.clear();
    loadMore.execute();
  }

  void appendMessage(BaseMessage message) {
    _data.add(message);
    notifyListeners();
  }

  final Map<String, GetVideoCardsItem> _videoInfoMap = {};
  Map<String, GetVideoCardsItem> get videoInfoMap => Map.unmodifiable(_videoInfoMap);

  final Map<String, VideoInfoLoadState> _getVideoInfoStateMap = {};

  Future<void> getAllCardInfoIfNeeded() async {
    final List<String> videoIds = [];
    for (final i in _data) {
      if (i is! VideoShareMessage) {
        continue;
      }

      if (_videoInfoMap.containsKey(i.id)) {
        continue;
      }

      final state = _getVideoInfoStateMap[i.id];
      if (state == .pending) {
        continue;
      }

      videoIds.add(i.videoId);
    }

    if (videoIds.isEmpty) {
      return;
    }

    for (final i in videoIds) {
      _getVideoInfoStateMap[i] = .pending;
    }

    final result = await _videoRepository.getVideoCards(videoIds);
    switch (result) {
      case Ok(:final value):
        for (final i in value.entries) {
          _getVideoInfoStateMap.remove(i.key);
          _videoInfoMap[i.key] = i.value;
        }
      case Error():
        for (final i in videoIds) {
          _getVideoInfoStateMap[i] = .failed;
        }
    }

    notifyListeners();
  }
}

class HeaderInfo {
  final String userId;
  final String nickname;
  final String avatar;
  final String description;

  const HeaderInfo({
    required this.userId,
    required this.nickname,
    required this.avatar,
    required this.description,
  });
}

enum VideoInfoLoadState {
  pending,
  failed,
}
