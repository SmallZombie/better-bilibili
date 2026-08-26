import 'dart:convert';

import 'package:better_bilibili/data/repositories/bilibili/auth_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_post_detail_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_post_list_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_posts_response.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:better_bilibili/utils/bili_util.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:dio/dio.dart';

class BiliPostApiService {
  final AuthRepository _authRepository;

  BiliPostApiService({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  /// 返回值可能为 [PostDetail]
  Future<Result<PostDetail>> getDetail({required String postId}) async {
    assert(postId.isNotEmpty);

    // final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    // final params = {
    //   'timezone_offset': -480,
    //   'platform': 'web',
    //   'gaia_source': 'main_web',
    //   'id': postId,
    //   // 必须包含 htmlNewStyle，否则文章会返回 fallback 要求重定向回文章接口
    //   'features': [
    //     'itemOpusStyle',
    //     'opusBigCover',
    //     'onlyfansVote',
    //     'endFooterHidden',
    //     'decorationCard',
    //     'onlyfansAssetsV2',
    //     'ugcDelete',
    //     'onlyfansQaCard',
    //     'editable',
    //     'opusPrivateVisible',
    //     'avatarAutoTheme',
    //     'sunflowerStyle',
    //     'cardsEnhance',
    //     'eva3CardOpus',
    //     'eva3CardVideo',
    //     'eva3CardComment',
    //     'eva3CardVote',
    //     'eva3CardUser',
    //   ].join(','),
    //   'web_location': WebLocation.postDetail_2,
    //   'x-bili-device-req-json': '{"platform":"web","device":"pc","spmid":"333.1368"}',
    // };
    // final (String wts, String wbiSign) = encWbi(params, account.wbiImgKey!, account.wbiSubKey!);

    // final resp = await client.get(
    //   'https://api.bilibili.com/x/polymer/web-dynamic/v1/detail',
    //   queryParameters: {
    //     ...params,
    //     'w_rid': wbiSign,
    //     'wts': wts,
    //   },
    // );

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

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(PostDetail.fromJson(resp.data['data']['item']));
  }

  Future<Result<void>> like({
    required String postId,
    required bool like,
  }) async {
    assert(postId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/dynamic/feed/dyn/thumb',
      queryParameters: {'csrf': account.biliJct},
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: jsonEncode({
        'dyn_id_str': postId,
        'spmid': '${WebLocation.postDetail}.0.0',
        'up': like ? 1 : 2,
      }),
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  Future<Result<void>> favorite({
    required String postId,
    required bool favorite,
  }) async {
    assert(postId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/community/cosmo/interface/simple_action',
      queryParameters: {'csrf': account.biliJct},
      options: Options(headers: {'Content-Type': 'application/json'}),
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

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
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

    final client = await _authRepository.getClient();

    final resp = await client.get(
      'https://api.bilibili.com/x/polymer/web-dynamic/v1/feed/all',
      queryParameters: userId != null
          ? {
              'host_mid': userId,
              'offset': offset ?? '',
              'page': pn,
              'platform': 'web',
              'features':
                  'itemOpusStyle,listOnlyfans,opusBigCover,onlyfansVote,decorationCard,onlyfansAssetsV2,forwardListHidden,ugcDelete,onlyfansQaCard,commentsNewVersion,avatarAutoTheme,sunflowerStyle,cardsEnhance,eva3CardOpus,eva3CardVideo,eva3CardComment,eva3CardVote,eva3CardUser',
              'web_location': WebLocation.dynamicHome,
            }
          : {
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
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    final items = (resp.data['data']['items'] as List).where((item) => item['type'] != 'DYNAMIC_TYPE_PGC_UNION');
    return Result.ok(
      GetPostListResponse(
        list: items.map((item) => Post.fromJson(item)).toList(),
        hasMore: resp.data['data']['has_more'] as bool,
        offset: resp.data['data']['offset'] as String,
      ),
    );
  }

  /// 获取活跃用户列表，最多20(存疑)个用户，这里的活跃用户指在所有关注中的近期最感兴趣(由b站决定)的用户
  /// 本来此接口还有正在直播的用户来着，被我砍了挪到 主页-直播 的顶部了
  Future<Result<List<User>>> getActiveUserList() async {
    final client = await _authRepository.getClient();
    final resp = await client.get(
      'https://api.bilibili.com/x/polymer/web-dynamic/v1/portal',
      queryParameters: {
        'up_list_more': 1,
        'web_location': WebLocation.dynamicHome,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

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

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final (String dmImgListStr, List<FingerprintLog> dmImgList) = getDmImgList(
      minLogCount: 2,
      maxLogCount: 2,
      windowWidth: account.windowWidth!,
      windowHeight: account.windowHeight!,
      maxTimestamp: getRandomInt(3000, 4000),
      mouseRangeX: 0.7,
      mouseRangeY: 0.6,
      useClickLog: false,
      useTargetList: [UserDetailPostElementList],
    );
    final params = {
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
        windowWidth: sometingOrElse(0.01, account.windowWidth! ~/ 2, account.windowWidth!),
        windowHeight: sometingOrElse(0.01, account.windowHeight! ~/ 2, account.windowHeight!),
      ),
      'x-bili-device-req-json': '{"platform":"web","device":"pc","spmid":"333.1387"}',
    };
    final (String wts, String wbiSign) = encWbi(params, account.wbiImgKey!, account.wbiSubKey!);

    final resp = await client.get(
      'https://api.bilibili.com/x/polymer/web-dynamic/v1/feed/space',
      queryParameters: {
        ...params,
        'w_rid': wbiSign,
        'wts': wts,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(
      GetUserPostsResponse(
        list: (resp.data['data']['items'] as List).map((v) => Post.fromJson(v)).toList(),
        hasMore: resp.data['data']['has_more'] as bool,
        nextOffset: resp.data['data']['offset'].isEmpty ? null : resp.data['data']['offset'],
      ),
    );
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

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/dynamic/feed/dynamic_report/add',
      queryParameters: {
        'csrf': account.biliJct,
      },
      options: Options(
        headers: {
          'content-type': 'application/json',
        },
      ),
      data: jsonEncode({
        'accused_uid': userId,
        'dynamic_id': postId,
        'reason_type': reasonId,
        'reason_desc': reason,
      }),
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }
}
