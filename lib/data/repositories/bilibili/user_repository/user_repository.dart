import 'package:better_bilibili/data/model/bilibili/movie_model.dart';
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

abstract interface class UserRepository {
  Future<Result<GetUserInfoResponse>> getUserInfo(String userId);

  Future<Result<GetSelfStatsResponse>> getSelfStats();

  Future<Result<GetWatchHistoryResponse>> getWatchHistory({
    int nextCursor = 0,
    int viewAt = 0,
    GetWatchHistoryTypeEnum type = .all,
    int ps = 20,
  });

  Future<Result<GetWatchHistoryWithFilterResult>> getWatchHistoryWithFilter({
    int pn = 1,
    String keyword = '',
    GetWatchHistoryWithFilterTypeEnum type = .all,
    int minDuration = 0,
    int maxDuration = 0,
    int minUploadTime = 0,
    int maxUploadTime = 0,
    GetWatchHistoryWithFilterDeviceTypeEnum deviceType = .all,
  });

  Future<Result<bool>> getWatchHistoryConfig();

  Future<Result<void>> setWatchHistoryConfig({required bool enable});

  Future<Result<void>> deleteWatchHistory(List<String> ids);

  Future<Result<void>> clearWatchHistory();

  Future<Result<GetWatchLaterResponse>> getWatchLater({
    int pn = 1,
    int ps = 20,
    GetWatchLaterOrderEnum order = .addTimeDesc,
    bool onlyUnwatched = false,
    int? minAddTime,
    int? maxAddTime,
    int? minDuration,
    int? maxDuration,
    String? keyword,
  });

  Future<Result<bool>> isExistInWatchLater({required String id, required String title});

  Future<Result<void>> copyFromWatchLaterToFavorites({
    required List<String> ids,
    required String targetFavoritesId,
  });

  Future<Result<void>> moveFromWatchLaterToFavorites({
    required List<String> ids,
    required String targetFavoritesId,
  });

  Future<Result<void>> clearWatchedInWatchLater();

  Future<Result<void>> addVideoToWatchLater(String videoId);

  Future<Result<void>> deleteVideosFromWatchLater(List<String> ids);

  Future<Result<GetFavoritesResponse>> getFavoritesList({
    required String userId,
    int pn = 1,
    int ps = 20,
  });

  Future<Result<GetFavoritesSimpleListResponse>> getFavoritesSimpleList({
    required String userId,
    String? videoId,
  });

  Future<Result<FavoriteFolder>> createFavorites({
    required String name,
    String? description,
    bool isPrivate = false,
    String? cover,
  });

  Future<Result<void>> modifyFavoriteFolder({
    required String favoritesId,
    required String name,
    String? description,
    bool isPrivate = false,
    String? cover,
  });

  Future<Result<void>> deleteFavorites(String favoritesId);

  Future<Result<void>> reorderFavoriteFolder({
    required List<String> ids,
  });

  Future<Result<GetFavoritesDetailResponse>> getFavoritesDetail({
    required String favoritesId,
    int pn = 1,
    int ps = 20,
    GetFavoritesDetailOrderEnum order = .favoriteTimeDesc,
    String? keyword,
    GetFavoritesDetailScopeEnum scope = .local,
  });

  Future<Result<void>> copyFavoritesVideos({
    required List<String> ids,
    required String sourceFavoritesId,
    required String targetFavoritesId,
  });

  Future<Result<void>> moveFavoritesVideos({
    required List<String> ids,
    required String sourceFavoritesId,
    required String targetFavoritesId,
  });

  Future<Result<void>> deleteFavoritesVideos({
    required String favoritesId,
    required List<String> ids,
  });

  Future<Result<void>> clearInvalidInFavorites(String favoritesId);

  Future<Result<void>> updateFavoritesVideo({
    required String videoId,
    List<String>? addIds,
    List<String>? deleteIds,
  });

  Future<Result<GetFavoriteArticlesResponse>> getFavoriteArticles({
    int pn = 1,
    int ps = 20,
  });

  Future<Result<void>> deleteFavoritePost(String postId);

  Future<Result<GetSubscribedPlaylistsResponse>> getSubscribedPlaylists({
    required String userId,
    int pn = 1,
    int ps = 50,
  });

  Future<Result<void>> unsubscribeFavorites(String favoritesId);

  Future<Result<void>> unsubscribePlaylist(String playlistId);

