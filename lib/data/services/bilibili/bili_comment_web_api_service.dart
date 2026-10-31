import 'dart:convert';

import 'package:better_bilibili/data/services/bilibili/model/get_comment_list.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_comment_report_reasons_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/uploaded_image.dart';
import 'package:better_bilibili/domain/exceptions/bili_http_exception.dart';
import 'package:better_bilibili/domain/exceptions/not_logged_in_exception.dart';
import 'package:better_bilibili/domain/models/bilibili/account.dart';
import 'package:better_bilibili/domain/models/bilibili/bilibili.dart';
import 'package:better_bilibili/domain/models/bilibili/comment.dart';
import 'package:better_bilibili/utils/bilibili/bili_util.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:dio/dio.dart';

class BiliCommentWebApiService {
  Future<Dio> Function() getClient;
  Future<Account> Function() getAccount;

  BiliCommentWebApiService({required this.getClient, required this.getAccount});

  Future<LoginedAccount> _getLoginedAccount() async {
    final account = await getAccount();
    if (account is! LoginedAccount) {
      throw const NotLoggedInException();
    }
    return account;
  }

  void _checkResponse(Response resp) {
    if (resp.data['code'] != 0) {
      throw BiliHttpException(resp.data['code'], resp.data['message']);
    }
  }

  Result<T> _handleError<T>(Object error) {
    if (error is DioException) {
      final resp = error.response;
      if (resp == null) {
        return Result.error(Exception('Unknown error: ${error.message}'));
      }
      return Result.error(Exception('${resp.statusCode}: ${resp.data}'));
    } else if (error is Exception) {
      return Result.error(error);
    } else if (error is Error) {
      assert(false, 'Something went wrong');
      return Result.error(Exception(error.toString()));
    } else {
      assert(false, 'What did you throw?');
      return Result.error(Exception('Unknown error'));
    }
  }

