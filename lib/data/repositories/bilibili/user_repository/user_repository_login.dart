import 'package:better_bilibili/config/account_config.dart';
import 'package:better_bilibili/data/model/bilibili/movie_model.dart';
import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/bili_user_web_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_fans_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorite_articles_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_detail_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_simple_list_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_following_users.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_self_info_response.dart';
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
import 'package:better_bilibili/utils/result.dart';

class UserRepositoryLogin implements UserRepository {
  final AuthRepository authRepository;
  late final BiliUserWebApiService userApiService = BiliUserWebApiService(
    getClient: () => authRepository.getClient(type: .web),
    getAccount: authRepository.getAccount,
  );
  final AccountConfig accountConfig;

  UserRepositoryLogin({required this.authRepository, required this.accountConfig});

  @override
  Future<Result<GetUserInfoResponse>> getUserInfo({required String userId}) async {
    return userApiService.getUserInfo(userId: userId);
  }

  @override
  Future<Result<GetSelfStatsResponse>> getSelfStats() async {
    return userApiService.getSelfStats();
  }

  @override
  Future<Result<GetWatchHistoryResponse>> getWatchHistory({
    int nextCursor = 0,
    int viewAt = 0,
    GetWatchHistoryTypeEnum type = GetWatchHistoryTypeEnum.all,
    int ps = 20,
  }) async {
    return userApiService.getWatchHistory(
      nextCursor: nextCursor,
      viewAt: viewAt,
      type: type,
      ps: ps,
    );
  }

