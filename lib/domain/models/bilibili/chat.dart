import 'package:better_bilibili/data/services/bilibili/model/get_conversation_response.dart' as unassembled;
import 'package:better_bilibili/domain/models/bilibili/comment.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';

enum ConversationType {
  user,
  system,
  fansGroup,
}

class Conversation {
  final String id;
  final ConversationType type;
  final User? user;
  final BaseMessage lastMessage;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.type,
    required this.user,
    required this.lastMessage,
    required this.unreadCount,
  });

  factory Conversation.assembly(unassembled.Conversation data1, User? data2) {
    return Conversation(
      id: data1.id,
      type: data1.type,
      user: data2,
      lastMessage: data1.lastMessage,
      unreadCount: data1.unreadCount,
    );
  }
}

abstract interface class BaseMessage {
  String get id;
  String get textContent;
  int get sendTime;
}

abstract interface class MessageWithSender implements BaseMessage {
  User get sender;
  MessageWithSender copyWithSender(User sender);
}

class TextMessage implements MessageWithSender {
  @override
  final String id;
  @override
  final String textContent;
  @override
  final int sendTime;
  @override
  final User sender;
  final String content;
  final List<Sticker> stickers;
  final bool isAutoReply;

  const TextMessage({
    required this.id,
    required this.textContent,
    required this.sendTime,
    required this.sender,
    required this.content,
    this.stickers = const [],
    required this.isAutoReply,
  });

  TextMessage copyWith({
    String? id,
    String? content,
    String? textContent,
    int? sendTime,
    List<Sticker>? stickers,
    User? sender,
    bool? isAutoReply,
  }) {
    return TextMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      textContent: textContent ?? this.textContent,
      sendTime: sendTime ?? this.sendTime,
      stickers: stickers ?? this.stickers,
      sender: sender ?? this.sender,
      isAutoReply: isAutoReply ?? this.isAutoReply,
    );
  }

  @override
  TextMessage copyWithSender(User sender) {
    return copyWith(sender: sender);
  }
}

class ImageMessage implements MessageWithSender {
  @override
  final String id;
  @override
  final String textContent;
  @override
  final int sendTime;
  @override
  final User sender;
  final String url;
  final int width;
  final int height;
  final double aspectRatio;
  final String mime;

  const ImageMessage({
    required this.id,
    this.textContent = '[图片]',
    required this.sendTime,
    required this.sender,
    required this.url,
    required this.width,
    required this.height,
    required this.aspectRatio,
    required this.mime,
  });

  ImageMessage copyWith({
    String? id,
    String? textContent,
    int? sendTime,
    String? url,
    int? width,
    int? height,
    double? aspectRatio,
    String? mime,
    User? sender,
  }) {
    return ImageMessage(
      id: id ?? this.id,
      textContent: textContent ?? this.textContent,
      sendTime: sendTime ?? this.sendTime,
      url: url ?? this.url,
      width: width ?? this.width,
      height: height ?? this.height,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      mime: mime ?? this.mime,
      sender: sender ?? this.sender,
    );
  }

  @override
  ImageMessage copyWithSender(User sender) {
    return copyWith(sender: sender);
  }
}

class LiveRoomShareMessage implements MessageWithSender {
  @override
  final String id;
  @override
  final String textContent;
  @override
  final int sendTime;
  @override
  final User sender;
  final String liveRoomId;
  final String liveRoomName;
  final String nickname;
  final String liveRoomCover;

  const LiveRoomShareMessage({
    required this.id,
    required this.textContent,
    required this.sendTime,
    required this.sender,
    required this.liveRoomId,
    required this.liveRoomName,
    required this.nickname,
    required this.liveRoomCover,
  });

  LiveRoomShareMessage copyWith({
    String? id,
    String? textContent,
    int? sendTime,
    String? liveRoomId,
    String? liveRoomName,
    String? nickname,
    String? liveRoomCover,
    User? sender,
  }) {
    return LiveRoomShareMessage(
      id: id ?? this.id,
      textContent: textContent ?? this.textContent,
      sendTime: sendTime ?? this.sendTime,
      liveRoomId: liveRoomId ?? this.liveRoomId,
      liveRoomName: liveRoomName ?? this.liveRoomName,
      nickname: nickname ?? this.nickname,
      liveRoomCover: liveRoomCover ?? this.liveRoomCover,
      sender: sender ?? this.sender,
    );
  }

