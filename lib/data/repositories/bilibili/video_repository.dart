import 'package:better_bilibili/data/services/bilibili/bili_video_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_collections_and_playlists_with_user_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_extra_play_info_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_playlist_info_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_playlist_keyword_suggestions_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_playlist_videos_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_recommend_videos_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_collections_and_playlists_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_videos_with_keyword_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_video_cards.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_video_detail_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_videos_with_user_id_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/video_report_history.dart';
import 'package:better_bilibili/domain/models/bilibili/bilibili.dart';
import 'package:better_bilibili/domain/models/bilibili/danmaku.dart';
import 'package:better_bilibili/domain/models/bilibili/play_info.dart';
import 'package:better_bilibili/utils/result.dart';

class VideoRepository {
  final BiliVideoApiService _videoApiService;

  VideoRepository({
    required BiliVideoApiService videoApiClient,
  }) : _videoApiService = videoApiClient;

  Future<Result<List<RecommendVideo>>> getRecommendVideos({
    required int pn,
    int ps = 30,
  }) async {
    return _videoApiService.getRecommendVideos(pn: pn, ps: ps);
  }

  Future<Result<List<RecommendVideo>>> getRecommendVideosByCategory({
    required String categoryId,
    required int pn,
    int ps = 20,
  }) async {
    return _videoApiService.getRecommendVideosByCategory(categoryId: categoryId, pn: pn, ps: ps);
  }

  Future<Result<GetVideoDetailResponse>> getVideoDetail({required String videoId}) async {
    return _videoApiService.getVideoDetail(videoId: videoId);
  }

  Future<Result<PlayInfo>> getPlayInfo({required String videoId, required String episodeId}) async {
    return _videoApiService.getPlayInfo(videoId: videoId, episodeId: episodeId);
  }

  Future<Result<void>> like({required String videoId, required bool like, required int playTime}) async {
    return _videoApiService.like(videoId: videoId, like: like, playTime: playTime);
  }

  Future<Result<void>> coin({required String videoId, required int count, required int playTime}) async {
    return _videoApiService.coin(videoId: videoId, count: count, playTime: playTime);
  }

  Future<Result<GetPlaylistInfoResponse>> getPlaylistInfo({required String playlistId}) async {
    return _videoApiService.getPlaylistInfo(playlistId: playlistId);
  }

  Future<Result<GetPlaylistVideosResponse>> getPlaylistVideos({
    required String playlistId,
    String? videoId,
    GetPlaylistVideosDirectionEnum direction = GetPlaylistVideosDirectionEnum.after,
    int ps = 20,
  }) async {
    return _videoApiService.getPlaylistVideos(playlistId: playlistId, videoId: videoId, direction: direction, ps: ps);
  }

  Future<Result<GetVideosWithUserIdResponse>> getVideosWithUser({
    required String userId,
    int pn = 1,
    int ps = 25,
    GetVideosWithUserTypeEnum type = .all,
    GetVideosWithUserOrderEnum order = .releaseTimeDesc,
  }) async {
    return _videoApiService.getVideosWithUser(userId: userId, pn: pn, ps: ps, type: type, order: order);
  }

  Future<Result<GetUserVideosWithKeywordResponse>> getUserVideosWithKeyword({
    String? keyword,
    int pn = 1,
    int ps = 20,
  }) async {
    return _videoApiService.getUserVideosWithKeyword(keyword: keyword, pn: pn, ps: ps);
  }

  Future<Result<List<PlaylistKeywordSuggestion>>> getPlaylistKeywordSuggestions() async {
    return _videoApiService.getPlaylistKeywordSuggestions();
  }

  Future<Result<int>> createPlaylist({
    required String name,
    String? description,
    String? keyword,
    List<String> videoIds = const [],
  }) async {
    return _videoApiService.createPlaylist(name: name, description: description, keyword: keyword, videoIds: videoIds);
  }

  @Deprecated('use [getUserCollectionsAndPlaylists]')
  Future<Result<List<GetCollectionsAndPlaylistsWithUserItem>>> getCollectionsAndPlaylistsWithUser({
    required String userId,
    int ps = 20,
  }) async {
    return _videoApiService.getCollectionsAndPlaylistsWithUser(userId: userId, ps: ps);
  }

  Future<Result<GetUserCollectionsAndPlaylistsResponse>> getUserCollectionsAndPlaylists({
    required String userId,
    int pn = 1,
    int ps = 20,
  }) async {
    return _videoApiService.getUserCollectionsAndPlaylists(userId: userId, pn: pn, ps: ps);
  }

  Future<Result<void>> subscriptionCollection({
    required String collectionId,
    required bool subscription,
  }) async {
    return _videoApiService.subscriptionCollection(collectionId: collectionId, subscription: subscription);
  }

  Future<Result<GetExtraPlayInfoResponse>> getExtraPlayInfo({
    required String videoId,
    required String episodeId,
  }) async {
    return _videoApiService.getExtraPlayInfo(videoId: videoId, episodeId: episodeId);
  }

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
    return _videoApiService.reportHistory(
      videoId: videoId,
      episodeId: episodeId,
      firstPlaybackTime: firstPlaybackTime,
      contentType: contentType,
      actionType: actionType,
      realPlaybackTime: realPlaybackTime,
      duration: duration,
      position: position,
      maxPosition: maxPosition,
      reportCounter: reportCounter,
      playInfoSession: playInfoSession,
      playInfoId: playInfoId,
      videoFileName: videoFileName,
    );
  }

  Future<Result<List<Danmaku>>> getDanmakus({
    required int index,
    required String videoId,
    required String episodeId,
    required BiliContentTypeEnum type,
  }) async {
    return _videoApiService.getDanmakus(
      index: index,
      videoId: videoId,
      episodeId: episodeId,
      type: type,
    );
  }

  Future<Result<Map<String, GetVideoCardsItem>>> getVideoCards(List<String> videoIds) {
    return _videoApiService.getVideoCards(videoIds);
  }

  Future<Result<void>> markNotInterested({
    required String videoId,
    required String userId,
    required String reasonId,
    required TrackingInfo trackingInfo,
  }) {
    return _videoApiService.markNotInterested(
      videoId: videoId,
      userId: userId,
      reasonId: reasonId,
      trackingInfo: trackingInfo,
    );
  }

  Future<Result<void>> cancelNotInterested({
    required String videoId,
    required String userId,
    required String reasonId,
    required TrackingInfo trackingInfo,
  }) {
    return _videoApiService.cancelNotInterested(
      videoId: videoId,
      userId: userId,
      reasonId: reasonId,
      trackingInfo: trackingInfo,
    );
  }
}
