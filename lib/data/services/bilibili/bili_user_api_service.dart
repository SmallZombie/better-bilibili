import 'dart:convert';

import 'package:better_bilibili/data/model/bilibili/movie_model.dart';
import 'package:better_bilibili/data/repositories/bilibili/auth_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_fans_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorite_articles_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_detail_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_simple_list_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_following_users.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_liked_videos_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_self_status_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_subscribed_manga.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_subscribed_movie_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_subscribed_playlists_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_subscribed_series_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_card_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_counters_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_info_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_pinned_videos_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_profile_settings_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_relation_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_stats_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_total_like_and_view_count_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_watch_history.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_watch_later.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/utils/bili_util.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

class BiliUserApiService {
  final Logger _log = Logger('BiliUserApiService');
  final AuthRepository _authRepository;

  BiliUserApiService({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  Future<Result<GetUserInfoResponse>> getUserInfo({required String userId}) async {
    assert(userId.isNotEmpty);

    final client = await _authRepository.getClient();
    final account = await _authRepository.getAccount();

    final params = {
      'mid': userId,
      'token': '',
      'platform': 'web',
      'web_location': WebLocation.userSpace_2,
      // 此接口使用场景不存在回退元素，故此字段可以为空数组
      'dm_img_list': '[]',
      'dm_img_str': getDmImgStr(),
      'dm_cover_img_str': getDmCoverImgStr(),
      'dm_img_inter': getDmImgInter(
        windowWidth: sometingOrElse(0.01, account.windowWidth! ~/ 2, account.windowWidth!),
        windowHeight: sometingOrElse(0.01, account.windowHeight! ~/ 2, account.windowHeight!),
      ),
    };
    final (String wts, String wbiSign) = encWbi(params, account.wbiImgKey!, account.wbiSubKey!);
    final resp = await client.get(
      'https://api.bilibili.com/x/space/wbi/acc/info',
      queryParameters: {
        ...params,
        'w_rid': wbiSign,
        'wts': wts,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(GetUserInfoResponse.fromJson(resp.data['data']));
  }

  Future<Result<GetSelfStatsResponse>> getSelfStats() async {
    final client = await _authRepository.getClient();
    final resp = await client.get(
      'https://api.bilibili.com/x/web-interface/nav/stat',
      queryParameters: {
        'web_location': WebLocation.home,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(
      GetSelfStatsResponse(
        dynamicCount: resp.data['data']['dynamic_count'],
        followCount: resp.data['data']['following'],
        fansCount: resp.data['data']['follower'],
      ),
    );
  }

  /// 解析与观看列表有关接口的 data.list 响应
  ///
  /// 返回值可能包含 [WatchHistoryVideo] | [WatchHistoryLive] | [WatchHistoryArticle] | [WatchHistoryMovie] | [WatchHistoryCourse]
  List<dynamic> _parseWatchHistoryResponse(List<dynamic> list) {
    final List<dynamic> result = [];

    for (final item in list) {
      if (item['history']['business'] == 'archive') {
        result.add(WatchHistoryVideo.fromJson(item));
      } else if (item['history']['business'] == 'live') {
        result.add(WatchHistoryLive.fromJson(item));
      } else if (item['history']['business'] == 'article') {
        result.add(WatchHistoryArticle.fromJson(item));
      } else if (item['history']['business'] == 'article-list') {
        result.add(WatchHistoryAnthology.fromJson(item));
      } else if (item['history']['business'] == 'pgc') {
        result.add(WatchHistoryMovie.fromJson(item));
      } else if (item['history']['business'] == 'cheese') {
        result.add(WatchHistoryCourse.fromJson(item));
      } else {
        _log.warning('Unknown business: ${item['history']['business']}');
      }
    }

    return result;
  }

  /// 获取观看历史列表
  ///
  /// 此接口使用游标分页，仅支持筛选类型，需要其他筛选条件请使用 [getWatchHistoryWithFilter]
  ///
  /// 返回值可能包含 [WatchHistoryVideo] | [WatchHistoryLive] | [WatchHistoryArticle] | [WatchHistoryMovie] | [WatchHistoryCourse]
  Future<Result<GetWatchHistoryResponse>> getWatchHistory({
    int nextCursor = 0,
    int viewAt = 0,
    GetWatchHistoryTypeEnum type = GetWatchHistoryTypeEnum.all,
    int ps = 20,
  }) async {
    assert(ps > 0);

    final client = await _authRepository.getClient();
    final resp = await client.get(
      'https://api.bilibili.com/x/web-interface/history/cursor',
      queryParameters: {
        'max': nextCursor,
        'view_at': viewAt,
        // 这个字段在这里很迷
        // 第一页时无论 type 是什么，都为空字符串
        // 非第一页时如果 tpye = all 此值为 archive，否则此值等同于 type
        'business': nextCursor == 0
            ? ''
            : type == GetWatchHistoryTypeEnum.all
            ? 'archive'
            : type.value,
        'ps': ps,
        'type': type.value,
        'web_location': WebLocation.watchHistory,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    final List<dynamic> list = _parseWatchHistoryResponse(resp.data['data']['list']);

    return Result.ok(
      GetWatchHistoryResponse(
        list: list,
        nextCursor: resp.data['data']['cursor']['max'] as int,
        // 本来游标分页只要一个 next_cursor 就可以了
        // 但这个接口返回了其他不知道干什么用的东西，也需要一并传入下一次请求
        viewAt: resp.data['data']['cursor']['view_at'] as int,
      ),
    );
  }

  /// 获取观看历史，支持更多查询条件
  ///
  /// 使用 pn 分页，ps 固定为 20
  ///
  /// - `pn`: 页码，最小为 1
  /// - `keyword`: 关键词
  /// - `type`: 类型
  /// - `minDuration`: 最小时长，单位秒
  /// - `maxDuration`: 最大时长，单位秒
  /// - `minUploadTime`: 最小上传时间，秒级时间戳
  /// - `maxUploadTime`: 最大上传时间，秒级时间戳
  /// - `deviceType`: 设备类型
  ///
  /// 返回值同 [getWatchHistory]
  Future<Result<GetWatchHistoryWithFilterResult>> getWatchHistoryWithFilter({
    int pn = 1,
    String keyword = '',
    GetWatchHistoryWithFilterTypeEnum type = GetWatchHistoryWithFilterTypeEnum.all,
    int minDuration = 0,
    int maxDuration = 0,
    int minUploadTime = 0,
    int maxUploadTime = 0,
    GetWatchHistoryWithFilterDeviceTypeEnum deviceType = GetWatchHistoryWithFilterDeviceTypeEnum.all,
  }) async {
    assert(pn > 0);
    assert(minDuration >= 0 && maxDuration >= 0 && minUploadTime >= 0 && maxUploadTime >= 0);

    final client = await _authRepository.getClient();
    final result = await client.get(
      'https://api.bilibili.com/x/web-interface/history/search',
      queryParameters: {
        'pn': pn,
        'keyword': keyword,
        'business': type.value,
        'add_time_start': minUploadTime,
        'add_time_end': maxUploadTime,
        'arc_max_duration': maxDuration,
        'arc_min_duration': minDuration,
        'device_type': deviceType.value,
        'web_location': WebLocation.watchHistory,
      },
    );

    if (result.data['code'] != 0) {
      return Result.error(Exception('${result.data['code']}: ${result.data['message']}'));
    }

    final List<dynamic> list = _parseWatchHistoryResponse(result.data['data']['list'] ?? []);

    return Result.ok(
      GetWatchHistoryWithFilterResult(
        list: list,
        hasMore: result.data['data']['has_more'] as bool,
      ),
    );
  }

  /// 获取观看历史配置，目前只有是否启用记录
  Future<Result<bool>> getWatchHistoryConfig() async {
    final client = await _authRepository.getClient();
    final resp = await client.get('https://api.bilibili.com/x/v2/history/shadow');

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    // 没错b站这个接口获取的是禁用状态，=true时为禁用
    return Result.ok(resp.data['data'] == false);
  }

  /// 设置观看历史配置，目前只有是否启用记录
  Future<Result<void>> setWatchHistoryConfig({required bool enable}) async {
    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();
    final resp = await client.post(
      'https://api.bilibili.com/x/v2/history/shadow/set',
      options: Options(
        contentType: 'application/x-www-form-urlencoded',
      ),
      data: {'switch': enable == false, 'csrf': account.biliJct},
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 删除历史记录，支持批量删除
  ///
  /// id格式：`<type>_<id>`，type 详见 [GetWatchHistoryWithFilterTypeEnum.value]
  Future<Result<void>> deleteWatchHistory({required List<String> ids}) async {
    assert(ids.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();
    final resp = await client.post(
      'https://api.bilibili.com/x/v2/history/delete',
      options: Options(contentType: 'application/x-www-form-urlencoded'),
      data: {'kid': ids.join(','), 'csrf': account.biliJct},
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 清除观看历史
  Future<Result<void>> clearWatchHistory() async {
    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();
    final resp = await client.post(
      'https://api.bilibili.com/x/v2/history/clear',
      options: Options(contentType: 'application/x-www-form-urlencoded'),
      data: {
        'business': '',
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 获取稍后观看列表
  ///
  /// 使用 ps+pn+total 分页
  ///
  /// 返回值可能包含 [WatchLaterVideoSummary] | [WatchLaterMovieSummary]
  /// order 排序方式，默认为添加时间降序
  Future<Result<GetWatchLaterResponse>> getWatchLater({
    int pn = 1,
    int ps = 20,
    GetWatchLaterOrderEnum order = GetWatchLaterOrderEnum.addTimeDesc,
    bool onlyUnwatched = false,
    int? minAddTime,
    int? maxAddTime,
    int? minDuration,
    int? maxDuration,
    String? keyword,
  }) async {
    assert(pn > 0 && ps > 0);

    final params = {
      'pn': pn,
      'ps': ps,
      // 0 = 全部，2 = 已观看，是的没有未观看只有已观看
      'viewed': onlyUnwatched ? 2 : 0,
      'key': keyword ?? '',
      'asc': order == GetWatchLaterOrderEnum.addTimeAsc,
      'need_split': true,
      'web_location': WebLocation.watchLater,
    };

    if (minAddTime != null || maxAddTime != null) {
      params['add_time_start'] = minAddTime!;
      params['add_time_end'] = maxAddTime!;
    }

    if (minDuration != null || maxDuration != null) {
      params['arc_min_duration'] = minDuration!;
      params['arc_max_duration'] = maxDuration!;
    }

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();
    final (String wts, String wbiSign) = encWbi(params, account.wbiImgKey!, account.wbiSubKey!);
    final resp = await client.get(
      'https://api.bilibili.com/x/v2/history/toview/web',
      queryParameters: {
        ...params,
        'w_rid': wbiSign,
        'wts': wts,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    final List<dynamic> list = [];
    for (final item in resp.data['data']['list']) {
      if (item['is_pgc'] as bool) {
        list.add(WatchLaterMovie.fromJson(item));
      } else {
        list.add(WatchLaterVideo.fromJson(item));
      }
    }

    return Result.ok(GetWatchLaterResponse(list: list, total: resp.data['data']['count'] as int));
  }

  /// 检查视频是否位于稍后观看
  ///
  /// 由于b站并没有直接实现此功能的接口，所以此函数实际使用 [getWatchLater] 来实现，
  /// 且此接口只根据第一页搜索结果判断，如果视频名过于常见可能会导致本位于稍后观看的视频在此接口返回 false
  Future<Result<bool>> isExistInWatchLater({required String id, required String title}) async {
    assert(id.isNotEmpty);
    assert(title.isNotEmpty);

    final result = await getWatchLater(keyword: title);
    switch (result) {
      case Ok(:final value):
        bool isExist = false;
        for (final item in value.list) {
          if (item is WatchLaterVideo) {
            if (item.id == id && item.title == title) {
              isExist = true;
              break;
            }
          } else if (item is WatchLaterMovie) {
            if (item.id == id && item.title == title) {
              isExist = true;
              break;
            }
          } else {
            _log.warning('Unknown item type: ${item.runtimeType}');
          }
        }
        return Result.ok(isExist);
      case Error():
        return Result.error(result.error);
    }
  }

  /// 将项目从稍后观看拷贝到收藏夹，支持批量操作
  Future<Result<void>> copyFromWatchLaterToFavorites({
    required List<String> ids,
    required String targetFavoritesId,
  }) async {
    assert(ids.isNotEmpty);
    assert(targetFavoritesId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();
    final (String wts, String wbiSign) = encWbi({}, account.wbiImgKey!, account.wbiSubKey!);
    final resp = await client.post(
      'https://api.bilibili.com/x/v2/history/toview/copy',
      queryParameters: {'wts': wts, 'w_rid': wbiSign},
      data: FormData.fromMap(
        {
          'resources': ids.join(','),
          'tar_media_id': targetFavoritesId,
          'csrf': account.biliJct,
        },
        ListFormat.multi,
        false,
        generateBoundaryName(),
      ),
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 将项目从稍后观看移动到收藏夹，支持批量操作
  Future<Result<void>> moveFromWatchLaterToFavorites({
    required List<String> ids,
    required String targetFavoritesId,
  }) async {
    assert(ids.isNotEmpty);
    assert(targetFavoritesId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();
    final (String wts, String wbiSign) = encWbi({}, account.wbiImgKey!, account.wbiSubKey!);
    final resp = await client.post(
      'https://api.bilibili.com/x/v2/history/toview/move',
      queryParameters: {'wts': wts, 'w_rid': wbiSign},
      data: FormData.fromMap(
        {
          'resources': ids.join(','),
          'tar_media_id': targetFavoritesId,
          'csrf': account.biliJct,
        },
        ListFormat.multi,
        false,
        generateBoundaryName(),
      ),
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 清理稍后观看所有已看完内容
  Future<Result<void>> clearWatchedInWatchLater() async {
    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();
    final (String wts, String wbiSign) = encWbi({}, account.wbiImgKey!, account.wbiSubKey!);
    final resp = await client.post(
      'https://api.bilibili.com/x/v2/history/toview/clear',
      queryParameters: {'wts': wts, 'w_rid': wbiSign},
      data: FormData.fromMap(
        {
          'clean_type': 2,
          'csrf': account.biliJct,
        },
        ListFormat.multi,
        false,
        generateBoundaryName(),
      ),
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 添加视频到稍后观看
  Future<Result<void>> addVideoToWatchLater({required String videoId}) async {
    assert(videoId.isNotEmpty);

    final client = await _authRepository.getClient();
    final account = await _authRepository.getAccount();
    final resp = await client.post(
      'https://api.bilibili.com/x/v2/history/toview/add',
      data: FormData.fromMap({
        'aid': videoId,
        'csrf': account.biliJct,
      }),
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 从稍后观看中删除视频，支持批量操作
  ///
  /// 与观看历史所使用的 id 不同，此处为常规 `videoId`
  ///
  /// 你可能会好奇番剧在这里是怎么处理的，详见开发文档 [B站番剧部分的工作原理]
  Future<Result<void>> deleteVideosFromWatchLater({required List<String> ids}) async {
    assert(ids.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();
    final (String wts, String wbiSign) = encWbi({}, account.wbiImgKey!, account.wbiSubKey!);
    final resp = await client.post(
      'https://api.bilibili.com/x/v2/history/toview/v2/dels',
      queryParameters: {'wts': wts, 'w_rid': wbiSign},
      data: FormData.fromMap(
        {'resources': ids.join(','), 'csrf': account.biliJct},
        ListFormat.multi,
        false,
        generateBoundaryName(),
      ),
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 获取收藏夹列表，此接口返回封面图，但不能一次性返回
  ///
  /// 如果你需要一次性获取全部收藏夹，请使用 [getFavoritesSimpleList]
  ///
  /// 使用 ps+pn+total 分页
  Future<Result<GetFavoritesResponse>> getFavoritesList({
    String? userId,
    int pn = 1,
    int ps = 20,
  }) async {
    assert(pn > 0 && ps > 0);

    final client = await _authRepository.getClient();
    String? uid = userId;
    if (uid == null) {
      final account = await _authRepository.getAccount();
      uid = account.uid;
    }
    assert(uid.isNotEmpty);

    final resp = await client.get(
      'https://api.bilibili.com/x/v3/fav/folder/created/list',
      queryParameters: {
        'up_mid': uid,
        'pn': pn,
        'ps': ps,
        'web_location': WebLocation.userSpace,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    final List<Favorites> list = [];
    for (final item in resp.data['data']['list']) {
      list.add(Favorites.fromJson(item));
    }

    return Result.ok(
      GetFavoritesResponse(
        list: list,
        total: resp.data['data']['count'] as int,
        hasMore: resp.data['data']['has_more'] as bool,
      ),
    );
  }

  /// 获取收藏夹列表，此接口不返回封面图，但可一次性返回全部
  ///
  /// 如果你需要封面图，请使用 [getFavoritesList]
  ///
  /// 携带 [videoId] 时会在第二个返回值中返回包含该视频的收藏夹 id
  Future<Result<GetFavoritesSimpleListResponse>> getFavoritesSimpleList({
    String? userId,
    String? videoId,
  }) async {
    final client = await _authRepository.getClient();

    String? uid = userId;
    if (userId == null) {
      final account = await _authRepository.getAccount();
      uid = account.uid;
    }

    assert(uid != null && uid.isNotEmpty);

    final resp = await client.get(
      'https://api.bilibili.com/x/v3/fav/folder/created/list-all',
      queryParameters: {
        'type': 2,
        'rid': videoId ?? '',
        'up_mid': uid,
        'web_location': '333.788',
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    final List<SimpleFavorites> list = [];
    final List<String> ids = [];

    for (final item in resp.data['data']['list']) {
      list.add(SimpleFavorites.fromJson(item));
      if (item['fav_state'] == 1) {
        ids.add(item['id'].toString());
      }
    }

    return Result.ok(GetFavoritesSimpleListResponse(list: list, ids: ids));
  }

  /// 创建收藏夹
  Future<Result<Favorites>> createFavorites({
    required String name,
    String? description,
    bool isPrivate = false,
    String? coverUrl,
  }) async {
    assert(name.isNotEmpty);

    final client = await _authRepository.getClient();
    final account = await _authRepository.getAccount();

    final resp = await client.post(
      'https://api.bilibili.com/x/v3/fav/folder/add',
      options: Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
      data: {
        'title': name,
        'intro': description,
        'privacy': isPrivate ? 1 : 0,
        'cover': coverUrl ?? '',
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(Favorites.fromJson(resp.data['data']));
  }

  /// 修改收藏夹，必须带上全量的参数请求，而不是只携带修改过的参数
  Future<Result<void>> modifyFavorites({
    required String favoritesId,
    required String name,
    String? description,
    bool isPrivate = false,
    String? coverUrl,
  }) async {
    assert(favoritesId.isNotEmpty && name.isNotEmpty);

    final client = await _authRepository.getClient();
    final account = await _authRepository.getAccount();

    final resp = await client.post(
      'https://api.bilibili.com/x/v3/fav/folder/add',
      options: Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
      data: {
        'media_id': favoritesId,
        'title': name,
        'intro': description,
        'privacy': isPrivate ? 1 : 0,
        'cover': coverUrl ?? '',
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 删除收藏夹
  Future<Result<void>> deleteFavorites({required String favoritesId}) async {
    assert(favoritesId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/v3/fav/folder/del',
      options: Options(
        headers: {'Content-Type': 'multipart/form-data; boundary=${generateBoundaryName2()}'},
      ),
      data: FormData.fromMap({
        'media_ids': favoritesId,
        'platform': 'web',
        'csrf': account.biliJct,
      }),
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 重新排序收藏夹
  Future<Result<void>> reorderFavorites({
    required List<String> ids,
  }) async {
    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/v3/fav/folder/sort',
      queryParameters: {
        'sort': ids.join(','),
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 获取收藏夹详细信息及其内容列表
  ///
  /// 使用 `pn`+`ps`+`hasMore` 翻页
  ///
  /// [favoritesId]: 只有当此参数存在时B站才会返回 `info`，才能拿到 `info.total`，此参数也被用作归属判断，
  /// 传入收藏夹ID或传入任意收藏夹ID+withAll来在全部收藏夹中搜索
  ///
  /// 可用排序方式：`favorite_time_desc` = 收藏时间降序(默认)，`view_desc` = 播放量降序，`release_time_desc` = 发布时间降序
  ///
  /// 返回值包含: [FavoritesVideo] | [FavoritesMovie]
  ///
  /// 注意当存在 `keyword` 时，`total` 为筛选后的总内容数，而不是收藏夹的总内容数(这是人能写出来的接口?)，此时没办法拿到总数，需要提前缓存
  Future<Result<GetFavoritesDetailResponse>> getFavoritesDetail({
    required String favoritesId,
    int pn = 1,
    int ps = 20,
    GetFavoritesDetailOrderEnum order = GetFavoritesDetailOrderEnum.favoriteTimeDesc,
    String? keyword,
    GetFavoritesDetailScopeEnum scope = GetFavoritesDetailScopeEnum.local,
  }) async {
    assert(pn > 0 && ps > 0);

    final client = await _authRepository.getClient();
    final resp = await client.get(
      'https://api.bilibili.com/x/v3/fav/resource/list',
      queryParameters: {
        'media_id': favoritesId,
        'pn': pn,
        'ps': ps,
        'keyword': keyword ?? '',
        'order': order.value,
        // 为1时为在全部收藏夹中搜索
        'type': scope.value,
        'tid': 0,
        'platform': 'web',
        'web_location': WebLocation.userSpace,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    final List<dynamic> list = [];
    for (final item in resp.data['data']['medias'] ?? []) {
      if (item['ugc'] != null) {
        // 视频
        list.add(FavoritesVideo.fromJson(item));
      } else {
        // 番剧
        list.add(FavoritesMovie.fromJson(item));
      }
    }

    return Result.ok(GetFavoritesDetailResponse.fromJson(resp.data['data'], list));
  }

  /// 将收藏夹内容复制到另一个收藏夹
  ///
  /// 注意此接口使用的id格式为 `<id>:<type>`，视频 type 为 2，番剧为 24
  ///
  /// 注意此接口不可以跨收藏夹操作，传入的 [ids] 必须位于 [sourceFavoritesId]，[targetFavoritesId] 也必须有效，
  /// B站完全没做相应的功能，网页端只是做做样子，包括移动和删除也是一样
  Future<Result<void>> copyFavoritesVideos({
    required List<String> ids,
    required String sourceFavoritesId,
    required String targetFavoritesId,
  }) async {
    assert(ids.isNotEmpty);
    assert(sourceFavoritesId.isNotEmpty && targetFavoritesId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/v3/fav/resource/copy',
      options: Options(contentType: 'application/x-www-form-urlencoded'),
      data: {
        'resources': ids.join(','),
        'src_media_id': sourceFavoritesId,
        'tar_media_id': targetFavoritesId,
        'mid': account.uid,
        'platform': 'web',
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 将收藏夹内容移动到另一个收藏夹
  ///
  /// 注意此接口使用的id格式为 `<id>:<type>`，视频 type 为 2，番剧为 24
  ///
  /// 注意此接口不可以跨收藏夹操作，传入的 [ids] 必须位于 [sourceFavoritesId]，[targetFavoritesId] 也必须有效，
  /// B站完全没做相应的功能，网页端只是做做样子，包括复制和删除也是一样
  Future<Result<void>> moveFavoritesVideos({
    required List<String> ids,
    required String sourceFavoritesId,
    required String targetFavoritesId,
  }) async {
    assert(ids.isNotEmpty);
    assert(sourceFavoritesId.isNotEmpty && targetFavoritesId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/v3/fav/resource/move',
      options: Options(contentType: 'application/x-www-form-urlencoded'),
      data: {
        'resources': ids.join(','),
        'src_media_id': sourceFavoritesId,
        'tar_media_id': targetFavoritesId,
        'mid': account.uid,
        'platform': 'web',
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 从收藏夹中删除内容
  ///
  /// 注意此接口使用的id格式为 `<id>:<type>`，视频 type 为 2，番剧为 24
  ///
  /// 注意此接口不可以跨收藏夹操作，传入的 [ids] 必须存在于 [favoritesId]，
  /// B站完全没做相应的功能，网页端只是做做样子，包括复制和移动也是一样
  Future<Result<void>> deleteFavoritesVideos({
    required String favoritesId,
    required List<String> ids,
  }) async {
    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/v3/fav/resource/batch-del',
      options: Options(contentType: 'application/x-www-form-urlencoded'),
      data: {
        'resources': ids.join(','),
        'media_id': favoritesId,
        'platform': 'web',
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 清理收藏夹所有失效内容
  Future<Result<void>> clearInvalidInFavorites({required String favoritesId}) async {
    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/v3/fav/resource/clean',
      options: Options(contentType: 'application/x-www-form-urlencoded'),
      data: {
        'media_id': favoritesId,
        'platform': 'web',
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 按指定收藏夹添加或删除内容
  ///
  /// [addIds] 和 [deleteIds] 必须至少存在一项
  Future<Result<void>> updateFavoritesVideo({
    required String videoId,
    List<String>? addIds,
    List<String>? deleteIds,
  }) async {
    assert(videoId.isNotEmpty);
    assert((addIds?.isNotEmpty ?? false) || (deleteIds?.isNotEmpty ?? false));

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/v3/fav/resource/deal',
      options: Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
      data: {
        'rid': videoId,
        'type': 2,
        'add_media_ids': addIds?.join(',') ?? '',
        'del_media_ids': deleteIds?.join(',') ?? '',
        'platform': 'web',
        'from_spmid': '',
        'spmid': '333.788.0.0',
        'statistics': '{"appId":100,"platform":5}',
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 获取收藏文章列表，与收藏夹不同，文章无法获取他人收藏，B站就是这样设计的
  ///
  /// 使用 pn+ps+hasMore 翻页
  Future<Result<GetFavoriteArticlesResponse>> getFavoriteArticles({
    int pn = 1,
    int ps = 20,
  }) async {
    assert(pn > 0 && ps > 0);

    final client = await _authRepository.getClient();
    final resp = await client.get(
      // 目前新版接口是下面这个，但新接口只有 content，没有 title，也没有失效内容，故使用老接口
      // 'https://api.bilibili.com/x/polymer/web-dynamic/v1/opus/feed/fav',
      'https://api.bilibili.com/x/polymer/web-dynamic/v1/opus/favlist',
      queryParameters: {
        'page': pn,
        'page_size': ps,
        'timezone_offset': '-480',
        'web_location': WebLocation.userSpace,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    final list = (resp.data['data']['items'] as List).map((v) => FavoriteArticle.fromJson(v));
    return Result.ok(
      GetFavoriteArticlesResponse(
        total: resp.data['data']['total'] as int,
        hasMore: resp.data['data']['has_more'] as bool,
        list: list.toList(),
      ),
    );
  }

  /// 删除收藏的动态
  ///
  /// 不支持批量，虽然B站APP端支持但我扒不出来接口
  Future<Result<void>> deleteFavoritePost({required String postId}) async {
    assert(postId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/community/cosmo/interface/simple_action',
      options: Options(contentType: 'application/json'),
      queryParameters: {
        'csrf': account.biliJct,
      },
      data: jsonEncode({
        'meta': {'spmid': '333.999.0.0', 'from': 'unknown'},
        'entity': {
          'object_id_str': postId,
          'type': {'biz': 2},
        },
        'action': 4,
      }),
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 获取所有订阅的收藏和播放列表
  ///
  /// 使用 pn+ps+hasMore 分页，此处 `ps` 对齐网页端的默认值 50
  ///
  /// 返回值可能包含 [SubscribedFavorites] | [SubscribedPlaylist]
  Future<Result<GetSubscribedPlaylistsResponse>> getSubscribedPlaylists({
    required String userId,
    int pn = 1,
    int ps = 50,
  }) async {
    assert(userId.isNotEmpty);
    assert(pn > 0 && ps > 0);

    final client = await _authRepository.getClient();

    final resp = await client.get(
      'https://api.bilibili.com/x/v3/fav/folder/collected/list',
      queryParameters: {
        'pn': pn,
        'ps': ps,
        'up_mid': userId,
        'platform': 'web',
        'web_location': WebLocation.userSpace,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    final List<dynamic> list = [];
    for (final item in resp.data['data']['list']) {
      if (item['type'] == 11) {
        list.add(SubscribedFavorites.fromJson(item));
      } else if (item['type'] == 21) {
        list.add(SubscribedPlaylist.fromJson(item));
      } else {
        throw Exception('Unknown type: ${item['type']}');
      }
    }

    return Result.ok(
      GetSubscribedPlaylistsResponse(
        total: resp.data['data']['count'] as int,
        hasMore: resp.data['data']['has_more'] as bool,
        list: list,
      ),
    );
  }

  /// 退订收藏夹
  Future<Result<void>> unsubscribeFavorites({required String favoritesId}) async {
    assert(favoritesId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/v3/fav/folder/unfav',
      queryParameters: {
        'media_id': favoritesId,
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 退订播放列表
  Future<Result<void>> unsubscribePlaylist({required String playlistId}) async {
    assert(playlistId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/v3/fav/season/unfav',
      queryParameters: {
        'season_id': playlistId,
        'platform': 'web',
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 获取所有订阅的剧集
  ///
  /// 使用 pn+ps+total 分页
  Future<Result<GetSubscribedSeriesResponse>> getSubscribedSeries({
    String? userId,
    int pn = 1,
    int ps = 20,
    GetSubscribedSeriesWatchStatusEnum watchStatus = GetSubscribedSeriesWatchStatusEnum.all,
  }) async {
    assert(userId == null || userId.isNotEmpty);
    assert(pn > 0 && ps > 0);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final params = {
      'vmid': userId ?? account.uid,
      'type': 1,
      'pn': pn,
      'ps': ps,
      'playform': 'web',
      'follow_status': watchStatus.value,
      'web_location': WebLocation.userSpace,
    };
    final (String wts, String wbiSign) = encWbi(params, account.wbiImgKey!, account.wbiSubKey!);
    final resp = await client.get(
      'https://api.bilibili.com/x/space/bangumi/follow/list',
      queryParameters: {
        ...params,
        'w_rid': wbiSign,
        'wts': wts,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    final List<SubscribedSeries> list = [];
    for (final item in resp.data['data']['list']) {
      list.add(SubscribedSeries.fromJson(item));
    }

    return Result.ok(
      GetSubscribedSeriesResponse(
        total: resp.data['data']['total'] as int,
        list: list,
      ),
    );
  }

  /// 修改订阅剧集的观看状态
  Future<Result<void>> modifySeriesWatchStatus({
    required String seriesId,
    required MovieWatchStatus watchStatus,
  }) async {
    assert(seriesId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/pgc/web/follow/status/update',
      queryParameters: {
        'season_id': seriesId,
        'status': watchStatus.value,
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 退订剧集
  Future<Result<void>> unsubscribeSeries({required String seriesId}) async {
    assert(seriesId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/pgc/web/follow/del',
      queryParameters: {
        'season_id': seriesId,
        'season_type': 1,
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 获取所有订阅的电影
  ///
  /// 使用 pn+ps+total 分页
  Future<Result<GetSubscribedMovieResponse>> getSubscribedMovie({
    String? userId,
    int pn = 1,
    int ps = 20,
    GetSubscribedSeriesWatchStatusEnum watchStatus = GetSubscribedSeriesWatchStatusEnum.all,
  }) async {
    assert(userId == null || userId.isNotEmpty);
    assert(pn > 0 && ps > 0);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final params = {
      'vmid': userId ?? account.uid,
      'type': 2,
      'pn': pn,
      'ps': ps,
      'playform': 'web',
      'follow_status': watchStatus.value,
      'web_location': WebLocation.userSpace,
    };
    final (String wts, String wbiSign) = encWbi(params, account.wbiImgKey!, account.wbiSubKey!);
    final resp = await client.get(
      'https://api.bilibili.com/x/space/bangumi/follow/list',
      queryParameters: {
        ...params,
        'w_rid': wbiSign,
        'wts': wts,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    final List<SubscribedMovie> list = [];
    for (final item in resp.data['data']['list']) {
      list.add(SubscribedMovie.fromJson(item));
    }

    return Result.ok(
      GetSubscribedMovieResponse(
        total: resp.data['data']['total'] as int,
        list: list,
      ),
    );
  }

  /// 修改订阅电影的观看状态
  Future<Result<void>> modifyMovieWatchStatus({
    required String movieId,
    required MovieWatchStatus watchStatus,
  }) async {
    assert(movieId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/pgc/web/follow/status/update',
      queryParameters: {
        'season_id': movieId,
        'status': watchStatus.value,
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 退订电影
  Future<Result<void>> unsubscribeMovie({required String movieId}) async {
    assert(movieId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/pgc/web/follow/del',
      queryParameters: {
        'season_id': movieId,
        'season_type': 2,
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 获取订阅的漫画
  ///
  /// 使用 pn+ps+hasMore 分页
  ///
  /// 此接口最后一页会返回一个空列表并带有 hasMore=false，
  /// 因为B站不给 total 也不给 hasMore，只能通过列表是否为空来判断是否到头了
  Future<Result<GetSubscribedMangaResponse>> getSubscribedManga({
    int pn = 1,
    int ps = 20,
    GetSubscribedMangaOrderEnum order = GetSubscribedMangaOrderEnum.subscribeDesc,
    bool waitFree = false,
  }) async {
    assert(pn > 0 && ps > 0);

    final client = await _authRepository.getClient();
    final resp = await client.post(
      'https://manga.bilibili.com/twirp/bookshelf.v1.Bookshelf/ListFavorite',
      options: Options(
        headers: {
          'Content-Type': 'application/json;charset=UTF-8',
        },
      ),
      queryParameters: {
        'device': 'pc',
        'platform': 'web',
        // 这俩什么玩意懒得研究了
        'nov': 27,
        'a': 810,
      },
      data: jsonEncode({
        'page_num': pn,
        'page_size': ps,
        'order': GetSubscribedMangaOrderEnum.subscribeDesc.value,
        // 这个在网页端叫 "完成等免"，不知道是什么先做了再说
        'wait_free': waitFree ? 1 : 0,
      }),
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    final List<SubscribedManga> list = [];
    for (final item in resp.data['data']) {
      list.add(SubscribedManga.fromJson(item));
    }

    return Result.ok(
      GetSubscribedMangaResponse(
        hasMore: list.isNotEmpty,
        list: list,
      ),
    );
  }

  /// 退订漫画，支持批量
  Future<Result<void>> unsubscribeManga({required List<String> mangaIds}) async {
    assert(mangaIds.isNotEmpty);

    final client = await _authRepository.getClient();
    final resp = await client.post(
      'https://manga.bilibili.com/twirp/bookshelf.v1.Bookshelf/DeleteFavorite',
      queryParameters: {
        'device': 'pc',
        'platform': 'web',
        'nov': 27,
        'a': 810,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json;charset=UTF-8',
        },
      ),
      data: jsonEncode({
        'comic_ids': mangaIds.join(','),
      }),
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 获取对视频的互动信息
  Future<Result<VideoInteraction>> getVideoInteraction({required String videoId}) async {
    assert(videoId.isNotEmpty);

    final client = await _authRepository.getClient();
    final resp = await client.get(
      'https://api.bilibili.com/x/web-interface/archive/relation',
      queryParameters: {
        'aid': videoId,
        'bvid': av2bv(videoId),
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(
      VideoInteraction(
        hasLiked: resp.data['data']['like'],
        hasDisliked: resp.data['data']['dislike'],
        hasFavorited: resp.data['data']['favorite'],
        coinCount: resp.data['data']['coin'],
        hasFollowed: resp.data['data']['attention'],
        isSubscribedCollection: resp.data['data']['season_fav'],
      ),
    );
  }

  /// 关注/取消关注用户
  Future<Result<void>> followUser({
    required String userId,
    required bool follow,
  }) async {
    assert(userId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/relation/modify',
      options: Options(
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      ),
      queryParameters: {'statistics': '{"appId":100,"platform":5}'},
      data: {
        // 此函数模拟从用户主页关注/取消关注用户，如果需要模拟从其他地方关注，比如视频详情页，需要成套替换下面的参数！
        'fid': userId,
        'act': follow ? 1 : 2,
        're_src': 11,
        'gaia_source': 'main_web',
        'spmid': WebLocation.userSpace,
        'extend_content': '{"entity":"user","entity_id":$userId}',
        'is_from_frontend_component': true,
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 获取用户最后点赞的20个视频
  ///
  /// 未传入 [userId] 则获取当前登录用户的点赞视频
  ///
  /// 返回值可能为 [LikedVideo] | [LikedMovie] | [LikedSeries]
  Future<Result<List<dynamic>>> getLikedVideos({String? userId}) async {
    assert(userId == null || userId.isNotEmpty);

    final uid = switch (userId) {
      null => (await _authRepository.getAccount()).uid,
      _ => userId,
    };

    final client = await _authRepository.getClient();
    final resp = await client.get(
      'https://api.bilibili.com/x/space/like/video',
      queryParameters: {'vmid': uid, 'web_location': WebLocation.userSpace},
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    final List<dynamic> list = [];
    for (final item in resp.data['data']['list']) {
      if (item['resource_type'] == 'ugc') {
        // 视频
        list.add(LikedVideo.fromJson(item));
      } else if (item['redirect_url'].contains('?theme=movie')) {
        // 电影
        list.add(LikedMovie.fromJson(item));
      } else if (item['resource_type'] == 'ogv') {
        // 剧集
        list.add(LikedSeries.fromJson(item));
      } else {
        _log.warning('Unknown resource type: ${item['resource_type']}');
      }
    }

    return Result.ok(list);
  }

  /// 获取用户最后投币的20个视频
  ///
  /// 未传入 [userId] 则获取当前登录用户的投币视频
  ///
  /// 返回值可能为 [LikedVideo] | [LikedMovie] | [LikedSeries]
  Future<Result<List<dynamic>>> getCoinedVideos({String? userId}) async {
    assert(userId == null || userId.isNotEmpty);

    final uid = switch (userId) {
      null => (await _authRepository.getAccount()).uid,
      _ => userId,
    };

    final client = await _authRepository.getClient();
    final resp = await client.get(
      'https://api.bilibili.com/x/space/coin/video',
      queryParameters: {'vmid': uid, 'web_location': WebLocation.userSpace},
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    final List<dynamic> list = [];
    for (final item in resp.data['data']) {
      if (item['resource_type'] == 'ugc') {
        // 视频
        list.add(LikedVideo.fromJson(item));
      } else if (item['redirect_url'].contains('?theme=movie')) {
        // 电影
        list.add(LikedMovie.fromJson(item));
      } else if (item['resource_type'] == 'ogv') {
        // 剧集
        list.add(LikedSeries.fromJson(item));
      } else {
        _log.warning('Unknown resource type: ${item['resource_type']}');
      }
    }

    return Result.ok(list);
  }

  /// 获取对文章的互动信息
  Future<Result<ArticleInteraction>> getArticleInteraction({required String articleId}) async {
    assert(articleId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final params = {
      'id': articleId,
      'mobi_app': 'pc',
      'from': 'web',
      'gaia_source': 'main_web',
      'web_location': WebLocation.articleDetail,
    };

    final (String wts, String wbiSign) = encWbi(params, account.wbiImgKey!, account.wbiSubKey!);
    final resp = await client.get(
      'https://api.bilibili.com/x/article/viewinfo',
      queryParameters: {
        ...params,
        'w_rid': wbiSign,
        'wts': wts,
      },
    );

    // if (resp.data['code'] == -404) {
    //   throw NotFoundException();
    // }

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(
      ArticleInteraction(
        hasLiked: resp.data['data']['like'] == 1,
        hasFavorited: resp.data['data']['favorite'],
        hasFollowed: resp.data['data']['attention'],
        coinCount: resp.data['data']['coin'],
      ),
    );
  }

  Future<Result<void>> reportArticleHistory({required String articleId}) async {
    assert(articleId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/v2/history/report',
      options: Options(headers: {'Content-Type': 'application/x-www-form-urlencoded'}),
      data: {
        'aid': articleId,
        'type': 5,
        'dt': 2,
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  Future<Result<int>> getUnreadPostCount() async {
    final client = await _authRepository.getClient();
    final resp = await client.get(
      'https://api.bilibili.com/x/web-interface/dynamic/entrance',
      queryParameters: {
        'alltype_offset': 0,
        'video_offset': 0,
        'article_offset': 0,
        'web_location': WebLocation.home,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(resp.data['data']['update_info']['item']['count'] as int);
  }

  /// 创建用户组
  ///
  /// 创建成功返回新创建的用户组
  Future<Result<UserGroup>> createUserGroup({required String name}) async {
    assert(name.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/relation/tag/create',
      options: Options(headers: {'Content-Type': 'application/x-www-form-urlencoded'}),
      queryParameters: {'x-bili-device-req-json': '{"platform":"web","device":"pc","spmid":"333.1387"}'},
      data: {
        'tag': name,
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(
      UserGroup(
        id: resp.data['data']['tagid'].toString(),
        name: name,
        count: 0,
      ),
    );
  }

  /// 获取全部用户组
  Future<Result<List<UserGroup>>> getGroupList() async {
    final client = await _authRepository.getClient();
    final resp = await client.get(
      'https://api.bilibili.com/x/relation/tags',
      queryParameters: {
        // 开不开没区别，不知道有什么用
        'only_master': false,
        'web_location': WebLocation.userSpace,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    final List<UserGroup> list = [];
    for (final item in resp.data['data']) {
      list.add(UserGroup(id: item['tagid'].toString(), name: item['name'], count: item['count']));
    }
    return Result.ok(list);
  }

  /// 获取指定用户组内的用户
  ///
  /// [groupId] 为 0 时返回未在任何分组内的用户，为 -10 时返回特别关注用户，为 -20 时返回悄悄关注用户
  ///
  /// 使用 pn+ps 分页，此接口不返回 total，需要自行提前调用 [getGroupList] 获取总数然后自行计算
  Future<Result<List<FollowingUser>>> getUsersInGroup({
    required String groupId,
    int pn = 1,
    int ps = 24, // ps 对齐网页端默认 24
  }) async {
    assert(groupId.isNotEmpty);
    assert(pn > 0 && ps > 0);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    late final List<dynamic> data;

    if (groupId == '-20') {
      final resp = await client.get(
        'https://api.bilibili.com/x/relation/whispers',
        queryParameters: {
          'pn': pn,
          'ps': ps,
          'web_location': WebLocation.userSpace,
        },
      );

      if (resp.data['code'] != 0) {
        return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
      }

      data = resp.data['data']['list'] as List;
    } else {
      final resp = await client.get(
        'https://api.bilibili.com/x/relation/tag',
        queryParameters: {
          'tagid': groupId,
          'pn': pn,
          'ps': ps,
          'mid': account.uid,
          'web_location': WebLocation.userSpace,
        },
      );

      if (resp.data['code'] != 0) {
        return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
      }

      data = resp.data['data'] as List;
    }

    return Result.ok(data.map((v) => FollowingUser.fromJson(v)).toList());
  }

  /// 获取指定用户正在关注的用户，非当前用户只能获取前100人，此后列表为空
  ///
  /// 使用 pn+ps+total 分页
  Future<Result<GetFollowingUsersResponse>> getFollowingUsers({
    required String userId,
    int pn = 1,
    int ps = 24, // ps 对齐网页端默认 24
    GetFollowingUsersOrderEnum order = GetFollowingUsersOrderEnum.followTimeDesc,
  }) async {
    assert(userId.isNotEmpty);

    final client = await _authRepository.getClient();
    final resp = await client.get(
      'https://api.bilibili.com/x/relation/followings',
      queryParameters: {
        'order': switch (order) {
          .followTimeAsc => 'asc',
          .viewTimeAsc => 'asc',
          .followTimeDesc => 'desc',
          .viewTimeDesc => 'desc',
        },
        'order_type': switch (order) {
          .followTimeAsc => '',
          .followTimeDesc => '',
          .viewTimeAsc => 'attention',
          .viewTimeDesc => 'attention',
        },
        'vmid': userId,
        'pn': pn,
        'ps': ps,
        'gaia_source': 'main_web',
        'web_location': WebLocation.userSpace,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(
      GetFollowingUsersResponse(
        list: (resp.data['data']['list'] as List).map((v) => FollowingUser.fromJson(v)).toList(),
        total: resp.data['data']['total'] as int,
      ),
    );
  }

  /// 在正在关注的用户中搜索
  ///
  /// 使用 pn+ps+total 分页
  Future<Result<GetFollowingUsersResponse>> getFollowingUsersWithKeyword({
    required String keyword,
    int pn = 1,
    int ps = 24, // ps 对齐网页端默认 24
  }) async {
    assert(keyword.isNotEmpty);
    assert(pn > 0, ps > 0);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.get(
      'https://api.bilibili.com/x/relation/followings/search',
      queryParameters: {
        // 虽然有排序相关的参数，但实际上这些参数没有效果
        'order': 'desc',
        'order_type': '',
        // 虽然有这个参数，但实测在非当前登录账户的关注列表搜索时均返回 `{"code":22115,"message":"用户已设置隐私","ttl":1}`
        'vmid': account.uid,
        'pn': pn,
        'ps': ps,
        'name': keyword,
        'gaia_source': 'main_web',
        'web_location': WebLocation.userSpace,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(
      GetFollowingUsersResponse(
        list: (resp.data['data']['list'] as List).map((v) => FollowingUser.fromJson(v)).toList(),
        total: resp.data['data']['total'] as int,
      ),
    );
  }

  /// 获取指定用户所在的全部用户组
  Future<Result<List<String>>> getGroupIdsWithUser({required String userId}) async {
    assert(userId.isNotEmpty);

    final client = await _authRepository.getClient();
    final resp = await client.get(
      'https://api.bilibili.com/x/relation',
      queryParameters: {
        'fid': userId,
        'web_location': WebLocation.userSpace,
        'x-bili-device-req-json': '{"platform":"web","device":"pc","spmid":"333.1387"}',
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    if (resp.data['data']['tag'] == null) return Result.ok(const []);
    return Result.ok((resp.data['data']['tag'] as List).map((v) => v.toString()).toList());
  }

  /// 设置指定用户到指定组
  ///
  /// [groupIds] 不传或者为空则为不保存到任何分组
  Future<Result<void>> setUsersToGroups({
    required List<String> userIds,
    List<String>? groupIds,
  }) async {
    assert(userIds.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/relation/tags/addUsers',
      options: Options(headers: {'Content-Type': 'application/x-www-form-urlencoded'}),
      queryParameters: {'x-bili-device-req-json': '{"platform":"web","device":"pc","spmid":"333.1387"}'},
      data: {
        'fids': userIds.join(','),
        'tagids': groupIds == null || groupIds.isEmpty ? 0 : groupIds.join(','),
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  Future<Result<void>> modifyUserGroup({required String groupId, required String name}) async {
    assert(groupId.isNotEmpty);
    assert(name.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/relation/tag/update',
      options: Options(headers: {'Content-Type': 'application/x-www-form-urlencoded'}),
      queryParameters: {'x-bili-device-req-json': '{"platform":"web","device":"pc","spmid":"333.1387"}'},
      data: {
        'tagid': groupId,
        'name': name,
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  Future<Result<void>> deleteUserGroup({required String groupId}) async {
    assert(groupId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/relation/tag/del',
      options: Options(headers: {'Content-Type': 'application/x-www-form-urlencoded'}),
      queryParameters: {'x-bili-device-req-json': '{"platform":"web","device":"pc","spmid":"333.1387"}'},
      data: {
        'tagid': groupId,
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 使用关键词获取指定用户的粉丝，非当前用户只能获取前100人，此后列表为空
  ///
  /// 使用 pn+ps+total 分页
  Future<Result<GetFansResponse>> getFans({
    required String userId,
    int pn = 1,
    int ps = 24, // ps 对齐网页端默认 24
  }) async {
    assert(userId.isNotEmpty);
    assert(pn > 0 && ps > 0);

    final client = await _authRepository.getClient();
    final resp = await client.get(
      'https://api.bilibili.com/x/relation/fans',
      queryParameters: {
        'pn': pn,
        'ps': ps,
        'vmid': userId,
        'gaia_source': 'main_web',
        'web_location': WebLocation.userSpace,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(
      GetFansResponse(
        list: (resp.data['data']['list'] as List).map((v) => FanUser.fromJson(v)).toList(),
        total: resp.data['data']['total'] as int,
      ),
    );
  }

  /// 删除粉丝
  Future<Result<void>> deleteFans({required String userId}) async {
    assert(userId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/relation/modify',
      options: Options(headers: {'Content-Type': 'application/x-www-form-urlencoded'}),
      queryParameters: {
        'statistics': '{"appId":100,"platform":5}',
        'x-bili-device-req-json': '{"platform":"web","device":"pc","spmid":"333.1387"}',
      },
      data: {
        'fid': userId,
        'act': 7,
        're_src': 11,
        'gaia_source': 'web_main',
        'spmid': WebLocation.userSpace,
        'extend_content': '{"entity":"user","entity_id":$userId}',
        'is_from_frontend_component': true,
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 屏蔽/取消屏蔽用户
  Future<Result<void>> blockUser({required String userId, required bool block}) async {
    assert(userId.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/relation/modify',
      options: Options(headers: {'Content-Type': 'application/x-www-form-urlencoded'}),
      queryParameters: {
        'statistics': '{"appId":100,"platform":5}',
        'x-bili-device-req-json': '{"platform":"web","device":"pc","spmid":"333.1387"}',
      },
      data: {
        'fid': userId,
        'act': block ? 5 : 6,
        're_src': 11,
        'gaia_source': 'web_main',
        'spmid': WebLocation.userSpace,
        'extend_content': '{"entity":"user","entity_id":$userId}',
        'is_from_frontend_component': true,
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 获取与另一位用户一同关注的用户
  ///
  /// 使用 pn+ps+total 翻页
  ///
  /// 注意此接口未测试过翻页功能以及最多能获取多少共同关注
  Future<Result<GetFollowingUsersResponse>> getMutualFollowingUsers({
    required String userId,
    int pn = 1,
    // 此处由于接口是从别处搜集来的，并不知道都需要什么参数，ps 也是，这里就参考相似页面下的接口设置为 24
    int ps = 24,
  }) async {
    assert(userId.isNotEmpty);

    final client = await _authRepository.getClient();
    final resp = await client.get(
      'https://api.bilibili.com/x/relation/same/followings',
      queryParameters: {
        'pn': pn,
        'ps': ps,
        'vmid': userId,
        'gaia_source': 'main_web',
        'web_location': WebLocation.userSpace,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(
      GetFollowingUsersResponse(
        list: (resp.data['data']['list'] as List).map((v) => FollowingUser.fromJson(v)).toList(),
        total: resp.data['data']['total'] as int,
      ),
    );
  }

  /// 获取指定用户的关注、悄悄关注、粉丝、屏蔽用户数
  ///
  /// 屏蔽用户数和悄悄关注数只有当前登录账户能获取到，其他情况均为 0
  Future<Result<GetUserStatsResponse>> getUserStats({required String userId}) async {
    assert(userId.isNotEmpty);

    final client = await _authRepository.getClient();
    final resp = await client.get(
      'https://api.bilibili.com/x/relation/stat',
      queryParameters: {
        'vmid': userId,
        'web_location': WebLocation.userSpace,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(GetUserStatsResponse.fromJson(resp.data['data']));
  }

  /// 获取用户总获赞和总播放
  Future<Result<GetUserTotalLikeAndViewCountResponse>> getUserTotalLikeAndViewCount({required String userId}) async {
    assert(userId.isNotEmpty);

    final client = await _authRepository.getClient();
    final resp = await client.get(
      'https://api.bilibili.com/x/space/upstat',
      queryParameters: {
        'mid': userId,
        'web_location': WebLocation.userSpace,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(GetUserTotalLikeAndViewCountResponse.fromJson(resp.data['data']));
  }

  /// 获取用户置顶视频
  Future<Result<List<PinnedVideo>>> getUserPinnedVideos({required String userId}) async {
    assert(userId.isNotEmpty);

    final client = await _authRepository.getClient();
    final resp = await client.get(
      'https://api.bilibili.com/x/space/masterpiece',
      queryParameters: {
        'vmid': userId,
        'web_location': WebLocation.userSpace,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok((resp.data['data'] as List).map((v) => PinnedVideo.fromJson(v)).toList());
  }

  /// 获取用户个人空间隐私设置和模块顺序
  Future<Result<GetUserProfileSettingsResponse>> getUserProfileSettings({required String userId}) async {
    assert(userId.isNotEmpty);

    final client = await _authRepository.getClient();
    final resp = await client.get(
      'https://api.bilibili.com/x/space/setting',
      queryParameters: {
        'mid': userId,
        'web_location': WebLocation.userSpace,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(GetUserProfileSettingsResponse.fromJson(resp.data['data']));
  }

  /// 修改隐私设置，只能一次修改一个字段
  Future<Result<void>> modifyUserPrivacySetting({
    required UserPrivacySettingsEnum field,
    required bool value,
  }) async {
    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/space/setting',
      options: Options(headers: {'Content-Type': 'application/x-www-form-urlencoded'}),
      data: {
        'field': field.value,
        'value': value,
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 修改个人空间模块排序
  ///
  /// [moduleSorting] 模块 ID 列表，顺序即为排序顺序
  ///
  /// 默认排序为 `1,10,5,3,7,8,2,9,26,25,22,23,21,6,4`
  Future<Result<void>> modifyUserModuleSorting({required List<int> moduleSorting}) async {
    assert(moduleSorting.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/space/index/order/modify',
      options: Options(headers: {'Content-Type': 'application/x-www-form-urlencoded'}),
      data: {
        'index_order': moduleSorting.join(','),
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 修改个人标签，注意需要带上所有标签，留空则清空所有标签
  Future<Result<void>> modifyTags({List<String>? tags = const []}) async {
    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/space/acc/tags/set',
      options: Options(headers: {'Content-Type': 'application/x-www-form-urlencoded'}),
      data: {
        'tags': tags == null ? '' : tags.join(','),
        'csrf': account.biliJct,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(null);
  }

  /// 获取用户的视频、文章、音频数量
  Future<Result<GetUserCountersResponse>> getUserCounters({required String userId}) async {
    assert(userId.isNotEmpty);

    final client = await _authRepository.getClient();
    final resp = await client.get(
      'https://api.bilibili.com/x/space/navnum',
      queryParameters: {
        'mid': userId,
        'web_location': WebLocation.userSpace,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(GetUserCountersResponse.fromJson(resp.data['data']));
  }

  /// 获取自身与另一个用户的关系
  Future<Result<GetUserRelationResponse>> getUserRelation({required String userId}) async {
    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final params = {
      'mid': userId,
      'web_location': WebLocation.userSpace,
    };
    final (String wts, String wbiSign) = encWbi(params, account.wbiImgKey!, account.wbiSubKey!);

    final resp = await client.get(
      'https://api.bilibili.com/x/space/wbi/acc/relation',
      queryParameters: {
        ...params,
        'w_rid': wbiSign,
        'wts': wts,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(GetUserRelationResponse.fromJson(resp.data['data']));
  }

  Future<Result<GetUserCardResponse>> getUserCard(String userId) async {
    final client = await _authRepository.getClient();
    final resp = await client.get(
      'https://api.bilibili.com/x/web-interface/card',
      queryParameters: {
        'mid': userId,
        'photo': 1,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    final card = resp.data['data']['card'];

    return Result.ok(
      GetUserCardResponse(
        id: userId,
        nickname: card['name'],
        avatar: card['face'],
        avatarFrame: AvatarFrame.fromJson(card['pendant']),
        banner: resp.data['data']['space']['l_img'],
        description: card['sign'],
        level: card['is_senior_member'] == 1 ? 7 : card['level_info']['current_level'],
        videoCount: resp.data['data']['archive_count'] as int,
        fansCount: resp.data['data']['follower'] as int,
        followCount: card['friend'] as int,
        likeCount: resp.data['data']['like_num'] as int,
      ),
    );
  }

  Future<Result<Map<String, User>>> getUserCards(List<String> userIds) async {
    final client = await _authRepository.getClient();
    final resp = await client.get(
      'https://api.bilibili.com/x/polymer/pc-electron/v1/user/cards',
      queryParameters: {
        'uids': userIds.join(','),
        'build': 0,
        'mobi_app': 'web',
        'web_location': WebLocation.message,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    final Map<String, User> users = {};
    for (final i in (resp.data['data'] as Map<String, dynamic>).entries) {
      users[i.key] = User(id: i.value['mid'], nickname: i.value['name'], avatar: i.value['face']);
    }

    return Result.ok(users);
  }
}
