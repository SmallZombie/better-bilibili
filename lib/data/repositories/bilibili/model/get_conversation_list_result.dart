import 'package:better_bilibili/domain/models/bilibili/chat.dart';

class GetConversationListResult {
  final String? nextCursor;
  final List<Conversation> data;

  const GetConversationListResult({this.nextCursor, required this.data});
}
