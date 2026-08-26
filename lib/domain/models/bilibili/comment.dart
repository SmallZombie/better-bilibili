import 'package:better_bilibili/domain/models/bilibili/bilibili.dart';

class Comment {
  final String id;
  final String contextId;
  final String? rootId;
  final String? parentId;
  final BiliContentTypeEnum type;
  final CommentUser owner;
  final int replyCount;
  final int creationTime;
  final CommentContent content;
  final List<Comment> replies;
  final bool isLiked;
  final bool isDisliked;
  final int likeCount;
  // 只有在回复时存在
  final ReplyTargetUser? replyTarget;
  final bool isSendByMe;
  final bool isPinned;
  final bool isSendByUploader;
  final String? region;
  final bool isEarlyFan;
  final bool islikedByUploader;
  final bool isRepliedByUploader;
  final bool isMutualFollow;

  Comment({
    required this.id,
    required this.contextId,
    this.rootId,
    this.parentId,
    required this.type,
    required this.owner,
    required this.replyCount,
    required this.creationTime,
    required this.content,
    required this.replies,
    required this.isLiked,
    required this.isDisliked,
    required this.likeCount,
    this.replyTarget,
    required this.isSendByMe,
    required this.isPinned,
    required this.isSendByUploader,
    this.region,
    required this.isEarlyFan,
    required this.islikedByUploader,
    required this.isRepliedByUploader,
    required this.isMutualFollow,
  });

  Comment copyWith({
    String? id,
    String? contextId,
    String? rootId,
    String? parentId,
    BiliContentTypeEnum? type,
    CommentUser? owner,
    int? replyCount,
    int? creationTime,
    CommentContent? content,
    List<Comment>? replies,
    bool? isLiked,
    bool? isDisliked,
    int? likeCount,
    ReplyTargetUser? replyTarget,
    bool? isSendByMe,
    bool? isPinned,
    bool? isSendByUploader,
    String? region,
    bool? isEarlyFan,
    bool? islikedByUploader,
    bool? isRepliedByUploader,
    bool? isMutualFollow,
  }) {
    return Comment(
      id: id ?? this.id,
      contextId: contextId ?? this.contextId,
      rootId: rootId ?? this.rootId,
      parentId: parentId ?? this.parentId,
      type: type ?? this.type,
      owner: owner ?? this.owner,
      replyCount: replyCount ?? this.replyCount,
      creationTime: creationTime ?? this.creationTime,
      content: content ?? this.content,
      replies: replies ?? this.replies,
      isLiked: isLiked ?? this.isLiked,
      isDisliked: isDisliked ?? this.isDisliked,
      likeCount: likeCount ?? this.likeCount,
      replyTarget: replyTarget ?? this.replyTarget,
      isSendByMe: isSendByMe ?? this.isSendByMe,
      isPinned: isPinned ?? this.isPinned,
      isSendByUploader: isSendByMe ?? this.isSendByUploader,
      region: region ?? this.region,
      isEarlyFan: isEarlyFan ?? this.isEarlyFan,
      islikedByUploader: islikedByUploader ?? this.islikedByUploader,
      isRepliedByUploader: isRepliedByUploader ?? this.isRepliedByUploader,
      isMutualFollow: isMutualFollow ?? this.isMutualFollow,
    );
  }

