import 'package:better_bilibili/data/repositories/bilibili/video_repository/video_repository.dart';
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

class VideoRepositoryMock implements VideoRepository {
  @override
  Future<Result<void>> cancelNotInterested({
    required String videoId,
    required String userId,
    required String reasonId,
    required TrackingInfo trackingInfo,
  }) {
    // TODO: implement cancelNotInterested
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> coin({required String videoId, required int count, required int playTime}) {
    // TODO: implement coin
    throw UnimplementedError();
  }

  @override
  Future<Result<int>> createPlaylist({required String name, String? description, String? keyword, List<String> videoIds = const []}) {
    // TODO: implement createPlaylist
    throw UnimplementedError();
  }

  @override
  Future<Result<List<GetCollectionsAndPlaylistsWithUserItem>>> getCollectionsAndPlaylistsWithUser({required String userId, int ps = 20}) {
    // TODO: implement getCollectionsAndPlaylistsWithUser
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Danmaku>>> getDanmakus({
    required int index,
    required String videoId,
    required String episodeId,
    required BiliContentTypeEnum type,
  }) {
    // TODO: implement getDanmakus
    throw UnimplementedError();
  }

  @override
  Future<Result<PlayInfo>> getPlayInfo({required String videoId, required String episodeId}) {
    // TODO: implement getPlayInfo
    throw UnimplementedError();
  }

  @override
  Future<Result<GetPlaylistInfoResponse>> getPlaylistInfo(String playlistId) {
    // TODO: implement getPlaylistInfo
    throw UnimplementedError();
  }

  @override
  Future<Result<List<PlaylistKeywordSuggestion>>> getPlaylistKeywordSuggestions() {
    // TODO: implement getPlaylistKeywordSuggestions
    throw UnimplementedError();
  }

  @override
  Future<Result<GetPlaylistVideosResponse>> getPlaylistVideos({
    required String playlistId,
    String? videoId,
    GetPlaylistVideosDirectionEnum direction = .after,
    int ps = 20,
  }) {
    // TODO: implement getPlaylistVideos
    throw UnimplementedError();
  }

  @override
  Future<Result<List<RecommendVideo>>> getRecommendVideos({required int pn, int ps = 30}) {
    // TODO: implement getRecommendVideos
    throw UnimplementedError();
  }

  @override
  Future<Result<List<RecommendVideo>>> getRecommendVideosByCategory({required String categoryId, required int pn, int ps = 20}) {
    // TODO: implement getRecommendVideosByCategory
    throw UnimplementedError();
  }

  @override
  Future<Result<GetTimelinePreviewResponse>> getTimelinePreview({required String videoId, required String episodeId}) {
    // TODO: implement getTimelinePreview
    throw UnimplementedError();
  }

  @override
  Future<Result<List<double>>> getTimelineWaveform({required String videoId, required String episodeId}) {
    // TODO: implement getTimelineWaveform
    throw UnimplementedError();
  }

  @override
  Future<Result<GetUserCollectionsAndPlaylistsResponse>> getUserCollectionsAndPlaylists({required String userId, int pn = 1, int ps = 20}) {
    // TODO: implement getUserCollectionsAndPlaylists
    throw UnimplementedError();
  }

  @override
  Future<Result<GetUserVideosWithKeywordResponse>> getUserVideosWithKeyword({String? keyword, int pn = 1, int ps = 20}) {
    // TODO: implement getUserVideosWithKeyword
    throw UnimplementedError();
  }

  @override
  Future<Result<Map<String, GetVideoCardsItem>>> getVideoCards(List<String> videoIds) {
    // TODO: implement getVideoCards
    throw UnimplementedError();
  }

  @override
  Future<Result<GetVideoDetailResponse>> getVideoDetail(String videoId) {
    // TODO: implement getVideoDetail
    throw UnimplementedError();
  }

  @override
  Future<Result<GetVideosWithUserIdResponse>> getVideosWithUser({
    required String userId,
    int pn = 1,
    int ps = 25,
    GetVideosWithUserTypeEnum type = .all,
    GetVideosWithUserOrderEnum order = .releaseTimeDesc,
  }) {
    // TODO: implement getVideosWithUser
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> like({required String videoId, required bool like, required int playTime}) {
    // TODO: implement like
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> markNotInterested({
    required String videoId,
    required String userId,
    required String reasonId,
    required TrackingInfo trackingInfo,
  }) {
    // TODO: implement markNotInterested
    throw UnimplementedError();
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
    // TODO: implement reportHistory
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> subscriptionCollection({required String collectionId, required bool subscription}) {
    // TODO: implement subscriptionCollection
    throw UnimplementedError();
  }
}
