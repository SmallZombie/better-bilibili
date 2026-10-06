import 'package:better_bilibili/data/repositories/bilibili/video_repository/video_repository.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/timeline/waveform/timeline_waveform_controller.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:flutter/material.dart';

class BiliTimelineWaveformController extends ChangeNotifier implements TimelineWaveformController {
  final String videoId;
  final String episodeId;
  final VideoRepository videoRepository;
  bool _disposed = false;

  BiliTimelineWaveformController({
    required this.videoRepository,
    required this.videoId,
    required this.episodeId,
  }) {
    _loadData();
  }

  final List<double> _data = [];

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
  @override
  List<double> get data => List.unmodifiable(_data);

  Future<void> _loadData() async {
    final result = await videoRepository.getTimelineWaveform(videoId: videoId, episodeId: episodeId);
    if (_disposed) return;
    switch (result) {
      case Ok(:final value):
        _data.addAll(value);
      case Error():
    }
  }
}
