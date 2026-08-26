import 'package:better_bilibili/data/repositories/bilibili/auth_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_trending_list_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/search_response.dart';
import 'package:better_bilibili/utils/bili_util.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:dio/dio.dart';

class BiliSearchApiService {
  final AuthRepository _authRepository;

  BiliSearchApiService({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  /// 获取综合搜索结果，但不支持更多筛选条件，需要更多筛选条件请使用 [getSearchResultWithFilter]
  ///
  /// 使用 pn+ps+total 分页
  ///
  /// 返回值 list 可能包含 [SearchResultVideo] | [SearchResultLive]
  Future<Result<SearchResponse>> getSearchResult({
    int pn = 1,
    int ps = 20,
    required String keyword,
  }) async {
    assert(pn > 0 && ps > 0);
    assert(keyword.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    // 没写成变量的都是固定值
    final params = {
      '__refresh__': true,
      '_extra': '',
      'context': '',
      'page': pn,
      'page_size': ps,
      'order': '',
      'pubtime_begin_s': '',
      'pubtime_end_s': '',
      'duration': '',
      'from_source': '',
      'from_spmid': '333.337',
      'platform': 'pc',
      // 此参数无作用，不传或无论传什么都会返回高亮的结果
      'highlight': 1,
      'single_column': 0,
      'keyword': keyword,
      'qv_id': generateQvId(),
      'ad_resource': 5646,
      'source_tag': 3,
      'web_roll_page': 1,
      'web_location': WebLocation.search,
    };
    final (String wts, String wbiSign) = encWbi(params, account.wbiImgKey!, account.wbiSubKey!);
    final resp = await client.get(
      'https://api.bilibili.com/x/web-interface/wbi/search/all/v2',
      options: Options(
        headers: {
          'Referer':
              'https://search.bilibili.com/all?vt=45903040&keyword=${Uri.encodeComponent(keyword)}&from_source=webtop_search&spm_id_from=333.1007&search_source=5',
        },
      ),
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
    for (final item in (resp.data['data']['result'] as List).firstWhere((v) => v['result_type'] == 'video')['data']) {
      // 排除起飞推广
      if (item['biz_data'] != null) continue;

      // 这里有可能出现直播间
      if (item['type'] == 'live_room') {
        list.add(SearchResultLive.fromJson(item));
      } else {
        list.add(SearchResultVideo.fromJson(item));
      }
    }

    final List<SearchResultSeries> series = [];
    for (final item
        in (resp.data['data']['result'] as List).firstWhere((v) => v['result_type'] == 'media_bangumi')['data']) {
      series.add(SearchResultSeries.fromJson(item));
    }

    final List<SearchResultMovie> movies = [];
    for (final item
        in (resp.data['data']['result'] as List).firstWhere((v) => v['result_type'] == 'media_ft')['data']) {
      movies.add(SearchResultMovie.fromJson(item));
    }

    final List<SearchResultUser> users = [];
    for (final item
        in (resp.data['data']['result'] as List).firstWhere((v) => v['result_type'] == 'bili_user')['data']) {
      users.add(SearchResultUser.fromJson(item));
    }

    final List<SearchResultGame> games = [];
    for (final item
        in (resp.data['data']['result'] as List).firstWhere((v) => v['result_type'] == 'web_game')['data']) {
      games.add(SearchResultGame.fromJson(item));
    }

    final List<SearchResultEvent> events = [];
    for (final item
        in (resp.data['data']['result'] as List).firstWhere((v) => v['result_type'] == 'activity')['data']) {
      // 这个接口不知道为什么b站总是会返回一个 id 为 117664 的空活动回来
      if (item['title'].isEmpty) continue;
      events.add(SearchResultEvent.fromJson(item));
    }

    // 横幅广告
    final List<SearchResultBanner> banners = [];
    for (final item
        in (resp.data['data']['result'] as List).firstWhere((v) => v['result_type'] == 'brand_ad')['data']) {
      banners.add(SearchResultBanner.fromJson(item));
    }

    return Result.ok(
      SearchResponse(
        total: resp.data['data']['numResults'],
        list: list,
        series: series,
        movies: movies,
        games: games,
        users: users,
        events: events,
        banners: banners,
      ),
    );
  }

  /// 按特定类型搜索，只能搜索单一分类下的内容，如果需要综合搜索请使用 [getSearchResult]
  ///
  /// 使用 pn+ps+total 分页
  ///
  /// - [type]: 默认 video
  /// - [order]: 默认 auto(综合排序)
  ///
  /// type 为 [video] 时:
  /// - [order]: viewDesc = 播放量降序, releaseTimeDesc = 发布时间降序, danmakuDesc = 弹幕量降序, favoriteDesc = 收藏量降序
  /// - [duration]: under10Minutes = 10分钟以下, under30Minutes = 10-30分钟, under60Minutes = 30-60分钟, over60Minutes = 60分钟以上
  ///
  /// type 为 [live] 时:
  /// - [order]: airtimeDesc = 开播时间降序
  ///
  /// type 为 [article] 时:
  /// - [order]: viewDesc = 浏览量降序, releaseTimeDesc = 发布时间降序, likeDesc = 点赞量降序, commentDesc = 评论量降序
  ///
  /// type 为 [user] 时:
  /// - [order]: fansDesc = 粉丝量降序, fansAsc = 粉丝量升序, levelDesc = 等级降序, levelAsc = 等级升序
  /// - [userType]: all = 全部(默认), uploadVideo = 上传过视频, notUploadVideo = 未上传过视频, certified = 拥有认证
  ///
  /// 注意此接口故意去掉了直播-全部(type=live)和直播-主播(type=live_user)只保留了直播-直播间
  Future<Result<SearchResponseWithFilter>> getSearchResultWithFilter({
    int pn = 1,
    int ps = 20,
    required String keyword,
    GetSearchResultWithFilterTypeEnum type = GetSearchResultWithFilterTypeEnum.video,
    GetSearchResultWithFilterOrderEnum order = GetSearchResultWithFilterOrderEnum.auto,
    GetSearchResultWithFilterDurationEnum? duration,
    int? categoryId,
    GetSearchResultWithFilterUserTypeEnum userType = GetSearchResultWithFilterUserTypeEnum.all,
    int releaseTimeStart = 0,
    int releaseTimeEnd = 0,
  }) async {
    assert(pn > 0 && ps > 0);
    assert(keyword.isNotEmpty);
    assert(releaseTimeStart >= 0 && releaseTimeEnd >= 0);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    // 没写成变量的都是固定值
    final params = {
      'category_id': categoryId ?? '',
      // video = 视频, media_bangumi = 番剧, media_ft = 影视, live = 直播, article = 专栏, bili_user = 用户
      'search_type': type.value,
      'ad_resource': 5654,
      '__refresh__': true,
      '_extra': '',
      'context': '',
      'page': pn,
      'page_size': ps,
      // 可选值(视频)：留空为综合, click = 播放, pubdate = 发布时间, dm = 弹幕, stow = 收藏
      // 可选值(直播)：online = 综合排序, live_time = 最新开播
      // 可选值(专栏)：留空为综合, totalrank = 综合, pubdate = 最新发布, click = 最多点击, attention = 最多喜欢, scores = 最多评论
      // 可选值(用户)：留空为综合, fans = 粉丝数, level = 等级
      'order': order.value,
      'pubtime_begin_s': releaseTimeStart,
      'pubtime_end_s': releaseTimeEnd,
      'from_source': '',
      'from_spmid': '333.337',
      'platform': 'pc',
      'highlight': 1,
      'single_column': 0,
      'keyword': keyword,
      'qv_id': generateQvId(),
      'source_tag': 3,
      'gaia_vtoken': '',
      'dynamic_offset': 0,
      'web_roll_page': 1,
      'web_location': WebLocation.search,
    };
    if (duration != null) {
      params['duration'] = duration.value;
    }
    if (type == GetSearchResultWithFilterTypeEnum.user) {
      // userType 可选值：0 = 全部, 1 = UP主用户, 2 = 普通用户, 3 = 认证用户
      params['user_type'] = userType.value;
      params['order_sort'] =
          (order == GetSearchResultWithFilterOrderEnum.fansAsc || order == GetSearchResultWithFilterOrderEnum.levelAsc)
              ? 1
              : 0;
    }

    final (String wts, String wbiSign) = encWbi(params, account.wbiImgKey!, account.wbiSubKey!);
    final result = await client.get(
      'https://api.bilibili.com/x/web-interface/wbi/search/type',
      options: Options(
        headers: {
          'Referer':
              'https://search.bilibili.com/video?keyword=${Uri.encodeComponent(keyword)}&from_source=webtop_search&spm_id_from=333.1007&search_source=5',
        },
      ),
      queryParameters: {
        ...params,
        'w_rid': wbiSign,
        'wts': wts,
      },
    );

    if (result.data['code'] != 0) {
      return Result.error(Exception('${result.data['code']}: ${result.data['message']}'));
    }

    final List<dynamic> list = [];
    // 直播的搜索结果这里是个对象 {live_room: [], live_user: []}
    // 其余这里是个列表
    if (result.data['data']['result'] is List) {
      for (final item in result.data['data']['result']) {
        // 纯广告
        if (item['type'] == 'picture_ad_0' || item['type'] == 'video_ad_82') {
          continue;
        }

        list.add(switch (item['type']) {
          'video' => SearchResultVideo.fromJson(item),
          'media_bangumi' => SearchResultSeries.fromJson(item),
          'media_ft' => SearchResultMovie.fromJson(item),
          'article' => SearchResultArticle.fromJson(item),
          'bili_user' => SearchResultUser.fromJson(item),
          _ => throw Exception('Invalid type: ${item['type']}'),
        });
      }
    } else {
      for (final item in result.data['data']['result']['live_room']) {
        list.add(SearchResultLive.fromJson(item));
      }
    }

    return Result.ok(
      SearchResponseWithFilter(
        total: result.data['data']['numResults'] as int,
        list: list,
      ),
    );
  }

  /// 获取热搜列表
  Future<Result<List<Trending>>> getTrendingList() async {
    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    // web端搜索框使用的结尾是这个，但这个接口不会返回置顶，
    // 故使用完整榜单接口，还不用 wbi
    // 'https://api.bilibili.com/x/web-interface/wbi/search/square',
    final resp = await client.get(
      // https://www.bilibili.com/blackboard/activity-trending-topic.html
      'https://app.bilibili.com/x/v2/search/trending/ranking',
      queryParameters: {
        'csrf': account.biliJct,
        // 默认30，最大30
        'limit': 30,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    final List<Trending> list = [];
    for (final item in resp.data['data']['top_list']) {
      list.add(
        Trending(
          keyword: item['keyword'],
          name: item['show_name'],
          isPinned: true,
        ),
      );
    }
    for (final item in resp.data['data']['list']) {
      list.add(
        Trending(
          keyword: item['keyword'],
          name: item['show_name'],
          isPinned: false,
        ),
      );
    }

    return Result.ok(list);
  }

  /// 获取搜索建议
  Future<Result<List<String>>> getSuggestList({required String keyword}) async {
    assert(keyword.isNotEmpty);

    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final params = {
      'highlight': 0,
      'term': keyword,
      'spmid': WebLocation.home,
      'web_location': WebLocation.home,
    };
    final (String wts, String wbiSign) = encWbi(params, account.wbiImgKey!, account.wbiSubKey!);
    final resp = await client.get(
      'https://api.bilibili.com/x/web-interface/suggest',
      queryParameters: {
        ...params,
        'w_rid': wbiSign,
        'wts': wts,
      },
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    final List<String> list = [];
    for (final item in resp.data['data']['result']['tag']) {
      list.add(item['value']);
    }

    return Result.ok(list);
  }
}
