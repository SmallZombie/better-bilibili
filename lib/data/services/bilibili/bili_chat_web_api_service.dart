import 'dart:convert';

import 'package:better_bilibili/data/services/bilibili/model/get_conversation.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_conversation_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_messages_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_unread_count_response.dart';
import 'package:better_bilibili/domain/models/bilibili/account.dart';
import 'package:better_bilibili/domain/models/bilibili/chat.dart' as chat_model;
import 'package:better_bilibili/domain/models/bilibili/comment.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/utils/bili_util.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:dio/dio.dart';

class BiliChatWebApiService {
  Future<Dio> Function() getClient;
  Future<Account> Function() getAccount;

  BiliChatWebApiService({required this.getClient, required this.getAccount});

  Future<Result<GetUnreadCountResponse>> getUnreadCount() async {
    final client = await getClient();

    final resp = await client.get(
      'https://api.vc.bilibili.com/session_svr/v1/session_svr/single_unread',
      queryParameters: {
        'unread_type': 0,
        'show_dustbin': 1,
        'build': 0,
        'mobi_app': 'web',
        'web_location': WebLocation.message,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(
      GetUnreadCountResponse(
        followed: resp.data['data']['follow_unread'],
        notFollowed: resp.data['data']['unfollow_unread'],
      ),
    );
  }

  chat_model.BaseMessage _parseMessage(dynamic obj, {List<Sticker>? stickers}) {
    final id = (obj['msg_key'] as int).toString();
    final sendTime = obj['timestamp'] as int;
    final jsonContent = jsonDecode(obj['content'] as String);
    final senderUserId = obj['sender_uid'].toString();

    switch (obj['msg_type']) {
      // 文本
      case 1:
        final content = jsonContent['content'] as String;
        return chat_model.TextMessage(
          id: id,
          content: content,
          textContent: content,
          sendTime: sendTime,
          stickers: stickers?.where((v) => content.contains(v.code)).toList() ?? [],
          sender: User(id: senderUserId, avatar: '', nickname: ''),
          // 8: 被关注自动回复
          // 9: 收到消息自动回复
          // 10: 关键词自动回复
          // 11: 大航海上船自动回复
          isAutoReply: const [8, 9, 10, 11].contains(obj['msg_source']),
        );
      // 图片
      case 2:
        return chat_model.ImageMessage(
          id: id,
          textContent: '[图片]',
          sendTime: sendTime,
          url: jsonContent['url'],
          width: jsonContent['width'],
          height: jsonContent['height'],
          aspectRatio: (jsonContent['height'] as int) / (jsonContent['width'] as int),
          mime: 'image/${jsonContent['imageType']}',
          sender: User(id: senderUserId, avatar: '', nickname: ''),
        );
      // 分享
      case 7:
        final shareType = jsonContent['source'] as int;
        switch (shareType) {
          // 视频
          case 5:
            return chat_model.VideoShareMessage(
              id: id,
              textContent: '[视频]',
              sendTime: sendTime,
              videoId: jsonContent['id'].toString(),
              sender: User(id: senderUserId, avatar: '', nickname: ''),
            );
          // 文章
          case 6:
            return chat_model.ArticleShareMessage(
              id: id,
              textContent: '[文章]',
              sendTime: sendTime,
              articleId: jsonContent['id'].toString(),
              sender: User(id: senderUserId, avatar: '', nickname: ''),
            );
          // 剧集
          case 7:
            return chat_model.SeriesShareMessage(
              id: id,
              textContent: '[剧集]',
              sendTime: sendTime,
              episodeId: jsonContent['id'].toString(),
              sender: User(id: senderUserId, avatar: '', nickname: ''),
            );
          // 帖子
          case 11:
            return chat_model.PostShareMessage(
              id: id,
              textContent: '[帖子]',
              sendTime: sendTime,
              postId: jsonContent['id'].toString(),
              postCover: jsonContent['thumb'],
              postTitle: jsonContent['headline'],
              description: jsonContent['title'],
              nickname: jsonContent['author'],
              sender: User(id: senderUserId, avatar: '', nickname: ''),
            );
          default:
            return chat_model.TextMessage(
              id: id,
              content: '(不支持的分享类型: $shareType)',
              textContent: '(不支持的分享类型)',
              sendTime: sendTime,
              sender: User(id: senderUserId, avatar: '', nickname: ''),
              isAutoReply: false,
            );
        }
      case 14:
        final shareType = jsonContent['source'] as String;
        switch (shareType) {
          case '直播':
            final url = Uri.parse(jsonContent['url']);
            final liveRoomId = url.path.split('/').last;

            return chat_model.LiveRoomShareMessage(
              id: id,
              textContent: '[直播间]',
              sendTime: sendTime,
              liveRoomId: liveRoomId,
              liveRoomName: jsonContent['title'],
              nickname: jsonContent['author'],
              liveRoomCover: jsonContent['cover'],
              sender: User(id: senderUserId, avatar: '', nickname: ''),
            );
          default:
            return chat_model.TextMessage(
              id: id,
              content: '(不支持的其他分享类型: $shareType)',
              textContent: '(不支持的其他分享类型)',
              sendTime: sendTime,
              sender: User(id: senderUserId, avatar: '', nickname: ''),
              isAutoReply: false,
            );
        }
      case _:
        return chat_model.TextMessage(
          id: id,
          content: '(不支持的消息类型: ${obj['msg_type']})',
          textContent: '(不支持的消息类型)',
          sendTime: sendTime,
          sender: User(id: senderUserId, avatar: '', nickname: ''),
          isAutoReply: false,
        );
    }
  }

  Future<Result<GetConversationResponse>> getConversationList({
    required ConversationListType type,
    int? limit,
    required bool foldGroup,
    required bool foldNotFollowed,
    String? nextCursor,
  }) async {
    final account = await getAccount();
    final client = await getClient();

    final resp = await client.get(
      'https://api.vc.bilibili.com/session_svr/v1/session_svr/get_sessions',
      queryParameters: buildWbiParams(
        {
          'session_type': type.value,
          if (limit != null) ...{'size': limit},
          'group_fold': foldGroup ? 1 : 0,
          'unfollow_fold': foldNotFollowed ? 1 : 0,
          'sort_rule': switch (type) {
            .userAndSystem => 2,
            _ => 1,
          },
          if (nextCursor != null) ...{'end_ts': nextCursor},
          'build': 0,
          'mobi_app': 'web',
          'web_location': WebLocation.message,
        },
        account.wbiImgKey,
        account.wbiSubKey,
      ),
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    final sessionList = resp.data['data']['session_list'] as List;

    final List<Conversation> result = [];
    final Map<String, User> systemUsers = {};
    for (final i in sessionList) {
      final chat_model.ConversationType type = i['system_msg_type'] != 0
          ? .system
          : i['session_type'] == 2
          ? .fansGroup
          : .user;

      late final String id;
      if (type == .user) {
        id = i['talker_id'].toString();
      } else if (i['system_msg_type'] == 1) {
        id = '#streamerHelper';
        systemUsers['#streamerHelper'] = User(
          id: '#streamerHelper',
          avatar: i['account_info']['pic_url'],
          nickname: i['account_info']['name'],
        );
      } else if (i['system_msg_type'] == 7) {
        id = '#uploaderHelper';
        systemUsers['#uploaderHelper'] = User(
          id: '#uploaderHelper',
          avatar: i['account_info']['pic_url'],
          nickname: i['account_info']['name'],
        );
      } else if (i['system_msg_type'] == 8) {
        id = '#support';
        systemUsers['#support'] = User(
          id: '#support',
          avatar: i['account_info']['pic_url'],
          nickname: i['account_info']['name'],
        );
      } else if (i['system_msg_type'] == 9) {
        id = '#paymentCenter';
        systemUsers['#paymentCenter'] = User(
          id: '#paymentCenter',
          avatar: i['account_info']['pic_url'],
          nickname: i['account_info']['name'],
        );
      } else if (i['system_msg_type'] == 12) {
        id = '#communityCenter';
        systemUsers['#communityCenter'] = User(
          id: '#communityCenter',
          avatar: i['account_info']['pic_url'],
          nickname: i['account_info']['name'],
        );
      } else {
        throw Exception('Invaild conversation type:${i['session_type']} systemType:${i['system_msg_type']}');
      }

      result.add(
        Conversation(
          id: id,
          type: type,
          lastMessage: _parseMessage(i['last_msg']),
          unreadCount: i['unread_count'] as int,
        ),
      );
    }

    return Result.ok(
      GetConversationResponse(
        nextCursor: resp.data['data']['has_more'] == 1 ? sessionList.last['session_ts'].toString() : null,
        data: result,
        systemUsers: systemUsers,
      ),
    );
  }

  Future<Result<GetMessagesResponse>> getMessages({
    required String conversationId,
    String? messageId,
  }) async {
    assert(conversationId.isNotEmpty);
    assert(messageId == null || messageId.isNotEmpty);

    final account = await getAccount();
    final client = await getClient();

    final resp = await client.get(
      'https://api.vc.bilibili.com/svr_sync/v1/svr_sync/fetch_session_msgs',
      queryParameters: buildWbiParams(
        {
          'size': 20,
          'session_type': 1,
          'talker_id': conversationId,
          if (messageId == null) ...{
            'begin_seqno': '',
            'end_seqno': '',
          },
          if (messageId != null) ...{
            'end_seqno': messageId,
          },
          'sender_device_id': 1,
          'build': 0,
          'mobi_app': 'web',
          'web_location': WebLocation.message,
        },
        account.wbiImgKey,
        account.wbiSubKey,
      ),
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    final List<Sticker> stickers = [];
    for (final i in resp.data['data']?['e_infos'] ?? []) {
      stickers.add(
        Sticker(
          id: '0',
          packId: '0',
          name: (i['text'] as String).substring(1, i['text'].length - 1),
          code: i['text'],
          url: i['url'],
          thumbnail: '${i['url']}@40w_40h',
          size: i['size'].toDouble() * 25,
        ),
      );
    }

    return Result.ok(
      GetMessagesResponse(
        hasMore: resp.data['data']['has_more'] == 1,
        list: (resp.data['data']['messages'] as List).reversed.map((v) {
          return _parseMessage(v, stickers: stickers);
        }).toList(),
      ),
    );
  }
}
