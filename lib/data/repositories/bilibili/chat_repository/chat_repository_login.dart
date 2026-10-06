import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/chat_repository/chat_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/model/get_conversation_list_result.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/bili_chat_web_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_conversation.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_conversation_response.dart' as conversation_response;
import 'package:better_bilibili/data/services/bilibili/model/get_messages_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_unread_count_response.dart';
import 'package:better_bilibili/domain/models/bilibili/chat.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/utils/result.dart';

class ChatRepositoryLogin implements ChatRepository {
  final AuthRepository authRepository;
  late final BiliChatWebApiService chatApiService = BiliChatWebApiService(
    getClient: () => authRepository.getClient(type: .web),
    getAccount: authRepository.getAccount,
  );
  final UserRepository userRepository;

  ChatRepositoryLogin({required this.authRepository, required this.userRepository});

  @override
  Future<Result<GetUnreadCountResponse>> getUnreadCount() {
    return chatApiService.getUnreadCount();
  }

  @override
  Future<Result<GetConversationListResult>> getConversationList({
    required ConversationListType type,
    int? limit,
    required bool foldGroup,
    required bool foldNotFollowed,
    String? nextCursor,
  }) async {
    final result1 = await chatApiService.getConversationList(
      type: type,
      limit: limit,
      foldGroup: foldGroup,
      foldNotFollowed: foldNotFollowed,
      nextCursor: nextCursor,
    );

    late final conversation_response.GetConversationResponse data1;
    switch (result1) {
      case Ok(:final value):
        data1 = value;
        data1.data.sort((a, b) => b.unreadCount - a.unreadCount);
      case Error(:final error):
        return Result.error(error);
    }

    final List<String> userIds = [];
    for (final i in data1.data) {
      if (i.type == .user) userIds.add(i.id);
    }

    final result2 = await userRepository.getUserCards(userIds);

    late final Map<String, User> data2;
    switch (result2) {
      case Ok(:final value):
        data2 = value;
      case Error(:final error):
        return Result.error(error);
    }

    final List<Conversation> result = [];
    for (final i in data1.data) {
      if (i.type == .user) {
        result.add(Conversation.assembly(i, data2[i.id]));
      } else {
        result.add(Conversation.assembly(i, data1.systemUsers[i.id]));
      }
    }

    return Result.ok(
      GetConversationListResult(
        nextCursor: data1.nextCursor,
        data: data1.data.map((v) {
          return Conversation.assembly(v, data2[v.id]);
        }).toList(),
      ),
    );
  }

  @override
  Future<Result<GetMessagesResponse>> getMessages({
    required String conversationId,
    String? messageId,
  }) async {
    final result1 = await chatApiService.getMessages(conversationId: conversationId, messageId: messageId);
    late final GetMessagesResponse data1;
    switch (result1) {
      case Ok(:final value):
        data1 = value;
      case Error(:final error):
        return Result.error(error);
    }

    final Set<String> userIds = {};
    for (final i in data1.list) {
      if (i is MessageWithSender) {
        userIds.add(i.sender.id);
      }
    }

    final result2 = await userRepository.getUserCards(userIds.toList());
    late final Map<String, User> data2;
    switch (result2) {
      case Ok(:final value):
        data2 = value;
      case Error(:final error):
        return Result.error(error);
    }

    final List<BaseMessage> result = [];
    for (final i in data1.list) {
      if (i is MessageWithSender) {
        final user = data2[i.sender.id]!;
        result.add(
          i.copyWithSender(
            User(
              id: user.id,
              nickname: user.nickname,
              avatar: user.avatar,
            ),
          ),
        );
      } else {
        result.add(i);
      }
    }

    return Result.ok(GetMessagesResponse(hasMore: data1.hasMore, list: result));
  }
}
