import 'package:better_bilibili/data/repositories/bilibili/video_repository/video_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_playlist_info_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_playlist_videos_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:material_ui/material_ui.dart';

class BiliPlaylistController extends ChangeNotifier {
  final String playlistId;
  final String initVideoId;
  final VideoRepository videoRepository;
  final ValueChanged<PlaylistVideo>? onPlay;

  BiliPlaylistController({
    required this.playlistId,
    required this.initVideoId,
    required this.videoRepository,
    this.onPlay,
  }) {
    initLoad = Command0(_initLoad)..execute();
    loadMoreBefore = Command0(_loadMoreBefore);
    loadMoreAfter = Command0(_loadMoreAfter);
  }

  late final Command0 initLoad;

  GetPlaylistInfoResponse? _playlistInfo;
  GetPlaylistInfoResponse? get playlistInfo => _playlistInfo;

  final List<PlaylistVideo> _videos = [];
  List<PlaylistVideo> get videos => List.unmodifiable(_videos);

  int get length => _videos.length;

  bool _hasMoreBefore = true;
  bool _hasMoreAfter = true;
  bool get hasMoreBefore => _hasMoreBefore;
  bool get hasMoreAfter => _hasMoreAfter;

  late String _currentVideoId = initVideoId;
  String get currentVideoId => _currentVideoId;

  Future<Result<void>> _initLoad() async {
    final result = await videoRepository.getPlaylistInfo( playlistId);
    switch (result) {
      case Ok(:final value):
        _playlistInfo = value;
      case Error():
    }

    final result2 = await videoRepository.getPlaylistVideos(
      playlistId: playlistId,
      videoId: initVideoId,
      direction: .both,
    );
    switch (result2) {
      case Ok(:final value):
        _videos.addAll(value.list);
      case Error():
    }

    notifyListeners();
    return result;
  }

  late final Command0 loadMoreBefore;

  Future<Result<void>> _loadMoreBefore() async {
    final result = await videoRepository.getPlaylistVideos(
      playlistId: playlistId,
      videoId: _videos.first.id,
      direction: .before,
    );
    switch (result) {
      case Ok(:final value):
        _videos.insertAll(0, value.list);
        _hasMoreBefore = value.hasMore;
      case Error():
    }

    notifyListeners();
    return result;
  }

  late final Command0 loadMoreAfter;

  Future<Result<void>> _loadMoreAfter() async {
    final result = await videoRepository.getPlaylistVideos(
      playlistId: playlistId,
      videoId: _videos.last.id,
      direction: .after,
    );
    switch (result) {
      case Ok(:final value):
        _videos.addAll(value.list);
        _hasMoreAfter = value.hasMore;
      case Error():
    }

    notifyListeners();
    return result;
  }

  void play(PlaylistVideo video) {
    _currentVideoId = video.id;
    onPlay?.call(video);
    notifyListeners();
  }

  int getCurrentIndex() {
    return videos.indexWhere((v) => v.id == _currentVideoId);
  }
}
