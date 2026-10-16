import 'dart:convert';

import 'package:better_bilibili/data/services/bilibili/model/get_post_detail_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_post_list_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_posts_response.dart';
import 'package:better_bilibili/domain/exceptions/bili_http_exception.dart';
import 'package:better_bilibili/domain/exceptions/not_logged_in_exception.dart';
import 'package:better_bilibili/domain/models/bilibili/account.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:better_bilibili/utils/bili/bili_util.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:dio/dio.dart';

class BiliPostWebApiService {
  Future<Dio> Function() getClient;
  Future<Account> Function() getAccount;

  BiliPostWebApiService({required this.getClient, required this.getAccount});

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
      return Result.error(error.error);
    } else {
      assert(false, 'What did you throw?');
      return Result.error(Exception('Unknown error'));
    }
  }

  /// 返回值可能为 [PostDetail]
  Future<Result<PostDetail>> getDetail( String postId) async {
    assert(postId.isNotEmpty);

    final client = await getClient();

    try {
      final resp = await client.get(
        'https://api.bilibili.com/x/polymer/web-dynamic/v1/opus/detail',
        queryParameters: {
          'id': postId,
          'timezone_offset': -480,
          // 必须包含 htmlNewStyle，否则文章会返回 fallback 要求重定向回文章接口
          'features': [
            'onlyfansVote',
            'onlyfansAssetsV2',
            'onlyfansOpusCard',
            'decorationCard',
            'htmlNewStyle',
            'ugcDelete',
            'editable',
            'opusPrivateVisible',
            'opusTribeeApprovedThread',
            'tribeeEdit',
            'avatarAutoTheme',
            'avatarTypeOpus',
            'sunflowerStyle',
            'articleEnhance',
            'cardsEnhance',
            'eva3CardOpus',
            'eva3CardVideo',
            'eva3CardComment',
            'eva3CardVote',
            'eva3CardUser',
          ].join(','),
          'web_location': WebLocation.postDetail,
        },
      );

      _checkResponse(resp);

      return Result.ok(PostDetail.fromJson(resp.data['data']['item']));
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Result<void>> like({
    required String postId,
    required bool like,
  }) async {
    assert(postId.isNotEmpty);

    final client = await getClient();

    try {
      final account = await _getLoginedAccount();
      final resp = await client.post(
        'https://api.bilibili.com/x/dynamic/feed/dyn/thumb',
        queryParameters: {'csrf': account.biliJct},
        options: Options(contentType: 'application/json'),
        data: jsonEncode({
          'dyn_id_str': postId,
          'spmid': '${WebLocation.postDetail}.0.0',
          'up': like ? 1 : 2,
        }),
      );

      _checkResponse(resp);

      return Result.ok(null);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Result<void>> favorite({
    required String postId,
    required bool favorite,
  }) async {
    assert(postId.isNotEmpty);

    final client = await getClient();

    try {
      final account = await _getLoginedAccount();
      final resp = await client.post(
        'https://api.bilibili.com/x/community/cosmo/interface/simple_action',
        queryParameters: {'csrf': account.biliJct},
        options: Options(contentType: 'application/json'),
        data: jsonEncode({
          'action': favorite ? 3 : 4,
          'entity': {
            'object_id_str': postId,
            'type': {'biz': 2},
          },
          'meta': {
            'spmid': '${WebLocation.postDetail}.0.0',
            'from': 'unknown',
          },
        }),
      );

      _checkResponse(resp);

      return Result.ok(null);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 获取动态列表
  ///
  /// 同时使用 pn 和 offset + hasMore 来分页
  ///
  /// 存在 [userId] 时，[type] 会被忽略并设置为 [GetPostListTypeEnum.all]
  Future<Result<GetPostListResponse>> getList({
    int pn = 1,
    String? offset,
    GetPostListTypeEnum type = GetPostListTypeEnum.all,
    String? userId,
  }) async {
    assert(pn > 0);
    assert(pn == 1 || (pn > 1 && offset != null));
    assert(offset == null || offset.isNotEmpty);
    assert(userId == null || userId.isNotEmpty);

    final client = await getClient();

    try {
      final resp = await client.get(
        'https://api.bilibili.com/x/polymer/web-dynamic/v1/feed/all',
        // dart format off
        queryParameters: userId != null ? {
          'host_mid': userId,
          'offset': offset ?? '',
          'page': pn,
          'platform': 'web',
          'features':
              'itemOpusStyle,listOnlyfans,opusBigCover,onlyfansVote,decorationCard,onlyfansAssetsV2,forwardListHidden,ugcDelete,onlyfansQaCard,commentsNewVersion,avatarAutoTheme,sunflowerStyle,cardsEnhance,eva3CardOpus,eva3CardVideo,eva3CardComment,eva3CardVote,eva3CardUser',
          'web_location': WebLocation.dynamicHome,
        } : {
          // 此参数貌似已经废弃，此处写死即可
          'timezone_offset': -480,
          'type': type.value,
          'platform': 'web',
          'page': pn,
          'offset': offset,
          // 貌似是写死的
          // https://s1.hdslb.com/bfs/static/2233-monorepo/dyn-home/static/js/index.61366064.js: `itemOpusStyle:!0`
          'features':
              'itemOpusStyle,listOnlyfans,opusBigCover,onlyfansVote,decorationCard,onlyfansAssetsV2,forwardListHidden,ugcDelete,onlyfansQaCard,commentsNewVersion,avatarAutoTheme,sunflowerStyle,cardsEnhance,eva3CardOpus,eva3CardVideo,eva3CardComment,eva3CardVote,eva3CardUser',
          'web_location': WebLocation.dynamicHome,
          'x-bili-device-req-json': '{"platform":"web","device":"pc","spmid":"333.1365"}',
        },
        // dart format on
      );

      _checkResponse(resp);

      final items = (resp.data['data']['items'] as List).where((item) => item['type'] != 'DYNAMIC_TYPE_PGC_UNION');
      return Result.ok(
        GetPostListResponse(
          list: items.map((item) => Post.fromJson(item)).toList(),
          hasMore: resp.data['data']['has_more'] as bool,
          offset: resp.data['data']['offset'] as String,
        ),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 获取活跃用户列表，最多20(存疑)个用户，这里的活跃用户指在所有关注中的近期最感兴趣(由b站决定)的用户
  /// 本来此接口还有正在直播的用户来着，被我砍了挪到 主页-直播 的顶部了
  Future<Result<List<User>>> getActiveUserList() async {
    final client = await getClient();

    try {
      await _getLoginedAccount();
      final resp = await client.get(
        'https://api.bilibili.com/x/polymer/web-dynamic/v1/portal',
        queryParameters: {
          'up_list_more': 1,
          'web_location': WebLocation.dynamicHome,
        },
      );

      _checkResponse(resp);

      final List<User> users = [];
      for (final user in resp.data['data']['up_list']['items']) {
        users.add(
          User(
            id: user['mid'].toString(),
            nickname: user['uname'],
            avatar: user['face'],
          ),
        );
      }

      return Result.ok(users);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 获取用户发布的动态
  ///
  /// 使用 offset 分页
  Future<Result<GetUserPostsResponse>> getUserPosts({
    required String userId,
    String? offset,
    GetUserPostsTypeEnum type = .all,
  }) async {
    assert(userId.isNotEmpty);
    assert(offset == null || offset.isNotEmpty);

    final account = await getAccount();
    final client = await getClient();

    final (String dmImgListStr, List<FingerprintLog> dmImgList) = getDmImgList(
      minLogCount: 2,
      maxLogCount: 2,
      windowWidth: account.windowWidth,
      windowHeight: account.windowHeight,
      maxTimestamp: getRandomInt(3000, 4000),
      mouseRangeX: 0.7,
      mouseRangeY: 0.6,
      useClickLog: false,
      useTargetList: [UserDetailPostElementList],
    );

    try {
      final resp = await client.get(
        'https://api.bilibili.com/x/polymer/web-dynamic/v1/feed/space',
        queryParameters: buildWbiParams(
          {
            'offset': offset,
            'host_mid': userId,
            'timezone_offset': '-480',
            'platform': 'web',
            if (type != .all) ...{'type': type.value},
            'features':
                'itemOpusStyle,listOnlyfans,opusBigCover,onlyfansVote,forwardListHidden,decorationCard,commentsNewVersion,onlyfansAssetsV2,ugcDelete,onlyfansQaCard,avatarAutoTheme,sunflowerStyle,cardsEnhance,eva3CardOpus,eva3CardVideo,eva3CardComment,eva3CardUser',
            'web_location': WebLocation.userSpace,
            'dm_img_list': dmImgListStr,
            'dm_img_str': getDmImgStr(),
            'dm_cover_img_str': getDmCoverImgStr(),
            'dm_img_inter': getDmImgInter(
              log: dmImgList.last,
              windowWidth: sometingOrElse(0.01, account.windowWidth ~/ 2, account.windowWidth),
              windowHeight: sometingOrElse(0.01, account.windowHeight ~/ 2, account.windowHeight),
            ),
            'x-bili-device-req-json': '{"platform":"web","device":"pc","spmid":"333.1387"}',
          },
          account.wbiImgKey,
          account.wbiSubKey,
        ),
      );

      _checkResponse(resp);

      return Result.ok(
        GetUserPostsResponse(
          list: (resp.data['data']['items'] as List).map((v) => Post.fromJson(v)).toList(),
          hasMore: resp.data['data']['has_more'] as bool,
          nextOffset: resp.data['data']['offset'].isEmpty ? null : resp.data['data']['offset'],
        ),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Result<void>> report({
    required String postId,
    required String userId,
    required int reasonId,
    String? reason,
  }) async {
    assert(postId.isNotEmpty);
    assert(const [0, 1, 3, 4, 5, 8, 9, 10, 12, 13].contains(reasonId));
    assert(reasonId != 0 || reason != null);
    assert(reason == null || reason.isNotEmpty);
    assert(userId.isNotEmpty);

    final client = await getClient();

    try {
      final account = await _getLoginedAccount();
      final resp = await client.post(
        'https://api.bilibili.com/x/dynamic/feed/dynamic_report/add',
        queryParameters: {
          'csrf': account.biliJct,
        },
        options: Options(contentType: 'application/json'),
        data: jsonEncode({
          'accused_uid': userId,
          'dynamic_id': postId,
          'reason_type': reasonId,
          'reason_desc': reason,
        }),
      );

      _checkResponse(resp);

      return Result.ok(null);
    } catch (e) {
      return _handleError(e);
    }
  }
}
