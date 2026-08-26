import 'package:better_bilibili/domain/models/bilibili/chat.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';

class GetConversationResponse {
  final String? nextCursor;
  final List<Conversation> data;
  final Map<String, User> systemUsers;

  const GetConversationResponse({
    this.nextCursor,
    required this.data,
    required this.systemUsers,
  });
}

class Conversation {
  final String id;
  final ConversationType type;
  final BaseMessage lastMessage;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.type,
    required this.lastMessage,
    required this.unreadCount,
  });
}
