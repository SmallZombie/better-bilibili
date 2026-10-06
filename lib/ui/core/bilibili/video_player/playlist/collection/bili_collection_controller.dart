import 'package:better_bilibili/data/services/bilibili/model/get_video_detail_response.dart';
import 'package:flutter/foundation.dart';

class BiliCollectionController extends ChangeNotifier {
  final VideoCollection collection;
  final String initVideoId;
  final ValueChanged<VideoCollectionVideo>? onPlay;

  List<VideoCollectionGroup> get groups => collection.groups;

  late int _currentGroupIndex;
  int get currentGroupIndex => _currentGroupIndex;

  List<VideoCollectionVideo> get videos => collection.groups[_currentGroupIndex].videos;
  int get length => videos.length;

  late String _currentVideoId = initVideoId;
  String get currentVideoId => _currentVideoId;

  BiliCollectionController({
    required this.collection,
    required this.initVideoId,
    this.onPlay,
  }) {
    // 由于一个视频只能加一个合集，这里的查找方法是合适的
    _currentGroupIndex = getGroupIndexWithVideoId(initVideoId);
  }

  void play(VideoCollectionVideo video) {
    final groupIndex = getGroupIndexWithVideo(video);
    if (groupIndex == -1) return;

    _currentGroupIndex = groupIndex;
    _currentVideoId = video.id;

    onPlay?.call(video);
    notifyListeners();
  }

  int getGroupIndexWithVideo(VideoCollectionVideo video) {
    return collection.groups.indexWhere((group) => group.videos.contains(video));
  }

  int getGroupIndexWithVideoId(String videoId) {
    return collection.groups.indexWhere(
      (group) => group.videos.any((v) => v.id == videoId),
    );
  }

  int getCurrentIndex() {
    return videos.indexWhere((v) => v.id == _currentVideoId);
  }
}
