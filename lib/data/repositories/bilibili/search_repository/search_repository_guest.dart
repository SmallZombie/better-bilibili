import 'package:better_bilibili/config/account_config.dart';
import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/search_repository/search_repository.dart';
import 'package:better_bilibili/data/services/bilibili/bili_search_web_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_trending_list_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/search_response.dart';
import 'package:better_bilibili/utils/result.dart';

class SearchRepositoryGuest implements SearchRepository {
  final AuthRepository authRepository;
  late final BiliSearchWebApiService searchApiService = BiliSearchWebApiService(
    getClient: () => authRepository.getClient(type: .web, userId: kGuestUserId),
    getAccount: () => authRepository.getAccount('0'),
  );

  SearchRepositoryGuest({required this.authRepository});

  @override
  Future<Result<SearchResponse>> getSearchResult({
    int pn = 1,
    int ps = 20,
    required String keyword,
  }) {
    return searchApiService.getSearchResult(pn: pn, ps: ps, keyword: keyword);
  }

  @override
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
  }) {
    return searchApiService.getSearchResultWithFilter(
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

  @override
  Future<Result<List<Trending>>> getTrendingList() {
    return searchApiService.getTrendingList();
  }

  @override
  Future<Result<List<String>>> getSuggestList( String keyword) {
    return searchApiService.getSuggestList(keyword);
  }
}
