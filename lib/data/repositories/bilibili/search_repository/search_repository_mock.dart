import 'package:better_bilibili/data/repositories/bilibili/search_repository/search_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_trending_list_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/search_response.dart';
import 'package:better_bilibili/utils/result.dart';

class SearchRepositoryMock implements SearchRepository {
  @override
  Future<Result<SearchResponse>> getSearchResult({int pn = 1, int ps = 20, required String keyword}) {
    // TODO: implement getSearchResult
    throw UnimplementedError();
  }

  @override
  Future<Result<SearchResponseWithFilter>> getSearchResultWithFilter({
    int pn = 1,
    int ps = 20,
    required String keyword,
    GetSearchResultWithFilterTypeEnum type = .video,
    GetSearchResultWithFilterOrderEnum order = .auto,
    GetSearchResultWithFilterDurationEnum? duration,
    int? categoryId,
    GetSearchResultWithFilterUserTypeEnum userType = .all,
    int releaseTimeStart = 0,
    int releaseTimeEnd = 0,
  }) {
    // TODO: implement getSearchResultWithFilter
    throw UnimplementedError();
  }

  @override
  Future<Result<List<String>>> getSuggestList(String keyword) {
    // TODO: implement getSuggestList
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Trending>>> getTrendingList() {
    // TODO: implement getTrendingList
    throw UnimplementedError();
  }
}
