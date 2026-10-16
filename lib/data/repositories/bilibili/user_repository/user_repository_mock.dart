import 'package:better_bilibili/data/model/bilibili/movie_model.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_fans_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorite_articles_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_detail_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_response.dart';
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

class UserRepositoryMock implements UserRepository {
  @override
  Future<Result<void>> addSearchHistory(String keyword) {
    // TODO: implement addSearchHistory
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> addVideoToWatchLater(String videoId) {
    // TODO: implement addVideoToWatchLater
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> blockUser({required String userId, required bool block}) {
    // TODO: implement blockUser
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> clearInvalidInFavorites(String favoritesId) {
    // TODO: implement clearInvalidInFavorites
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> clearSearchHistory() {
    // TODO: implement clearSearchHistory
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> clearWatchHistory() {
    // TODO: implement clearWatchHistory
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> clearWatchedInWatchLater() {
    // TODO: implement clearWatchedInWatchLater
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> copyFavoritesVideos({required List<String> ids, required String sourceFavoritesId, required String targetFavoritesId}) {
    // TODO: implement copyFavoritesVideos
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> copyFromWatchLaterToFavorites({required List<String> ids, required String targetFavoritesId}) {
    // TODO: implement copyFromWatchLaterToFavorites
    throw UnimplementedError();
  }

  @override
  Future<Result<Favorites>> createFavorites({required String name, String? description, bool isPrivate = false, String? coverUrl}) {
    // TODO: implement createFavorites
    throw UnimplementedError();
  }

  @override
  Future<Result<UserGroup>> createUserGroup(String name) {
    // TODO: implement createUserGroup
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteFans(String userId) {
    // TODO: implement deleteFans
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteFavoritePost(String postId) {
    // TODO: implement deleteFavoritePost
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteFavorites(String favoritesId) {
    // TODO: implement deleteFavorites
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteFavoritesVideos({required String favoritesId, required List<String> ids}) {
    // TODO: implement deleteFavoritesVideos
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteSearchHistory(String keyword) {
    // TODO: implement deleteSearchHistory
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteUserGroup(String groupId) {
    // TODO: implement deleteUserGroup
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteVideosFromWatchLater(List<String> ids) {
    // TODO: implement deleteVideosFromWatchLater
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteWatchHistory(List<String> ids) {
    // TODO: implement deleteWatchHistory
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> followUser({required String userId, required bool follow}) {
    // TODO: implement followUser
    throw UnimplementedError();
  }

  @override
  Future<Result<ArticleInteraction>> getArticleInteraction(String articleId) {
    // TODO: implement getArticleInteraction
    throw UnimplementedError();
  }

  @override
  Future<Result<List<dynamic>>> getCoinedVideos(String userId) {
    // TODO: implement getCoinedVideos
    throw UnimplementedError();
  }

  @override
  Future<Result<GetFansResponse>> getFans({required String userId, int pn = 1, int ps = 24}) {
    // TODO: implement getFans
    throw UnimplementedError();
  }

  @override
  Future<Result<GetFavoriteArticlesResponse>> getFavoriteArticles({int pn = 1, int ps = 20}) {
    // TODO: implement getFavoriteArticles
    throw UnimplementedError();
  }

  @override
  Future<Result<GetFavoritesDetailResponse>> getFavoritesDetail({required String favoritesId, int pn = 1, int ps = 20, GetFavoritesDetailOrderEnum order = .favoriteTimeDesc, String? keyword, GetFavoritesDetailScopeEnum scope = .local}) {
    // TODO: implement getFavoritesDetail
    throw UnimplementedError();
  }

  @override
  Future<Result<GetFavoritesResponse>> getFavoritesList({required String userId, int pn = 1, int ps = 20}) {
    // TODO: implement getFavoritesList
    throw UnimplementedError();
  }

  @override
  Future<Result<GetFavoritesSimpleListResponse>> getFavoritesSimpleList({required String userId, String? videoId}) {
    // TODO: implement getFavoritesSimpleList
    throw UnimplementedError();
  }

  @override
  Future<Result<GetFollowingUsersResponse>> getFollowingUsers({required String userId, int pn = 1, int ps = 24, GetFollowingUsersOrderEnum order = .followTimeDesc}) {
    // TODO: implement getFollowingUsers
    throw UnimplementedError();
  }

  @override
  Future<Result<GetFollowingUsersResponse>> getFollowingUsersWithKeyword({required String keyword, int pn = 1, int ps = 24}) {
    // TODO: implement getFollowingUsersWithKeyword
    throw UnimplementedError();
  }

  @override
  Future<Result<List<String>>> getGroupIdsWithUser(String userId) {
    // TODO: implement getGroupIdsWithUser
    throw UnimplementedError();
  }

  @override
  Future<Result<List<UserGroup>>> getGroupList() {
    // TODO: implement getGroupList
    throw UnimplementedError();
  }

  @override
  Future<Result<List<dynamic>>> getLikedVideos(String userId) {
    // TODO: implement getLikedVideos
    throw UnimplementedError();
  }

  @override
  Future<String?> getLocalUserData(String userId, String key) {
    // TODO: implement getLocalUserData
    throw UnimplementedError();
  }

  @override
  Future<Result<GetFollowingUsersResponse>> getMutualFollowingUsers({required String userId, int pn = 1, int ps = 24}) {
    // TODO: implement getMutualFollowingUsers
    throw UnimplementedError();
  }

  @override
  Future<Result<List<String>>> getSearchHistory() {
    // TODO: implement getSearchHistory
    throw UnimplementedError();
  }

  @override
  Future<Result<GetSelfInfoLogginResponse>> getSelfInfo() {
    // TODO: implement getSelfInfo
    throw UnimplementedError();
  }

  @override
  Future<Result<GetSelfStatsResponse>> getSelfStats() {
    // TODO: implement getSelfStats
    throw UnimplementedError();
  }

  @override
  Future<Result<GetSubscribedMangaResponse>> getSubscribedManga({int pn = 1, int ps = 20, GetSubscribedMangaOrderEnum order = .subscribeDesc, bool waitFree = false}) {
    // TODO: implement getSubscribedManga
    throw UnimplementedError();
  }

  @override
  Future<Result<GetSubscribedMovieResponse>> getSubscribedMovie({required String userId, int pn = 1, int ps = 20, GetSubscribedSeriesWatchStatusEnum watchStatus = .all}) {
    // TODO: implement getSubscribedMovie
    throw UnimplementedError();
  }

  @override
  Future<Result<GetSubscribedPlaylistsResponse>> getSubscribedPlaylists({required String userId, int pn = 1, int ps = 50}) {
    // TODO: implement getSubscribedPlaylists
    throw UnimplementedError();
  }

  @override
  Future<Result<GetSubscribedSeriesResponse>> getSubscribedSeries({String? userId, int pn = 1, int ps = 20, GetSubscribedSeriesWatchStatusEnum watchStatus = .all}) {
    // TODO: implement getSubscribedSeries
    throw UnimplementedError();
  }

  @override
  Future<Result<int>> getUnreadPostCount() {
    // TODO: implement getUnreadPostCount
    throw UnimplementedError();
  }

  @override
  Future<Result<GetUserCardResponse>> getUserCard(String userId) {
    // TODO: implement getUserCard
    throw UnimplementedError();
  }

  @override
  Future<Result<Map<String, User>>> getUserCards(List<String> userIds) {
    // TODO: implement getUserCards
    throw UnimplementedError();
  }

  @override
  Future<Result<GetUserCountersResponse>> getUserCounters(String userId) {
    // TODO: implement getUserCounters
    throw UnimplementedError();
  }

  @override
  Future<Result<GetUserInfoResponse>> getUserInfo(String userId) {
    // TODO: implement getUserInfo
    throw UnimplementedError();
  }

  @override
  Future<Result<List<PinnedVideo>>> getUserPinnedVideos(String userId) {
    // TODO: implement getUserPinnedVideos
    throw UnimplementedError();
  }

  @override
  Future<Result<GetUserProfileSettingsResponse>> getUserProfileSettings(String userId) {
    // TODO: implement getUserProfileSettings
    throw UnimplementedError();
  }

  @override
  Future<Result<GetUserRelationResponse>> getUserRelation(String userId) {
    // TODO: implement getUserRelation
    throw UnimplementedError();
  }

  @override
  Future<Result<GetUserStatsResponse>> getUserStats(String userId) {
    // TODO: implement getUserStats
    throw UnimplementedError();
  }

  @override
  Future<Result<GetUserTotalLikeAndViewCountResponse>> getUserTotalLikeAndViewCount(String userId) {
    // TODO: implement getUserTotalLikeAndViewCount
    throw UnimplementedError();
  }

  @override
  Future<Result<List<FollowingUser>>> getUsersInGroup({required String groupId, int pn = 1, int ps = 24}) {
    // TODO: implement getUsersInGroup
    throw UnimplementedError();
  }

  @override
  Future<Result<VideoInteraction>> getVideoInteraction(String videoId) {
    // TODO: implement getVideoInteraction
    throw UnimplementedError();
  }

  @override
  Future<Result<GetWatchHistoryResponse>> getWatchHistory({int nextCursor = 0, int viewAt = 0, GetWatchHistoryTypeEnum type = .all, int ps = 20}) {
    // TODO: implement getWatchHistory
    throw UnimplementedError();
  }

  @override
  Future<Result<bool>> getWatchHistoryConfig() {
    // TODO: implement getWatchHistoryConfig
    throw UnimplementedError();
  }

  @override
  Future<Result<GetWatchHistoryWithFilterResult>> getWatchHistoryWithFilter({int pn = 1, String keyword = '', GetWatchHistoryWithFilterTypeEnum type = .all, int minDuration = 0, int maxDuration = 0, int minUploadTime = 0, int maxUploadTime = 0, GetWatchHistoryWithFilterDeviceTypeEnum deviceType = .all}) {
    // TODO: implement getWatchHistoryWithFilter
    throw UnimplementedError();
  }

  @override
  Future<Result<GetWatchLaterResponse>> getWatchLater({int pn = 1, int ps = 20, GetWatchLaterOrderEnum order = .addTimeDesc, bool onlyUnwatched = false, int? minAddTime, int? maxAddTime, int? minDuration, int? maxDuration, String? keyword}) {
    // TODO: implement getWatchLater
    throw UnimplementedError();
  }

  @override
  Future<Result<bool>> isExistInWatchLater({required String id, required String title}) {
    // TODO: implement isExistInWatchLater
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> modifyFavorites({required String favoritesId, required String name, String? description, bool isPrivate = false, String? coverUrl}) {
    // TODO: implement modifyFavorites
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> modifyMovieWatchStatus({required String movieId, required MovieWatchStatus watchStatus}) {
    // TODO: implement modifyMovieWatchStatus
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> modifySeriesWatchStatus({required String seriesId, required MovieWatchStatus watchStatus}) {
    // TODO: implement modifySeriesWatchStatus
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> modifyTags({List<String>? tags = const []}) {
    // TODO: implement modifyTags
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> modifyUserGroup({required String groupId, required String name}) {
    // TODO: implement modifyUserGroup
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> modifyUserModuleSorting(List<int> moduleSorting) {
    // TODO: implement modifyUserModuleSorting
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> modifyUserPrivacySetting({required UserPrivacySettingsEnum field, required bool value}) {
    // TODO: implement modifyUserPrivacySetting
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> moveFavoritesVideos({required List<String> ids, required String sourceFavoritesId, required String targetFavoritesId}) {
    // TODO: implement moveFavoritesVideos
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> moveFromWatchLaterToFavorites({required List<String> ids, required String targetFavoritesId}) {
    // TODO: implement moveFromWatchLaterToFavorites
    throw UnimplementedError();
  }

  @override
  Future<void> removeLocalUserData(String userId, String key) {
    // TODO: implement removeLocalUserData
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> reorderFavorites({required List<String> ids}) {
    // TODO: implement reorderFavorites
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> reportArticleHistory(String articleId) {
    // TODO: implement reportArticleHistory
    throw UnimplementedError();
  }

  @override
  Future<void> setLocalUserData(String userId, String key, String value) {
    // TODO: implement setLocalUserData
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> setUsersToGroups({required List<String> userIds, List<String>? groupIds}) {
    // TODO: implement setUsersToGroups
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> setWatchHistoryConfig({required bool enable}) {
    // TODO: implement setWatchHistoryConfig
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> unsubscribeFavorites(String favoritesId) {
    // TODO: implement unsubscribeFavorites
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> unsubscribeManga(List<String> mangaIds) {
    // TODO: implement unsubscribeManga
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> unsubscribeMovie(String movieId) {
    // TODO: implement unsubscribeMovie
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> unsubscribePlaylist(String playlistId) {
    // TODO: implement unsubscribePlaylist
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> unsubscribeSeries(String seriesId) {
    // TODO: implement unsubscribeSeries
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> updateFavoritesVideo({required String videoId, List<String>? addIds, List<String>? deleteIds}) {
    // TODO: implement updateFavoritesVideo
    throw UnimplementedError();
  }
}