  /// 获取评论列表
  ///
  /// 此接口使用 cursor 翻页
  /// sort: true = 发布时间降序, false = 默认
  /// anchorCommentId: 传入此id来让目标评论一定被包含在第一页中,
  /// 不可以在非首页中使用, 并且目标评论可能会重复出现在非首页响应中, 需要调用者自行检测
  Future<Result<GetCommentListResponse>> getList({
    required String id,
    required BiliContentTypeEnum type,
    String? cursor,
    bool sort = false,
    String? anchorCommentId,
  }) async {
    assert(id.isNotEmpty);
    assert(anchorCommentId == null || anchorCommentId.isNotEmpty);
    assert(cursor == null || anchorCommentId == null);

    final account = await getAccount();
    final client = await getClient();

    try {
      final resp = await client.get(
        'https://api.bilibili.com/x/v2/reply/wbi/main',
        queryParameters: buildWbiParams(
          {
            'oid': id,
            'type': type.value,
            'mode': sort ? 2 : 3,
            'pagination_str': '{"offset":"${cursor ?? ''}"}',
            'plat': 1,
            'seek_rpid': anchorCommentId ?? '',
            'web_location': '1315875',
          },
          account.wbiImgKey,
          account.wbiSubKey,
        ),
      );

      _checkResponse(resp);

      // b站的神秘操作，即使只有 1 条评论，b站也会在第一页返回 nextOffset 并 is_end=false，
      // 直到第二次请求 replies.length=0 才会 is_end=true
      // 这里尝试修正一下，但仍存在多发一次请求的问题
      final String? nextCursor = resp.data['data']['replies'].isNotEmpty
          ? resp.data['data']['cursor']['pagination_reply']['next_offset']
          : null;

      return Result.ok(
        GetCommentListResponse(
          nextCursor: nextCursor,
          list:
              [
                if (resp.data['data']['top_replies'] != null) ...resp.data['data']['top_replies'],
                ...resp.data['data']['replies'],
              ].map(
                (comment) {
                  return Comment.fromJson(
                    comment,
                    myUserId: account.userId,
                    uploaderUserId: resp.data['data']['upper']['mid'].toString(),
                  );
                },
              ).toList(),
        ),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  /// type: 1 = 视频, 12 = 文章
  /// 回复内容本身只传入 id 和 type 即可, 回复评论需要带上 rootId 和 parentId
  /// rootId: 根评论id
  /// parentId: 父评论id, 也就是要回复的评论id
  /// 当评论中存在 at 时, 需要传入 nicknameToUserId
  /// 当评论中存在贴纸时, 只需在 content 中将其替换为 code 即可, 例如: `你好呀[千恋万花表情包_丛雨Ciallo]`
  /// 当评论中存在图片时, 需要先通过 [base_uploadImage] 上传得到 [UploadedImage] 然后以列表形式传入此函数
  Future<Result<Comment>> post({
    required String id,
    required BiliContentTypeEnum type,
    required String content,
    String? rootId,
    String? parentId,
    Map<String, String>? nicknameToUserId,
    List<UploadedImage>? images,
  }) async {
    assert(id.isNotEmpty && content.isNotEmpty);
    // rootId 和 parentId 必须同时存在或同时不存在
    assert((rootId != null && parentId != null) || (rootId == null && parentId == null));
    assert((images?.length ?? 0) <= 9);

    final client = await getClient();

    try {
      final account = await _getLoginedAccount();

      final resp = await client.post(
        'https://api.bilibili.com/x/v2/reply/add',
        options: Options(contentType: Headers.formUrlEncodedContentType),
        queryParameters: buildWbiParams(
          {
            // 因为文章页没有回退元素，所以这里留空没问题
            'dm_img_list': '[]',
            'dm_img_str': getDmImgStr(),
            'dm_cover_img_str': getDmCoverImgStr(),
            'dm_img_inter': getDmImgInter(
              windowWidth: sometingOrElse(0.01, account.windowWidth ~/ 2, account.windowWidth),
              windowHeight: sometingOrElse(0.01, account.windowHeight ~/ 2, account.windowHeight),
            ),
          },
          account.wbiImgKey,
          account.wbiSubKey,
        ),
        data: {
          'plat': 1,
          'oid': id,
          'type': type.value,
          'message': content.isEmpty ? 'ㅤ' : content,
          'root': rootId ?? parentId,
          'parent': parentId,
          'at_name_to_mid': nicknameToUserId != null ? jsonEncode(nicknameToUserId.map((k, v) => MapEntry(k, int.parse(v)))) : '{}',
          'pictures': jsonEncode(images),
          'gaia_source': 'main_web',
          'csrf': account.biliJct,
          'statistics': '{"appId":100,"platform":5}',
        },
      );

      _checkResponse(resp);

      return Result.ok(
        Comment.fromJson(
          resp.data['data']['reply'],
          myUserId: account.userId,
          uploaderUserId: resp.data['data']['upper']['mid'].toString(),
        ),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Result<List<MentionUser>>> getMentionList({
    String? keyword,
    required BiliContentTypeEnum type,
  }) async {
    assert(keyword == null || keyword.isNotEmpty);

    final client = await getClient();

    try {
      await _getLoginedAccount();

      final resp = await client.get(
        'https://api.bilibili.com/x/v2/reply/at',
        queryParameters: {
          'keyword': keyword ?? '',
          'web_location': type.webLocation,
        },
      );

      _checkResponse(resp);

      if (resp.data['data']['groups'] == null) return Result.ok(const []);

      final List<MentionUser> list = [];
      for (final item in resp.data['data']['groups']) {
        // 1 = 最近联系，2 = 我的关注，3 = 未知，4 = 其他
        final hasFollowed = item['group_type'] == 2;
        list.addAll(
          (item['items'] as List).map(
            (user) => MentionUser(
              id: user['mid'].toString(),
              nickname: user['name'],
              avatar: user['face'],
              fansCount: user['fan'],
              hasFollowed: hasFollowed,
            ),
          ),
        );
      }

      return Result.ok(list);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 强烈建议传入准确的 WebLocation, 为空使用默认值(视频详情页)
  Future<Result<List<StickerPack>>> getStickerList({String webLocation = WebLocation.videoDetail}) async {
    assert(webLocation.isNotEmpty);

    final client = await getClient();

    try {
      await _getLoginedAccount();

      final resp = await client.get(
        'https://api.bilibili.com/x/emote/user/panel/web',
        queryParameters: {
          'business': 'reply',
          'web_location': webLocation,
        },
      );

      _checkResponse(resp);

      final List<StickerPack> list = [];
      for (final pack in resp.data['data']['packages'] as List) {
        // 排除颜文字
        if (pack['id'] == 4) continue;

        list.add(
          StickerPack(
            id: pack['id'].toString(),
            name: pack['text'],
            icon: pack['url'],
            stickers: (pack['emote'] as List)
                .map(
                  (item) => Sticker(
                    id: item['id'].toString(),
                    packId: pack['id'].toString(),
                    name: item['meta']['alias'],
                    code: item['text'],
                    url: item['url'],
                    thumbnail: item['url'],
                    size: item['package_id'] == 1 ? 24.0 : 60.0,
                  ),
                )
                .toList(),
          ),
        );
      }

      return Result.ok(list);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Result<void>> delete({
    required String contextId,
    required BiliContentTypeEnum type,
    required String commentId,
  }) async {
    assert(contextId.isNotEmpty && commentId.isNotEmpty);

    final client = await getClient();

    try {
      final account = await _getLoginedAccount();
      final resp = await client.post(
        'https://api.bilibili.com/x/v2/reply/del',
        options: Options(contentType: Headers.formUrlEncodedContentType),
        data: {
          'oid': contextId,
          'type': type.value,
          'rpid': commentId,
          'csrf': account.biliJct,
        },
      );

      _checkResponse(resp);

      return Result.ok(null);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Result<void>> like({
    required String contextId,
    required BiliContentTypeEnum type,
    required String commentId,
    required bool like,
  }) async {
    assert(contextId.isNotEmpty && commentId.isNotEmpty);

    final client = await getClient();

    try {
      final account = await _getLoginedAccount();
      final resp = await client.post(
        'https://api.bilibili.com/x/v2/reply/action',
        options: Options(contentType: Headers.formUrlEncodedContentType),
        data: {
          'oid': contextId,
          'type': type.value,
          'rpid': commentId,
          'action': like ? 1 : 0,
          'csrf': account.biliJct,
        },
      );

      _checkResponse(resp);

      return Result.ok(null);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Result<void>> dislike({
    required String contextId,
    required BiliContentTypeEnum type,
    required String commentId,
    required bool dislike,
  }) async {
    assert(contextId.isNotEmpty && commentId.isNotEmpty);

    final client = await getClient();

    try {
      final account = await _getLoginedAccount();
      final resp = await client.post(
        'https://api.bilibili.com/x/v2/reply/hate',
        options: Options(contentType: Headers.formUrlEncodedContentType),
        data: {
          'oid': contextId,
          'type': type.value,
          'rpid': commentId,
          'action': dislike ? 1 : 0,
          'csrf': account.biliJct,
        },
      );

      _checkResponse(resp);

      return Result.ok(null);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 不同于其他接口，此接口 ps 默认 10，建议也是 10
  Future<Result<List<Comment>>> getReplies({
    required String contextId,
    required BiliContentTypeEnum type,
    required String rootId,
    int pn = 1,
    int ps = 10,
  }) async {
    assert(contextId.isNotEmpty && rootId.isNotEmpty);

    final account = await getAccount();
    final client = await getClient();

    try {
      final resp = await client.get(
        'https://api.bilibili.com/x/v2/reply/reply',
        queryParameters: {
          'oid': contextId,
          'type': type.value,
          'root': rootId,
          'ps': ps,
          'pn': pn,
          'web_location': type.webLocation,
        },
      );

      _checkResponse(resp);

      return Result.ok(
        (resp.data['data']['replies'] as List).map(
          (comment) {
            return Comment.fromJson(
              comment,
              myUserId: account.userId,
              uploaderUserId: resp.data['data']['upper']['mid'].toString(),
            );
          },
        ).toList(),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Result<List<ReportReasonItem>>> getReportReasons({
    required BiliContentTypeEnum contentType,
    required String contentId,
  }) async {
    assert(contentId.isNotEmpty);

    final client = await getClient();

    try {
      final resp = await client.get(
        'https://api.bilibili.com/x/v2/reply/report/metadata',
        queryParameters: {
          'oid': contentId,
          'type': contentType.value,
          'web_location': switch (contentType) {
            .article => '333.1369',
            .post => '333.1369',
            .video => '333.788',
            _ => throw Exception('Unsupported contentType: $contentType'),
          },
        },
      );

      _checkResponse(resp);

      return Result.ok(
        (resp.data['data']['reason_list'] as List).map((v) {
          return ReportReasonItem.fromJson(v);
        }).toList(),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Result<void>> report({
    required BiliContentTypeEnum contentType,
    required String contentId,
    required String commentId,
    required int reasonId,
    String? description,
  }) async {
    assert(contentId.isNotEmpty && commentId.isNotEmpty);
    assert(reasonId > 0);

    final client = await getClient();

    try {
      final account = await _getLoginedAccount();
      final resp = await client.post(
        'https://api.bilibili.com/x/v2/reply/report',
        options: Options(contentType: Headers.formUrlEncodedContentType),
        data: {
          'type': contentType.value,
          'oid': contentId,
          'rpid': commentId,
          'reason': reasonId,
          'content': description ?? '',
          'add_blacklist': false,
          'delete': false,
          'ordering': 'heat',
          'statistics': '{"appId":100,"platform":5}',
          'gaia_source': 'main_web',
          'csrf': account.biliJct,
        },
      );

      _checkResponse(resp);

      return Result.ok(null);
    } catch (e) {
      return _handleError(e);
    }
  }
}
