import 'package:better_bilibili/data/model/bilibili/movie_model.dart';
import 'package:better_bilibili/data/repositories/bilibili/auth_repository.dart';
import 'package:better_bilibili/data/services/bilibili/bili_user_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_fans_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorite_articles_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_detail_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_simple_list_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_following_users.dart';
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
import 'package:better_bilibili/data/services/cache_service.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/utils/result.dart';

class UserRepository {
  final BiliUserApiService _biliUserApiService;
  final CacheService _cacheService;
  final AuthRepository _authRepository;

  UserRepository({
    required BiliUserApiService biliUserApiService,
    required CacheService cacheService,
    required AuthRepository authRepository,
  }) : _biliUserApiService = biliUserApiService,
       _authRepository = authRepository,
       _cacheService = cacheService;

  Future<Result<GetUserInfoResponse>> getUserInfo({required String userId}) async {
    return _biliUserApiService.getUserInfo(userId: userId);
  }

  Future<Result<GetSelfStatsResponse>> getSelfStats() async {
    return _biliUserApiService.getSelfStats();
  }

  Future<Result<GetWatchHistoryResponse>> getWatchHistory({
    int nextCursor = 0,
    int viewAt = 0,
    GetWatchHistoryTypeEnum type = GetWatchHistoryTypeEnum.all,
    int ps = 20,
  }) async {
    return _biliUserApiService.getWatchHistory(
      nextCursor: nextCursor,
      viewAt: viewAt,
      type: type,
      ps: ps,
    );
  }

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
    return _biliUserApiService.getWatchHistoryWithFilter(
      pn: pn,
      keyword: keyword,
      type: type,
      minDuration: minDuration,
      maxDuration: maxDuration,
      minUploadTime: minUploadTime,
      maxUploadTime: maxUploadTime,
      deviceType: deviceType,
    );
  }

  Future<Result<bool>> getWatchHistoryConfig() async {
    return _biliUserApiService.getWatchHistoryConfig();
  }

  Future<Result<void>> setWatchHistoryConfig({required bool enable}) async {
    return _biliUserApiService.setWatchHistoryConfig(enable: enable);
  }

  Future<Result<void>> deleteWatchHistory({required List<String> ids}) async {
    return _biliUserApiService.deleteWatchHistory(ids: ids);
  }

  Future<Result<void>> clearWatchHistory() async {
    return _biliUserApiService.clearWatchHistory();
  }

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
    return _biliUserApiService.getWatchLater(
      pn: pn,
      ps: ps,
      order: order,
      onlyUnwatched: onlyUnwatched,
      minAddTime: minAddTime,
      maxAddTime: maxAddTime,
      minDuration: minDuration,
      maxDuration: maxDuration,
      keyword: keyword,
    );
  }

  Future<Result<bool>> isExistInWatchLater({required String id, required String title}) async {
    return _biliUserApiService.isExistInWatchLater(id: id, title: title);
  }

  Future<Result<void>> copyFromWatchLaterToFavorites({
    required List<String> ids,
    required String targetFavoritesId,
  }) async {
    return _biliUserApiService.copyFromWatchLaterToFavorites(
      ids: ids,
      targetFavoritesId: targetFavoritesId,
    );
  }

  Future<Result<void>> moveFromWatchLaterToFavorites({
    required List<String> ids,
    required String targetFavoritesId,
  }) async {
    return _biliUserApiService.moveFromWatchLaterToFavorites(
      ids: ids,
      targetFavoritesId: targetFavoritesId,
    );
  }

  Future<Result<void>> clearWatchedInWatchLater() async {
    return _biliUserApiService.clearWatchedInWatchLater();
  }

  Future<Result<void>> addVideoToWatchLater({required String videoId}) async {
    return _biliUserApiService.addVideoToWatchLater(videoId: videoId);
  }

  Future<Result<void>> deleteVideosFromWatchLater({required List<String> ids}) async {
    return _biliUserApiService.deleteVideosFromWatchLater(ids: ids);
  }

  Future<Result<GetFavoritesResponse>> getFavoritesList({
    String? userId,
    int pn = 1,
    int ps = 20,
  }) async {
    return _biliUserApiService.getFavoritesList(userId: userId, pn: pn, ps: ps);
  }

  Future<Result<GetFavoritesSimpleListResponse>> getFavoritesSimpleList({
    String? userId,
    String? videoId,
  }) async {
    return _biliUserApiService.getFavoritesSimpleList(userId: userId, videoId: videoId);
  }

  Future<Result<Favorites>> createFavorites({
    required String name,
    String? description,
    bool isPrivate = false,
    String? coverUrl,
  }) async {
    return _biliUserApiService.createFavorites(
      name: name,
      description: description,
      isPrivate: isPrivate,
      coverUrl: coverUrl,
    );
  }

  Future<Result<void>> modifyFavorites({
    required String favoritesId,
    required String name,
    String? description,
    bool isPrivate = false,
    String? coverUrl,
  }) async {
    return _biliUserApiService.modifyFavorites(
      favoritesId: favoritesId,
      name: name,
      description: description,
      isPrivate: isPrivate,
      coverUrl: coverUrl,
    );
  }

  Future<Result<void>> deleteFavorites({required String favoritesId}) async {
    return _biliUserApiService.deleteFavorites(favoritesId: favoritesId);
  }

  Future<Result<void>> reorderFavorites({
    required List<String> ids,
  }) async {
    return _biliUserApiService.reorderFavorites(ids: ids);
  }

  Future<Result<GetFavoritesDetailResponse>> getFavoritesDetail({
    required String favoritesId,
    int pn = 1,
    int ps = 20,
    GetFavoritesDetailOrderEnum order = GetFavoritesDetailOrderEnum.favoriteTimeDesc,
    String? keyword,
    GetFavoritesDetailScopeEnum scope = GetFavoritesDetailScopeEnum.local,
  }) async {
    return _biliUserApiService.getFavoritesDetail(
      favoritesId: favoritesId,
      pn: pn,
      ps: ps,
      order: order,
      keyword: keyword,
      scope: scope,
    );
  }

  Future<Result<void>> copyFavoritesVideos({
    required List<String> ids,
    required String sourceFavoritesId,
    required String targetFavoritesId,
  }) async {
    return _biliUserApiService.copyFavoritesVideos(
      ids: ids,
      sourceFavoritesId: sourceFavoritesId,
      targetFavoritesId: targetFavoritesId,
    );
  }

  Future<Result<void>> moveFavoritesVideos({
    required List<String> ids,
    required String sourceFavoritesId,
    required String targetFavoritesId,
  }) async {
    return _biliUserApiService.moveFavoritesVideos(
      ids: ids,
      sourceFavoritesId: sourceFavoritesId,
      targetFavoritesId: targetFavoritesId,
    );
  }

  Future<Result<void>> deleteFavoritesVideos({
    required String favoritesId,
    required List<String> ids,
  }) async {
    return _biliUserApiService.deleteFavoritesVideos(favoritesId: favoritesId, ids: ids);
  }

  Future<Result<void>> clearInvalidInFavorites({required String favoritesId}) async {
    return _biliUserApiService.clearInvalidInFavorites(favoritesId: favoritesId);
  }

  Future<Result<void>> updateFavoritesVideo({
    required String videoId,
    List<String>? addIds,
    List<String>? deleteIds,
  }) async {
    return _biliUserApiService.updateFavoritesVideo(
      videoId: videoId,
      addIds: addIds,
      deleteIds: deleteIds,
    );
  }

  Future<Result<GetFavoriteArticlesResponse>> getFavoriteArticles({
    int pn = 1,
    int ps = 20,
  }) async {
    return _biliUserApiService.getFavoriteArticles(pn: pn, ps: ps);
  }

  Future<Result<void>> deleteFavoritePost({required String postId}) async {
    return _biliUserApiService.deleteFavoritePost(postId: postId);
  }

  Future<Result<GetSubscribedPlaylistsResponse>> getSubscribedPlaylists({
    required String userId,
    int pn = 1,
    int ps = 50,
  }) async {
    return _biliUserApiService.getSubscribedPlaylists(userId: userId, pn: pn, ps: ps);
  }

  Future<Result<void>> unsubscribeFavorites({required String favoritesId}) async {
    return _biliUserApiService.unsubscribeFavorites(favoritesId: favoritesId);
  }

  Future<Result<void>> unsubscribePlaylist({required String playlistId}) async {
    return _biliUserApiService.unsubscribePlaylist(playlistId: playlistId);
  }

  Future<Result<GetSubscribedSeriesResponse>> getSubscribedSeries({
    String? userId,
    int pn = 1,
    int ps = 20,
    GetSubscribedSeriesWatchStatusEnum watchStatus = GetSubscribedSeriesWatchStatusEnum.all,
  }) async {
    return _biliUserApiService.getSubscribedSeries(userId: userId, pn: pn, ps: ps, watchStatus: watchStatus);
  }

  Future<Result<void>> modifySeriesWatchStatus({
    required String seriesId,
    required MovieWatchStatus watchStatus,
  }) async {
    return _biliUserApiService.modifySeriesWatchStatus(seriesId: seriesId, watchStatus: watchStatus);
  }

  Future<Result<void>> unsubscribeSeries({required String seriesId}) async {
    return _biliUserApiService.unsubscribeSeries(seriesId: seriesId);
  }

  Future<Result<GetSubscribedMovieResponse>> getSubscribedMovie({
    String? userId,
    int pn = 1,
    int ps = 20,
    GetSubscribedSeriesWatchStatusEnum watchStatus = GetSubscribedSeriesWatchStatusEnum.all,
  }) async {
    return _biliUserApiService.getSubscribedMovie(userId: userId, pn: pn, ps: ps, watchStatus: watchStatus);
  }

  Future<Result<void>> modifyMovieWatchStatus({
    required String movieId,
    required MovieWatchStatus watchStatus,
  }) async {
    return _biliUserApiService.modifyMovieWatchStatus(movieId: movieId, watchStatus: watchStatus);
  }

  Future<Result<void>> unsubscribeMovie({required String movieId}) async {
    return _biliUserApiService.unsubscribeMovie(movieId: movieId);
  }

  Future<Result<GetSubscribedMangaResponse>> getSubscribedManga({
    int pn = 1,
    int ps = 20,
    GetSubscribedMangaOrderEnum order = GetSubscribedMangaOrderEnum.subscribeDesc,
    bool waitFree = false,
  }) async {
    return _biliUserApiService.getSubscribedManga(pn: pn, ps: ps, order: order, waitFree: waitFree);
  }

  Future<Result<void>> unsubscribeManga({required List<String> mangaIds}) async {
    return _biliUserApiService.unsubscribeManga(mangaIds: mangaIds);
  }

  Future<Result<VideoInteraction>> getVideoInteraction({required String videoId}) async {
    return _biliUserApiService.getVideoInteraction(videoId: videoId);
  }

  Future<List<String>> _getSearchHistory() async {
    final account = await _authRepository.getAccount();
    final str = await _cacheService.getString('search_history.${account.uid}');
    return str == null ? [] : str.split('%%%');
  }

  Future<void> _setSearchHistory(List<String> keywords) async {
    final account = await _authRepository.getAccount();
    await _cacheService.setString('search_history.${account.uid}', keywords.join('%%%'));
  }

  Future<Result<List<String>>> getSearchHistory() async {
    return Result.ok(await _getSearchHistory());
  }

  Future<Result<void>> addSearchHistory(String keyword) async {
    final data = await _getSearchHistory();
    data.removeWhere((v) => v == keyword);
    data.insert(0, keyword);
    await _setSearchHistory(data);
    return Result.ok(null);
  }

  Future<Result<void>> deleteSearchHistory(String keyword) async {
    final data = await _getSearchHistory();
    data.removeWhere((v) => v == keyword);
    await _setSearchHistory(data);
    return Result.ok(null);
  }

  Future<Result<void>> clearSearchHistory() async {
    await _setSearchHistory([]);
    return Result.ok(null);
  }

  Future<Result<void>> followUser({required String userId, required bool follow}) async {
    return _biliUserApiService.followUser(userId: userId, follow: follow);
  }

  Future<Result<List<dynamic>>> getLikedVideos({String? userId}) async {
    return _biliUserApiService.getLikedVideos(userId: userId);
  }

  Future<Result<List<dynamic>>> getCoinedVideos({String? userId}) async {
    return _biliUserApiService.getCoinedVideos(userId: userId);
  }

  Future<Result<ArticleInteraction>> getArticleInteraction({required String articleId}) async {
    return _biliUserApiService.getArticleInteraction(articleId: articleId);
  }

  Future<Result<void>> reportArticleHistory({required String articleId}) async {
    return _biliUserApiService.reportArticleHistory(articleId: articleId);
  }

  Future<Result<int>> getUnreadPostCount() async {
    return _biliUserApiService.getUnreadPostCount();
  }

  Future<Result<UserGroup>> createUserGroup({required String name}) async {
    return _biliUserApiService.createUserGroup(name: name);
  }

  Future<Result<List<UserGroup>>> getGroupList() async {
    return _biliUserApiService.getGroupList();
  }

  Future<Result<List<FollowingUser>>> getUsersInGroup({
    required String groupId,
    int pn = 1,
    int ps = 24,
  }) async {
    return _biliUserApiService.getUsersInGroup(groupId: groupId, pn: pn, ps: ps);
  }

  Future<Result<GetFollowingUsersResponse>> getFollowingUsers({
    required String userId,
    int pn = 1,
    int ps = 24,
    GetFollowingUsersOrderEnum order = GetFollowingUsersOrderEnum.followTimeDesc,
  }) async {
    return _biliUserApiService.getFollowingUsers(
      userId: userId,
      pn: pn,
      ps: ps,
      order: order,
    );
  }

  Future<Result<GetFollowingUsersResponse>> getFollowingUsersWithKeyword({
    required String keyword,
    int pn = 1,
    int ps = 24,
  }) async {
    return _biliUserApiService.getFollowingUsersWithKeyword(
      keyword: keyword,
      pn: pn,
      ps: ps,
    );
  }

  Future<Result<List<String>>> getGroupIdsWithUser({required String userId}) async {
    return _biliUserApiService.getGroupIdsWithUser(userId: userId);
  }

  Future<Result<void>> setUsersToGroups({
    required List<String> userIds,
    List<String>? groupIds,
  }) async {
    return _biliUserApiService.setUsersToGroups(userIds: userIds, groupIds: groupIds);
  }

  Future<Result<void>> modifyUserGroup({required String groupId, required String name}) async {
    return _biliUserApiService.modifyUserGroup(groupId: groupId, name: name);
  }

  Future<Result<void>> deleteUserGroup({required String groupId}) async {
    return _biliUserApiService.deleteUserGroup(groupId: groupId);
  }

  Future<Result<GetFansResponse>> getFans({
    required String userId,
    int pn = 1,
    int ps = 24,
  }) async {
    return _biliUserApiService.getFans(userId: userId, pn: pn, ps: ps);
  }

  Future<Result<void>> deleteFans({required String userId}) async {
    return _biliUserApiService.deleteFans(userId: userId);
  }

  Future<Result<void>> blockUser({required String userId, required bool block}) async {
    return _biliUserApiService.blockUser(userId: userId, block: block);
  }

  Future<Result<GetFollowingUsersResponse>> getMutualFollowingUsers({
    required String userId,
    int pn = 1,
    int ps = 24,
  }) async {
    return _biliUserApiService.getMutualFollowingUsers(userId: userId, pn: pn, ps: ps);
  }

  Future<Result<GetUserStatsResponse>> getUserStats({required String userId}) async {
    return _biliUserApiService.getUserStats(userId: userId);
  }

  Future<Result<GetUserTotalLikeAndViewCountResponse>> getUserTotalLikeAndViewCount({required String userId}) async {
    return _biliUserApiService.getUserTotalLikeAndViewCount(userId: userId);
  }

  Future<Result<List<PinnedVideo>>> getUserPinnedVideos({required String userId}) async {
    return _biliUserApiService.getUserPinnedVideos(userId: userId);
  }

  Future<Result<GetUserProfileSettingsResponse>> getUserProfileSettings({required String userId}) async {
    return _biliUserApiService.getUserProfileSettings(userId: userId);
  }

  Future<Result<void>> modifyUserPrivacySetting({
    required UserPrivacySettingsEnum field,
    required bool value,
  }) async {
    return _biliUserApiService.modifyUserPrivacySetting(field: field, value: value);
  }

  Future<Result<void>> modifyUserModuleSorting({required List<int> moduleSorting}) async {
    return _biliUserApiService.modifyUserModuleSorting(moduleSorting: moduleSorting);
  }

  Future<Result<void>> modifyTags({List<String>? tags = const []}) async {
    return _biliUserApiService.modifyTags(tags: tags);
  }

  Future<Result<GetUserCountersResponse>> getUserCounters({required String userId}) async {
    return _biliUserApiService.getUserCounters(userId: userId);
  }

  Future<Result<GetUserRelationResponse>> getUserRelation({required String userId}) async {
    return _biliUserApiService.getUserRelation(userId: userId);
  }

  Future<Result<GetUserCardResponse>> getUserCard(String userId) {
    return _biliUserApiService.getUserCard(userId);
  }

  Future<Result<Map<String, User>>> getUserCards(List<String> userIds) {
    return _biliUserApiService.getUserCards(userIds);
  }
}
