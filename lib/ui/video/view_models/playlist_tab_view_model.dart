import 'package:better_bilibili/data/repositories/bilibili/video_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_playlist_info_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_playlist_videos_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class PlaylistTabViewModel extends SafeChangeNotifier {
  final VideoRepository _videoRepository;

  String playlistId;
  String videoId;

  PlaylistTabViewModel({
    required VideoRepository videoRepository,
    required this.playlistId,
    required this.videoId,
  }) : _videoRepository = videoRepository {
    initLoad = Command0(_initLoad)..execute();
    loadMoreBefore = Command0(_loadMoreBefore);
    loadMoreAfter = Command0(_loadMoreAfter);
  }

  late final Command0 initLoad;

  GetPlaylistInfoResponse? _playlistInfo;
  GetPlaylistInfoResponse? get playlistInfo => _playlistInfo;

  final List<PlaylistVideo> _videos = [];
  List<PlaylistVideo> get videos => List.unmodifiable(_videos);

  bool _hasMoreBefore = true;
  bool _hasMoreAfter = true;
  bool get hasMoreBefore => _hasMoreBefore;
  bool get hasMoreAfter => _hasMoreAfter;

  Future<Result<void>> _initLoad() async {
    final result = await _videoRepository.getPlaylistInfo(playlistId: playlistId);
    switch (result) {
      case Ok(:final value):
        _playlistInfo = value;
      case Error():
    }

    final result2 = await _videoRepository.getPlaylistVideos(
      playlistId: playlistId,
      videoId: videoId,
      direction: GetPlaylistVideosDirectionEnum.both,
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
    final result = await _videoRepository.getPlaylistVideos(
      playlistId: playlistId,
      videoId: _videos.first.id,
      direction: GetPlaylistVideosDirectionEnum.before,
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
    final result = await _videoRepository.getPlaylistVideos(
      playlistId: playlistId,
      videoId: _videos.last.id,
      direction: GetPlaylistVideosDirectionEnum.after,
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
}
