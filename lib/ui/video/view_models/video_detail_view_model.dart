import 'dart:async';

import 'package:better_bilibili/config/danmaku_config.dart';
import 'package:better_bilibili/config/player_config.dart';
import 'package:better_bilibili/data/repositories/bilibili/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/video_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_extra_play_info_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_recommend_videos_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_video_detail_response.dart';
import 'package:better_bilibili/domain/models/bilibili/play_info.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/ui/core/app_shell/app_title_bar_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/history_reporter/bili_history_reporter.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/bili_video_player_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/danmaku_layer/bili_danmaku_controller.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';
import 'package:logging/logging.dart';

class VideoDetailViewModel extends SafeChangeNotifier {
  final Logger _log = Logger('VideoDetailViewModel');
  final VideoRepository videoRepository;
  final UserRepository userRepository;
  final AuthRepository authRepository;
  final PlayerConfig playerConfig;
  final DanmakuConfig danmakuConfig;
  final AppTitleBarController appTitleBarController;

  String videoId;
  String? episodeId;
  String? cover;
  String? playlistId;

  VideoDetailViewModel({
    required this.videoRepository,
    required this.userRepository,
    required this.authRepository,
    required this.playerConfig,
    required this.danmakuConfig,
    required this.appTitleBarController,
    required this.videoId,
    this.episodeId,
    String? initCover,
    this.playlistId,
  }) : cover = initCover {
    getDetail = CancellableCommand0(
      _getDetail,
      onCancel: () {},
      onSuccess: _getDetailSuccess,
    );
    getVideoInteraction = CancellableCommand0(
      _getVideoInteraction,
      onCancel: () {},
      onSuccess: _getVideoInteractionSuccess,
    );
    getPlayInfo = CancellableCommand0(
      _getPlayInfo,
      onCancel: () {},
      onSuccess: _getPlayInfoSuccess,
    );
    like = Command0(_like);
    coin = Command1(_coin);
    favorite = Command1(_favorite);
    watchLater = Command0(_watchLater);
  }

  @override
  void dispose() {
    _biliHistoryReporter?.dispose();
    _danmakuController?.dispose();
    _videoController?.dispose();

    super.dispose();
  }

  late final CancellableCommand0<GetVideoDetailResponse> getDetail;

  VideoDetail? _detail;
  VideoDetail? get detail => _detail;
  VideoDetailStats? _detailStats;
  VideoDetailStats? get detailStats => _detailStats;
  VideoCollection? _collection;
  VideoCollection? get collection => _collection;
  List<RecommendVideo>? _recommandVideos;
  List<RecommendVideo> get recommandVideos => _recommandVideos ?? const [];
  List<VideoDetailEpisode> get episodes => _detail?.episodes != null && _detail!.episodes.length > 1 ? _detail!.episodes : const [];

  Future<Result<GetVideoDetailResponse>> _getDetail() async {
    final result = await videoRepository.getVideoDetail(videoId: videoId);
    return result;
  }

  void _getDetailSuccess(GetVideoDetailResponse result) {
    episodeId = result.video.episodeId;
    cover = result.video.cover;
    _detail = result.video;
    _detailStats = result.video.stats;
    _collection ??= result.video.collection;
    _recommandVideos = result.recommandVideos;

    notifyListeners();
  }

  late final CancellableCommand0<GetVideoInteractionResult> getVideoInteraction;

  VideoInteraction? _interaction;
  VideoInteraction? get interaction => _interaction;

  bool get hasLiked => _interaction?.hasLiked ?? false;
  bool get hasCoined => (_interaction?.coinCount ?? 0) > 0;
  bool get hasFavorited => _interaction?.hasFavorited ?? false;
  bool get hasFollowed => _interaction?.hasFollowed ?? false;

  bool _isInWatchLater = false;
  bool get isInWatchLater => _isInWatchLater;

  Future<Result<GetVideoInteractionResult>> _getVideoInteraction() async {
    final [interactionResult, watchLaterResult] = await Future.wait([
      userRepository.getVideoInteraction(videoId: videoId),
      userRepository.isExistInWatchLater(id: videoId, title: _detail!.title),
    ]);

    switch ((interactionResult, watchLaterResult)) {
      case (Ok(value: final interaction), Ok(value: final inWatchLater)):
        return Result.ok(
          GetVideoInteractionResult(
            interaction: interaction as VideoInteraction,
            isInWatchLater: inWatchLater as bool,
          ),
        );
      case (Error(:final error), _):
        return Result.error(error);
      case (_, Error(:final error)):
        return Result.error(error);
    }
  }

  void _getVideoInteractionSuccess(GetVideoInteractionResult result) {
    _interaction = result.interaction;
    _isInWatchLater = result.isInWatchLater;
    _log.info('new interaction: ${result.interaction.isSubscribedCollection}');

    notifyListeners();
  }

  late final CancellableCommand0<GetPlayInfoResult> getPlayInfo;

