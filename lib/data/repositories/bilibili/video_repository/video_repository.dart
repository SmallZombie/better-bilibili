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

abstract interface class VideoRepository {
  Future<Result<List<RecommendVideo>>> getRecommendVideos({
    required int pn,
    int ps = 30,
  });

  Future<Result<List<RecommendVideo>>> getRecommendVideosByCategory({
    required String categoryId,
    required int pn,
    int ps = 20,
  });

  Future<Result<GetVideoDetailResponse>> getVideoDetail(String videoId);

  Future<Result<PlayInfo>> getPlayInfo({required String videoId, required String episodeId});

  Future<Result<void>> like({required String videoId, required bool like, required int playTime});

  Future<Result<void>> coin({required String videoId, required int count, required int playTime});

  Future<Result<GetPlaylistInfoResponse>> getPlaylistInfo(String playlistId);

  Future<Result<GetPlaylistVideosResponse>> getPlaylistVideos({
    required String playlistId,
    String? videoId,
    GetPlaylistVideosDirectionEnum direction = .after,
    int ps = 20,
  });

  Future<Result<GetVideosWithUserIdResponse>> getVideosWithUser({
    required String userId,
    int pn = 1,
    int ps = 25,
    GetVideosWithUserTypeEnum type = .all,
    GetVideosWithUserOrderEnum order = .releaseTimeDesc,
  });

  Future<Result<GetUserVideosWithKeywordResponse>> getUserVideosWithKeyword({
    String? keyword,
    int pn = 1,
    int ps = 20,
  });

  Future<Result<List<PlaylistKeywordSuggestion>>> getPlaylistKeywordSuggestions();

  Future<Result<int>> createPlaylist({
    required String name,
    String? description,
    String? keyword,
    List<String> videoIds = const [],
  });

  @Deprecated('use [getUserCollectionsAndPlaylists]')
  Future<Result<List<GetCollectionsAndPlaylistsWithUserItem>>> getCollectionsAndPlaylistsWithUser({
    required String userId,
    int ps = 20,
  });

  Future<Result<GetUserCollectionsAndPlaylistsResponse>> getUserCollectionsAndPlaylists({
    required String userId,
    int pn = 1,
    int ps = 20,
  });

  Future<Result<void>> subscriptionCollection({
    required String collectionId,
    required bool subscription,
  });

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
  });

  Future<Result<List<Danmaku>>> getDanmakus({
    required int index,
    required String videoId,
    required String episodeId,
    required BiliContentTypeEnum type,
  });

  Future<Result<Map<String, GetVideoCardsItem>>> getVideoCards(List<String> videoIds);

  Future<Result<void>> markNotInterested({
    required String videoId,
    required String userId,
    required String reasonId,
    required TrackingInfo trackingInfo,
  });

  Future<Result<void>> cancelNotInterested({
    required String videoId,
    required String userId,
    required String reasonId,
    required TrackingInfo trackingInfo,
  });

  Future<Result<GetTimelinePreviewResponse>> getTimelinePreview({
    required String videoId,
    required String episodeId,
  });

  Future<Result<List<double>>> getTimelineWaveform({
    required String videoId,
    required String episodeId,
  });
}
