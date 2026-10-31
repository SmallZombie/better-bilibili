import 'dart:convert';
import 'dart:io';

import 'package:better_bilibili/config/constants.dart';
import 'package:better_bilibili/data/model/bilibili/bilibili.pb.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_collections_and_playlists_with_user_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_extra_play_info_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_play_info_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_playlist_info_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_playlist_keyword_suggestions_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_playlist_videos_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_recommend_videos_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_report_options_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_timeline_preview_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_collections_and_playlists_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_videos_with_keyword_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_video_cards.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_video_detail_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_videos_with_user_id_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/video_report_history.dart';
import 'package:better_bilibili/domain/exceptions/bili_http_exception.dart';
import 'package:better_bilibili/domain/exceptions/not_logged_in_exception.dart';
import 'package:better_bilibili/domain/models/bilibili/account.dart';
import 'package:better_bilibili/domain/models/bilibili/bilibili.dart';
import 'package:better_bilibili/domain/models/bilibili/danmaku.dart';
import 'package:better_bilibili/domain/models/bilibili/play_info.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:better_bilibili/utils/bilibili/bili_util.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:logger/logger.dart';

const _qn = 126;

class BiliVideoWebApiService {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'BiliVideoApiService'));

  Future<Dio> Function() getClient;
  Future<Account> Function() getAccount;

  BiliVideoWebApiService({required this.getClient, required this.getAccount});

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

  /// 获取推荐视频
  Future<Result<List<RecommendVideo>>> getRecommendVideos({
    int pn = 1,
    int ps = 20,
  }) async {
    assert(pn > 0 && ps > 0);

    final client = await getClient();
    final account = await getAccount();

    try {
      // 该接口不带 buvid3 会导致每次请求的响应相同
      final resp = await client.get(
        'https://api.bilibili.com/x/web-interface/wbi/index/top/feed/rcmd',
        queryParameters: buildWbiParams(
          // 虽然参数全不传也能响应数据，但不建议这么做
          // 比如不传 pn 也能每次响应不一样的视频，但这里不这样做
          {
            'web_location': WebLocation.home_2,
            'y_num': 4,
            'fresh_type': 4,
            'feed_version': 'V8',
            'fresh_idx_1h': pn,
            // 初始从 4 开始，也就是 pn = 1，row = 4，随后递增3，也就是 pn = 2，row = 7，以此类推
            'fetch_row': 1 + pn * 3,
            'fresh_idx': pn,
            'brush': pn,
            'device': 'win',
            'homepage_ver': 1,
            'ps': ps,
            'last_y_num': 5,
            'screen': '${account.windowWidth}-${account.windowHeight}',
            'seo_info': '',
            'tt_exp': '',
            'last_showlist': '',
            'uniq_id': '',
          },
          account.wbiImgKey,
          account.wbiSubKey,
        ),
      );

      _checkResponse(resp);

      return Result.ok(
        (resp.data['data']['item'] as List).where((item) => item['goto'] == 'av').map((item) => RecommendVideo.fromJson(item)).toList(),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 按分类获取推荐视频
  ///
  /// ps 最大 20
  Future<Result<List<RecommendVideo>>> getRecommendVideosByCategory({
    required String categoryId,
    int pn = 1,
    int ps = 20,
  }) async {
    assert(categoryId.isNotEmpty);
    assert(pn > 0);
    assert(ps > 0 && ps <= 20);

    final client = await getClient();
    final account = await getAccount();

    try {
      final resp = await client.get(
        'https://api.bilibili.com/x/web-interface/region/feed/rcmd',
        queryParameters: buildWbiParams(
          {
            'display_id': pn,
            // b站默认 15，最大 20，超过会返回 "62013: 暂时没有更多内容了"
            'request_cnt': ps,
            'from_region': categoryId,
            'device': 'web',
            'plat': 30,
            'web_location': WebLocation.categoryHome,
          },
          account.wbiImgKey,
          account.wbiSubKey,
        ),
      );

      _checkResponse(resp);

      return Result.ok(
        (resp.data['data']['archives'] as List).where((item) => item['goto'] == 'av').map((item) => RecommendVideo.fromJson(item)).toList(),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 获取视频详情
  Future<Result<GetVideoDetailResponse>> getVideoDetail(String videoId) async {
    assert(videoId.isNotEmpty);

    final account = await getAccount();
    final client = await getClient();

    final (String dmImgList, List<FingerprintLog> logs) = getDmImgList(
      // 这里原计划是0~1的，改成1~2的原因见 `getDmImgInter` 函数注释
      minLogCount: 1,
      maxLogCount: 2,
      windowWidth: sometingOrElse(0.01, account.windowWidth ~/ 2, account.windowWidth),
      windowHeight: sometingOrElse(0.01, account.windowHeight ~/ 2, account.windowHeight),
      maxTimestamp: getRandomInt(
        RECOMMENDED_FINGERORINT_EVENT_TS_MINIMUM,
        RECOMMENDED_FINGERORINT_EVENT_TS_MINIMUM + 2000,
      ),
      mouseRangeX: 0.8,
      mouseRangeY: 0.5,
      useClickLog: false,
      useTargetList: [VideoDetailPageElementList],
    );

    try {
      final resp = await client.get(
        'https://api.bilibili.com/x/web-interface/wbi/view/detail',
        queryParameters: buildWbiParams(
          {
            'aid': videoId,
            'need_view': 1,
            'isGaiaAvoided': false,
            'web_location': WebLocation.videoDetail,
            'dm_img_list': dmImgList,
            'dm_img_str': getDmImgStr(),
            'dm_cover_img_str': getDmCoverImgStr(),
            'dm_img_inter': getDmImgInter(
              log: logs.last,
              windowWidth: sometingOrElse(0.01, account.windowWidth ~/ 2, account.windowWidth),
              windowHeight: sometingOrElse(0.01, account.windowHeight ~/ 2, account.windowHeight),
            ),
          },
          account.wbiImgKey,
          account.wbiSubKey,
        ),
      );

      _checkResponse(resp);

      // 62012 = 私密视频
      // 62002 = 失效视频

      return Result.ok(
        GetVideoDetailResponse(
          video: VideoDetail.fromJson(resp.data['data']),
          recommendVideos: (resp.data['data']['Related'] as List).map((v) => RecommendVideo.fromJson(v)).toList(),
        ),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Result<PlayInfo>> getPlayInfo({
    required String videoId,
    required String episodeId,
  }) async {
    assert(videoId.isNotEmpty && episodeId.isNotEmpty);

    final account = await getAccount();
    final client = await getClient();

    final (String dmImgList, List<FingerprintLog> logs) = getDmImgList(
      // 这里原计划是0~1的，改成1~2的原因见 `getDmImgInter` 函数注释
      minLogCount: 1,
      maxLogCount: 2,
      windowWidth: sometingOrElse(0.01, account.windowWidth ~/ 2, account.windowWidth),
      windowHeight: sometingOrElse(0.01, account.windowHeight ~/ 2, account.windowHeight),
      maxTimestamp: getRandomInt(
        RECOMMENDED_FINGERORINT_EVENT_TS_MINIMUM,
        RECOMMENDED_FINGERORINT_EVENT_TS_MINIMUM + 2000,
      ),
      mouseRangeX: 0.8,
      mouseRangeY: 0.5,
      useClickLog: false,
      useTargetList: [VideoDetailPageElementList],
    );
    final dmImgStr = getDmImgStr();
    final dmCoverImgStr = getDmCoverImgStr();
    final dmImgInter = getDmImgInter(
      log: logs.last,
      windowWidth: sometingOrElse(0.01, account.windowWidth ~/ 2, account.windowWidth),
      windowHeight: sometingOrElse(0.01, account.windowHeight ~/ 2, account.windowHeight),
    );

    try {
      GetPlayInfoResponse playInfoResp;
      {
        final session = generateSession(account.buvid3);

        final resp = await client.get(
          'https://api.bilibili.com/x/player/wbi/playurl',
          queryParameters: buildWbiParams(
            {
              'avid': videoId,
              'bvid': av2bv(videoId),
              'cid': episodeId,
              'qn': _qn,
              'fnver': 0,
              'fnval': 4048,
              'fourk': 1,
              'gaia_source': '',
              'from_client': 'BROWSER',
              'is_main_page': true,
              'need_fragment': false,
              'isGaiaAvoided': false,
              'client_attr': 0,
              'version_name': '4.9.86',
              'app_id': 100,
              'session': session,
              'voice_balance': 1,
              'web_location': WebLocation.videoDetail,
              'dm_img_list': dmImgList,
              'dm_img_str': dmImgStr,
              'dm_cover_img_str': dmCoverImgStr,
              'dm_img_inter': dmImgInter,
            },
            account.wbiImgKey,
            account.wbiSubKey,
          ),
        );

        _checkResponse(resp);

        playInfoResp = GetPlayInfoResponse(
          id: resp.data['data']['auto_qn_resp']['dyeid'],
          session: session,
          videoId: videoId,
          bvid: av2bv(videoId),
          episodeId: episodeId,
          duration: Duration(seconds: (resp.data['data']['dash']['duration'] as int)),
          videoTracks: (resp.data['data']['dash']['video'] as List).map((value) => MediaStream.fromJson(value)).toList(),
          audioTracks: [
            // Hi-Res(30251)
            if (resp.data['data']['dash']['flac'] != null) resp.data['data']['dash']['flac']['audio'],
            // DolbyAtmos(30250)
            if (resp.data['data']['dash']['dolby']['type'] != 0) ...resp.data['data']['dash']['dolby']['audio'] as List,
            ...((resp.data['data']['dash']['audio'] as List?) ?? []),
          ].map((value) => MediaStream.fromJson(value)).toList(),
        );
      }

      GetExtraPlayInfoResponse? extraPlayInfoResp;
      {
        final resp = await client.get(
          'https://api.bilibili.com/x/player/wbi/v2',
          queryParameters: buildWbiParams(
            {
              'aid': videoId,
              'cid': episodeId,
              'isGaiaAvoided': false,
              'web_location': WebLocation.videoDetail,
              'dm_img_list': dmImgList,
              'dm_img_str': dmImgStr,
              'dm_cover_img_str': dmCoverImgStr,
              'dm_img_inter': dmImgInter,
            },
            account.wbiImgKey,
            account.wbiSubKey,
          ),
        );

        _checkResponse(resp);

        final maskUrl = resp.data['data']?['dm_mask']?['mask_url'];
        extraPlayInfoResp = GetExtraPlayInfoResponse(
          subtitles: (resp.data['data']['subtitle']['subtitles'] as List).map((v) => Subtitle.fromJson(v)).toList(),
          lastPosition: Duration(milliseconds: resp.data['data']['last_play_time']),
          lastEpisodeId: resp.data['data']['last_play_cid'] != 0 ? resp.data['data']['last_play_cid'].toString() : null,
          chapters: (resp.data['data']['view_points'] as List).map((v) => Chapter.fromJson(v)).toList(),
          // fps 跟随视频，最高 30，且向下取整
          // 例如 29.97 帧的视频会生成 29 帧的遮罩，
          // 60 帧的视频会生成 30 帧的遮罩
          maskUrl: maskUrl != null ? 'https:$maskUrl' : null,
        );
      }

      return Result.ok(PlayInfo.assembly(playInfoResp, extraPlayInfoResp));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 点赞视频
  ///
  /// [playTime] 表示指实际播放时间，单位秒，比如用户从头看了10s然后拖动进度条到某处再看5s，那么此值就是15
  Future<Result<void>> like({
    required String videoId,
    required bool like,
    required int playTime,
  }) async {
    assert(videoId.isNotEmpty);
    assert(playTime >= 0);

    final client = await getClient();

    try {
      final account = await _getLoginedAccount();
      final resp = await client.post(
        'https://api.bilibili.com/x/web-interface/archive/like',
        options: Options(contentType: Headers.formUrlEncodedContentType),
        data: {
          'aid': videoId,
          'like': like ? 1 : 2,
          'from_spmid': '',
          'spmid': '333.788.0.0',
          'statistics': '{"appId":100,"platform":5}',
          // 此值表示播放器是否暂停, 1 = 播放, 2 = 暂停
          'eab_x': 2,
          // 通过 `window.player.getMediaInfo().absolutePlayTime` (没错b站把播放器挂到window上了) 获取
          // 是用户实际播放一个视频的时间，单位秒，比如用户从头看了10s然后拖动进度条到某处再看5s，那么此值就是15
          'ramval': playTime,
          'source': 'web_normal',
          'ga': 1,
          'csrf': account.biliJct,
        },
      );

      _checkResponse(resp);

      return Result.ok(null);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 投币视频
  ///
  /// [playTime] 表示指实际播放时间，单位秒，比如用户从头看了10s然后拖动进度条到某处再看5s，那么此值就是15
  Future<Result<void>> coin({
    required String videoId,
    required int count,
    required int playTime,
  }) async {
    assert(videoId.isNotEmpty);
    assert(count == 1 || count == 2);
    assert(playTime >= 0);

    final client = await getClient();

    try {
      final account = await _getLoginedAccount();
      final resp = await client.post(
        'https://api.bilibili.com/x/web-interface/coin/add',
        options: Options(contentType: Headers.formUrlEncodedContentType),
        data: {
          'aid': videoId,
          'multiply': count,
          // 同时点赞内容, 0 = 否, 1 = 是, 由于本应用不提供此功能，故此值始终为0
          'select_like': 0,
          'cross_domain': true,
          'from_spmid': '',
          'spmid': '333.788.0.0',
          'statistics': '{"appId":100,"platform":5}',
          'eab_x': 2,
          'ramval': playTime,
          'source': 'web_normal',
          'ga': 1,
          'csrf': account.biliJct,
        },
      );

      _checkResponse(resp);

      return Result.ok(null);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 获取播放列表基本信息
  Future<Result<GetPlaylistInfoResponse>> getPlaylistInfo(String playlistId) async {
    assert(playlistId.isNotEmpty);

    final client = await getClient();

    try {
      final resp = await client.get(
        // `https://s1.hdslb.com/bfs/static/jinkela/playlist/playlist.6c3087bb9f83ebc149b2019d583cd4a5330ff332.js (/x/v1/medialist/info)`
        'https://api.bilibili.com/x/v1/medialist/info',
        queryParameters: {
          'out_referer': '',
          'type': 3,
          'biz_id': playlistId,
          'tid': 0,
          'web_location': WebLocation.videoDetailWithPlaylist,
        },
      );

      _checkResponse(resp);

      return Result.ok(GetPlaylistInfoResponse.fromJson(resp.data['data']));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 获取播放列表内视频列表
  ///
  /// 不传入 videoId 返回第一页数据
  /// 传入 videoId 且 direction = both 时返回当前视频和前后一小部分
  /// 传入 videoId 且 direction = before 时返回当前视频前一部分
  /// 传入 videoId 且 direction = after(默认) 返回此视频后的数据
  Future<Result<GetPlaylistVideosResponse>> getPlaylistVideos({
    required String playlistId,
    String? videoId,
    GetPlaylistVideosDirectionEnum direction = GetPlaylistVideosDirectionEnum.after,
    int ps = 20,
  }) async {
    assert(playlistId.isNotEmpty);
    assert(videoId == null || videoId.isNotEmpty);
    assert(ps > 0);

    final client = await getClient();

    try {
      final resp = await client.get(
        'https://api.bilibili.com/x/v2/medialist/resource/list',
        queryParameters: {
          'out_referer': '',
          'mobi_app': 'web',
          'type': 3,
          'biz_id': playlistId,
          'ps': ps,
          'desc': true,
          'sort_field': 1,
          'tid': 0,
          'bvid': '',
          'oid': videoId ?? 0,
          'otype': 2,
          // oid && with_current = true && direction = false && preview = 1 时，可以返回当前视频和前后一小部分
          // oid && with_current = false && direction = false && preview = 0 时，可以返回当前视频后一部分
          // oid && with_current = false && direction = true && preview = 0 时，可以返回当前视频前一部分
          if (direction == GetPlaylistVideosDirectionEnum.both) ...{
            'with_current': true,
            'direction': false,
            'preview': 1,
          } else if (direction == GetPlaylistVideosDirectionEnum.before) ...{
            'with_current': false,
            'direction': true,
            'preview': 0,
          } else ...{
            'with_current': false,
            'direction': false,
            'preview': 0,
          },
          // 这个 pn 是给随机播放用的，b站的逻辑是先从总数里随机一个 pn，然后再把返回结果打乱实现随机效果
          // 本应用暂不支持，故此值始终为 false
          'use_pn': false,
          'pn': 1,
          'web_location': WebLocation.videoDetailWithPlaylist,
        },
      );

      _checkResponse(resp);

      final mediaList = resp.data['data']['media_list'] as List?;
      return Result.ok(
        GetPlaylistVideosResponse(
          hasMore: resp.data['data']['has_more'] as bool,
          list: mediaList == null ? const [] : mediaList.map((value) => PlaylistVideo.fromJson(value)).toList(),
        ),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 获取用户上传的视频
  ///
  /// 使用 pn+ps+total 分页
  Future<Result<GetVideosWithUserIdResponse>> getVideosWithUser({
    required String userId,
    int pn = 1,
    int ps = 25,
    GetVideosWithUserTypeEnum type = .all,
    GetVideosWithUserOrderEnum order = .releaseTimeDesc,
  }) async {
    assert(userId.isNotEmpty);
    assert(pn > 0 && ps > 0);
    assert(type == .all || (type == .sponsorOnly && order == .releaseTimeDesc));

    final account = await getAccount();
    final client = await getClient();

    final (String dmImgList, List<FingerprintLog> logs) = getDmImgList(
      minLogCount: 2,
      maxLogCount: 4,
      windowWidth: sometingOrElse(0.01, account.windowWidth ~/ 2, account.windowWidth),
      windowHeight: sometingOrElse(0.01, account.windowHeight ~/ 2, account.windowHeight),
      maxTimestamp: getRandomInt(
        RECOMMENDED_FINGERORINT_EVENT_TS_MINIMUM,
        RECOMMENDED_FINGERORINT_EVENT_TS_MINIMUM + 2000,
      ),
      mouseRangeX: 0.8,
      mouseRangeY: 0.5,
      useClickLog: false,
      useTargetList: [UserDetailVideoElementList],
    );

    try {
      final resp = await client.get(
        'https://api.bilibili.com/x/space/wbi/arc/search',
        queryParameters: buildWbiParams(
          {
            'pn': pn,
            'ps': ps,
            'tid': 0,
            // 不可以与 order 一同使用，如果想要充电专属视频则 order 必须为默认的 releaseTimeDesc
            'special_type': type == .sponsorOnly ? 'charging' : '',
            'order': order.value,
            'mid': userId,
            // 此值在首页获取时为 1, 视频 tab 里为 0, 作用不明
            'index': 0,
            'keyword': '',
            'order_avoided': true,
            'platform': 'web',
            'web_location': WebLocation.userSpace,
            'dm_img_list': dmImgList,
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
      );

      _checkResponse(resp);

      final slist = resp.data['data']['list']['slist'] as List?;
      final charging = slist?.firstWhere((v) => v['special_type'] == 'charging', orElse: () => null);

      return Result.ok(
        GetVideosWithUserIdResponse(
          list: (resp.data['data']['list']['vlist'] as List).map((v) => VideoItem.fromJson(v)).toList(),
          total: resp.data['data']['page']['count'] as int,
          sponsorOnlyTotal: charging == null ? 0 : charging['count'] as int,
        ),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 获取简单视频列表，支持使用关键词筛选
  ///
  /// 使用 pn+ps+total 分页
  Future<Result<GetUserVideosWithKeywordResponse>> getUserVideosWithKeyword({
    String? keyword,
    int pn = 1,
    int ps = 20,
  }) async {
    assert(keyword == null || keyword.isNotEmpty);
    assert(pn > 0 && ps > 0);

    final account = await getAccount();
    final client = await getClient();

    try {
      final resp = await client.get(
        'https://api.bilibili.com/x/series/recArchivesByKeywords',
        queryParameters: {
          'mid': account.userId,
          'keywords': keyword,
          'pn': pn,
          'ps': ps,
          'web_location': WebLocation.userSpace,
        },
      );

      _checkResponse(resp);

      return Result.ok(
        GetUserVideosWithKeywordResponse(
          list: (resp.data['data']['archives'] as List).map((v) => GetUserVideosWithKeywordItem.fromJson(v)).toList(),
          total: resp.data['data']['page']['total'] as int,
        ),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 获取用于创建播放列表的关键词建议
  Future<Result<List<PlaylistKeywordSuggestion>>> getPlaylistKeywordSuggestions() async {
    final client = await getClient();

    try {
      final account = await _getLoginedAccount();
      final resp = await client.get(
        'https://api.bilibili.com/x/series/propose',
        queryParameters: {
          'mid': account.userId,
          'csrf': account.biliJct,
        },
      );

      _checkResponse(resp);

      return Result.ok((resp.data['data']['series_list'] as List).map((v) => PlaylistKeywordSuggestion.fromJson(v)).toList());
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 创建播放列表
  ///
  /// [keyword] 可以通过 [getPlaylistKeywordSuggestions] 向用户展示建议
  /// [videoIds] 通过 [getUserVideosWithKeyword] 获取
  ///
  /// 返回创建的播放列表ID
  Future<Result<int>> createPlaylist({
    required String name,
    String? description,
    String? keyword,
    List<String> videoIds = const [],
  }) async {
    assert(name.isNotEmpty);
    assert(description == null || description.isNotEmpty);
    assert(keyword == null || keyword.isNotEmpty);

    final client = await getClient();

    try {
      final account = await _getLoginedAccount();
      final resp = await client.post(
        'https://api.bilibili.com/x/series/series/createAndAddArchives',
        options: Options(contentType: 'multipart/form-data; boundary=${generateBoundaryName2()}'),
        data: {
          'mid': account.userId,
          'name': name,
          'keywords': keyword,
          'description': description,
          'aids': videoIds.join(','),
          'csrf': account.biliJct,
        },
      );

      _checkResponse(resp);

      return Result.ok(resp.data['data']['series_id'] as int);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 获取用户创建的合集和播放列表，此接口仅用作获取前20个结果，想要全部合集和播放列表请使用 [getUserCollectionsAndPlaylists]
  ///
  /// [ps] 最大 20
  ///
  /// 合在一起返回，通过 [isPlaylist] 区分
  @Deprecated('use [getUserCollectionsAndPlaylists]')
  Future<Result<List<GetCollectionsAndPlaylistsWithUserItem>>> getCollectionsAndPlaylistsWithUser({
    required String userId,
    int ps = 20,
  }) async {
    assert(userId.isNotEmpty);
    assert(ps > 0 && ps <= 20);

    final client = await getClient();

    try {
      final resp = await client.get(
        'https://api.bilibili.com/x/polymer/web-space/home/seasons_series',
        queryParameters: {
          'mid': userId,
          'page_size': ps,
          // 实测此参数无作用
          'page_num': 1,
          'web_location': WebLocation.userSpace,
        },
      );

      _checkResponse(resp);

      return Result.ok([
        ...(resp.data['data']['items_lists']['seasons_list'] as List).map((v) => GetCollectionsAndPlaylistsWithUserItem.fromJson(v)),
        ...(resp.data['data']['items_lists']['series_list'] as List).map((v) => GetCollectionsAndPlaylistsWithUserItem.fromJson(v)),
      ]);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 获取用户创建的合集和播放列表
  ///
  /// 使用 pn+ps+total 分页
  ///
  /// 合在一起返回，通过 [isPlaylist] 区分
  Future<Result<GetUserCollectionsAndPlaylistsResponse>> getUserCollectionsAndPlaylists({
    required String userId,
    int pn = 1,
    int ps = 20,
  }) async {
    assert(userId.isNotEmpty);
    assert(pn > 0 && ps > 0);

    final client = await getClient();

    try {
      final resp = await client.get(
        'https://api.bilibili.com/x/polymer/web-space/seasons_series_list',
        queryParameters: {
          'mid': userId,
          'page_size': ps,
          'page_num': pn,
          'web_location': WebLocation.userSpace,
        },
      );

      _checkResponse(resp);

      return Result.ok(
        GetUserCollectionsAndPlaylistsResponse(
          list: [
            ...(resp.data['data']['items_lists']['seasons_list'] as List).map((v) => GetUserCollectionsAndPlaylistsItem.fromJson(v)),
            ...(resp.data['data']['items_lists']['series_list'] as List).map((v) => GetUserCollectionsAndPlaylistsItem.fromJson(v)),
          ],
          total: resp.data['data']['items_lists']['page']['total'] as int,
        ),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Result<void>> subscriptionCollection({
    required String collectionId,
    required bool subscription,
  }) async {
    assert(collectionId.isNotEmpty);

    final client = await getClient();

    try {
      final account = await _getLoginedAccount();
      if (subscription) {
        final resp = await client.post(
          'https://api.bilibili.com/x/v3/fav/season/fav',
          options: Options(contentType: Headers.formUrlEncodedContentType),
          data: {
            'platform': 'web',
            'season_id': collectionId,
            'csrf': account.biliJct,
          },
        );

        _checkResponse(resp);

        return Result.ok(null);
      } else {
        final resp = await client.post(
          'https://api.bilibili.com/x/v3/fav/season/unfav',
          options: Options(contentType: Headers.formUrlEncodedContentType),
          data: {
            'platform': 'web',
            'season_id': collectionId,
            'csrf': account.biliJct,
          },
        );

        _checkResponse(resp);

        return Result.ok(null);
      }
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 上报历史记录，推荐的 timer 间隔为 15 秒
  ///
  /// - [firstPlaybackTime] 首次开始播放时的秒级时间戳
  /// - [realPlaybackTime] 会话期间不跳转进度的实际播放时间，单位秒，比如先从0:00看到15:00，然后跳转进度到25:00看到30:00，此时真实观看时间为 20
  /// - [duration] 总时长，单位秒
  /// - [position] 当前位置，单位秒
  /// - [maxPosition] 会话期间最远的播放位置，单位秒，比如从0:00看到1:00，然后再拖进度条回到0:00，此时最远位置为 60
  /// - [reportCounter] 调用方维护一个计数器，每当汇报由 timer 发起时 +1，否则不变
  /// - [playInfoSession] 获取 playInfo 时生成的 session
  /// - [playInfoId] 获取 playInfo 时返回的 id
  /// - [videoFileName] 正在播放的视频文件名，例如 "1386420236-1-30102.m4s"
  Future<Result<void>> reportHistory({
    required String videoId,
    required String episodeId,
    required int firstPlaybackTime,
    required BiliContentTypeEnum contentType,
    bool isDocumentary = false,
    bool isGuochuang = false,
    bool isTVSeries = false,
    bool isVarietyShow = false,
    required ReportHistoryActionTypeEnum actionType,
    required int realPlaybackTime,
    required int duration,
    required int position,
    required int maxPosition,
    required int reportCounter,
    required String playInfoSession,
    required String playInfoId,
    required String videoFileName,
  }) async {
    assert(videoId.isNotEmpty);
    assert(episodeId.isNotEmpty);
    assert(firstPlaybackTime > 0);
    assert(
      const [
        BiliContentTypeEnum.video,
        BiliContentTypeEnum.series,
        BiliContentTypeEnum.movie,
        BiliContentTypeEnum.coures,
      ].contains(contentType),
    );
    assert(realPlaybackTime >= 0);
    assert(duration > 0);
    assert(position >= 0);
    assert(maxPosition >= 0);
    assert(reportCounter >= 0);
    assert(playInfoSession.isNotEmpty);
    assert(playInfoId.isNotEmpty);
    assert(videoFileName.isNotEmpty);

    final client = await getClient();

    try {
      final account = await _getLoginedAccount();
      final realPlayedTime = actionType == .end ? -1 : reportCounter * 15;
      final resp = await client.post(
        'https://api.bilibili.com/x/click-interface/web/heartbeat',
        queryParameters: buildWbiParams(
          {
            // 此处参数大部分同 body 部分
            'w_start_ts': firstPlaybackTime,
            'w_mid': account.userId,
            'w_aid': videoId,
            'w_dt': 2,
            'w_realtime': realPlaybackTime,
            'w_played_time': position,
            'w_real_played_time': realPlayedTime,
            'w_video_duration': duration,
            'w_last_play_progress_time': position,
            'web_location': WebLocation.videoDetail,
          },
          account.wbiImgKey,
          account.wbiSubKey,
        ),
        options: Options(contentType: Headers.formUrlEncodedContentType),
        data: {
          // 首次开始播放时的秒级时间戳
          'start_ts': firstPlaybackTime,
          'mid': account.userId,
          'aid': videoId,
          'cid': episodeId,
          'type': switch (contentType) {
            .video => 3,
            .series => 4,
            .movie => 4,
            .coures => 10,
            _ => Exception('Invaild contentType: $contentType'),
          },
          // dart format off
        'sub_type':
          isDocumentary ? 3 :
          isGuochuang ? 4 :
          isTVSeries ? 5 :
          isVarietyShow ? 7 :
          contentType == .video ? 0 :
          contentType == .series ? 1 :
          contentType == .movie ? 2 :
          Exception('Invaild contentType: $contentType'),
        // dart format on
          // 固定为 2
          'dt': 2,
          'play_type': actionType.value,
          // 会话期间不跳转进度的实际播放时间，单位秒
          // 比如先从0:00看到00:15，然后跳转进度到00:25看到00:30，此时真实观看时间为 20
          'realtime': realPlaybackTime,
          // 当前播放位置，单位秒
          'played_time': position,
          // 每当汇报由 timer 发起时 +15，否则不变，也就是永远都是 15 的倍数
          // 播放结束时为 -1
          'real_played_time': realPlayedTime,
          // 为空即可
          'refer_url': '',
          'quality': _qn,
          // 固定为 0 即可，懒得研究了
          'is_auto_qn': 0,
          // 总时长，单位秒
          'video_duration': duration,
          // 此值可能为 position，也可能为 position - 1
          // 懒得仔细研究了，就与 played_time 保持一致即可
          'last_play_progress_time': position,
          // 会话期间最远的播放位置，单位秒
          // 比如从0:00看到1:00，然后再拖进度条回到0:00，此时最远位置为 60
          'max_play_progress_time': maxPosition,
          // 以下固定即可
          'outer': 0,
          'statistics': '{"appId":100,"platform":5,"abtest":"","version":""}',
          'mobi_app': 'web',
          'device': 'web',
          'platform': 'web',
          'cur_language_vt': '{}',
          'perfer_type': '{}',
          'play_mode': 1,
          'spmid': '333.788.0.0',
          'from_spmid': '333.788.0.0',
          // 获取 playInfo 时生成的 session
          'session': playInfoSession,
          // 为空即可
          'track_id': '',
          // 此处 auto_play 可能为 99，懒得研究了
          'extra':
              '{"player_version":"4.9.86","video_dye_id":"$playInfoId","video_file_name":"$videoFileName","play_method":2,"play_volume":1,"auto_play":0}',
          'csrf': account.biliJct,
        },
      );

      _checkResponse(resp);

      return Result.ok(null);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Result<List<Danmaku>>> getDanmakus({
    required int index,
    required String videoId,
    required String episodeId,
    required BiliContentTypeEnum type,
  }) async {
    assert(index > 0);
    assert(videoId.isNotEmpty && episodeId.isNotEmpty);
    assert(type == .video);

    final account = await getAccount();
    final client = await getClient();

    try {
      final resp = await client.get(
        'https://api.bilibili.com/x/v2/dm/wbi/web/seg.so',
        queryParameters: buildWbiParams(
          {
            // 1 = 视频, 2 = 漫画
            'type': type.value,
            'oid': episodeId,
            'pid': videoId,
            'segment_index': index,
            'pull_mode': 1,
            'ps': (index - 1) * 360000,
            'pe': index * 360000,
            'web_location': WebLocation.videoDetail,
          },
          account.wbiImgKey,
          account.wbiSubKey,
        ),
        options: Options(responseType: ResponseType.bytes),
      );

      final dm = DmSegMobileReply.fromBuffer(resp.data as List<int>);

      if (kDebugMode) {
        final logsDir = Directory('${Directory.systemTemp.path}\\better_bilibili_http_logs');
        if (!await logsDir.exists()) {
          await logsDir.create(recursive: true);
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'seg.so_$timestamp.txt';
        final logFile = File('${logsDir.path}\\$fileName');

        final sort = [...dm.elems]..sort((a, b) => a.progress - b.progress);

        await logFile.writeAsString(
          'index: $index\nvideoId: $videoId\nepisodeId: $episodeId\ntype: $type\n\n${sort.map((v) => v.toProto3Json()).join('\n')}',
        );
      }

      int toInt(dynamic v) => switch (v) {
        int i => i,
        double d => d.toInt(),
        String s => s.isEmpty ? 0 : double.parse(s).toInt(),
        _ => 0,
      };
      double toDouble(dynamic v) => switch (v) {
        num n => n.toDouble(),
        String s => s.isEmpty ? 0.0 : double.parse(s),
        _ => 0.0,
      };
      bool toBool(dynamic v) => switch (v) {
        bool b => b,
        int i => i == 1,
        String s => s == '1' || s == 'true',
        _ => false,
      };

      List<Danmaku> list = [];
      for (final i in dm.elems) {
        if (i.mode == 6) {
          continue;
        }

        String text = i.content;

        ExtraAnimation? extra;
        if (i.mode == 7) {
          if (!i.content.startsWith('[') || !i.content.endsWith(']')) {
            _log.w('Invaild advanced danmaku payload: ${i.content}');
            continue;
          }

          // [0.65, 0.1, "1-1", 10, "と", 0, 0, 0.65, 0.1, 10, 0, 1, "SimSun", 1] // length=14
          // ["0.35", "0.48", "1-1", "8", "aaaaaaaaaa", 0, 0, "0.35", "0.48", 500, 0, 1, "SimHei", 1] // length=14
          // [0.99, 0.35, "1-1", 3, "为了那个傻傻的放电妹", 0, 0, 0, 0.35, 3000, 0, true, "幼圆", 1] // length=14
          // [0.4, 0.01, "1-1", 4.5, "妹妹们都很努力的活着", 0, 0, 0.4, 0.99, 1600, 0, true, "幼圆", 1] // length=14
          // [0, 0.99, "0.5-1", 4, "御园腊月落白雪", 0, 0, 0, 0, 3000, 0, true, "微软雅黑", 1] // length=14
          // ["", "", "1-1", "10", "三刀流奥义", "0", "0", "", "2", 500, 0, 1, "SimHei", 1] // length=14
          // ["0.5", "0.5", "1-1", "5", "绝对冰洁·iced·shell\n", 0, 0, "0.5", "0.5", "", "", 1, "SimHei", 1] // length=14
          late List<dynamic> json;
          try {
            json = jsonDecode(i.content);
          } catch (e, s) {
            _log.e('Unable to parse advanced danmaku payload: ${i.content}', error: e, stackTrace: s);
            continue;
          }

          double beginX = toDouble(json[0]);
          double beginY = toDouble(json[1]);

          // 整数时为绝对坐标，浮点时为相对坐标 (存疑)
          // https://commentcorelibrary.readthedocs.io/en/latest/data-formats/bilibili-xml/#:~:text=基础属性
          // 已知网页端发送高级弹幕时，相对坐标的取值范围为 0~0.99 不包括 1
          // 此处可能为字符串所以统一用 "." 来判断
          bool useRelativePosition = '${json[0]} ${json[1]}'.contains('.');

          List<String> alphaArr = (json[2] as String).split('-');
          double beginAlpha;
          double endAlpha;
          try {
            // [0, 0, "1e-7-1", 10, "⬛️⬛️⬛️⬛️⬛️⬛️⬛️⬛️⬛️⬛️⬛️⬛️⬛️⬛️⬛️⬛️⬛️", 0, 0, 0, 200, 500, 0, 1, "NSimSun", 1]
            beginAlpha = toDouble(alphaArr.first);
            endAlpha = toDouble(alphaArr.last);
          } catch (e, s) {
            _log.e('Unable to parse advanced danmaku payload: invaild alpha array: ${i.content}', error: e, stackTrace: s);
            continue;
          }

          Duration duration = Duration(milliseconds: (toDouble(json[3]) * 1000).toInt());

          Duration translationDuration = duration;
          Duration translationStartDelay = Duration.zero;

          double endX = beginX;
          double endY = beginY;

          double rotateY = 0;
          double rotateZ = 0;

          bool border = false;
          String? fontFamily;

          bool useLinearEaseIn = false;

          text = json[4] as String;

          if (json.length >= 7) {
            rotateZ = toDouble(json[5]);
            rotateY = toDouble(json[6]);
          }

          if (json.length >= 8) {
            endX = toDouble(json[7]);
            useRelativePosition = json[7].toString().contains('.');
          }

          if (json.length >= 9) {
            endY = toDouble(json[8]);
            useRelativePosition = json[8].toString().contains('.');
          }

          if (json.length >= 10) {
            translationDuration = Duration(milliseconds: toInt(json[9]));
          }

          if (json.length >= 11) {
            translationStartDelay = Duration(milliseconds: toInt(json[10]));
          }

          if (json.length >= 12) {
            border = toBool(json[11]);
          }

          if (json.length >= 13) {
            fontFamily = json[12] as String;
          }

          // Linear.easeIn or Quadratic.easeOut
          if (json.length >= 14) {
            useLinearEaseIn = toBool(json[13]);
          }

          extra = ExtraAnimation(
            beginX: beginX,
            beginY: beginY,
            useRelativePosition: useRelativePosition,
            endX: endX,
            endY: endY,
            beginAlpha: beginAlpha,
            endAlpha: endAlpha,
            alphaDuration: duration,
            translationDuration: translationDuration,
            translationStartDelay: translationStartDelay,
            rotateY: rotateY,
            rotateZ: rotateZ,
            duration: duration,
            border: border,
            fontFamily: fontFamily,
            useLinearEaseIn: useLinearEaseIn,
          );
        }

        list.add(
          Danmaku(
            type: switch (i.mode) {
              1 => .scroll,
              2 => .scroll,
              3 => .scroll,
              4 => .bottom,
              5 => .top,
              // 6 => ?, // 逆向弹幕
              7 => .advanced, // 高级弹幕
              // 8 => ?, // 代码弹幕
              _ => throw Exception('Unexpected danmaku type: ${i.mode}'),
            },
            text: text,
            cleanText: text.length > 1 ? cleanString(text) : text,
            time: i.progress,
            color: Color(0xFF000000 | i.color),
            size: i.fontsize - 2,
            extra: extra,
          ),
        );
      }

      return Result.ok(list);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Result<Map<String, GetVideoCardsItem>>> getVideoCards(List<String> videoIds) async {
    assert(videoIds.isNotEmpty);
    assert(!videoIds.any((v) => v.isEmpty));

    final client = await getClient();

    try {
      final resp = await client.get(
        'https://api.vc.bilibili.com/x/im/feed/infoweb',
        queryParameters: {
          'build': 0,
          'mobi_app': 'web',
          'aids': videoIds.join(','),
          'ep_ids': '',
          'article_ids': '',
          'web_location': WebLocation.message,
        },
      );

      _checkResponse(resp);

      final Map<String, GetVideoCardsItem> result = {};

      for (final i in resp.data['data']['archive'] as List) {
        final videoId = i['aid'].toString();
        result[videoId] = GetVideoCardsItem(
          videoId: videoId,
          bvid: i['bvid'],
          cover: i['pic'].isEmpty ? kUnavailableImageUrl : i['pic'],
          title: i['title'],
          nickname: i['up_name'],
          viewCount: i['view'],
          danmakuCount: i['danmaku'],
          duration: i['duration'].toDouble(),
        );
      }

      return Result.ok(result);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Result<void>> markNotInterested({
    required String videoId,
    required String userId,
    required String reasonId,
    required TrackingInfo trackingInfo,
  }) async {
    assert(videoId.isNotEmpty);
    assert(userId.isNotEmpty);
    assert(reasonId.isNotEmpty);
    assert(trackingInfo.id.isNotEmpty && trackingInfo.goto.isNotEmpty);

    final account = await getAccount();
    final client = await getClient();

    try {
      final resp = await client.post(
        'https://api.bilibili.com/x/web-interface/feedback/dislike',
        queryParameters: buildWbiParams({}, account.wbiImgKey, account.wbiSubKey),
        options: Options(contentType: Headers.formUrlEncodedContentType),
        data: {
          'app_id': 100,
          'platform': 5,
          'from_spmid': '',
          'spmid': '${WebLocation.home}.0.0',
          'goto': trackingInfo.goto,
          'id': videoId,
          'mid': userId,
          'track_id': trackingInfo.id,
          'feedback_page': 1,
          'reason_id': reasonId,
          if (account is LoginedAccount) 'csrf': account.biliJct,
        },
      );

      _checkResponse(resp);

      return Result.ok(null);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Result<void>> cancelNotInterested({
    required String videoId,
    required String userId,
    required String reasonId,
    required TrackingInfo trackingInfo,
  }) async {
    assert(videoId.isNotEmpty);
    assert(userId.isNotEmpty);
    assert(reasonId.isNotEmpty);
    assert(trackingInfo.id.isNotEmpty && trackingInfo.goto.isNotEmpty);

    final account = await getAccount();
    final client = await getClient();

    try {
      final resp = await client.post(
        'https://api.bilibili.com/x/web-interface/feedback/dislike/cancel',
        queryParameters: buildWbiParams({}, account.wbiImgKey, account.wbiSubKey),
        options: Options(contentType: Headers.formUrlEncodedContentType),
        data: {
          'app_id': 100,
          'platform': 5,
          'from_spmid': '',
          'spmid': '${WebLocation.home}.0.0',
          'goto': trackingInfo.goto,
          'id': videoId,
          'mid': userId,
          'track_id': trackingInfo.id,
          'feedback_page': 1,
          'reason_id': reasonId,
          if (account is LoginedAccount) 'csrf': account.biliJct,
        },
      );

      _checkResponse(resp);

      return Result.ok(null);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Result<List<GetReportOptionsItem>>> getReportOptions(String videoId) async {
    assert(videoId.isNotEmpty);

    final client = await getClient();

    try {
      final account = await _getLoginedAccount();
      final resp = await client.get(
        'https://api.bilibili.com/x/web-interface/appeal/v2/tags',
        queryParameters: {
          'aid': videoId,
          'buvid': account.buvid3,
          'csrf': account.biliJct,
          'from': 'web',
          'version': 'v1',
          'web_location': '333.46',
        },
      );

      _checkResponse(resp);

      final List<GetReportOptionsItem> result = [];
      for (final group in resp.data['data']['tags'] as List) {
        for (final i in group['sub_tag'] as List) {
          final id = i['tid'].toString();
          final nameKey = 'video_report.reason_name.$id';
          final descripionKey = 'video_report.reason_description.$id';

          if (i['type'] == 'jump') {
            result.add(
              GetReportOptionsItem(
                id: id,
                nameKey: nameKey,
                descripionKey: descripionKey,
                allowInput: false,
                redirectTo: switch (id) {
                  '10029' => i['attr']['url'], //  // 侵犯企业权益
                  _ => '${i['attr']['url']}&aid=$videoId&mid=${resp.data['data']['author']['mid']}&version=new',
                },
              ),
            );
          } else {
            result.add(
              GetReportOptionsItem(
                id: id,
                nameKey: nameKey,
                descripionKey: descripionKey,
                allowInput: true,
              ),
            );
          }
        }
      }

      return Result.ok(result);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Result<GetTimelinePreviewResponse>> getTimelinePreview({
    required String videoId,
    required String episodeId,
  }) async {
    assert(videoId.isNotEmpty && episodeId.isNotEmpty);

    final client = await getClient();

    try {
      final resp = await client.get(
        'https://api.bilibili.com/x/player/videoshot',
        queryParameters: {
          'aid': videoId,
          'cid': episodeId,
        },
      );

      _checkResponse(resp);

      return Result.ok(GetTimelinePreviewResponse.fromJson(resp.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 获取时间线上用于构建亮点波形的点位
  Future<Result<List<double>>> getTimelineWaveform({required String videoId, required String episodeId}) async {
    assert(videoId.isNotEmpty && episodeId.isNotEmpty);

    final client = await getClient();

    try {
      final resp = await client.get(
        'https://bvc.bilivideo.com/pbp/data',
        queryParameters: {
          'aid': videoId,
          'cid': episodeId,
          'bvid': av2bv(videoId),
          'r': 'loader',
        },
      );

      final data = (resp.data['modules'] as List).first['params']['data']['events']['default'] as List?;

      if (data == null) {
        return Result.ok([]);
      }

      final List<double> result = [];
      for (final i in data) {
        result.add(i.toDouble());
      }

      return Result.ok(result);
    } catch (e) {
      return _handleError(e);
    }
  }
}