  PlayInfo? _playInfo;
  PlayInfo? get playInfo => _playInfo;
  GetExtraPlayInfoResponse? _extraPlayInfo;
  GetExtraPlayInfoResponse? get extraPlayInfo => _extraPlayInfo;
  BiliVideoPlayerController? _videoController;
  BiliVideoPlayerController? get videoController => _videoController;
  BiliDanmakuController? _danmakuController;
  BiliDanmakuController? get danmakuController => _danmakuController;
  BiliHistoryReporter? _biliHistoryReporter;
  BiliHistoryReporter? get biliHistoryReporter => _biliHistoryReporter;

  Future<Result<GetPlayInfoResult>> _getPlayInfo() async {
    final [
      playInfoResult as Result<PlayInfo>,
      extraPlayInfoResult as Result<GetExtraPlayInfoResponse>,
    ] = await Future.wait([
      videoRepository.getPlayInfo(videoId: videoId, episodeId: episodeId!),
      videoRepository.getExtraPlayInfo(videoId: videoId, episodeId: episodeId!),
    ]);

    switch (playInfoResult) {
      case Ok():
        break;
      case Error(:final error):
        Result.error(error);
    }
    switch (extraPlayInfoResult) {
      case Ok():
        break;
      case Error(:final error):
        Result.error(error);
    }

    playInfoResult as Ok<PlayInfo>;
    extraPlayInfoResult as Ok<GetExtraPlayInfoResponse>;

    await playerConfig.ensureInitialized();
    await danmakuConfig.ensureInitialized();

    return Result.ok(
      GetPlayInfoResult(
        playInfo: playInfoResult.value,
        extraPlayInfo: extraPlayInfoResult.value,
      ),
    );
  }

  void _getPlayInfoSuccess(GetPlayInfoResult result) {
    _playInfo = result.playInfo;
    _extraPlayInfo = result.extraPlayInfo;

    _biliHistoryReporter?.dispose();
    _danmakuController?.dispose();
    _videoController?.dispose();

    _videoController = BiliVideoPlayerController(
      authRepository: authRepository,
      playerConfig: playerConfig,
      danmakuConfig: danmakuConfig,
      playInfo: result.playInfo,
      extraPlayInfo: result.extraPlayInfo,
    );
    _danmakuController = BiliDanmakuController(
      contentType: .video,
      contentId: result.playInfo.videoId,
      episodeId: result.playInfo.episodeId,
      config: danmakuConfig,
      controller: _videoController!,
      videoRepository: videoRepository,
    );
    _biliHistoryReporter = BiliHistoryReporter(
      controller: _videoController!,
      videoRepository: videoRepository,
    );

    notifyListeners();
  }

  Future<void> reload() async {
    getDetail.cancel();
    getPlayInfo.cancel();
    getVideoInteraction.cancel();

    final id = videoId;

    if (episodeId == null) {
      await getDetail.execute();
      if (id != videoId) return;
      if (getDetail.error) return;
    }

    await getPlayInfo.execute();
    if (id != videoId) return;
    if (getPlayInfo.error) return;

    if (_detail == null) {
      await getDetail.execute();
      if (id != videoId) return;
      if (getDetail.error) return;
    }

    getVideoInteraction.execute();
  }

  Future<void> switchVideo(String nextVideoId, String? nextEpisodeId, String? nextCover) async {
    _log.info('switchVideo: videoId = $nextVideoId, episodeId = $nextEpisodeId, cover = $nextCover');

    videoId = nextVideoId;
    episodeId = nextEpisodeId;
    cover = nextCover;
    _detail = null;
    _detailStats = null;
    _interaction = null;
    _playInfo = null;

    notifyListeners();
    reload();
  }

  Future<void> switchEpisode(VideoDetailEpisode episode) async {
    _log.info('switchEpisode: episodeId = ${episode.episodeId}, cover = ${episode.cover}');

    episodeId = episode.episodeId;
    cover = episode.cover;
    _playInfo = null;

    notifyListeners();
    reload();
  }

  late final Command0 like;

  Future<Result<void>> _like() async {
    if (_interaction == null) {
      return Result.error(Exception('Interaction not found'));
    }

    final previousInteraction = _interaction!;
    final previousStats = _detailStats;
    final action = !hasLiked;
    final currentLikeCount = previousStats?.like ?? 0;
    final nextLikeCount = currentLikeCount + (action ? 1 : -1);

    _interaction = previousInteraction.copyWith(hasLiked: action);
    _detailStats = previousStats?.copyWith(like: nextLikeCount);
    notifyListeners();

    final result = await videoRepository.like(videoId: videoId, like: action, playTime: 0);
    switch (result) {
      case Ok():
        return result;
      case Error():
        _interaction = previousInteraction;
        _detailStats = previousStats;
        notifyListeners();
        return result;
    }
  }

  late final Command1<void, int> coin;