  Future<Result<GetSubscribedSeriesResponse>> getSubscribedSeries({
    String? userId,
    int pn = 1,
    int ps = 20,
    GetSubscribedSeriesWatchStatusEnum watchStatus = .all,
  });

  Future<Result<void>> modifySeriesWatchStatus({
    required String seriesId,
    required MovieWatchStatus watchStatus,
  });

  Future<Result<void>> unsubscribeSeries(String seriesId);

  Future<Result<GetSubscribedMovieResponse>> getSubscribedMovie({
    required String userId,
    int pn = 1,
    int ps = 20,
    GetSubscribedSeriesWatchStatusEnum watchStatus = .all,
  });

  Future<Result<void>> modifyMovieWatchStatus({
    required String movieId,
    required MovieWatchStatus watchStatus,
  });

  Future<Result<void>> unsubscribeMovie(String movieId);

  Future<Result<GetSubscribedMangaResponse>> getSubscribedManga({
    int pn = 1,
    int ps = 20,
    GetSubscribedMangaOrderEnum order = .subscribeDesc,
    bool waitFree = false,
  });

  Future<Result<void>> unsubscribeManga(List<String> mangaIds);

  Future<Result<VideoInteraction>> getVideoInteraction(String videoId);

  Future<Result<List<String>>> getSearchHistory();

  Future<Result<void>> addSearchHistory(String keyword);

  Future<Result<void>> deleteSearchHistory(String keyword);

  Future<Result<void>> clearSearchHistory();

  Future<Result<void>> followUser({required String userId, required bool follow});

  Future<Result<List<dynamic>>> getLikedVideos(String userId);

  Future<Result<List<dynamic>>> getCoinedVideos(String userId);

  Future<Result<ArticleInteraction>> getArticleInteraction(String articleId);

  Future<Result<void>> reportArticleHistory(String articleId);

  Future<Result<int>> getUnreadPostCount();

  Future<Result<UserGroup>> createUserGroup(String name);

  Future<Result<List<UserGroup>>> getGroupList();

  Future<Result<List<FollowingUser>>> getUsersInGroup({
    required String groupId,
    int pn = 1,
    int ps = 24,
  });

  Future<Result<GetFollowingUsersResponse>> getFollowingUsers({
    required String userId,
    int pn = 1,
    int ps = 24,
    GetFollowingUsersOrderEnum order = .followTimeDesc,
  });

  Future<Result<GetFollowingUsersResponse>> getFollowingUsersWithKeyword({
    required String keyword,
    int pn = 1,
    int ps = 24,
  });

  Future<Result<List<String>>> getGroupIdsWithUser(String userId);

  Future<Result<void>> setUsersToGroups({
    required List<String> userIds,
    List<String>? groupIds,
  });

  Future<Result<void>> modifyUserGroup({required String groupId, required String name});

  Future<Result<void>> deleteUserGroup(String groupId);

  Future<Result<GetFansResponse>> getFans({
    required String userId,
    int pn = 1,
    int ps = 24,
  });

  Future<Result<void>> deleteFans(String userId);

  Future<Result<void>> blockUser({required String userId, required bool block});

  Future<Result<GetFollowingUsersResponse>> getMutualFollowingUsers({
    required String userId,
    int pn = 1,
    int ps = 24,
  });

  Future<Result<GetUserStatsResponse>> getUserStats(String userId);

  Future<Result<GetUserTotalLikeAndViewCountResponse>> getUserTotalLikeAndViewCount(String userId);

  Future<Result<List<PinnedVideo>>> getUserPinnedVideos(String userId);

  Future<Result<GetUserProfileSettingsResponse>> getUserProfileSettings(String userId);

  Future<Result<void>> modifyUserPrivacySetting({
    required UserPrivacySettingsEnum field,
    required bool value,
  });

  Future<Result<void>> modifyUserModuleSorting(List<int> moduleSorting);

  Future<Result<void>> modifyTags({List<String>? tags = const []});

  Future<Result<GetUserCountersResponse>> getUserCounters(String userId);

  Future<Result<GetUserRelationResponse>> getUserRelation(String userId);

  Future<Result<GetUserCardResponse>> getUserCard(String userId);

  Future<Result<Map<String, User>>> getUserCards(List<String> userIds);

  Future<Result<GetSelfInfoLogginResponse>> getSelfInfo();

  Future<String?> getLocalUserData(String userId, String key);
  Future<void> setLocalUserData(String userId, String key, String value);
  Future<void> removeLocalUserData(String userId, String key);
}
