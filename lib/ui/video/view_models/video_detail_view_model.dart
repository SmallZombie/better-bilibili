import 'dart:async';

import 'package:better_bilibili/config/danmaku_config.dart';
import 'package:better_bilibili/config/player_config.dart';
import 'package:better_bilibili/data/repositories/bilibili/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/video_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_recommend_videos_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_video_detail_response.dart';
import 'package:better_bilibili/domain/models/bilibili/play_info.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/ui/core/app/app_controller.dart';
import 'package:better_bilibili/ui/core/app/media_session_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/history_reporter/bili_history_reporter.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/bili_video_player_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/danmaku_layer/bili_danmaku_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/notice_layer/notice_controller.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class VideoDetailViewModel extends SafeChangeNotifier {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'VideoDetailViewModel'));

  final VideoRepository videoRepository;
  final UserRepository userRepository;
  final AuthRepository authRepository;
  final PlayerConfig playerConfig;
  final DanmakuConfig danmakuConfig;
  final AppController appController;
  final MediaSessionController mediaSessionController;

  String videoId;
  String? episodeId;
  String? cover;
  String? playlistId;

  /// 额外传入 episodeId 以触发加载加速，
  /// 使用了加载加速并且启用媒体控制时会导致媒体控制在初期短暂显示为 "Unknown Title"
  VideoDetailViewModel({
    required this.videoRepository,
    required this.userRepository,
    required this.authRepository,
    required this.playerConfig,
    required this.danmakuConfig,
    required this.appController,
    required this.mediaSessionController,
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
  List<VideoDetailEpisode> get episodes => _detail?.episodes != null ? _detail!.episodes : const [];

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
    _log.i('new interaction: ${result.interaction.isSubscribedCollection}');

    notifyListeners();
  }

  late final CancellableCommand0<PlayInfo> getPlayInfo;

  PlayInfo? _playInfo;
  PlayInfo? get playInfo => _playInfo;
  BiliVideoPlayerController? _videoController;
  BiliVideoPlayerController? get videoController => _videoController;
  BiliDanmakuController? _danmakuController;
  BiliDanmakuController? get danmakuController => _danmakuController;
  BiliHistoryReporter? _biliHistoryReporter;
  BiliHistoryReporter? get biliHistoryReporter => _biliHistoryReporter;
  final NoticeController _noticeController = NoticeController();

  Future<Result<PlayInfo>> _getPlayInfo() async {
    final result = await videoRepository.getPlayInfo(videoId: videoId, episodeId: episodeId!);
    switch (result) {
      case Ok():
        await playerConfig.ensureInitialized();
        await danmakuConfig.ensureInitialized();
        return result;
      case Error(:final error):
        return Result.error(error);
    }
  }

  bool _isFirstPlayInfoLoad = true;

  void _getPlayInfoSuccess(PlayInfo result) {
    _playInfo = result;
    if (_isFirstPlayInfoLoad && _detail != null) {
      _isFirstPlayInfoLoad = false;

      if (_switchToLastEpisodeIfNeeded()) {
        return;
      }
    }

    _biliHistoryReporter?.dispose();
    _danmakuController?.dispose();
    _videoController?.dispose();

    _videoController = BiliVideoPlayerController(
      authRepository: authRepository,
      playerConfig: playerConfig,
      danmakuConfig: danmakuConfig,
      playInfo: result,
      initPosition: _initPosition ?? result.lastPosition,
      noticeController: _noticeController,
      initTitle: detail?.title,
      mediaSessionController: mediaSessionController,
    );
    if (result.lastPosition != .zero) {
      _noticeController.show(
        Notice(
          content: Text('上次观看到 ${formatDuration(result.lastPosition)}'),
          action: '撤销',
          duration: const Duration(seconds: 6),
          onTap: (self) {
            _videoController?.seek(.zero);
            _noticeController.dismiss(self);
          },
        ),
      );
    }

    _danmakuController = BiliDanmakuController(
      contentType: .video,
      contentId: result.videoId,
      episodeId: result.episodeId,
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

  Duration? _initPosition;

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

      if (_videoController?.title == null) {
        _videoController?.updateTitle(_detail!.title);
      }

      if (_isFirstPlayInfoLoad) {
        _isFirstPlayInfoLoad = false;

        if (_switchToLastEpisodeIfNeeded()) {
          return;
        }
      }
    }

    getVideoInteraction.execute();
  }

  Future<void> switchVideo(String nextVideoId, String? nextEpisodeId, String? nextCover) async {
    _log.i('switchVideo: videoId = $nextVideoId, episodeId = $nextEpisodeId, cover = $nextCover');

    videoId = nextVideoId;
    episodeId = nextEpisodeId;
    cover = nextCover;
    _detail = null;
    _detailStats = null;
    _interaction = null;
    _playInfo = null;
    _initPosition = .zero;

    notifyListeners();
    reload();
  }

  Future<void> switchEpisode(VideoDetailEpisode episode, {Duration initPosition = .zero}) async {
    _log.i('switchEpisode: episodeId = ${episode.episodeId}, cover = ${episode.cover}');

    episodeId = episode.episodeId;
    cover = episode.cover;
    _playInfo = null;
    _initPosition = initPosition;

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
    _danmakuController?.dispose();
    _danmakuController = null;
    notifyListeners();
  }

  bool _isPlayerWindowFullscreen = false;
  bool get isPlayerWindowFullscreen => _isPlayerWindowFullscreen;
  void onToggleWindowFullscreen(bool event) {
    _isPlayerWindowFullscreen = event;

    if (event) {
      appController.setTitleBarVisible(false);
    } else if (!_isPlayerFullscreen) {
      appController.setTitleBarVisible(true);
    }

    notifyListeners();
  }

  bool _isPlayerFullscreen = false;
  bool get isPlayerFullscreen => _isPlayerFullscreen;
  void onToggleFullscreen(bool event) {
    _isPlayerFullscreen = event;

    if (event) {
      appController.setTitleBarVisible(false);
    } else if (!_isPlayerWindowFullscreen) {
      appController.setTitleBarVisible(true);
    }

    notifyListeners();
  }

  /// 如果上次观看的位置不是当前ep，则跳转至对应ep并返回true
  bool _switchToLastEpisodeIfNeeded() {
    if (_playInfo == null || _detail == null) {
      return false;
    }

    final currentEpisode = _detail!.episodes.firstWhere((v) => v.episodeId == episodeId!);
    final lastEpisodeId = _playInfo!.lastEpisodeId;

    if (lastEpisodeId != null && lastEpisodeId != episodeId) {
      final index = _detail!.episodes.indexWhere((v) => v.episodeId == episodeId);
      final lastEpisode = _detail!.episodes[index];

      _log.i('[switchToLastEpisodeIfNeeded] switch to ${lastEpisode.episodeId}($index)');
      switchEpisode(lastEpisode, initPosition: _playInfo!.lastPosition);

      _noticeController.show(
        Notice(
          content: Text('上次观看到 P${index + 1} ${formatDuration(_playInfo!.lastPosition)}'),
          action: '撤销',
          duration: const Duration(seconds: 6),
          onTap: (self) {
            switchEpisode(currentEpisode);
            _noticeController.dismiss(self);
          },
        ),
      );

      return true;
    }

    return false;
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
