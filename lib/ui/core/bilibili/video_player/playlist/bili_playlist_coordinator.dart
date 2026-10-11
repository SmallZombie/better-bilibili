import 'dart:async';

import 'package:better_bilibili/config/player_config.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/playlist/collection/bili_collection_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/playlist/episode/bili_episode_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/playlist/playlist/bili_playlist_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/playlist/recommend/bili_recommend_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/playlist/playlist_controller.dart';
import 'package:material_ui/material_ui.dart';

/// 负责协调剧集、播放列表、合集与推荐视频之间的播放逻辑
class BiliPlaylistCoordinator extends ChangeNotifier implements PlaylistController {
  final PlayerConfig config;
  final BiliEpisodeController? episodeController;
  final BiliPlaylistController? playlistController;
  final BiliCollectionController? collectionController;
  final BiliRecommendController? recommendController;

  final List<StreamSubscription> _subscriptions = [];

  BiliPlaylistCoordinator({
    required this.config,
    this.episodeController,
    this.playlistController,
    this.collectionController,
    this.recommendController,
  }) {
    _update();

    _subscriptions.addAll([
      config.autoPlayNextEpisode.stream.listen((_) => _update()),
      config.autoPlayNextPlaylist.stream.listen((_) => _update()),
      config.autoPlayNextCollection.stream.listen((_) => _update()),
      config.autoPlayNextRecommend.stream.listen((_) => _update()),
    ]);

    episodeController?.addListener(_update);
    playlistController?.addListener(_update);
    collectionController?.addListener(_update);
    recommendController?.addListener(_update);
  }

  @override
  void dispose() {
    for (final subscroption in _subscriptions) {
      subscroption.cancel();
    }
    _subscriptions.clear();

    episodeController?.removeListener(_update);
    playlistController?.removeListener(_update);
    collectionController?.removeListener(_update);
    recommendController?.removeListener(_update);

    super.dispose();
  }

  bool _hasNext = false;
  @override
  bool get hasNext => _hasNext;

  bool _hasPrevious = false;
  @override
  bool get hasPrevious => _hasPrevious;

  PlaylistItemMetadata? _nextMetadata;
  @override
  PlaylistItemMetadata? get nextMetadata => _nextMetadata;

  PlaylistItemMetadata? _previousMetadata;
  @override
  PlaylistItemMetadata? get previousMetadata => _previousMetadata;

  void _update() {
    _hasPrevious = false;
    _hasNext = false;
    _previousMetadata = null;
    _nextMetadata = null;

    // config.autoPlayNextEpisode.value
    if (config.autoPlayNextEpisode.value && (episodeController?.length ?? 0) > 1) {
      final index = episodeController!.index;
      final previous = index <= 0 ? null : episodeController!.episodes[index - 1];
      final next = index >= episodeController!.length - 1 ? null : episodeController!.episodes[index + 1];

      if (previous != null) {
        _hasPrevious = true;
        _previousMetadata = PlaylistItemMetadata(title: previous.title, cover: previous.cover);
      }
      if (next != null) {
        _hasNext = true;
        _previousMetadata = PlaylistItemMetadata(title: next.title, cover: next.cover);
      }

      if (_hasPrevious && _hasNext) {
        notifyListeners();
        return;
      }
    }

    // config.autoPlayNextPlaylist.value
    if (config.autoPlayNextPlaylist.value && (playlistController?.length ?? 0) > 1) {
      final index = playlistController!.getCurrentIndex();

      if (!_hasPrevious) {
        final previous = index <= 0 ? null : playlistController!.videos[index - 1];
        if (previous != null) {
          _hasPrevious = true;
          _previousMetadata = PlaylistItemMetadata(title: previous.title, cover: previous.cover);
        }
      }

      if (!_hasNext) {
        final next = index >= playlistController!.length - 1 ? null : playlistController!.videos[index + 1];
        if (next != null) {
          _hasNext = true;
          _previousMetadata = PlaylistItemMetadata(title: next.title, cover: next.cover);
        }
      }

      if (_hasPrevious && _hasNext) {
        notifyListeners();
        return;
      }
    }

    // config.autoPlayNextCollection.value
    if (config.autoPlayNextCollection.value && (collectionController?.length ?? 0) > 1) {
      final index = collectionController!.getCurrentIndex();

      if (!_hasPrevious) {
        final previous = index <= 0 ? null : collectionController!.videos[index - 1];
        if (previous != null) {
          _hasPrevious = true;
          _previousMetadata = PlaylistItemMetadata(title: previous.title, cover: previous.cover);
        }
      }

      if (!_hasNext) {
        final next = index >= collectionController!.length - 1 ? null : collectionController!.videos[index + 1];
        if (next != null) {
          _hasNext = true;
          _previousMetadata = PlaylistItemMetadata(title: next.title, cover: next.cover);
        }
      }

      if (_hasPrevious && _hasNext) {
        notifyListeners();
        return;
      }
    }

    // config.autoPlayNextRecommend.value
    if (config.autoPlayNextRecommend.value && (recommendController?.length ?? 0) >= 1) {
      if (!_hasNext) {
        final next = recommendController!.videos.first;
        _hasNext = true;
        _previousMetadata = PlaylistItemMetadata(title: next.title, cover: next.cover);
      }
    }

    notifyListeners();
  }