  @override
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
    return userApiService.getWatchHistoryWithFilter(
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

  @override
  Future<Result<bool>> getWatchHistoryConfig() async {
    return userApiService.getWatchHistoryConfig();
  }

  @override
  Future<Result<void>> setWatchHistoryConfig({required bool enable}) async {
    return userApiService.setWatchHistoryConfig(enable: enable);
  }

  @override
  Future<Result<void>> deleteWatchHistory({required List<String> ids}) async {
    return userApiService.deleteWatchHistory(ids: ids);
  }

  @override
  Future<Result<void>> clearWatchHistory() async {
    return userApiService.clearWatchHistory();
  }

  @override
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
    return userApiService.getWatchLater(
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

  @override
  Future<Result<bool>> isExistInWatchLater({required String id, required String title}) async {
    return userApiService.isExistInWatchLater(id: id, title: title);
  }

  @override
  Future<Result<void>> copyFromWatchLaterToFavorites({
    required List<String> ids,
    required String targetFavoritesId,
  }) async {
    return userApiService.copyFromWatchLaterToFavorites(
      ids: ids,
      targetFavoritesId: targetFavoritesId,
    );
  }

  @override
  Future<Result<void>> moveFromWatchLaterToFavorites({
    required List<String> ids,
    required String targetFavoritesId,
  }) async {
    return userApiService.moveFromWatchLaterToFavorites(
      ids: ids,
      targetFavoritesId: targetFavoritesId,
    );
  }

  @override
  Future<Result<void>> clearWatchedInWatchLater() async {
    return userApiService.clearWatchedInWatchLater();
  }

  @override
  Future<Result<void>> addVideoToWatchLater({required String videoId}) async {
    return userApiService.addVideoToWatchLater(videoId: videoId);
  }

  @override
  Future<Result<void>> deleteVideosFromWatchLater({required List<String> ids}) async {
    return userApiService.deleteVideosFromWatchLater(ids: ids);
  }

  @override
  Future<Result<GetFavoritesResponse>> getFavoritesList({
    String? userId,
    int pn = 1,
    int ps = 20,
  }) async {
    return userApiService.getFavoritesList(userId: userId, pn: pn, ps: ps);
  }

  @override
  Future<Result<GetFavoritesSimpleListResponse>> getFavoritesSimpleList({
    String? userId,
    String? videoId,
  }) async {
    return userApiService.getFavoritesSimpleList(userId: userId, videoId: videoId);
  }

  @override
  Future<Result<Favorites>> createFavorites({
    required String name,
    String? description,
    bool isPrivate = false,
    String? coverUrl,
  }) async {
    return userApiService.createFavorites(
      name: name,
      description: description,
      isPrivate: isPrivate,
      coverUrl: coverUrl,
    );
  }

  @override
  Future<Result<void>> modifyFavorites({
    required String favoritesId,
    required String name,
    String? description,
    bool isPrivate = false,
    String? coverUrl,
  }) async {
    return userApiService.modifyFavorites(
      favoritesId: favoritesId,
      name: name,
      description: description,
      isPrivate: isPrivate,
      coverUrl: coverUrl,
    );
  }

  @override
  Future<Result<void>> deleteFavorites({required String favoritesId}) async {
    return userApiService.deleteFavorites(favoritesId: favoritesId);
  }

  @override
  Future<Result<void>> reorderFavorites({
    required List<String> ids,
  }) async {
    return userApiService.reorderFavorites(ids: ids);
  }

  @override
  Future<Result<GetFavoritesDetailResponse>> getFavoritesDetail({
    required String favoritesId,
    int pn = 1,
    int ps = 20,
    GetFavoritesDetailOrderEnum order = GetFavoritesDetailOrderEnum.favoriteTimeDesc,
    String? keyword,
    GetFavoritesDetailScopeEnum scope = GetFavoritesDetailScopeEnum.local,
  }) async {
    return userApiService.getFavoritesDetail(
      favoritesId: favoritesId,
      pn: pn,
      ps: ps,
      order: order,
      keyword: keyword,
      scope: scope,
    );
  }

  @override
  Future<Result<void>> copyFavoritesVideos({
    required List<String> ids,
    required String sourceFavoritesId,
    required String targetFavoritesId,
  }) async {
    return userApiService.copyFavoritesVideos(
      ids: ids,
      sourceFavoritesId: sourceFavoritesId,
      targetFavoritesId: targetFavoritesId,
    );
  }

  @override
  Future<Result<void>> moveFavoritesVideos({
    required List<String> ids,
    required String sourceFavoritesId,
    required String targetFavoritesId,
  }) async {
    return userApiService.moveFavoritesVideos(
      ids: ids,
      sourceFavoritesId: sourceFavoritesId,
      targetFavoritesId: targetFavoritesId,
    );
  }

  @override
  Future<Result<void>> deleteFavoritesVideos({
    required String favoritesId,
    required List<String> ids,
  }) async {
    return userApiService.deleteFavoritesVideos(favoritesId: favoritesId, ids: ids);
  }

  @override
  Future<Result<void>> clearInvalidInFavorites({required String favoritesId}) async {
    return userApiService.clearInvalidInFavorites(favoritesId: favoritesId);
  }

  @override
  Future<Result<void>> updateFavoritesVideo({
    required String videoId,
    List<String>? addIds,
    List<String>? deleteIds,
  }) async {
    return userApiService.updateFavoritesVideo(
      videoId: videoId,
      addIds: addIds,
      deleteIds: deleteIds,
    );
  }

  @override
  Future<Result<GetFavoriteArticlesResponse>> getFavoriteArticles({
    int pn = 1,
    int ps = 20,
  }) async {
    return userApiService.getFavoriteArticles(pn: pn, ps: ps);
  }

  @override
  Future<Result<void>> deleteFavoritePost({required String postId}) async {
    return userApiService.deleteFavoritePost(postId: postId);
  }

  @override
  Future<Result<GetSubscribedPlaylistsResponse>> getSubscribedPlaylists({
    required String userId,
    int pn = 1,
    int ps = 50,
  }) async {
    return userApiService.getSubscribedPlaylists(userId: userId, pn: pn, ps: ps);
  }

  @override
  Future<Result<void>> unsubscribeFavorites({required String favoritesId}) async {
    return userApiService.unsubscribeFavorites(favoritesId: favoritesId);
  }

  @override
  Future<Result<void>> unsubscribePlaylist({required String playlistId}) async {
    return userApiService.unsubscribePlaylist(playlistId: playlistId);
  }

  @override
  Future<Result<GetSubscribedSeriesResponse>> getSubscribedSeries({
    String? userId,
    int pn = 1,
    int ps = 20,
    GetSubscribedSeriesWatchStatusEnum watchStatus = GetSubscribedSeriesWatchStatusEnum.all,
  }) async {
    return userApiService.getSubscribedSeries(userId: userId, pn: pn, ps: ps, watchStatus: watchStatus);
  }

  @override
  Future<Result<void>> modifySeriesWatchStatus({
    required String seriesId,
    required MovieWatchStatus watchStatus,
  }) async {
    return userApiService.modifySeriesWatchStatus(seriesId: seriesId, watchStatus: watchStatus);
  }

  @override
  Future<Result<void>> unsubscribeSeries({required String seriesId}) async {
    return userApiService.unsubscribeSeries(seriesId: seriesId);
  }

  @override
  Future<Result<GetSubscribedMovieResponse>> getSubscribedMovie({
    String? userId,
    int pn = 1,
    int ps = 20,
    GetSubscribedSeriesWatchStatusEnum watchStatus = GetSubscribedSeriesWatchStatusEnum.all,
  }) async {
    return userApiService.getSubscribedMovie(userId: userId, pn: pn, ps: ps, watchStatus: watchStatus);
  }

  @override
  Future<Result<void>> modifyMovieWatchStatus({
    required String movieId,
    required MovieWatchStatus watchStatus,
  }) async {
    return userApiService.modifyMovieWatchStatus(movieId: movieId, watchStatus: watchStatus);
  }

  @override
  Future<Result<void>> unsubscribeMovie({required String movieId}) async {
    return userApiService.unsubscribeMovie(movieId: movieId);
  }

  @override
  Future<Result<GetSubscribedMangaResponse>> getSubscribedManga({
    int pn = 1,
    int ps = 20,
    GetSubscribedMangaOrderEnum order = GetSubscribedMangaOrderEnum.subscribeDesc,
    bool waitFree = false,
  }) async {
    return userApiService.getSubscribedManga(pn: pn, ps: ps, order: order, waitFree: waitFree);
  }

  @override
  Future<Result<void>> unsubscribeManga({required List<String> mangaIds}) async {
    return userApiService.unsubscribeManga(mangaIds: mangaIds);
  }

  @override
  Future<Result<VideoInteraction>> getVideoInteraction({required String videoId}) async {
    return userApiService.getVideoInteraction(videoId: videoId);
  }

  Future<List<String>> _getSearchHistory() async {
    final userId = await authRepository.getCurrentAccountId();
    final str = await getLocalUserData(userId, 'search_history');
    return str == null ? [] : str.split('%%%');
  }

  Future<void> _setSearchHistory(List<String> keywords) async {
    final userId = await authRepository.getCurrentAccountId();
    await setLocalUserData(userId, 'search_history', keywords.join('%%%'));
  }

  @override
  Future<Result<List<String>>> getSearchHistory() async {
    return Result.ok(await _getSearchHistory());
  }

  @override
  Future<Result<void>> addSearchHistory(String keyword) async {
    final data = await _getSearchHistory();
    data.removeWhere((v) => v == keyword);
    data.insert(0, keyword);
    await _setSearchHistory(data);
    return Result.ok(null);
  }

  @override
  Future<Result<void>> deleteSearchHistory(String keyword) async {
    final data = await _getSearchHistory();
    data.removeWhere((v) => v == keyword);
    await _setSearchHistory(data);
    return Result.ok(null);
  }

  @override
  Future<Result<void>> clearSearchHistory() async {
    await _setSearchHistory([]);
    return Result.ok(null);
  }

  @override
  Future<Result<void>> followUser({required String userId, required bool follow}) async {
    return userApiService.followUser(userId: userId, follow: follow);
  }

  @override
  Future<Result<List<dynamic>>> getLikedVideos({String? userId}) async {
    return userApiService.getLikedVideos(userId: userId);
  }

  @override
  Future<Result<List<dynamic>>> getCoinedVideos({String? userId}) async {
    return userApiService.getCoinedVideos(userId: userId);
  }

  @override
  Future<Result<ArticleInteraction>> getArticleInteraction({required String articleId}) async {
    return userApiService.getArticleInteraction(articleId: articleId);
  }

  @override
  Future<Result<void>> reportArticleHistory({required String articleId}) async {
    return userApiService.reportArticleHistory(articleId: articleId);
  }

  @override
  Future<Result<int>> getUnreadPostCount() async {
    return userApiService.getUnreadPostCount();
  }

  @override
  Future<Result<UserGroup>> createUserGroup({required String name}) async {
    return userApiService.createUserGroup(name: name);
  }

  @override
  Future<Result<List<UserGroup>>> getGroupList() async {
    return userApiService.getGroupList();
  }

  @override
  Future<Result<List<FollowingUser>>> getUsersInGroup({
    required String groupId,
    int pn = 1,
    int ps = 24,
  }) async {
    return userApiService.getUsersInGroup(groupId: groupId, pn: pn, ps: ps);
  }

  @override
  Future<Result<GetFollowingUsersResponse>> getFollowingUsers({
    required String userId,
    int pn = 1,
    int ps = 24,
    GetFollowingUsersOrderEnum order = GetFollowingUsersOrderEnum.followTimeDesc,
  }) async {
    return userApiService.getFollowingUsers(
      userId: userId,
      pn: pn,
      ps: ps,
      order: order,
    );
  }

  @override
  Future<Result<GetFollowingUsersResponse>> getFollowingUsersWithKeyword({
    required String keyword,
    int pn = 1,
    int ps = 24,
  }) async {
    return userApiService.getFollowingUsersWithKeyword(
      keyword: keyword,
      pn: pn,
      ps: ps,
    );
  }

  @override
  Future<Result<List<String>>> getGroupIdsWithUser({required String userId}) async {
    return userApiService.getGroupIdsWithUser(userId: userId);
  }

  @override
  Future<Result<void>> setUsersToGroups({
    required List<String> userIds,
    List<String>? groupIds,
  }) async {
    return userApiService.setUsersToGroups(userIds: userIds, groupIds: groupIds);
  }

  @override
  Future<Result<void>> modifyUserGroup({required String groupId, required String name}) async {
    return userApiService.modifyUserGroup(groupId: groupId, name: name);
  }

  @override
  Future<Result<void>> deleteUserGroup({required String groupId}) async {
    return userApiService.deleteUserGroup(groupId: groupId);
  }

  @override
  Future<Result<GetFansResponse>> getFans({
    required String userId,
    int pn = 1,
    int ps = 24,
  }) async {
    return userApiService.getFans(userId: userId, pn: pn, ps: ps);
  }

  @override
  Future<Result<void>> deleteFans({required String userId}) async {
    return userApiService.deleteFans(userId: userId);
  }

  @override
  Future<Result<void>> blockUser({required String userId, required bool block}) async {
    return userApiService.blockUser(userId: userId, block: block);
  }

  @override
  Future<Result<GetFollowingUsersResponse>> getMutualFollowingUsers({
    required String userId,
    int pn = 1,
    int ps = 24,
  }) async {
    return userApiService.getMutualFollowingUsers(userId: userId, pn: pn, ps: ps);
  }

  @override
  Future<Result<GetUserStatsResponse>> getUserStats({required String userId}) async {
    return userApiService.getUserStats(userId: userId);
  }

  @override
  Future<Result<GetUserTotalLikeAndViewCountResponse>> getUserTotalLikeAndViewCount({required String userId}) async {
    return userApiService.getUserTotalLikeAndViewCount(userId: userId);
  }

  @override
  Future<Result<List<PinnedVideo>>> getUserPinnedVideos({required String userId}) async {
    return userApiService.getUserPinnedVideos(userId: userId);
  }

  @override
  Future<Result<GetUserProfileSettingsResponse>> getUserProfileSettings({required String userId}) async {
    return userApiService.getUserProfileSettings(userId: userId);
  }

  @override
  Future<Result<void>> modifyUserPrivacySetting({
    required UserPrivacySettingsEnum field,
    required bool value,
  }) async {
    return userApiService.modifyUserPrivacySetting(field: field, value: value);
  }

  @override
  Future<Result<void>> modifyUserModuleSorting({required List<int> moduleSorting}) async {
    return userApiService.modifyUserModuleSorting(moduleSorting: moduleSorting);
  }

  @override
  Future<Result<void>> modifyTags({List<String>? tags = const []}) async {
    return userApiService.modifyTags(tags: tags);
  }

  @override
  Future<Result<GetUserCountersResponse>> getUserCounters({required String userId}) async {
    return userApiService.getUserCounters(userId: userId);
  }

  @override
  Future<Result<GetUserRelationResponse>> getUserRelation({required String userId}) async {
    return userApiService.getUserRelation(userId: userId);
  }

  @override
  Future<Result<GetUserCardResponse>> getUserCard(String userId) {
    return userApiService.getUserCard(userId);
  }

  @override
  Future<Result<Map<String, User>>> getUserCards(List<String> userIds) {
    return userApiService.getUserCards(userIds);
  }

  @override
  Future<Result<GetSelfInfoLogginResponse>> getSelfInfo() {
    return userApiService.getSelfInfo();
  }

  @override
  Future<String?> getLocalUserData(String userId, String key) async {
    final box = accountConfig.box;
    final str = await box.get('user.$userId.$key');
    return str is String ? str : null;
  }

  @override
  Future<void> removeLocalUserData(String userId, String key) {
    final box = accountConfig.box;
    return box.delete('user.$userId.$key');
  }

  @override
  Future<void> setLocalUserData(String userId, String key, String value) {
    final box = accountConfig.box;
    return box.put('user.$userId.$key', value);
  }
}
