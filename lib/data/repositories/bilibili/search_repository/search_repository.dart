import 'package:better_bilibili/data/services/bilibili/model/get_trending_list_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/search_response.dart';
import 'package:better_bilibili/utils/result.dart';

abstract interface class SearchRepository {
  Future<Result<SearchResponse>> getSearchResult({
    int pn = 1,
    int ps = 20,
    required String keyword,
  });

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
  });

  Future<Result<List<Trending>>> getTrendingList();

  Future<Result<List<String>>> getSuggestList({required String keyword});
}
