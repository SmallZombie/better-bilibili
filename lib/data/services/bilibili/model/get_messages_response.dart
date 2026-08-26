import 'package:better_bilibili/domain/models/bilibili/chat.dart';

class GetMessagesResponse {
  /// 在此之前是否还有消息
  final bool hasMore;
  final List<BaseMessage> list;

  const GetMessagesResponse({required this.hasMore, required this.list});
}
