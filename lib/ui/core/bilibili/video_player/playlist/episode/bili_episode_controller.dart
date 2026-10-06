import 'package:better_bilibili/data/services/bilibili/model/get_video_detail_response.dart';
import 'package:flutter/material.dart';

class BiliEpisodeController extends ChangeNotifier {
  final List<VideoDetailEpisode> episodes;
  final int initIndex;
  final Function(VideoDetailEpisode video, Duration? initPosition)? onPlay;

  BiliEpisodeController({required this.episodes, this.initIndex = 0, this.onPlay});

  int get length => episodes.length;

  late int _index = initIndex;
  int get index => _index;

  VideoDetailEpisode get current => episodes[index];

  void play(VideoDetailEpisode episode) {
    final nextIndex = episodes.indexOf(episode);
    if (nextIndex == -1) return;

    _index = nextIndex;
    playByIndex(nextIndex);

    notifyListeners();
  }

  int getIndexByEpisodeId(String episodeId) {
    return episodes.indexWhere((v) => v.id == episodeId);
  }

  void playByIndex(int index, [Duration? initPosition]) {
    assert(index >= 0 && index <= episodes.length - 1);

    _index = index;
    onPlay?.call(episodes[index], initPosition);

    notifyListeners();
  }
}