  @override
  LiveRoomShareMessage copyWithSender(User sender) {
    return copyWith(sender: sender);
  }
}

class VideoShareMessage implements MessageWithSender {
  @override
  final String id;
  @override
  final String textContent;
  @override
  final int sendTime;
  @override
  final User sender;
  final String videoId;

  const VideoShareMessage({
    required this.id,
    required this.textContent,
    required this.sendTime,
    required this.sender,
    required this.videoId,
  });

  VideoShareMessage copyWith({
    String? id,
    String? textContent,
    int? sendTime,
    String? videoId,
    User? sender,
  }) {
    return VideoShareMessage(
      id: id ?? this.id,
      textContent: textContent ?? this.textContent,
      sendTime: sendTime ?? this.sendTime,
      videoId: videoId ?? this.videoId,
      sender: sender ?? this.sender,
    );
  }

  @override
  VideoShareMessage copyWithSender(User sender) {
    return copyWith(sender: sender);
  }
}

class ArticleShareMessage implements MessageWithSender {
  @override
  final String id;
  @override
  final String textContent;
  @override
  final int sendTime;
  @override
  final User sender;
  final String articleId;

  const ArticleShareMessage({
    required this.id,
    required this.textContent,
    required this.sendTime,
    required this.sender,
    required this.articleId,
  });

  ArticleShareMessage copyWith({
    String? id,
    String? textContent,
    int? sendTime,
    String? articleId,
    User? sender,
  }) {
    return ArticleShareMessage(
      id: id ?? this.id,
      textContent: textContent ?? this.textContent,
      sendTime: sendTime ?? this.sendTime,
      articleId: articleId ?? this.articleId,
      sender: sender ?? this.sender,
    );
  }

  @override
  ArticleShareMessage copyWithSender(User sender) {
    return copyWith(sender: sender);
  }
}

class SeriesShareMessage implements MessageWithSender {
  @override
  final String id;
  @override
  final String textContent;
  @override
  final int sendTime;
  @override
  final User sender;
  final String episodeId;

  const SeriesShareMessage({
    required this.id,
    required this.textContent,
    required this.sendTime,
    required this.sender,
    required this.episodeId,
  });

  SeriesShareMessage copyWith({
    String? id,
    String? textContent,
    int? sendTime,
    String? episodeId,
    User? sender,
  }) {
    return SeriesShareMessage(
      id: id ?? this.id,
      textContent: textContent ?? this.textContent,
      sendTime: sendTime ?? this.sendTime,
      episodeId: episodeId ?? this.episodeId,
      sender: sender ?? this.sender,
    );
  }

  @override
  SeriesShareMessage copyWithSender(User sender) {
    return copyWith(sender: sender);
  }
}

class PostShareMessage implements MessageWithSender {
  @override
  final String id;
  @override
  final String textContent;
  @override
  final int sendTime;
  @override
  final User sender;
  final String postId;
  final String postCover;
  final String postTitle;
  final String description;
  final String nickname;

  const PostShareMessage({
    required this.id,
    required this.textContent,
    required this.sendTime,
    required this.sender,
    required this.postId,
    required this.postCover,
    required this.postTitle,
    required this.description,
    required this.nickname,
  });

  PostShareMessage copyWith({
    String? id,
    String? textContent,
    int? sendTime,
    String? postId,
    String? postCover,
    String? postTitle,
    String? description,
    String? nickname,
    User? sender,
  }) {
    return PostShareMessage(
      id: id ?? this.id,
      textContent: textContent ?? this.textContent,
      sendTime: sendTime ?? this.sendTime,
      postId: postId ?? this.postId,
      postCover: postCover ?? this.postCover,
      postTitle: postTitle ?? this.postTitle,
      description: description ?? this.description,
      nickname: nickname ?? this.nickname,
      sender: sender ?? this.sender,
    );
  }

  @override
  PostShareMessage copyWithSender(User sender) {
    return copyWith(sender: sender);
  }
}