  @override
  void previous() {
    if (!_hasPrevious) return;

    // config.autoPlayNextEpisode.value
    if (config.autoPlayNextEpisode.value && (episodeController?.length ?? 0) > 1) {
      final index = episodeController!.index;
      final previous = index <= 0 ? null : episodeController!.episodes[index - 1];

      if (previous != null) {
        episodeController?.play(previous);
        return;
      }
    }

    // config.autoPlayNextPlaylist.value
    if (config.autoPlayNextPlaylist.value && (playlistController?.length ?? 0) > 1) {
      final index = playlistController!.getCurrentIndex();
      final previous = index <= 0 ? null : playlistController!.videos[index - 1];

      if (previous != null) {
        playlistController!.play(previous);
        return;
      }
    }

    // config.autoPlayNextCollection.value
    if (config.autoPlayNextCollection.value && (collectionController?.length ?? 0) > 1) {
      final index = collectionController!.getCurrentIndex();
      final previous = index <= 0 ? null : collectionController!.videos[index - 1];

      if (previous != null) {
        collectionController!.play(previous);
      }
    }
  }

  @override
  void next() {
    if (!_hasNext) return;

    // config.autoPlayNextEpisode.value
    if (config.autoPlayNextEpisode.value && (episodeController?.length ?? 0) > 1) {
      final index = episodeController!.index;
      final next = index >= episodeController!.length - 1 ? null : episodeController!.episodes[index + 1];

      if (next != null) {
        episodeController!.play(next);
      }
    }

    // config.autoPlayNextPlaylist.value
    if (config.autoPlayNextPlaylist.value && (playlistController?.length ?? 0) > 1) {
      final index = playlistController!.getCurrentIndex();
      final next = index >= playlistController!.length - 1 ? null : playlistController!.videos[index + 1];

      if (next != null) {
        playlistController!.play(next);
      }
    }

    // config.autoPlayNextCollection.value
    if (config.autoPlayNextCollection.value && (collectionController?.length ?? 0) > 1) {
      final index = collectionController!.getCurrentIndex();
      final next = index >= collectionController!.length - 1 ? null : collectionController!.videos[index + 1];

      if (next != null) {
        collectionController!.play(next);
      }
    }

    // config.autoPlayNextRecommend.value
    if (config.autoPlayNextRecommend.value && (recommendController?.length ?? 0) >= 0) {
      final next = recommendController!.videos.first;
      recommendController!.play(next);
    }
  }
}
