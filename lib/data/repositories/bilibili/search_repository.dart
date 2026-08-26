import 'package:better_bilibili/data/services/bilibili/bili_search_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_trending_list_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/search_response.dart';
import 'package:better_bilibili/utils/result.dart';

class SearchRepository {
  final BiliSearchApiService _biliSearchApiService;

  SearchRepository({
    required BiliSearchApiService biliSearchApiService,
  }) : _biliSearchApiService = biliSearchApiService;

  Future<Result<SearchResponse>> getSearchResult({
    int pn = 1,
    int ps = 20,
    required String keyword,
  }) async {
    return _biliSearchApiService.getSearchResult(pn: pn, ps: ps, keyword: keyword);
  }

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
    return _biliSearchApiService.getSearchResultWithFilter(
      pn: pn,
      ps: ps,
      keyword: keyword,
      type: type,
      order: order,
      duration: duration,
      categoryId: categoryId,
      userType: userType,
      releaseTimeStart: releaseTimeStart,
      releaseTimeEnd: releaseTimeEnd,
    );
  }

  Future<Result<List<Trending>>> getTrendingList() async {
    return _biliSearchApiService.getTrendingList();
  }

  Future<Result<List<String>>> getSuggestList({required String keyword}) async {
    return _biliSearchApiService.getSuggestList(keyword: keyword);
  }
}
