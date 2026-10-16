import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/video_repository/video_repository.dart';
import 'package:better_bilibili/data/services/bilibili/bili_video_web_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_collections_and_playlists_with_user_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_playlist_info_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_playlist_keyword_suggestions_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_playlist_videos_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_recommend_videos_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_timeline_preview_response.dart';
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

class VideoRepositoryLogin implements VideoRepository {
  final AuthRepository authRepository;
  late final BiliVideoWebApiService videoApiService = BiliVideoWebApiService(
    getClient: () => authRepository.getClient(type: .web),
    getAccount: authRepository.getAccount,
  );

  VideoRepositoryLogin({required this.authRepository});

  @override
  Future<Result<List<RecommendVideo>>> getRecommendVideos({
    required int pn,
    int ps = 30,
  }) {
    return videoApiService.getRecommendVideos(pn: pn, ps: ps);
  }

  @override
  Future<Result<List<RecommendVideo>>> getRecommendVideosByCategory({
    required String categoryId,
    required int pn,
    int ps = 20,
  }) {
    return videoApiService.getRecommendVideosByCategory(categoryId: categoryId, pn: pn, ps: ps);
  }

  @override
  Future<Result<GetVideoDetailResponse>> getVideoDetail( String videoId) {
    return videoApiService.getVideoDetail( videoId);
  }

  @override
  Future<Result<PlayInfo>> getPlayInfo({required String videoId, required String episodeId}) {
    return videoApiService.getPlayInfo(videoId: videoId, episodeId: episodeId);
  }

  @override
  Future<Result<void>> like({required String videoId, required bool like, required int playTime}) {
    return videoApiService.like(videoId: videoId, like: like, playTime: playTime);
  }

  @override
  Future<Result<void>> coin({required String videoId, required int count, required int playTime}) {
    return videoApiService.coin(videoId: videoId, count: count, playTime: playTime);
  }

  @override
  Future<Result<GetPlaylistInfoResponse>> getPlaylistInfo( String playlistId) {
    return videoApiService.getPlaylistInfo( playlistId);
  }

  @override
  Future<Result<GetPlaylistVideosResponse>> getPlaylistVideos({
    required String playlistId,
    String? videoId,
    GetPlaylistVideosDirectionEnum direction = GetPlaylistVideosDirectionEnum.after,
    int ps = 20,
  }) {
    return videoApiService.getPlaylistVideos(playlistId: playlistId, videoId: videoId, direction: direction, ps: ps);
  }

  @override
  Future<Result<GetVideosWithUserIdResponse>> getVideosWithUser({
    required String userId,
    int pn = 1,
    int ps = 25,
    GetVideosWithUserTypeEnum type = .all,
    GetVideosWithUserOrderEnum order = .releaseTimeDesc,
  }) {
    return videoApiService.getVideosWithUser(userId: userId, pn: pn, ps: ps, type: type, order: order);
  }

  @override
  Future<Result<GetUserVideosWithKeywordResponse>> getUserVideosWithKeyword({
    String? keyword,
    int pn = 1,
    int ps = 20,
  }) {
    return videoApiService.getUserVideosWithKeyword(keyword: keyword, pn: pn, ps: ps);
  }

  @override
  Future<Result<List<PlaylistKeywordSuggestion>>> getPlaylistKeywordSuggestions() {
    return videoApiService.getPlaylistKeywordSuggestions();
  }

  @override
  Future<Result<int>> createPlaylist({
    required String name,
    String? description,
    String? keyword,
    List<String> videoIds = const [],
  }) {
    return videoApiService.createPlaylist(name: name, description: description, keyword: keyword, videoIds: videoIds);
  }

  @override
  Future<Result<List<GetCollectionsAndPlaylistsWithUserItem>>> getCollectionsAndPlaylistsWithUser({
    required String userId,
    int ps = 20,
  }) {
    return videoApiService.getCollectionsAndPlaylistsWithUser(userId: userId, ps: ps);
  }

  @override
  Future<Result<GetUserCollectionsAndPlaylistsResponse>> getUserCollectionsAndPlaylists({
    required String userId,
    int pn = 1,
    int ps = 20,
  }) {
    return videoApiService.getUserCollectionsAndPlaylists(userId: userId, pn: pn, ps: ps);
  }

  @override
  Future<Result<void>> subscriptionCollection({
    required String collectionId,
    required bool subscription,
  }) {
    return videoApiService.subscriptionCollection(collectionId: collectionId, subscription: subscription);
  }

  @override
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
  }) {
    return videoApiService.reportHistory(
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

  @override
  Future<Result<List<Danmaku>>> getDanmakus({
    required int index,
    required String videoId,
    required String episodeId,
    required BiliContentTypeEnum type,
  }) {
    return videoApiService.getDanmakus(
      index: index,
      videoId: videoId,
      episodeId: episodeId,
      type: type,
    );
  }

  @override
  Future<Result<Map<String, GetVideoCardsItem>>> getVideoCards(List<String> videoIds) {
    return videoApiService.getVideoCards(videoIds);
  }

  @override
  Future<Result<void>> markNotInterested({
    required String videoId,
    required String userId,
    required String reasonId,
    required TrackingInfo trackingInfo,
  }) {
    return videoApiService.markNotInterested(
      videoId: videoId,
      userId: userId,
      reasonId: reasonId,
      trackingInfo: trackingInfo,
    );
  }

  @override
  Future<Result<void>> cancelNotInterested({
    required String videoId,
    required String userId,
    required String reasonId,
    required TrackingInfo trackingInfo,
  }) {
    return videoApiService.cancelNotInterested(
      videoId: videoId,
      userId: userId,
      reasonId: reasonId,
      trackingInfo: trackingInfo,
    );
  }

  @override
  Future<Result<GetTimelinePreviewResponse>> getTimelinePreview({required String videoId, required String episodeId}) {
    return videoApiService.getTimelinePreview(videoId: videoId, episodeId: episodeId);
  }

  @override
  Future<Result<List<double>>> getTimelineWaveform({required String videoId, required String episodeId}) {
    return videoApiService.getTimelineWaveform(videoId: videoId, episodeId: episodeId);
  }
}
