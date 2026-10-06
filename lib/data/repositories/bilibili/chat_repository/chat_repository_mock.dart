import 'package:better_bilibili/data/repositories/bilibili/chat_repository/chat_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/model/get_conversation_list_result.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_conversation.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_messages_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_unread_count_response.dart';
import 'package:better_bilibili/utils/result.dart';

class ChatRepositoryMock implements ChatRepository {
  @override
  Future<Result<GetConversationListResult>> getConversationList({
    required ConversationListType type,
    int? limit,
    required bool foldGroup,
    required bool foldNotFollowed,
    String? nextCursor,
  }) {
    // TODO: implement getConversationList
    throw UnimplementedError();
  }

  @override
  Future<Result<GetMessagesResponse>> getMessages({required String conversationId, String? messageId}) {
    // TODO: implement getMessages
    throw UnimplementedError();
  }

  @override
  Future<Result<GetUnreadCountResponse>> getUnreadCount() {
    // TODO: implement getUnreadCount
    throw UnimplementedError();
  }
}