  Future<Result<void>> _coin(int count) async {
    if (_interaction == null || _detailStats == null) {
      return Result.error(Exception('Interaction not found'));
    }

    final previousInteraction = _interaction!;
    final previousStats = _detailStats!;
    final nextCoinCount = (previousInteraction.coinCount + count).clamp(0, 2);
    final nextCoinStat = previousStats.coin + count;

    _interaction = previousInteraction.copyWith(coinCount: nextCoinCount);
    _detailStats = previousStats.copyWith(coin: nextCoinStat);
    notifyListeners();

    final result = await videoRepository.coin(videoId: videoId, count: count, playTime: 0);
    switch (result) {
      case Ok():
        return result;
      case Error():
        _interaction = previousInteraction;
        _detailStats = previousStats;
        notifyListeners();
        return result;
    }
  }

  late final Command1<void, UpdateVideoFavoritesRequest> favorite;

  Future<Result<void>> _favorite(UpdateVideoFavoritesRequest request) async {
    final addIds = request.addFavoritesIds;
    final deleteIds = request.deleteFavoritesIds;
    if (addIds.isEmpty && deleteIds.isEmpty) {
      return Result.ok(null);
    }

    final previousInteraction = _interaction;
    final previousStats = _detailStats;
    final previousHasFavorited = _interaction?.hasFavorited ?? false;

    if (_interaction != null) {
      _interaction = _interaction!.copyWith(hasFavorited: request.hasFavoritedAfter);
    }
    if (_detailStats != null) {
      final currentFavoriteCount = _detailStats!.favorite;
      final favoriteDelta = request.hasFavoritedAfter == previousHasFavorited ? 0 : (request.hasFavoritedAfter ? 1 : -1);
      final nextFavoriteCount = (currentFavoriteCount + favoriteDelta).clamp(0, 1 << 30).toInt();
      _detailStats = _detailStats!.copyWith(favorite: nextFavoriteCount);
    }
    notifyListeners();

    final result = await userRepository.updateFavoritesVideo(
      videoId: videoId,
      addIds: addIds.isEmpty ? null : addIds,
      deleteIds: deleteIds.isEmpty ? null : deleteIds,
    );
    switch (result) {
      case Ok():
        return result;
      case Error():
        _interaction = previousInteraction;
        _detailStats = previousStats;
        notifyListeners();
        return result;
    }
  }

  late final Command0 watchLater;

  Future<Result<void>> _watchLater() async {
    final action = !_isInWatchLater;
    _isInWatchLater = action;
    notifyListeners();

    if (action) {
      final result = await userRepository.addVideoToWatchLater(videoId: videoId);
      switch (result) {
        case Ok():
          return result;
        case Error():
          _isInWatchLater = !action;
          notifyListeners();
          return result;
      }
    } else {
      final result = await userRepository.deleteVideosFromWatchLater(ids: [videoId]);
      switch (result) {
        case Ok():
          return result;
        case Error():
          _isInWatchLater = !action;
          notifyListeners();
          return result;
      }
    }
  }

  void updateFollowStatus(bool followed) {
    if (_detail == null || _interaction == null) return;

    final owner = _detail!.owner;
    _detail = _detail!.copyWith(
      owner: owner.copyWith(
        stats: owner.stats.copyWith(
          fans: owner.stats.fans + (followed ? 1 : -1),
        ),
      ),
    );
    _interaction = _interaction!.copyWith(hasFollowed: followed);
    notifyListeners();
  }

  void disposePlayer() {
    _playInfo = null;
    _extraPlayInfo = null;
    _danmakuController?.dispose();
    _danmakuController = null;
    notifyListeners();
  }

  bool _isPlayerWindowFullscreen = false;
  bool get isPlayerWindowFullscreen => _isPlayerWindowFullscreen;
  void onToggleWindowFullscreen(bool event) {
    _isPlayerWindowFullscreen = event;

    if (event) {
      appTitleBarController.setTitleBarVisible(false);
    } else if (!_isPlayerFullscreen) {
      appTitleBarController.setTitleBarVisible(true);
    }

    notifyListeners();
  }

  bool _isPlayerFullscreen = false;
  bool get isPlayerFullscreen => _isPlayerFullscreen;
  void onToggleFullscreen(bool event) {
    _isPlayerFullscreen = event;

    if (event) {
      appTitleBarController.setTitleBarVisible(false);
    } else if (!_isPlayerWindowFullscreen) {
      appTitleBarController.setTitleBarVisible(true);
    }

    notifyListeners();
  }
}

class UpdateVideoFavoritesRequest {
  final List<String> addFavoritesIds;
  final List<String> deleteFavoritesIds;
  final bool hasFavoritedAfter;

  UpdateVideoFavoritesRequest({
    List<String>? addFavoritesIds,
    List<String>? deleteFavoritesIds,
    required this.hasFavoritedAfter,
  }) : addFavoritesIds = List.unmodifiable(addFavoritesIds ?? const []),
       deleteFavoritesIds = List.unmodifiable(deleteFavoritesIds ?? const []);
}

class GetVideoInteractionResult {
  final VideoInteraction interaction;
  final bool isInWatchLater;

  GetVideoInteractionResult({
    required this.interaction,
    required this.isInWatchLater,
  });
}

class GetPlayInfoResult {
  final PlayInfo playInfo;
  final GetExtraPlayInfoResponse extraPlayInfo;

  const GetPlayInfoResult({required this.playInfo, required this.extraPlayInfo});
}
