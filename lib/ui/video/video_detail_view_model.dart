import 'dart:async';

import 'package:better_bilibili/config/bsbsb_config.dart';
import 'package:better_bilibili/config/constants.dart';
import 'package:better_bilibili/config/danmaku_config.dart';
import 'package:better_bilibili/config/player_config.dart';
import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/video_repository/video_repository.dart';
import 'package:better_bilibili/data/repositories/bsbsb/bsbsb_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_video_detail_response.dart';
import 'package:better_bilibili/domain/models/bilibili/play_info.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/ui/core/app/app_controller.dart';
import 'package:better_bilibili/ui/core/app/media_session_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/extra_video_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/media_session/media_session_data.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/notice/notice_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/playlist/bili_playlist_coordinator.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/playlist/collection/bili_collection_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/playlist/episode/bili_episode_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/playlist/playlist/bili_playlist_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/playlist/recommend/bili_recommend_controller.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';
import 'package:material_ui/material_ui.dart';
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
  final BsbsbRepository bsbsbRepository;
  final BsbsbConfig bsbsbConfig;

  String videoId;
  String? episodeId;
  String? cover;
  String? playlistId;

  /// 额外传入 episodeId 以触发快速播放
  VideoDetailViewModel({
    required this.videoRepository,
    required this.userRepository,
    required this.authRepository,
    required this.playerConfig,
    required this.danmakuConfig,
    required this.appController,
    required this.mediaSessionController,
    required this.bsbsbRepository,
    required this.bsbsbConfig,
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
  }

  @override
  void dispose() {
    videoController.dispose();
    episodeController?.dispose();
    playlistController?.dispose();
    collectionController?.dispose();
    recommendController?.dispose();
    playlistCoordinator?.dispose();
    noticeController.dispose();
    mediaSessionData.dispose();

    super.dispose();
  }

  late final CancellableCommand0<GetVideoDetailResponse> getDetail;

  VideoDetail? _detail;
  VideoDetail? get detail => _detail;
  StateModel? states;
  List<VideoDetailEpisode> get episodes => _detail?.episodes ?? const [];
  VideoCollection? get collection => _detail?.collection;

  BiliEpisodeController? episodeController;
  BiliPlaylistController? playlistController;
  BiliCollectionController? collectionController;
  BiliRecommendController? recommendController;
  BiliPlaylistCoordinator? playlistCoordinator;

  Future<Result<GetVideoDetailResponse>> _getDetail() async {
    final result = await videoRepository.getVideoDetail(videoId: videoId);
    return result;
  }

  void _getDetailSuccess(GetVideoDetailResponse result) {
    videoId = result.video.id;
    episodeId = result.video.episodeId;
    cover = result.video.cover;
    _detail = result.video;
    states = StateModel.from(result.video.stats);

    final hideMediaControlInfo = playerConfig.hideMediaControlInfo.value;
    mediaSessionData.setPrivacyMode(hideMediaControlInfo);
    mediaSessionData.setTitle(_detail!.title);
    mediaSessionData.setArtist(kAppName);

    if (result.video.episodes.length > 1) {
      episodeController?.dispose();
      episodeController = BiliEpisodeController(
        episodes: result.video.episodes,
        onPlay: switchEpisode,
      );
    } else {
      episodeController?.dispose();
      episodeController = null;
    }

    if (playlistId != null && playlistController == null) {
      playlistController = BiliPlaylistController(
        playlistId: playlistId!,
        initVideoId: videoId,
        videoRepository: videoRepository,
        onPlay: (event) {
          switchVideo(event.id, event.episodeId, event.cover);
        },
      );
    }

    if (result.video.collection != null && result.video.collection?.id != collectionController?.collection.id) {
      collectionController?.dispose();
      collectionController = BiliCollectionController(
        collection: result.video.collection!,
        initVideoId: videoId,
        onPlay: (event) {
          switchVideo(event.id, event.episodeId, event.cover);
        },
      );
    } else {
      collectionController?.dispose();
      collectionController = null;
    }

    if (result.recommendVideos.isNotEmpty) {
      recommendController?.dispose();
      recommendController = BiliRecommendController(
        videos: result.recommendVideos,
        onPlay: (event) {
          switchVideo(event.id, event.episodeId, event.cover);
        },
      );
    } else {
      recommendController?.dispose();
      recommendController = null;
    }

    if ([
      episodeController,
      playlistController,
      collectionController,
      recommendController,
    ].any((v) => v != null)) {
      playlistCoordinator?.dispose();
      playlistCoordinator = BiliPlaylistCoordinator(
        config: playerConfig,
        episodeController: episodeController,
        playlistController: playlistController,
        collectionController: collectionController,
        recommendController: recommendController,
      );
    } else {
      playlistCoordinator?.dispose();
      playlistCoordinator = null;
    }

    if (_canResumePosition()) {
      _resumePosition();
    } else {
      notifyListeners();
    }

    if (_detail != null && _playInfo != null) {
      _isFirstPlay = false;
    }
  }

  late final CancellableCommand0<VideoInteraction> getVideoInteraction;

  bool get hasLiked => states?.hasLiked ?? false;
  bool get hasCoined => (states?.coinCount ?? 0) > 0;
  bool get hasFavorited => states?.hasFavorited ?? false;
  bool get hasFollowed => states?.hasFollowed ?? false;

  Future<Result<VideoInteraction>> _getVideoInteraction() async {
    return userRepository.getVideoInteraction(videoId: videoId);
  }

  void _getVideoInteractionSuccess(VideoInteraction result) {
    states = states?.copyWith(
      hasLiked: result.hasLiked,
      hasDisliked: result.hasDisliked,
      hasFavorited: result.hasFavorited,
      coinCount: result.coinCount,
      hasFollowed: result.hasFollowed,
      isSubscribedCollection: result.isSubscribedCollection,
    );
    notifyListeners();
  }

  late final CancellableCommand0<PlayInfo> getPlayInfo;

  PlayInfo? _playInfo;
  PlayInfo? get playInfo => _playInfo;
  final ExtraVideoController videoController = ExtraVideoController(kAppName);
  final MediaSessionData mediaSessionData = MediaSessionData();
  final NoticeController noticeController = NoticeController();

  Future<Result<PlayInfo>> _getPlayInfo() async {
    final result = await videoRepository.getPlayInfo(videoId: videoId, episodeId: episodeId!);
    return result;
  }

  void _getPlayInfoSuccess(PlayInfo result) {
    _playInfo = result;

    if (_canResumePosition()) {
      _resumePosition();
    } else {
      notifyListeners();
    }

    if (_detail != null && _playInfo != null) {
      _isFirstPlay = false;
    }
  }

  bool _isFirstPlay = true;

  /// 是否需要切换剧集才能恢复观看位置
  bool _needSwitchEpisodeToResumePosition() {
    return _playInfo?.lastEpisodeId != null && _playInfo!.lastEpisodeId != episodeId;
  }

  bool _canResumePosition() {
    if (_playInfo == null || _detail == null) {
      return false;
    }

    if (!_isFirstPlay) {
      return false;
    }

    if (episodeId != _playInfo!.lastEpisodeId) {
      return true;
    }
    if (_playInfo!.lastPosition > .zero) {
      // 如果恢复位置接近视频末尾，则视为观看完成
      if (playInfo!.lastPosition > playInfo!.duration - const Duration(seconds: 5)) {
        return false;
      }

      return true;
    }

    return false;
  }

  void _resumePosition() {
    if (_detail == null || _playInfo == null) {
      return;
    }

    if (_needSwitchEpisodeToResumePosition() && episodeController != null) {
      final index = episodeController!.getIndexByEpisodeId(playInfo!.lastEpisodeId!);
      if (index == -1) return;

      final indexBak = episodeController!.index;
      final positionBak = videoController.state.position;

      noticeController.show(
        Notice(
          content: Text('上次观看到 P${index + 1} ${formatDuration(_playInfo!.lastPosition)}'),
          action: '撤销',
          duration: const Duration(seconds: 6),
          onTap: (self) {
            episodeController!.playByIndex(indexBak, positionBak);
            noticeController.dismiss(self);
          },
        ),
      );

      episodeController!.playByIndex(index, playInfo!.lastPosition);
      return;
    }

    if (playInfo!.lastPosition > .zero) {
      final positionBak = videoController.state.position;
      noticeController.show(
        Notice(
          content: Text('上次观看到 ${formatDuration(playInfo!.lastPosition)}'),
          action: '撤销',
          duration: const Duration(seconds: 6),
          onTap: (self) {
            videoController.seek(positionBak);
            noticeController.dismiss(self);
          },
        ),
      );

      // 因为快速播放的存在，如果触发了快速播放 playInfo 会先加载，
      // 此时检查会因为缺少 detail 返回 false，
      // 然后 detail 加载完成后检查返回 true，此时到达此处可能会因为 duration 未加载而 seek 失败
      //
      // 如果给 [ExtraVideoController] 加一个 initPosition：
      // 这在没有剧集的情况下可行，因为我们可以将检查中的 detail == null 去掉，
      // 这样就可以在 playInfo 的检查中返回 true 了，但这在存在剧集的情况下是不行的，
      // 因为剧集信息由 detail 返回，省略 detail 检查会导致在需要跳转剧集的情况下恢复失败
      //
      // 既然播放由 [BiliQualityController] 控制，那么我们手动控制他何时加载呢：
      // 首先这样做会让 ViewModel 多一个需要管理生命周期的类，这一点就不太能接受了，
      // 其次这样做就相当于我们在触发快速播放时不提前加载 videoController，而是等待 detail 然后再加载，
      // 那快速播放不就没有意义了么
      //
      // 最后这里想了一个退而求其次的方案，改 seek：
      // 如果在 seek 时 duration 为 0，我们就等待 duration 直到他不为 0
      videoController.seek(playInfo!.lastPosition);
      return;
    }
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
    _log.i('switchVideo: videoId = $nextVideoId, episodeId = $nextEpisodeId, cover = $nextCover');

    videoId = nextVideoId;
    episodeId = nextEpisodeId;
    cover = nextCover;
    _detail = null;
    states = null;
    // _playInfo = null;

    notifyListeners();
    reload();
  }

  Future<void> switchEpisode(VideoDetailEpisode episode, [Duration? initPosition]) async {
    _log.i('switchEpisode: episodeId = ${episode.id}, cover = ${episode.cover}, initPosition=$initPosition');

    episodeId = episode.id;
    cover = episode.cover;
    // _playInfo = null;
    if (initPosition != null) {
      videoController.setInitPosition(initPosition);
    }

    notifyListeners();
    Future.microtask(reload);
  }

  late final Command0 like;

  Future<Result<void>> _like() async {
    if (states == null) return Result.ok(null);

    final statesBak = states;
    final action = !hasLiked;

    states = states!.copyWith(hasLiked: action, like: states!.like + 1);
    notifyListeners();

    final result = await videoRepository.like(videoId: videoId, like: action, playTime: 0);
    switch (result) {
      case Ok():
        return result;
      case Error():
        states = statesBak;
        notifyListeners();
        return result;
    }
  }

  late final Command1<void, int> coin;

  Future<Result<void>> _coin(int count) async {
    if (states == null) return Result.ok(null);

    final statesBak = states;

    states = states!.copyWith(
      coinCount: states!.coinCount + count,
      like: states!.coinCount + count,
    );
    notifyListeners();

    final result = await videoRepository.coin(videoId: videoId, count: count, playTime: 0);
    switch (result) {
      case Ok():
        return result;
      case Error():
        states = statesBak;
        notifyListeners();
        return result;
    }
  }

  late final Command1<void, UpdateVideoFavoritesRequest> favorite;

  Future<Result<void>> _favorite(UpdateVideoFavoritesRequest request) async {
    if (states == null) return Result.ok(null);

    final addIds = request.addFavoritesIds;
    final deleteIds = request.deleteFavoritesIds;
    if (addIds.isEmpty && deleteIds.isEmpty) {
      return Result.ok(null);
    }

    final statesBak = states;

    final currFavoriteCount = states!.favorite;
    final delta = request.hasFavoritedAfter == states!.hasFavorited ? 0 : (request.hasFavoritedAfter ? 1 : -1);
    states = states!.copyWith(
      hasFavorited: request.hasFavoritedAfter,
      favorite: (currFavoriteCount + delta).clamp(0, 1 << 30).toInt(),
    );
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
        states = statesBak;
        notifyListeners();
        return result;
    }
  }

  void updateFollowStatus(bool followed) {
    if (_detail == null || states == null) return;

    final owner = _detail!.owner;
    _detail = _detail!.copyWith(
      owner: owner.copyWith(
        stats: owner.stats.copyWith(
          fans: owner.stats.fans + (followed ? 1 : -1),
        ),
      ),
    );
    states = states!.copyWith(hasFollowed: followed);
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

class StateModel {
  final int view;
  final int danmaku;
  final int comment;
  final int like;
  final int coin;
  final int favorite;
  final int share;
  final bool hasLiked;
  final bool hasDisliked;
  final bool hasFavorited;
  final int coinCount;
  final bool hasFollowed;
  final bool isSubscribedCollection;
  final bool hasWatchLater;

  const StateModel({
    required this.view,
    required this.danmaku,
    required this.comment,
    required this.like,
    required this.coin,
    required this.favorite,
    required this.share,
    required this.hasLiked,
    required this.hasDisliked,
    required this.hasFavorited,
    required this.coinCount,
    required this.hasFollowed,
    required this.isSubscribedCollection,
    required this.hasWatchLater,
  });

  factory StateModel.from(VideoDetailStats stats) {
    return StateModel(
      view: stats.view,
      danmaku: stats.danmaku,
      comment: stats.comment,
      like: stats.like,
      coin: stats.coin,
      favorite: stats.favorite,
      share: stats.share,
      hasLiked: false,
      hasDisliked: false,
      hasFavorited: false,
      coinCount: 0,
      hasFollowed: false,
      isSubscribedCollection: false,
      hasWatchLater: false,
    );
  }

  StateModel copyWith({
    int? view,
    int? danmaku,
    int? comment,
    int? like,
    int? coin,
    int? favorite,
    int? share,
    bool? hasLiked,
    bool? hasDisliked,
    bool? hasFavorited,
    int? coinCount,
    bool? hasFollowed,
    bool? isSubscribedCollection,
    bool? hasWatchLater,
  }) {
    return StateModel(
      view: view ?? this.view,
      danmaku: danmaku ?? this.danmaku,
      comment: comment ?? this.comment,
      like: like ?? this.like,
      coin: coin ?? this.coin,
      favorite: favorite ?? this.favorite,
      share: share ?? this.share,
      hasLiked: hasLiked ?? this.hasLiked,
      hasDisliked: hasDisliked ?? this.hasDisliked,
      hasFavorited: hasFavorited ?? this.hasFavorited,
      coinCount: coinCount ?? this.coinCount,
      hasFollowed: hasFollowed ?? this.hasFollowed,
      isSubscribedCollection: isSubscribedCollection ?? this.isSubscribedCollection,
      hasWatchLater: hasWatchLater ?? this.hasWatchLater,
    );
  }
}
