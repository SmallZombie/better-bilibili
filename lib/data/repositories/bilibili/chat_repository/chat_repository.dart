import 'package:better_bilibili/data/repositories/bilibili/model/get_conversation_list_result.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_conversation.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_messages_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_unread_count_response.dart';
import 'package:better_bilibili/utils/result.dart';

abstract interface class ChatRepository {
  static bool isOfficial(String userId) {
    if (userId.startsWith('#')) {
      return true;
    }

    return false;
  }

  Future<Result<GetUnreadCountResponse>> getUnreadCount();

  Future<Result<GetConversationListResult>> getConversationList({
    required ConversationListType type,
    int? limit,
    required bool foldGroup,
    required bool foldNotFollowed,
    String? nextCursor,
  });

  Future<Result<GetMessagesResponse>> getMessages({
    required String conversationId,
    String? messageId,
  });
}