  factory Comment.fromJson(Map<String, dynamic> json, {String? myUserId, String? uploaderUserId}) {
    // 此处按照设计从消息正文中移除开头的回复目标
    final String contentMessage = json['content']['message'].replaceAll(RegExp('^回复\\s*@.+?[:：]\\s*'), '').trim();
    final ReplyTargetUser? replyTarget = json['parent_reply_member'] != null
        ? ReplyTargetUser(
            // 当回复对象为自己时，此处 uid 为 null
            id: json['parent_reply_member']['mid'] ?? json['member']?['mid']?.toString(),
            nickname: json['parent_reply_member']['name'],
          )
        : null;

    final atNameToMidStr = json['content']['at_name_to_mid_str'] as Map?;
    final emote = json['content']['emote'] as Map?;
    final imageEnhance = json['member']['pendant']['image_enhance'];

    return Comment(
      id: json['rpid_str'],
      type: BiliContentTypeEnumExtension.fromNumber(json['type']),
      contextId: json['oid_str'],
      rootId: json['root_str'] == '0' ? null : json['root_str'],
      parentId: json['parent_str'] == '0' ? null : json['parent_str'],
      owner: CommentUser(
        id: json['member']['mid'].toString(),
        nickname: json['member']['uname'],
        avatar: json['member']['avatar'],
        avatarFrame: imageEnhance.isEmpty ? null : imageEnhance,
      ),
      replyCount: json['rcount'],
      creationTime: json['ctime'],
      content: CommentContent(
        text: contentMessage == 'ㅤ' ? null : contentMessage,
        users: atNameToMidStr == null
            ? []
            : atNameToMidStr.entries.map((e) {
                return CommentContentUser(
                  id: e.value,
                  nickname: e.key,
                );
              }).toList(),
        stickers: emote == null
            ? []
            : emote.entries.map((e) {
                return Sticker(
                  id: e.value['id'].toString(),
                  packId: e.value['package_id'].toString(),
                  name: e.value['jump_title'],
                  code: e.key,
                  url: e.value['gif_url'] ?? e.value['url'],
                  thumbnail: e.value['gif_url'] != null ? e.value['url'] : null,
                  size: e.value['package_id'] == 1 ? 24.0 : 60.0,
                );
              }).toList(),
        images: (json['content']['pictures'] as List?)?.map((image) => image['img_src'] as String).toList() ?? const [],
        // Map<String, dynamic> => Map<String, CommentContentLink>
        links: (json['content']['jump_url'] as Map<String, dynamic>).entries.map(
          (e) {
            return CommentContentLink(
              rawText: e.key,
              title: e.value['title'],
              url: e.value['pc_url'].isEmpty ? e.key : e.value['pc_url'],
              appUrl: e.value['app_url_schema'].isEmpty ? null : e.value['app_url_schema'],
            );
          },
        ).toList(),
      ),
      // 一级评论是否附带回复、附带几个都是由b站决定的，此处存在 replyCount != 0 但 replies 为 null 的情况
      // replies: (json['replies'] as List?)?.map((reply) => _handleComment(reply)).toList() ?? [],
      // 此处从顶层屏蔽回复来满足 "评论默认不展开" 的设计
      replies: [],
      isLiked: json['action'] == 1,
      isDisliked: json['action'] == 2,
      likeCount: json['like'],
      replyTarget: replyTarget,
      isSendByMe: json['member']['mid'] == myUserId,
      isPinned: json['reply_control']?['is_up_top'] == true,
      isSendByUploader: json['member']['mid'].toString() == uploaderUserId,
      // "IP属地：辽宁"
      region: json['reply_control']?['location']?.substring(5),
      isEarlyFan: json['reply_control']?['is_contractor'] == true,
      islikedByUploader: json['up_action']['like'] as bool,
      isRepliedByUploader: json['up_action']['reply'] as bool,
      isMutualFollow: (json['card_label'] as List?)?.any((v) => v['text_content'] == '互相关注') ?? false,
    );
  }
}

class CommentUser {
  final String id;
  final String nickname;
  final String avatar;
  final String? avatarFrame;

  const CommentUser({
    required this.id,
    required this.nickname,
    required this.avatar,
    this.avatarFrame,
  });
}

class CommentContent {
  final String? text;
  final List<CommentContentUser> users;
  final List<Sticker> stickers;
  final List<String> images;
  final List<CommentContentLink> links;

  CommentContent({
    this.text,
    this.users = const [],
    this.stickers = const [],
    this.images = const [],
    this.links = const [],
  });
}

class CommentContentLink {
  final String? title;
  final String rawText;
  final String? appUrl;
  final String url;

  const CommentContentLink({
    this.title,
    required this.rawText,
    this.appUrl,
    required this.url,
  });
}

class CommentContentUser {
  final String id;
  final String nickname;

  const CommentContentUser({required this.id, required this.nickname});
}

class Sticker {
  final String id;
  final String packId;
  final String name;
  final String code;
  final String url;
  final String? thumbnail;
  final double size;

  const Sticker({
    required this.id,
    required this.packId,
    required this.name,
    required this.code,
    required this.url,
    required this.thumbnail,
    required this.size,
  });

  Sticker copyWith({
    String? id,
    String? packId,
    String? name,
    String? code,
    String? url,
    String? thumbnail,
    double? size,
  }) {
    return Sticker(
      id: id ?? this.id,
      packId: packId ?? this.packId,
      name: name ?? this.name,
      code: code ?? this.code,
      url: url ?? this.url,
      thumbnail: thumbnail ?? this.thumbnail,
      size: size ?? this.size,
    );
  }
}

class StickerPack {
  final String id;
  final String name;
  final String icon;
  final List<Sticker> stickers;

  StickerPack({required this.id, required this.name, required this.icon, required this.stickers});
}

class ReplyTargetUser {
  final String id;
  final String nickname;

  ReplyTargetUser({required this.id, required this.nickname});
}

class MentionUser {
  final String id;
  final String nickname;
  final String avatar;
  final int fansCount;
  final bool hasFollowed;

  MentionUser({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.fansCount,
    required this.hasFollowed,
  });
}

class SubscriptionTier {
  final String id;
  final String name;
  // final String description;
  final double price;
  final String currency = 'CNY';

  SubscriptionTier({
    required this.id,
    required this.name,
    // required this.description,
    required this.price,
  });
}
